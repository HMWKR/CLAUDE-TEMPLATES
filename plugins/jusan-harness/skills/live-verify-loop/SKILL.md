---
name: live-verify-loop
description: 라이브 검증 무한 루프. "코드 100% ≠ 라이브 100%" 함정 차단. 검수 모드 9종(UI·UX/DB/코드/API/접근성/성능/SEO/보안/통합) + 7-STEP 도메인 맞춤 정착(또는 lite 3-STEP) + 5단계 N라운드 자율 엔진 + 모드 A(수동) / B(/loop ScheduleWakeup) 분기. 메타 학습 R45/R54/R55+ 영구 1급 시민화 + 모드별 특화 함정 슬롯 + 새 함정 R(N+1) 자동 등재. Pre-Flight MCP 검증 + Auto-Discovery + 페르소나 자동 부트스트랩(3단계 승인) + 라운드별 git 체크포인트 + session-handoff + 비용 가드레일(라운드 상한·토큰 임계·stagnation 감지). Use when "/live-verify", "라이브 검증 루프", "100% 도달까지 반복", "ultradetail audit", "콘솔 100% 도달까지", "Playwright MCP로 모든 버튼 click 시연", "라운드 반복하면서 fix". Skip for one-shot tests, single page checks, single bug fixes, code generation tasks.
allowed-tools: ['*']
---

## ⚠️ Uncompromising Rigor (글로벌 룰 강제 적용)

이 스킬은 `~/.claude/rules/uncompromising-rigor.md` 의 4개 정책을 **무조건 준수**한다:

1. **Browser Tool Priority** — `mcp__claude-in-chrome__*` 우선, `mcp__playwright__*` 는 fallback only
2. **Self-Justification Red Flags** — "이 정도면 충분" / "사소함" / "사용자가 신경 안 씀" / "베타니까 OK" / "fetch 진행 중이라 정상" 등장 시 **즉시 자기 차단**
3. **All Findings Are Defects** — 모든 발견은 결함. 사용자가 명시적으로 "강등"한 것만 Low
4. **Per-Round Deep Analysis** — 매 라운드 5단계 심층 분석 강제 (이전 재조회 → 미세 재스캔 → Adversarial walk → 자기 정당화 자가 검증 → 신규+재현성)

훅 강제: `detect-self-justification.sh` (5개 키워드 차단) + `check-chrome-mcp-priority.sh` (Playwright 우선 호출 가드).

---

# Live-Verify Loop — 라이브 검증 무한 루프

## Core Principle

**"코드 100% ≠ 라이브 100%"**

Playwright MCP 실제 도구 + N중 페르소나 매핑 + 4중 라이브 검증 게이트 통과까지 자율 반복. 매 호출은 도메인 맞춤 인터랙티브 정착으로 시작하며, R45~R55 라운드를 거치며 누적된 메타 학습이 본문 상·하단 양쪽에 영구 1급 시민으로 인용된다.

> **출발선 평행이동**: 새 프로젝트의 출발점 = 누적 메타 학습의 종착점. 50라운드 걸려 누적된 길을 새 프로젝트는 1라운드부터 단축 출발.

---

## Meta-Learning — 영구 1급 시민 (상단 인용)

> Token Position **첫 위치** 효과. 매 호출 시 자동 환기.

### 메타 학습 카테고리 분류학 (S-1)

| 카테고리 | 정의 | 등재 사례 | 차단 메커니즘 |
|---|---|---|---|
| **C-A** 외부 도구 함정 | 타인이 만든 도구·환경에 속음 | R45 / R54 / R55 | 본문 명시 + 환기 |
| **C-B** 도메인 코드 함정 | 도메인 코드 패턴의 함정 | R75 | 케이스북 + fix 패턴 |
| **C-C** **자기 위반 함정** | 내가 만든 룰을 내가 어김 | **R76** + 향후 R77/R78... 자동 등재 | **훅 강제 + 본문 다중 환기 + 자기 정당화 키워드 감지** |

> C-C는 가장 위험한 카테고리 — 명시·인용으로는 차단 불가. Iron Law처럼 훅 수준 강제 필요. 상세: `_meta-learning/_C-C-self-violation-category.md`

### 봉인된 일반 메타 학습

| 코드 | 카테고리 | 함정 | 위험 | 상세 |
|---|:---:|---|---|---|
| **R45** | C-A | "curl 200 OK = 라이브 작동" 가정 | 실제 브라우저 Hydration mismatch 폭발 / 인터랙션 실패 | `_meta-learning/R45-curl-only-pass.md` |
| **R54** | C-A | "코드 100% = 라이브 100%" 가정 | Server HTML과 CSR 분기 다름 / Hook Rules 위반 | `_meta-learning/R54-code-100-not-live-100.md` |
| **R55** | C-A | "`npx playwright test` = Playwright MCP" 가정 | testing framework는 실제 브라우저 인터랙션 시연 아님 | `_meta-learning/R55-playwright-test-not-mcp.md` |
| **R75** | C-B | TypeScript cursor self-reference cycle (TS7022) | BE export endpoint cursor pagination 추가 시 implicit any cycle 회귀 | `_meta-learning/R75-typescript-cursor-self-reference-cycle-ts7022.md` |
| **R76** | **C-C** | 자기 정의 Layer 우회 (스킬 본문 명시 위반) | 첫 호출엔 충실, 후속 라운드에 효율·milestone 욕구로 curl 갈음 → R45와 같은 함정 자기 재현 | `_meta-learning/R76-self-defined-layer-bypass.md` |
| **R77** | **C-A 진화** | "Playwright MCP 표면 검증 = 기능 작동" 가정 | navigate 200 + console clean + ErrorBoundary 0 → PASS인데 실제 click·form 인터랙션·상태 격리 미작동 | `_meta-learning/R77-playwright-surface-vs-functional.md` |

### 모드 특화 메타 학습 슬롯 (D-11)

검수 모드 선택 시 일반 R45/R54/R55 + 모드 특화 함정이 동시 인용된다. **모든 모드는 R76 (Layer 매트릭스 우회 차단) 공통 함정을 추가로 인용**한다.

| 모드 | 모드 특화 함정 | R76 (공통) |
|---|---|:---:|
| UI/UX | (등재 시 추가) | ✓ |
| DB | "마이그레이션 PASS ≠ FK 무결성·데이터 일관성" | ✓ |
| 코드 품질 | R75 cursor self-reference cycle (TS7022) — where 별도 const 분리로 회피 | ✓ |
| API | "/api/api/... 이중 prefix는 fallback 환경변수 충돌의 신호" | ✓ |
| 접근성 | "WCAG 자동 검증 PASS ≠ 인지 부담 0" | ✓ |
| 성능 | "Lighthouse 100 ≠ 실제 사용자 INP" | ✓ |
| SEO | "meta tag PASS ≠ 검색 노출" | ✓ |
| 보안 | "OWASP scan PASS ≠ business logic 안전" | ✓ |
| 통합 | (모드별 함정 합집합) | ✓ |

> R76 공통 인용 = "매 라운드 SKILL.md Layer 1~4 매트릭스 본문 재참조 의무. Layer skip 시 3-step 게이트(사유 명시 / 사용자 승인 / 라운드 요약 기록)"

### 새 함정 R(N+1) 등재 메커니즘 (D-1)

매 라운드 Step ⑤(commit) 직후 자동 평가:

- **등재 기준**:
  - (a) 다른 도메인 재현 가능
  - (b) 기존 R45~R55와 다른 새 패턴
  - (c) "모르면 다시 빠진다"는 일반성
- **충족 시**: 사용자에게 추천 → 명시 승인 후 `~/.claude/scripts/append-meta-learning.sh R(N+1) "제목" "본문"` 호출 → `_meta-learning/R(N+1)-<slug>.md` + 본문 인용 자동 추가
- **거부 시**: 라운드별 로컬 메모(`<project>/.thoughts/live-verify-rounds/`)에만 기록 → 다음 호출에서 재평가 가능

---

## Trigger Rules

### 작동
- `/live-verify <대상 영역>`, `/live-verify`
- "라이브 검증 루프", "100% 도달까지 반복", "ultradetail audit"
- "콘솔 100% 도달까지", "Playwright MCP로 모든 버튼 click 시연"
- "라운드 반복하면서 fix", "끝까지 자동으로 검증"

### 비작동
- 단순 "테스트해줘" — e2e spec 1회 실행으로 충분
- 단순 "한 페이지만 확인" — 단일 검증
- "버그 하나만 고쳐" — 일회성 fix
- UI 디자인 시안 / 코드 신규 생성 (검증 아님)

---

## Skill Boundary Matrix (D-3)

> 인접 스킬과의 역할 경계. **Confusion 4대 실패 모드 차단**.

| 스킬 | live-verify-loop와의 관계 |
|---|---|
| `harness-loop` | 상위 오케스트레이션 — live-verify-loop를 한 단계로 호출 가능 |
| `continuous-qa-loop` | 경량 폐쇄 루프 — live-verify-loop는 강화판 (메타 학습 영구 인용 + 7-STEP 정착 차이) |
| `playwright-qa-expert` | 단일 라운드 깊이 분석 — live-verify-loop는 N라운드 반복 |
| `playwright-qa-agent-teams` | 병렬 분석 1회 — live-verify-loop는 직렬 반복 |
| `agent-teams-reactive-dev` | Observer-Worker 폐쇄 루프 — live-verify-loop와 **상호 배타** (둘 중 하나만) |
| `playwright-design-audit` | 단일 디자인 감사 — live-verify-loop는 그 위 N라운드 fix 반복 가능 |
| `ultradetail-walk` | **자매 보완재**. ultradetail-walk = 단발 발견 (정상+Adversarial 두 페르소나, DOM 전수, 결함 카테고리 객관 도출 10+개) / live-verify-loop = N라운드 무한 fix 사이클. ultradetail-walk 발견 결과를 live-verify-loop 입력으로 체이닝 가능 (발견 → 수렴) |
| `ultradetail-loop` | **자매 곱 — 끈기 × 깊이**. live-verify-loop과 ultradetail-walk를 합친 하이브리드 무한 사이클 — **매 라운드** ultradetail-walk 전체 → fix → 재 walk. 비용 매우 큼 (라운드 1 ≈ ultradetail-walk 1회 = ~50K-200K). live-verify-loop은 가벼운 라운드 fix용, ultradetail-loop는 출시 전 종합 게이트·결함 100% 제거용. **상호 배타** — 동시 호출 금지 |

---

## Cantos Integration (조건부 활성화)

> cantos MCP가 환경에 connected 시 **자동 활성화**. 미연결 시 **silent skip + 1줄 로그** — 기존 워크플로우 100% 보존 (graceful degradation).
> 출처: `~/.claude/rules/agent-mapping.md` Step 4 "시각 검증 (UI/UX 작업 한정)" 워크플로우 정합성 회복.

### 활성화 검증
Pre-Flight 단계에서 `check-mcp-environment.sh`가 cantos 가용 여부 출력:
- `✓ cantos: connected (의사결정·시각 자산화 가용)` → 본 섹션 적용
- `⚠ cantos: missing — graceful skip` → 본 섹션 SKIP

### Project Registration (사용자 명시 승인 의무)
- 첫 호출 시 `mcp__cantos__list_projects` 자동 호출 → 본 프로젝트 등록 여부 확인
- **미등록 시**: 사용자에게 명시 질문 — "이 프로젝트를 cantos에 등록할까요?"
- 승인 시에만 `mcp__cantos__register_project` 호출. 자동 등록 금지.

### Visual Verification 미러링 (UI 모드 한정)

**트리거 조건**: 검수 모드 = UI/UX(1) / 접근성(5) / 통합(9) → 자동 활성화.
**SKIP 조건**: DB(2) / 코드 품질(3) / API(4) / 성능(6) / SEO(7) / 보안(8) → 시각 캡처 SKIP (관련성 낮음).

**2단계 워크플로우** (의무):
```
1. mcp__cantos__capture_visual({ htmlPath, viewports, themes })
   → cantos가 _screenshots/ 디렉토리 준비 + placeholder 생성

2. mcp__playwright__browser_navigate
   + mcp__playwright__browser_resize ({ width, height })
   + mcp__playwright__browser_take_screenshot ({
       filename: <cantos _screenshots/ 절대 경로>,
       fullPage: true
     })
   → 실제 캡처가 cantos 디렉토리에 저장
```

**4 viewport 매트릭스** (라운드별 의무):

| Viewport | 크기 | 용도 |
|---|---|---|
| 모바일 | **375×812** | iPhone 표준 |
| 태블릿 | **768×1024** | iPad 표준 |
| 데스크톱 | **1280×800** | 표준 노트북 |
| 대형 데스크톱 | **1920×1080** | FullHD 모니터 |

라우트당 4장 × 라우트 수 = 라운드별 캡처 매트릭스.

### ADR / DDR 자동 생성 (Step ⑤ commit 직후)

**분류 룰**:

| 결정 유형 | 도구 | 첨부 |
|---|---|---|
| 페르소나 부트스트랩 / 도구 매트릭스 변경 / mode A↔B 전환 / 메타 학습 R(N+1) 등재 | `mcp__cantos__create_adr` | — |
| UI 변경 / 결함 fix 패턴 / 디자인 토큰 / Visual Diff | `mcp__cantos__create_ddr` | `body.visual_diff` ← D-4 라운드 요약 + 4 viewport 캡처 |
| 단순 typo / cosmetic | 기록 안 함 (노이즈 차단) |

**호출 시점**: Step ⑤ commit 후 → `checkpoint-round.sh` 실행 → cantos 동기화 가이드 출력 → Claude가 분류 룰에 따라 `create_adr` / `create_ddr` 호출.

### Cantos Reusability Dryrun (구축 직후 검증)

스킬 cantos 통합 직후 다음 도메인 1개에서 호출하여 검증:
- Pre-Flight 출력에 `cantos: connected` 라인 표시
- UI 모드 호출 시 4 viewport 캡처 자동 실행 (라운드 1)
- ADR 1건 + DDR 1건 자동 생성 (분류 룰 준수)
- cantos 미연결 환경 시뮬 — `claude mcp` 일시 미등록 후 재호출 → silent skip 확인

PASS 시 cantos 통합 정착 완료.

---

## Pre-Flight Environment Check (D-10)

> 스킬 호출 직후 **첫 단계**. MCP 부재 시 graceful degradation.

```bash
bash ~/.claude/scripts/check-mcp-environment.sh
```

검증 대상:
- `playwright` MCP — 필수 (Layer 2 전부)
- `supabase` MCP — DB 모드 시 필수 (Layer 3)
- 기타 모드별 도구

부재 시 옵션 (사용자 선택):
1. **설치 가이드** 표시 → 사용자 설치 후 재시도
2. **Graceful degradation** — 예: Playwright MCP 부재 시 curl-only 모드 + R45 함정 명시 경고 후 진행
3. **취소** — 환경 정비 후 재호출

---

## Auto-Discovery Pre-Flight (D-6)

> Pre-Flight 직후. 프로젝트 컨텍스트 분석으로 검수 모드 추천.

```bash
bash ~/.claude/scripts/discover-inspection-mode.sh
```

분석 대상:
- `package.json` (Next.js / React / Vue / ...)
- `next.config.js` / `vite.config.ts`
- `supabase/` 디렉토리
- `playwright.config.ts`
- `.lighthouserc.json` / `axe-core` 등

추천 매핑 예시:
- Next.js + Playwright → "UI/UX (1순위) / 성능 (2순위)"
- Supabase + 마이그레이션 누적 → "DB (3순위)"
- OWASP/Snyk 설정 발견 → "보안" 추가
- a11y 라이브러리 발견 → "접근성" 추가

추천 수용 또는 9종 중 직접 선택 (3-phase 재추천 적용, 최대 2회).

---

## Mode Selection: lite vs full (D-13)

> Pre-Flight + Auto-Discovery 직후. **호출마다 사용자 선택**.

| 모드 | 정착 STEP | 적합 |
|---|---|---|
| **`lite`** | 3-STEP — ① 모드+종결조건 / ② 페르소나 / ③ 도구. 케이스북·인사이트·모드 A/B 기본값 자동 | 단일 PR 검토 / 빠른 재호출 / 가벼운 검증 |
| **`full`** (기본값) | 7-STEP 풀 정착 | 출시 전 종합 / 첫 호출 / 깊이 검수 |

선택 후:
- `lite` → 3-STEP 압축 정착 → 5단계 자율 엔진
- `full` → Information Pipeline (Memory Recall 포함) → 7-STEP 정착 → 5단계 자율 엔진

---

## Information Pipeline

### Priority 1: 사용자 종결 조건 (필수)
사용자가 정의한 4중 PASS 기준 (라우트 list / 인터랙션 list / 검수 모드 / 점수 기준).

### Priority 2: 마스터 설계서 / 프로젝트 체크리스트
`<project>/docs/` 내 설계 문서 / 마스터 체크리스트 / ADR.

### Priority 3: 자동 발견
- `Glob src/app/**/page.tsx` 라우트 자동 발견
- `Glob .claude/agents/*.md` 페르소나 자동 매핑
- `claude mcp list` 도구 자동 검증

### Priority 4: 사용자 직접 질문
위 1~3으로 부족 시 AskUserQuestion (3-phase 재추천 최대 2회).

### Priority 5: Session Memory Recall (D-5)

```bash
bash ~/.claude/scripts/recall-live-verify-history.sh
```

`~/.claude/projects/<slug>/memory/live-verify-history.md` 자동 회상.

이전 호출 존재 시 STEP ① 첫 질문에 추가 옵션:
- ① 이어받기 (이전 라운드 N에서 재개)
- ② 새로 시작 (이전 결과 무시)
- ③ 부분 재개 (특정 라우트만)

---

## The Process — 인터랙티브 7-STEP 정착

`full` 모드 시 매 호출마다 진행. 각 STEP은 AskUserQuestion + 3-phase 재추천(최대 2회).

### STEP ① 검수 모드 + 종결 조건 (Layer 1~4)

**검수 모드 9종 매트릭스**:

| # | 모드 | 페르소나 추천 | 도구 | 케이스북 |
|---|---|---|---|---|
| 1 | UI/UX | ux-ui-designer + ux-lead + qa-e2e-tester | Playwright MCP visual+interaction+console | Hydration / 디자인 토큰 / 반응형 |
| 2 | DB | backend-architect + dba + data-engineer | Supabase MCP (list_tables / execute_sql / migrations) | Migration mismatch / Schema drift / Index missing |
| 3 | 코드 품질 | fe-lead + qa-lead + security-reviewer | typecheck + lint + security scan | undefined data / as any / dead code |
| 4 | API/백엔드 | backend-architect + qa-e2e-tester | curl + Playwright MCP network | BE_URL 이중 prefix / status code drift / pagination |
| 5 | 접근성 | ux-ui-designer + qa-a11y-expert | Playwright MCP + axe-core | WCAG 위반 / contrast / keyboard nav |
| 6 | 성능 | perf-engineer + fe-lead | Lighthouse + Playwright trace | LCP/INP/CLS / bundle bloat / N+1 query |
| 7 | SEO | content-strategist + seo-auditor | Playwright MCP + meta scan | meta tag / sitemap / structured data |
| 8 | 보안 | security-reviewer + backend-architect | OWASP scan + dependency audit | XSS / CSRF / SQL injection / secret leak |
| 9 | 통합 | 위 모든 페르소나 N명 | 위 모든 도구 | 기본 6종 + 도메인 추가 |

**종결 조건 Layer 1~4** (사용자가 모드별로 채움):

```yaml
종결_조건:
  Layer_1_health:
    - BE GET /health → 200
    - FE GET / → 200
  Layer_2_playwright_mcp:
    - 모든 대상 라우트 navigate + status 200
    - hasErrorBoundary === false (모든 페이지)
    - console errors === 0 (WebSocket noise는 화이트리스트)
    - pageerror === 0
    - failedRequest 5xx === 0
    - 인터랙션 시연 PASS (사용자 정의 핵심 버튼)
  Layer_3_db_schema:
    - 마이그레이션 모든 적용 검증
    - 대상 테이블/컬럼 존재 확인
  Layer_4_code_quality:
    - npx tsc --noEmit 0 errors
    - npx next lint 신규 회귀 0
    - as any 캐스트 신규 0건

루프_종결_트리거:
  - 4 Layer 모두 PASS → 마스터 점수 갱신 + commit + stop
  - 1+ Layer 미달 → 라운드 N+1
  - 사용자 명시 stop → 즉시 종결
  - D-2 가드레일 (라운드 상한 / 토큰 임계 / stagnation) → 자동 정지
```

### STEP ② 페르소나 매핑 — 자동 부트스트랩 (D-7)

**1) 매핑 시도**:

```
Glob .claude/agents/<recommended-name>.md
```

**2-A) 존재 시** — Read하여 페르소나로 변신:

```
Read .claude/agents/<name>.md
```

PostToolUse(Read) 훅이 자동으로 매핑 timestamp 기록 → Iron Law #1 통과.

**2-B) 부재 시** — Persona Bootstrap Safety Protocol (D-7):

1. **표준 템플릿 로드**: `~/.claude/skills/live-verify-loop/_personas/<name>.md`
2. **사용자 미리보기**: 파일 내용 표시 (50줄 이내)
3. **3단계 승인**:
   - ① 파일명 확정
   - ② 내용 미리보기 검토
   - ③ 최종 승인
4. **생성**: `<project>/.claude/agents/<name>.md` 작성
5. **자동 lint**: `bash ~/.claude/scripts/lint-persona-template.sh <name>` — 글로벌 표준 스키마 검증

승인 거부 시 해당 페르소나 스킵, 다른 페르소나로 진행.

### STEP ③ 도구 매트릭스

Pre-Flight에서 검증된 도구 + 모드별 추가 도구. 사용자 확인 후 확정.

```
- Playwright MCP: browser_navigate / browser_evaluate / browser_console_messages / browser_take_screenshot / browser_click / browser_fill_form / browser_network_requests
- Supabase MCP: list_tables / execute_sql / list_migrations / apply_migration (사용자 명시 승인 시)
- 모드별 추가 도구 (Lighthouse / axe-core / OWASP scan / ...)
```

### STEP ④ 라우트 + Critical User Journey 매트릭스 (R77 강화)

**Part A — 라우트 매트릭스**: `Glob src/app/**/page.tsx` 자동 발견 → 우선순위 추천 → 사용자 검토.

**Part B — Critical User Journey 매트릭스 (R77 신설)**:

> 단순 라우트 navigate가 아닌 **사용자 사용 시나리오 체인**을 사전 declare. R77 차단 핵심.

라운드 시작 시 사용자가 critical journey 명시:

```yaml
journeys:
  - name: 신규 사용자 회원가입 → 첫 결제
    steps:
      - browser_navigate /signup
      - browser_fill_form (email, password, name)
      - browser_click "회원가입"
      - browser_navigate /login
      - browser_fill_form (email, password)
      - browser_click "로그인"
      - browser_navigate /products
      - browser_click 첫 상품
      - browser_click "장바구니 담기"
      - browser_navigate /cart
      - browser_click "결제하기"
      - browser_evaluate { 결제 모달 visible === true }

  - name: admin이 seller 권한 차단 (cross-cutting)
    steps:
      - browser_navigate /admin/login (admin 권한)
      - browser_navigate /seller/dashboard
      - browser_evaluate { status: 200 또는 403 정책 명시 }

  - name: seller A가 seller B 데이터 격리 (cross-cutting)
    steps:
      - browser_navigate /seller/login (seller_A)
      - browser_navigate /seller/orders/<seller_B_order_id>
      - browser_evaluate { status: 403/404 ✓ (격리 확인) }
```

**핵심 인터랙션 시연 대상 버튼**: 위 journey 안에 명시된 모든 `browser_click` / `browser_fill_form` 대상.

**검증 의무**: Layer 2-B (인터랙션) + 2-C (상태) 매트릭스를 journey 위에서 전수 PASS. 누락 시 `enforce-layer-matrix.sh` 차단.

### STEP ⑤ 결함 케이스북

**기본 6종 표시**:

```
1. Hydration mismatch (mounted 가드 / Shell wrap)
2. BE_URL 이중 prefix (/api/api/...) (mode C SSoT import)
3. enum mismatch (FE 'active' ↔ BE 'APPROVED') (매핑 객체)
4. undefined data (queryFn return undefined) (?? [] fallback / Array.isArray)
5. cross-cutting (header 무차별 노출) (path 분기 + early null)
6. production DB 마이그레이션 (psql 미설치) (Supabase MCP apply_migration)
```

상세: `_casebook.md`. 도메인 추가 결함은 사용자 입력 → 케이스북 누적.

### STEP ⑥ 인사이트 경로

부서별 인사이트 채널 자동 매핑:

```
docs/domain-knowledge/<persona>-insights.md
```

부재 시 파일 자동 생성 + 사용자 승인. 라운드별 발견 매트릭스 누적 채널.

### STEP ⑦ 모드 A vs 모드 B 선택

| 모드 | 동작 | 적합 |
|---|---|---|
| **A** (메인 turn 의존) | 매 라운드 끝에 사용자 "계속" 명령 대기 | 사용자 즉시 검토 / destructive 작업 |
| **B** (`/loop` ScheduleWakeup 자동) | delaySeconds 60~300 dynamic 페이싱 | 야간 / 사용자 부재 / 반복 fix |

Mode B 선택 시 자동으로 D-2 가드레일이 활성화된다 (라운드 상한 50 / 토큰 임계 200K / stagnation 3라운드).

---

## The Process — 5단계 N라운드 자율 실행 엔진

7-STEP 정착(또는 lite 3-STEP) 완료 후 진입. 종결 조건 PASS까지 라운드 반복.

### Pre-Step Body Recall (S-4) — 각 Step 진입 시 강제 환기

> **R76 차단의 1차 방어선**. 호출 시점·라운드 진입에 더해 **각 Step ① ~ ⑤ 진입 시에도 SKILL.md 해당 섹션 본문 재참조 의무**. 메타 학습이 박제된 문구가 아닌 라운드 중에도 작동하는 살아있는 가드가 되도록.

매 Step 진입 시:
1. 해당 Step 섹션 본문 1줄 자동 인용 (예: Step ② → "Layer 1~4 라이브 검증 게이트 — Layer 2는 Playwright MCP 의무")
2. 효율 핑계로 단계 압축 시도 시 **Pre-Step Body Recall 통과 못 함** → R76 자기 위반 카테고리 C-C
3. 헬퍼: `bash ~/.claude/scripts/step-entry-recall.sh <step-number>` (선택, Mode B 자동 모드에서 사용)

### Step ① 매핑 — Iron Law #1 충족

3가지 경로 중 하나로 30분 내 매핑 timestamp 갱신:

- **(A) 매핑 자동**: `.claude/agents/<name>.md` Read → PostToolUse(Read) 훅이 자동 기록
- **(B) 매핑 명시**: `bash ~/.claude/scripts/record-agent-mapping.sh <name> "ctx"`
- **(C) Spawn**: 독립 컨텍스트 필요 시 `Agent` 도구 호출

### Step ② Layer 1~4 라이브 검증 게이트

#### Pre-Round Layer Matrix Recall (S-3) — 매 라운드 강제 환기

> **R76 차단의 2차 방어선**. Step ② 진입 직전 Layer 1~4 매트릭스 본문을 자동 출력 + "이번 라운드 검증 도구 사전 declare" 의무.

매 라운드 Step ② 시작 시:
1. 아래 Layer 1~4 매트릭스 본문 자동 인용 (필수)
2. **"이번 라운드 N에서 사용할 검증 도구를 사전에 declare"** — 어떤 라우트에서 어떤 Layer를 어떤 도구로 검증할지 명시
3. Layer skip 시 → 아래 Layer Skip Protocol (S-5) 게이트 통과 의무

#### Layer 1~4 매트릭스 (Layer 2 분화 — R77 차단)

| Layer | 검증 도구 | PASS 기준 |
|---|---|---|
| 1 health | curl | BE/FE GET 200 |
| **2-A** Playwright MCP **렌더** | `browser_navigate` + `browser_console_messages` + `browser_evaluate(hasErrorBoundary)` | status 200 + console errors 0 + ErrorBoundary 0 + pageerror 0 + failedRequest 5xx 0 |
| **2-B** Playwright MCP **인터랙션** (R77 신설) | `browser_click` + `browser_fill_form` + `browser_press_key` + `browser_select_option` | 핵심 버튼 click 후 모달 visible / 폼 제출 후 응답 받기 / 단축키 작동 — **사전 declare한 인터랙션 시연 100% PASS** |
| **2-C** Playwright MCP **상태·격리** (R77 신설) | `browser_evaluate` (DOM/state assertion) + cookie 권한 시연 | 인터랙션 후 데이터 업데이트 ✓ + admin↔seller 권한 격리 ✓ + 데이터 격리 (행위자 X가 행위자 Y 데이터 접근 차단) ✓ |
| 3 DB schema | Supabase MCP `list_tables` / `execute_sql` / `list_migrations` | 마이그레이션 적용 + 테이블·컬럼 존재 |
| 4 코드 품질 | `tsc --noEmit` + `next lint` | 0 errors + 신규 회귀 0 + as any 신규 0 |

> **R77 차단 핵심**: Layer 2-A 통과만으론 게이트 미통과. Layer 2-B + Layer 2-C 모두 통과해야 라운드 commit 가능. `enforce-layer-matrix.sh`가 Layer 2-B 누락 시 `exit 2` 차단.

#### Cross-cutting Matrix — admin ↔ seller 권한·데이터 격리 (R77 신설)

> **R77 차단의 핵심 부속**. multi-role 다중 권한 도메인의 cross-cutting 결함은 단일 라우트 navigate로는 못 잡는다. **권한 매트릭스 + 데이터 격리 매트릭스**로 전수 검증.

```yaml
권한 매트릭스 (라우트 × 권한):
  /admin/dashboard:
    admin: 200 ✓
    seller: 403 / redirect ✓
    guest: 401 ✓
  /seller/dashboard:
    admin: 200 (또는 403) — 정책 명시
    seller: 200 ✓ (자신 데이터만)
    guest: 401 ✓

데이터 격리 매트릭스 (행위자 × 데이터 소유자):
  seller_A → seller_A 데이터: 200 ✓
  seller_A → seller_B 데이터: 403 / 404 ✓ (격리 확인)
  admin → seller_A 데이터: 200 ✓ (정책 따라)
  admin → admin 자신 데이터: (별도 정책)
```

라운드 시작 시 사용자가 매트릭스 명시 declare → 라운드 종결 시 모든 cell PASS 검증.

#### Layer Skip Protocol (S-5) — 3-step 게이트

> Layer를 SKIP하려면 아래 3-step 게이트 모두 통과 의무. 통과 못 하면 R76 카테고리 C-C 자기 위반 → enforce-layer-matrix.sh 훅이 commit 시점에 `exit 2` 차단.

```
(a) skip 사유 명시 — "이전 라운드 검증 완료" 같은 자기 정당화 금지. 신규 변경 0건이 증명되어야 함.
(b) 사용자 명시 승인 — AskUserQuestion으로 명시적 "OK" 받기. 추정·암시 금지.
(c) 라운드 요약 기록 — .thoughts/live-verify-rounds/r<N>-summary.md 에 "Layer X SKIP 사유 + 승인 timestamp" 기록.
```

3-step 게이트 통과 안 한 채 라운드 commit → `enforce-layer-matrix.sh` PreToolUse(Bash, `git tag live-verify-r*`) 훅이 `exit 2` 차단.

#### 준수 검증 일반화 매트릭스 (S-6)

> Layer 1~4 매트릭스만이 아니라 **모든 의무 항목**에 동일한 게이트 적용. R77/R78... 향후 자기 위반 함정 자동 등재 채널.

| 의무 항목 | 게이트 형태 | R(N) 슬롯 |
|---|---|---|
| Layer 1~4 매트릭스 | Pre-Round Recall + Layer Skip Protocol | **R76** (이번 등재) |
| 정착 7변수 (검수모드/페르소나/도구/라우트/케이스북/인사이트/모드 A·B) | STEP ①~⑦ 모두 명시 declare 의무 | R77 슬롯 (대기) |
| 인사이트 기록 (R47 권고) | Step ④ ultradetail audit 후 평가 | R78 슬롯 (대기) |
| 페르소나 매핑 timestamp 30분 | Step ① Iron Law #1 | (Iron Law 통합) |
| 모드 A/B 선택 명시 | STEP ⑦ 의무 | R79 슬롯 (대기) |

향후 위 슬롯 중 어느 하나에서 자기 위반 패턴이 발견되면 D-1 메커니즘으로 R77+ 자동 등재.

#### Cookie 주입 패턴 — 기존

**Cookie 주입 패턴** (host-only port-agnostic 인증):

```js
// browser_evaluate 내부에서 fetch credentials:'include'
async () => {
  const res = await fetch('http://localhost:4000/api/auth/social', {
    method: 'POST', credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ provider: 'kakao', accessToken: 'e2e-seller-001' }),
  });
  // host-only cookie는 port 무관 → :3001에서도 인식
  return { ok: res.ok };
}
```

### Step ③ 결함 즉시 fix — 케이스북 매트릭스 참조

`_casebook.md` 6종 기본 패턴 + 도메인 추가 결함. 진단·fix 패턴 적용.

### Step ④ ultradetail audit

매핑된 N명의 페르소나가 각자 관점에서 검증 결과 평가. 발견 매트릭스는 인사이트 1건으로 누적 (정말 좋은 발견만 — Iron Law #2 R47 정책).

### Step ⑤ commit + 종결조건 검증 + 체크포인트 + 메타 학습 평가

```bash
# 1) commit (4섹션 의무)
git add <변경 파일>
git commit -m "## What ... ## Why ... ## Impact ...
Co-Authored-By: Claude ..."

# 2) Round Checkpointing (D-4)
bash ~/.claude/scripts/checkpoint-round.sh <N>
# → git tag live-verify-r<N>
# → <project>/.thoughts/live-verify-rounds/r<N>-summary.md 생성

# 3) Session Handoff (D-9)
bash ~/.claude/scripts/update-session-handoff.sh
# → <project>/session-handoff.md 갱신

# 4) Meta-Learning Append 평가 (D-1)
bash ~/.claude/scripts/append-meta-learning.sh --evaluate
# → 새 함정 등재 후보면 사용자에게 추천
```

종결 조건 4중 검증 → PASS → Phase C' Self-Reflection → Self-Test → 종결.
미달 → 라운드 N+1 (Mode A: 사용자 "계속" / Mode B: ScheduleWakeup).

---

## Termination Conditions

```yaml
PASS:
  Layer_1: 헬스 200
  Layer_2: Playwright MCP 모든 검증
  Layer_3: DB schema 정합
  Layer_4: 코드 품질 회귀 없음

NEXT_ROUND:
  1+ Layer 미달

FORCE_STOP:
  - 사용자 명시 stop
  - D-2 stagnation 감지 (동일 결함 3라운드 연속 fix 실패)
  - D-2 라운드 상한 도달 (기본 50)
  - D-2 토큰 임계 200K + 사용자 "계속" 미응답
```

---

## Failure Modes — 영구 1급 시민 (하단 인용)

> Token Position **마지막 위치** 효과. 매 호출 종결 시 자동 환기.

### 일반 메타 학습 (R45 / R54 / R55) — 재인용

| 코드 | 함정 | 진단 트리거 |
|---|---|---|
| **R45** | curl-only PASS | "curl 200 OK인데 브라우저는 hydration error" |
| **R54** | code-100 = live-100 | "tsc 0 + lint 0인데 라이브에서 ErrorBoundary" |
| **R55** | npx playwright test ≠ MCP | "spec 통과인데 인터랙션 click 작동 안 함" |
| **R75** | cursor self-reference cycle (TS7022) | "단일 endpoint typecheck 0인데 누적 후 implicit any cycle" |
| **R76** | 자기 정의 Layer 우회 (스킬 본문 명시 위반) | "이전 라운드 검증했으니 이번엔 curl로 갈음 — 효율·milestone 욕구로 자기 정당화" |

### Mode-Specific Pitfalls (D-11)

검수 모드 선택 시 일반 + 모드 특화 동시 인용. 누적되는 살아있는 자산.

```
[모드별 슬롯 — _meta-learning/<mode>/*.md 자동 누적]
[모든 모드 공통: R76 카테고리 C-C — Layer 매트릭스 우회 차단]

UI/UX:        (등재 시 자동 인용) + R76
DB:           "마이그레이션 PASS ≠ FK 무결성·데이터 일관성" + R76
코드 품질:    R75 cursor self-reference cycle (TS7022) + R76
API:          "/api/api/... 이중 prefix는 fallback 환경변수 충돌의 신호" + R76
접근성:       "WCAG 자동 검증 PASS ≠ 인지 부담 0" + R76
성능:         "Lighthouse 100 ≠ 실제 사용자 INP" + R76
SEO:          "meta tag PASS ≠ 검색 노출" + R76
보안:         "OWASP scan PASS ≠ business logic 안전" + R76
통합:         (모드별 합집합) + R76
```

### 새 함정 R(N+1) 등재 — D-1 메커니즘

매 라운드 Step ⑤에서 자동 평가 (등재 기준 a/b/c 충족 시). 사용자 승인 후 본문 자동 추가.

---

## Red Flags

**Never:**
- 종결 조건 미정의 시 무한 루프 진입 (사용자 입력 의무)
- Iron Law #1 매핑 timestamp 30분 만료 무시
- false positive 자동 차단 검증 누락 (예: WebSocket noise 화이트리스트 없이 무조건 fail)
- 재추천 무한 루프 (최대 2회 제약 위반)
- D-2 가드레일 회피 (Mode B에서 라운드 50 / 토큰 임계 200K / stagnation 3라운드 무시 금지)
- 페르소나 자동 부트스트랩 사용자 승인 없이 .md 생성 (D-7 Poisoning 차단)

**Don't:**
- `npx playwright test`를 Playwright MCP 검증으로 갈음 (R55)
- curl 200 OK를 라이브 PASS로 갈음 (R45)
- typecheck 0 + lint 0을 라이브 PASS로 갈음 (R54)
- 한 라운드에 새 함정 등재 + 기존 함정 lock-in + lite/full 전환 동시 처리 (Confusion)
- 인사이트 무차별 누적 (Iron Law #2 R47: 정말 좋은 도메인 발견만)

**Don't — 자기 정당화 키워드 5종 (R76 카테고리 C-C 명시 금지)**:

스킬 본문 명시 위반(R76)의 대표 표면 형태. 매 라운드 출력 텍스트에 아래 키워드 등장 시 `detect-self-justification.sh` 훅이 stderr 경고 + 라운드 요약 자동 기록.

1. **"이미 비슷한 거 했으니 OK"** — 신규 변경에 대한 검증 의무는 자동 면제되지 않음
2. **"유사 검증 완료"** — 동일 라우트라도 신규 마이그/hook은 재검증 의무
3. **"골든 패턴 검증 완료"** — 골든 패턴 외 신규 변경은 그 패턴 적용 외부
4. **"이미 검증된 하부구조"** — 라운드 N의 검증은 라운드 N+1 신규 변경에 적용 안 됨
5. **"효율 우선"** — 효율 최적화 본능이 검증 의무를 압도하는 순간 = R76 카테고리 C-C 발동

→ 이런 추론이 떠오를 때 **즉시 정지** + Pre-Round Layer Matrix Recall (S-3) 재참조 + Layer Skip Protocol (S-5) 3-step 게이트 통과 의무.

---

## Loop Mechanism

### Mode A — 메인 turn 의존

매 라운드 종료 후 사용자 "계속" 명령 대기. 가장 안전.

- 사용자가 매 fix를 검토
- destructive 작업(DB migration / 대량 파일 변경) 권장
- 토큰은 라운드별 정확히 계산 가능

### Mode B — `/loop` ScheduleWakeup 재귀

`ScheduleWakeup` 도구로 dynamic 페이싱:

```javascript
ScheduleWakeup({
  delaySeconds: 60~300,
  prompt: "live-verify-loop 라운드 N+1 (본 스킬 자체 재귀)",
  reason: "라운드 N PASS 미달 — 자동 재시작"
})
```

### Cost Guardrails (D-2) — Mode B 자동 활성화

```yaml
guardrails:
  hard_limit:
    rounds: 50  # 사용자 정착 시 가감 가능
  soft_alerts:
    token_threshold: 200000  # 누적 토큰 임계 — 사용자 "계속" 명시 요청
  stagnation:
    same_defect_max_attempts: 3  # 동일 결함 3라운드 연속 fix 실패 → 자동 정지
    auto_request_diagnosis: true  # 인간 개입 요청
```

### delaySeconds 가이드

- **60~270초**: 캐시 warm 유지, 활발한 fix 사이클
- **1200~1800초**: 캐시 miss 1회 감수, idle tick 권장값
- **3600초 (max)**: 야간 정기 점검

---

## Loop Hardening — 루프 하네스 조사 반영 (2026-06-26)

> 루프 하네스 베스트프랙티스 전수조사(Ralph/ghuntley · frankbria/ralph-claude-code · Microsoft Agentic AI Failure Taxonomy · Termination-Poisoning arxiv:2605.05846) 반영. 기존 D-2 가드레일을 **보강**한다(대체 아님).

### H-1. Fresh-Context Round (Mode B 권장 — 컨텍스트 오염 차단)
> 근거: Ralph "각 이터레이션 = 새 컨텍스트 윈도우 = 한 작업 = 한 커밋, 상태는 디스크로만 공유"(github.com/ghuntley/how-to-ralph-wiggum). 동일 컨텍스트 라운드 누적 = Distraction/Poisoning 위험.

Mode B(자동 반복)에서 라운드 N+1을 **독립 서브에이전트(새 컨텍스트)** 로 실행하는 옵션:
- 라운드 상태는 인-컨텍스트가 아니라 **디스크로만 인계**: `r<N>-summary.md` + `session-handoff.md` + 미해결 이슈 목록.
- 다음 라운드 에이전트는 그 파일만 읽고 출발 → 이전 라운드 추론 누적 차단(출발선 평행이동 강화).
- 권장 트리거: 라운드 ≥ 5 또는 누적 토큰 ≥ 100K. Mode A(수동)는 기존대로 동일 컨텍스트 유지 가능.

### H-2. Deterministic Exit Gate — 이중조건 (정지 오염 방어)
> 근거: Termination-poisoning(arxiv:2605.05846) — 자기평가형 정지조건이 공격면(평균 3.57x·최대 25x 비용 폭주). ralph-claude-code = 휴리스틱 완료지표 AND 명시 `EXIT_SIGNAL` 이중조건.

"Layer 1~4 PASS / 이슈 0건"을 **자기 선언만으로 종료 금지**. 종료는 아래 **둘 다** 충족 시에만:
1. **결정론적 게이트**: 외부 검증 명령 **exit 0** (`enforce-layer-matrix.sh` + `tsc --noEmit` + 종결조건 검증). 에이전트 판단이 아닌 프로세스 exit code.
2. **명시 종료 신호**: 라운드 요약에 `EXIT_SIGNAL: true` + Layer 1~4 PASS 증거 첨부.
→ 하나라도 미충족 시 라운드 N+1. self-eval 단독 stop 시도 = R76 카테고리 C-C 자기위반(detect-self-justification 가드 연동).

### H-3. Sub-Agent Call Budget (자원 고갈 방어)
> 근거: Microsoft Taxonomy — 'Resource exhaustion'(서브에이전트 무한 호출, 10만 리뷰어 콜). 기존 D-2는 라운드·토큰만 캡, 호출 수 미캡.

- 라운드당 서브에이전트(Agent 도구) 호출 상한: 기본 **8** (초과 시 사용자 승인 요청).
- 전체 루프 누적 호출 상한: 기본 **60** (초과 시 자동 정지 + 진단 요청).

### H-4. Multi-Signal Stagnation + Cooldown (D-2 강화)
> 근거: ralph-claude-code circuit breaker — 무진척 3회 / 동일에러 5회 / 출력 >70% 감소 → cooldown 자동복구.

기존 D-2 "동일결함 3라운드"에 신호 추가:
- 동일 에러 시그니처 **5라운드 연속** → 정지
- 라운드 산출(변경 파일 수·diff 라인) 직전 대비 **>70% 감소 2연속** → 정지
- 정지 시 즉시 종료가 아니라 **cooldown 라운드 1회**(다른 가설·접근으로 재시도) 후에도 정체면 인간 개입 요청.

---

## Reusability Test

스킬 작성 직후 다른 도메인에서 호출하여 검증:

1. 7-STEP 정착이 모든 변수 채움 가능한지 (또는 lite 3-STEP)
2. 페르소나 자동 부트스트랩 작동 여부
3. 메타 학습 상·하단 인용 본문 가시 여부
4. 모드 A/B 분기 정상 작동 여부
5. `grep 'R45\|R54\|R55' SKILL.md` ≥ 3 통과
6. STEP 매트릭스 7개 / Step 자율 5개 / 검수 모드 9종 본문 검증

→ 모두 PASS 시 스킬 정착 완료.

---

## Self-Reflection (Phase C') — D-12

스킬 호출 종결 직후 자동 평가:

> "이번 호출에서 발견한 새 메타 학습이 있는가?"

후보가 있으면:
1. 후보 요약 + 일반화 검증 (다른 도메인 재현 가능?)
2. 사용자에게 추천: "R(N+1)으로 본문 등재할까요?"
3. 승인 시 `append-meta-learning.sh` 호출 → `_meta-learning/R(N+1)-<slug>.md` + 본문 자동 추가

자기 참조 학습 — 본 호출 자체가 누적 자산이 됨.

---

## Self-Test Protocol (D-8)

스킬 작성 직후 + 매 호출 종결 시 자동 실행:

```bash
bash ~/.claude/scripts/validate-skill.sh live-verify-loop
```

검증 항목:
- `grep -c 'R45\|R54\|R55'` ≥ 3 (메타 학습 인용)
- STEP ①~⑦ 헤더 7개
- Step ①~⑤ 헤더 5개
- Mode A / Mode B 양쪽 헤더
- 검수 모드 9종 매트릭스 (10행 이상의 표)
- D-1~D-13 통합 위치 명시

누락 시 어떤 항목 빠졌는지 명시 → 사용자가 보강.

---

## 결함 케이스북

상세 결함 패턴은 `_casebook.md` 분리 보관 (Progressive Disclosure 원칙).

기본 6종 + 도메인 추가 결함 — 매 라운드 Step ③에서 참조.

---

## 관련 파일·스크립트

### 스킬 디렉토리
```
~/.claude/skills/live-verify-loop/
├── SKILL.md                       # 본 파일
├── _casebook.md                   # 결함 케이스북 (기본 6종 + 도메인 추가)
├── _personas/                     # D-7 표준 페르소나 템플릿
│   ├── _common.md
│   └── <9 mode-specific>.md
└── _meta-learning/                # D-1 누적 메타 학습 영역
    ├── R45-curl-only-pass.md
    ├── R54-code-100-not-live-100.md
    ├── R55-playwright-test-not-mcp.md
    └── (R56+ 자동 추가)
```

### 헬퍼 스크립트
```
~/.claude/scripts/
├── record-agent-mapping.sh        # 기존 (Iron Law #1)
├── check-mcp-environment.sh       # D-10 Pre-Flight
├── discover-inspection-mode.sh    # D-6 Auto-Discovery
├── recall-live-verify-history.sh  # D-5 Memory Recall
├── lint-persona-template.sh       # D-7 Persona Lint
├── checkpoint-round.sh            # D-4 Round Checkpointing
├── update-session-handoff.sh      # D-9 Session Handoff
├── append-meta-learning.sh        # D-1, D-12 Meta-Learning
└── validate-skill.sh              # D-8 Self-Test
```

### 글로벌 참조
```
~/.claude/CLAUDE.md                       # Iron Law #1/#2
~/.claude/rules/agent-mapping.md          # 5단계 매핑 워크플로우
~/.claude/rules/insight-distribution.md   # 인사이트 분배 프로토콜
```

### 프로젝트 참조
```
<project>/.claude/agents/                 # 페르소나 정의
<project>/.claude/rules/agent-matrix.md   # (있으면 우선)
<project>/docs/domain-knowledge/          # 인사이트 채널
<project>/.thoughts/live-verify-rounds/   # D-4 라운드 요약
<project>/session-handoff.md              # D-9 인계
~/.claude/projects/<slug>/memory/live-verify-history.md  # D-5 회상
```

---

## End of SKILL.md

> 본 스킬은 R45~R55 메타 학습을 영구 자산화한 결과물이며, 매 호출 시 도메인 맞춤 인터랙티브 정착으로 새 프로젝트의 출발점 = 메타 학습의 종착점을 보장한다.
