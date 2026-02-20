#!/usr/bin/env node
/**
 * create-thinking-log.js v1.0
 *
 * CE 사고 여정 템플릿 파일을 .thoughts/ 폴더에 생성합니다.
 * Claude가 작업 완료 시 직접 호출하거나, 수동 실행 가능.
 *
 * 사용법: node scripts/create-thinking-log.js [subject]
 */

import { execSync } from 'child_process';
import { writeFileSync, existsSync, mkdirSync } from 'fs';
import { join } from 'path';

const THOUGHTS_DIR = '.thoughts';

/**
 * CE 사고 여정 템플릿 생성
 */
function createThinkingLog(subject) {
  // 날짜
  const now = new Date();
  const dateStr = now.toISOString().split('T')[0];

  // 커밋 정보 (있으면)
  let commitHash = 'none';
  let commitType = 'unknown';
  let commitSubject = subject || 'untitled';
  try {
    commitHash = execSync('git rev-parse --short HEAD', { encoding: 'utf8' }).trim();
    const commitMsg = execSync('git log -1 --format=%s', { encoding: 'utf8' }).trim();
    const match = commitMsg.match(/^(\w+)(?:\(.+\))?:\s(.+)$/);
    if (match) {
      commitType = match[1];
      commitSubject = match[2];
    } else {
      commitSubject = commitMsg;
    }
  } catch {
    // Git 정보 없어도 생성 가능
  }

  // 파일명 생성 (한글/특수문자 제거)
  const safeSubject = commitSubject
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
    .toLowerCase()
    .slice(0, 50);
  const fileName = `${dateStr}-${safeSubject}.md`;

  // 폴더 확인
  if (!existsSync(THOUGHTS_DIR)) {
    mkdirSync(THOUGHTS_DIR, { recursive: true });
  }

  const filePath = join(THOUGHTS_DIR, fileName);

  // 이미 존재하면 건너뜀
  if (existsSync(filePath)) {
    console.log(`이미 존재: ${filePath}`);
    return filePath;
  }

  // 템플릿 생성
  const template = `---
date: ${dateStr}
commit: ${commitHash}
type: ${commitType}
subject: "${commitSubject}"
ce_strategies: []
---

# ${commitSubject}

## 1. 컨텍스트 수집 (Gather)

### 읽은 파일과 이유
| 파일 | 이유 | 유용했는가 |
|------|------|:----------:|
| | | |

### 사용한 도구
- Glob:
- Grep:
- Read:

## 2. 정보 선택/폐기 (Select)

### 채택한 정보
-

### 폐기한 정보
-

### 컨텍스트 예산
- 수집 단계: ~?%
- 구현 단계: ~?%

## 3. 실패 모드 감지 (Detect)

| 실패 모드 | 감지 | 회피 전략 |
|----------|:----:|----------|
| Poisoning (오염) | | |
| Distraction (산만) | | |
| Confusion (혼란) | | |
| Clash (충돌) | | |

## 4. 대안 비교 및 결정 (Decide)

| 대안 | 장점 | 단점 | 채택 |
|------|------|------|:----:|
| | | | |

### 결정 근거


## 5. 적용된 CE 전략

- [ ] Write:
- [ ] Select:
- [ ] Compress:
- [ ] Isolate:

## 6. 핵심 통찰

>

---
*자동 생성: ${dateStr} | 커밋: ${commitHash}*
`;

  writeFileSync(filePath, template, 'utf8');
  console.log(`CE 사고 여정 생성: ${filePath}`);
  return filePath;
}

// 실행
const subject = process.argv[2] || null;
createThinkingLog(subject);
