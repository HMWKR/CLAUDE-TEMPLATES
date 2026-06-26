---
name: aidlc-realizesoft
description: "RealizeSoft layer for aidlc-baseline. Enforces cross-runtime-guide §4 non-negotiable rules (Selection Gate / Strict Gate Preservation / UserChoice Records / Provider-Neutral Deployment / Product Input Exclusion / No Hidden Helper Execution / No Fake Runtime Equivalence) on top of aidlc-baseline workflow. REQUIRES aidlc-baseline skill installed at ~/.claude/skills/aidlc-baseline/. Use when starting AI-DLC workflow with helper routing, when phrases like 'RealizeSoft', 'realizesoft layer', 'AI-DLC with helper routing', 'helper routing', 'Selection Gate', 'UserChoice', 'provider-neutral deploy', '워크플로우 with helper', '비협상 규칙' appear. Universal AskUserQuestion Wrapper: every helper trigger and every gate is enforced via the AskUserQuestion tool — helpers without their own gate are wrapped automatically."
---

# aidlc-realizesoft — RealizeSoft Layer for aidlc-baseline

> Companion to `aidlc-baseline`. Implements cross-runtime-guide §3 Core Architecture's 2-Layer model. **Does not modify the baseline lifecycle file — it only attaches non-negotiable rules, helper routing, and user-choice gates on top.**

---

## 1. Purpose

본 스킬은 `realizesoft-cross-runtime-skill-guide.md` §3 Core Architecture 가 정의한 2-Layer 모델의 **RealizeSoft 레이어**를 Claude Code 환경에서 실현한다:

```
Baseline Source Discovery    ← aidlc-baseline (별도 스킬, 본 스킬과 함께 활성화)
       ↓
RealizeSoft Layer            ← 본 스킬 (helper routing + user-choice gate + 비협상 규칙)
       ↓
Baseline AI-DLC Stage Continues
```

가이드 §4 의 비협상 규칙 7개를 모든 AI-DLC 워크플로우 분기에 강제하여, 자동 helper 폭주 / deploy 자동 가정 / product input 오염을 차단하고, 모든 사용자 결정은 native UI gate (`AskUserQuestion`) 로 처리되도록 한다.

## 2. Layer Relationship (aidlc-baseline 과의 관계)

본 스킬은 **aidlc-baseline 의 lifecycle 본문을 변경하지 않는다** (가이드 §4.1). 워크플로우 진행 시점에 비협상 규칙·게이트·helper routing 을 부착하는 **별도 레이어** 다.

### Layer 구성

| Layer | 자산 | 역할 |
|---|---|---|
| **Baseline Layer** | `aidlc-baseline` 스킬 (`~/.claude/skills/aidlc-baseline/SKILL.md`) | AI-DLC 3-Phase 14-stage lifecycle 본문. 가이드 §4.1 에 따라 절대 수정하지 않음. |
| **RealizeSoft Layer** | **본 스킬** | Baseline 위에 부착되는 helper routing + user-choice gate + 비협상 규칙 강제. AI 모델이 본 스킬을 호출하면 Baseline 의 lifecycle 본문을 자동으로 참조 (글로벌 같은 위치에 설치된 동등 자산). |

### Activation Order

- 사용자 트리거 키워드로 호출 → AI 모델이 두 스킬 모두 매칭 → 본 스킬이 RealizeSoft 레이어로 활성화하면서 Baseline 의 lifecycle 본문을 따라 진행
- 또는 사용자가 명시적으로 본 스킬만 호출 → 본 스킬이 글로벌 위치 `~/.claude/skills/aidlc-baseline/` 의 Baseline 자산을 자동 참조

### Hard Constraint

본 스킬을 사용하는 모든 작업에서 **aidlc-baseline 의 SKILL.md / references/ 는 절대 수정하지 않는다.** 본 스킬이 baseline 본문에 영향을 주려면 새 RealizeSoft 레이어 산출물 (예: `aidlc-docs/UserChoice/<stage>/decision.md`) 을 별도 생성한다 — baseline 자산은 byte-for-byte 그대로 유지.

## 3. Non-Negotiable Rules (가이드 §4, 7개)

이하 7개 규칙은 본 스킬이 활성화된 모든 워크플로우에서 **하드 제약** 이다. 어떤 helper routing 결정도 이 규칙을 위배할 수 없다. 상세는 `references/non-negotiable-rules.md` (가이드 §4 원문 인용 사본).

| # | 규칙 | 본 스킬의 실현 메커니즘 |
|:-:|---|---|
| 1 | **Preserve The Baseline** (§4.1) | aidlc-baseline 의 SKILL.md / references/ 절대 수정 안 함. 본 스킬은 별도 파일 |
| 2 | **No Hidden Helper Execution** (§4.2) | helper 호출 전 §6 Selection Gate (AskUserQuestion) 필수 |
| 3 | **Strict Gate Preservation** (§4.3) | 각 helper 의 자체 input gate 보존 (§12 Layer 2). 자체 gate 가 없으면 본 스킬이 wrapper (§12 Layer 3) |
| 4 | **UserChoice Records** (§4.4) | 모든 사용자 결정 후 `aidlc-docs/UserChoice/<stage>/<gate-slug>/decision.md` 자동 작성 (§9 명세) |
| 5 | **Provider-Neutral Deployment** (§4.5) | 배포 시 §8 Deployment Provider Gate 발동. Vercel/AWS/GCP 등 자동 가정 금지 |
| 6 | **No Fake Runtime Equivalence** (§4.6) | 본 스킬은 Claude Code 전용 (frontmatter 명시). Codex/Kiro 동등 가정 금지 |
| 7 | **Product Input Exclusion** (§4.7) | 워크스페이스의 `requirements/`, `constraints.md`, `docs/prd*` 등은 generic lifecycle source 로 사용 안 함 |

## 4. Helper Routing Matrix (가이드 §9 + 사용자 환경 매핑)

상세는 `references/helper-routing-matrix.md`. AI-DLC 의 각 영역에서 본 스킬이 Selection Gate 시 추천하는 helper:

| AI-DLC Area | Recommended Helper (Claude Code 글로벌 스킬) | Trigger Condition |
|---|---|---|
| Orient / Purpose | `what`, `cynefin` | 목적 / 복잡도 / 성공 기준 불명확 |
| Requirements / Discovery | `domain-researcher`, `ux-pattern-researcher` | 시장·도메인·경쟁사·UX 패턴 지식 부족 |
| Planning / Design | `architect`, `first-principles` | 아키텍처 설계 / 전제 의심 / 근본부터 재구성 |
| Implementation | `js-refactor-cleanup-skill` (JS/TS 한정) | 코드 cleanup·rename·refactor |
| Verification | `webapp-testing`, `security-audit`, `web-design-guidelines`, `live-verify-loop` | 브라우저 검증 / 보안 / UI 가이드라인 / 라이브 루프 |
| Deployment | (본 스킬의 §8 Provider Gate) | 배포 시점 |

가이드 §9 가 명시한 helper 중 사용자 환경에 미존재 (`to-prd`, `grill-me`, `tdd`, `diagnose`) 는 본 스킬에서 추천 안 함. 미존재 helper 가 사용자 환경에 추가되면 routing matrix 에 추가 가능.

## 5. Explicit-Only Skills (가이드 §15 — 자동 spawn 절대 금지)

상세는 `references/explicit-only-skills.md`. 다음 helper 들은 사용자가 **명시적으로 요청하지 않으면 절대 호출 안 한다**. 본 스킬이 Selection Gate 추천 목록에도 포함시키지 않는다. 사용자가 직접 키워드로 호출할 때만 발동:

| 카테고리 | 사용자 환경 스킬 | 자동 spawn 금지 사유 (가이드 §15) |
|---|---|---|
| Harness loops | `harness-loop` | broad orchestration, repeated quality rounds |
| Agent teams | `agent-teams-*` (6개), `agent-teams-orchestrator` | real delegation requires explicit authorization |
| Continuous QA | `continuous-qa-loop` | repeated automated fix-verify 비용 |
| Ultradetail walks | `ultradetail-walk`, `ultradetail-loop`, `ultra-walk-deep`, `walk-all-deep` | exhaustive browser inspection 고비용 |
| Project bootstrap | `project-bootstrapper`, `project-kickstart`, `pipeline-orchestrator` | baseline lifecycle 덮어쓸 위험 |
| Thinking chains | `think-deep`, `think-full`, `think-teams` | `cynefin` / `what` / `first-principles` 와 중복 가능성 |
| External record writers | (Cantos MCP / journal 등 명시 호출만) | ADR/DDR/journal 쓰기는 별도 user intent 필요 |

본 스킬은 위 helper 들의 **자동 spawn 시도를 차단**. 사용자가 직접 트리거 키워드를 입력할 때만 호출됨 (Q4 explicit approval, §12 Layer 1).

## 6. Selection Gate Protocol (가이드 §10 + 사용자 명시 2026-05-16 확장)

### 발동 분기점 3 종 (사용자 명시 2026-05-16 강화)

| # | 분기점 | 발동 위치 | Layer |
|:-:|---|---|---|
| 1 | **Stage Entry** (신규) | 매 AI-DLC stage 진입 시 자동 | §12 Layer 0 + §10 Step 4a |
| 2 | **Helper 호출 직전** | helper 도구 호출 도구 invoke 직전 | §12 Layer 1 + §10 Step 5 |
| 3 | **Per-Step Sub-Gate** (선택) | stage 내부 step 에서 helper 적합 분기점 발생 시 | §10 Step 8a |

상세는 `references/selection-gate-template.md`. 위 3 분기점 모두에서 본 스킬은 **반드시** 다음 형식으로 `AskUserQuestion` 도구를 호출:

### Selection Gate 형식

```
<Stage> Selection Gate

Goal: <이 결정이 무엇을 통제하는가>

Option 1. <Recommended helper> (첫 번째 위치 = 추천)
  - Why recommended: <이유>
  - Pros / Cons: <장단점>
  - Cost / Speed / Risk: <트레이드오프>

Option 2. <Alternative or Skip>
  - Pros / Cons / Cost: ...

Option 3. <Other alternative if any>
  - ...

(AskUserQuestion 의 "Other" 옵션은 자동 제공됨)
```

### AskUserQuestion 매핑 규칙

- 첫 옵션 = 추천 (label 에 "(Recommended)" 표기)
- 옵션 최대 4개 + Other 자동
- 5개 이상의 helper 후보가 있으면: (a) 가장 중요한 4개로 압축 + Other / (b) 두 번의 AskUserQuestion 으로 분할 (예: "Category 1 vs Category 2" 먼저, 그 후 "선택된 Category 안에서 어느 helper")
- `description` 필드에 Pros / Cons / Cost 명시
- 결과 받기 전 helper 호출 도구 호출 금지 (blocking gate)

## 7. UI/UX Decision Gate (가이드 §13)

상세는 `references/uiux-decision-gate.md`. UI/UX 결정이 필요한 시점에 본 스킬은 다음 형식으로 `AskUserQuestion` 호출:

| 옵션 | 사용 시점 | Pros | Cons |
|---|---|---|---|
| **ASCII Wireframe** (Recommended for quick structure) | 정보 설계 / IA 검증 단계 | 빠름, 채팅에서 읽기 좋음 | 비주얼 다듬기·반응형 판단 약함 |
| **HTML Preview** | 실제 layout / flow / visual state 확인 | 실제와 가까움 | 파일 생성·검증 시간 필요 |
| **External Reference Input** | 사용자가 Figma / Notion / 스크린샷 / URL / 자유 텍스트 스타일 방향 제공 | 사용자 의도 정확 반영 | 입력 품질에 의존 |

External Reference Input 선택 시 받을 수 있는 입력 형태: Figma link / Notion page / 스크린샷 또는 이미지 경로 / 참조 웹사이트 URL / 자유 텍스트 스타일 설명.

## 8. Deployment Provider Gate (가이드 §14)

상세는 `references/deployment-provider-gate.md`. 배포 계획·실행 시점에 본 스킬은 **Vercel 등을 default 로 가정하지 않는다** (§4.5). 다음 형식으로 `AskUserQuestion` 호출:

### Provider 후보 (가이드 §14 명시 9개)

1. **Plan only** (Recommended when credentials/tools are unclear)
2. AWS
3. Google Cloud
4. Azure
5. Cloudflare
6. Firebase
7. Supabase
8. Vercel
9. Self-hosted / VPS

### AskUserQuestion 4 옵션 한도 처리

AskUserQuestion 도구는 최대 4 옵션이므로, 9개 후보 → 2단계 gate:

- **1st gate**: ["Plan only (Recommended)", "Major cloud (AWS/GCP/Azure)", "PaaS/BaaS (Cloudflare/Firebase/Supabase/Vercel)", "Self-hosted"]
- **2nd gate** (1st 에서 cloud 또는 PaaS 선택 시): 해당 카테고리 안의 구체 옵션 4개

### Selection Criteria

가이드 §14 의 표 (App shape / Runtime / Data / Traffic / Operations / Cost / Region / Tool / Rollback) 를 사용자에게 보여주고 선택 도움. 실제 배포·production change·domain change·external write·credential·cost-impacting 작업은 별도 Q4 explicit approval 필수.

## 9. UserChoice Standard (가이드 §12)

상세는 `references/userchoice-standard.md`. 모든 사용자 결정 후 다음 위치에 `decision.md` 자동 작성:

### 디렉토리 구조

```
<WORKSPACE-ROOT>/aidlc-docs/UserChoice/
├── orient/
├── requirements-discovery/
├── planning-design/
├── implementation/
├── verification/
├── deployment/
└── uiux/

각 게이트별:
aidlc-docs/UserChoice/<stage>/<gate-slug>/
├── ascii-wireframe.txt    (선택: §7 ASCII 선택 시)
├── preview.html           (선택: §7 HTML 선택 시)
├── external-input.txt     (선택: §7 External 선택 시)
└── decision.md            (필수)
```

### decision.md 템플릿 (가이드 §12)

```markdown
# User Choice Decision

## Pipeline Stage
## Gate
## Options Presented
## Recommended Option
## Why Recommended
## User Selection
## Evidence Flow
## Tradeoffs
## Input Gate Mode
## Triggered Skill Gates

| Skill | Gate Profile | Applied As | Reason |
|---|---|---|---|

## Resulting Pipeline Behavior
## Files Created
## Remaining Risks
```

**원칙**: 빈 placeholder 만들지 않음. 사용자가 실제 선택한 후만 `decision.md` 생성.

## 10. Workflow (가이드 §11.2 + 사용자 명시 2026-05-16 — Stage Entry Gate 강화)

본 스킬이 활성화되면 다음 9단계 워크플로우로 baseline 위에 부착된다:

| Step | 동작 | Gate? |
|:-:|---|:-:|
| 1 | Resolve baseline source — `~/.claude/skills/aidlc-baseline/references/aws-aidlc-rule-details/` 우선, 워크스페이스 `.aidlc-rule-details/` 도 발견 시 인지 | — |
| 2 | Classify and exclude product inputs — 워크스페이스의 `requirements/`, `constraints.md`, `docs/prd*` 발견 시 generic source 에서 제외 명시 | — |
| 3 | Extract stage / gate / artifact / validation rules from baseline | — |
| 4 | Detect current AI-DLC stage — baseline lifecycle 의 어느 stage 인지 (Workspace Detection → Requirements Analysis → ...) | — |
| **4a** | **🆕 Stage Entry Selection Gate (사용자 명시 2026-05-16 강화)** — 매 stage 진입 시 **분석 방식 자체를 게이트화**. helper 호출 여부와 무관하게 자동 발동. 옵션 default: (a) 메인 Claude 직접 분석 / (b) `Explore` 서브에이전트 위임 / (c) stage-적합 helper 호출 (`architect` / `domain-researcher` / `webapp-testing` 등) | **🚨 MANDATORY** |
| 5 | helper 호출 분기점 발생 시 **Pre-Helper Selection Gate** (§6) — `AskUserQuestion` blocking | **Q3** |
| 6 | Execute selected helper (preserve its own gates per §12 Layer 2, or wrap per §12 Layer 3) | helper 자체 gate |
| 7 | Continue baseline lifecycle to next stage | — |
| 8 | Write `aidlc-docs/UserChoice/<stage>/<gate-slug>/decision.md` (§9) | — |
| **8a** | **🆕 Per-Step Sub-Gate (선택적 강화)** — stage 내부 step 이 helper 적합 분기점을 가지면 (예: Architecture step 에서 `architect` 호출 vs 직접 작성) Pre-Helper Selection Gate 추가 발동. baseline 의 inception/construction stage 내부 step (workspace-detection / requirements-analysis / user-stories / workflow-planning / application-design / units-generation / reverse-engineering / functional-design / nfr-* / infrastructure-design / code-generation / build-and-test) 모두 검토 | 선택 |

### Step 4a 상세 (사용자 명시 2026-05-16 강화)

> **사용자 명시 (2026-05-16)**: "Stage 진입 시점에 자동으로 Selection Gate 발동되도록 스킬 수정해줘"

본 스킬은 **매 AI-DLC stage 진입 시점에 helper 호출 분기점이 있든 없든 무관하게** `AskUserQuestion` 으로 Stage Entry Selection Gate 발동:

```
<Stage N> Entry Selection Gate

Goal: <Stage N> 의 분석/실행 방식 선택

Option 1. <Recommended for this stage>
  - 예: Workspace Detection → 메인 Claude 직접 (정보 수집형)
  - 예: Reverse Engineering → `Explore` 서브에이전트 (코드베이스 탐색 + 메인 컨텍스트 보호)
  - 예: Application Design → `architect` helper (아키텍처 설계 전문)
  - 예: Code Generation → 메인 Claude 직접 + Edit/Write
  - 예: Requirements Analysis → `domain-researcher` 또는 메인 + AskUserQuestion 사용자 인터뷰

Option 2. 메인 Claude 직접 (Read/Glob/Grep + Write)
Option 3. <Alternative helper or Explore subagent>
(Other 옵션 AskUserQuestion 자동 제공)
```

### Stage-별 Recommended Helper 매트릭스 (Step 4a 기본 추천)

| Baseline Stage | Recommended Helper | 이유 |
|---|---|---|
| 1. Workspace Detection | 메인 Claude 직접 | 정보 수집형, 빠른 진행 |
| 2. Reverse Engineering | `Explore` 서브에이전트 (대규모 코드베이스) 또는 메인 직접 (소규모) | 코드베이스 탐색 + 메인 컨텍스트 보호 |
| 3. Requirements Analysis | 메인 Claude 직접 + `domain-researcher` (시장 지식 필요 시) | 사용자 인터뷰 형식 |
| 4. User Stories | 메인 Claude 직접 | INVEST 원칙 적용 |
| 5. Workflow Planning | 메인 Claude 직접 | 의존성 매트릭스 |
| 6. Application Design | `architect` helper | 아키텍처 설계 전문 |
| 7. Units Generation | 메인 Claude 직접 | DDD bounded context |
| 8. Functional Design | `architect` 또는 메인 직접 | 컴포넌트 설계 |
| 9. NFR Requirements | 메인 Claude 직접 + `security-audit` 사전 review | 비기능 요구 |
| 10. NFR Design | 메인 직접 + `architect` (선택) | NFR 설계 |
| 11. Infrastructure Design | `architect` + `domain-researcher` (클라우드 비용 비교) | 인프라 설계 |
| 12. Code Generation | 메인 Claude 직접 + Edit/Write + `js-refactor-cleanup-skill` (선택) | 직접 구현 |
| 13. Build and Test | `webapp-testing` + `security-audit` | 검증 |
| 14. Operations | `webapp-testing` + `live-verify-loop` (사용자 명시 시) | 운영 검증 |

각 stage 진입 시 위 매트릭스를 default 추천으로 사용. 단 매트릭스 외 선택 (Other) 항상 가능.

### Anti-Pattern (Step 4a 위반 사례 영구 기록, 2026-05-16)

- ❌ Stage 진입 시 helper 호출 분기점이 없다는 이유로 Step 4a 를 SKIP
- ❌ "이전 stage 와 같은 방식으로 진행" 가정 (각 stage 는 독립 게이트)
- ❌ 사장이 한 번 "직접 진행" 결정했다고 모든 후속 stage 에 자동 적용

각 stage 의 user approval gate 는 baseline 의 본문 자체가 명시하므로, 본 스킬은 그 게이트 발동 시점에 **`AskUserQuestion` 도구 사용을 강제** (§12 Universal Wrapper).

## 11. Completion Report

본 스킬을 사용한 작업이 완료되면 다음 항목을 보고:

- **Baseline source**: 어디서 lifecycle 본문을 가져왔는지 (`~/.claude/skills/aidlc-baseline/` 또는 워크스페이스 `.aidlc-rule-details/`)
- **Excluded product inputs**: 제외한 파일 목록 (`requirements/` 등)
- **Stages used**: baseline 의 어느 stage 들이 실행되었는지
- **Helpers selected**: Selection Gate 에서 선택된 helper 목록
- **UserChoice records**: 작성된 `aidlc-docs/UserChoice/.../decision.md` 파일 목록
- **Files changed**: 사용자 워크스페이스의 변경 파일 목록
- **Verification**: 실행한 검증 (test 결과, security audit 결과 등)
- **Runtime limits**: Claude Code 환경에서 작동 안 한 부분 (예: Codex/Kiro native 도구)
- **Next step**: 사용자가 추가로 결정해야 할 사항

## 12. Universal AskUserQuestion Enforcement (Wrapper Role, 2026-05-14 사용자 명시 요구)

> 사용자 명시 (2026-05-14): "트리거 되는 스킬중 [AskUserQuestion 이] 안 뜨는 스킬들이 있다면 본 스킬을 수정해도 상관 없으니 뜨게끔 해줘"

본 스킬은 helper routing 시점에 `AskUserQuestion` gate 를 **4 계층** 으로 강제한다 (Layer 0 신규 추가, 사용자 명시 2026-05-16). 모든 분기점에서 native UI gate 가 발동되도록 보장.

### Layer 0: Stage Entry Gate (사용자 명시 2026-05-16 신규)

> 사용자 명시: "Stage 진입 시점에 자동으로 Selection Gate 발동되도록"

매 AI-DLC stage 진입 시 helper 호출 분기점 유무와 무관하게 자동 발동:

- `question`: "<Stage N> Entry Selection Gate — 분석/실행 방식 선택"
- `options`: §10 Step 4a 의 Stage-별 Recommended Helper 매트릭스 기반 3~4개 (Recommended + 메인 직접 + Explore + Other)
- `description`: 각 옵션의 Pros / Cons / Cost / Speed
- 결과 받기 전 어떤 도구도 호출 금지 (BLOCKING)
- 결과 받은 후 `aidlc-docs/UserChoice/<stage>/method-selection/decision.md` 즉시 작성

**위반 시 처벌**: Stage 진입 후 첫 Read/Glob/Grep/Write/Edit/Bash 호출이 Layer 0 발동 흔적 없이 실행되면 anti-pattern. 사용자 retroactive 검증 시점에 즉시 archive + 재시작.

### Layer 1: Pre-Helper Selection Gate (본 스킬 직접 발동)

helper 를 호출하기 **직전**, 반드시 `AskUserQuestion` 으로 Selection Gate 발동:

- `question`: "What helper should run for <current stage>?"
- `options`: [Recommended helper, Alternative, Skip] (최대 4 + Other)
- 결과를 받기 전 helper 호출 도구 호출 금지

### Layer 2: Helper Self-Gate Preservation (가이드 §4.3)

helper 가 자체 `AskUserQuestion` gate 를 가지면 **그대로 보존**. 본 스킬이 추가 wrapper 안 함.

확인된 자체 사용 helper:
- `what` (Why-What-How-So What 4단계 Confirmation Loop)
- `ce-advisor` (3+1 suggestions Confirmation)
- `architect` (7-step expert flow, gate 사용 확신)

### Layer 3: Helper Self-Gate Absence Fallback (사용자 요청 2026-05-14)

helper 가 user input 이 필요한 시점에서 자체 `AskUserQuestion` 을 **안 띄우면** (텍스트로만 묻고 채팅 입력 기대):

- 본 스킬이 helper 실행 직후 즉시 `AskUserQuestion` 으로 user input 보강
- helper 가 텍스트로 출력한 질문이 있으면 → 본 스킬이 그 질문을 `AskUserQuestion` 의 `question` 으로 변환, 선택지를 `options` 로 변환
- helper 가 자유 입력만 받는 경우 → 본 스킬이 기본 4 옵션 wrapper: ["Continue with default", "Modify", "Cancel and return"]

### Helper-by-Helper Mapping ([미확인] 인 helper 는 default Layer 3)

| Helper | 자체 AskUserQuestion? | 본 스킬 처리 |
|---|:-:|---|
| `what` | O | Layer 2 (보존) |
| `ce-advisor` | O | Layer 2 (보존) |
| `architect` | O (추정) | Layer 2 (보존) |
| `cynefin` | [미확인] | **Layer 3** (default wrapper) |
| `domain-researcher` | [미확인] | **Layer 3** |
| `ux-pattern-researcher` | [미확인] | **Layer 3** |
| `first-principles` | [미확인] | **Layer 3** |
| `webapp-testing` | [미확인] | **Layer 3** |
| `security-audit` | [미확인] | **Layer 3** |
| `web-design-guidelines` | [미확인] | **Layer 3** |
| `live-verify-loop` | [미확인] | **Layer 3** |
| `js-refactor-cleanup-skill` | [미확인] | **Layer 3** |
| Explicit-only (§5) | N/A — spawn 자체 차단 | **Layer 1** (Pre-Selection Gate 로 사용자 명시 승인 필수) |

**Default 정책**: 자체 사용 여부 [미확인] 인 모든 helper 는 **Layer 3 (wrapper) 적용**. 안전한 over-coverage 로, helper 호출 후 AI 가 텍스트로 사용자 응답을 기다리는 패턴 발견 시 즉시 `AskUserQuestion` 으로 변환.

### Anti-Patterns (절대 금지)

1. helper 가 자체 `AskUserQuestion` 안 띄운다고 본 스킬도 안 띄우고 그냥 진행 — 사용자 명시 요청 위배
2. helper 텍스트 출력을 본 스킬이 그대로 user 에게 흘려보내고 채팅 응답 대기 — Question Gate Mandate 위배
3. Layer 1 Selection Gate 를 skip 하고 바로 helper invoke — §4.2 No Hidden Helper Execution 위배
4. Layer 3 wrapper 를 "helper 가 알아서 처리할 것" 이라며 생략 — 사용자 명시 over-coverage 정책 위배

### 효과 (사용자 경험)

본 스킬이 활성화된 워크플로우에서 사용자는:
- 모든 helper 호출 전 Selection Gate 를 본다 (Layer 1)
- 자체 gate 있는 helper 는 그 helper 의 native UI gate 를 본다 (Layer 2)
- 자체 gate 없는 helper 도 본 스킬이 wrapper 로 native UI gate 를 본다 (Layer 3)
- 절대 "텍스트로만 묻고 채팅 응답 기다리기" 패턴을 만나지 않는다

---

## Operational Notes

### 호출 방법

다음 트리거 키워드 중 하나로 본 스킬 호출:
- "RealizeSoft", "realizesoft layer"
- "AI-DLC with helper routing"
- "Selection Gate", "UserChoice"
- "provider-neutral deploy"
- "비협상 규칙", "워크플로우 with helper"

### 사전 조건

- `aidlc-baseline` 스킬이 글로벌 `~/.claude/skills/aidlc-baseline/` 에 설치되어 있어야 함
- 미설치 시 본 스킬은 사용자에게 baseline 설치를 안내하고 종료

### Baseline 단독 사용 vs 본 스킬 함께 사용

- **Baseline 단독** (본 스킬 없음): AI-DLC lifecycle 본문만 실행. helper routing / Selection Gate / UserChoice 기록 없음. 모든 gate 는 baseline 본문의 "Wait for Explicit Approval" 만 발동
- **Baseline + 본 스킬**: lifecycle 본문 위에 §3-12 의 모든 기능 부착. **권장 운영 형태**.

### References

본 스킬의 references/ 디렉토리는 cross-runtime-guide 의 관련 §section 원문 인용 사본을 보존:

- `references/non-negotiable-rules.md` — 가이드 §4 전문
- `references/helper-routing-matrix.md` — 가이드 §9 + 사용자 환경 매핑
- `references/selection-gate-template.md` — 가이드 §10
- `references/runtime-gate-mapping.md` — 가이드 §11.2
- `references/userchoice-standard.md` — 가이드 §12
- `references/uiux-decision-gate.md` — 가이드 §13
- `references/deployment-provider-gate.md` — 가이드 §14
- `references/explicit-only-skills.md` — 가이드 §15 + 사용자 환경 자동 차단 목록
- `references/minimal-cross-runtime-template.md` — 가이드 §17
- `references/verification-checklist.md` — 가이드 §18 (RealizeSoft 항목)

원본 가이드 (`realizesoft/realizesoft-cross-runtime-skill-guide.md`) 와 baseline 스킬 (`aidlc-baseline`) 은 절대 수정하지 않는다.
