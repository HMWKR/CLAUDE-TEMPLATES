#!/usr/bin/env node
/**
 * extract-local-prompts.js
 *
 * 현재 프로젝트의 커밋 메시지에서 16개 섹션 프롬프트를 추출하여
 * prompts.json 파일로 저장합니다.
 *
 * 사용법: node scripts/extract-local-prompts.js
 */

import { execSync } from 'child_process';
import { writeFileSync } from 'fs';

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
function extractPromptInfo(commit) {
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
 * 모든 커밋에서 프롬프트 추출
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
    const prompts = validCommits.map(extractPromptInfo);

    // 결과 JSON 생성
    const result = {
      project: {
        name: repoName || 'unknown',
        owner: owner || 'unknown',
        url: repoUrl || ''
      },
      extractedAt: new Date().toISOString(),
      totalCommits: commits.length,
      promptCommits: prompts.length,
      prompts: prompts
    };

    // prompts.json 저장
    writeFileSync('prompts.json', JSON.stringify(result, null, 2));
    console.log(`Saved ${prompts.length} prompts to prompts.json`);

    return result;

  } catch (error) {
    console.error('Error extracting prompts:', error.message);

    // 빈 결과 저장
    const emptyResult = {
      project: { name: 'unknown', owner: 'unknown', url: '' },
      extractedAt: new Date().toISOString(),
      totalCommits: 0,
      promptCommits: 0,
      prompts: []
    };

    writeFileSync('prompts.json', JSON.stringify(emptyResult, null, 2));
    return emptyResult;
  }
}

// 실행
extractAllPrompts();
