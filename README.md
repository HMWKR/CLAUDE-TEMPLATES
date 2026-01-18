# CLAUDE-TEMPLATES

Claude Code CLI 협업을 위한 마스터 템플릿 저장소

## 이 저장소는?

새 프로젝트에 Claude Code 협업 환경을 빠르게 구축하기 위한 템플릿 모음입니다.

## 원클릭 설정 (권장)

새 프로젝트에서 아래 명령어 한 줄로 모든 설정을 자동으로 완료합니다:

```bash
curl -sL https://raw.githubusercontent.com/HMWKR/CLAUDE-TEMPLATES/main/init-project.sh | bash
```

**자동으로 수행되는 작업 (10단계):**
- CLAUDE.md 템플릿 다운로드
- 16개 섹션 커밋 검증 시스템 설치 (commitlint + husky)
- 커밋 메시지 템플릿 설정
- 프롬프트 추출 스크립트 다운로드 (`extract-local-prompts.js`)
- GitHub Actions 워크플로우 생성 (`sync-prompts.yml`)
- gh-pages 자동 배포 설정
- 프롬프트 저널 폴더 생성 (`.prompts/`)
- 저널 자동 생성 스크립트 다운로드 (`create-journal-from-commit.js`)
- 저널 검증 스크립트 다운로드 (`validate-journals.js`)
- post-commit 훅 설정 (저널 자동 생성)

## 포함 파일

| 파일 | 용도 |
|------|------|
| `init-project.sh` | 원클릭 자동 설정 스크립트 (10단계) |
| `CLAUDE_TEMPLATE.md` | CLAUDE.md 전체 템플릿 (19개 섹션) |
| `CLAUDE_UNIVERSAL_RULES.md` | 공통 규칙 (섹션 9-19) |
| `PROJECT_SETUP_CHECKLIST.md` | 새 프로젝트 설정 체크리스트 |
| `CONVERSATION_PROMPTS.md` | Claude 대화 프롬프트 패턴 모음 |
| `커밋메시지-16섹션-설정가이드.md` | 16개 섹션 커밋 검증 시스템 가이드 |
| `commitlint.config.cjs` | 16개 섹션 검증 규칙 |
| `.gitmessage` | 커밋 메시지 템플릿 |
| `scripts/extract-local-prompts.js` | 프롬프트 추출 (커밋 + 저널) v3.0 |
| `scripts/create-journal-from-commit.js` | 커밋 후 저널 자동 생성 (v3.1) |
| `scripts/validate-journals.js` | 저널 형식 검증 (v3.1) |
| `.github/workflows/sync-prompts.yml` | 푸시 시 자동 프롬프트 추출 및 gh-pages 배포 |
| `PROMPT_JOURNAL_TEMPLATE.md` | 프롬프트 저널 작성 가이드 및 템플릿 |
| `.prompts/` | 프롬프트 저널 저장 폴더 |

## 핵심 기능

1. **16개 섹션 커밋 메시지 검증** - Husky + Commitlint 자동화
   - 커밋 시: 16개 섹션 권장 (commitlint 검증)
   - 프롬프트 수집: 최소 10개 섹션 이상 (extract-local-prompts.js)
2. **프롬프트 저널 시스템** (v3.0 신규)
   - 마크다운 형식으로 프롬프트와 사고 과정 기록
   - 읽고 배우기 좋은 형태
   - YAML frontmatter로 ML 파싱 가능
3. **환각 방지 프로토콜** - Read Before Write
4. **체계적 8단계 워크플로우** - 문제 해결 프로토콜
5. **5계층 48점 프롬프트 품질 평가** - 객관적 품질 측정

## Claude와 첫 대화

새 프로젝트 설정 후, 다음 프롬프트로 시작하세요:

### 1. 프로젝트 분석
```
이 프로젝트를 깊이 분석해줘.
```

### 2. 기능 구현
```
[기능명]을 깊이 분석해서 구현해줘.

## 요구사항
- [요구사항]

## 제약 조건
- 기존 코드 스타일 유지
```

### 3. 커밋 작성
```
현재 변경사항을 16개 섹션 템플릿으로 커밋해줘.
```

> 더 많은 프롬프트 패턴: [CONVERSATION_PROMPTS.md](./CONVERSATION_PROMPTS.md) | 상세 가이드: [PROJECT_SETUP_CHECKLIST.md](./PROJECT_SETUP_CHECKLIST.md)

## 수동 설정

원클릭 설정 대신 수동으로 설정하려면:

```bash
# 1. 템플릿 복사
cp CLAUDE_TEMPLATE.md /path/to/new-project/CLAUDE.md

# 2. 커밋 검증 시스템 설치
npm install -D husky @commitlint/cli @commitlint/config-conventional
npx husky init

# 3. 설정 파일 복사
cp commitlint.config.cjs /path/to/new-project/
cp .gitmessage /path/to/new-project/

# 4. Git 템플릿 등록
git config commit.template .gitmessage
```

상세 가이드: `PROJECT_SETUP_CHECKLIST.md` 참고

## 프롬프트 수집 아키텍처

### 분산 Push + 클라이언트 집계

```
┌─────────────────────────────────────────────────────────────┐
│                  분산 Push 아키텍처                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [프로젝트 A]       [프로젝트 B]       [프로젝트 N]          │
│       │                 │                   │               │
│       │ (git push)      │ (git push)        │ (git push)    │
│       ▼                 ▼                   ▼               │
│  sync-prompts.yml   sync-prompts.yml   sync-prompts.yml     │
│  prompts.json 생성  prompts.json 생성  prompts.json 생성    │
│       │                 │                   │               │
│       ▼                 ▼                   ▼               │
│   gh-pages 배포      gh-pages 배포      gh-pages 배포       │
│       │                 │                   │               │
│       └─────────────────┼───────────────────┘               │
│                         │                                   │
│                         ▼                                   │
│              ┌─────────────────────┐                        │
│              │  prompt-dashboard   │                        │
│              │  (브라우저 집계)    │                        │
│              └─────────────────────┘                        │
│                                                             │
│  특징: 100개+ 프로젝트 무제한 확장, 커밋 후 1-2분 반영     │
└─────────────────────────────────────────────────────────────┘
```

### 동작 흐름

1. **커밋** → 16개 섹션 커밋 메시지 작성
2. **푸시** → GitHub Actions 자동 실행
3. **추출** → `extract-local-prompts.js`가 프롬프트 추출
4. **배포** → `prompts.json`을 gh-pages 브랜치에 배포
5. **집계** → prompt-dashboard가 모든 프로젝트에서 fetch

### 연동 저장소

| 저장소 | 용도 | 링크 |
|--------|------|------|
| **prompt-library** | 프로젝트 레지스트리 (v3.0) | [GitHub](https://github.com/HMWKR/prompt-library) |
| **prompt-dashboard** | 통계 대시보드 | [Live](https://hmwkr.github.io/prompt-dashboard/) |

### 저장소별 역할 상세

| 저장소 | 역할 | 데이터 |
|--------|------|--------|
| **claude-templates** | 마스터 템플릿/스크립트 배포 | CLAUDE.md, init-project.sh, extract-local-prompts.js |
| **prompt-library** | 프로젝트 레지스트리 (v3.0) | `data/projects.json` |
| **prompt-dashboard** | 데이터 집계 및 시각화 | 브라우저에서 각 프로젝트 prompts.json fetch |
| **각 프로젝트** | 자체 프롬프트 추출 및 배포 | gh-pages에 `prompts.json` 배포 |

### projects.json 구조 (v3.0)

prompt-library의 `data/projects.json` 파일 구조:

```json
{
  "version": "3.0",
  "architecture": "distributed-push",
  "projects": [
    {
      "name": "프로젝트명",
      "repo": "owner/repo",
      "owner": "owner",
      "promptsUrl": "https://owner.github.io/repo/prompts.json",
      "metadata": {
        "category": "application",
        "status": "active",
        "description": "프로젝트 설명"
      },
      "cache": {
        "promptCount": null,
        "lastFetched": null
      }
    }
  ],
  "summary": {
    "totalProjects": 4,
    "totalPromptsCached": null
  }
}
```

### prompts.json 구조 (v3.0)

각 프로젝트의 gh-pages에 배포되는 `prompts.json` 파일 구조:

```json
{
  "version": "3.0",
  "project": {
    "name": "프로젝트명",
    "owner": "owner",
    "url": "https://github.com/owner/repo"
  },
  "extractedAt": "2026-01-14T00:00:00.000Z",
  "stats": {
    "totalCommits": 100,
    "fromCommits": 7,
    "fromJournals": 5,
    "total": 12
  },
  "prompts": [
    {
      "source": "commit",
      "hash": "abc1234",
      "date": "2026-01-14",
      "type": "feat",
      "subject": "커밋 제목",
      "originalPrompt": "사용자 프롬프트",
      "optimizedPrompt": "최적화된 프롬프트",
      "qualityScore": 45,
      "grade": "A+"
    },
    {
      "source": "journal",
      "journalFile": "2026-01-14-feature.md",
      "date": "2026-01-14",
      "type": "backend",
      "subject": "기능 구현",
      "originalPrompt": "사용자 프롬프트",
      "optimizedPrompt": "최적화된 프롬프트",
      "qualityScore": 42,
      "grade": "A+",
      "tags": ["auth", "security"],
      "thinking": "사고 여정...",
      "learning": "핵심 학습..."
    }
  ]
}
```

### 새 프로젝트 등록 방법

프롬프트 대시보드에 프로젝트를 표시하려면:

1. **init-project.sh 실행** (10단계 자동 완료)
   ```bash
   curl -sL https://raw.githubusercontent.com/HMWKR/CLAUDE-TEMPLATES/main/init-project.sh | bash
   ```

2. **GitHub Pages 활성화**
   - Repository Settings → Pages → Source: gh-pages

3. **prompt-library에 프로젝트 추가**
   - [prompt-library](https://github.com/HMWKR/prompt-library) 저장소 Fork
   - `data/projects.json`에 프로젝트 정보 추가
   - PR 생성 또는 이슈로 등록 요청

### GitHub Pages 설정 (필수)

워크플로우가 gh-pages에 배포하려면 Pages 설정이 필요합니다:

1. Repository → Settings → Pages
2. Source: **Deploy from a branch**
3. Branch: **gh-pages** / (root)
4. Save

## 프롬프트 저널 사용법 (v3.0)

프롬프트 저널은 16개 섹션 커밋과 **병행**하여 사용합니다.

### 언제 사용하나요?

| 상황 | 저널 작성 | 이유 |
|------|:--------:|------|
| 중요한 기능 구현 | O | 사고 과정 기록 가치 |
| 복잡한 문제 해결 | O | 전환점 기록 필요 |
| 새로운 패턴 발견 | O | 학습 포인트 보존 |
| 단순 버그 수정 | △ | 선택적 |
| 오타 수정 | X | 불필요 |

### 작성 방법

1. `.prompts/` 폴더에 새 파일 생성
2. 파일명: `YYYY-MM-DD-{topic}.md`
3. [PROMPT_JOURNAL_TEMPLATE.md](./PROMPT_JOURNAL_TEMPLATE.md) 템플릿 사용

### 예시

```markdown
---
date: 2026-01-14
domain: backend
complexity: medium
quality_score: 42
grade: A+
tags: [auth, JWT]
---

# JWT 인증 구현

## 원본 프롬프트
> JWT 인증 시스템을 구현해줘.

## 사고 여정
처음에는... 그런데... 결국...

## 최적화된 프롬프트
```JWT 인증 시스템을 깊이 분석해서 구현해줘...```

## 핵심 학습
1. 토큰 저장 위치가 보안의 핵심
2. ...
```

### 데이터 흐름

```
16섹션 커밋 ─────┐
                 ├──▶ prompts.json ──▶ dashboard
프롬프트 저널 ───┘

두 소스에서 모두 데이터 수집 → 더 풍부한 데이터셋
```

## 라이선스

MIT
