---
name: playwright-qa-expert
description: |
  QA testing using Playwright MCP tools with multi-expert panel analysis.
  Use when asked to "test this page", "QA test", "check UI bugs", "test website",
  "run QA checks", "QA 테스트", "버그 확인", or "웹 테스트".
  Supports 3 tiers: basic (~30), --full (~80), --all (175 items).
  Routes to agent-teams when AGENT_TEAMS=1, to uiux-audit with --audit flag.
---

## ⚠️ Uncompromising Rigor (글로벌 룰 강제 적용)

이 스킬은 `~/.claude/rules/uncompromising-rigor.md` 의 4개 정책을 **무조건 준수**한다:

1. **Browser Tool Priority** — 브라우저 우선순위는 `rules/uncompromising-rigor` §1(2026-07-07 Playwright MCP 전역 우선)을 따른다. 로그인 세션 재사용이 필요할 때만 `mcp__claude-in-chrome__*`를 쓴다.
2. **Self-Justification Red Flags** — "이 정도면 충분" / "사소함" / "사용자가 신경 안 씀" / "베타니까 OK" / "fetch 진행 중이라 정상" 등장 시 **즉시 자기 차단**
3. **All Findings Are Defects** — 모든 발견은 결함. 사용자가 명시적으로 "강등"한 것만 Low
4. **Per-Round Deep Analysis** — 매 라운드 5단계 심층 분석 강제 (이전 재조회 → 미세 재스캔 → Adversarial walk → 자기 정당화 자가 검증 → 신규+재현성)
> 이 스킬 이름의 "playwright"는 legacy 명칭 — 브라우저 우선순위는 `rules/uncompromising-rigor` §1(2026-07-07 Playwright MCP 전역 우선)을 따른다.

---

# Playwright QA Expert

> **핵심 철학**: "다양한 전문가의 눈으로 직접 보고, 직접 확인한 것만 보고한다"
> **버전**: v2 - 확장 가능한 전문가 패널 + 필수 타겟 사용자 페르소나

## 목차
- [1. 실행 모드](#1-실행-모드)
- [2. 핵심 원칙](#2-핵심-원칙)
- [3. 전문가 패널 구조](#3-전문가-패널-구조)
- [4. 테스트 실행 워크플로우](#4-테스트-실행-워크플로우)
- [5. 기본 전문가 상세 정의](#5-기본-전문가-상세-정의)
- [6. 타겟 사용자 페르소나 시스템](#6-타겟-사용자-페르소나-시스템)
- [7. 자동 전문가 선택 알고리즘](#7-자동-전문가-선택-알고리즘)
- [7.5. 체크리스트 실행 티어](#75-체크리스트-실행-티어-시스템)
- [8. Ultra-Detail UI/UX 체크리스트](#8-ultra-detail-uiux-체크리스트-175항목)
- [9. 환각 방지 프로토콜](#9-환각-방지-프로토콜)
- [10. 테스트 리포트 형식](#10-테스트-리포트-형식)
- [11. 사용 예시](#11-사용-예시)
- [12. browser_evaluate CSS 검증 스니펫](#12-browser_evaluate-css-검증-스니펫)
- [13. 에러 핸들링 & 재시도 가이드](#13-에러-핸들링--재시도-가이드)
- [14. 리포트 비교 기능](#14-리포트-비교-기능)
- [15. 카테고리별 실행](#15-카테고리별-실행)
- [16. 행동 채택 표준](#16-행동-채택-표준)

---

## 1. 실행 모드

| 모드 | 명령어 | 설명 |
|:----:|--------|------|
| **기본** | `/playwright-qa-expert` | UI/UX 다중 전문가 심층 테스트 (Tier 1 ~30항목) |
| **전체** | `/playwright-qa-expert --full` | 6개 관점 통합 QA 테스트 (Tier 1+2 ~80항목) |
| **완전** | `/playwright-qa-expert --all` | 175개 전체 항목 완전 검사 (Tier 1+2+3) |
| **카테고리** | `/playwright-qa-expert --category=<name>` | 특정 카테고리만 집중 테스트 |
| **UI/UX 감사** | `/playwright-qa-expert --audit` | → playwright-uiux-audit 라우팅 (360항목) |
| **미리보기 생략** | `/playwright-qa-expert --skip-preview` | QA 시트 미리보기 단계를 건너뛰고 즉시 실행 |
| **조용한 모드** | `/playwright-qa-expert --quiet` | 중간 보고 시 Critical만 표시 |
| **이슈 재검증** | `/playwright-qa-expert --verify <ID>` | 특정 이슈만 재검증 (예: --verify CRIT-001) |
| **전체 재검증** | `/playwright-qa-expert --verify-all <심각도>` | 해당 심각도 이슈 전체 재검증 |

### 1.2 자동 모드 선택 (라우팅)

```
/playwright-qa-expert [옵션]
  ↓
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1?
  ├─ Yes + --audit → playwright-uiux-audit (18명 3-Wave, 360항목)
  ├─ Yes           → playwright-qa-agent-teams (4-8명 팀, 175항목)
  └─ No            → 이 스킬 단일 에이전트 모드 (6명 롤플레이)
```

**스킬 간 역할 분담:**

| 스킬 | 역할 | 체크리스트 | 에이전트 |
|:----:|------|:----------:|:--------:|
| **playwright-qa-expert** | QA 진입점 + 단일 에이전트 엔진 | 175항목 (원본) | 1 (6명 롤플레이) |
| **playwright-qa-agent-teams** | 팀 실행 엔진 | qa-expert 참조 | 4-8명 독립 |
| **playwright-uiux-audit** | UI/UX 심층 감사 | 360항목 (독자) | 18명 3-Wave |

---

## 2. 핵심 원칙

1. **직접 검증 (Read Before Report)**: 스크린샷/스냅샷으로 확인한 것만 보고
2. **다중 전문가 롤플레잉**: 각 관점별 전문가 페르소나 채택
3. **확장 가능한 전문가 패널**: 기본 6명 + 프로젝트별 동적 추가 가능 (최대 3명)
4. **필수 타겟 사용자 페르소나**: 프로젝트별 맞춤 사용자 관점 필수 포함
5. **상세 리포트**: 스크린샷 + 검증 마커 필수

---

## 3. 전문가 패널 구조

```
┌─────────────────────────────────────────────────────────────┐
│               전문가 패널 구조 (확장 가능)                    │
├─────────────────────────────────────────────────────────────┤
│  기본 전문가 (5명) - 항상 포함                               │
│  ├─ UX 디자이너 (10년차)                                    │
│  ├─ 프론트엔드 아키텍트                                     │
│  ├─ 접근성 전문가 (WCAG 인증)                               │
│  ├─ 사용자 심리학자                                         │
│  └─ 모바일 UX 전문가                                        │
├─────────────────────────────────────────────────────────────┤
│  필수 타겟 사용자 (1명) - 항상 포함                          │
│  └─ 프로젝트 타겟 사용자 (자동 페르소나 생성)               │
├─────────────────────────────────────────────────────────────┤
│  추가 전문가 (동적 확장) - 프로젝트별 선택적 (최대 3명)      │
│  ├─ 국제화(i18n) 전문가                                     │
│  ├─ 성능 최적화 전문가                                      │
│  ├─ 시각 디자이너                                           │
│  ├─ 콘텐츠 전략가                                           │
│  ├─ 게이미피케이션 전문가                                   │
│  ├─ 이커머스 UX 전문가                                      │
│  ├─ 대시보드/데이터 시각화 전문가                           │
│  └─ SaaS UX 전문가                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. 테스트 실행 워크플로우

### 4.1 기본 모드 워크플로우

```
[0단계] 프로젝트 분석 및 준비
├─ 프로젝트 도메인 파악 (Glob/Grep으로 시그널 탐지)
├─ 타겟 사용자 페르소나 자동 생성
├─ 추가 전문가 필요 여부 판단 (100점 기준, 70점 이상 시 추가)
└─ 테스트 URL 및 범위 확인

[0.5단계] QA 시트 미리보기 및 승인 (--skip-preview 시 건너뜀)
├─ 0단계 결과 기반으로 선택된 체크리스트 항목 요약 테이블 출력:
│   "## QA 시트 미리보기
│    ### 프로젝트 분석 결과
│    - 도메인: {감지된 도메인}
│    - 기술 스택: {감지된 스택}
│    ### 선택된 체크리스트 ({N}개 항목)
│    | 카테고리 | 항목 수 | 포함 이유 |
│    | A. 타이포그래피 | 4 | Tier 1 기본 |
│    | ... | ... | ... |
│    ### 선택된 전문가 패널
│    | 역할 | 담당 | 추가 이유 |
│    예상 소요 시간: ~{N}분"
├─ 사용자에게 조정 기회 제공:
│   - "진행" / Enter → 1단계로 이동
│   - "모바일 빼줘" → G 카테고리 제거 후 재출력
│   - "성능도 추가해줘" → TM5 성능 항목 추가
│   - 커스텀 항목 추가 가능 (예: "결제 폼 제출 테스트")
└─ 최종 확정된 QA 시트를 기반으로 1단계 진행

[1단계] 초기 탐색
├─ browser_navigate → 테스트 URL 접속
├─ browser_snapshot → 초기 페이지 구조 파악
└─ browser_take_screenshot → 초기 상태 캡처

[2단계] 전문가별 순차 테스트 + 중간 보고
├─ [UX 디자이너] 체크리스트 7개 항목
│   └─ 📊 중간보고 출력: "UX 디자이너 완료 (1/N): Critical {N}, Major {N}"
├─ [프론트엔드 아키텍트] 체크리스트 7개 항목
│   └─ 📊 중간보고 출력
├─ [접근성 전문가] 체크리스트 7개 항목
│   └─ 📊 중간보고 출력 (Critical 발견 시 즉시 강조)
├─ [사용자 심리학자] 체크리스트 7개 항목
│   └─ 📊 중간보고 출력
├─ [모바일 UX 전문가] 체크리스트 7개 항목 (뷰포트 리사이즈 포함)
│   └─ 📊 중간보고 출력
├─ [타겟 사용자 페르소나] 핵심 시나리오 테스트
│   └─ 📊 중간보고 출력
├─ [추가 전문가들] 해당 시 체크리스트 실행
│
│ 중간보고 형식:
│ "---
│  ## 중간 진행 상황 ({완료}/{전체} 전문가)
│  | 전문가 | 상태 | Critical | Major | Minor |
│  | UX 디자이너 | 완료 | 1 | 2 | 3 |
│  | 접근성 전문가 | 진행중... | - | - | - |
│  지금까지 Critical: {이슈 1줄 요약}
│  ---"
│
└─ --quiet 옵션: Critical만 즉시 보고, 나머지는 최종 리포트에서

[3단계] Ultra-Detail UI/UX 검사 (Tier 1 핵심 항목 ~30개)
├─ 🔴 Tier 1 항목만 실행 (--full은 Tier 1+2, --all은 전체 175개)
├─ A. 타이포그래피 → 핵심 4개 (본문크기, iOS줌방지, 행간, 문단너비)
├─ B. 간격 & 레이아웃 → 핵심 4개 (패딩, 페이지여백, 그리드, 콘텐츠너비)
├─ C. 색상 & 대비 → 핵심 4개 (텍스트대비, 포커스대비, 브랜드일관성, 호버)
├─ D. 사용자 심리학 → 핵심 5개 (근접성, Miller's Law, Fitts's Law, 피드백, 어포던스)
├─ E. 마이크로 인터랙션 → 핵심 3개 (호버, 포커스, 로딩상태)
├─ F. 시각적 계층 → 핵심 2개 (크기계층, 버튼스타일)
├─ G. 모바일 특화 → 핵심 3개 (터치타겟, 줌방지, 뷰포트)
└─ H. 엣지케이스 → 핵심 4개 (긴텍스트, 빈상태, 에러상태, 로딩상태)

[4단계] 이슈 정리 및 리포트 생성
├─ 심각도별 분류 (Critical/Major/Minor/Suggestion)
├─ 전문가별 총평 작성
├─ 스크린샷 포함 상세 리포트 출력
└─ qa-issues/ 디렉토리에 이슈별 독립 파일 생성 (섹션 17 참조)
```

### 4.2 전체 모드 (--full) 워크플로우

```
[0단계] 프로젝트 분석 및 페르소나 생성 (기본 모드와 동일)

[1단계] 기능 테스트 (QA 엔지니어 관점)
├─ 핵심 사용자 시나리오 실행
├─ 폼 제출, 데이터 CRUD 동작 확인
├─ 경계값 및 잘못된 입력 테스트
└─ browser_console_messages로 에러 모니터링

[2단계] UI/UX 테스트 (확장 전문가 패널)
├─ 기본 5명 전문가 순차 검토
├─ Ultra-Detail Tier 1+2 항목 검사 (~80개)
├─ (--all 모드 시 Tier 3 포함 전체 175항목)
└─ 발견 이슈 심각도 분류

[3단계] 타겟 사용자 테스트 (필수)
├─ 페르소나 기반 핵심 시나리오 실행
├─ "실제 사용자라면" 관점에서 평가
├─ 기대-현실 갭 분석
└─ 경쟁 서비스 대비 경험 수준 평가

[4단계] 접근성 테스트 (a11y 전문가)
├─ 키보드 전용 네비게이션 (browser_press_key Tab)
├─ 접근성 스냅샷 트리 분석
├─ 포커스 순서 및 트랩 확인
└─ WCAG 2.1 AA 기준 검증

[5단계] 성능 테스트 (성능 엔지니어)
├─ 페이지 로드 시간 측정
├─ browser_network_requests로 요청 분석
├─ 큰 데이터셋 렌더링 성능
└─ 메모리 누수 징후 확인

[6단계] 보안 테스트 (보안 분석가)
├─ XSS 벡터 입력 테스트
├─ 인증 없이 보호된 경로 접근 시도
├─ 민감 정보 노출 확인 (콘솔, 네트워크)
└─ HTTPS 리다이렉트 확인
```

---

## 5. 기본 전문가 상세 정의 (Progressive Disclosure)

> 전문가 상세 정의는 [references/expert-definitions.md](references/expert-definitions.md) 참조.
> 전문가 spawn 시 해당 파일을 Read하여 역할 정의 로드.

## 6. 타겟 사용자 페르소나 시스템

### 6.1 자동 생성 프로세스

```
[Step 1] 프로젝트 분석
├─ 프로젝트 도메인 파악 (예: 프롬프트 관리 도구)
├─ 주요 기능/페이지 식별
└─ CLAUDE.md / README.md 분석

[Step 2] 타겟 사용자 유형 도출
├─ prompt-vault → "프롬프트를 자주 사용하는 AI 개발자"
├─ 쇼핑몰 → "30대 직장인, 모바일 구매 선호"
├─ B2B SaaS → "IT팀 매니저, 효율성 중시"
└─ 게임 대시보드 → "데이터 분석이 필요한 게임 기획자"

[Step 3] 페르소나 상세 정의
├─ 이름, 직업, 기술 수준
├─ 주요 사용 시나리오
├─ 기대치와 불편 포인트
└─ 사용 환경 (기기, 시간대, 컨텍스트)

[Step 4] 사용자 관점 테스트 체크리스트 생성
├─ 해당 사용자가 가장 자주 수행하는 작업
├─ 해당 사용자가 겪을 수 있는 frustration point
└─ 해당 사용자의 성공 기준
```

### 6.2 페르소나 템플릿

```markdown
## 타겟 사용자 페르소나

### 기본 정보
| 항목 | 내용 |
|------|------|
| **페르소나명** | [예: 김개발] |
| **직업/역할** | [예: AI 스타트업 백엔드 개발자] |
| **기술 수준** | [초급/중급/고급] |
| **주 사용 기기** | [데스크톱/모바일/태블릿] |

### 사용 컨텍스트
- **사용 시나리오**: [언제, 왜 이 서비스를 사용하는가]
- **핵심 목표**: [이 서비스로 달성하려는 것]
- **시간 제약**: [얼마나 빠르게 작업을 완료해야 하는가]

### 기대와 불편
- **기대하는 것**: [원하는 경험]
- **불편해할 것**: [짜증나게 할 요소들]
- **대안 서비스**: [현재 사용 중인 대안/경쟁 서비스]

### 핵심 질문
> "이 사용자가 [주요 목표]를 달성하는 데 걸리는 시간과 노력은 적절한가?"
```

### 6.3 타겟 사용자 체크리스트 (동적 생성)

| # | 항목 | Playwright 도구 | 평가 기준 |
|:-:|------|----------------|----------|
| 1 | 핵심 작업 완료 가능 | 시나리오 테스트 | 목표 달성 여부 |
| 2 | 첫 방문 온보딩 명확 | 초기 진입 테스트 | 시작 방법 이해 |
| 3 | 자주 사용 기능 접근성 | 반복 작업 테스트 | 클릭 수 최소 |
| 4 | 에러 시 복구 용이 | 실패 시나리오 | 막다른 길 없음 |
| 5 | 기대 시간 내 완료 | 작업 시간 측정 | 사용자 인내 범위 |
| 6 | [프로젝트별 맞춤 항목] | - | - |
| 7 | [프로젝트별 맞춤 항목] | - | - |

---

## 7. 자동 전문가 선택 알고리즘 (Progressive Disclosure)

> 3단계 분석 프로세스, 전문가별 트리거 조건(100점 만점), 시그널 매칭은
> [references/expert-selection.md](references/expert-selection.md) 참조.
> 프로젝트 분석 시 해당 파일을 Read하여 전문가 선택.


---

## 7.5. 체크리스트 실행 티어 (Checklist Execution Tiers)

> 175개 항목을 한 세션에서 모두 실행하는 것은 비현실적이므로, 3단계 티어로 분류하여 모드별 실행

### 모드-티어 매핑

| 모드 | 실행 티어 | 항목 수 | 예상 시간 | 적합한 상황 |
|:----:|:---------:|:-------:|:---------:|------------|
| 기본 (`/playwright-qa-expert`) | 🔴 Tier 1 | ~35개 | 10-15분 | 빠른 품질 확인, MVP 검증 |
| 전체 (`--full`) | 🔴 Tier 1 + 🟡 Tier 2 | ~85개 | 30-45분 | 릴리즈 전 종합 검수 |
| 완전 (`--all`) | 🔴🟡🔵 전체 | 175개 | 60-90분 | 최초 런칭, 대규모 리팩토링 후 |

> 🔴 Tier 1 / 🟡 Tier 2 / 🔵 Tier 3 **카테고리별 항목 번호 상세 분해표**는 [references/checklists-tiers.md](references/checklists-tiers.md) 참조. (위 모드-티어 매핑은 본문 유지)

## 8. UI/UX 체크리스트 (Progressive Disclosure)

> 175항목 전체 체크리스트는 [references/checklist-full.md](references/checklist-full.md) 참조.
> 모드별 해당 Tier 항목만 로드.

## 9. 환각 방지 프로토콜

### 9.1 핵심 원칙: "직접 본 것만 보고"

| 단계 | 필수 행동 | 금지 |
|:----:|----------|------|
| 1 | UI 언급 전 `browser_snapshot` 실행 | 기억 의존 |
| 2 | 에러 보고 전 `browser_console_messages` 확인 | 추정 |
| 3 | 네트워크 이슈는 `browser_network_requests` | 가정 |
| 4 | 클릭 결과는 스냅샷으로 확인 | 예상 동작 기술 |
| 5 | 사용자 관점 발언은 페르소나 기반 | 일반화 |

### 9.2 검증 마커 시스템

| 마커 | 의미 | 사용 시점 |
|------|------|----------|
| `[스크린샷]` | 화면 캡처로 확인 | UI 요소 언급 시 |
| `[스냅샷]` | 접근성 트리로 확인 | 구조/계층 설명 시 |
| `[콘솔확인]` | 콘솔 메시지 확인 | 에러/경고 보고 시 |
| `[네트워크확인]` | 네트워크 탭 확인 | API 관련 이슈 |
| `[직접테스트]` | 클릭/입력 등 실행 | 동작 설명 시 |
| `[페르소나관점]` | 타겟 사용자 페르소나 기반 | 사용자 경험 평가 시 |

---

## 10. 테스트 리포트 형식 (Progressive Disclosure)

> 리포트 템플릿 + 비교 기능은 [references/report-templates.md](references/report-templates.md) 참조.

## 11. 사용 예시

### 기본 모드 실행 (Tier 1 ~30항목)
```
/playwright-qa-expert
```
→ 프로젝트 분석 → 페르소나 생성 → Tier 1 핵심 항목 검사 → 상세 리포트 (10-15분)

### 전체 모드 실행 (Tier 1+2 ~80항목)
```
/playwright-qa-expert --full
```
→ 6개 관점 통합 테스트 + Tier 1+2 항목 검사 (30-45분)

### 완전 모드 실행 (175개 전체 항목)
```
/playwright-qa-expert --all
```
→ 175개 전체 Ultra-Detail 항목 완전 검사 (60-90분)

### URL 직접 지정
```
/playwright-qa-expert https://example.com
/playwright-qa-expert --full https://example.com
/playwright-qa-expert --all https://example.com
```
→ 지정 URL에 대해 선택한 모드로 테스트 실행

### 모드 선택 의사결정 트리

```
시작: 어떤 모드를 사용할까?
│
├─ Q1. 시간이 15분 이내인가?
│   ├─ YES → 🟢 기본 모드 (/playwright-qa-expert)
│   └─ NO ↓
│
├─ Q2. 특정 카테고리만 확인하면 되는가?
│   ├─ YES → 🟢 기본 모드 + --category 옵션
│   │        (예: --category=a11y, --category=mobile)
│   └─ NO ↓
│
├─ Q3. 릴리즈/배포 전 종합 검수인가?
│   ├─ YES → 🟡 전체 모드 (--full)
│   └─ NO ↓
│
├─ Q4. 외부 감사/규정 준수/최종 감수인가?
│   ├─ YES → 🔴 완전 모드 (--all)
│   └─ NO ↓
│
└─ 기본값 → 🟢 기본 모드
```

#### 상황별 추천 모드

| 상황 | 추천 모드 | Tier | 항목 수 | 소요 시간 |
|------|:---------:|:----:|:-------:|:---------:|
| MVP/프로토타입 빠른 확인 | 기본 | 1 | ~35개 | 10-15분 |
| 일상적 개발 후 검증 | 기본 | 1 | ~35개 | 10-15분 |
| CI/CD 파이프라인 통합 | 기본 | 1 | ~35개 | 10-15분 |
| 스프린트 종료 QA | --full | 1+2 | ~80개 | 30-45분 |
| 주요 릴리즈 전 검수 | --full | 1+2 | ~80개 | 30-45분 |
| 리팩토링 후 회귀 테스트 | --full | 1+2 | ~80개 | 30-45분 |
| 최종 감수/외부 감사 | --all | 1+2+3 | 175개 | 60-90분 |
| WCAG 인증 대비 | --all | 1+2+3 | 175개 | 60-90분 |
| 디자인 시스템 구축 검증 | --all | 1+2+3 | 175개 | 60-90분 |

---

## 12. CSS 검증 스니펫 (Progressive Disclosure)

> CSS 검증 스니펫은 [references/css-snippets.md](references/css-snippets.md) 참조.
> browser_evaluate 실행 시 해당 파일을 Read.

## 13. 에러 핸들링 & 재시도 가이드 (Progressive Disclosure)

> 도구별 실패 대응 전략, 재시도 프로토콜, Graceful Degradation 전략,
> 검증 불가 항목 리포트 형식은 [references/error-handling.md](references/error-handling.md) 참조.


---

## 15. 카테고리별 실행 (Progressive Disclosure)

> `--category` 옵션 사용법, 카테고리 매핑(9개 + a11y 교차), 복수 카테고리 실행,
> 실행 규칙은 [references/category-execution.md](references/category-execution.md) 참조.


---

> **최종 원칙**: "다양한 전문가의 눈으로 직접 보고, 직접 확인한 것만 보고한다"

---

## 16. 행동 채택 표준

> 역할 채택 신호(Signal 1-3), 출력 형식([A][B][C]), 전환 프로토콜, 스킬 간 역할 참조 체계는
> 공유 파일을 참조합니다: `${CLAUDE_PLUGIN_ROOT}/skills/_core/qa/behavioral-signals.md`
>
> 이 파일은 playwright-qa-expert, playwright-qa-agent-teams, playwright-uiux-audit 3개 스킬이
> 공유하는 Single Source of Truth입니다.
>
> **실행 시**: 전문가 역할 전환/채택 시 해당 파일을 Read하여 Signal 1-3과 [A][B][C] 형식을 적용하세요.

---

## 17. 이슈 추적 시스템 (Progressive Disclosure)

> 이슈별 디렉토리 구조, metadata.json 스키마, 상태 전이, 재검증 워크플로우(--verify),
> _index.json은 [references/issue-tracking.md](references/issue-tracking.md) 참조.


---

> **_core 참조**: 전문가 역할은 `${CLAUDE_PLUGIN_ROOT}/skills/_core/roles.md`,
> 환각 방지 프로토콜은 `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md` 참조.

---

## 18. 10단계 파이프라인 View (인사이트 1 매핑, 2026-05-25 P1-5 추가)

> QA 작업의 보편 원리를 인사이트 1(CLI LLM 하네스 10단계)과 매핑한 명시적 framing. 기존 본문 변경 없이 View만 추가. **playwright-qa-expert 가 대표 패턴** — 나머지 3개 playwright-* 는 P2에서 동일 패턴 적용.

### QA 파이프라인 10단계 매핑

| Step | 인사이트 1 단계 | QA 매핑 | 출력 계약 |
|:-:|---|---|---|
| **1** | Input Normalizer | URL / 페이지 / 테스트 대상 정규화 | `{ target_url, scope, mode }` |
| **2** | Intent Classifier | 테스트 유형 분류 (Smoke / Regression / E2E / Visual / A11y / Performance) | `{ test_type, priority }` |
| **3** | Task Router | TM 분배 — UI 시각 검수 / 인터랙션 / 접근성 / 성능 / 보안 (모드별 단축 가능) | `{ tm_assignments }` |
| **4** | Context Builder | 페이지 구조 + DOM 트리 + 라우트 + 사용자 페르소나 + 검증 대상 매트릭스 | `audit-data/page-structure.md` |
| **5** | Planner | 시나리오 작성 — 전수 클릭 (LLM 임의 판단 0건) + 8축 카오스 + 페르소나 walk | `scenarios.md` per TM |
| **6** | Tool Executor | 브라우저 도구 (UR §1 우선순위, Playwright MCP 전역 우선) — 실제 브라우저 호출. | tool_logs/* |
| **7** | Draft Generator | 결함 발견 → metadata.json 작성 (이슈 추적 시스템 §17) | `issues/{issue-id}/metadata.json` |
| **8** | Critic / Verifier | 재현성 확인 — 같은 결함이 2회 이상 재현되는지 / 환경 의존성 분리 | `issues/{issue-id}/verification.md` |
| **9** | Refiner | 우선순위 정렬 + 중복 통합 + Blockers/Warnings/Suggestions 분류 + 사용자 명시 강등만 Low | `_index.json` 갱신 |
| **10** | Output Renderer | 최종 QA 리포트 — Markdown + 스크린샷 + DOM 캡처 + 재현 절차 | `QA-REPORT-{date}.md` |

### 단계별 검증/분기

| Step | 검증 | 실패 분기 |
|:-:|---|---|
| 1 | URL/scope 명확 | 불명확 → 사장 질의 |
| 2 | 테스트 유형 매칭 | 불명확 → Smoke 기본 |
| 3 | TM 분배 (1-6명) | 7+ → 분할 |
| 4 | page-structure 수집 OK | 브라우저 도구 실패 시 §1 우선순위 따라 재시도/폴백 |
| 5 | 시나리오 ≥ 매트릭스 100% 커버 | 미달 → 보강 |
| 6 | **§1 우선순위 도구 시도** (Playwright MCP 우선) | 실패 시 대체 도구 + 사유 명시 |
| 7 | 결함 metadata.json 생성 | 누락 → 재발견 |
| 8 | 재현성 ≥ 2회 | 1회만 → 환경 의존성 분리 + flaky 표시 |
| 9 | 등급 분류 일관 (Uncompromising Rigor §3) | 임의 강등 → 차단 |
| 10 | 리포트 + 스크린샷 + 재현 절차 모두 | 누락 → 보강 |

### Uncompromising Rigor 4 정책 정합 (본 스킬 핵심)

- **§1 Browser Priority**: Step 6 에서 §1 우선순위(Playwright MCP 전역 우선) 명시
- **§2 Self-Justification Block**: Step 9 등급 분류 시 "이 정도면 충분" 차단
- **§3 All Findings Are Defects**: Step 7-9 모든 발견 결함 처리
- **§4 Per-Round Deep Analysis**: 매 라운드 5단계 (이전 재조회 / 미세 재스캔 / Adversarial / 자기 정당화 자가 검증 / 신규+재현성)

### 인사이트 1 vs 본 스킬 — Confusion 방지

- 인사이트 1의 fast/normal/pro 모드 ↔ 본 스킬의 Smoke/Regression/E2E/Visual/A11y/Performance 모드 — 다른 체계.
- 인사이트 1의 "한 모델 vs 다단계 호출" → 본 스킬은 **Agent-Teams 다중 TM + Lead 통합** + Playwright/Chrome MCP 실제 브라우저 호출로 다단계 실현.

### 다른 playwright-* 스킬과의 정합 (P1-5 패턴 확립)

본 스킬에 framing 추가 → **대표 패턴**. 나머지 3개 (`playwright-qa-agent-teams` / `playwright-uiux-audit` / `playwright-design-audit`) 은 **P2 단계에서 동일 패턴 적용** 예정.

> **참조**: 인사이트 1 원문 — `.thoughts/2026-05-25-harness-insights-round1.md` / 라운드 3 합의안 — `.thoughts/2026-05-25-harness-insights-round2-round3.md`