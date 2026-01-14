#!/usr/bin/env node
/**
 * extract-local-prompts.js v3.0
 *
 * 프롬프트를 두 소스에서 추출합니다:
 * 1. 16개 섹션 커밋 메시지 (기존)
 * 2. .prompts/*.md 프롬프트 저널 (신규)
 *
 * 사용법: node scripts/extract-local-prompts.js
 */

import { execSync } from 'child_process';
import { writeFileSync, readFileSync, readdirSync, existsSync } from 'fs';
import { join, basename } from 'path';

// 16개 필수 섹션 패턴
const REQUIRED_SECTIONS = [
  '## 산출물',
  '## 변경 영향도',
  '## 테스트 전략',
  '## 롤백 계획',
  '## 관련 이슈',
  '## Breaking Changes',
  '## 성능 벤치마크',
  '## 아키텍처 다이어그램',
  '## UI/UX 와이어프레임',
  '## 사고 여정',
  '### 원본 프롬프트',
  '### 프롬프트 분석',
  '### 최적화된 프롬프트',
  '## 프롬프트 품질 검수',
  'Co-Authored-By:'
];

/**
 * Git 커밋 메시지가 16개 섹션을 포함하는지 확인
 */
function has16Sections(message) {
  let count = 0;
  for (const section of REQUIRED_SECTIONS) {
    if (message.includes(section)) {
      count++;
    }
  }
  // 최소 10개 이상의 섹션이 있으면 유효한 프롬프트로 간주
  return count >= 10;
}

/**
 * 커밋 메시지에서 프롬프트 정보 추출
 */
function extractPromptFromCommit(commit) {
  const { hash, date, message } = commit;

  // 타입과 제목 추출 (첫 줄)
  const firstLine = message.split('\n')[0];
  const typeMatch = firstLine.match(/^(\w+)(?:\((.+)\))?:\s*(.+)$/);

  const type = typeMatch ? typeMatch[1] : 'unknown';
  const scope = typeMatch ? typeMatch[2] || '' : '';
  const subject = typeMatch ? typeMatch[3] : firstLine;

  // 원본 프롬프트 추출
  const originalPromptMatch = message.match(/### 원본 프롬프트\s*```([\s\S]*?)```/);
  const originalPrompt = originalPromptMatch
    ? originalPromptMatch[1].trim()
    : '';

  // 최적화된 프롬프트 추출
  const optimizedPromptMatch = message.match(/### 최적화된 프롬프트\s*```([\s\S]*?)```/);
  const optimizedPrompt = optimizedPromptMatch
    ? optimizedPromptMatch[1].trim()
    : '';

  // 프롬프트 분석 추출
  const analysisMatch = message.match(/### 프롬프트 분석\s*>([\s\S]*?)(?=###|## |$)/);
  const analysis = analysisMatch
    ? analysisMatch[1].trim()
    : '';

  // 품질 점수 추출
  const scoreMatch = message.match(/\*\*총점\*\*.*?(\d+)\/48/);
  const qualityScore = scoreMatch ? parseInt(scoreMatch[1]) : null;

  // 등급 추출
  const gradeMatch = message.match(/등급:\s*\[?\s*([A-F][+-]?|[가-힣]+)\s*\]?/);
  const grade = gradeMatch ? gradeMatch[1] : null;

  return {
    source: 'commit',  // 소스 구분 (v3.0 추가)
    hash,
    date,
    type,
    scope,
    subject,
    originalPrompt,
    optimizedPrompt,
    analysis,
    qualityScore,
    grade,
    fullMessage: message
  };
}

/**
 * YAML frontmatter 파싱
 */
function parseYamlFrontmatter(content) {
  const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/);
  if (!frontmatterMatch) {
    return {};
  }

  const yaml = frontmatterMatch[1];
  const result = {};

  // 간단한 YAML 파서 (key: value 형식)
  const lines = yaml.split('\n');
  for (const line of lines) {
    // 주석 무시
    if (line.trim().startsWith('#')) continue;

    const match = line.match(/^(\w+):\s*(.*)$/);
    if (match) {
      const key = match[1];
      let value = match[2].trim();

      // 배열 처리 [item1, item2]
      if (value.startsWith('[') && value.endsWith(']')) {
        value = value.slice(1, -1).split(',').map(s => s.trim());
      }
      // 숫자 처리
      else if (!isNaN(value) && value !== '') {
        value = Number(value);
      }
      // null 처리
      else if (value === 'null' || value === '') {
        value = null;
      }
      // 문자열 따옴표 제거
      else if ((value.startsWith('"') && value.endsWith('"')) ||
               (value.startsWith("'") && value.endsWith("'"))) {
        value = value.slice(1, -1);
      }

      result[key] = value;
    }
  }

  return result;
}

/**
 * 마크다운 섹션 추출
 */
function extractMarkdownSection(content, sectionName) {
  // ## 섹션명 또는 # 섹션명 형식 지원
  const escapedName = sectionName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const regex = new RegExp(`#+\\s*(?:[^\\n]*)?${escapedName}[^\\n]*\\n([\\s\\S]*?)(?=\\n#|$)`, 'i');
  const match = content.match(regex);
  return match ? match[1].trim() : '';
}

/**
 * 프롬프트 저널 파일에서 정보 추출
 */
function extractPromptFromJournal(filePath) {
  try {
    const content = readFileSync(filePath, 'utf8');
    const frontmatter = parseYamlFrontmatter(content);

    // 마크다운 본문에서 섹션 추출
    const originalPromptSection = extractMarkdownSection(content, '원본 프롬프트');
    const optimizedPromptSection = extractMarkdownSection(content, '최적화된 프롬프트');
    const thinkingSection = extractMarkdownSection(content, '사고 여정');
    const learningSection = extractMarkdownSection(content, '핵심 학습');
    const resultSection = extractMarkdownSection(content, '결과');

    // 원본 프롬프트에서 인용문(>) 추출
    const quoteMatch = originalPromptSection.match(/^>\s*(.+)$/m);
    const originalPrompt = quoteMatch ? quoteMatch[1].trim() : originalPromptSection;

    // 최적화된 프롬프트에서 코드 블록 추출
    const codeBlockMatch = optimizedPromptSection.match(/```[\s\S]*?\n([\s\S]*?)```/);
    const optimizedPrompt = codeBlockMatch ? codeBlockMatch[1].trim() : optimizedPromptSection;

    // 제목 추출 (첫 번째 # 헤더)
    const titleMatch = content.match(/^#\s+(.+)$/m);
    const subject = titleMatch ? titleMatch[1].trim() : basename(filePath, '.md');

    return {
      source: 'journal',  // 소스 구분
      hash: frontmatter.commit || null,
      date: frontmatter.date || null,
      type: frontmatter.domain || 'general',
      scope: frontmatter.subdomain || '',
      subject: subject,
      originalPrompt: originalPrompt,
      optimizedPrompt: optimizedPrompt,
      analysis: thinkingSection,
      qualityScore: frontmatter.quality_score || null,
      grade: frontmatter.grade || null,
      // 저널 전용 필드
      journalFile: basename(filePath),
      tags: frontmatter.tags || [],
      complexity: frontmatter.complexity || null,
      thinking: thinkingSection,
      learning: learningSection,
      result: resultSection
    };

  } catch (error) {
    console.error(`Error parsing journal file ${filePath}:`, error.message);
    return null;
  }
}

/**
 * .prompts/ 폴더에서 모든 저널 추출
 */
function extractAllJournals() {
  const promptsDir = '.prompts';

  if (!existsSync(promptsDir)) {
    console.log('.prompts/ folder not found, skipping journal extraction');
    return [];
  }

  const files = readdirSync(promptsDir)
    .filter(f => f.endsWith('.md'))
    .map(f => join(promptsDir, f));

  console.log(`Found ${files.length} journal files in .prompts/`);

  const journals = files
    .map(extractPromptFromJournal)
    .filter(j => j !== null);

  console.log(`Extracted ${journals.length} valid journals`);

  return journals;
}

/**
 * 모든 커밋에서 프롬프트 추출
 */
function extractAllCommitPrompts() {
  try {
    // 모든 커밋 가져오기 (최근 500개까지)
    const gitLog = execSync(
      'git log --format="COMMIT_START%n%H%n%aI%n%B%nCOMMIT_END" -500',
      { encoding: 'utf8', maxBuffer: 50 * 1024 * 1024 }
    );

    // 커밋 파싱
    const commits = gitLog
      .split('COMMIT_START')
      .filter(c => c.trim())
      .map(block => {
        const lines = block.trim().split('\n');
        const hash = lines[0];
        const date = lines[1];
        const message = lines.slice(2, -1).join('\n').replace('COMMIT_END', '').trim();
        return { hash, date, message };
      });

    console.log(`Found ${commits.length} commits`);

    // 16개 섹션이 있는 커밋만 필터링
    const validCommits = commits.filter(c => has16Sections(c.message));
    console.log(`Found ${validCommits.length} commits with 16 sections`);

    // 프롬프트 정보 추출
    return validCommits.map(extractPromptFromCommit);

  } catch (error) {
    console.error('Error extracting commit prompts:', error.message);
    return [];
  }
}

/**
 * 메인 함수: 모든 소스에서 프롬프트 추출
 */
function extractAllPrompts() {
  try {
    // Git 저장소 정보 가져오기
    let repoUrl = '';
    let repoName = '';
    let owner = '';

    try {
      repoUrl = execSync('git config --get remote.origin.url', { encoding: 'utf8' }).trim();
      // GitHub URL에서 owner/repo 추출
      const match = repoUrl.match(/github\.com[:/]([^/]+)\/([^/.]+)/);
      if (match) {
        owner = match[1];
        repoName = match[2];
      }
    } catch (e) {
      console.warn('Warning: Could not get remote URL');
    }

    // 1. 커밋에서 프롬프트 추출 (기존 로직)
    const commitPrompts = extractAllCommitPrompts();

    // 2. 저널에서 프롬프트 추출 (v3.0 추가)
    const journalPrompts = extractAllJournals();

    // 3. 두 소스 통합 (중복 제거: 같은 commit hash가 있으면 저널 우선)
    const commitHashes = new Set(journalPrompts.filter(j => j.hash).map(j => j.hash));
    const filteredCommitPrompts = commitPrompts.filter(c => !commitHashes.has(c.hash));

    const allPrompts = [...journalPrompts, ...filteredCommitPrompts];

    // 날짜순 정렬 (최신 먼저)
    allPrompts.sort((a, b) => {
      const dateA = a.date ? new Date(a.date) : new Date(0);
      const dateB = b.date ? new Date(b.date) : new Date(0);
      return dateB - dateA;
    });

    // 결과 JSON 생성 (v3.0 스키마)
    const result = {
      version: '3.0',
      project: {
        name: repoName || 'unknown',
        owner: owner || 'unknown',
        url: repoUrl || ''
      },
      extractedAt: new Date().toISOString(),
      stats: {
        totalCommits: commitPrompts.length + filteredCommitPrompts.length,
        fromCommits: filteredCommitPrompts.length,
        fromJournals: journalPrompts.length,
        total: allPrompts.length
      },
      prompts: allPrompts
    };

    // prompts.json 저장
    writeFileSync('prompts.json', JSON.stringify(result, null, 2));
    console.log(`\nSaved ${allPrompts.length} prompts to prompts.json`);
    console.log(`  - From commits: ${filteredCommitPrompts.length}`);
    console.log(`  - From journals: ${journalPrompts.length}`);

    return result;

  } catch (error) {
    console.error('Error extracting prompts:', error.message);

    // 빈 결과 저장
    const emptyResult = {
      version: '3.0',
      project: { name: 'unknown', owner: 'unknown', url: '' },
      extractedAt: new Date().toISOString(),
      stats: { totalCommits: 0, fromCommits: 0, fromJournals: 0, total: 0 },
      prompts: []
    };

    writeFileSync('prompts.json', JSON.stringify(emptyResult, null, 2));
    return emptyResult;
  }
}

// 실행
extractAllPrompts();
