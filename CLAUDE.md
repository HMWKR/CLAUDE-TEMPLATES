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
├── .claude/                     # Claude Code 프로젝트 설정
│   ├── rules/                   # 프로젝트별 규칙
│   │   └── template-quality.md  # 템플릿 품질 검증 규칙
│   └── skills/                  # 프로젝트 스킬 자산
│       ├── aidlc-baseline/      # AI-DLC baseline lifecycle 스킬 (v1.0) — § 4.8
│       │   ├── SKILL.md         # frontmatter + Skill Bundle Note + 원본 CLAUDE.md byte-for-byte
│       │   ├── README.md        # 출처·제외·install 안내
│       │   └── references/      # 30개 baseline-lifecycle md 원문 보존
│       │       ├── original-CLAUDE.md          # 원본 byte-for-byte 사본
│       │       └── aws-aidlc-rule-details/     # 29 파일 (common/inception/construction/operations/extensions)
│       └── aidlc-realizesoft/   # RealizeSoft Layer 스킬 (v1.0) — § 4.9
│           ├── SKILL.md         # frontmatter + 12 섹션 (Purpose/Layer/§4 규칙 7/Helper Routing/Explicit-Only/Selection Gate/UI-UX Gate/Deployment Gate/UserChoice/Workflow/Completion/Universal AskUserQuestion Wrapper)
│           ├── README.md        # 출처·2-Layer 도식·install·§18 11항목
│           └── references/      # 10개 가이드 §section 원문 인용 사본
├── scripts/                     # 자동화 스크립트
│   ├── extract-local-prompts.js # CE 데이터 추출 (v4.0)
│   ├── create-thinking-log.js   # .thoughts/ 사고여정 생성
│   ├── create-journal-from-commit.js # 커밋 기반 저널 자동 생성
│   ├── validate-journals.js     # 저널/사고여정 형식 검증
│   ├── journal-stats.js         # 저널 통계 분석
│   ├── harness-eval.js          # 하니스 5축 자동 평가
│   ├── harness-gc.js            # 하니스 가비지 컬렉션
│   ├── install-aidlc-baseline.ps1     # aidlc-baseline 글로벌 install (v1.0)
│   └── install-aidlc-realizesoft.ps1  # aidlc-realizesoft 글로벌 install (v1.0)
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

### 4.8 aidlc-baseline 스킬 (v1.0)

**위치**: `.claude/skills/aidlc-baseline/`

`realizesoft/table-order-macos-claudecode/` 의 baseline lifecycle 을 byte-for-byte 보존하여 자산화한 첫 프로젝트 스킬.

**구성**:
- `SKILL.md` — Claude Code 스킬 진입점. frontmatter + Skill Bundle Note (references/ 우선순위 안내) + 원본 `.claude/CLAUDE.md` byte-for-byte 본문
- `README.md` — 출처, 가이드 §4.7·6.4 에 따른 `requirements/` 제외 사유, install 방법, 스킬 2 부착 명시
- `references/original-CLAUDE.md` — 원본 byte-for-byte 100% 보존 사본
- `references/aws-aidlc-rule-details/` — 29 파일 (common/inception/construction/operations/extensions)

**제외 (가이드 §4.7·6.4)**:
- `requirements/table-order-requirements.md`, `requirements/constraints.md` — product input 이므로 generic skill 의 source 아님

**Hybrid 배치 전략**:
- **마스터 사본** (git 추적): `claude-templates/.claude/skills/aidlc-baseline/`
- **활성 글로벌 사본**: `~/.claude/skills/aidlc-baseline/` — `scripts/install-aidlc-baseline.ps1` 실행으로 배포

**글로벌 install**:
```powershell
.\scripts\install-aidlc-baseline.ps1
```

활성화 후 어느 프로젝트에서나 "AI-DLC workflow", "aidlc baseline", "inception phase" 등 키워드로 호출 가능.

**스킬 2 (RealizeSoft 레이어) 부착 완료**:
가이드 §3 Core Architecture 의 2-Layer 모델 — 본 baseline 위에 cross-runtime-guide §4 비협상 규칙 (Selection Gate, UserChoice, Strict Gate Preservation, Provider-Neutral Deployment, Explicit-Only Skills) 을 강제하는 RealizeSoft 레이어가 §4.9 `aidlc-realizesoft` 스킬로 부착됨.

**참조**:
- `realizesoft/realizesoft-cross-runtime-skill-guide.md` (§6.4 Concrete Example, §11.2 Claude, §16 Build Procedure, §18 Verification Checklist)
- `.claude/plans/table-order-macos-claudecode-requirement-iridescent-leaf.md` — 본 스킬화 작업의 plan 기록

### 4.9 aidlc-realizesoft 스킬 (v1.0)

**위치**: `.claude/skills/aidlc-realizesoft/`

cross-runtime-guide §3 의 2-Layer 모델을 완성하는 RealizeSoft 레이어 스킬. `aidlc-baseline` (§4.8) 위에 부착되어 가이드 §4 비협상 규칙 7개를 강제하는 helper routing + user-choice gate 레이어.

**2-Layer 관계**:

```
AI-DLC Workflow Invocation
        ↓
Layer 2: RealizeSoft Layer  ← aidlc-realizesoft (본 스킬)
  • §4 비협상 규칙 7개 강제
  • Selection Gate (AskUserQuestion)
  • Universal AskUserQuestion Wrapper (3-Layer)
  • UserChoice Records
  • Provider-Neutral Deployment Gate
  • Explicit-Only Skills isolation
        ↓ attaches on top of (never modifies)
Layer 1: Baseline Layer  ← aidlc-baseline (§4.8)
  • AI-DLC 3-Phase 14-stage lifecycle 본문
  • 원본 byte-for-byte 보존
```

**구성**:
- `SKILL.md` — frontmatter (REQUIRES aidlc-baseline 명시) + 12 섹션 본문 (§1 Purpose / §2 Layer Relationship / §3 Non-Negotiable Rules 7개 / §4 Helper Routing Matrix / §5 Explicit-Only Skills / §6 Selection Gate Protocol / §7 UI/UX Decision Gate / §8 Deployment Provider Gate / §9 UserChoice Standard / §10 Workflow 8단계 / §11 Completion Report / §12 Universal AskUserQuestion Enforcement 3-Layer)
- `README.md` — 출처, 2-Layer 도식, 사전조건 (aidlc-baseline 먼저 설치), install 방법, 가이드 §18 RealizeSoft 11 항목 충족
- `references/` — 10개 가이드 §section 원문 인용 사본 (§4 / §9 / §10 / §11.2 / §12 / §13 / §14 / §15 / §17 / §18)

**§4 비협상 규칙 7개 (cross-runtime-guide 인용)**:
1. Preserve The Baseline (§4.1)
2. No Hidden Helper Execution (§4.2)
3. Strict Gate Preservation (§4.3)
4. UserChoice Records (§4.4)
5. Provider-Neutral Deployment (§4.5)
6. No Fake Runtime Equivalence (§4.6)
7. Product Input Exclusion (§4.7)

**Universal AskUserQuestion Wrapper (사용자 명시 요청 2026-05-14)**:
helper routing 시점에 AskUserQuestion gate 를 3 계층으로 강제:
- **Layer 1**: Pre-Helper Selection Gate (본 스킬 직접 발동)
- **Layer 2**: Helper Self-Gate Preservation (helper 자체 gate 보존)
- **Layer 3**: Helper Self-Gate Absence Fallback (helper 가 자체 gate 없으면 본 스킬이 wrapper 로 강제 발동)

→ 본 스킬이 활성화된 모든 helper 호출에서 AskUserQuestion 이 반드시 뜸. helper 가 자체 미지원이어도 over-coverage.

**Hybrid 배치 전략**:
- **마스터 사본** (git 추적): `claude-templates/.claude/skills/aidlc-realizesoft/`
- **활성 글로벌 사본**: `~/.claude/skills/aidlc-realizesoft/` — `scripts/install-aidlc-realizesoft.ps1` 실행으로 배포
- **backup 격리**: `~/.claude/skills-backups/` (skill registry 오염 방지 — 스킬 1 에서 검증된 패턴)

**사전조건**:
`aidlc-baseline` (§4.8) 이 먼저 글로벌 설치되어 있어야 함. install 스크립트가 `~/.claude/skills/aidlc-baseline/SKILL.md` 존재 여부를 검증.

**글로벌 install**:
```powershell
# 스킬 1 먼저 (이미 설치되어 있으면 skip)
.\scripts\install-aidlc-baseline.ps1
# 스킬 2
.\scripts\install-aidlc-realizesoft.ps1
```

활성화 후 어느 프로젝트에서나 "aidlc realizesoft", "AI-DLC workflow", "start AI-DLC with realizesoft" 등 키워드로 호출. 두 스킬 모두 매칭되어 RealizeSoft 레이어가 baseline 위에서 작동.

**가이드 §18 RealizeSoft Verification Checklist (11 항목 모두 통과)**:
Layer 분리 / 조건부 helper routing / Selection Gate 5요소 / Strict Gate Preservation / Q4 mandatory / UserChoice 표준 / Provider-Neutral deployment / Explicit-only 격리 / Runtime 차이 명시 / Project-specific exclusion / Generated layer type 명시.

**참조**:
- `realizesoft/realizesoft-cross-runtime-skill-guide.md` (§3 Core Architecture, §4 Non-Negotiable Rules, §9 Helper Routing, §10 Selection Gate, §11.2 Claude command skeleton, §12 UserChoice, §13 UI/UX Gate, §14 Deployment Gate, §15 Explicit-Only Skills, §17 Minimal Template, §18 Verification Checklist)
- `.claude/plans/table-order-macos-claudecode-requirement-iridescent-leaf.md` — 본 스킬 작업의 plan 기록 (Why/What/How/So What 4단계 + 9 실행 단계)

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
