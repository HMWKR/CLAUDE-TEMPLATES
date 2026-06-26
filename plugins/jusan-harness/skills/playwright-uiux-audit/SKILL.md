---
name: playwright-uiux-audit
description: |
  Comprehensive UI/UX audit with 18 Agent-Teams specialists, 360 checklist items.
  Use when asked to "audit UI/UX", "UX review", "accessibility check", "UI audit",
  "check design quality", "UX 감사", "UI 감사", "접근성 검사", or "디자인 검토".
  UX Score (0-100). Modes: basic/--pro/--expert/--focus=<cat>.
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

1. **Browser Tool Priority** — `mcp__claude-in-chrome__*` 우선, `mcp__playwright__*` 는 fallback only
2. **Self-Justification Red Flags** — "이 정도면 충분" / "사소함" / "사용자가 신경 안 씀" / "베타니까 OK" / "fetch 진행 중이라 정상" 등장 시 **즉시 자기 차단**
3. **All Findings Are Defects** — 모든 발견은 결함. 사용자가 명시적으로 "강등"한 것만 Low
4. **Per-Round Deep Analysis** — 매 라운드 5단계 심층 분석 강제 (이전 재조회 → 미세 재스캔 → Adversarial walk → 자기 정당화 자가 검증 → 신규+재현성)

훅 강제: `detect-self-justification.sh` (5개 키워드 차단) + `check-chrome-mcp-priority.sh` (Playwright 우선 호출 가드).

> **이 스킬 이름은 "playwright-uiux-audit"이지만, Chrome MCP 가용 시 우선 사용 후 Playwright fallback. 이름은 legacy.**

---

# playwright-uiux-audit: 18-Agent Three-Wave UI/UX Audit System

> **버전**: 1.0.0 | **에이전트**: 18명 (3-Wave) | **체크리스트**: 360항목 | **카테고리**: 21개
> **프레임워크**: Nielsen's 10, WCAG 2.2 AA, Baymard, Laws of UX (31+), Gestalt, Material Design 3, Apple HIG, Atomic Design, Don Norman's 3 Levels, Core Web Vitals/RAIL, Rosenfeld & Morville, W3C i18n/CLDR, Color Theory/APCA, 12 Principles of Animation, Tufte

---

## 섹션 1: 실행 모드

### 모드별 구성

| 모드 | TM 수 | 웨이브 | 항목 수 | Tier | 예상 시간 | 비용 |
|:----:|:-----:|:------:|:------:|:----:|:---------:|:----:|
| `basic` | 6 | Wave 1만 | ~52 | T1 | 8-12분 | ~3-5x |
| `--pro` | 12 | Wave 1+2 | ~216 | T1+T2 | 25-40분 | ~8-12x |
| `--expert` | 18 | 전체 | 360 | 전체 | 45-80분 | ~15-18x |
| `--focus=<cat>` | 1 | 해당 TM | 15-25 | 전체 | 5-8분 | ~1-2x |

### 모드 파싱

```
입력: /playwright-uiux-audit <URL> [모드]

예시:
  /playwright-uiux-audit https://example.com              → basic
  /playwright-uiux-audit https://example.com --pro        → pro (12 TM)
  /playwright-uiux-audit https://example.com --expert     → expert (18 TM)
  /playwright-uiux-audit https://example.com --focus=E    → TM7만 (Micro-interactions)
  /playwright-uiux-audit https://example.com --focus=C1   → TM4만 (WCAG Core)
```

### --focus 카테고리 매핑

| Cat | TM | 이름 |
|:---:|:--:|------|
| A1 | TM1 | Typography Fundamentals |
| A2 | TM2 | Typography Advanced |
| B | TM3 | Spacing & Layout |
| C1 | TM4 | WCAG Core Accessibility |
| C2 | TM5 | WCAG Advanced Accessibility |
| D | TM6 | Cognitive Psychology & UX Laws |
| E | TM7 | Micro-interactions & Animation |
| F | TM8 | Interaction Patterns & Feedback |
| G | TM9 | Information Architecture & Navigation |
| H | TM10 | Mobile & Responsive Design |
| I,Q | TM11 | Visual Hierarchy & Brand + i18n |
| M | TM12 | Form UX & Data Entry |
| J | TM13 | Design System Consistency |
| K | TM14 | Emotional Design & Delight |
| L,R | TM15 | Performance UX & Data Visualization |
| N | TM16 | Microcopy & Content UX |
| O | TM17 | Color & Visual Harmony |
| P | TM18 | Loading & State Transitions |

---

## 섹션 2: 핵심 원칙

### 2.1 Anti-Hallucination Protocol (환각 방지)

모든 TM은 다음 6가지 검증 마커를 의무적으로 사용:

| 마커 | 의미 | 사용 시점 |
|------|------|----------|
| `[DATA-VERIFIED]` | CSS/DOM 데이터에서 확인 | 수치 기반 판단 |
| `[SNAPSHOT-VERIFIED]` | 스냅샷에서 시각 확인 | UI 요소 존재/배치 |
| `[PATTERN-INFERRED]` | 데이터 패턴에서 추론 | 직접 확인 불가 |
| `[CROSS-REFERENCED]` | 다른 Wave 리포트 참조 | Wave 2/3 교차 검증 |
| `[FRAMEWORK-BASED]` | 전문 프레임워크 기준 | 평가 근거 명시 |
| `[NOT-TESTABLE]` | 현재 데이터로 검증 불가 | Skip 처리 + 사유 |

**금지사항**: 데이터 없이 "~일 것이다", "~해 보인다" 등 추정 표현 사용 시 해당 항목 무효

### 2.2 카테고리 경계 규칙

#### E/F 경계 (Micro-interactions vs Interaction Patterns)

| 구분 | E: Micro-interactions (TM7) | F: Interaction Patterns (TM8) |
|:----:|:---------------------------:|:-----------------------------:|
| **핵심 질문** | "어떻게 움직이는가?" | "사용자가 무엇을 얻는가?" |
| **hover** | 시각 변화 (색상, 크기, 그림자, 트랜지션) | 정보 제공 (tooltip, 상태 표시, 피드백) |
| **focus** | focus ring 스타일, 애니메이션 | focus 시 행동 (자동스크롤, 확장 등) |
| **click** | ripple, scale, 색상 전환 | 결과물 (모달, 드롭다운, 네비게이션) |
| **scroll** | parallax, reveal 효과 | infinite scroll, lazy load 패턴 |
| **중복 발견 시** | TM7이 `[OVERLAP:F]` 태그 → Lead가 Stage 3에서 제거 |

#### I/J 경계 (Visual Hierarchy vs Design System)

| 구분 | I: Visual Hierarchy & Brand (TM11) | J: Design System Consistency (TM13) |
|:----:|:----------------------------------:|:------------------------------------:|
| **핵심 질문** | "눈이 올바른 순서로 흐르는가?" | "같은 역할이 같은 스타일인가?" |
| **일관성** | 페이지 간 브랜드 톤·무드 | 컴포넌트 변형(variant) 수 제한 |
| **측정** | F-패턴, Z-패턴, 시각 무게 | 디자인 토큰, 컴포넌트 카탈로그 |
| **범위** | 전체적 시각 흐름 | 원자(Atomic) 수준 일관성 |

#### N/O 경계 (Microcopy vs Color Harmony)

| 구분 | N: Microcopy (TM16) | O: Color Harmony (TM17) |
|:----:|:-------------------:|:-----------------------:|
| **텍스트 색상** | 가독성·톤 관점 | 색상 조화·심리학 관점 |

### 2.3 13+ 전문 프레임워크 참조 체계

| # | 프레임워크 | 적용 카테고리 | 핵심 원칙 |
|:-:|-----------|:------------:|----------|
| 1 | Nielsen's 10 Heuristics | F, 전체 | 시스템 상태 가시성, 일관성, 오류 예방 |
| 2 | WCAG 2.2 AA | C1, C2 | Perceivable, Operable, Understandable, Robust |
| 3 | Baymard Institute | M, F | 폼 UX, 체크아웃 패턴, 이커머스 UX |
| 4 | Laws of UX (31+) | D | Fitts', Hick's, Miller's, Jakob's, Doherty Threshold |
| 5 | Gestalt Principles | I, D | 근접성, 유사성, 연속성, 폐합, 전경/배경 |
| 6 | Material Design 3 | A1, H | 타이포그래피 스케일, 반응형 레이아웃 |
| 7 | Apple HIG | A1, H | SF Pro 시스템, 동적 타입, 안전 영역 |
| 8 | Atomic Design | J | Atoms → Molecules → Organisms → Templates → Pages |
| 9 | Don Norman's 3 Levels | K | Visceral, Behavioral, Reflective |
| 10 | Core Web Vitals/RAIL | L | LCP, FID/INP, CLS, Response/Animation/Idle/Load |
| 11 | Rosenfeld & Morville | G | IA: Organization, Labeling, Navigation, Search |
| 12 | W3C i18n / CLDR | Q | 텍스트 방향, 날짜/숫자 포맷, 문화적 적합성 |
| 13 | Color Theory / APCA | O | APCA 대비, 색상 조화, 색각 이상 시뮬레이션 |
| 14 | 12 Principles of Animation | E | Squash/Stretch, Anticipation, Staging, Ease in/out |
| 15 | Tufte's Data-Ink Ratio | R | 데이터 시각화, 차트 접근성, 정보 밀도 |

---

## 섹션 3: Three-Wave 하이브리드 아키텍처

### 3.1 전체 흐름

```
Stage 0: 프로젝트 & UX 컨텍스트 분석 (Lead 단독)
    │
    ▼
Stage 1: 25+단계 데이터 수집 (Lead 단독, Playwright MCP)
    │   ├─ 5개 뷰포트 스냅샷/스크린샷
    │   ├─ 16개 CSS Evaluate 스니펫 → JSON 토큰
    │   ├─ 네비게이션/사이트맵 수집
    │   ├─ 성능/네트워크 데이터
    │   └─ 콘솔 로그
    │
    ▼
Stage 2A: Wave 1 — Foundation 6명 병렬 (TM1-TM6)
    │   110항목 | 기초 분석 | 데이터만 참조
    │
    ▼
Stage 2B: Wave 2 — Interaction 6명 병렬 (TM7-TM12)
    │   125항목 | ★ Wave 1 리포트 교차 참조
    │
    ▼
Stage 2C: Wave 3 — Expert 6명 병렬 (TM13-TM18)
    │   125항목 | ★ Wave 1+2 리포트 교차 참조
    │
    ▼
Stage 3: 리포트 통합 + UX Score 산출 (Lead)
    └─ 중복 제거 → 점수 산출 → 15차원 레이더 → 최종 리포트
```

### 3.2 핵심 제약

| 제약 | 해결책 |
|------|--------|
| Playwright MCP 단일 브라우저 | Lead만 브라우저 조작, TM은 파일 기반 분석 |
| Orchestrator 최대 6명/웨이브 | 3-Wave 전략 (6+6+6 = 18명) |
| TM 간 파일 충돌 방지 | 각 TM은 지정된 자기 리포트 파일만 쓰기 |
| Wave 간 의존성 | Wave 2→1, Wave 3→1+2 리포트 읽기 전용 |

### 3.3 18명 전문가 팀 구성

#### Wave 1 — Foundation (6명, 항상 활성)

| TM | 역할 | 카테고리 | 항목 | T1 | 리포트 파일 |
|:--:|------|:--------:|:----:|:--:|------------|
| TM1 | 타이포그래피 기초 전문가 | A1(15) | 15 | 3 | typography-fundamentals.md |
| TM2 | 타이포그래피 고급 전문가 | A2(15) | 15 | 2 | typography-advanced.md |
| TM3 | 스페이싱 & 레이아웃 전문가 | B(25) | 25 | 5 | spacing-layout.md |
| TM4 | WCAG 핵심 접근성 전문가 | C1(15) | 15 | 5 | wcag-core.md |
| TM5 | WCAG 고급 접근성 전문가 | C2(15) | 15 | 2 | wcag-advanced.md |
| TM6 | 인지 심리학 & UX 법칙 전문가 | D(25) | 25 | 5 | cognitive-psychology.md |
| | | **W1 합계** | **110** | **22** | |

#### Wave 2 — Interaction (6명, --pro 이상)

| TM | 역할 | 카테고리 | 항목 | T1 | 리포트 파일 |
|:--:|------|:--------:|:----:|:--:|------------|
| TM7 | 마이크로인터랙션 & 애니메이션 전문가 | E(20) | 20 | 3 | micro-interactions.md |
| TM8 | 인터랙션 패턴 & 피드백 전문가 | F(20) | 20 | 3 | interaction-patterns.md |
| TM9 | 정보 아키텍처 & 네비게이션 분석가 | G(20) | 20 | 3 | information-architecture.md |
| TM10 | 모바일 & 반응형 디자인 전문가 | H(20) | 20 | 3 | mobile-responsive.md |
| TM11 | 시각 계층 & 브랜드 + i18n 전문가 | I(15)+Q(10) | 25 | 3 | visual-hierarchy-i18n.md |
| TM12 | 폼 UX & 데이터 입력 전문가 | M(20) | 20 | 3 | form-ux.md |
| | | **W2 합계** | **125** | **18** | |

#### Wave 3 — Expert (6명, --expert)

| TM | 역할 | 카테고리 | 항목 | T1 | 리포트 파일 |
|:--:|------|:--------:|:----:|:--:|------------|
| TM13 | 디자인 시스템 감사관 | J(20)+Edge(4) | 24 | 3 | design-system.md |
| TM14 | 감성 디자인 & 딜라이트 평가사 | K(15)+Edge(4) | 19 | 2 | emotional-design.md |
| TM15 | 성능 UX & 데이터 시각화 엔지니어 | L(15)+R(10) | 25 | 3 | performance-dataviz.md |
| TM16 | 마이크로카피 & 콘텐츠 UX 전문가 | N(15)+Edge(4) | 19 | 2 | microcopy-content.md |
| TM17 | 색상 조화 & 비주얼 하모니 전문가 | O(15)+Edge(4) | 19 | 2 | color-harmony.md |
| TM18 | 로딩 & 상태 전환 전문가 | P(15)+Edge(4) | 19 | 2 | loading-states.md |
| | | **W3 합계** | **125** | **14** | |

### 3.4 Tier 시스템

| Tier | 이름 | 항목 수 | 포함 모드 | 설명 |
|:----:|------|:------:|:---------:|------|
| Tier 1 | Essential | ~52 | basic, --pro, --expert | 핵심 UX 문제 (반드시 수정) |
| Tier 2 | Professional | ~164 | --pro, --expert | 전문 UX 향상 (권장 수정) |
| Tier 3 | Expert | ~144 | --expert | 심층 UX 최적화 (고급 개선) |
| **합계** | | **360** | | |

### 3.5 Agent-Teams 비활성 시 Fallback

```
IF agent-teams 미활성:
  → 단일 에이전트가 Lead + TM1-TM6 역할 순차 수행
  → Tier 1 (~52항목)만 검사
  → Wave 2/3 스킵
  → 리포트에 "[FALLBACK-MODE] agent-teams 비활성 — Tier 1만 검사됨" 표시
```

---

## 섹션 4: 데이터 디렉토리 구조

### 4.1 디렉토리 레이아웃

```
{project-root}/
├── uiux-data/                    # Lead만 쓰기, TMs 읽기 전용
│   ├── snapshots/                # browser_snapshot 결과 (5 viewport)
│   │   ├── desktop-1920.md
│   │   ├── laptop-1366.md
│   │   ├── tablet-768.md
│   │   ├── mobile-390.md
│   │   └── mobile-small-320.md
│   ├── screenshots/              # 5개 뷰포트 스크린샷
│   │   ├── desktop-1920.png
│   │   ├── laptop-1366.png
│   │   ├── tablet-768.png
│   │   ├── mobile-390.png
│   │   └── mobile-small-320.png
│   ├── tokens/                   # 16개 CSS JSON
│   │   ├── typography.json       (T-1~T-5)
│   │   ├── spacing.json          (S-1, S-2)
│   │   ├── colors.json           (C-1, C-2)
│   │   ├── animation.json        (ANIM-1)
│   │   ├── components.json       (M-1, M-2)
│   │   ├── design-system.json    (DS-1)
│   │   ├── forms.json            (FORM-1)
│   │   └── comprehensive.json    (A-1)
│   ├── navigation/               # IA 데이터
│   │   ├── sitemap.json
│   │   ├── nav-structure.json    (NAV-1)
│   │   └── links.json
│   ├── performance/              # 성능 데이터
│   │   ├── network.json
│   │   ├── resources.json
│   │   └── timing.json
│   ├── console-logs.md
│   ├── project-analysis.md
│   └── personas.md
└── uiux-reports/                 # 각 TM 자기 파일만 쓰기
    ├── typography-fundamentals.md   (TM1)
    ├── typography-advanced.md       (TM2)
    ├── spacing-layout.md            (TM3)
    ├── wcag-core.md                 (TM4)
    ├── wcag-advanced.md             (TM5)
    ├── cognitive-psychology.md      (TM6)
    ├── micro-interactions.md        (TM7)
    ├── interaction-patterns.md      (TM8)
    ├── information-architecture.md  (TM9)
    ├── mobile-responsive.md         (TM10)
    ├── visual-hierarchy-i18n.md     (TM11)
    ├── form-ux.md                   (TM12)
    ├── design-system.md             (TM13)
    ├── emotional-design.md          (TM14)
    ├── performance-dataviz.md       (TM15)
    ├── microcopy-content.md         (TM16)
    ├── color-harmony.md             (TM17)
    ├── loading-states.md            (TM18)
    └── UIUX-AUDIT-{timestamp}.md   (Lead 최종)
```

### 4.2 접근 권한 매트릭스 (★ 3-Wave 교차 참조)

| 주체 | uiux-data/ | 자기 리포트 | W1 리포트 | W2 리포트 | W3 리포트 |
|:----:|:----------:|:----------:|:---------:|:---------:|:---------:|
| Lead | **R/W** | FINAL만 W | R (Stage 3) | R (Stage 3) | R (Stage 3) |
| Wave 1 (TM1-6) | R | **W** | N/A | N/A | N/A |
| Wave 2 (TM7-12) | R | **W** | **R** ★ | N/A | N/A |
| Wave 3 (TM13-18) | R | **W** | **R** ★ | **R** ★ | N/A |

### 4.3 디렉토리 생성 (Lead Stage 1 시작 전)

```bash
mkdir -p uiux-data/snapshots uiux-data/screenshots uiux-data/tokens uiux-data/navigation uiux-data/performance uiux-reports
```

---

## 섹션 5: Stage 0 — 프로젝트 분석 (Progressive Disclosure)

> 프로젝트 분석 절차(4단계), 페르소나 템플릿(3명), 분석 결과 저장 형식은
> [references/stage0-analysis.md](references/stage0-analysis.md) 참조.


---

## 섹션 6: Stage 1 — 데이터 수집 (Progressive Disclosure)

> 27단계 수집 절차, 도구 실패 대응표, 16개 CSS Evaluate 스니펫 ID 매핑은
> [references/stage1-data-collection.md](references/stage1-data-collection.md) 참조.
> CSS 스니펫 상세는 [references/css-evaluate-snippets.md](references/css-evaluate-snippets.md) 참조.


---

## 섹션 7: TM Spawn 프롬프트 (Progressive Disclosure)

> 공통 4-Block 템플릿, Wave 교차 참조 블록, 리포트 출력 형식은
> [references/tm-spawn-templates.md](references/tm-spawn-templates.md) 참조.
> Wave별 TM Spawn 상세: spawn-wave1/2/3.md 참조.

---## 섹션 8: 360항목 체크리스트 (Progressive Disclosure)> 모드별 해당 Tier 체크리스트만 로드하여 컨텍스트 절약.| 모드 | 로드할 파일 | 항목 수 ||:----:|-----------|:------:|| basic | [references/checklist-tier1.md](references/checklist-tier1.md) | ~54 (T1) || --pro | 위 + [references/checklist-tier2.md](references/checklist-tier2.md) | ~216 (T1+T2) || --expert | 위 + [references/checklist-tier3.md](references/checklist-tier3.md) | 360 (전체) |### 검증 요약```Wave 1 (Foundation): A1(15) + A2(15) + B(25) + C1(15) + C2(15) + D(25) = 110항목Wave 2 (Interaction): E(20) + F(20) + G(20) + H(20) + I(15) + Q(10) + M(20) = 125항목Wave 3 (Expert):      J(20) + K(15) + L(15) + R(10) + N(15) + O(15) + P(15) + Edge(20) = 125항목총합: 360항목Tier 분포: T1 ~54항목 / T2 ~162항목 / T3 ~144항목```---
## 9. Wave 실행 프로토콜 (Progressive Disclosure)

> Wave 실행 절차, 완료 게이트 체크리스트, 중복 제거 프로토콜, 모드별 실행 매트릭스는
> [references/wave-execution.md](references/wave-execution.md) 참조.


---

## 10-11. UX Score 산출 + 최종 리포트 (Progressive Disclosure)

> 15차원 가중치 체계, 점수 산출 공식, 등급 체계(S~F), 레이더 차트,
> 심각도 분류, 최종 리포트 템플릿은 [references/score-and-report.md](references/score-and-report.md) 참조.


---

## 12. 에러 핸들링 + 환각 방지 (Progressive Disclosure)

> 에러 핸들링 매트릭스, Fallback 전략, 6가지 검증 마커 규칙,
> TM 리포트 필수 구조, Lead 최종 검증 체크리스트는
> [references/error-handling-audit.md](references/error-handling-audit.md) 참조.


---

## 스킬 메타 정보

```
버전: 1.0.0
최종 업데이트: 2026-02-08
에이전트 수: 18 (3-Wave × 6)
체크리스트: 360항목 (21 카테고리)
프레임워크: 13+ 전문 프레임워크
CSS 스니펫: 16개 (기존 12 + 신규 4)
UX Score: 0-100 (15차원 가중)
등급: S / A+ / A / B+ / B / C / F
검증 마커: 6종
```

---

> **공유 참조**: 역할 채택 신호(Signal 1-3)와 출력 형식([A][B][C])은
> `~/.claude/skills/_core/qa/behavioral-signals.md` 참조.
> QA 전문가 역할 체계는 `~/.claude/skills/_core/qa/checklist-175.md`와
> `~/.claude/skills/_core/roles.md`에서 정의된 역할을 기반으로 확장합니다.

---

## 10단계 파이프라인 View (인사이트 1 매핑, 2026-05-25 P2-4b 추가)

> 본 스킬은 UI/UX audit 360 체크리스트 + 18 Agent-Teams specialists. UX Score 18차원. 인사이트 1의 Step 4(Context) + Step 8(Critic — UX Score 산정)이 가장 강하게 매핑.

| Step | 인사이트 1 단계 | 본 스킬 매핑 |
|:-:|---|---|
| 1 | Input Normalizer | URL + 모드 (basic / --pro / --expert / --focus=<cat>) |
| 2 | Intent Classifier | UX 영역 분류 (시각 / 인터랙션 / 접근성 / 정보 설계 등 18차원) |
| 3 | Task Router | 18 specialists 분배 (모드에 따라 활성화 specialists 수 조정) |
| 4 | **Context Builder (강함)** | DOM + 시각 캡처 + 사용자 페르소나 + 360 체크리스트 |
| 5 | Planner | 각 specialist 별 체크리스트 분담 |
| 6 | Tool Executor | `mcp__claude-in-chrome__*` 우선 (UR §1) / 18 specialists 병렬 분석 |
| 7 | Draft Generator | 18개 영역별 보고서 |
| 8 | **Critic / Verifier (강함)** | Lead가 18차원 점수 통합 + UX Score 0-100 산정 + 7등급 (S~F) |
| 9 | Refiner | Blockers / Warnings / Suggestions + 사용자 명시 강등만 Low (UR §3) |
| 10 | Output Renderer | 통합 UX 리포트 + 6종 검증 마커 + UX Score |

### 확립 패턴 (P1-5) — UX Score 산정 특화

playwright-qa-expert(P1-5)와 동일 framing. 본 스킬은 UX Score 18차원 산정이 핵심 차이.

> **참조**: 인사이트 1 — `.thoughts/2026-05-25-harness-insights-round1.md` / 회고 — `.thoughts/2026-05-25-harness-application-completed.md`
