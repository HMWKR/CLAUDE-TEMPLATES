#!/usr/bin/env node
/**
 * harness-eval.js v1.0 — Harness Engineering 평가 파이프라인
 *
 * 5축 자동 측정: CE / AC / GC / EL / SI
 * 사용법: node scripts/harness-eval.js [--project /path] [--json]
 *
 * CE v2.0 + Harness Engineering 프레임워크 기반
 */

import { execSync } from 'child_process';
import { readFileSync, readdirSync, existsSync, statSync, writeFileSync } from 'fs';
import { join, basename } from 'path';

const PROJECT_PATH = process.argv.find(a => a.startsWith('--project='))?.split('=')[1] || '.';
const JSON_MODE = process.argv.includes('--json');

// ========== 측정 함수들 ==========

/**
 * CE (Context Engineering) 측정
 */
function measureCE() {
  const scores = [];
  const details = [];

  // 1. CLAUDE.md 크기 효율성 (300줄 이하 = 10점, 600줄 이하 = 7점, 그 이상 감점)
  const claudeMd = join(PROJECT_PATH, 'CLAUDE.md');
  if (existsSync(claudeMd)) {
    const lines = readFileSync(claudeMd, 'utf8').split('\n').length;
    const globalRef = readFileSync(claudeMd, 'utf8').includes('글로벌') ||
                      readFileSync(claudeMd, 'utf8').includes('~/.claude/CLAUDE.md');

    let score = lines <= 200 ? 10 : lines <= 400 ? 8 : lines <= 600 ? 6 : 4;
    if (globalRef) score = Math.min(score + 1, 10);
    scores.push(score);
    details.push(`CLAUDE.md: ${lines}줄 (${score}/10)${globalRef ? ' +글로벌 참조' : ''}`);
  } else {
    scores.push(0);
    details.push('CLAUDE.md: 없음 (0/10)');
  }

  // 2. 글로벌 중복 여부 (중복 키워드 검사)
  if (existsSync(claudeMd)) {
    const content = readFileSync(claudeMd, 'utf8');
    const duplicateKeywords = ['환각 방지 프로토콜', '5단계 메타인지', '48점', '16개 섹션'];
    const dupCount = duplicateKeywords.filter(k => content.includes(k)).length;
    const score = dupCount === 0 ? 10 : dupCount <= 1 ? 7 : dupCount <= 2 ? 4 : 2;
    scores.push(score);
    details.push(`글로벌 중복: ${dupCount}개 키워드 (${score}/10)`);
  }

  // 3. .thoughts/ 폴더 존재 + 파일 수
  const thoughtsDir = join(PROJECT_PATH, '.thoughts');
  if (existsSync(thoughtsDir)) {
    const files = readdirSync(thoughtsDir).filter(f => f.endsWith('.md'));
    const score = files.length >= 5 ? 10 : files.length >= 1 ? 7 : 5;
    scores.push(score);
    details.push(`.thoughts/: ${files.length}개 파일 (${score}/10)`);
  } else {
    scores.push(3);
    details.push('.thoughts/: 없음 (3/10)');
  }

  // 4. auto memory 존재
  const memoryGlob = join(PROJECT_PATH, '.claude', 'memory');
  // 프로젝트별 memory 경로는 다를 수 있으므로 홈 디렉토리도 확인
  const hasMemory = existsSync(join(PROJECT_PATH, 'MEMORY.md')) ||
                    existsSync(memoryGlob);
  scores.push(hasMemory ? 8 : 4);
  details.push(`auto memory: ${hasMemory ? '있음' : '없음'} (${hasMemory ? 8 : 4}/10)`);

  const avg = scores.reduce((a, b) => a + b, 0) / scores.length;
  return { axis: 'CE', score: Math.round(avg * 10) / 10, details };
}

/**
 * AC (Architectural Constraints) 측정
 */
function measureAC() {
  const scores = [];
  const details = [];

  // 1. commitlint 설정 존재 + 4섹션 검증
  const commitlint = join(PROJECT_PATH, 'commitlint.config.cjs');
  if (existsSync(commitlint)) {
    const content = readFileSync(commitlint, 'utf8');
    const has4Sections = content.includes('require-4-sections');
    const hasLegacy = content.includes('require-16-sections');
    const score = has4Sections ? 10 : hasLegacy ? 5 : 3;
    scores.push(score);
    details.push(`commitlint: ${has4Sections ? '4섹션 v2.0' : hasLegacy ? '레거시 16섹션' : '커스텀'} (${score}/10)`);
  } else {
    scores.push(0);
    details.push('commitlint: 없음 (0/10)');
  }

  // 2. Husky 훅 상태
  const huskyDir = join(PROJECT_PATH, '.husky');
  if (existsSync(huskyDir)) {
    const commitMsg = existsSync(join(huskyDir, 'commit-msg'));
    const postCommit = existsSync(join(huskyDir, 'post-commit'));
    const score = (commitMsg && postCommit) ? 9 : commitMsg ? 7 : 4;
    scores.push(score);
    details.push(`Husky: commit-msg(${commitMsg ? 'O' : 'X'}) post-commit(${postCommit ? 'O' : 'X'}) (${score}/10)`);
  } else {
    scores.push(0);
    details.push('Husky: 없음 (0/10)');
  }

  // 3. .gitmessage 템플릿
  const gitmessage = join(PROJECT_PATH, '.gitmessage');
  if (existsSync(gitmessage)) {
    const content = readFileSync(gitmessage, 'utf8');
    const hasWhat = content.includes('## What');
    const score = hasWhat ? 10 : 5;
    scores.push(score);
    details.push(`.gitmessage: ${hasWhat ? '4섹션 v2.0' : '레거시'} (${score}/10)`);
  } else {
    scores.push(0);
    details.push('.gitmessage: 없음 (0/10)');
  }

  // 4. package.json 존재
  const pkg = join(PROJECT_PATH, 'package.json');
  scores.push(existsSync(pkg) ? 8 : 3);
  details.push(`package.json: ${existsSync(pkg) ? '있음' : '없음'}`);

  const avg = scores.reduce((a, b) => a + b, 0) / scores.length;
  return { axis: 'AC', score: Math.round(avg * 10) / 10, details };
}

/**
 * GC (Garbage Collection) 측정
 */
function measureGC() {
  const scores = [];
  const details = [];

  // 1. 레거시 잔재 검사
  const legacyKeywords = ['16개 섹션', '16섹션', '48점', 'require-16', 'ultrathink 모드'];
  let legacyCount = 0;
  const claudeMd = join(PROJECT_PATH, 'CLAUDE.md');
  if (existsSync(claudeMd)) {
    const content = readFileSync(claudeMd, 'utf8');
    legacyCount = legacyKeywords.filter(k => content.includes(k)).length;
  }
  const score1 = legacyCount === 0 ? 10 : legacyCount <= 1 ? 6 : 3;
  scores.push(score1);
  details.push(`레거시 잔재 (CLAUDE.md): ${legacyCount}개 (${score1}/10)`);

  // 2. deprecated 파일 존재 여부
  const deprecatedFiles = [
    'scripts/create-journal-from-commit.js',
    'CLAUDE_UNIVERSAL_RULES.md',
    '커밋메시지-16섹션-설정가이드.md',
  ];
  const depCount = deprecatedFiles.filter(f => existsSync(join(PROJECT_PATH, f))).length;
  // deprecated 파일이 있어도 archive/에 있으면 OK
  const score2 = depCount === 0 ? 10 : 6;
  scores.push(score2);
  details.push(`deprecated 파일: ${depCount}개 (${score2}/10)`);

  // 3. validate-journals.js 존재 (v2.0)
  const validator = join(PROJECT_PATH, 'scripts', 'validate-journals.js');
  if (existsSync(validator)) {
    const content = readFileSync(validator, 'utf8');
    const isV2 = content.includes('v2.0') || content.includes('.thoughts');
    scores.push(isV2 ? 9 : 6);
    details.push(`validate-journals: ${isV2 ? 'v2.0' : 'v1.x'} (${isV2 ? 9 : 6}/10)`);
  } else {
    scores.push(3);
    details.push('validate-journals: 없음 (3/10)');
  }

  // 4. harness-gc.js 존재 (자동 정리 에이전트)
  const gc = join(PROJECT_PATH, 'scripts', 'harness-gc.js');
  scores.push(existsSync(gc) ? 9 : 3);
  details.push(`harness-gc: ${existsSync(gc) ? '있음' : '없음'} (${existsSync(gc) ? 9 : 3}/10)`);

  const avg = scores.reduce((a, b) => a + b, 0) / scores.length;
  return { axis: 'GC', score: Math.round(avg * 10) / 10, details };
}

/**
 * EL (Evaluation Loop) 측정
 */
function measureEL() {
  const scores = [];
  const details = [];

  // 1. harness-eval.js 자체 존재 (이 파일)
  scores.push(10);
  details.push('harness-eval.js: 존재 (10/10)');

  // 2. extract-local-prompts.js 버전
  const extract = join(PROJECT_PATH, 'scripts', 'extract-local-prompts.js');
  if (existsSync(extract)) {
    const content = readFileSync(extract, 'utf8');
    const isV4 = content.includes('v4.0') || content.includes('.thoughts');
    scores.push(isV4 ? 9 : 5);
    details.push(`extract-prompts: ${isV4 ? 'v4.0' : 'legacy'} (${isV4 ? 9 : 5}/10)`);
  } else {
    scores.push(2);
    details.push('extract-prompts: 없음 (2/10)');
  }

  // 3. .thoughts/ 데이터 축적 (실제 활용 여부)
  const thoughtsDir = join(PROJECT_PATH, '.thoughts');
  if (existsSync(thoughtsDir)) {
    const files = readdirSync(thoughtsDir).filter(f => f.endsWith('.md'));
    const score = files.length >= 10 ? 10 : files.length >= 5 ? 8 : files.length >= 1 ? 6 : 3;
    scores.push(score);
    details.push(`.thoughts/ 데이터: ${files.length}개 (${score}/10)`);
  } else {
    scores.push(2);
    details.push('.thoughts/: 없음 (2/10)');
  }

  // 4. CE 사고 여정 완성도 (채워진 항목 비율)
  if (existsSync(thoughtsDir)) {
    const files = readdirSync(thoughtsDir).filter(f => f.endsWith('.md'));
    if (files.length > 0) {
      let filledCount = 0;
      for (const f of files.slice(0, 5)) {
        const content = readFileSync(join(thoughtsDir, f), 'utf8');
        // 실제로 채워진 섹션이 있는지 확인 (TODO나 빈 표가 아닌)
        const hasContent = !content.includes('| | | |') || content.includes('[x]');
        if (hasContent) filledCount++;
      }
      const ratio = filledCount / Math.min(files.length, 5);
      const score = ratio >= 0.8 ? 9 : ratio >= 0.5 ? 7 : ratio >= 0.2 ? 5 : 3;
      scores.push(score);
      details.push(`사고 여정 완성도: ${Math.round(ratio * 100)}% (${score}/10)`);
    }
  }

  // 5. prompts.json 존재 + v4.0
  const prompts = join(PROJECT_PATH, 'prompts.json');
  if (existsSync(prompts)) {
    try {
      const data = JSON.parse(readFileSync(prompts, 'utf8'));
      const isV4 = data.version === '4.0';
      scores.push(isV4 ? 9 : 5);
      details.push(`prompts.json: ${data.version || '?'} (${isV4 ? 9 : 5}/10)`);
    } catch {
      scores.push(3);
      details.push('prompts.json: 파싱 오류 (3/10)');
    }
  } else {
    scores.push(4);
    details.push('prompts.json: 없음 — node scripts/extract-local-prompts.js 실행 필요 (4/10)');
  }

  const avg = scores.reduce((a, b) => a + b, 0) / scores.length;
  return { axis: 'EL', score: Math.round(avg * 10) / 10, details };
}

/**
 * SI (Simplicity/Iteration) 측정
 */
function measureSI() {
  const scores = [];
  const details = [];

  // 1. init-project.sh 또는 동등한 설정 자동화
  const initScript = join(PROJECT_PATH, 'init-project.sh');
  scores.push(existsSync(initScript) ? 9 : 5);
  details.push(`init-project.sh: ${existsSync(initScript) ? '있음' : '없음'}`);

  // 2. 스크립트 수 적정성 (3-7개 = 최적)
  const scriptsDir = join(PROJECT_PATH, 'scripts');
  if (existsSync(scriptsDir)) {
    const scriptCount = readdirSync(scriptsDir).filter(f => f.endsWith('.js')).length;
    const score = scriptCount >= 3 && scriptCount <= 7 ? 9 : scriptCount <= 10 ? 7 : 5;
    scores.push(score);
    details.push(`스크립트 수: ${scriptCount}개 (${score}/10)`);
  } else {
    scores.push(4);
    details.push('scripts/: 없음 (4/10)');
  }

  // 3. sync-prompts.yml 존재
  const workflow = join(PROJECT_PATH, '.github', 'workflows', 'sync-prompts.yml');
  scores.push(existsSync(workflow) ? 8 : 4);
  details.push(`CI 워크플로우: ${existsSync(workflow) ? '있음' : '없음'}`);

  // 4. 모델 업그레이드 체크리스트 존재
  const upgradeChecklist = join(PROJECT_PATH, 'HARNESS_UPGRADE_CHECKLIST.md');
  scores.push(existsSync(upgradeChecklist) ? 9 : 3);
  details.push(`업그레이드 체크리스트: ${existsSync(upgradeChecklist) ? '있음' : '없음'}`);

  const avg = scores.reduce((a, b) => a + b, 0) / scores.length;
  return { axis: 'SI', score: Math.round(avg * 10) / 10, details };
}

// ========== 메인 ==========

function runEval() {
  const results = [measureCE(), measureAC(), measureGC(), measureEL(), measureSI()];

  const weights = { CE: 0.3, AC: 0.2, GC: 0.15, EL: 0.2, SI: 0.15 };
  const weightedTotal = results.reduce((sum, r) => sum + r.score * weights[r.axis], 0);
  const grade = weightedTotal >= 9.0 ? 'A+' : weightedTotal >= 8.0 ? 'A' :
                weightedTotal >= 7.0 ? 'B+' : weightedTotal >= 6.0 ? 'B' : 'C';

  const output = {
    project: basename(PROJECT_PATH === '.' ? process.cwd() : PROJECT_PATH),
    date: new Date().toISOString().split('T')[0],
    axes: results,
    weightedTotal: Math.round(weightedTotal * 100) / 100,
    grade,
  };

  if (JSON_MODE) {
    console.log(JSON.stringify(output, null, 2));
  } else {
    console.log('');
    console.log('================================================');
    console.log('  Harness Engineering 평가 v1.0');
    console.log('================================================');
    console.log(`  프로젝트: ${output.project}`);
    console.log(`  날짜: ${output.date}`);
    console.log('');

    for (const r of results) {
      const bar = '█'.repeat(Math.round(r.score));
      const empty = '░'.repeat(10 - Math.round(r.score));
      console.log(`  ${r.axis} ${bar}${empty} ${r.score}/10`);
      for (const d of r.details) {
        console.log(`     ${d}`);
      }
      console.log('');
    }

    console.log('------------------------------------------------');
    console.log(`  총점: ${output.weightedTotal}/10  등급: ${output.grade}`);
    console.log('================================================');
  }

  return output;
}

try {
  runEval();
} catch (err) {
  console.error(`[harness-eval] 실행 오류: ${err.message}`);
  process.exit(2);
}
