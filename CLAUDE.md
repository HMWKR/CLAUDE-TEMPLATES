# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 1. 프로젝트 개요

**claude-templates**는 Claude Code CLI 협업을 위한 **마스터 템플릿 저장소**입니다.

새로운 프로젝트에서 Claude와 효과적으로 협업하기 위한 템플릿, 규칙, 가이드라인, 자동화 설정을 한곳에 모아둔 "씨앗 저장소"입니다.

### 핵심 기능

1. **CLAUDE.md 템플릿** - 새 프로젝트에 복사할 템플릿 (글로벌 참조 구조)
2. **4섹션 커밋 검증** - Husky + Commitlint (What/Why/Impact/Co-Authored-By)
3. **CE 사고 여정** - .thoughts/ 시스템으로 Context Engineering 과정 기록
4. **하니스 평가 도구** - harness-eval.js (5축 자동 측정)

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
| `git commit` | 4섹션 커밋 (What/Why/Impact) |

---

## 3. 아키텍처

### 폴더 구조

```
claude-templates/
├── init-project.sh              # 원클릭 자동 설정 스크립트 (10단계, v3.1)
├── CLAUDE_TEMPLATE.md           # CLAUDE.md 전체 템플릿
├── PROJECT_SETUP_CHECKLIST.md   # 새 프로젝트 설정 체크리스트
├── CONVERSATION_PROMPTS.md      # Claude 대화 프롬프트 패턴 모음
├── PROMPT_JOURNAL_TEMPLATE.md   # 프롬프트 저널 템플릿 (v3.0)
├── CODE_REVIEW_GUIDE.md         # 코드 리뷰 가이드라인
├── CLAUDE_CODE_SKILLS_GUIDE.md  # Claude Code 스킬 활용 가이드
├── PLUGIN_GUIDE.md              # Claude Code 플러그인 가이드
├── SECTION_1_TO_8_WRITING_GUIDE.md # CLAUDE.md 섹션 1-8 작성 가이드
├── archive/                     # PE 시대 레거시 보관
│   └── pe-legacy/
│       ├── 커밋메시지-16섹션-설정가이드.md  # [아카이브] PE 시대 커밋 가이드
│       ├── CLAUDE_OPTIMIZATION_ANALYSIS.md # [아카이브] 최적화 분석
│       └── CLAUDE_UNIVERSAL_RULES.md       # [아카이브] 공통 규칙 (→ 글로벌 CLAUDE.md로 이관)
├── package.json                 # Husky + Commitlint 의존성
├── commitlint.config.cjs        # 4섹션 커밋 검증 규칙 (CE v2.0)
├── .gitmessage                  # 커밋 메시지 템플릿
├── .prompts/                    # 프롬프트 저널 폴더 (v3.0)
├── .thoughts/                   # CE 사고여정 기록
├── .husky/                      # Git 훅 설정
│   ├── commit-msg               # 커밋 메시지 검증 훅
│   └── post-commit              # 저널 자동 생성 훅 (v3.1)
├── scripts/                     # 자동화 스크립트
│   ├── extract-local-prompts.js # CE 데이터 추출 (v4.0)
│   ├── create-thinking-log.js   # .thoughts/ 사고여정 생성
│   ├── create-journal-from-commit.js # 커밋 기반 저널 자동 생성
│   ├── validate-journals.js     # 저널/사고여정 형식 검증
│   ├── journal-stats.js         # 저널 통계 분석
│   ├── harness-eval.js          # 하니스 5축 자동 평가
│   └── harness-gc.js            # 하니스 가비지 컬렉션
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
│  │ commitlint       │ ─────────▶  │ 4섹션 커밋 검증  │         │
│  │  .config.cjs     │  (CE v2.0)  │ What/Why/Impact  │         │
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

### 4.2 공통 규칙 (글로벌 관리)

CE v2.0 이전에는 `CLAUDE_UNIVERSAL_RULES.md`로 공통 규칙을 관리했으나, 현재는 글로벌 인프라로 이관되었습니다.

**현재 위치**:
- `~/.claude/CLAUDE.md` — 글로벌 공통 지침
- `~/.claude/rules/` — 환각 방지, 루프 방지, 안전 규칙

**레거시**: `archive/pe-legacy/CLAUDE_UNIVERSAL_RULES.md`에 보관

### 4.3 CONVERSATION_PROMPTS.md

**위치**: `CONVERSATION_PROMPTS.md`

Claude와 효과적으로 대화하기 위한 검증된 프롬프트 패턴 모음입니다.

**카테고리**:
- 기본 작업 모드 (깊은 사고, 계획, 검수)
- 기능 구현 / 버그 수정 프롬프트
- 코드 리뷰 / 리팩토링 프롬프트
- 성능 최적화 / 테스트 작성 프롬프트
- CE 컨텍스트 최적화 패턴

### 4.4 CE v2.0 커밋 검증 시스템

**설정 파일**: `commitlint.config.cjs` (4섹션 검증 규칙)

CE v2.0에서는 커밋 메시지를 4개 핵심 섹션(What/Why/Impact + Co-Authored-By)으로 간소화하고, 사고 과정은 `.thoughts/`에 분리 기록합니다.

**포함 내용**:
- `commitlint.config.cjs`: 4섹션 검증 규칙 (CE v2.0)
- `.gitmessage`: 간결한 커밋 템플릿
- `.thoughts/`: CE 사고 여정 자동 생성

> **레거시 참조**: PE 시대 16섹션 가이드는 `archive/pe-legacy/커밋메시지-16섹션-설정가이드.md`에 보관

### 4.5 extract-local-prompts.js (v4.0)

**위치**: `scripts/extract-local-prompts.js`

4섹션 커밋 메시지 + `.thoughts/` CE 사고여정에서 데이터를 추출하는 Node.js 스크립트입니다.

**기능**:
- Git 로그에서 4섹션 커밋(What/Why/Impact) 탐지
- `.thoughts/` 디렉토리의 CE 사고여정 파일 수집
- 커밋 컨텍스트, CE 전략, 핵심 통찰 추출
- `prompts.json` 파일로 출력

**사용법**:
```bash
node scripts/extract-local-prompts.js
# → prompts.json 생성 (커밋 + .thoughts/ 데이터 통합)
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
git commit  # 템플릿 표시 → 4섹션 커밋 작성 → 저장
# → 커밋 성공
```

### 테스트 현황

| 영역 | 테스트 방법 | 예상 결과 |
|------|------------|----------|
| commitlint | 빈 커밋 메시지 | 오류 |
| commitlint | 헤더만 있는 메시지 | 필수 섹션 누락 오류 |
| commitlint | 4섹션 검증 (What/Why/Impact) | 통과 |

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
- [x] ~~MCP 서버 설정 템플릿~~ → **글로벌 인프라로 이관** (아래 참조)

### 글로벌 인프라 상태 (참고용, 이 저장소 범위 밖)

이 저장소는 **CE v2.0 템플릿**만 관리한다. 사용자의 글로벌 Claude Code 환경(`~/.claude/`)은 별도로 진화하며, 현재 상태는 프로젝트 메모리에 스냅샷으로 유지된다.

| 항목 | 최신 스냅샷 위치 |
|------|----------------|
| MCP 서버 / 플러그인 / 훅 / 로컬 도구 인벤토리 | `~/.claude/projects/<slug>/memory/environment_inventory.md` (2026-04-11) |
| CapCut MCP 연동 (VectCutAPI) | `~/.claude/projects/<slug>/memory/capcut_integration.md` |
| 하니스 업그레이드 절차 | `~/.claude/HARNESS_UPGRADE_CHECKLIST.md` |

> **원칙**: 글로벌 환경의 구체적 도구 목록(MCP 서버, 설치 경로 등)은 `CLAUDE.md`에 직접 기재하지 않는다. CE v2.0의 "최소 토큰 + 중복 제거" 원칙에 따라 `claude mcp list` 등 실시간 조회로 대체 가능한 정보는 메모리에만 시점 기록으로 남긴다.

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
