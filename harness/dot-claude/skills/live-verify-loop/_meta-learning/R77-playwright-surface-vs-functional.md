# R77 — Playwright MCP 표면 검증 ≠ 기능 작동 (R45 진화형)

- **카테고리**: C-A (외부 도구 함정 — R45 진화)
- **등재**: 2026-05-06 (사용자 발견 — multi-role 호환성 오류)
- **상위 메타 학습**: R45 (curl 200 OK = 라이브 작동 가정의 위험)
- **자동 등재 메커니즘**: D-1 (R75/R76에 이은 세 번째 실증)

---

## 함정

R45는 "curl 200 OK = 라이브 작동" 가정의 위험을 다룬다. R45 fix로 Playwright MCP가 도입됐지만, **Playwright MCP의 표면 검증도 동일한 false positive 패턴을 만든다**:

| Layer | 검증 도구 | 검증 대상 | 한계 |
|---|---|---|---|
| R45 함정 | curl | HTTP 응답 | 클라이언트 측 작동 미검증 |
| **R77 함정 (신설)** | `browser_navigate` + `browser_console_messages` + `hasErrorBoundary` 체크 | **페이지가 렌더되는가** | **기능이 작동하는가는 미검증** |

→ **R45의 한 단계 진화형**. 페이지가 ErrorBoundary 없이 렌더되어도 다음을 못 잡는다:
- 버튼 click 후 BE 호출 실패 (404/500)
- 폼 제출 후 응답 처리 누락
- 모달 열림 후 닫기 버튼 미작동
- 데이터 로드 후 UI 업데이트 안 됨
- multi-role cross-cutting (admin이 seller 데이터 못 보거나 반대)

## 진단 트리거

라운드 검증 결과에 다음이 보이면 R77 의심:
- "navigate 200 + console errors 0 → PASS"만 출력하고 인터랙션 시연 0건
- "Layer 2 ✓"인데 사용자가 직접 클릭해보면 기능 안 됨
- admin 라우트만 검증하고 seller 라우트의 cross-cutting (권한 격리 / 데이터 격리) 검증 누락
- "이 페이지는 정상 렌더되니 OK" 같은 self-reinforcing 판단

## 실제 사례 (사용자 발견)

**상황**: live-verify-loop 라운드에서 admin·seller 페이지를 모두 PASS 판정. 종합 점수 100%.

**위반**: 사용자가 실제 테스트 시 admin 페이지·seller 페이지의 다음 결함 발견:
- admin·seller cross-cutting (권한 분리 / 데이터 격리)
- 안 되는 기능들 (인터랙션 후 BE 호출 실패)
- 서로 호환 안 되는 부분 (admin↔seller 데이터 흐름 단절)

**원인**:
1. Playwright MCP 표면 검증 (`navigate` + `console_messages` + `ErrorBoundary` 체크)만 사용
2. `browser_click` + `browser_fill_form` + `browser_evaluate` 인터랙션 시연 누락
3. admin↔seller cross-cutting matrix 부재
4. Critical user journey 명시 의무 부재

→ **R45 함정이 한 단계 깊은 형태로 재현**. 본 함정을 catch하려면 Layer 2 분화 + cross-cutting matrix + critical user journey 필요.

## Fix 패턴 (Layer 2 분화)

### Layer 2-A: 페이지 렌더 검증 (기존)
- `browser_navigate` → status 200
- `browser_console_messages({level:'error'})` → 0
- `browser_evaluate(() => !!document.querySelector('[data-error-boundary]'))` → false
- **충분 조건 아님**. R45 진화형 트랩 표면.

### Layer 2-B: 인터랙션 시연 검증 (신설 — R77 차단)
- `browser_click` 핵심 버튼 N개 시연 (라운드별 사용자 명시 declare 의무)
- `browser_fill_form` 폼 제출 + 응답 처리 검증
- `browser_press_key` 단축키 / Escape / Enter 시연
- **각 인터랙션 후 결과 검증**: 모달 visible / dropdown open / 응답 받기

### Layer 2-C: 상태·격리 검증 (신설 — R77 차단)
- `browser_evaluate`로 DOM/state assertion (`window.__store.getState()` 등)
- 인터랙션 후 데이터 업데이트 확인 (예: cart count +1)
- **권한 격리**: admin이 seller 데이터 접근 차단 / seller가 admin 라우트 접근 차단
- **데이터 격리**: seller A가 seller B의 데이터 못 보는지

### Cross-cutting Matrix (Step ② 안 신설)
- multi-role 권한 매트릭스 전수 (라우트 × 권한)
- 데이터 격리 매트릭스 (행위자 × 데이터 소유자)

### Critical User Journey (STEP ④ 강화)
라운드 시작 시 사용자 시나리오 명시 declare 의무:
```yaml
journey:
  - 회원가입 → 로그인 → 상품 등록 → 결제 → 환불
  - admin 로그인 → 사용자 차단 → seller 라우트 진입 시도 → 차단 확인
  - seller A 로그인 → seller B 데이터 조회 시도 → 차단 확인
```

## 일반성 검증

- ✅ **다른 도메인 재현 가능**: 모든 Playwright MCP 사용 프로젝트에서 발생. UI 프레임워크 무관 — 표면 검증의 본질적 한계
- ✅ **R45와 다른 새 패턴**: R45는 외부 도구(curl)의 한계, R77은 외부 도구(Playwright MCP) 사용 방법의 한계 — 같은 카테고리(C-A)의 한 단계 진화
- ✅ **"모르면 다시 빠진다"는 일반성**: navigate-only 검증은 efficient하므로 자동 루프가 자연스럽게 빠짐. 본문 명시 + 훅 강제로 차단 필요

## 관련 R 시리즈 (카테고리 C-A 진화 lineage)

| 코드 | 진화 단계 | 도구 |
|---|---|---|
| R45 | 1단계 | curl만 사용 |
| **R77** | **2단계** | Playwright MCP 표면 검증만 사용 |
| (향후) | 3단계 | Layer 2-A·B·C 모두 통과해도 못 잡는 깊이 — 실제 사용자 사용 패턴 |

R77은 R45 박제 상태에서 한 단계 더 진화시킨 사례 — 카테고리 C-A 자체가 살아있는 자산임을 증명.

## 차단 메커니즘 (Hard + Soft)

### Soft (본문)
- Layer 2 분화 (2-A / 2-B / 2-C) 명시
- Cross-cutting Matrix 신설
- Critical User Journey STEP ④ 의무
- Pre-Round Layer Matrix Recall (S-3) 강화 — Layer 2-B/C 사전 declare 의무
- Red Flags "Don't" 추가: "navigate 200 + console clean = 기능 작동" 추론 명시 금지

### Hard (훅)
- `record-playwright-call.sh` 확장 — `browser_click` / `browser_fill_form` / `browser_evaluate` tool name별 timestamp 별도 추적
- `enforce-layer-matrix.sh` 확장 — Layer 2-B (인터랙션) + 2-C (상태) 별도 검증, 누락 시 `exit 2`

## 본문 인용 위치

- SKILL.md "Meta-Learning 상단 인용" 표 (R45/R54/R55/R75/R76 옆에 R77, 카테고리 C-A)
- SKILL.md "Failure Modes 하단 인용" 표
- SKILL.md "메타 학습 카테고리 분류학" — C-A 진화 lineage
- SKILL.md Step ② Layer 2 분화 절
- SKILL.md "Red Flags Don't" — "navigate 200 + console clean = 기능 작동" 추론 금지
- SKILL.md 9 모드 슬롯 모두 (공통 R77)

## 관련 문서

- `R45-curl-only-pass.md` — 상위 함정 (1단계)
- `_C-C-self-violation-category.md` — R76 (자기 위반)과 다른 카테고리임을 명시
- `~/.claude/scripts/enforce-layer-matrix.sh` — Hard 게이트 (Layer 2-B/C 검증 추가)
- `~/.claude/scripts/record-playwright-call.sh` — tool name별 timestamp
