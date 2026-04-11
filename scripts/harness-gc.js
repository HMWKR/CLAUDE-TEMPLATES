#!/usr/bin/env node
/**
 * harness-gc.js v1.0 — Harness Garbage Collection 에이전트
 *
 * 프로젝트의 하니스 정합성을 자동 점검하고 불일치를 보고합니다.
 * 사용법: node scripts/harness-gc.js [--fix] [--project /path]
 *
 * 점검 항목:
 * 1. 레거시 잔재 (16섹션, 48점, ultrathink 등)
 * 2. _core 참조 유효성
 * 3. 스킬 description과 실제 내용 불일치
 * 4. deprecated 파일 존재
 * 5. 스크립트 버전 일관성
 */

import { readFileSync, readdirSync, existsSync, unlinkSync, renameSync } from 'fs';
import { join, basename } from 'path';

const PROJECT_PATH = process.argv.find(a => a.startsWith('--project='))?.split('=')[1] || '.';
const FIX_MODE = process.argv.includes('--fix');

const issues = [];
const warnings = [];
const fixed = [];

// ========== 점검 함수들 ==========

/**
 * 1. 레거시 잔재 점검
 */
function checkLegacyRemnants() {
  const legacyPatterns = [
    { pattern: '16개 섹션', severity: 'high', context: 'PE 시대 커밋 규칙' },
    { pattern: 'require-16-sections', severity: 'critical', context: 'commitlint 레거시 규칙' },
    { pattern: '48점', severity: 'medium', context: 'PE 품질 채점 시스템' },
    { pattern: '5계층.*평가', severity: 'medium', context: 'PE 품질 채점' },
    { pattern: 'ultrathink 모드', severity: 'high', context: '더 이상 작동하지 않는 키워드' },
    { pattern: '프롬프트 엔지니어링', severity: 'low', context: 'CE로 전환됨' },
  ];

  const filesToCheck = ['CLAUDE.md', 'README.md', 'commitlint.config.cjs'];

  for (const file of filesToCheck) {
    const filePath = join(PROJECT_PATH, file);
    if (!existsSync(filePath)) continue;

    const content = readFileSync(filePath, 'utf8');
    for (const { pattern, severity, context } of legacyPatterns) {
      const regex = new RegExp(pattern, 'g');
      const matches = content.match(regex);
      if (matches && matches.length > 0) {
        issues.push({
          type: 'legacy',
          severity,
          file,
          pattern,
          count: matches.length,
          context,
        });
      }
    }
  }
}

/**
 * 2. commitlint 버전 일관성
 */
function checkCommitlintVersion() {
  const commitlint = join(PROJECT_PATH, 'commitlint.config.cjs');
  if (!existsSync(commitlint)) {
    warnings.push('commitlint.config.cjs 없음');
    return;
  }

  const content = readFileSync(commitlint, 'utf8');

  if (content.includes('require-16-sections')) {
    issues.push({
      type: 'version',
      severity: 'critical',
      file: 'commitlint.config.cjs',
      message: '레거시 16섹션 검증 규칙 사용 중. 4섹션(v2.0)으로 업데이트 필요',
    });
  }

  if (!content.includes('require-4-sections') && !content.includes('require-16-sections')) {
    warnings.push('commitlint: 커스텀 규칙 사용 중 (4섹션도 16섹션도 아님)');
  }
}

/**
 * 3. .gitmessage 버전 확인
 */
function checkGitmessage() {
  const gitmessage = join(PROJECT_PATH, '.gitmessage');
  if (!existsSync(gitmessage)) {
    warnings.push('.gitmessage 없음');
    return;
  }

  const content = readFileSync(gitmessage, 'utf8');
  const lines = content.split('\n').length;

  if (lines > 30) {
    issues.push({
      type: 'legacy',
      severity: 'medium',
      file: '.gitmessage',
      message: `${lines}줄 — 레거시 16섹션 템플릿 가능성. 14줄(v2.0)으로 교체 권장`,
    });
  }

  if (!content.includes('## What')) {
    issues.push({
      type: 'version',
      severity: 'high',
      file: '.gitmessage',
      message: '4섹션 구조(## What/Why/Impact) 미사용',
    });
  }
}

/**
 * 4. scripts 버전 일관성
 */
function checkScriptsVersion() {
  const scripts = {
    'scripts/extract-local-prompts.js': { expected: 'v4.0', check: 'version.*4.0' },
    'scripts/validate-journals.js': { expected: 'v2.0', check: 'v2.0' },
    'scripts/create-thinking-log.js': { expected: 'v1.0', check: 'v1.0' },
  };

  for (const [file, { expected, check }] of Object.entries(scripts)) {
    const filePath = join(PROJECT_PATH, file);
    if (!existsSync(filePath)) {
      warnings.push(`${file}: 없음 (${expected} 필요)`);
      continue;
    }

    const content = readFileSync(filePath, 'utf8');
    const regex = new RegExp(check);
    if (!regex.test(content)) {
      issues.push({
        type: 'version',
        severity: 'medium',
        file,
        message: `${expected} 아님 — 업데이트 필요`,
      });
    }
  }
}

/**
 * 5. deprecated 파일 존재 확인
 */
function checkDeprecatedFiles() {
  const deprecated = [
    { file: 'CLAUDE_UNIVERSAL_RULES.md', reason: '글로벌 CLAUDE.md로 대체' },
    { file: '커밋메시지-16섹션-설정가이드.md', reason: '4섹션으로 전환' },
    { file: 'CLAUDE_OPTIMIZATION_ANALYSIS.md', reason: 'CE v2.0으로 대체' },
  ];

  for (const { file, reason } of deprecated) {
    if (existsSync(join(PROJECT_PATH, file))) {
      warnings.push(`deprecated 파일 존재: ${file} (${reason}). archive/ 이동 권장`);
    }
  }
}

/**
 * 6. .thoughts/ 상태 확인
 */
function checkThoughtsDir() {
  const thoughtsDir = join(PROJECT_PATH, '.thoughts');
  if (!existsSync(thoughtsDir)) {
    issues.push({
      type: 'missing',
      severity: 'medium',
      file: '.thoughts/',
      message: 'CE 사고 여정 폴더 없음. mkdir -p .thoughts && touch .thoughts/.gitkeep',
    });
    return;
  }

  const files = readdirSync(thoughtsDir).filter(f => f.endsWith('.md'));
  if (files.length === 0) {
    warnings.push('.thoughts/: 파일 0개. 작업 후 사고 여정 기록 권장');
  }
}

// ========== 메인 ==========

function runGC() {
  checkLegacyRemnants();
  checkCommitlintVersion();
  checkGitmessage();
  checkScriptsVersion();
  checkDeprecatedFiles();
  checkThoughtsDir();

  // 결과 출력
  console.log('');
  console.log('================================================');
  console.log('  Harness GC (Garbage Collection) v1.0');
  console.log('================================================');
  console.log(`  프로젝트: ${basename(PROJECT_PATH === '.' ? process.cwd() : PROJECT_PATH)}`);
  console.log('');

  if (issues.length === 0 && warnings.length === 0) {
    console.log('  ✅ 정합성 검사 통과! 불일치 없음.');
  } else {
    if (issues.length > 0) {
      console.log(`  ❌ 이슈 ${issues.length}개:`);
      for (const issue of issues) {
        const icon = issue.severity === 'critical' ? '🔴' :
                     issue.severity === 'high' ? '🟠' :
                     issue.severity === 'medium' ? '🟡' : '🔵';
        console.log(`     ${icon} [${issue.severity}] ${issue.file}: ${issue.message || issue.pattern + ' (' + issue.count + '회)'}`);
      }
      console.log('');
    }

    if (warnings.length > 0) {
      console.log(`  ⚠️  경고 ${warnings.length}개:`);
      for (const w of warnings) {
        console.log(`     ⚠️  ${w}`);
      }
    }
  }

  if (fixed.length > 0) {
    console.log('');
    console.log(`  🔧 자동 수정 ${fixed.length}개:`);
    for (const f of fixed) {
      console.log(`     ✓ ${f}`);
    }
  }

  console.log('');
  console.log('================================================');

  // 종료 코드
  const criticalCount = issues.filter(i => i.severity === 'critical').length;
  process.exit(criticalCount > 0 ? 1 : 0);
}

runGC();
