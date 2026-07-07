---
name: frontend-review
description: |
  프론트엔드 코드 PR/diff 정적 검수 통합 스킬. 18 specialists 6 Tier 병렬 (UI/UX 4 + Design 4 + Accessibility 3 + Performance 3 + Framework 2 + FE Security 2).
  ~450 체크리스트 항목 + Frontend Quality Score 0-100 (18차원 가중치) + 7등급 (S/A+/A/B+/B/C/F).
  Use when asked to "frontend review", "프론트엔드 리뷰", "프론트 검수", "UI 코드 리뷰", "디자인 코드 리뷰", "React 리뷰", "Next.js 리뷰", "프론트 PR 리뷰", or "/frontend-review".
  NOT for: 백엔드/일반 코드 (use code-review plugin), 라이브 브라우저 검수 (use playwright-uiux-audit / playwright-design-audit / playwright-qa-expert), 보안만 (use security-reviewer agent), CE 4대 실패 모드 (use ce-reviewer agent).
  Modes: basic (30 items quick) / --full (~150 items) / --all (~450 items 18 specialists). Agent-Teams with AGENT_TEAMS=1.
user_invocable: true
---

# Frontend Review — 프론트엔드 전수 코드 리뷰

> **원칙**: "프론트엔드는 백엔드보다 사용자 경험에 직접 노출 — 한 줄 코드 차이가 전환율을 흔든다."
> **공통 프로토콜**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md` 참조
> **역할 정의**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/roles.md` 참조
> **P3-6 신설**: 2026-05-26. 사용자 명시 발화 "code-review 처럼 UI/UX 디자인 전부 진행하는 스킬 만들자" + `/propose-skill` 워크플로우 통과 (skill-candidate 2/4 트리거 충족: 사용자 명시 + CE Architect 권장 / B 카테고리 / ROI High).

---

## ⚠️ Uncompromising Rigor (글로벌 룰 강제 적용)

이 스킬은 `~/.claude/rules/uncompromising-rigor.md` 4개 정책을 **무조건 준수**:

1. **§1 Browser Tool Priority** — 본 스킬은 정적 코드 리뷰. 라이브 검증 필요 시 `playwright-uiux-audit` / `playwright-design-audit` 로 위임 (브라우저 우선순위는 rules/uncompromising-rigor §1 — 2026-07-07 Playwright MCP 전역 우선)
2. **§2 Self-Justification 차단** — "이 정도면 충분" / "사소함" / "사용자가 신경 안 씀" 표현 즉시 차단
3. **§3 All Findings Are Defects** — 모든 발견은 결함. 사용자 명시 강등만 Low
4. **§4 Per-Round Deep Analysis** — `--loop` 모드 시 매 라운드 5단계 강제

---

## 1. 책임 경계 (Confusion 차단 — 필수 분담 매트릭스)

| 스킬 / 에이전트 | 시점 | 영역 | 환경 |
|---|---|---|---|
| **`frontend-review` (본 스킬)** | **PR 단계 (정적)** | **프론트엔드 UI/UX + Design + A11y + Performance + React/Next.js + FE Security** | **정적 코드** |
| `code-review` (외부 플러그인) | PR 단계 | 백엔드/일반 코드 (Security/Architecture/Performance/Testing) | 정적 |
| `security-reviewer` (agent, P0-3) | PR 단계 | 보안만 — OWASP Top 10 (백엔드 포함) | 정적 |
| `ce-reviewer` (agent) | PR 단계 | CE 4대 실패 모드 (Poisoning/Distraction/Confusion/Clash) | 정적 |
| `playwright-uiux-audit` | 구현 후 | UI/UX 18 specialists 360 체크리스트 | **라이브 브라우저** |
| `playwright-design-audit` | 구현 후 | UI/UX + Design 19 specialists 3-Wave ~450 체크리스트 24 카테고리 | **라이브 브라우저** |
| `playwright-qa-expert` | 구현 후 | QA 다중 전문가 패널 | **라이브 브라우저** |
| `vercel-react-best-practices` | 가이드라인 (참조용) | React/Next.js 성능 패턴 | 정적 (참조 문서) |
| `web-design-guidelines` | 가이드라인 (참조용) | Web Interface Guidelines | 정적 (참조 문서) |

**핵심 분담 한 문장**: PR 단계 = **frontend-review (UI/UX/디자인/A11y/성능/프레임워크/FE보안)** + code-review (백엔드) + security-reviewer (보안만) + ce-reviewer (CE). 구현 후 = playwright-* 4종 (라이브).

---

## 2. 실행 모드

| 모드 | 호출 | 팀 구성 | 체크리스트 | 시간 | 설명 |
|:----:|---|:-------:|:---:|:--:|---|
| **basic** | `/frontend-review` 또는 `frontend-review` | Lead 1 (Agent-Teams 비활성) | ~30 항목 | 5-8분 | 핵심 Tier (Top 30 검사) |
| **--full** | `--full` | Lead + 6 TM (Tier 대표) | ~150 항목 | 15-25분 | Tier별 1 specialist + Lead |
| **--all** | `--all` | Lead + 18 TM (전체) | **~450 항목** | 30-60분 | 18 specialists 전수 |
| **--focus** | `--focus=<tier>` | Lead + 해당 Tier specialists | 가변 | 가변 | 특정 Tier만 집중 (uiux/design/a11y/performance/framework/security) |
| **--loop** | `--loop` | 위 모드 + Stage 7 수렴 루프 | 무한 | 무한 | 결함 0건 도달까지 walk-fix-walk |

### 환경 확인

```
1. CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 확인 (--full / --all 모드)
2. 프로젝트 루트 확인 (package.json + 프론트엔드 의존성)
3. 기술 스택 자동 식별 (React / Next.js / Vue / Svelte / Solid 등)
4. 환경 미충족 → basic 모드 자동 fallback
```

---

## 3. 18 Specialists 구성 (6 Tier)

```
┌────────────────────────────────────────────────────────────────────────┐
│  Lead (Frontend Review Director)                                       │
│  - 18 TM 산출물 통합 + Frontend Quality Score 산정 + 등급 (S~F)         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                        │
│  Tier 1: UI/UX (4 TM) — 가중치 22%                                       │
│  ├─ TM1 UI Heuristics (Nielsen 10원칙)                                  │
│  ├─ TM2 Interaction Design (인터랙션 / 마이크로 인터랙션)                  │
│  ├─ TM3 Information Architecture (정보 계층 / 네비게이션)                 │
│  └─ TM4 User Flow (사용자 여정 / 에러 복구 경로)                          │
│                                                                        │
│  Tier 2: Design Quality (4 TM) — 가중치 22%                              │
│  ├─ TM5 Design Tokens (토큰 / CSS 변수 / theme)                          │
│  ├─ TM6 Color & Typography (색상 시스템 / 타이포 hierarchy)               │
│  ├─ TM7 Layout & Spacing (그리드 / 간격 / 반응형)                         │
│  └─ TM8 Visual Hierarchy (시각 우선순위 / 강조)                           │
│                                                                        │
│  Tier 3: Accessibility (3 TM) — 가중치 18%                                │
│  ├─ TM9 WCAG AA (perceivable/operable/understandable/robust)            │
│  ├─ TM10 Semantic HTML & ARIA (시맨틱 / role / aria-*)                   │
│  └─ TM11 Keyboard & Screen Reader (탭 순서 / 라이브 영역)                 │
│                                                                        │
│  Tier 4: Performance (3 TM) — 가중치 18%                                  │
│  ├─ TM12 React Rendering (memo/useMemo/useCallback/Suspense)            │
│  ├─ TM13 Bundle & Loading (코드 스플리팅 / Lazy / preload)                │
│  └─ TM14 Core Web Vitals (LCP/INP/CLS/TTFB/Hydration)                   │
│                                                                        │
│  Tier 5: Framework Best Practices (2 TM) — 가중치 12%                     │
│  ├─ TM15 React Patterns (Hooks 규칙 / 컴포넌트 패턴 / 상태 관리)           │
│  └─ TM16 Next.js / SSR (App Router / RSC / Server Actions / metadata)   │
│                                                                        │
│  Tier 6: Frontend Security (2 TM) — 가중치 8%                             │
│  ├─ TM17 XSS & Injection (innerHTML / sanitize / DOMPurify)             │
│  └─ TM18 CSP & Client Secrets (CSP / NEXT_PUBLIC / localStorage 시크릿)  │
└────────────────────────────────────────────────────────────────────────┘
```

---

> **18 specialists 상세 체크리스트 (6 Tier, ~450 항목, grep 패턴 포함)는 `references/checklists.md` 참조.** §3 의 TM1~TM18 구성표가 인덱스이며, 각 TM 의 핵심 책임·Grep 패턴·체크리스트 전문은 분리 파일에 보존됨.

## 5. 작업 절차

```
Stage 0: 프론트엔드 코드베이스 수집 (Lead)
- Glob 프론트엔드 파일 (*.tsx, *.jsx, *.vue, *.svelte, *.astro)
- package.json 분석 (의존성 / 프레임워크 식별)
- next.config.js / vite.config.ts / tailwind.config.js
- public/ 정적 자산
- styles/ + globals.css + tokens
→ audit-data/frontend-structure.md 저장

Stage 1: 18 specialists 병렬 분석 (Agent-Teams)
- 6 Tier 동시 활성화
- 각 TM이 자기 영역 grep + Read + 분석
- 컴포넌트별 매트릭스 생성
→ audit-reports/{tm-N}-{tier}.md 18개 보고서

Stage 2: Lead 통합 + Frontend Quality Score 산정
- 18개 보고서 통합
- 중복 발견 제거
- 우선순위 정렬 (Blockers / Warnings / Suggestions)
- 18차원 가중치 적용 → Frontend Quality Score 0-100
- 7등급 (S/A+/A/B+/B/C/F)
→ FRONTEND-REVIEW-{date}.md 통합 리포트

(--loop 옵션 시) Stage 7: 수렴 루프
- 발견 → 사용자 fix → 재 Stage 0~2 반복
- 결함 0건 3 라운드 연속 종결
```

---

## 6. Frontend Quality Score (0-100, 18차원 가중치)

```
영역_점수 = (PASS×10 + WARN×5) / (전체×10) × 100

가중치:
- Tier 1 UI/UX (4 TM):              22% (각 TM 5.5%)
- Tier 2 Design Quality (4 TM):      22% (각 TM 5.5%)
- Tier 3 Accessibility (3 TM):        18% (각 TM 6.0%)
- Tier 4 Performance (3 TM):          18% (각 TM 6.0%)
- Tier 5 Framework Best Practices (2 TM): 12% (각 TM 6.0%)
- Tier 6 Frontend Security (2 TM):    8% (각 TM 4.0%)

총점 = Σ (TM_점수 × 가중치)
```

### 등급 체계

| 점수 | 등급 |
|:----:|:----:|
| 95+ | S |
| 90+ | A+ |
| 85+ | A |
| 80+ | B+ |
| 70+ | B |
| 50+ | C |
| <50 | F |

---

## 7. 출력 형식

```markdown
# Frontend Review Report (YYYY-MM-DD)

## 검토 범위
- 모드: basic / --full / --all
- 변경 파일: N개
- 프론트엔드 프레임워크: React/Next.js/Vue/Svelte
- 검사 항목: ~30 / ~150 / ~450

## Frontend Quality Score
- **총점: NN.N / 100** (등급: S/A+/A/B+/B/C/F)
- Tier별 점수:
  | Tier | 점수 | 가중 | 기여 |
  |---|:--:|:--:|:--:|
  | UI/UX | 87.5 | 22% | 19.25 |
  | Design Quality | 92.0 | 22% | 20.24 |
  | Accessibility | 78.0 | 18% | 14.04 |
  | Performance | 85.5 | 18% | 15.39 |
  | Framework | 90.0 | 12% | 10.80 |
  | FE Security | 95.0 | 8% | 7.60 |
  | **합계** | — | 100% | **87.32 → A** |

## 🚨 Blockers (Critical/High — 머지 차단)

### B-1 [Tier 3 A11y / TM9 WCAG] 이미지 alt 누락 12개
- 파일: `src/components/Hero.tsx:42`, `src/components/Gallery.tsx:18`, ...
- 위험: WCAG 2.1 AA 1.1.1 위반 — 스크린 리더 사용자 정보 누락
- 권장: 의미 있는 이미지는 `alt="설명"`, 장식은 `alt=""`

### B-2 [Tier 6 FE Security / TM17 XSS] dangerouslySetInnerHTML 13개
- 파일: `src/blog/MarkdownRenderer.tsx:34`
- 위험: XSS 취약점
- 권장: DOMPurify sanitize 추가

## ⚠️ Warnings (Medium — 후속 조치)

### W-1 [Tier 2 Design / TM5 Tokens] 매직 컬러 값 35개
- 파일: `src/components/*.tsx`
- 위험: 토큰 일관성 약화
- 권장: theme.ts 토큰으로 교체

## 💡 Suggestions (Low — 권고)

### S-1 [Tier 4 Performance / TM13 Bundle] dynamic import 후보 5개

## Tier별 상세 보고서
(18개 TM 보고서 요약, 클릭하여 펼치기)

## 라우팅 권고 (다음 단계)

- Blockers는 즉시 fix → `/frontend-review --loop` 재검수
- Warnings는 별도 PR
- 라이브 검증 권장 시: `playwright-uiux-audit` 또는 `playwright-design-audit` 호출
- 보안 추가 검증: `security-reviewer` 또는 `security-audit` 호출

## 검토 결과
- **Approve / Conditional Approve / Request Changes**
- 사유: ...
```

---

## 8. 10단계 파이프라인 View (인사이트 1 매핑)

| Step | 인사이트 1 단계 | 본 스킬 매핑 |
|:-:|---|---|
| 1 | Input Normalizer | PR / diff / 디렉토리 정규화 + 모드 (basic / --full / --all) |
| 2 | Intent Classifier | 프레임워크 식별 (React/Next.js/Vue/...) + Tier 활성화 결정 |
| 3 | Task Router | 18 TM 분배 (또는 단일 모드 6 영역 순차) |
| 4 | Context Builder | audit-data/* — 프로젝트 구조 + tokens + 의존성 |
| 5 | Planner | 각 TM 체크리스트 분담 + grep 패턴 매트릭스 |
| 6 | Tool Executor | Read / Glob / Grep / Bash (정적) — Chrome MCP 사용 X (라이브 검수는 playwright-*로 위임) |
| 7 | Draft Generator | 18 TM 보고서 작성 |
| 8 | Critic / Verifier | Lead 통합 + 18차원 점수 + 등급 |
| 9 | Refiner | Blockers / Warnings / Suggestions 분류 + 사용자 명시 강등만 Low |
| 10 | Output Renderer | FRONTEND-REVIEW-{date}.md + Score 표 + Tier별 보고서 + 라우팅 권고 |

---

## 9. 우회 금지

- "코드 보고 OK" 라이브 검증 대체 → `playwright-uiux-audit` 호출 권장
- "이 정도면 충분" / "사소함" 자기 합리화 → Uncompromising Rigor §2 차단 발동
- 사용자 명시 강등 없이 임의 Low 등급 → §3 위반
- "Tier 일부만 검사" 임의 결정 → 사장 명시 옵션 (`--focus`)만 인정
- 외부 라이브러리 코드까지 검사 → 본 프로젝트 소스만

---

## 10. 참조 자산 (자동 인용)

본 스킬 실행 시 다음 가이드라인 자산을 자동 인용:

- **`vercel-react-best-practices`** — React/Next.js 성능 50+ 규칙
- **`web-design-guidelines`** — Web Interface Guidelines compliance
- **`${CLAUDE_PLUGIN_ROOT}/skills/_core/qa/checklist-175.md`** — QA 체크리스트 베이스
- **`${CLAUDE_PLUGIN_ROOT}/skills/_core/qa/behavioral-signals.md`** — 역할 채택 신호 (Signal 1-3)
- **`${CLAUDE_PLUGIN_ROOT}/skills/_core/roles.md`** — 전문가 역할 정의
- **`${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md`** — 환각 방지 프로토콜

---

## 11. 라우팅 정책 (다음 스킬 자동 권고)

본 스킬 검수 후 결과에 따라 다음 스킬 호출 권고:

| 발견 | 권고 스킬 | 사유 |
|---|---|---|
| 라이브 검증 필요 | `playwright-uiux-audit` 또는 `playwright-design-audit` | 실제 브라우저에서 동작 확인 |
| Frontend Security Blockers | `security-reviewer` (agent) 또는 `security-audit` (스킬) | 보안 전수 검수 |
| Performance 점수 < 80 | `playwright-qa-expert --full` | Web Vitals 라이브 측정 |
| 다수 Tier Blockers | `harness-loop --mode=debug-failure` | 수렴 루프 활성 |
| 신규 프로젝트 시작 | `aidlc-baseline` Inception | 처음부터 다시 설계 |

---

## 12. 옵션 플래그

- `--focus=<tier>` — 특정 Tier만 (uiux / design / a11y / performance / framework / security)
- `--mode=basic|full|all` — 검사 항목 수 결정
- `--teams` — Agent-Teams 강제 활성
- `--no-teams` — 단일 에이전트 강제
- `--loop` — Stage 7 수렴 루프 (결함 0건까지)
- `--include=<glob>` — 특정 파일만
- `--exclude=<glob>` — 특정 파일 제외 (예: `--exclude=*.test.tsx`)
- `--evidence=strict|balanced` — 근거 모드 (strict는 모든 발견 파일:라인 인용 의무)
- `--score-only` — 점수만 출력 (요약 모드)

---

## 13. Agent-Teams Fallback (단일 모드)

CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 미설정 시 자동 fallback:

```
basic 모드: 6 Tier 대표 항목만 (~30 항목) — 단일 에이전트 1회 호출
--full 모드: 6 Tier 순차 (~150 항목) — 단일 에이전트 6회 순차
--all 모드: 18 영역 순차 (~450 항목) — 단일 에이전트 18회 순차 (시간 ↑)
```

품질 ↓ 보다 시간 ↑. 사용자에게 Agent-Teams 활성화 권장 메시지 출력.

---

## 14. 환각 방지

- 발견된 파일 경로 + 라인 번호 반드시 명시 (`src/components/X.tsx:42`)
- "추정" / "확정" 구분 (예: `[추정]` / `[검증됨]`)
- 외부 라이브러리 동작 추측 X — 실제 코드 또는 공식 문서 인용
- React / Next.js 버전별 차이 확인 (사용자 package.json 인용)
- `_core/protocols.md` 의 anti-hallucination 프로토콜 준수

---

## 15. 참조

- **인사이트 1**: `.thoughts/2026-05-25-harness-insights-round1.md` (10단계 파이프라인)
- **라운드 2-3 합의**: `.thoughts/2026-05-25-harness-insights-round2-round3.md`
- **회고**: `.thoughts/2026-05-25-harness-application-completed.md`
- **P3-5 메타 루프**: `insight-sentinel` 스킬 (skill-candidate 유형)
- **P3-6 본 스킬 신설 결정**: 사용자 발화 "code-review 처럼 UI/UX 디자인 전부 진행" (2026-05-26)
- **분담 스킬**:
  - `code-review` (외부 플러그인 — 백엔드/일반 코드)
  - `security-reviewer` (`${CLAUDE_PLUGIN_ROOT}/agents/security-reviewer.md` — 보안만)
  - `ce-reviewer` (`${CLAUDE_PLUGIN_ROOT}/agents/ce-reviewer.md` — CE)
  - `playwright-uiux-audit` (라이브 UI/UX)
  - `playwright-design-audit` (라이브 디자인 통합)
  - `vercel-react-best-practices` (가이드라인 참조)
  - `web-design-guidelines` (가이드라인 참조)

---

> **외부 `code-review` 플러그인 정합 옵션(Effort Level 별칭 / `--comment` PR Inline 게시 / 분담 매트릭스 / 환경 요구사항)은 `references/code-review-compat.md` 참조.** §2 실행 모드(basic/--full/--all)와 §12 옵션 플래그가 본문에 남아 기본 호출은 그대로 작동.
