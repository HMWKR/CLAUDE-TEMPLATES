#!/usr/bin/env node
/**
 * create-journal-from-commit.js v1.0
 *
 * 16섹션 커밋 메시지에서 프롬프트 저널을 자동 생성합니다.
 * post-commit 훅에서 호출됩니다.
 *
 * 사용법: node scripts/create-journal-from-commit.js
 */

import { execSync } from 'child_process';
import { writeFileSync, existsSync, mkdirSync } from 'fs';
import { join } from 'path';

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
 * 커밋 메시지에서 섹션 내용 추출
 */
function extractSection(message, sectionName, endMarkers = ['##', '###', 'Co-Authored-By:']) {
  const escapedName = sectionName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const pattern = new RegExp(`${escapedName}[\\s\\S]*?\\n([\\s\\S]*?)(?=\\n(?:${endMarkers.join('|')})|$)`);
  const match = message.match(pattern);
  return match ? match[1].trim() : '';
}

/**
 * 코드 블록 내용 추출
 */
function extractCodeBlock(content) {
  const match = content.match(/```[\s\S]*?\n([\s\S]*?)```/);
  return match ? match[1].trim() : content.trim();
}

/**
 * 품질 점수 추출
 */
function extractQualityScore(message) {
  const scoreMatch = message.match(/\*\*총점\*\*.*?(\d+)\/48/);
  return scoreMatch ? parseInt(scoreMatch[1]) : null;
}

/**
 * 등급 추출
 */
function extractGrade(message) {
  const gradeMatch = message.match(/등급:\s*\[?\s*([A-FS][+-]?)\s*\]?/);
  return gradeMatch ? gradeMatch[1] : null;
}

/**
 * 커밋 타입/스코프 추출
 */
function parseCommitHeader(message) {
  const firstLine = message.split('\n')[0];
  const match = firstLine.match(/^(\w+)(?:\(([^)]+)\))?:\s*(.+)$/);

  return {
    type: match ? match[1] : 'unknown',
    scope: match ? match[2] || '' : '',
    subject: match ? match[3] : firstLine
  };
}

/**
 * 복잡도 추정 (커밋 메시지 길이 기반)
 */
function estimateComplexity(message) {
  const length = message.length;
  if (length > 5000) return 'high';
  if (length > 2000) return 'medium';
  return 'low';
}

/**
 * 도메인 매핑
 */
function mapTypeToDomain(type) {
  const domainMap = {
    feat: 'backend',
    fix: 'backend',
    docs: 'docs',
    style: 'frontend',
    refactor: 'refactor',
    perf: 'performance',
    test: 'test',
    build: 'devops',
    ci: 'devops',
    chore: 'general',
    security: 'security'
  };
  return domainMap[type] || 'general';
}

/**
 * 저널 파일명 생성
 */
function generateJournalFilename(date, type, scope, subject) {
  // 제목에서 파일명에 적합한 slug 생성
  let slug = scope || subject.toLowerCase()
    .replace(/[^a-z0-9가-힣\s-]/g, '')
    .replace(/\s+/g, '-')
    .substring(0, 30);

  return `${date}-${type}-${slug}.md`;
}

/**
 * 저널 마크다운 내용 생성
 */
function generateJournalContent(data) {
  const {
    date,
    time,
    commitHash,
    type,
    scope,
    subject,
    domain,
    complexity,
    qualityScore,
    grade,
    originalPrompt,
    optimizedPrompt,
    thinkingJourney,
    promptAnalysis
  } = data;

  return `---
date: ${date}
time: "${time}"
commit: ${commitHash}
branch: main
domain: ${domain}
subdomain: ${scope || 'null'}
complexity: ${complexity}
quality_score: ${qualityScore || 'null'}
grade: ${grade || 'null'}
tags: []
---

# ${subject}

## 원본 프롬프트

> ${originalPrompt || '(커밋 메시지에서 추출됨)'}

## 사고 여정

### 처음 생각
<!-- TODO: 처음에 어떻게 접근하려고 했는가? -->
${thinkingJourney ? thinkingJourney.split('\n').slice(0, 5).join('\n') : '(자동 생성됨 - 편집 필요)'}

### 전환점
<!-- TODO: 무엇이 생각을 바꾸게 했는가? -->
- 전환점 1: ...
- 전환점 2: ...

### 최종 통찰
<!-- TODO: 결국 어떤 결론에 도달했는가? -->
(자동 생성됨 - 편집 필요)

## 최적화된 프롬프트

\`\`\`
${optimizedPrompt || '(커밋 메시지에서 추출됨)'}
\`\`\`

## 품질 분석

| 계층 | 항목 | 점수 | 메모 |
|:----:|------|:----:|------|
| L1 | 구조적 완성도 | /18 | 자동 추출 |
| L2 | 엔지니어링 기법 | /8 |  |
| L3 | 맥락 최적화 | /6 |  |
| L4 | 효과 검증 | /4 |  |
| L5 | 할루시네이션 | /12 |  |
| **총점** | | **${qualityScore || '?'}/48** | ${grade || ''} |

## 핵심 학습

<!-- TODO: 이번 작업에서 배운 점을 정리하세요 -->

1. **학습 포인트 1**
   - (자동 생성됨 - 편집 필요)

2. **학습 포인트 2**
   - (자동 생성됨 - 편집 필요)

## 결과

- **성공 여부**: [ ] 성공 / [ ] 실패 / [ ] 부분 성공
- **반복 횟수**:
- **변경 파일**:
- **테스트**: [ ] 통과 / [ ] 실패 / [ ] 해당없음

## 관련 파일

<!-- 커밋에서 변경된 파일 목록 -->
(자동 추출 예정)

---

*자동 생성: ${date} ${time}*
*Claude Opus 4.5 + User 협업*
*커밋: ${commitHash}*
`;
}

/**
 * 메인 함수
 */
function main() {
  try {
    console.log('📝 프롬프트 저널 자동 생성 시작...\n');

    // 1. 최근 커밋 정보 조회
    const commitHash = execSync('git rev-parse --short HEAD', { encoding: 'utf8' }).trim();
    const commitDate = execSync('git log -1 --format=%cs', { encoding: 'utf8' }).trim();
    const commitTime = execSync('git log -1 --format=%H:%M', { encoding: 'utf8' }).trim().substring(0, 5);
    const commitMsg = execSync('git log -1 --format=%B', { encoding: 'utf8' }).trim();

    console.log(`커밋: ${commitHash}`);
    console.log(`날짜: ${commitDate}`);

    // 2. 16섹션 포함 확인
    if (!has16Sections(commitMsg)) {
      console.log('\n⏭️  16섹션 커밋이 아닙니다. 저널 생성을 건너뜁니다.');
      console.log('   (일반 커밋은 저널 생성 대상이 아닙니다)\n');
      return;
    }

    console.log('✓ 16섹션 커밋 확인됨\n');

    // 3. 커밋 메시지 파싱
    const { type, scope, subject } = parseCommitHeader(commitMsg);
    const domain = mapTypeToDomain(type);
    const complexity = estimateComplexity(commitMsg);
    const qualityScore = extractQualityScore(commitMsg);
    const grade = extractGrade(commitMsg);

    // 원본 프롬프트 추출
    const originalPromptSection = extractSection(commitMsg, '### 원본 프롬프트');
    const originalPrompt = extractCodeBlock(originalPromptSection) || originalPromptSection;

    // 최적화된 프롬프트 추출
    const optimizedPromptSection = extractSection(commitMsg, '### 최적화된 프롬프트');
    const optimizedPrompt = extractCodeBlock(optimizedPromptSection) || optimizedPromptSection;

    // 사고 여정 추출
    const thinkingJourney = extractSection(commitMsg, '## 사고 여정');

    // 프롬프트 분석 추출
    const promptAnalysis = extractSection(commitMsg, '### 프롬프트 분석');

    console.log(`타입: ${type}`);
    console.log(`스코프: ${scope || '(없음)'}`);
    console.log(`도메인: ${domain}`);
    console.log(`복잡도: ${complexity}`);
    console.log(`품질 점수: ${qualityScore || '(미평가)'}/48`);
    console.log(`등급: ${grade || '(미평가)'}\n`);

    // 4. .prompts/ 폴더 확인/생성
    const promptsDir = '.prompts';
    if (!existsSync(promptsDir)) {
      mkdirSync(promptsDir, { recursive: true });
      console.log(`✓ ${promptsDir}/ 폴더 생성됨`);
    }

    // 5. 저널 파일명 생성
    const filename = generateJournalFilename(commitDate, type, scope, subject);
    const journalPath = join(promptsDir, filename);

    // 중복 파일 확인
    if (existsSync(journalPath)) {
      console.log(`⚠️  이미 존재하는 저널: ${journalPath}`);
      console.log('   기존 파일을 유지합니다.\n');
      return;
    }

    // 6. 저널 내용 생성
    const journalContent = generateJournalContent({
      date: commitDate,
      time: commitTime || '00:00',
      commitHash,
      type,
      scope,
      subject,
      domain,
      complexity,
      qualityScore,
      grade,
      originalPrompt,
      optimizedPrompt,
      thinkingJourney,
      promptAnalysis
    });

    // 7. 파일 저장
    writeFileSync(journalPath, journalContent, 'utf8');

    console.log(`✅ 저널 생성 완료: ${journalPath}\n`);
    console.log('┌─────────────────────────────────────────────────┐');
    console.log('│  📋 다음 단계:                                   │');
    console.log('│                                                  │');
    console.log('│  1. 저널 파일을 열어 편집하세요                  │');
    console.log('│  2. "사고 여정" 섹션을 작성하세요                │');
    console.log('│  3. "핵심 학습" 섹션을 작성하세요                │');
    console.log('│  4. 저널을 다음 커밋에 포함하세요                │');
    console.log('│                                                  │');
    console.log('│  git add .prompts/                               │');
    console.log('│  git commit --amend --no-edit                    │');
    console.log('│                                                  │');
    console.log('└─────────────────────────────────────────────────┘\n');

  } catch (error) {
    // Git 저장소가 아니거나 커밋이 없는 경우
    if (error.message.includes('not a git repository') ||
        error.message.includes('does not have any commits')) {
      console.log('⚠️  Git 저장소가 아니거나 커밋이 없습니다.');
      return;
    }

    console.error('❌ 오류 발생:', error.message);
    // post-commit 훅에서 실패해도 커밋은 유지되어야 함
    // 따라서 exit(1)을 호출하지 않음
  }
}

// 실행
main();
