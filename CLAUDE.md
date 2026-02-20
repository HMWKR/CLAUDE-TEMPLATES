# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 1. 프로젝트 개요

**claude-templates**는 Claude Code CLI 협업을 위한 **마스터 템플릿 저장소**입니다.

새로운 프로젝트에서 Claude와 효과적으로 협업하기 위한 템플릿, 규칙, 가이드라인, 자동화 설정을 한곳에 모아둔 "씨앗 저장소"입니다.

### 핵심 기능

1. **CLAUDE.md 템플릿** - 새 프로젝트에 복사할 19개 섹션 전체 템플릿
2. **16개 섹션 커밋 검증** - Husky + Commitlint 자동화 시스템
3. **프롬프트 패턴 가이드** - 검증된 대화 패턴 모음
4. **5계층 48점 품질 평가** - 객관적 프롬프트 품질 측정 시스템

### 기술 스택

- Node.js (npm)
- Husky (Git 훅)
- Commitlint (커밋 메시지 검증)
- Markdown (문서)

---

## 2. Quick Start

### 새 프로젝트에 적용하기

```bash
# 1. 템플릿 복사 (Windows)
copy C:\Users\jusan\Desktop\claude-templates\CLAUDE_TEMPLATE.md .\CLAUDE.md

# 2. 커밋 검증 시스템 설치
npm install -D husky @commitlint/cli @commitlint/config-conventional
npx husky init

# 3. 설정 파일 복사
copy C:\Users\jusan\Desktop\claude-templates\commitlint.config.cjs .
copy C:\Users\jusan\Desktop\claude-templates\.gitmessage .

# 4. Git 템플릿 등록
git config commit.template .gitmessage
```

### 주요 명령어

| 명령어 | 설명 |
|--------|------|
| `npm install` | 의존성 설치 |
| `git commit` | 템플릿 기반 커밋 (16개 섹션 검증) |

---

## 3. 아키텍처

### 폴더 구조

```
claude-templates/
├── init-project.sh              # 원클릭 자동 설정 스크립트 (10단계, v3.1)
├── CLAUDE_TEMPLATE.md           # CLAUDE.md 전체 템플릿 (19개 섹션)
├── CLAUDE_UNIVERSAL_RULES.md    # 공통 규칙 (섹션 9-19 분리본)
├── PROJECT_SETUP_CHECKLIST.md   # 새 프로젝트 설정 체크리스트
├── CONVERSATION_PROMPTS.md      # Claude 대화 프롬프트 패턴 모음
├── PROMPT_JOURNAL_TEMPLATE.md   # 프롬프트 저널 템플릿 (v3.0)
├── 커밋메시지-16섹션-설정가이드.md  # 커밋 검증 시스템 상세 가이드
├── package.json                 # Husky + Commitlint 의존성
├── commitlint.config.cjs        # 16개 섹션 검증 규칙
├── .gitmessage                  # 커밋 메시지 템플릿
├── .prompts/                    # 프롬프트 저널 폴더 (v3.0)
├── .husky/                      # Git 훅 설정
│   ├── commit-msg               # 커밋 메시지 검증 훅
│   └── post-commit              # 저널 자동 생성 훅 (v3.1)
├── scripts/                     # 자동화 스크립트
│   ├── extract-local-prompts.js # 프롬프트 추출 (v3.1)
│   ├── create-journal-from-commit.js # 저널 자동 생성 (v3.1)
│   ├── validate-journals.js     # 저널 형식 검증 (v3.1)
│   └── journal-stats.js         # 저널 통계 분석 (v3.1)
├── .github/                     # GitHub 설정
│   └── workflows/
│       └── sync-prompts.yml     # 프롬프트 자동 동기화 워크플로우
└── node_modules/                # npm 패키지
```

### 파일 관계도

```
┌─────────────────────────────────────────────────────────────────┐
│                    claude-templates 저장소                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐                                          │
│  │ init-project.sh  │ ─────────▶ 새 프로젝트에 10단계 자동 설정 │
│  └──────────────────┘                                          │
│           │ 다운로드                                            │
│           ▼                                                     │
│  ┌──────────────────┐    복사     ┌──────────────────┐         │
│  │ CLAUDE_TEMPLATE  │ ─────────▶  │ 새 프로젝트      │         │
│  │      .md         │             │ CLAUDE.md        │         │
│  └──────────────────┘             └──────────────────┘         │
│                                                                 │
│  ┌──────────────────┐    설정     ┌──────────────────┐         │
│  │ 커밋메시지-16섹션│ ─────────▶  │ commitlint       │         │
│  │ -설정가이드.md   │             │  .config.cjs     │         │
│  └──────────────────┘             └──────────────────┘         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│               분산 Push 프롬프트 수집 아키텍처                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  새 프로젝트 (init-project.sh로 생성)                          │
│  ├── sync-prompts.yml      ← 자동 생성                         │
│  └── extract-local-prompts.js  ← 자동 다운로드                 │
│           │                                                     │
│           │ git push                                            │
│           ▼                                                     │
│  ┌──────────────────┐                                          │
│  │ GitHub Actions   │  프롬프트 추출 실행                       │
│  │ sync-prompts.yml │                                          │
│  └──────────────────┘                                          │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────┐                                          │
│  │   gh-pages 배포   │  prompts.json                           │
│  └──────────────────┘                                          │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────┐                                          │
│  │ prompt-dashboard │  브라우저에서 모든 프로젝트 집계          │
│  └──────────────────┘                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. 핵심 모듈

### 4.1 CLAUDE_TEMPLATE.md

**위치**: `CLAUDE_TEMPLATE.md`

새 프로젝트의 `CLAUDE.md`로 복사할 전체 템플릿입니다.

**구조**:
- 섹션 1-8: 프로젝트별 정보 (TODO 작성 필요)
- 섹션 9-19: 공통 규칙 (그대로 사용)

**사용법**:
```bash
# 새 프로젝트에 복사
cp CLAUDE_TEMPLATE.md /path/to/new-project/CLAUDE.md

# 섹션 1-8 작성
# [TODO] 표시된 부분을 프로젝트에 맞게 수정
```

### 4.2 CLAUDE_UNIVERSAL_RULES.md

**위치**: `CLAUDE_UNIVERSAL_RULES.md`

프로젝트 독립적인 공통 규칙 (섹션 9-19)만 분리한 파일입니다.

**포함 내용**:
- 언어 및 스타일 규칙
- 환각 방지 프로토콜
- 체계적 8단계 워크플로우
- 코드 작성/리뷰/테스트 규칙
- 커밋 메시지 16개 섹션 구조

### 4.3 CONVERSATION_PROMPTS.md

**위치**: `CONVERSATION_PROMPTS.md`

Claude와 효과적으로 대화하기 위한 검증된 프롬프트 패턴 모음입니다.

**카테고리**:
- 기본 작업 모드 (깊은 사고, 계획, 검수)
- 기능 구현 / 버그 수정 프롬프트
- 코드 리뷰 / 리팩토링 프롬프트
- 성능 최적화 / 테스트 작성 프롬프트
- 5계층 48점 품질 평가 프롬프트

### 4.4 커밋메시지-16섹션-설정가이드.md

**위치**: `커밋메시지-16섹션-설정가이드.md`

Husky + Commitlint를 사용한 16개 필수 섹션 커밋 메시지 검증 시스템 설정 가이드입니다.

**포함 내용**:
- 패키지 설치 명령어
- `commitlint.config.cjs` 전체 코드
- `.gitmessage` 템플릿
- GitHub Actions CI 설정

### 4.5 extract-local-prompts.js

**위치**: `scripts/extract-local-prompts.js`

16개 섹션 커밋 메시지에서 프롬프트 정보를 추출하는 Node.js 스크립트입니다.

**기능**:
- Git 로그에서 16개 섹션이 포함된 커밋 탐지
- 원본 프롬프트, 최적화된 프롬프트, 분석, 품질 점수 추출
- `prompts.json` 파일로 출력

**사용법**:
```bash
node scripts/extract-local-prompts.js
# → prompts.json 생성
```

### 4.6 sync-prompts.yml

**위치**: `.github/workflows/sync-prompts.yml`

푸시 시 자동으로 프롬프트를 추출하고 gh-pages에 배포하는 GitHub Actions 워크플로우입니다.

**트리거**:
- `main` 또는 `master` 브랜치 푸시
- 수동 실행 (`workflow_dispatch`)

**동작 흐름**:
1. 저장소 체크아웃 (전체 히스토리)
2. Node.js 설정
3. `extract-local-prompts.js` 실행
4. `prompts.json`을 gh-pages 브랜치에 배포

**필수 설정**:
- Repository Settings → Pages → Source: gh-pages 브랜치

### 4.7 prompt-library 연동 (v3.0)

**위치**: 외부 저장소 `HMWKR/prompt-library`

prompt-dashboard가 프로젝트 목록을 가져오는 **프로젝트 레지스트리**입니다.

**역할**:
- `data/projects.json`: 프로젝트 레지스트리 (목록 관리만)
- 각 프로젝트의 `promptsUrl` 제공 (gh-pages URL)
- prompt-dashboard가 이 목록을 기반으로 모든 프로젝트의 `prompts.json`을 fetch하여 집계

**projects.json 구조 (v3.0)**:
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

**새 프로젝트 등록 방법**:
1. prompt-library 저장소에 PR 생성
2. `data/projects.json`에 프로젝트 정보 추가 (v3.0 스키마)
3. 머지 후 자동으로 prompt-dashboard에서 집계됨

---

## 5. 타입 시스템

> 이 저장소는 문서 템플릿 저장소로, 별도의 타입 시스템이 없습니다.

---

## 6. 테스트

### 커밋 메시지 검증 테스트

```bash
# 실패 테스트 (섹션 누락)
git commit -m "test"
# → 필수 섹션 누락 오류 발생해야 정상

# 성공 테스트 (전체 구조)
git commit  # 템플릿 표시 → 16개 섹션 작성 → 저장
# → 커밋 성공
```

### 테스트 현황

| 영역 | 테스트 방법 | 예상 결과 |
|------|------------|----------|
| commitlint | 빈 커밋 메시지 | 오류 |
| commitlint | 헤더만 있는 메시지 | 필수 섹션 누락 오류 |
| commitlint | 16개 섹션 완비 | 통과 |

---

## 7. 환경 설정

### 의존성

| 패키지 | 버전 | 용도 |
|--------|------|------|
| `husky` | ^9.0.0 | Git 훅 관리 |
| `@commitlint/cli` | ^19.0.0 | 커밋 메시지 린트 |
| `@commitlint/config-conventional` | ^19.0.0 | 기본 규칙 |

### Git 설정

| 설정 | 값 | 용도 |
|------|-----|------|
| `commit.template` | `.gitmessage` | 커밋 템플릿 |

---

## 8. 알려진 이슈 & TODO

### 현재 제한사항

- [ ] commitlint.config.cjs, .gitmessage 파일이 저장소에 포함되어 있는지 확인 필요
- [ ] macOS/Linux용 설정 스크립트 추가

### 향후 개선 계획

- [ ] 언어별 템플릿 추가 (Python, Go, Rust)
- [ ] VS Code 확장 연동 가이드
- [ ] GitHub Copilot 연동 가이드
- [ ] MCP 서버 설정 템플릿

---

# 작업 지침

> 공통 규칙(언어, 환각 방지, 코드 작성, 보안 등)은 **글로벌 `~/.claude/CLAUDE.md`** 참조.
> 아래는 이 프로젝트에만 해당하는 보충 지침.

## 프로젝트 고유 규칙

- 이 저장소는 **문서 템플릿 저장소** — 코드 실행보다 문서 품질이 중요
- 스크립트: [scripts/](scripts/) 디렉토리의 Node.js 스크립트로 추출/검증

## 커밋 메시지 (4개 필수 섹션)

| # | 섹션 | 용도 |
|:-:|------|------|
| 1 | `[type]:` 헤더 | Conventional Commits |
| 2 | `## What` | 변경된 파일/기능 |
| 3 | `## Why` | 변경 이유 |
| 4 | `## Impact` | 영향 범위, 위험도, Breaking |
| - | `Co-Authored-By:` | AI 협업 표시 |

> Husky + Commitlint가 4개 섹션을 자동 검증합니다.

## CE 사고 여정 (.thoughts/)

커밋 후 Claude가 `.thoughts/YYYY-MM-DD-{subject}.md`에 CE 관점 사고 과정을 기록합니다.

| 섹션 | 내용 |
|:----:|------|
| 1. 컨텍스트 수집 | 읽은 파일, 사용한 도구, 이유 |
| 2. 정보 선택/폐기 | Select 전략, 컨텍스트 예산 |
| 3. 실패 모드 감지 | Poisoning/Distraction/Confusion/Clash |
| 4. 대안 비교 | 장단점 표, 결정 근거 |
| 5. CE 전략 | Write/Select/Compress/Isolate 적용 |
| 6. 핵심 통찰 | 재사용 가능한 CE 교훈 |

## 브랜치

- `main` / `feature/<기능>` / `fix/<버그>` / `chore/<작업>`

---

# End of CLAUDE.md
