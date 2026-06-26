---
name: playwright-qa-agent-teams
description: |
  This skill performs parallel QA testing with Agent Teams using Playwright MCP tools.
  Use when AGENT_TEAMS=1 and asked to "QA test with team", or routed from playwright-qa-expert.
  Hybrid Pattern: Lead collects data via Playwright, 4-8 Teammates analyze in parallel.
  Supports 3 tiers: basic (~35 items), --full (~120 items), --all (175 items).
  Fallback: single agent mode when agent-teams is disabled.
  Requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1.
---

## ⚠️ Uncompromising Rigor (글로벌 룰 강제 적용)

이 스킬은 `~/.claude/rules/uncompromising-rigor.md` 의 4개 정책을 **무조건 준수**한다:

1. **Browser Tool Priority** — `mcp__claude-in-chrome__*` 우선, `mcp__playwright__*` 는 fallback only
2. **Self-Justification Red Flags** — "이 정도면 충분" / "사소함" / "사용자가 신경 안 씀" / "베타니까 OK" / "fetch 진행 중이라 정상" 등장 시 **즉시 자기 차단**
3. **All Findings Are Defects** — 모든 발견은 결함. 사용자가 명시적으로 "강등"한 것만 Low
4. **Per-Round Deep Analysis** — 매 라운드 5단계 심층 분석 강제 (이전 재조회 → 미세 재스캔 → Adversarial walk → 자기 정당화 자가 검증 → 신규+재현성)

훅 강제: `detect-self-justification.sh` (5개 키워드 차단) + `check-chrome-mcp-priority.sh` (Playwright 우선 호출 가드).

> **이 스킬 이름은 "playwright-qa"이지만, Chrome MCP 가용 시 우선 사용 후 Playwright fallback. 이름은 legacy.**

---

# Playwright QA Agent-Teams 스킬

> **패턴**: Hybrid (Lead 데이터 수집 + Parallel Specialists 분석)
> **기반**: playwright-qa-expert 175개 체크리스트 + agent-teams 멀티 에이전트 아키텍처

## 목차
- [1. 실행 모드](#1-실행-모드)
- [2. 핵심 원칙](#2-핵심-원칙)
- [3. Hybrid Pattern 아키텍처](#3-hybrid-pattern-아키텍처)
- [4. 데이터 디렉토리 구조](#4-데이터-디렉토리-구조)
- [5. Stage 0: 프로젝트 분석](#5-stage-0-프로젝트-분석)
- [6. Stage 1: Lead 데이터 수집](#6-stage-1-lead-데이터-수집)
- [7. 팀 정의 & Spawn 시스템](#7-팀-정의--spawn-시스템)
- [8. 체크리스트 분배](#8-체크리스트-분배)
- [9. Stage 2: 병렬 전문가 분석](#9-stage-2-병렬-전문가-분석)
- [10. Stage 3: 리포트 통합](#10-stage-3-리포트-통합)
- [11. 최종 리포트 템플릿](#11-최종-리포트-템플릿)
- [12. 에러 핸들링 & Fallback](#12-에러-핸들링--fallback)
- [13. 환각 방지 프로토콜](#13-환각-방지-프로토콜)
- [14. 리포트 비교 & 카테고리별 실행](#14-리포트-비교--카테고리별-실행)
- [15. 체크리스트 소스 참조](#15-체크리스트-소스-참조)
- [16. 단일 에이전트 vs Agent-Teams 비교](#16-단일-에이전트-vs-agent-teams-비교)
- [17. 행동 채택 표준](#17-행동-채택-표준)

---

## 1. 실행 모드

### 1.1 모드 선택

| 모드 | 호출 | 팀 구성 | 티어 | 항목 수 | 소요 시간 |
|:----:|------|:-------:|:----:|:-------:|:---------:|
| **기본** | `/playwright-qa-agent-teams` | Lead + 4 TM | Tier 1 | ~35 | 7-10분 |
| **전체** | `--full` | Lead + 6 TM | Tier 1+2 | ~120 | 15-25분 |
| **완전** | `--all` | Lead + 6-8 TM | 전체 | 175 | 25-40분 |
| **카테고리** | `--category=<name>` | Lead + 1-2 TM | 해당 카테고리 전체 | 가변 | 5-10분 |

### 1.2 환경 확인 (최초 실행 시)

```
1. CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 환경변수 확인
2. Playwright MCP 서버 연결 확인 (browser_navigate 가용 여부)
3. 프로젝트 루트 디렉토리 확인
4. 환경 미충족 시 → Fallback: 단일 에이전트 모드 안내
   "agent-teams 환경이 감지되지 않습니다. /playwright-qa-expert 단일 에이전트 모드를 사용하시겠습니까?"
```

---

## 2. 핵심 원칙

| # | 원칙 | 설명 |
|:-:|------|------|
| 1 | **Hybrid Pattern** | Lead만 Playwright MCP 사용, Teammates는 파일만 읽기 |
| 2 | **독립 컨텍스트** | 각 Teammate는 자기 전용 1M 토큰 컨텍스트 보유 |
| 3 | **파일 기반 통신** | qa-data/ (Lead→TM 읽기전용), qa-reports/ (TM별 전용 파일) |
| 4 | **검증된 것만 보고** | 직접 확인한 데이터만 리포트, 추정은 `[추정]` 마커 |
| 5 | **Graceful Degradation** | TM 실패 → Lead가 해당 역할 수행, 전체 실패 → 단일 에이전트 |

---

## 3. Hybrid Pattern 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│  Stage 0: 프로젝트 분석 (Lead 단독)                          │
│  • 프로젝트 도메인/기술스택 파악                              │
│  • 타겟 사용자 페르소나 생성                                  │
│  • 추가 전문가 자동 선택 (8개 트리거)                         │
│  • 실행 모드에 따른 팀 구성 결정                              │
└───────────────────────┬─────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│  Stage 1: 데이터 수집 (Lead 단독, Playwright MCP)            │
│  • browser_navigate → 모든 페이지 탐색                       │
│  • browser_snapshot → 접근성 트리 (qa-data/snapshots/)       │
│  • browser_take_screenshot → 스크린샷 (qa-data/screenshots/) │
│  • browser_evaluate → CSS 값 JSON (qa-data/css-values/)     │
│  • browser_console_messages → 콘솔 로그                      │
│  • browser_network_requests → 네트워크 로그                  │
│  • browser_resize → 모바일/태블릿 반응형 데이터              │
│  → 모든 데이터를 qa-data/ 폴더에 파일로 저장                 │
└───────────────────────┬─────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│  Stage 2: 병렬 전문가 분석 (Teammates)                       │
│                                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │TM1: UX   │ │TM2: 접근 │ │TM3: 모바 │ │TM4: 타겟 │      │
│  │+시각계층 │ │성+심리학 │ │일+아키텍 │ │사용자    │      │
│  │A,B,F     │ │C,D       │ │E,G,H     │ │페르소나  │      │
│  │qa-data/→ │ │qa-data/→ │ │qa-data/→ │ │qa-data/→ │      │
│  │ux-visual │ │a11y-psych│ │mobile-   │ │target-   │      │
│  │.md       │ │.md       │ │arch.md   │ │user.md   │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
│                                                             │
│  ┌──────────┐ ┌──────────┐                (--full/--all)   │
│  │TM5: 성능 │ │TM6: 보안 │                                 │
│  │엔지니어  │ │분석가    │                                  │
│  └──────────┘ └──────────┘                                  │
└───────────────────────┬─────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│  Stage 3: 리포트 통합 (Lead)                                 │
│  • qa-reports/*.md 수집                                      │
│  • 중복 이슈 제거 + 심각도 재분류                             │
│  • Critical 이슈 원본 데이터 교차 검증                        │
│  • FINAL-REPORT-{timestamp}.md 생성                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. 데이터 디렉토리 구조

```
{project-root}/
├── qa-data/                          # Lead만 쓰기, Teammates는 읽기 전용
│   ├── snapshots/                    # 접근성 스냅샷 (browser_snapshot)
│   │   ├── page-main.md
│   │   ├── page-login.md
│   │   └── page-{name}.md
│   ├── screenshots/                  # 스크린샷 (browser_take_screenshot)
│   │   ├── desktop-main.png
│   │   ├── mobile-main.png
│   │   └── tablet-main.png
│   ├── css-values/                   # CSS computed style (browser_evaluate)
│   │   ├── typography.json
│   │   ├── spacing.json
│   │   ├── colors.json
│   │   └── comprehensive.json        # A-1 종합 스니펫 결과
│   ├── console-logs.md               # 콘솔 메시지
│   ├── network-log.md                # 네트워크 요청
│   ├── project-analysis.md           # 프로젝트 분석 결과
│   └── persona.md                    # 타겟 사용자 페르소나 정의
│
└── qa-reports/                       # 각 Teammate가 자기 파일만 작성
    ├── ux-visual.md                  # TM1
    ├── a11y-psychology.md            # TM2
    ├── mobile-arch.md                # TM3
    ├── target-user.md                # TM4
    ├── performance.md                # TM5 (--full/--all)
    ├── security.md                   # TM6 (--full/--all)
    └── FINAL-REPORT-{timestamp}.md   # Lead가 통합 생성
```

### 접근 규칙

| 주체 | qa-data/ | qa-reports/ |
|:----:|:--------:|:-----------:|
| Lead | **읽기+쓰기** | FINAL-REPORT만 쓰기 |
| TM1 | 읽기 전용 | `ux-visual.md`만 쓰기 |
| TM2 | 읽기 전용 | `a11y-psychology.md`만 쓰기 |
| TM3 | 읽기 전용 | `mobile-arch.md`만 쓰기 |
| TM4 | 읽기 전용 | `target-user.md`만 쓰기 |
| TM5 | 읽기 전용 | `performance.md`만 쓰기 |
| TM6 | 읽기 전용 | `security.md`만 쓰기 |

---

## 5. Stage 0: 프로젝트 분석 (Lead 단독)

### 5.1 분석 단계

```
1. 프로젝트 디렉토리의 package.json, README.md 등 읽기
2. 기술 스택 파악 (React, Vue, Angular, Vanilla 등)
3. 도메인 파악 (e-commerce, SaaS, 대시보드, 랜딩 등)
4. 타겟 사용자 페르소나 정의 → qa-data/persona.md 저장
5. 동적 전문가 트리거 테이블 확인 → 추가 Teammate 결정
6. 팀 구성 확정
```

### 5.2 타겟 사용자 페르소나 템플릿

qa-data/persona.md에 저장:

```markdown
# 타겟 사용자 페르소나

## 인구통계
- **연령대**: [예: 25-45세]
- **기술 수준**: [초급/중급/고급]
- **디바이스**: [모바일 중심 / 데스크톱 중심 / 혼합]

## 사용 맥락
- **주요 사용 환경**: [예: 출퇴근 중 모바일, 사무실 데스크톱]
- **사용 빈도**: [일일 / 주간 / 비정기]
- **핵심 목표**: [예: 빠른 정보 확인, 거래 완료]

## 불편 지점 (Pain Points)
1. [예: 느린 로딩에 민감]
2. [예: 복잡한 네비게이션]
3. [예: 접근성 의존]

## 테스트 시나리오
1. [페르소나 관점의 핵심 사용자 여정]
2. [불편 지점과 관련된 스트레스 시나리오]
3. [예외 상황 시나리오]
```

### 5.3 동적 전문가 트리거 테이블

| # | 트리거 조건 | 추가 Teammate | 모드 |
|:-:|------------|:------------:|:----:|
| 1 | lang 속성 다국어 / i18n 라이브러리 감지 | 국제화 전문가 | --all |
| 2 | Lighthouse 점수 낮음 / 번들 >500KB | 성능 엔지니어 (TM5) | --full |
| 3 | 일러스트/아이콘 30개+ / 커스텀 폰트 3종+ | 비주얼 디자이너 | --all |
| 4 | 장문 콘텐츠 5개+ / 마케팅 CTA 3개+ | 콘텐츠 전략가 | --all |
| 5 | 포인트/뱃지/리더보드 감지 | 게이미피케이션 전문가 | --all |
| 6 | 장바구니/결제/상품 목록 감지 | E-commerce UX | --full |
| 7 | 차트/테이블/대시보드 레이아웃 감지 | 대시보드/DataViz | --full |
| 8 | SaaS 패턴 (구독, 온보딩, 설정) 감지 | SaaS UX 전문가 | --full |

### 5.4 모드별 팀 구성

```
기본 모드: Lead + TM1(UX) + TM2(접근성) + TM3(모바일) + TM4(페르소나)
--full:    기본 + TM5(성능) + TM6(보안) + 트리거 매치 1-2명
--all:     --full + 모든 트리거 매치 (최대 8 Teammates)
--category: Lead + 해당 카테고리 담당 TM 1-2명
```

### 5.5 project-analysis.md 저장

```markdown
# 프로젝트 분석 결과

## 기본 정보
- **프로젝트명**: {name}
- **기술 스택**: {tech stack}
- **도메인**: {domain}
- **URL**: {target URL}

## 페이지 목록
1. {page1 URL} - {설명}
2. {page2 URL} - {설명}

## 감지된 패턴
- {패턴1}: {설명}
- {패턴2}: {설명}

## 트리거 매치
- {트리거#}: {매치 이유}

## 팀 구성
- Lead: 데이터 수집 + 리포트 통합
- TM1: {역할} - {담당 카테고리}
- TM2: {역할} - {담당 카테고리}
- ...
```

---

## 6. Stage 1: Lead 데이터 수집 (Playwright MCP)

> **핵심**: Lead만 Playwright MCP 도구를 사용. 모든 데이터를 qa-data/에 파일로 저장.

### 6.1 수집 절차

```
[Step 1] 디렉토리 생성
mkdir -p qa-data/snapshots qa-data/screenshots qa-data/css-values qa-reports

[Step 2] 메인 페이지 탐색
browser_navigate → 대상 URL

[Step 3] 데스크톱 스냅샷
browser_snapshot → qa-data/snapshots/page-main.md 저장

[Step 4] 데스크톱 스크린샷
browser_take_screenshot → qa-data/screenshots/desktop-main.png 저장

[Step 5] CSS 값 종합 수집 (A-1 스니펫)
browser_evaluate → qa-data/css-values/comprehensive.json 저장

[Step 6] 콘솔 로그 수집
browser_console_messages → qa-data/console-logs.md 저장

[Step 7] 네트워크 요청 수집
browser_network_requests → qa-data/network-log.md 저장

[Step 8] 모바일 뷰포트 수집
browser_resize(width: 375, height: 812) → 스냅샷 + 스크린샷
→ qa-data/snapshots/page-main-mobile.md
→ qa-data/screenshots/mobile-main.png

[Step 9] 태블릿 뷰포트 수집
browser_resize(width: 768, height: 1024) → 스냅샷 + 스크린샷
→ qa-data/snapshots/page-main-tablet.md
→ qa-data/screenshots/tablet-main.png

[Step 10] 데스크톱 복원
browser_resize(width: 1280, height: 800)

[Step 11] 하위 페이지 탐색 (발견된 링크 기반)
⚠️ 종료 조건 (의미적 루프 방지):
  - 최대 페이지 수: 5개 (--full: 10개, --all: 20개)
  - 최대 깊이: 2단계 (메인 → 하위1 → 하위2까지만)
  - 순환 링크 감지: 이미 방문한 URL은 스킵 (visited_urls 목록 관리)
  - 컨텍스트 예산: 전체의 40% 이상 소진 시 즉시 중단
  - 타임아웃: 페이지당 최대 30초, 전체 탐색 최대 5분

각 페이지마다 Step 2-5 반복 (위 종료 조건 내에서만)
→ qa-data/snapshots/page-{name}.md
→ qa-data/screenshots/desktop-{name}.png
→ qa-data/css-values/{name}.json

[Step 11-checkpoint] 탐색 진행 상태 저장
각 하위 페이지 완료 시 qa-data/checkpoint.json 업데이트:
  - completed_pages: 완료된 페이지 URL 목록
  - remaining_pages: 미탐색 페이지 URL 목록
  - visited_urls: 방문 완료 URL (순환 방지)
  - context_usage_percent: 현재 컨텍스트 사용 추정치

[Step 12] 인터랙션 테스트
폼, 버튼, 모달 등 인터랙티브 요소 조작 후 스냅샷
→ qa-data/snapshots/interaction-{name}.md

[Step 13] 포커스 테스트 (Tab 키)
browser_press_key("Tab") 반복 → 포커스 순서 기록
→ qa-data/snapshots/focus-order.md

[Step 14] 에러 상태 수집
잘못된 입력, 빈 상태 등 에러 UI 캡처
→ qa-data/snapshots/error-states.md
→ qa-data/screenshots/error-{name}.png

[Step 15] 수집 완료 확인
qa-data/ 파일 목록 + 크기 기록 → qa-data/collection-summary.md
```

### 6.2 A-1 종합 CSS 수집 스니펫

```javascript
// browser_evaluate: 한 번에 핵심 CSS 지표 수집
(function() {
  const body = document.body;
  const p = document.querySelector('p');
  const h1 = document.querySelector('h1');
  const input = document.querySelector('input');
  const btn = document.querySelector('button');
  const cs = (el) => el ? window.getComputedStyle(el) : null;

  return {
    typography: {
      bodyFontSize: cs(p)?.fontSize || cs(body)?.fontSize,
      bodyLineHeight: cs(p)?.lineHeight,
      bodyFontFamily: cs(p)?.fontFamily?.split(',')[0],
      h1FontSize: cs(h1)?.fontSize,
      inputFontSize: cs(input)?.fontSize
    },
    spacing: {
      bodyPadding: cs(body)?.padding,
      bodyMargin: cs(body)?.margin,
      buttonPadding: cs(btn) ? `${cs(btn).paddingTop} ${cs(btn).paddingRight} ${cs(btn).paddingBottom} ${cs(btn).paddingLeft}` : null
    },
    color: {
      bodyColor: cs(body)?.color,
      bodyBg: cs(body)?.backgroundColor,
      linkColor: cs(document.querySelector('a'))?.color,
      buttonBg: cs(btn)?.backgroundColor
    },
    viewport: {
      width: window.innerWidth,
      height: window.innerHeight,
      devicePixelRatio: window.devicePixelRatio
    },
    meta: {
      viewport: document.querySelector('meta[name="viewport"]')?.content,
      charset: document.characterSet,
      title: document.title?.substring(0, 50)
    }
  };
})()
```

### 6.3 도구 실패 시 대처

| 도구 | 실패 유형 | 대처 |
|------|----------|------|
| browser_navigate | 타임아웃/404 | 3초 후 재시도 1회 → 실패 시 해당 페이지 건너뛰기 |
| browser_snapshot | 빈 결과 | browser_evaluate로 DOM 구조 직접 수집 |
| browser_evaluate | 스크립트 에러 | 개별 속성 쿼리로 분할 시도 |
| browser_take_screenshot | 실패 | 스냅샷으로 대체, `[스크린샷 미수집]` 표시 |
| browser_resize | 실패 | 현재 뷰포트에서 계속, `[반응형 미확인]` 표시 |
| browser_console_messages | 빈 결과 | 정상 (에러 없음), `console-logs.md`에 "에러 없음" 기록 |

### 6.4 체크리스트 기반 데이터 파일 자동 생성

Lead는 수집 완료 후, 각 Teammate가 필요한 데이터를 쉽게 찾을 수 있도록 인덱스 파일 생성:

```markdown
# qa-data/collection-summary.md

## 수집 완료 시각: {timestamp}
## 수집 페이지: {count}개

### 파일 목록
| 파일 | 크기 | 수집 상태 |
|------|:----:|:---------:|
| snapshots/page-main.md | {size} | OK |
| screenshots/desktop-main.png | {size} | OK |
| css-values/comprehensive.json | {size} | OK |
| ... | ... | ... |

### 미수집 항목
- [항목]: [사유]
```

---

## 7. 팀 정의 & Spawn 시스템

### 7.1 Teammate Spawn 프롬프트 공통 템플릿

모든 Teammate는 다음 4-블록 구조로 Spawn:

```
[Block 1: Context Priming]
당신은 QA 테스트팀의 {역할명}입니다.
Lead가 Playwright MCP로 수집한 데이터가 `qa-data/` 폴더에 있습니다.
프로젝트 분석 결과: `qa-data/project-analysis.md`
타겟 사용자 정의: `qa-data/persona.md`

[Block 2: Role Definition]
당신의 전문 분야: {전문 분야 설명}
핵심 질문: "{이 전문가가 답해야 할 핵심 질문}"
평가 기준: {구체적 기준값들}

[Block 3: Task Instructions]
1. qa-data/ 폴더의 관련 파일들을 모두 읽으세요
2. 담당 체크리스트 항목별로 PASS/FAIL 판정하세요
3. FAIL 항목은 심각도(Critical/Major/Minor/Suggestion) 분류하세요
4. 재현 경로 + 권장 수정사항을 작성하세요
5. 결과를 `qa-reports/{output-file}.md` 에 저장하세요

[Block 4: Completion Conditions]
- 모든 담당 체크리스트 항목 평가 완료
- 각 FAIL 항목에 심각도 + 재현경로 + 수정권장 포함
- 추정이 필요한 경우 [추정] 마커 사용
- 완료 후 "분석 완료" 메시지 출력
```

### 7.2-7.7 Teammate Spawn 프롬프트

> Teammate별 4-Block Spawn 프롬프트는 [references/spawn-prompts.md](references/spawn-prompts.md) 참조.
> Lead가 Stage 2에서 각 TM Spawn 시 해당 섹션을 Read하여 프롬프트에 포함.
>
> **포함 내용**: TM1(UX+시각계층), TM2(접근성+심리), TM3(모바일+아키텍트), TM4(타겟사용자), TM5(성능, --full/--all), TM6(보안, --full/--all)

### 7.8 Spawn 절차

```
1. Stage 0 완료 후 팀 구성 확정
2. qa-data/ 수집 완료 확인
3. 각 Teammate를 병렬로 Spawn:
   - TM1~TM4: 동시 Spawn (기본 모드)
   - TM5~TM6: 추가 Spawn (--full/--all)
   - 동적 TM: 트리거 매치 시 추가 Spawn (--all)
4. 각 TM에게 전달:
   - 공통 템플릿 (Block 1-4)
   - 해당 TM의 역할/기준/데이터소스/산출물
   - 실행 모드에 따른 티어 범위
5. 모든 TM 완료 대기
```

---

## 8. 체크리스트 분배

### 8.1 카테고리-Teammate 매핑

| 카테고리 | 항목 범위 | 총 항목 | 담당 TM |
|:--------:|:---------:|:-------:|:-------:|
| A. 타이포그래피 | #1-#30 | 30 | TM1 |
| B. 레이아웃/간격 | #31-#55 | 25 | TM1 |
| C. 색상/대비 | #56-#80 | 25 | TM2 |
| D. 사용자 심리 | #81-#105 | 25 | TM2 |
| E. 마이크로인터랙션 | #106-#125 | 20 | TM3 |
| F. 시각적 계층 | #126-#140 | 15 | TM1 |
| G. 모바일 | #141-#155 | 15 | TM3 |
| H. 엣지케이스 | #156-#175 | 20 | TM3 |
| (동적) 사용자여정 | - | 가변 | TM4 |
| (성능) | - | 가변 | TM5* |
| (보안) | - | 가변 | TM6* |

### 8.2 Teammate별 티어 분포

| TM | 카테고리 | Tier 1 | Tier 2 | Tier 3 | 합계 |
|:--:|:--------:|:------:|:------:|:------:|:----:|
| TM1 | A,B,F | 12 | 38 | 20 | 70 |
| TM2 | C,D | 13 | 26 | 11 | 50 |
| TM3 | E,G,H | 10 | 23 | 22 | 55 |
| TM4 | 동적 | - | - | - | 가변 |
| **합계** | | **35** | **87** | **53** | **175** |

### 8.3 모드별 실행 범위

| 모드 | TM1 | TM2 | TM3 | TM4 | 총 항목 |
|:----:|:---:|:---:|:---:|:---:|:-------:|
| 기본 | 12 | 13 | 10 | 3-5 시나리오 | ~35 + 시나리오 |
| --full | 50 | 39 | 33 | 5-7 시나리오 | ~122 + 시나리오 |
| --all | 70 | 50 | 55 | 7-10 시나리오 | 175 + 시나리오 |

### 8.4 Tier 1 세부 (기본 모드, ~35항목)

| TM | 항목 번호 | 수 |
|:--:|----------|:--:|
| TM1 (A) | #1, #7, #19, #25 | 4 |
| TM1 (B) | #32, #35, #41, #46, #51, #54 | 6 |
| TM1 (F) | #126, #132 | 2 |
| TM2 (C) | #56, #61, #64, #67, #76 | 5 |
| TM2 (D) | #81, #88, #90, #91, #95, #98, #99, #100 | 8 |
| TM3 (E) | #106, #108, #112 | 3 |
| TM3 (G) | #141, #145, #147 | 3 |
| TM3 (H) | #156, #157, #158, #159 | 4 |

### 8.5 Tier 2 추가 (--full 모드, +87항목)

| TM | 카테고리 | 추가 항목 번호 |
|:--:|:--------:|-------------|
| TM1 | A | #2-#6, #8-#14 |
| TM1 | B | #33-#34, #36-#40, #42-#45, #48-#50, #52-#53, #55 |
| TM1 | F | #127-#131, #133-#134, #139-#140 |
| TM2 | C | #57-#60, #62-#63, #65-#66, #68 |
| TM2 | D | #82-#87, #89, #92-#94, #96-#97, #101-#105 |
| TM3 | E | #107, #109-#111, #113-#115 |
| TM3 | G | #142-#144, #146, #150-#152, #155 |
| TM3 | H | #160-#163, #169-#172 |

### 8.6 Tier 3 추가 (--all 모드, +53항목)

| TM | 카테고리 | 추가 항목 번호 |
|:--:|:--------:|-------------|
| TM1 | A | #15-#18, #20-#24, #26-#30 |
| TM1 | B | #31, #47 |
| TM2 | C | #69-#75, #77-#80 |
| TM2 | D | (없음) |
| TM3 | E | #116-#125 |
| TM3 | F | #135-#138 |
| TM3 | G | #148-#149, #153-#154 |
| TM3 | H | #164-#168, #173-#175 |

---

## 9. Stage 2: 병렬 전문가 분석

### 9.1 실행 규칙

```
1. 모든 Teammate는 동시에 Spawn되어 병렬 실행
2. 각 TM은 자기 담당 체크리스트만 평가 (교차 평가 금지)
3. qa-data/ 파일은 읽기만 가능, 수정 금지
4. 각 TM은 qa-reports/{자기파일}.md 에만 쓰기
5. 다른 TM의 qa-reports/ 파일 읽기 금지
6. 분석 중 추가 브라우저 조작 필요 시 → [추가수집필요] 마커로 표시
   (Lead가 Stage 3에서 보충 수집 가능)
```

### 9.2 Teammate 리포트 형식

각 Teammate는 다음 형식으로 `qa-reports/{자기파일}.md` 작성:

```markdown
# {역할명} 분석 리포트

## 메타데이터
- 분석자: {역할명}
- 담당 카테고리: {A,B,F 등}
- 실행 모드: {기본/--full/--all}
- 평가 항목 수: {N}
- 분석 완료 시각: {timestamp}

## 요약
- PASS: {N}개
- FAIL: {N}개 (Critical: {N}, Major: {N}, Minor: {N}, Suggestion: {N})
- 검증불가: {N}개

## Critical 이슈
| # | 항목 | 현재값 | 기준값 | 재현경로 | 수정 권장 |
|:-:|------|--------|--------|---------|----------|
| 1 | {항목번호+설명} | {값} | {값} | {경로} | {수정안} |

## Major 이슈
(동일 형식)

## Minor 이슈
(동일 형식)

## Suggestion
(동일 형식)

## PASS 항목
| # | 항목 | 현재값 | 기준값 | 검증 마커 |
|:-:|------|--------|--------|:---------:|
| 1 | {항목} | {값} | {값} | [검증됨] |

## 검증불가 항목
| # | 항목 | 사유 |
|:-:|------|------|
| 1 | {항목} | {데이터 미수집/스냅샷 없음 등} |

## 추가 수집 필요
- [추가수집필요] {필요한 데이터}: {이유}
```

### 9.3 통신 규칙

| 허용 | 금지 |
|------|------|
| qa-data/ 파일 읽기 | qa-data/ 파일 수정 |
| 자기 qa-reports/ 파일 쓰기 | 다른 TM의 qa-reports/ 파일 읽기/쓰기 |
| [추가수집필요] 마커 사용 | Playwright MCP 도구 직접 호출 |
| Read/Glob/Grep 도구 사용 | 브라우저 조작 시도 |

---

## 10. Stage 3: 리포트 통합 (Lead)

### 10.1 통합 절차

```
[Step 1] 모든 TM 완료 확인
- qa-reports/ 폴더에 예상된 파일 수 확인
- 각 파일의 "분석 완료 시각" 확인
- 미완료 TM 있으면 → 60초 추가 대기 후 재확인

[Step 2] 리포트 수집
- qa-reports/*.md (FINAL-REPORT 제외) 모두 읽기
- 각 TM의 요약 섹션에서 FAIL 카운트 추출

[Step 3] Critical 이슈 교차 검증
- 모든 Critical 이슈를 qa-data/ 원본 데이터와 대조
- 오탐(False Positive) 제거
- 심각도 재분류 (필요시 Major로 하향)

[Step 4] 중복 제거
- 여러 TM이 같은 요소에 대해 지적한 이슈 통합
- 예: TM1(시각) + TM2(대비) 가 같은 색상 지적 → 하나로 통합

[Step 5] 우선순위 정렬
- Critical → Major → Minor → Suggestion 순
- 같은 심각도 내에서 영향 범위(페이지 수) 순

[Step 6] 추가 수집 처리
- [추가수집필요] 마커가 있으면 Lead가 보충 데이터 수집
- 보충 후 해당 항목 재평가

[Step 7] FINAL-REPORT 생성
- qa-reports/FINAL-REPORT-{YYYYMMDD-HHMM}.md 작성

[Step 8] 이슈 디렉토리 생성
- FAIL 항목을 심각도별로 qa-issues/ 디렉토리에 분리
- 각 이슈에 대해 issue.md + metadata.json 생성
- 관련 스크린샷을 qa-data/screenshots/에서 복사
- _index.json 업데이트
- .gitignore에 qa-issues/ 추가 확인
```

---

## 11. 최종 리포트 템플릿

```markdown
# QA Agent-Teams 최종 리포트

## 메타데이터
| 항목 | 값 |
|------|-----|
| 대상 URL | {url} |
| 실행 모드 | {기본/--full/--all} |
| 실행 일시 | {YYYY-MM-DD HH:MM} |
| 팀 구성 | Lead + {N} Teammates |
| 총 평가 항목 | {N}개 |
| 분석 소요 시간 | {N}분 |

## 팀 구성
| TM | 역할 | 담당 | 평가 항목 | 결과 |
|:--:|------|------|:---------:|------|
| TM1 | UX+시각계층 | A,B,F | {N} | P:{N} F:{N} |
| TM2 | 접근성+심리 | C,D | {N} | P:{N} F:{N} |
| TM3 | 모바일+아키텍트 | E,G,H | {N} | P:{N} F:{N} |
| TM4 | 타겟사용자 | 시나리오 | {N} | P:{N} F:{N} |

## 종합 스코어
| 카테고리 | PASS | FAIL | 통과율 |
|:--------:|:----:|:----:|:------:|
| A. 타이포그래피 | {N} | {N} | {%} |
| B. 레이아웃/간격 | {N} | {N} | {%} |
| C. 색상/대비 | {N} | {N} | {%} |
| D. 사용자 심리 | {N} | {N} | {%} |
| E. 마이크로인터랙션 | {N} | {N} | {%} |
| F. 시각적 계층 | {N} | {N} | {%} |
| G. 모바일 | {N} | {N} | {%} |
| H. 엣지케이스 | {N} | {N} | {%} |
| **총계** | **{N}** | **{N}** | **{%}** |

## Critical 이슈 (즉시 수정 필요)

### C-{N}: {이슈 제목}
- **항목**: #{번호} - {체크리스트 항목명}
- **발견자**: {TM번호} ({역할})
- **현재값**: {실제 측정값}
- **기준값**: {기준}
- **재현 경로**: {페이지} → {요소} → {상태}
- **스크린샷**: `qa-data/screenshots/{파일}`
- **교차 검증**: [검증됨] Lead가 qa-data/ 원본으로 확인
- **수정 권장**:
  ```css
  /* 예시: CSS 수정 코드 */
  ```

## Major 이슈
(Critical과 동일 형식, 번호는 M-{N})

## Minor 이슈
(간략 형식)
| # | 항목 | 현재값 | 기준값 | 수정 권장 |
|:-:|------|--------|--------|----------|

## Suggestion
(간략 형식, 동일 테이블)

## 타겟 사용자 시나리오 결과
(TM4 리포트에서 가져옴)

### 시나리오 1: {시나리오명}
- **결과**: 성공 / 부분성공 / 실패
- **이탈 지점**: {페이지/단계}
- **개선 제안**: {내용}

## 검증불가 항목
| # | 항목 | 사유 | 담당 TM |
|:-:|------|------|:-------:|

## 개선 우선순위 요약

### 즉시 수정 (Critical)
1. {이슈 1줄 요약}
2. ...

### 단기 개선 (Major)
1. {이슈 1줄 요약}
2. ...

### 중기 개선 (Minor + Suggestion)
1. {이슈 1줄 요약}
2. ...

---
*Generated by playwright-qa-agent-teams | {YYYY-MM-DD HH:MM}*
*Team: Lead + {N} Teammates | Mode: {mode} | Items: {N}*
```

---

## 12. 에러 핸들링 & Fallback

### 12.1 Teammate 실패 시

| 실패 유형 | 대처 |
|----------|------|
| TM Spawn 실패 | Lead가 해당 역할을 직접 수행 (단일 에이전트 방식) |
| TM 분석 중 에러 | Lead가 qa-reports/{tm}.md 확인 → 미완료 항목만 보충 |
| TM 리포트 미생성 | Lead가 해당 카테고리를 qa-data/ 기반으로 직접 평가 |
| TM 분석 품질 부족 | Lead가 리포트를 검토하여 Critical 이슈 보강 |

### 12.2 부분 실패 시 리포트

```markdown
## 팀 실행 상태
| TM | 상태 | 비고 |
|:--:|:----:|------|
| TM1 | 완료 | - |
| TM2 | 실패 | Lead가 대체 수행 |
| TM3 | 완료 | - |
| TM4 | 부분완료 | 시나리오 3/5만 수행 |
```

### 12.3 전체 Fallback (agent-teams 불가)

```
조건: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 미설정
      또는 Teammate Spawn 전체 실패

대처:
1. 사용자에게 안내:
   "Agent-teams 환경이 감지되지 않습니다.
    단일 에이전트 모드(/playwright-qa-expert)로 전환하시겠습니까?"
2. 사용자 승인 시 → /playwright-qa-expert 실행
3. 동일한 체크리스트, 동일한 175항목 커버
4. 단, 순차 실행이므로 소요 시간 증가
```

---

## 13. 환각 방지 프로토콜 (멀티 에이전트)

### 13.1 핵심 원칙: Read Before Write

| 단계 | 행동 | 금지 |
|:----:|------|------|
| 1 | qa-data/ 파일에서 **실제 값**을 읽은 후 판정 | 추정으로 PASS/FAIL 금지 |
| 2 | CSS 값은 **JSON 파일에서 복사** | 기억에 의존한 값 금지 |
| 3 | 요소 참조 시 **스냅샷의 실제 ref** 사용 | 추정 ref 금지 |
| 4 | 스크린샷 참조 시 **실제 파일명** 확인 | 존재하지 않는 파일 금지 |

### 13.2 검증 마커 체계

| 마커 | 의미 | 사용 시점 |
|------|------|----------|
| `[검증됨]` | qa-data/ 파일에서 확인 | 수치 기반 PASS/FAIL |
| `[스냅샷확인]` | 접근성 스냅샷에서 확인 | 구조/속성 기반 판정 |
| `[스크린샷확인]` | 스크린샷 시각 확인 | 시각적 판정 |
| `[추정]` | 데이터 불완전, 패턴 기반 추측 | 직접 데이터 없을 때 |
| `[검증불가]` | 데이터 미수집 | 해당 데이터 없을 때 |
| `[추가수집필요]` | 추가 브라우저 조작 필요 | Lead 보충 수집 요청 |

### 13.3 심각도별 검증 요구

| 심각도 | 필수 마커 | 최소 데이터 |
|:------:|:---------:|------------|
| Critical | `[검증됨]` 필수 | CSS값 + 스냅샷 ref + 기준값 |
| Major | `[검증됨]` 또는 `[스냅샷확인]` | 스냅샷 ref + 기준값 |
| Minor | `[스냅샷확인]` 이상 | 스냅샷 또는 스크린샷 |
| Suggestion | `[추정]` 허용 | 패턴 관찰 기반 |

### 13.4 Lead 교차 검증 (Stage 3)

```
Critical 이슈 교차 검증 절차:
1. TM 리포트에서 Critical 이슈 추출
2. 해당 이슈의 "현재값"을 qa-data/ 원본에서 직접 확인
3. 원본과 불일치 시 → 심각도 하향 또는 제거
4. 일치 확인 시 → [교차검증됨] 마커 추가
```

---

## 14. 리포트 비교 & 카테고리별 실행

### 14.1 이전 리포트 비교

```
조건: qa-reports/ 에 이전 FINAL-REPORT 파일 존재

비교 절차:
1. 이전 FINAL-REPORT-{이전timestamp}.md 읽기
2. 현재 리포트와 항목별 비교
3. 변화 요약 추가:

## 이전 리포트 대비 변화
| 항목 | 이전 | 현재 | 변화 |
|------|:----:|:----:|:----:|
| Critical | {N} | {N} | {+/-N} |
| Major | {N} | {N} | {+/-N} |
| 총 통과율 | {%} | {%} | {+/-pp} |

### 해결된 이슈
- {이전에 FAIL이었으나 현재 PASS인 항목}

### 신규 이슈
- {이전에 없었으나 현재 FAIL인 항목}

### 미해결 이슈
- {이전과 동일하게 FAIL인 항목}
```

### 14.2 카테고리별 실행 (--category 옵션)

| 카테고리명 | 항목 범위 | Teammate |
|:----------:|:---------:|:--------:|
| typography | A (#1-#30) | TM1 |
| layout | B (#31-#55) | TM1 |
| color | C (#56-#80) | TM2 |
| psychology | D (#81-#105) | TM2 |
| interaction | E (#106-#125) | TM3 |
| hierarchy | F (#126-#140) | TM1 |
| mobile | G (#141-#155) | TM3 |
| edge-cases | H (#156-#175) | TM3 |
| a11y | C + 접근성 관련 교차 항목 | TM2 |

### 14.3 카테고리 모드 실행 규칙

```
1. --category=<name> 지정 시:
   - 해당 카테고리 담당 TM만 Spawn (1-2명)
   - Lead 데이터 수집도 해당 카테고리에 초점
   - TM4(페르소나)는 선택적 (2개+ 카테고리 시 Spawn)

2. 접근성(a11y) 카테고리:
   - C 카테고리 전체
   - + 다른 카테고리의 접근성 관련 항목 (포커스, ARIA 등)
   - TM2가 담당

3. 복수 카테고리:
   - --category=typography,color 형태로 지정
   - 관련 TM 모두 Spawn
```

---

## 15. 체크리스트 소스 참조

> 175개 체크리스트의 상세 내용은 공유 디렉토리의 원본을 참조합니다.
> **원본 위치**: `~/.claude/skills/_core/qa/checklist-175.md`
>
> **Lead 지시**: 각 TM Spawn 시, 해당 TM의 담당 카테고리 항목을
> checklist-175.md에서 Read하여 Spawn 프롬프트의 Block 3에 삽입하세요.
> 예: TM1(A,B,F 카테고리) → A. 타이포그래피, B. 간격&레이아웃, F. 시각적 계층 항목 추출

### 15.1 스니펫 참조

12개 browser_evaluate CSS 스니펫(T-1 ~ A-1)은 `playwright-qa-expert/references/css-snippets.md`에 정의.
Lead가 Stage 1 데이터 수집 시 해당 스니펫을 Read하여 사용합니다.

---

## 16. 단일 에이전트 vs Agent-Teams 비교

| 항목 | playwright-qa-expert | playwright-qa-agent-teams |
|------|:-------------------:|:------------------------:|
| 전문가 수 | 6명 (순차 롤플레이) | 4-8명 (병렬 독립 실행) |
| 컨텍스트 | 1개 공유 | 팀원별 독립 1M |
| 브라우저 | 직접 조작 | Lead만 조작 |
| 실행 시간 (기본) | 10-15분 | 7-10분 |
| 실행 시간 (--full) | 30-45분 | 15-25분 |
| 비용 | 1x | ~3-5x |
| 리포트 품질 | 후반부 감소 가능 | 균일한 품질 |
| Fallback | - | 단일 에이전트로 전환 |
| 추천 상황 | 빠른 검수, 비용 절약 | 철저한 검수, 시간 절약 |

---

## 17. 행동 채택 표준

> 역할 채택 신호(Signal 1-3), 출력 형식([A][B][C]), 역할 전환/참조 체계는
> 공유 파일을 참조합니다: [~/.claude/skills/_core/qa/behavioral-signals.md](~/.claude/skills/_core/qa/behavioral-signals.md)
>
> **Agent-Teams 특이사항**:
> - 각 TM은 고정 역할 유지 (전환 프로토콜은 단일 에이전트 전용)
> - TM 실패 시 Lead가 Fallback 역할 수행 (12 에러 핸들링 참조)
> - 크로스 도메인 이슈 발견 시 `[TM{N} 참고]` 마커로 표시, Lead가 통합 시 연결

---

## 18. 10단계 파이프라인 View (인사이트 1 매핑, 2026-05-25 P2-4b 추가)

> 본 스킬은 Agent-Teams Hybrid Pattern — Lead(Playwright 데이터 수집) + 4-8 TM(병렬 분석). 3 tier (basic ~35 / --full ~120 / --all 175 items).

| Step | 인사이트 1 단계 | 본 스킬 매핑 |
|:-:|---|---|
| 1 | Input Normalizer | URL + tier(basic/full/all) + scope |
| 2 | Intent Classifier | 테스트 유형 (smoke / regression / E2E / visual / a11y) |
| 3 | **Task Router (강함)** | Lead가 Playwright 데이터 수집 후 4-8 TM 분배 (도메인별) |
| 4 | Context Builder | Lead의 audit-data/ — DOM 트리 + 네트워크 + 콘솔 + 스크린샷 |
| 5 | Planner | 각 TM별 검사 체크리스트 (tier에 따라 35/120/175 항목) |
| 6 | **Tool Executor (강함)** | Lead: `mcp__claude-in-chrome__*` 우선 (Uncompromising Rigor §1) / TM: 분석 |
| 7 | Draft Generator | 각 TM 보고서 (병렬 작성) |
| 8 | Critic / Verifier | Lead 통합 + 재현성 확인 (Uncompromising Rigor §4) |
| 9 | Refiner | 우선순위 정렬 (Uncompromising Rigor §3 — 사용자 명시 강등만 Low) |
| 10 | Output Renderer | 통합 QA 리포트 + 이슈 추적 metadata.json |

### 확립 패턴 (P1-5) — Hybrid Pattern 특화

playwright-qa-expert(P1-5)와 동일 framing. 본 스킬은 Agent-Teams 모드만 작동 (단일 모드는 playwright-qa-expert).

> **참조**: 인사이트 1 — `.thoughts/2026-05-25-harness-insights-round1.md` / 회고 — `.thoughts/2026-05-25-harness-application-completed.md`
