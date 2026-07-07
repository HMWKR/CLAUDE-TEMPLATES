---
name: ultradetail-walk
description: 구현 직후 단발 ultradetail 페르소나 walk-through 검수. 정상 + Adversarial 두 페르소나 모드. 프로젝트 자동 적응. DOM 전수 클릭(LLM 임의 판단 0건). 결함 카테고리 객관 도출 10+개. Use when "/ultradetail-walk", "전수 검수", "페르소나 walk", "ultradetail walk", "모든 버튼 클릭", "구현 직후 검수", "click everything". Skip for ongoing fix loops (use live-verify-loop instead).
allowed-tools: ['*']
---

## ⚠️ Uncompromising Rigor (글로벌 룰 강제 적용)

이 스킬은 `~/.claude/rules/uncompromising-rigor.md` 의 4개 정책을 **무조건 준수**한다:

1. **Browser Tool Priority** — 브라우저 우선순위는 rules/uncompromising-rigor §1(2026-07-07 Playwright MCP 전역 우선)을 따른다. 본 스킬의 DOM 전수 walk는 Playwright MCP가 기본·필수(사용자 로그인 세션 재사용이 필요할 때만 Chrome MCP)
2. **Self-Justification Red Flags** — "이 정도면 충분" / "사소함" / "사용자가 신경 안 씀" / "베타니까 OK" / "fetch 진행 중이라 정상" 등장 시 **즉시 자기 차단**
3. **All Findings Are Defects** — 모든 발견은 결함. 사용자가 명시적으로 "강등"한 것만 Low
4. **Per-Round Deep Analysis** — 매 라운드 5단계 심층 분석 강제 (이전 재조회 → 미세 재스캔 → Adversarial walk → 자기 정당화 자가 검증 → 신규+재현성)

---

# Ultradetail Walk — 구현 직후 페르소나 walk-through 단발 검수

## Core Principle

> **"구현이 됐다 ≠ 끝"**.
> 코드 동작·typecheck PASS·라우트 200 OK 이후에도 **실제 사용자 페르소나가 자기 여정대로 클릭**할 때 발견되는 결함이 있다. 정상 페르소나(happy path) + Adversarial 페르소나(일부러 오류 유발 chaos)가 **DOM의 모든 인터랙티브 element를 빠짐없이** 호출. **LLM 임의 판단 없음**. 결함 카테고리는 **6 시그널 채널에서 객관 도출**. live-verify-loop와 자매 — 발견 ↔ 수렴 보완재.

---

## Meta-Learning (R45 / R54 / R55 / R75 / R76 / R77) — 영구 1급 시민 [상단 인용]

본 스킬의 직접 동기는 **R77 (multi-role 호환성 — 표면 검증 함정)**. 함정 lineage 6건을 본문 시작 시점에 환기한다:

| 코드 | 함정 패턴 | 핵심 교훈 | 본 스킬 적용 |
|:-:|---|---|---|
| **R45** | "curl 200 OK = 라이브 작동" | HTTP 응답 ≠ 실제 페르소나 클릭 동작 | DOM 전수 walk로 응답 ≠ UI 작동 분리 |
| **R54** | "환경 변수 채워짐 = 환경 정상" | env 정의 ≠ 페르소나가 그 기능을 쓸 수 있음 | Pre-Flight + 페르소나 walk로 실 사용 검증 |
| **R55** | "npx playwright test PASS = 라이브 PASS" | 테스트 코드 통과 ≠ 페르소나 직접 클릭 통과 | MCP 직접 호출로 테스트 코드 우회 |
| **R75** | 도메인 코드 패턴 함정 | TypeScript cursor self-reference 같은 도메인 결함 | 6 시그널 채널 #6 메타 학습 channel로 적용 |
| **R76** | 자기 위반 함정 | 내가 만든 룰을 내가 어김 (Layer 우회) | 7-STEP 순서 강제 + DOM 전수 (LLM 판단 0건) |
| **R77** | 표면 검증 함정 | multi-role 호환성처럼 페르소나 분기 누락 | **본 스킬의 직접 동기**. 두 페르소나 모드 + 권한 chaos |

→ 6건 모두 "표면 PASS = 실제 페르소나 작동"이 아님을 가르친다. 본 스킬은 그 격차(gap)를 단발로 뚫어내는 도구다.

---

## Trigger Rules

### 작동 (Use)

- `/ultradetail-walk` 슬래시 커맨드
- 자연어: "전수 검수", "페르소나 walk", "ultradetail walk", "모든 버튼 클릭", "구현 직후 검수", "click everything", "끝까지 다 눌러봐"
- 컨텍스트: 기능 구현 직후 PR/커밋 완료 시점, 실제 사용자처럼 검수하고 싶을 때
- 다중 페르소나 분기(admin/seller/customer 등)가 있는 프로젝트에서 호환성 결함 의심 시

### 비작동 (Skip)

- N라운드 fix 사이클 진행 중 (→ `live-verify-loop` 사용)
- 단일 PR의 작은 변경 검토 (→ 일반 코드 리뷰 또는 `/codex:review`)
- 코드 라인 단위 결함 (→ `playwright-qa-expert` 또는 `code-reviewer`)
- 일회성 typecheck/lint (→ 그냥 `tsc --noEmit` 직접)

---

## Skill Boundary Matrix

이웃 스킬과의 명시적 경계 — Confusion(4대 실패 모드) 차단.

| 스킬 | 본 스킬과의 관계 |
|---|---|
| `live-verify-loop` | **자매 보완재**. live-verify-loop = N라운드 무한 fix 사이클 / 본 스킬 = 단발 발견. 본 스킬 결과를 live-verify-loop 입력으로 체이닝 가능 |
| `playwright-qa-expert` | 단일 라운드 깊이 분석 — 본 스킬은 페르소나 여정 전수 walk, 표면적 더 넓고 LLM 판단 X |
| `playwright-qa-agent-teams` | 병렬 분석 1회 — 본 스킬은 직렬 페르소나별 전수 walk |
| `continuous-qa-loop` | 경량 폐쇄 루프 — 본 스킬과 상호 배타 (둘 중 하나만) |
| `agent-teams-reactive-dev` | Observer-Worker 폐쇄 루프 — 본 스킬과 상호 배타 |
| `harness-loop` | 상위 오케스트레이션 — 본 스킬을 한 단계로 호출 가능 |
| `ultradetail-loop` | **곱 진화형**. ultradetail-loop = ultradetail-walk × N라운드 무한 사이클 (매 라운드 walk 전체 + fix + 재 walk). 본 스킬 단발 / ultradetail-loop 무한. 발견만 필요하면 본 스킬, 발견 + 수렴까지 자동 무한 반복 필요하면 ultradetail-loop. **상호 배타** — 동시 호출 금지 |

---

## Information Pipeline

정보 수집은 환경 독립 우선순위 파이프라인을 따른다.

| 우선순위 | 출처 | 용도 |
|:-:|---|---|
| **Priority 1** | 사용자 입력 + 현재 turn 컨텍스트 | "이 프로젝트에서 검수해줘" 의도 파악 |
| **Priority 2** | 프로젝트 메타 파일 (`package.json`, `next.config.js`, `app/`, `pages/`, `supabase/`, `playwright.config.ts`) | 6 시그널 채널 #1~#4 입력 |
| **Priority 3** | 외부 도구 (Playwright MCP, Supabase MCP, Cantos MCP — 있을 때만) | DOM enumeration / 시각 캡처 / ADR·DDR 동기화 |
| **Priority 4** | 사용자 질문 (AskUserQuestion) | STEP ③/④ 인터랙티브 결정 |
| **Priority 5** | 메모리 (`~/.claude/projects/<slug>/memory/`) | 이전 호출 결과 회상 (있을 때) |

---

## Pre-Flight Environment Check (STEP ① 시작 시 자동)

스킬 진입 직후 환경 검증. 부재 시 graceful degradation 또는 차단.

| MCP | 필수도 | 부재 시 |
|---|:-:|---|
| Playwright MCP | **CRITICAL** | 차단 — DOM 전수 walk 불가능. 사용자에게 설치 가이드 표시 |
| Supabase MCP | optional | 권한 chaos / RLS 검수 시에만 활용 |
| Cantos MCP | optional | 시각 캡처 + ADR/DDR 동기화 시에만 활용 |

```bash
claude mcp list 2>&1 | grep -E "playwright|supabase|cantos"
```

→ Playwright `connected` 아니면 STEP ② 진입 차단.

---

## The Process — 단발 7-STEP

각 STEP은 명시 헤더로 본문에 존재. STEP ③/④는 **인터랙티브** (사용자 명시 선택). 나머지는 자동.

---

### STEP ① Pre-Flight Check

위 Pre-Flight 검증 실행 + 프로젝트 슬러그 / git 상태 / 디렉토리 구조 빠른 확인.

산출:
- MCP 가용성 매트릭스 (Playwright / Supabase / Cantos)
- 프로젝트 타입 (Next.js / Vite / Astro / etc.)
- 최근 커밋 hash (검수 대상 식별용)

---

### STEP ② 프로젝트 디스커버리 (자동)

**6 시그널 채널** 자동 분석 → 결함 카테고리 후보 풀 생성. 자세한 매핑은 [`_signal-channels.md`](./_signal-channels.md) 참조.

| # | 채널 | 도출 방법 |
|:-:|---|---|
| 1 | **라우트** | Next.js `app/` 또는 React Router enumeration → `[role=admin]/*`, `/checkout/*` 등 |
| 2 | **입력 type** | `Grep <input type=...>` 또는 `getByRole('textbox')` enumeration |
| 3 | **라이브러리** | `package.json` 파싱 → 알려진 함정 매트릭스 적용 (NextAuth/Supabase/Stripe/SWR 등) |
| 4 | **컴포넌트 패턴** | DOM/소스 grep — modal·form·table·pagination·tooltip·toast |
| 5 | **표준** | WCAG 2.1 AA / OWASP Top 10 / Web Vitals (LCP·INP·CLS) |
| 6 | **메타 학습** | R45/R54/R55/R75/R76/R77 본 프로젝트 적용 가능성 평가 |

→ 각 채널에서 발견된 시그널 → 후보 카테고리 자동 강제. 6 채널 × 평균 2-3개 ≈ **10+개 후보** 도출.

---

### STEP ③ 결함 카테고리 결정 (★인터랙티브)

> **핵심 원칙**: LLM 임의 판단 X. 객관 시그널 도출 + 사용자 명시 선택.

#### Step ③-1: 카테고리 후보 표 생성

STEP ② 결과를 5컬럼 표로 재구성:

```
| 카테고리명 | 시그널 출처 | 검수 행동 | 영향도 | 근거 |
```

- **카테고리명**: 예: "권한 분기 우회", "결제 race condition", "modal focus trap 결함"
- **시그널 출처**: 어떤 채널·어떤 시그널에서 도출 (예: "라우트 `/admin/*` 4건 발견")
- **검수 행동**: 어떤 click/입력/시퀀스로 검수 (예: "로그아웃 상태 admin URL 직접 입력 → 리디렉션 검증")
- **영향도**: critical / high / medium / low
- **근거**: 왜 이 프로젝트에 이 카테고리가 필요한지 (예: "R77 multi-role 호환성 패턴 적용")

#### Step ③-2: 3+안 조합 생성

10+개 카테고리를 다음 안 조합으로 그룹핑:

| 안 | 가중 | 적합 상황 |
|---|---|---|
| **안 A: Balanced** | 6 채널 균등 | 종합 출시 전 검수 |
| **안 B: Security·Permission weighted** | 채널 #1·#3·#5(OWASP) 우선 | 권한 분기 많은 프로젝트, PII 취급 |
| **안 C: UX·Micro-interaction weighted** | 채널 #4·#5(WCAG) 우선 | UI 풍부한 프로젝트, a11y 중요 |
| **안 D (선택): Performance·Reliability weighted** | 채널 #5(Web Vitals)·#6 우선 | 성능 회귀 우려, 트래픽 큼 |

각 안에는 10+개 카테고리 표가 부속. 안별 차이는 카테고리 가중치(영향도)와 검수 깊이.

#### Step ③-3: AskUserQuestion 인터랙티브 선택

```
질문: "어떤 결함 카테고리 안으로 진행할까요?"
옵션:
- 안 A: Balanced (10+ 카테고리, 모든 채널 균등)
- 안 B: Security weighted (10+ 카테고리, 권한·OWASP 우선)
- 안 C: UX weighted (10+ 카테고리, micro·a11y 우선)
- 안 D: Performance weighted (10+ 카테고리, Vitals·신뢰 우선)
```

→ 사용자 선택 후 **자유 추가/제거** 단계: "추가하고 싶은 카테고리?" / "제거할 카테고리?". 기본값 선택 안 변경.

#### Step ③-4: 확정

선택된 안 + 조정 결과를 라운드 컨텍스트로 저장. 이후 STEP ⑤·⑥에서 검수 우선순위로 사용.

---

### STEP ④ 페르소나 부트스트랩 (★인터랙티브)

> **핵심 원칙**: 페르소나 도출도 객관 시그널 기반. 정상 + Adversarial 양 모드.

#### Step ④-1: 페르소나 후보 자동 도출

STEP ② 라우트·라이브러리 시그널에서 페르소나 후보 추출:

- 라우트 prefix `/admin` → admin 페르소나
- 라우트 prefix `/seller` 또는 `/dashboard` → seller 페르소나
- 라우트 prefix `/customer` 또는 `/account` → customer 페르소나
- 라우트 `/login`, `/signup` 외 protected route → guest (로그아웃) 페르소나
- 라이브러리 `next-auth` + role-based 미들웨어 → multi-role 페르소나 분기 자동

각 후보 페르소나에 정상 모드 + Adversarial 모드 한 쌍 생성. 페르소나 템플릿: [`_personas/`](./_personas/) 참조.

#### Step ④-2: 페르소나 표 생성

5컬럼 표:

```
| 페르소나명 | 모드(정상/Adversarial) | 시그널 출처 | 행동 패턴 요약 | 근거 |
```

- **행동 패턴 요약** 예시:
  - admin 정상: "로그인 → 대시보드 → 사용자 관리 → 통계 → 로그아웃"
  - admin Adversarial: "로그아웃 admin URL 직접 / 다른 admin 데이터 접근 / 권한 token 조작"

#### Step ④-3: 3+안 조합 생성

| 안 | 페르소나 셋 | 적합 상황 |
|---|---|---|
| **안 A: Realistic** | 실 사용자 분포 (admin 1 / seller 2 / customer 3) | 일반 출시 전 검수 |
| **안 B: Coverage** | 모든 권한 레벨 max coverage (super-admin / admin / sub-admin / seller / sub-seller / customer / guest) | 권한 시스템 복잡한 프로젝트 |
| **안 C: Adversarial-heavy** | adversarial 비중 70% (정상 3 + 악성 7) | 보안 검수 우선, PII / 결제 |
| **안 D (선택): User custom** | 사용자가 직접 페르소나 추가 | 도메인 특수 |

#### Step ④-4: AskUserQuestion 인터랙티브 선택

```
질문: "어떤 페르소나 안으로 진행할까요?"
옵션:
- 안 A: Realistic
- 안 B: Coverage
- 안 C: Adversarial-heavy
- 안 D: User custom (Other)
```

→ 사용자 선택 후 **자유 추가/제거** 단계.

#### Step ④-5: 확정

선택된 페르소나 셋 → 라운드 컨텍스트로 저장. STEP ⑤·⑥의 actor.

---

### STEP ⑤ 정상 페르소나 전수 walk

> **DOM 전수 클릭** — LLM 임의 판단 0건. 모든 인터랙티브 element 호출.

#### Step ⑤-1: 페르소나 시작 상태 셋업

각 정상 페르소나마다:
1. 로그인 (또는 guest의 경우 로그아웃 보장)
2. 시작 라우트 (예: admin → `/admin`, customer → `/`)
3. 페르소나 컨텍스트 클리어 (로컬스토리지 / 쿠키 검증)

#### Step ⑤-2: DOM Enumeration (양면)

각 라우트에서 두 방법 동시 적용:

```javascript
// 방법 A: Playwright accessibility tree
mcp__playwright__browser_snapshot()
// → role=button, role=link, role=textbox, role=combobox, role=checkbox,
//   role=radio, role=tab, role=menuitem, role=switch, role=slider,
//   role=spinbutton, role=searchbox, role=link 모두 enumerate

// 방법 B: querySelectorAll 보강
mcp__playwright__browser_evaluate({
  function: `() => Array.from(document.querySelectorAll(
    'button, a[href], input, select, textarea, [role=button], ' +
    '[role=link], [role=tab], [role=menuitem], [role=switch], ' +
    '[role=slider], [role=combobox], [role=checkbox], [role=radio], ' +
    '[onclick], [data-testid], [contenteditable]'
  )).map(el => ({
    tag: el.tagName,
    role: el.getAttribute('role') || el.tagName.toLowerCase(),
    label: el.getAttribute('aria-label') || el.textContent?.slice(0, 40),
    selector: el.dataset.testid ? '[data-testid="'+el.dataset.testid+'"]' : null,
    rect: el.getBoundingClientRect(),
    disabled: el.disabled
  }))`
})
```

→ 두 결과 합집합 = 그 페이지의 모든 인터랙티브 element 후보.

#### Step ⑤-3: 합리적 순서 호출

정상 페르소나는 **합리적 순서**로 element 호출:
- 입력 필드 → 정상 값 (text → 의미 있는 단어 / number → 정상 범위 / email → 유효 형식)
- 버튼 → 정상 흐름 순서 (예: 폼 채우기 → submit)
- 네비 → 페르소나 권한 내 라우트만
- modal → open → 정상 액션 → close

각 호출 후:
- 새 DOM enumeration (동적 element 대응)
- 콘솔 메시지 / 네트워크 에러 / a11y 위반 capture
- 결함 발견 시 STEP ③ 카테고리 매핑 + 라운드 컨텍스트에 누적

#### Step ⑤-4: destructive policy

destructive 액션 (삭제·결제·외부 API 등):
1. 버튼 click 까지는 진행
2. confirm dialog 떠지면 **거기서 멈춤** (`browser_handle_dialog({ accept: false })`)
3. 실제 destructive는 0건 보장
4. confirm dialog 텍스트·UX는 capture (사용자 확인 명료성 검수 가능)

#### Step ⑤-5: 페르소나별 전수 완료 후 다음 페르소나

모든 정상 페르소나 셋이 모든 페이지의 모든 element를 호출할 때까지 반복. **누락 0건** 강제.

---

### STEP ⑥ Adversarial 페르소나 전수 walk

> Adversarial 페르소나는 **8축 카오스** 행동을 STEP ③ 결함 카테고리 우선순위 따라 적용. 자세한 8축은 [`_chaos-axes.md`](./_chaos-axes.md) 참조.

#### Step ⑥-1: 8축 카오스 매트릭스 적용

| # | 축 | Adversarial 행동 |
|:-:|---|---|
| 1 | **입력** | 빈값 / max+1 길이 / 특수문자 / emoji / SQL `' OR 1=1 --` / XSS `<script>alert(1)</script>` / null byte |
| 2 | **순서** | 결제→비우기→재시도 / 이전 단계 건너뛰기 / 폼 절반만 채우고 다른 페이지로 / 시간 역순 |
| 3 | **동시성** | 같은 버튼 빠른 연타 (×5) / 두 탭 동시 작업 / 새로고침 인터럽트 / 네트워크 throttle 중 액션 |
| 4 | **권한** | 로그아웃 admin URL 직접 / seller가 admin 페이지 / 다른 사용자 ID 데이터 / token 조작 |
| 5 | **상태** | loading 중 클릭 / error 상태 액션 / disabled 강제 (devtools `removeAttribute`) / busy 중 다른 액션 |
| 6 | **경계값** | 0개 / 1개 / 1000개 / max±1 / -1 / Infinity / NaN |
| 7 | **환경** | 모바일·데스크톱·태블릿 / 느린 3G / 오프라인 / 다른 언어·로케일 |
| 8 | **history** | 뒤로가기·새로고침 인터럽트 / 탭 닫고 다시 열기 / `history.replaceState` 조작 |

#### Step ⑥-2: 결함 카테고리 우선순위 적용

STEP ③ 선택된 안의 결함 카테고리에 따라 8축 행동 가중치:
- 안 B (Security): 축 #1 SQL/XSS, 축 #4 권한, 축 #6 경계값 ×2
- 안 C (UX): 축 #5 상태, 축 #8 history, 축 #7 환경 ×2
- 안 D (Performance): 축 #3 동시성, 축 #7 느린 네트워크 ×2
- 안 A (Balanced): 모든 축 ×1

#### Step ⑥-3: DOM 전수 + 카오스 곱

각 페이지의 모든 element × 8축 카오스 = 매우 큰 매트릭스. 그러나 **LLM 임의 판단 X**:
- 입력 필드 → 8개 입력 패턴 모두 시도
- 버튼 → 빠른 연타 + history 조작 + 환경 변경 시도
- 폼 → 비논리적 순서 시도

destructive policy 동일 적용 (confirm까지만).

#### Step ⑥-4: 결함 발견 즉시 카테고리 매핑

각 결함 발견 시 STEP ③ 카테고리 표에 누적:
- 어떤 페르소나가
- 어떤 element를
- 어떤 카오스 축으로 시도했고
- 어떤 응답·에러·UI 상태였고
- STEP ③ 어떤 카테고리에 매핑되는지

라운드 컨텍스트에 **append-only**.

---

> STEP ⑦ 결함 리포트 생성 상세 (markdown 리포트 양식 / HTML 리포트 / Cantos 통합)은 references/report-template.md 참조. 산출물은 markdown + HTML 둘 다 생성 필수.

## Termination Conditions

스킬 종료 조건:

| 조건 | 처리 |
|---|---|
| 모든 페르소나 × 모든 페이지 × 모든 element walk 완료 | 정상 종료 → STEP ⑦ 리포트 |
| Pre-Flight 차단 (Playwright 미연결) | 즉시 종료 → 사용자에게 설치 가이드 |
| 사용자 명시 중단 ("그만", "stop") | 즉시 종료 → 부분 리포트 (지금까지 발견만) |
| destructive 가드레일 위반 (실제 destructive 발생 시도) | 즉시 종료 → 안전 리포트 |
| DOM enumeration 실패 5회 연속 | 진단 모드 → 사용자에게 보고 |

---

## Failure Modes (R45 / R54 / R55 / R75 / R76 / R77) — 영구 1급 시민 [하단 인용]

본 스킬이 막으려는 함정 패턴 — 본 스킬 자체도 이 함정에 빠질 수 있다는 자기 경고. 상단 표와 동일하나, 마지막 토큰 위치에 다시 환기.

| 코드 | 함정 | 본 스킬 자기 경고 |
|:-:|---|---|
| **R45** | "curl 200 OK = 라이브" | DOM 전수 walk가 곧 진실. HTTP status는 보조 시그널만 |
| **R54** | "환경 변수 = 환경 정상" | Pre-Flight + 페르소나 walk 둘 다 통과해야 환경 OK |
| **R55** | "playwright test PASS = 라이브 PASS" | 본 스킬은 MCP 직접 호출. 테스트 코드 우회 |
| **R75** | 도메인 코드 함정 | 6 시그널 채널 #6에서 도메인 함정 자동 도출 |
| **R76** | 자기 위반 | 7-STEP 순서 강제 + DOM 전수 (LLM 판단 0건) — 스킬 본문이 룰을 어기지 않게 |
| **R77** | 표면 검증 | **본 스킬의 직접 동기**. 두 페르소나 모드로 multi-role 같은 분기 호환성 검출 |

---

## Red Flags

### Never (절대 금지)

- LLM이 "이 element는 안 눌러도 될 것 같다"라고 판단하지 않는다 — **전수 호출 강제**
- "이 페르소나는 비현실적이니 빼자"라고 임의 제거하지 않는다 — STEP ④ 사용자 선택만 변경자
- destructive 액션이 confirm 후 실제 실행되지 않게 한다 — gate 위반 시 즉시 종료
- 결함 카테고리를 "이 프로젝트에는 안 맞을 것 같다"라고 임의 제거하지 않는다 — STEP ③ 사용자 선택만

### Don't (지양)

- 자기 정당화 키워드 — "이미 검증된 컴포넌트" / "골든 패턴이라 스킵" / "이건 일반적인 React라 패스" / "효율 우선" / "유사 검증 충분"
  - 이 5종 키워드는 R76 자기 위반 함정의 표면. 등장 시 자기 차단
- live-verify-loop 본문 직접 복사 — self-contained 정책. 참고만, 자기 식으로 다시 작성
- 산출물 markdown만 / HTML만 — 두 가지 다 생성 필수
- 6 시그널 채널 4개 미만 활성 — 채널 부족 = 디스커버리 부족 진단

---

## Reusability Test

본 스킬을 다른 도메인에서 호출 시 작동 검증:

| 검증 항목 | 통과 기준 |
|---|---|
| 첫 호출 작동 | yt-longfrom-ai 또는 calclab에서 1회 호출 → 7-STEP 모두 정상 진행 |
| 객관 도출 | STEP ② 자동 디스커버리 → STEP ③ 10+개 카테고리 자동, 모두 시그널 출처 명시 |
| 인터랙티브 결정 | STEP ③/④ 3+안 표 + AskUserQuestion + 자유 추가/제거 |
| 전수 walk | DOM enumeration → 모든 element 호출 (LLM 임의 판단 0건) |
| destructive 안전 | confirm dialog까지만, 실제 실행 0건 |
| 결함 리포트 | markdown + HTML 둘 다 |
| live-verify-loop boundary | 두 스킬 본문에 명시 |
| 메타 학습 인용 | R45-R77 자체 인용 ≥ 3 (`grep -c 'R45\|R54\|R55\|R75\|R76\|R77'`) |

---

## Cantos Integration (선택, MCP connected 시만)

Cantos MCP가 환경에 connected 시 자동 활성화. 미연결 시 silent skip.

| 시점 | 동작 |
|---|---|
| Pre-Flight | `claude mcp list` 결과에 `cantos: ✓ Connected` 확인 → 활성 표시 |
| STEP ⑤·⑥ 결함 발견 시 | critical/high 결함 → DDR 후보 표시 (사용자 명시 승인 후 `mcp__cantos__create_ddr`) |
| STEP ⑦ HTML 리포트 | 시각 캡처를 `<cantos>/projects/<slug>/_screenshots/`에 미러링 |
| 종료 시 | ADR (Architecture Decision Record) 후보 표시 — 본 walk에서 발견된 구조적 결정 사항 |

→ Cantos 통합은 강제 X. 미연결 또는 사용자 거부 시 markdown 리포트만 생성.

---

## 부속 파일

| 파일 | 역할 |
|---|---|
| [`_signal-channels.md`](./_signal-channels.md) | 6 시그널 채널 → 카테고리 매핑 상세 |
| [`_chaos-axes.md`](./_chaos-axes.md) | 8축 카오스 추상 프레임워크 + 행동 카탈로그 |
| [`_defect-categories-template.md`](./_defect-categories-template.md) | 5컬럼 표 양식 + 안 조합 가이드 |
| [`_personas/_common.md`](./_personas/_common.md) | 페르소나 공통 스키마 |
| [`_personas/_normal-base.md`](./_personas/_normal-base.md) | 정상 페르소나 베이스 템플릿 |
| [`_personas/_adversarial-base.md`](./_personas/_adversarial-base.md) | Adversarial 페르소나 베이스 템플릿 |
| [`_meta-learning/_index.md`](./_meta-learning/_index.md) | R45-R77 자체 인용 인덱스 |

---

## 관련 파일·스크립트 (read-only 참조)

| 파일 | 용도 |
|---|---|
| `${CLAUDE_PLUGIN_ROOT}/skills/live-verify-loop/SKILL.md` | 자매 스킬, 메타 학습 lineage 참고 |
| `~/.claude/rules/agent-mapping.md` | 5단계 매핑 워크플로우 |
| `~/.claude/CLAUDE.md` | Iron Law #1/#2 |
| `~/.claude/scripts/check-mcp-environment.sh` | MCP 검증 헬퍼 (참고만, self-contained 원칙) |

---

> **Iron Law 적용**: 본 스킬을 호출하면 `~/.claude/agents/<persona>.md` Read 또는 `record-agent-mapping.sh` 호출 필요 (Iron Law #1). 인사이트 발견 시 `docs/domain-knowledge/<persona>-insights.md` 누적 (Iron Law #2).
