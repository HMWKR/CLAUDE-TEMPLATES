---
name: playwright-design-audit
description: |
  Unified UI/UX + Design Quality audit with 19 Agent-Teams specialists, ~450 checklist items.
  Use when asked to "design audit", "디자인 감사", "통합 감사", "design quality check",
  "UI/UX + design audit", or "playwright-design-audit".
  UX Score (0-100, 18 dimensions). Modes: basic/--pro/--expert/--focus=<cat>.
  Requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1.
user_invocable: true
args:
  - name: url
    description: "감사 대상 URL (필수)"
    required: true
  - name: mode
    description: "실행 모드: basic (기본), --pro, --expert, --focus=<cat>"
    required: false
    default: "basic"
---

## ⚠️ Uncompromising Rigor (글로벌 룰 강제 적용)

이 스킬은 `~/.claude/rules/uncompromising-rigor.md` 의 4개 정책을 **무조건 준수**한다:

1. **Browser Tool Priority** — 브라우저 우선순위는 `rules/uncompromising-rigor` §1(2026-07-07 Playwright MCP 전역 우선)을 따른다. 로그인 세션 재사용이 필요할 때만 `mcp__claude-in-chrome__*`를 쓴다.
2. **Self-Justification Red Flags** — "이 정도면 충분" / "사소함" / "사용자가 신경 안 씀" / "베타니까 OK" / "fetch 진행 중이라 정상" 등장 시 **즉시 자기 차단**
3. **All Findings Are Defects** — 모든 발견은 결함. 사용자가 명시적으로 "강등"한 것만 Low
4. **Per-Round Deep Analysis** — 매 라운드 5단계 심층 분석 강제 (이전 재조회 → 미세 재스캔 → Adversarial walk → 자기 정당화 자가 검증 → 신규+재현성)
> 이 스킬 이름의 "playwright"는 legacy 명칭 — 브라우저 우선순위는 `rules/uncompromising-rigor` §1(2026-07-07 Playwright MCP 전역 우선)을 따른다.

---

# 19-Agent Three-Wave Unified Design Audit System

> **버전**: 1.0.0 | **에이전트**: Lead + 19 TM (3-Wave)
> **체크리스트**: ~450항목 (24 카테고리, A–V)
> **UX Score**: 0-100 (18차원 가중치, 7등급)
> **CSS Evaluate 스니펫**: 22개 (기존 16 + Design Quality 6)
> **검증 마커**: 6종

## Shared References

- 역할 정의: `${CLAUDE_PLUGIN_ROOT}/skills/_core/roles.md`
- 프로토콜: `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md`
- 팀 패턴: `${CLAUDE_PLUGIN_ROOT}/skills/_core/team-patterns.md`

이 스킬은 기존 3개 QA 스킬(qa-expert, qa-agent-teams, uiux-audit)의 **기술적 정확성(Ground level)** 검증과 `/frontend-design` 스킬의 **디자인 전략(30,000ft)** 사이의 **중간 고도(5,000~15,000ft)** — 디자인 품질, 브랜드 정합성, 시각 기억성 — 을 통합 커버한다.

---

## 1. 실행 모드

| 모드 | TM 수 | 항목 수 | Wave | 예상 시간 | 비용 |
|------|:-----:|:------:|:----:|:---------:|:----:|
| **basic** (기본) | 7 | ~88 | Wave 1 | ~8분 | 낮음 |
| **--pro** | 13 | ~275 | Wave 1+2 | ~15분 | 중간 |
| **--expert** | 19 | ~450 | Wave 1+2+3 | ~25분 | 높음 |
| **--focus=\<cat\>** | 1~3 | 가변 | 지정 카테고리 | ~5분 | 최저 |

### --focus 카테고리 매핑 (24개)

| 카테고리 | ID | TM | Wave |
|----------|:--:|:--:|:----:|
| Typography Fundamentals | A | TM1 | 1 |
| Typography Advanced | B | TM2 | 1 |
| Spacing & Layout | C | TM3 | 1 |
| WCAG Core Accessibility | D | TM4 | 1 |
| WCAG Advanced Accessibility | E | TM5 | 1 |
| Cognitive Psychology & UX Laws | F | TM6 | 1 |
| Micro-interactions & Animation | G | TM8 | 2 |
| Interaction Patterns & Feedback | H | TM9 | 2 |
| IA & Navigation | I | TM10 | 2 |
| Mobile & Responsive | J | TM11 | 2 |
| Visual Hierarchy & Brand | K | TM12 | 2 |
| Form UX & Data Entry | L | TM13 | 2 |
| Design System Consistency | M | TM14 | 3 |
| Emotional Design & Delight | N | TM15 | 3 |
| Performance UX | O | TM16 | 3 |
| Microcopy & Content UX | P | TM17 | 3 |
| Color Harmony | Q | TM18 | 3 |
| Data Visualization | R | TM16 | 3 |
| **Typography & Color Quality** ★ | **S** | **TM7** | **1** |
| **Layout & Brand Coherence** ★ | **T** | **TM19** | **3** |
| **Memorability & Emotional Impact** ★ | **U** | **TM19** | **3** |
| i18n & Localization | V | TM18 | 3 |

> ★ = 신규 Design Quality 카테고리 (기존 스킬에 없던 "중간 고도" 항목)

---

## 2. 핵심 원칙

### Anti-Hallucination Protocol (6종 검증 마커)

| 마커 | 의미 | 사용 조건 |
|------|------|-----------|
| `[DATA-VERIFIED]` | CSS evaluate 데이터로 확인 | 스니펫 반환값 기반 |
| `[SNAPSHOT-VERIFIED]` | DOM 스냅샷으로 확인 | browser_snapshot 기반 |
| `[PATTERN-INFERRED]` | 패턴에서 추론 | 여러 데이터 포인트 종합 |
| `[CROSS-REFERENCED]` | 다른 TM 결과와 교차 검증 | Wave 간 참조 |
| `[FRAMEWORK-BASED]` | 이론/프레임워크 기반 판단 | Nielsen, WCAG 등 |
| `[NOT-TESTABLE]` | 자동 테스트 불가 | 주관적 판단 필요 항목 |

**절대 규칙**: 검증 마커 없는 이슈는 리포트에 포함하지 않는다.

### 카테고리 경계 규칙

중복 검사 방지를 위한 경계:
- **D (WCAG Core) vs E (WCAG Advanced)**: D는 AA 필수, E는 AAA + 보조 기술
- **F (Psychology) vs H (Interaction)**: F는 인지 법칙, H는 구현 패턴
- **J (Mobile) vs C (Layout)**: J는 터치/뷰포트 특화, C는 데스크톱 포함 전체
- **K (Visual) vs S (Design Quality)**: K는 시각 계층 구조, S는 폰트/색상 품질
- **N (Emotion) vs U (Memorability)**: N은 딜라이트 요소, U는 전체 기억성/톤

### 참조 프레임워크 (18개)

Nielsen's 10 Heuristics, WCAG 2.2 AA/AAA, Baymard Institute, Laws of UX, Gestalt Principles, Material Design 3, Apple HIG, Atomic Design, Don Norman's 3 Levels, Core Web Vitals/RAIL, Rosenfeld & Morville IA, W3C i18n, Color Theory (Itten/Albers), 12 Principles of Animation, Tufte Data-Ink, **Typewolf Best Practices**, **60-30-10 Color Rule**, **Brand Identity Design (Wheeler)**

---

## 3. Three-Wave 하이브리드 아키텍처

### 전체 흐름

```
Stage 0: 프로젝트 컨텍스트 분석 (Lead)
    ├── CLAUDE.md 파싱 → 브랜드 컬러/폰트/톤 추출
    ├── 도메인 자동 파악
    ├── 페르소나 3명 생성
    └── 전문가 선택 (모드별)

Stage 1: 데이터 수집 (Lead, Playwright MCP)
    ├── 5개 뷰포트 스냅샷+스크린샷
    ├── 22개 CSS Evaluate 스니펫 실행
    └── .qa-audit/run-{ts}/data/ 저장

Stage 2: 분석 (모드별 TM 스폰)
    ├── basic  → Wave 1 (TM1-7, 7명)
    ├── pro    → Wave 1 + Wave 2 (TM8-13, +6명)
    └── expert → Wave 1 + Wave 2 + Wave 3 (TM14-19, +6명)

Stage 3: 통합 (Lead)
    ├── 중복 제거 + Critical 교차 검증
    ├── UX Score 18차원 산출
    ├── 이전 리포트 diff 비교 (있는 경우)
    └── FINAL-REPORT 생성
```

### 핵심 제약

1. **Lead만 Playwright 도구 사용** — TM은 Lead가 수집한 데이터만 분석
2. **Wave 간 순차 실행** — Wave 1 완료 → Wave 2 시작 → Wave 3 시작
3. **Wave 내 병렬 실행** — 같은 Wave의 TM은 동시에 스폰
4. **데이터 공유는 파일 기반** — `.qa-audit/run-{ts}/data/` 디렉토리

### 19명 TM 구성

| Wave | TM | 카테고리 | 역할 | Tier |
|:----:|:--:|:--------:|------|:----:|
| 1 | TM1 | A | Typography Fundamentals | T1+T2+T3 |
| 1 | TM2 | B | Typography Advanced | T1+T2+T3 |
| 1 | TM3 | C | Spacing & Layout | T1+T2+T3 |
| 1 | TM4 | D | WCAG Core Accessibility | T1+T2+T3 |
| 1 | TM5 | E | WCAG Advanced Accessibility | T1+T2+T3 |
| 1 | TM6 | F | Cognitive Psychology & UX Laws | T1+T2+T3 |
| 1 | **TM7** | **S** | **Typography & Color Quality** ★ | T1+T2+T3 |
| 2 | TM8 | G | Micro-interactions & Animation | T1+T2+T3 |
| 2 | TM9 | H | Interaction Patterns & Feedback | T1+T2+T3 |
| 2 | TM10 | I | IA & Navigation | T1+T2+T3 |
| 2 | TM11 | J | Mobile & Responsive | T1+T2+T3 |
| 2 | TM12 | K | Visual Hierarchy & Brand | T1+T2+T3 |
| 2 | TM13 | L | Form UX & Data Entry | T1+T2+T3 |
| 3 | TM14 | M | Design System Consistency | T2+T3 |
| 3 | TM15 | N | Emotional Design & Delight | T2+T3 |
| 3 | TM16 | O+R | Performance UX & Data Viz | T2+T3 |
| 3 | TM17 | P | Microcopy & Content UX | T2+T3 |
| 3 | TM18 | Q+V | Color Harmony + i18n | T2+T3 |
| 3 | **TM19** | **T+U** | **Layout·Brand + Memorability** ★ | T2+T3 |

### Tier 활성화 (모드별)

| 모드 | T1 | T2 | T3 |
|------|:--:|:--:|:--:|
| basic | ✅ | ❌ | ❌ |
| --pro | ✅ | ✅ | ❌ |
| --expert | ✅ | ✅ | ✅ |
| --focus | 전체 | 전체 | 전체 |

### Fallback 모드

AGENT_TEAMS 미활성 또는 스폰 실패 시:
- Lead가 순차적으로 각 TM 역할을 수행
- 항목 수 자동 축소 (T1 항목만)

---

## 4. 데이터 디렉토리 구조

```
.qa-audit/
└── run-{YYYYMMDD-HHMMSS}/
    ├── data/
    │   ├── snapshots/
    │   │   ├── snapshot-1920.md
    │   │   ├── snapshot-1366.md
    │   │   ├── snapshot-768.md
    │   │   ├── snapshot-390.md
    │   │   └── snapshot-320.md
    │   ├── screenshots/
    │   │   ├── screenshot-1920.png
    │   │   ├── screenshot-768.png
    │   │   └── screenshot-390.png
    │   ├── css-evaluate/
    │   │   ├── typography.json      (T-1~T-5)
    │   │   ├── spacing.json         (S-1~S-2)
    │   │   ├── contrast.json        (C-1~C-2)
    │   │   ├── animation.json       (ANIM-1)
    │   │   ├── modal.json           (M-1)
    │   │   ├── component.json       (M-2)
    │   │   ├── design-system.json   (DS-1)
    │   │   ├── navigation.json      (NAV-1)
    │   │   ├── form.json            (FORM-1)
    │   │   ├── accessibility.json   (A-1)
    │   │   ├── font-quality.json    (DQ-1)  ★
    │   │   ├── color-dist.json      (DQ-2)  ★
    │   │   ├── layout-pattern.json  (DQ-3)  ★
    │   │   ├── brand-token.json     (DQ-4)  ★
    │   │   ├── motion-strategy.json (DQ-5)  ★
    │   │   └── signature.json       (DQ-6)  ★
    │   └── project-analysis.md
    ├── reports/
    │   ├── tm1-typography-fund.md
    │   ├── tm2-typography-adv.md
    │   ├── ...
    │   └── tm19-layout-memorability.md
    └── FINAL-REPORT.md
```

### 접근 권한

| 역할 | data/ | reports/ | FINAL-REPORT |
|------|:-----:|:--------:|:------------:|
| Lead | R/W | R/W | R/W |
| TM | R (자기 카테고리) | W (자기 리포트) | ❌ |

---

## 5. Stage 0 — 프로젝트 & UX 컨텍스트 분석

Lead가 감사 시작 전 수행하는 컨텍스트 수집 단계.

### 5.1 CLAUDE.md 파싱

프로젝트 루트의 CLAUDE.md에서 자동 추출:

```
1. 브랜드 컬러 (primary, secondary, accent)
2. 폰트 (heading, body)
3. 톤/분위기 (formal, casual, playful 등)
4. 도메인 (SaaS, e-commerce, education 등)
5. 기술 스택 (CSS 프레임워크, 디자인 시스템)
```

### 5.2 페르소나 생성 (3명)

도메인 기반 자동 생성:

```markdown
### 페르소나 1: {이름}
- 역할: {primary user}
- 기술 수준: {초급/중급/고급}
- 주요 목표: {핵심 태스크}
- 접근성 요구: {있을 경우}

### 페르소나 2: {이름}
- 역할: {secondary user}
...

### 페르소나 3: {이름}
- 역할: {edge case user}
...
```

### 5.3 전문가 선택

모드에 따라 활성화할 TM과 참조할 전문가 정의를 결정.
→ `references/expert-definitions.md` 참조

### 5.4 project-analysis.md 저장

수집된 컨텍스트를 `.qa-audit/run-{ts}/data/project-analysis.md`에 저장.
이 파일은 모든 TM에 Context Priming으로 전달된다.

---

## 6. Stage 1 — 데이터 수집 (Lead 단독, Playwright MCP)

### 6.1 실행 순서

```
1. browser_navigate → 대상 URL
2. 뷰포트별 순회 (1920 → 1366 → 768 → 390 → 320)
   ├── browser_resize(width, height)
   ├── browser_snapshot → snapshots/snapshot-{width}.md
   └── browser_take_screenshot → screenshots/screenshot-{width}.png (주요 3개만)
3. CSS Evaluate 스니펫 실행 (1920px 뷰포트)
   ├── A-1  → accessibility.json (공유 스냅샷 생성, 최우선)
   ├── T-1~T-5 → typography.json
   ├── S-1~S-2 → spacing.json
   ├── C-1~C-2 → contrast.json
   ├── ANIM-1 → animation.json
   ├── M-1    → modal.json
   ├── M-2    → component.json
   ├── DS-1   → design-system.json
   ├── NAV-1  → navigation.json
   ├── FORM-1 → form.json
   ├── DQ-1   → font-quality.json    ★
   ├── DQ-2   → color-dist.json      ★
   ├── DQ-3   → layout-pattern.json  ★
   ├── DQ-4   → brand-token.json     ★
   ├── DQ-5   → motion-strategy.json ★
   └── DQ-6   → signature.json       ★
```

> CSS Evaluate 스니펫 상세: `references/css-snippets.md` 참조

### 6.2 도구 실패 대응

| 도구 | 실패 유형 | 대응 |
|------|-----------|------|
| browser_navigate | 타임아웃 | 3회 재시도, 간격 5초 |
| browser_evaluate | 스크립트 에러 | 해당 스니펫 스킵, [NOT-TESTABLE] 마킹 |
| browser_snapshot | DOM 변경 | 1초 대기 후 재수집 |
| browser_resize | 뷰포트 실패 | 해당 뷰포트 스킵 |
| browser_take_screenshot | 캡처 실패 | 스크린샷 없이 진행, 스냅샷만 활용 |

---

## 7. TM Spawn 프롬프트 템플릿

각 TM은 다음 4-Block 구조로 스폰된다.

### 공통 템플릿

```
[Context Priming]
- 프로젝트 분석 결과 주입 (project-analysis.md)
- 브랜드 컬러/폰트/톤 주입
- 대상 URL + 뷰포트 정보

[Role Definition]
- 전문가 역할 (expert-definitions.md에서 해당 TM 참조)
- 참조 프레임워크
- 전문 용어

[Task Instructions]
- 체크리스트 항목 (checklist-unified.md에서 해당 카테고리)
- 데이터 파일 경로 (어떤 JSON/스냅샷 파일을 읽을지)
- Tier 필터링 (모드에 따라 T1만 / T1+T2 / 전체)
- 교차 참조 블록 (이전 Wave 결과 참조 가능)

[Completion]
- 리포트 출력 형식 (report-templates.md 참조)
- 이슈 ID 규칙: ISS-{C/M/N/S}-{3자리}
- 검증 마커 필수
- 리포트 저장 경로: reports/tm{n}-{category}.md
```

### Wave별 스폰 프롬프트

- **Wave 1** (TM1–TM7): `references/spawn-wave1.md`
- **Wave 2** (TM8–TM13): `references/spawn-wave2.md`
- **Wave 3** (TM14–TM19): `references/spawn-wave3.md`

### Progressive Disclosure 참조

모드에 따라 체크리스트 항목을 필터링:

```
basic  → checklist-unified.md에서 Tier=T1 항목만 추출
--pro  → checklist-unified.md에서 Tier=T1,T2 항목 추출
--expert → checklist-unified.md 전체
--focus → 지정 카테고리의 전체 Tier
```

---

## 8. 체크리스트 (Progressive Disclosure)

> SSOT: `references/checklist-unified.md`

### 항목 수 요약

| Tier | 항목 수 | 포함 모드 |
|:----:|:------:|:---------:|
| T1 (Essential) | ~88 | basic, pro, expert |
| T2 (Professional) | ~187 | pro, expert |
| T3 (Expert) | ~124 | expert |
| **합계** | **~400** | expert |

### 카테고리별 분포

| 카테고리 | T1 | T2 | T3 | 합계 | TM |
|:--------:|:--:|:--:|:--:|:----:|:--:|
| A | 5 | 10 | 5 | 20 | TM1 |
| B | 5 | 10 | 5 | 20 | TM2 |
| C | 5 | 10 | 5 | 20 | TM3 |
| D | 8 | 10 | 7 | 25 | TM4 |
| E | 3 | 7 | 5 | 15 | TM5 |
| F | 5 | 10 | 5 | 20 | TM6 |
| G | 5 | 7 | 6 | 18 | TM8 |
| H | 5 | 10 | 5 | 20 | TM9 |
| I | 5 | 7 | 6 | 18 | TM10 |
| J | 5 | 7 | 6 | 18 | TM11 |
| K | 5 | 7 | 6 | 18 | TM12 |
| L | 5 | 7 | 6 | 18 | TM13 |
| M | 0 | 8 | 7 | 15 | TM14 |
| N | 0 | 5 | 7 | 12 | TM15 |
| O | 0 | 5 | 5 | 10 | TM16 |
| P | 0 | 5 | 7 | 12 | TM17 |
| Q | 0 | 5 | 5 | 10 | TM18 |
| R | 0 | 3 | 5 | 8 | TM16 |
| **S** ★ | **5** | **10** | **10** | **25** | **TM7** |
| **T** ★ | **5** | **10** | **10** | **25** | **TM19** |
| **U** ★ | **5** | **7** | **8** | **20** | **TM19** |
| V | 0 | 3 | 5 | 8 | TM18 |

---

## 9. Stage 2 — Three-Wave 병렬 분석 실행

### Wave 실행 프로토콜

```
FOR each wave IN [wave1, wave2, wave3]:
  1. 해당 Wave의 TM 목록 결정 (모드 기반)
  2. 각 TM에 대해:
     a. expert-definitions.md에서 역할 로드
     b. checklist-unified.md에서 해당 카테고리 항목 추출 (Tier 필터링)
     c. css-evaluate 데이터 경로 매핑
     d. 4-Block 프롬프트 조립
     e. Task 도구로 스폰 (model: "sonnet")
  3. 모든 TM 완료 대기
  4. Wave 완료 게이트 검증
  5. 다음 Wave로 진행
```

### Wave 완료 게이트

각 Wave 완료 시 Lead가 검증:

```
□ 모든 TM 리포트 파일 존재 확인
□ 각 리포트에 [A] 구조 분석 / [B] 메트릭 / [C] 총평 포함
□ 이슈 ID 중복 없음
□ 검증 마커 누락 없음
□ 교차 참조 충돌 없음
```

### 중복 제거 프로토콜

```
1. 모든 TM 이슈를 이슈 ID + 위치(CSS 선택자) 기준으로 정렬
2. 동일 위치 + 유사 현상 → 심각도 높은 쪽만 유지
3. 제거된 이슈는 [CROSS-REFERENCED] 마커로 원본 참조
```

### 모드별 Wave 매트릭스

| 모드 | Wave 1 | Wave 2 | Wave 3 |
|------|:------:|:------:|:------:|
| basic | TM1-7 ✅ | ❌ | ❌ |
| --pro | TM1-7 ✅ | TM8-13 ✅ | ❌ |
| --expert | TM1-7 ✅ | TM8-13 ✅ | TM14-19 ✅ |
| --focus | 해당 TM만 ✅ | 해당 TM만 ✅ | 해당 TM만 ✅ |

---

## 10. Stage 3 — 리포트 통합 + UX Score 산출

### 18차원 가중치 모델

> SSOT: `references/scoring-model.md`

| # | 차원 | 가중치 | TM |
|:-:|------|:------:|:--:|
| 1 | Typography Fundamentals | 6% | TM1 |
| 2 | Typography Advanced | 5% | TM2 |
| 3 | Spacing & Layout | 7% | TM3 |
| 4 | WCAG Core Accessibility | **10%** | TM4 |
| 5 | WCAG Advanced Accessibility | 5% | TM5 |
| 6 | Cognitive Psychology & UX Laws | 7% | TM6 |
| 7 | **Typography & Color Quality** ★ | **4%** | **TM7** |
| 8 | Micro-interactions & Animation | 5% | TM8 |
| 9 | Interaction Patterns & Feedback | 7% | TM9 |
| 10 | IA & Navigation | 6% | TM10 |
| 11 | Mobile & Responsive | 6% | TM11 |
| 12 | Visual Hierarchy & Brand | 5% | TM12 |
| 13 | Form UX & Data Entry | 6% | TM13 |
| 14 | Design System Consistency | 4% | TM14 |
| 15 | Emotional Design & Delight | 3% | TM15 |
| 16 | Performance UX & Data Viz | 4% | TM16 |
| 17 | Microcopy & Content UX | 3% | TM17 |
| 18 | **Layout·Brand + Memorability** ★ | **4%** | **TM18-19** |

### 점수 산출 공식

```
차원_점수(d) = PASS(d) / (전체(d) - NOT_TESTABLE(d)) × 100
UX_총점 = Σ(차원_점수(d) × 가중치(d)) / Σ(활성_가중치(d))
최종_점수 = max(0, UX_총점 - CRITICAL×3 - MAJOR×1)
```

### 등급 체계

| 등급 | 점수 | 의미 |
|:----:|:----:|------|
| **S** | 90-100 | 탁월한 UX + 디자인 품질 |
| **A+** | 80-89 | 우수 |
| **A** | 70-79 | 양호 |
| **B+** | 60-69 | 평균 이상 |
| **B** | 50-59 | 평균 |
| **C** | 40-49 | 미흡 |
| **F** | 0-39 | 심각 |

### ASCII 레이더 차트

```
TYPO_FUND   ████████░░ 80%
TYPO_ADV    ███████░░░ 70%
LAYOUT      █████████░ 90%
A11Y_CORE   ██████░░░░ 60%
A11Y_ADV    ███████░░░ 70%
PSYCH       ████████░░ 80%
TYPO_COLOR  █████████░ 85%  ★
MICRO       ███████░░░ 70%
INTERACT    ████████░░ 80%
IA_NAV      ████████░░ 80%
MOBILE      ███████░░░ 70%
VISUAL      ████████░░ 80%
FORM        █████████░ 90%
DS          ███████░░░ 70%
EMOTION     ██████░░░░ 60%
PERF        ████████░░ 80%
CONTENT     ███████░░░ 70%
BRAND_MEM   ██████░░░░ 65%  ★
─────────────────────────────
총점: 76/100 (A)
```

### 이전 리포트 비교 (Diff)

```
1. .qa-audit/ 폴더 검색
2. 현재 run 제외 가장 최신 FINAL-REPORT.md 식별
3. 이슈 매칭 (카테고리 + 항목 ID + 위치)
4. 분류: 해결됨 / 신규 / 악화 / 유지
5. 비교 섹션 리포트 끝에 추가
```

> Diff 리포트 형식: `references/report-templates.md` 섹션 2 참조

---

## 11. 최종 리포트 템플릿

> SSOT: `references/report-templates.md`

저장 경로: `.qa-audit/run-{ts}/FINAL-REPORT.md`

리포트 구조:
1. 감사 개요 (URL, 일시, 모드, 항목 수, 뷰포트, TM 수, 소요 시간)
2. UX Score + 18차원 레이더 차트
3. 프로젝트 컨텍스트 (Stage 0)
4. 이슈 요약 (심각도별 건수 + 감점)
5. 상세 이슈 목록 (CRITICAL → MAJOR → MINOR → SUGGESTION)
6. 카테고리별 분석 (24개)
7. Design Quality 분석 (신규 S/T/U)
8. 검증 로그
9. 종합 권고사항 (P0~P3)
10. 이전 리포트 대비 변화 (있는 경우)

---

## 12. 에러 핸들링 + 환각 방지

### 실패 시나리오 매트릭스

| 시나리오 | 대응 |
|----------|------|
| Playwright 연결 실패 | "Playwright MCP 서버 확인 필요" 메시지 후 종료 |
| 대상 URL 접근 불가 | 3회 재시도, 실패 시 에러 리포트 |
| CSS Evaluate 스니펫 에러 | 해당 스니펫 [NOT-TESTABLE], 나머지 계속 |
| TM 스폰 실패 | Lead가 해당 카테고리 직접 수행 (Fallback) |
| TM 리포트 형식 오류 | Lead가 재요청 또는 직접 보정 |
| 모든 TM 실패 | basic 모드 Fallback (Lead 단독 T1만) |

### Lead 최종 검증 체크리스트

```
□ 모든 이슈에 검증 마커 존재
□ CRITICAL 이슈는 [DATA-VERIFIED] 또는 [SNAPSHOT-VERIFIED] 필수
□ 이슈 ID 중복 없음
□ 카테고리 간 중복 이슈 제거됨
□ UX Score 산출 공식 정확
□ 리포트 섹션 1-9 모두 존재 (10은 선택적)
□ 이전 리포트 대비 Diff 정확 (있는 경우)
```

---

## 메타

| 항목 | 값 |
|------|-----|
| 버전 | 1.0.0 |
| 최종 업데이트 | 2026-03-03 |
| 에이전트 | Lead + 19 TM (3-Wave) |
| 체크리스트 | ~450항목 (24 카테고리, A–V) |
| CSS 스니펫 | 22개 (기존 16 + DQ 6) |
| 참조 프레임워크 | 18개 |
| UX Score | 18차원 가중치, 7등급 (S~F) |
| 검증 마커 | 6종 |
| 참조 파일 | checklist-unified.md, css-snippets.md, expert-definitions.md, scoring-model.md, spawn-wave1/2/3.md, report-templates.md |

---

## 10단계 파이프라인 View (인사이트 1 매핑, 2026-05-25 P2-4b 추가)

> 본 스킬은 UI/UX + Design Quality 통합 audit ~450 체크리스트 + 19 specialists (3-Wave). 인사이트 1의 Step 3(Router 3-Wave) + Step 4(Context CSS 스니펫 22개) + Step 8(Critic 18차원 점수)이 가장 강하게 매핑.

| Step | 인사이트 1 단계 | 본 스킬 매핑 |
|:-:|---|---|
| 1 | Input Normalizer | URL + 모드 (basic / --pro / --expert / --focus=<cat>) |
| 2 | Intent Classifier | Design Quality 영역 분류 (24 카테고리 A-V) |
| 3 | **Task Router (강함)** | 3-Wave 분배 (Wave 1: 시각 / Wave 2: 인터랙션 / Wave 3: DQ 통합) |
| 4 | **Context Builder (강함)** | DOM + 시각 + CSS 스니펫 22개 + 18개 참조 프레임워크 |
| 5 | Planner | 각 Wave 별 specialists 동원 (총 19 specialists) |
| 6 | Tool Executor | 브라우저 도구 (UR §1 우선순위, Playwright MCP 전역 우선) + 3-Wave 순차+병렬 실행 |
| 7 | Draft Generator | 24 카테고리 보고서 (~450 체크리스트 항목) |
| 8 | **Critic / Verifier (강함)** | UX Score 18차원 가중치 산정 → 7등급 (S/A+/A/B+/B/C/F) |
| 9 | Refiner | 발견 정렬 + 사용자 명시 강등만 Low (UR §3) |
| 10 | Output Renderer | 통합 Design Quality 리포트 + UX Score + 검증 마커 6종 |

### 확립 패턴 (P1-5) — 3-Wave + 24 카테고리 특화

playwright-qa-expert(P1-5)와 동일 framing. 본 스킬은 24 카테고리 + 3-Wave 구조가 핵심 차이.

> **참조**: 인사이트 1 — `.thoughts/2026-05-25-harness-insights-round1.md` / 회고 — `.thoughts/2026-05-25-harness-application-completed.md`
