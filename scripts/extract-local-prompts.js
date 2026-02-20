#!/usr/bin/env node
/**
 * extract-local-prompts.js v4.0
 *
 * 프롬프트/사고여정을 3개 소스에서 추출합니다:
 * 1. 4섹션 커밋 메시지 (v4.0 신규)
 * 2. .prompts/*.md 프롬프트 저널 (레거시 호환)
 * 3. .thoughts/*.md CE 사고 여정 (v4.0 신규)
 *
 * 레거시: 16섹션 커밋도 여전히 파싱 가능
 *
 * 사용법: node scripts/extract-local-prompts.js
 */

import { execSync } from 'child_process';
import { writeFileSync, readFileSync, readdirSync, existsSync } from 'fs';
import { join, basename } from 'path';

// v4.0 필수 섹션
const REQUIRED_SECTIONS_V4 = ['## What', '## Why', '## Impact', 'Co-Authored-By:'];

// 레거시 16섹션 (하위 호환)
const REQUIRED_SECTIONS_LEGACY = [
  '## 산출물', '## 변경 영향도', '## 테스트 전략', '## 롤백 계획',
  '## 관련 이슈', '## Breaking Changes', '## 성능 벤치마크',
  '## 아키텍처 다이어그램', '## UI/UX 와이어프레임', '## 사고 여정',
  '### 원본 프롬프트', '### 프롬프트 분석', '### 최적화된 프롬프트',
  '## 프롬프트 품질 검수', 'Co-Authored-By:'
];

/**
 * 커밋이 유효한 구조인지 확인 (4섹션 또는 레거시 16섹션)
 */
function isValidCommit(message) {
  // v4.0: 4섹션 확인
  const v4Count = REQUIRED_SECTIONS_V4.filter(s => message.includes(s)).length;
  if (v4Count >= 3) return 'v4';

  // 레거시: 16섹션 확인
  const legacyCount = REQUIRED_SECTIONS_LEGACY.filter(s => message.includes(s)).length;
  if (legacyCount >= 10) return 'legacy';

  return null;
}

/**
 * v4 커밋에서 정보 추출
 */
function extractFromV4Commit(commit) {
  const { hash, date, message } = commit;
  const firstLine = message.split('\n')[0];
  const typeMatch = firstLine.match(/^(\w+)(?:\((.+)\))?:\s*(.+)$/);

  const whatMatch = message.match(/^## What\n([\s\S]*?)(?=\n## |$)/m);
  const whyMatch = message.match(/^## Why\n([\s\S]*?)(?=\n## |$)/m);
  const impactMatch = message.match(/^## Impact\n([\s\S]*?)(?=\n## |Co-Authored|$)/m);

  return {
    source: 'commit-v4',
    hash,
    date,
    type: typeMatch ? typeMatch[1] : 'unknown',
    scope: typeMatch ? typeMatch[2] || '' : '',
    subject: typeMatch ? typeMatch[3] : firstLine,
    what: whatMatch ? whatMatch[1].trim() : '',
    why: whyMatch ? whyMatch[1].trim() : '',
    impact: impactMatch ? impactMatch[1].trim() : '',
  };
}

/**
 * 레거시 16섹션 커밋에서 정보 추출
 */
function extractFromLegacyCommit(commit) {
  const { hash, date, message } = commit;
  const firstLine = message.split('\n')[0];
  const typeMatch = firstLine.match(/^(\w+)(?:\((.+)\))?:\s*(.+)$/);

  const originalPromptMatch = message.match(/### 원본 프롬프트\s*```([\s\S]*?)```/);
  const optimizedPromptMatch = message.match(/### 최적화된 프롬프트\s*```([\s\S]*?)```/);
  const scoreMatch = message.match(/\*\*총점\*\*.*?(\d+)\/48/);

  return {
    source: 'commit-legacy',
    hash,
    date,
    type: typeMatch ? typeMatch[1] : 'unknown',
    scope: typeMatch ? typeMatch[2] || '' : '',
    subject: typeMatch ? typeMatch[3] : firstLine,
    originalPrompt: originalPromptMatch ? originalPromptMatch[1].trim() : '',
    optimizedPrompt: optimizedPromptMatch ? optimizedPromptMatch[1].trim() : '',
    qualityScore: scoreMatch ? parseInt(scoreMatch[1]) : null,
  };
}

/**
 * YAML frontmatter 파싱
 */
function parseYamlFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return {};

  const result = {};
  for (const line of match[1].split('\n')) {
    if (line.trim().startsWith('#')) continue;
    const m = line.match(/^(\w+):\s*(.*)$/);
    if (m) {
      let value = m[2].trim();
      if (value.startsWith('[') && value.endsWith(']')) {
        value = value.slice(1, -1).split(',').map(s => s.trim()).filter(Boolean);
      } else if (value === 'null' || value === '') {
        value = null;
      } else if ((value.startsWith('"') && value.endsWith('"'))) {
        value = value.slice(1, -1);
      }
      result[m[1]] = value;
    }
  }
  return result;
}

/**
 * .prompts/ 저널 추출 (레거시 호환)
 */
function extractAllJournals() {
  const dir = '.prompts';
  if (!existsSync(dir)) return [];

  const files = readdirSync(dir).filter(f => f.endsWith('.md')).map(f => join(dir, f));
  console.log(`Found ${files.length} journal files in .prompts/`);

  return files.map(filePath => {
    try {
      const content = readFileSync(filePath, 'utf8');
      const fm = parseYamlFrontmatter(content);
      const titleMatch = content.match(/^#\s+(.+)$/m);
      return {
        source: 'journal',
        hash: fm.commit || null,
        date: fm.date || null,
        type: fm.domain || 'general',
        subject: titleMatch ? titleMatch[1].trim() : basename(filePath, '.md'),
        journalFile: basename(filePath),
        qualityScore: fm.quality_score || null,
        grade: fm.grade || null,
      };
    } catch (e) {
      console.error(`Error parsing ${filePath}:`, e.message);
      return null;
    }
  }).filter(Boolean);
}

/**
 * .thoughts/ CE 사고 여정 추출 (v4.0 신규)
 */
function extractAllThinkingLogs() {
  const dir = '.thoughts';
  if (!existsSync(dir)) return [];

  const files = readdirSync(dir).filter(f => f.endsWith('.md')).map(f => join(dir, f));
  console.log(`Found ${files.length} thinking logs in .thoughts/`);

  return files.map(filePath => {
    try {
      const content = readFileSync(filePath, 'utf8');
      const fm = parseYamlFrontmatter(content);
      const titleMatch = content.match(/^#\s+(.+)$/m);

      // CE 전략 추출
      const strategies = [];
      if (content.includes('[x] Write') || content.includes('[X] Write')) strategies.push('write');
      if (content.includes('[x] Select') || content.includes('[X] Select')) strategies.push('select');
      if (content.includes('[x] Compress') || content.includes('[X] Compress')) strategies.push('compress');
      if (content.includes('[x] Isolate') || content.includes('[X] Isolate')) strategies.push('isolate');

      // 실패 모드 감지 여부 추출
      const failureModes = {};
      for (const mode of ['Poisoning', 'Distraction', 'Confusion', 'Clash']) {
        const modeRegex = new RegExp(`${mode}[^|]*\\|[^|]*\\|([^|]+)\\|`, 'i');
        const m = content.match(modeRegex);
        failureModes[mode.toLowerCase()] = m ? m[1].trim() !== '' : false;
      }

      return {
        source: 'thinking',
        hash: fm.commit || null,
        date: fm.date || null,
        type: fm.type || 'unknown',
        subject: fm.subject || (titleMatch ? titleMatch[1].trim() : basename(filePath, '.md')),
        thinkingFile: basename(filePath),
        ceStrategies: fm.ce_strategies || strategies,
        failureModes,
      };
    } catch (e) {
      console.error(`Error parsing ${filePath}:`, e.message);
      return null;
    }
  }).filter(Boolean);
}

/**
 * 모든 커밋에서 프롬프트 추출
 */
function extractAllCommitPrompts() {
  try {
    const gitLog = execSync(
      'git log --format="COMMIT_START%n%H%n%aI%n%B%nCOMMIT_END" -500',
      { encoding: 'utf8', maxBuffer: 50 * 1024 * 1024 }
    );

    const commits = gitLog.split('COMMIT_START').filter(c => c.trim()).map(block => {
      const lines = block.trim().split('\n');
      return { hash: lines[0], date: lines[1], message: lines.slice(2, -1).join('\n').replace('COMMIT_END', '').trim() };
    });

    console.log(`Found ${commits.length} commits`);

    const results = [];
    for (const commit of commits) {
      const version = isValidCommit(commit.message);
      if (version === 'v4') {
        results.push(extractFromV4Commit(commit));
      } else if (version === 'legacy') {
        results.push(extractFromLegacyCommit(commit));
      }
    }

    console.log(`Found ${results.length} valid commits`);
    return results;
  } catch (e) {
    console.error('Error extracting commits:', e.message);
    return [];
  }
}

/**
 * 메인
 */
function extractAllPrompts() {
  try {
    let repoUrl = '', repoName = '', owner = '';
    try {
      repoUrl = execSync('git config --get remote.origin.url', { encoding: 'utf8' }).trim();
      const match = repoUrl.match(/github\.com[:/]([^/]+)\/([^/.]+)/);
      if (match) { owner = match[1]; repoName = match[2]; }
    } catch {}

    const commitPrompts = extractAllCommitPrompts();
    const journalPrompts = extractAllJournals();
    const thinkingLogs = extractAllThinkingLogs();

    // 중복 제거 (같은 commit hash → thinking > journal > commit 우선)
    const seen = new Set();
    const all = [...thinkingLogs, ...journalPrompts, ...commitPrompts].filter(item => {
      if (item.hash && seen.has(item.hash)) return false;
      if (item.hash) seen.add(item.hash);
      return true;
    });

    all.sort((a, b) => {
      const da = a.date ? new Date(a.date) : new Date(0);
      const db = b.date ? new Date(b.date) : new Date(0);
      return db - da;
    });

    const result = {
      version: '4.0',
      project: { name: repoName || 'unknown', owner: owner || 'unknown', url: repoUrl || '' },
      extractedAt: new Date().toISOString(),
      stats: {
        total: all.length,
        fromCommitsV4: commitPrompts.filter(c => c.source === 'commit-v4').length,
        fromCommitsLegacy: commitPrompts.filter(c => c.source === 'commit-legacy').length,
        fromJournals: journalPrompts.length,
        fromThinking: thinkingLogs.length,
      },
      prompts: all
    };

    writeFileSync('prompts.json', JSON.stringify(result, null, 2));
    console.log(`\nSaved ${all.length} entries to prompts.json (v4.0)`);
    console.log(`  - Commits (v4): ${result.stats.fromCommitsV4}`);
    console.log(`  - Commits (legacy): ${result.stats.fromCommitsLegacy}`);
    console.log(`  - Journals: ${result.stats.fromJournals}`);
    console.log(`  - Thinking logs: ${result.stats.fromThinking}`);

  } catch (e) {
    console.error('Error:', e.message);
    writeFileSync('prompts.json', JSON.stringify({
      version: '4.0', project: {}, extractedAt: new Date().toISOString(),
      stats: { total: 0 }, prompts: []
    }, null, 2));
  }
}

extractAllPrompts();
