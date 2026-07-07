---
name: agent-teams-reactive-dev
description: >
  Reactive Observer-Worker: Playwright Observer가 상주하며 Worker 코드 변경을 즉시 검증하고,
  설계 불일치 시 즉각 피드백하는 폐쇄 루프(Closed-Loop) 개발 스킬.
  Use when asked to "reactive dev", "reactive build", "build with live feedback",
  "실시간 검증 개발", "리액티브 개발", "Observer-Worker 개발",
  or when feature implementation requires continuous Playwright verification.
  Requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1.
triggers:
  - agent-teams-reactive-dev
  - reactive-dev
  - reactive-build
  - build-with-observer
  - 실시간 검증 개발
  - 리액티브 개발
---

## conductor-verify 정합

이 스킬은 conductor-verify 파이프라인 하위의 `<agent-teams-reactive-dev>` 전문 진입점이다. **완료권위·최종검증은 conductor-verify(계획→검수→실행→종합→독립검증→승인)·codex 교차벤더 게이트·verify-lock을 따른다** — 이 스킬의 자체 스코어링(수렴 추적·게이트 규칙)·완료보고는 그 단계에 **종속**되며 경쟁 권위가 아니다. 이 스킬의 고유 기여(Observer-Worker 폐쇄 검증 루프 — 고유 신규 패턴)는 그대로 유지한다.

---

## ⚠️ Uncompromising Rigor (글로벌 룰 강제 적용)

이 스킬은 `~/.claude/rules/uncompromising-rigor.md` 의 4개 정책을 **무조건 준수**한다:

1. **Browser Tool Priority** — 브라우저 우선순위는 `rules/uncompromising-rigor` §1(2026-07-07 Playwright MCP 전역 우선)을 따른다. 사용자의 실제 로그인 세션 재사용이 필요할 때만 Chrome MCP(`mcp__claude-in-chrome__*`).
2. **Self-Justification Red Flags** — "이 정도면 충분" / "사소함" / "사용자가 신경 안 씀" / "베타니까 OK" / "fetch 진행 중이라 정상" 등장 시 **즉시 자기 차단**
3. **All Findings Are Defects** — 모든 발견은 결함. 사용자가 명시적으로 "강등"한 것만 Low
4. **Per-Round Deep Analysis** — 매 라운드 5단계 심층 분석 강제 (이전 재조회 → 미세 재스캔 → Adversarial walk → 자기 정당화 자가 검증 → 신규+재현성)

---

# Agent-Teams Reactive Dev (Observer-Worker Closed-Loop)

> **패턴**: Reactive Observer-Worker (4번째 패턴)
> **핵심**: Playwright Observer 상주 + Worker 코드 변경 즉시 검증 + 피드백 루프
> **기업 패턴**: CI/CD 게이트키퍼 + Pair Programming + DevOps Infinity Loop + Visual Regression

## 목차
- [1. 실행 모드](#1-실행-모드)
- [2. 핵심 원칙](#2-핵심-원칙)
- [3. 파이프라인 아키텍처](#3-파이프라인-아키텍처)
- [4. 에이전트 역할 정의](#4-에이전트-역할-정의)
- [5. Phase 0: SETUP](#5-phase-0-setup)
- [6. Phase 1: INCREMENTAL BUILD + VERIFY](#6-phase-1-incremental-build--verify)
- [7. Phase 2: FULL VERIFICATION + REGRESSION](#7-phase-2-full-verification--regression)
- [8. Phase 3: FINALIZE](#8-phase-3-finalize)
- [9. 3유형 검증](#9-3유형-검증)
- [10. 피드백 심각도 4등급](#10-피드백-심각도-4등급)
- [11. 상태별 다중 검증](#11-상태별-다중-검증)
- [12. 회귀 방지](#12-회귀-방지)
- [13. 통신 프로토콜](#13-통신-프로토콜)
- [14. 수렴 추적](#14-수렴-추적)
- [15. 안전장치](#15-안전장치)
- [16. 에러 핸들링 & Fallback](#16-에러-핸들링--fallback)
- [17. 기존 스킬과의 관계](#17-기존-스킬과의-관계)

---

## 1. 실행 모드

| 모드 | 호출 | 팀 구성 | 설명 |
|:----:|------|:-------:|------|
| **기본** | `/agent-teams-reactive-dev` | Lead + Observer + FE-Worker | 프론트엔드 구현 + 실시간 검증 |
| **풀스택** | `--fullstack` | Lead + Observer + FE + BE | FE/BE 병렬 구현 + 실시간 검증 |
| **경량** | `--light` | Lead + Observer + Worker 1명 | 소규모 수정 + 검증 |
| **검증만** | `--verify-only` | Lead + Observer만 | 기존 구현을 검증 스펙 기준으로 검증 |

### 환경 확인

```
1. CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 확인
2. Playwright MCP 도구 사용 가능 여부 확인 (browser_navigate 등)
3. 개발 서버 실행 중 확인 (targetUrl 접속 가능)
4. Git 저장소 확인
5. 환경 미충족 → 단일 에이전트 fallback 안내
```

---

## 2. 핵심 원칙

| # | 원칙 | 기업 패턴 출처 | 설명 |
|:-:|------|:----------:|------|
| 1 | **즉시 검증** | CI/CD | 구현 즉시 Observer가 검증 — "Shift Left" |
| 2 | **폐쇄 루프** | DevOps ∞ | 검증→피드백→수정→재검증 양방향 순환 |
| 3 | **생산자≠검증자** | Pair Prog | Worker(Driver) ≠ Observer(Navigator) 역할 분리 |
| 4 | **게이트 통과** | CI/CD | BLOCKER+CRITICAL=0이어야 라운드 통과 |
| 5 | **회귀 방지** | CI/CD | 매 라운드 전체 re-verify, 기존 PASS 유지 확인 |
| 6 | **시각 검증** | Percy/Chromatic | 스크린샷 비교로 디자인 드리프트 감지 |
| 7 | **파일 분리** | feature-dev | 각 TM은 자기 담당 파일만 수정 |

---

## 3. 파이프라인 아키텍처

```
Phase 0: SETUP (Lead 단독)
  ├─ feature-plan/ 설계 문서 생성 (feature-dev 재사용)
  ├─ verification-spec.json 생성 (3유형 검증 기준 + 상태별 + 디자인 기준선)
  ├─ Observer TM spawn (Playwright browser_navigate로 dev 서버 접속 확인)
  └─ Worker TM들 spawn (FE/BE)

Phase 1: INCREMENTAL BUILD + VERIFY (Worker + Observer 교대)
  ┌────────────────────────────────────────────────────────────┐
  │ Worker: 컴포넌트/기능 단위 구현                              │
  │   → "부분 검증 요청" (구현한 기능 ID 명시)                   │
  │   → Observer: 해당 기능만 즉시 검증                         │
  │   → PASS: Worker 다음 기능으로 / FAIL: 즉시 수정            │
  │ (반복: file-assignments.md의 모든 기능 완료까지)             │
  └────────────────────────────────────────────────────────────┘

Phase 2: FULL VERIFICATION + REGRESSION (Observer 전체 검증)
  ┌────────────────────────────────────────────────────────────┐
  │ Observer: 전체 기준 검증 (3유형 x N상태)                    │
  │   → 구조 검증 (요소 존재, DOM 구조)                         │
  │   → 시각 검증 (스크린샷 vs 디자인 기준선)                   │
  │   → 동작 검증 (클릭/입력/네비게이션 시나리오)                │
  │   → 회귀 확인 (이전 PASS가 여전히 PASS인지)                 │
  │                                                            │
  │ 결과: BLOCKER / CRITICAL / MAJOR / MINOR 분류              │
  │   → BLOCKER/CRITICAL → Worker 즉시 수정 → 재검증            │
  │   → MAJOR → Worker 수정 권장                                │
  │   → MINOR → 리포트에 기록                                   │
  │                                                            │
  │ (반복: maxRounds=10 또는 BLOCKER+CRITICAL=0)                │
  └────────────────────────────────────────────────────────────┘

Phase 3: FINALIZE (Lead)
  ├─ 통합 리포트 생성 (라운드별 수렴 추이 포함)
  ├─ 미해결 MAJOR/MINOR 목록
  └─ 팀 shutdown
```

---

## 4. 에이전트 역할 정의

| 에이전트 | 기업 비유 | Playwright | 코드 수정 | 핵심 책임 |
|:--------:|:--------:|:----------:|:---------:|----------|
| **Lead** | Tech Lead | X | 설계 파일만 | 설계 + 조율 + 게이트 판정 + 리포트 |
| **Observer** | QA + Navigator | O (전담) | X (읽기만) | 3유형 검증 + 심각도 분류 + 구체적 피드백 |
| **FE-Worker** | FE Driver | X | 담당 파일만 | UI 구현 + Observer 피드백 반영 |
| **BE-Worker** | BE Driver | X | 담당 파일만 | API 구현 + Observer 피드백 반영 |

### Observer = Navigator (Pair Programming)

Observer는 코드를 직접 수정하지 않고, **무엇이 잘못되었는지 + 어떻게 고쳐야 하는지** 구체적으로 안내합니다.

**Observer 피드백 필수 6요소**:
1. **심각도**: BLOCKER / CRITICAL / MAJOR / MINOR
2. **위치**: 어떤 페이지, 어떤 요소
3. **현재 상태**: 지금 어떻게 되어 있는지
4. **기대 상태**: 어떻게 되어야 하는지
5. **수정 파일**: 어떤 파일을 고쳐야 하는지
6. **수정 방법**: 구체적인 수정 지침

**나쁜 피드백**: "로그인 폼이 요구사항과 다릅니다"

**좋은 피드백**:
```
[CRITICAL] 로그인 폼 — 이메일 입력 필드
현재: input[type='text'] (일반 텍스트)
기대: input[type='email'] (이메일 검증 + 모바일 키보드)
수정 파일: src/app/(auth)/login/page.tsx
수정 방법: type 속성을 'email'로 변경
스크린샷: verification-state/screenshots/v003-login-email.png
```

---

## 5. Phase 0: SETUP

### 5.1 Lead 단독 작업

```
[Step 1] 사용자 요구사항 정리
- 기능 설명, UI 설계, 검증 기준 파악
→ feature-plan/requirements.md

[Step 2] 기존 코드베이스 탐색
- 관련 기존 코드 식별 (Glob, Grep)
- 사용 중인 패턴/라이브러리 파악
→ feature-plan/architecture.md

[Step 3] 인터페이스 정의
- TypeScript 인터페이스/타입 작성
→ feature-plan/interfaces.ts

[Step 4] 파일 분배 + 기능 단위 검증 매핑
- 각 Worker의 담당 파일 목록
- 각 파일/기능과 검증 기준 ID 매핑
→ feature-plan/file-assignments.md

[Step 5] 검증 스펙 생성
- verification-spec.json (3유형 검증 기준 + 상태별 + 디자인 기준선)
- 참조: references/verification-spec-template.json
→ feature-plan/verification-spec.json

[Step 6] 공유 디렉토리 초기화
→ verification-state/ (queue.json, results/, screenshots/)
```

### 5.2 Observer Spawn

```
Observer TM spawn 시:
1. Playwright browser_navigate로 targetUrl 접속
2. 접속 성공 확인 (200 응답 또는 페이지 렌더링)
3. browser_snapshot으로 초기 상태 기록
4. "Observer 준비 완료" 메시지 → Lead에게 전달
5. idle 대기 (검증 요청 메시지 대기)
```

Observer 프롬프트: `references/observer-prompt.md` 참조

### 5.3 Worker Spawn

```
Worker TM spawn 시:
1. feature-plan/ 전체 문서 읽기
2. 프로젝트 기존 패턴 분석
3. file-assignments.md에서 자기 담당 파일 확인
4. 첫 번째 기능부터 구현 시작
```

Worker 프롬프트: `references/worker-prompts.md` 참조

### 5.4 공유 디렉토리 구조

```
{project-root}/
├── feature-plan/                       # Phase 0 (feature-dev 재사용)
│   ├── requirements.md
│   ├── architecture.md
│   ├── interfaces.ts
│   ├── file-assignments.md             # 파일 분배 + 기능-검증 매핑
│   └── verification-spec.json          # Observer 검증 기준 (3유형+상태별)
│
├── verification-state/                 # Phase 1-2 실시간 통신
│   ├── results/
│   │   ├── v001.json                   # 라운드별 검증 결과
│   │   └── ...
│   ├── screenshots/                    # 시각 검증 스크린샷
│   ├── regression-tracker.json         # 회귀 추적
│   ├── convergence-log.json            # 수렴 추이
│   ├── observer-log.md                 # Observer 히스토리
│   └── FINAL-VERIFICATION.md           # 전체 승인 시 생성
│
└── design-baselines/                   # 디자인 기준선 (선택)
    ├── *.png                           # 디자인 목업 스크린샷
    └── design-tokens.json              # 색상/간격/폰트 토큰
```

---

## 6. Phase 1: INCREMENTAL BUILD + VERIFY

### 6.1 점진적 검증 흐름 (Shift Left)

기존 패턴: "전체 구현 후 검증" → 문제점: 대량 FAIL, 대량 수정
개선: "컴포넌트/기능 단위로 즉시 검증" → 소량 FAIL, 소량 수정

```
Worker                           Observer
  │                                 │
  ├─ 기능 A 구현 완료               │
  ├─ "부분 검증 요청 [login-form]" ─▶│
  │                                 ├─ login-form 기준만 검증
  │                                 ├─ PASS: 2/3, FAIL: 1/3
  │◀─ 피드백 (CRITICAL 1건) ────────┤
  ├─ CRITICAL 수정                  │
  ├─ "재검증 요청 [login-form]" ───▶│
  │                                 ├─ login-form 재검증
  │                                 ├─ PASS: 3/3
  │◀─ "login-form 통과" ───────────┤
  ├─ 기능 B 구현 시작               │
  │  ...                            │
```

### 6.2 부분 검증 요청 형식

Worker → Lead (또는 Observer 직접):
```
[부분 검증 요청]
feature-id: login-form
구현 완료 파일: src/app/(auth)/login/page.tsx
변경 내용: 로그인 폼 UI 구현 (이메일/비밀번호/제출버튼)
검증 대상 기준: LF-01, LF-02, LF-03
```

### 6.3 Phase 1 종료 조건

- file-assignments.md의 모든 기능이 "부분 검증 통과" 상태
- 또는 Worker가 모든 할당 파일 구현 완료 선언

---

## 7. Phase 2: FULL VERIFICATION + REGRESSION

### 7.1 전체 검증 사이클

```
라운드 N:
  Observer → 전체 기준 검증 (verification-spec.json의 모든 features + globalCriteria)
    ├─ 구조 검증: 모든 selector 기반 요소 확인
    ├─ 시각 검증: 뷰포트별 스크린샷 캡처 + 기준선 비교
    ├─ 동작 검증: 시나리오별 인터랙션 실행
    ├─ 상태별 검증: 각 상태(초기/로딩/성공/에러/빈 데이터) 트리거 + 확인
    └─ 회귀 검증: 이전 라운드 PASS 항목이 여전히 PASS인지

  결과 저장 → verification-state/results/v{N}.json
  수렴 기록 → verification-state/convergence-log.json 업데이트
```

### 7.2 게이트 규칙 (CI/CD 게이트키퍼)

| 결과 | Worker 행동 | 게이트 |
|------|-----------|:------:|
| BLOCKER+CRITICAL = 0 | 라운드 통과 → Phase 3 | PASS |
| BLOCKER > 0 | 즉시 수정 필수, 다음 라운드 | BLOCK |
| CRITICAL > 0 | 현재 라운드 내 수정 | BLOCK |
| MAJOR만 잔존 | 수정 권장, Lead 판단으로 통과 가능 | 조건부 |
| MINOR만 잔존 | 리포트에 기록, 자동 통과 | PASS |

### 7.3 라운드 반복

```
라운드 1: BLOCKER 2, CRITICAL 3 → Worker 수정
라운드 2: BLOCKER 0, CRITICAL 1 → Worker 수정
라운드 3: BLOCKER 0, CRITICAL 0, MAJOR 2 → Lead 판단
  → Lead: "MAJOR 허용, Phase 3 진행"
  → 또는: "MAJOR 수정 요청" → 라운드 4
```

---

## 8. Phase 3: FINALIZE

> **완료권위 위임**: 이 Phase의 "라운드 통과·정상 종료·FINAL-VERIFICATION.md"는 팀 내부 검증 게이트이며 **최종 완료 선언·승인 권위가 아니다** → conductor-verify 승인 단계(+ codex 교차벤더 게이트·verify-lock)에 위임한다.

### 8.1 Lead 마무리 작업

```
[Step 1] 통합 리포트 생성
- 라운드별 수렴 추이 (convergence-log.json 기반)
- 최종 검증 결과 요약
- 미해결 MAJOR/MINOR 목록
→ verification-state/FINAL-VERIFICATION.md

[Step 2] 결과 요약
- 구현 파일 목록 + 변경 내용
- 검증 통과 현황 (PASS/FAIL/SKIP)
- 스크린샷 참조

[Step 3] 팀 Shutdown
- Observer → shutdown_request
- Worker(s) → shutdown_request
- 팀 정리
```

### 8.2 리포트 형식

`references/report-template.md` 참조

---

## 9. 3유형 검증

### 9.1 구조 검증 (Structure)

```
browser_snapshot → 텍스트 기반 DOM 구조 분석
체크: 요소 존재, 올바른 위치, 속성값
도구: browser_snapshot, browser_evaluate
결과: 요소별 PASS/FAIL + selector 정보
```

### 9.2 시각 검증 (Visual)

```
browser_take_screenshot → 스크린샷 캡처
뷰포트: desktop(1280) → tablet(768) → mobile(375)
비교: 디자인 기준선(텍스트 설명 or 이전 스크린샷)과 대조
도구: browser_take_screenshot, browser_resize
결과: 시각적 차이 설명 + 심각도
```

### 9.3 동작 검증 (Behavioral)

```
browser_click, browser_fill_form, browser_press_key
시나리오: 네비게이션 → 폼 입력 → 제출 → 결과 확인
상태 전이: 초기→로딩→성공 / 초기→로딩→에러
도구: browser_click, browser_fill_form, browser_evaluate
결과: 시나리오별 PASS/FAIL + 실패 지점 + 스크린샷
```

---

## 10. 피드백 심각도 4등급

| 등급 | 의미 | Worker 반응 | 게이트 |
|:----:|------|-----------|:------:|
| **BLOCKER** | 핵심 기능 불가 (페이지 안 열림, 크래시) | 즉시 수정 필수 | 차단 |
| **CRITICAL** | 설계 불일치 (레이아웃 깨짐, 데이터 안 보임) | 현재 라운드 내 수정 | 차단 |
| **MAJOR** | 부분 불일치 (간격, 색상, 폰트 차이) | 수정 권장, 다음 라운드 가능 | 비차단 |
| **MINOR** | 미세 개선 (정렬 미세 차이, 호버 효과) | 선택적 수정 | 비차단 |

### 심각도 판정 기준

```
BLOCKER:
  - 페이지 로드 실패 (빈 화면, 500 에러)
  - 콘솔에 uncaught 에러
  - 핵심 컴포넌트 렌더링 불가

CRITICAL:
  - 필수 요소 누락 (verification-spec의 required: true 항목)
  - 기능 동작 불가 (버튼 클릭 무반응, 폼 제출 실패)
  - 레이아웃 심각 깨짐 (요소 겹침, 화면 밖 이탈)

MAJOR:
  - 디자인 불일치 (색상, 간격, 폰트 크기 차이)
  - 반응형 미적용 (특정 뷰포트에서 깨짐)
  - 에러 상태 UI 미구현

MINOR:
  - 미세 정렬 차이
  - 호버/포커스 효과 미적용
  - 트랜지션/애니메이션 부재
```

---

## 11. 상태별 다중 검증

실제 UI는 여러 상태를 가짐 — 각 상태별 검증 필요:

| 상태 | 검증 내용 | 트리거 |
|------|----------|--------|
| **초기** | 빈 화면, 기본 레이아웃 | 페이지 로드 직후 |
| **로딩** | 스피너/스켈레톤 표시 | API 호출 중 |
| **성공** | 데이터 렌더링, 정확성 | API 응답 후 |
| **에러** | 에러 메시지, 재시도 버튼 | API 실패 시 |
| **빈 데이터** | 빈 상태 메시지 | 데이터 없을 때 |
| **인터랙션** | hover, focus, active 상태 | 사용자 조작 시 |

### 상태 트리거 방법

```
로딩 상태:
  → browser_evaluate로 API 요청 인터셉트 (지연 주입)
  → 또는 네트워크 지연 시 자연 발생 캡처

에러 상태:
  → browser_evaluate로 에러 응답 시뮬레이션
  → 또는 잘못된 입력으로 에러 유발

빈 데이터:
  → 데이터 없는 상태로 페이지 접근
  → 또는 browser_evaluate로 빈 응답 시뮬레이션
```

---

## 12. 회귀 방지

### 12.1 매 라운드 전체 Re-Verify

```
라운드 N에서 기준 C3 FAIL → Worker가 C3 수정

라운드 N+1:
  ├─ C3 재검증 (수정 확인)
  ├─ C1, C2 회귀 검증 (기존 PASS가 깨지지 않았는지)
  └─ C4+ 신규 검증 (아직 미검증 항목)
```

### 12.2 회귀 감지 시

```
회귀 감지 (이전 PASS → 현재 FAIL):
  → 심각도 자동 CRITICAL 격상
  → Worker에게 구체적 피드백:
    "C3 수정 시 C1이 깨짐 — C1의 selector가 변경된 DOM 구조에서 찾을 수 없음"
  → regression-tracker.json에 기록
```

### 12.3 regression-tracker.json

```jsonc
{
  "regressions": [
    {
      "criterionId": "LF-01",
      "passedInRound": 1,
      "failedInRound": 3,
      "cause": "C3 수정 시 DOM 구조 변경으로 selector 무효화",
      "resolvedInRound": 4
    }
  ],
  "totalRegressions": 1,
  "unresolvedRegressions": 0
}
```

### 12.4 회귀 루프 방지

- 동일 기준 5회 연속 FAIL → Lead에게 `PERSISTENT_FAIL` 에스컬레이션
- 회귀 3회 발생 → Lead에게 `REGRESSION_LOOP` — 아키텍처 재검토 요청

---

## 13. 통신 프로토콜

### 13.1 기본 모드: Lead 중계

```
Worker → Lead: "컴포넌트 A 구현 완료, 부분 검증 요청 [feature-id: login-form]"
Lead → Observer: "검증 요청 중계 [feature-id: login-form]"
Observer → Lead: "검증 결과 (BLOCKER 1, CRITICAL 2, MAJOR 1)"
Lead → Worker: "BLOCKER/CRITICAL 피드백 중계 + 수정 지침"
```

### 13.2 직접 모드: Worker↔Observer

TM 직접 통신 가능 시 (SendMessage로 이름 지정):

```
Worker → Observer: "부분 검증 요청 [feature-id: login-form]"
Observer → Worker: "검증 결과 + 수정 지침"
Observer → Lead: "검증 결과 요약 (기록용)"
```

### 13.3 메시지 형식

`references/message-templates.md` 참조 — 6종 메시지 정의

---

## 14. 수렴 추적

### 14.1 convergence-log.json

라운드별 개선 추이 추적 (CI/CD 빌드 히스토리):

```jsonc
{
  "rounds": [
    {
      "round": 1,
      "results": { "total": 15, "pass": 8, "blocker": 2, "critical": 3, "major": 1, "minor": 1 },
      "regressions": 0,
      "passRate": 0.53
    },
    {
      "round": 2,
      "results": { "total": 15, "pass": 12, "blocker": 0, "critical": 1, "major": 1, "minor": 1 },
      "regressions": 0,
      "passRate": 0.80
    }
  ],
  "convergenceRate": "+0.27/round",
  "estimatedRoundsToComplete": 2
}
```

### 14.2 수렴 실패 감지

- passRate 3라운드 연속 변화 없음 → `STAGNATION` 경고
- passRate 하락 → `REGRESSION_DETECTED` 경고

---

## 15. 안전장치

| 조건 | 동작 | 종료 코드 | 기업 비유 |
|------|------|:---------:|----------|
| BLOCKER+CRITICAL = 0 | 정상 종료 | `ALL_VERIFIED` | 모든 게이트 통과 |
| maxRounds(10) 초과 | 미완 종료 + 잔여 리포트 | `MAX_ROUNDS` | SLA 타임아웃 |
| 동일 기준 5회 연속 FAIL | Lead 직접 개입 판단 | `PERSISTENT_FAIL` | Incident Escalation |
| Worker 10분 무응답 | 타임아웃 | `WORKER_TIMEOUT` | Health Check 실패 |
| 컨텍스트 40% 초과 | 즉시 종료 | `CONTEXT_LIMIT` | 리소스 제한 |
| 회귀 3회 발생 | 아키텍처 재검토 요청 | `REGRESSION_LOOP` | 설계 결함 알림 |
| Observer Playwright 끊김 | Lead 재spawn 또는 직접 검증 | `OBSERVER_CRASH` | 서비스 재시작 |

> `ALL_VERIFIED`(정상 종료)는 팀 내부 게이트 통과 신호일 뿐 최종 완료권위(자체 최종 게이트)가 아니다 → conductor-verify 승인 단계에 위임한다.

---

## 16. 에러 핸들링 & Fallback

### 16.1 TM 실패 시

| 실패 유형 | 대처 |
|----------|------|
| Observer spawn 실패 | Lead가 Playwright로 직접 검증 (단일 에이전트) |
| Worker spawn 실패 | Lead가 구현 직접 수행 |
| Observer Playwright 연결 끊김 | Lead가 Observer 재spawn |
| Observer 검증 중 에러 | 해당 기준 SKIP 처리, 리포트에 기록 |

### 16.2 전체 Fallback

```
agent-teams 불가 시:
1. Lead가 순차적으로 설계 → 구현 → Playwright 검증 수행
2. 동일한 verification-spec.json 기준 사용
3. 피드백 루프: 자기 검증 → 자기 수정 (단일 에이전트 루프)
4. 소요 시간: 팀 모드 대비 2-3배 증가
```

### 16.3 Playwright MCP 미사용 Fallback

```
Playwright 도구 미사용 가능 시:
1. 구조 검증: 코드 리뷰 기반 (Read로 컴포넌트 분석)
2. 시각 검증: 불가 → SKIP
3. 동작 검증: 불가 → SKIP
4. 경고: "Playwright 미사용으로 시각/동작 검증 생략. 구조 검증만 수행합니다."
```

---

## 17. 기존 스킬과의 관계

| 스킬 | 관계 | 재사용 |
|------|------|--------|
| `agent-teams-feature-dev` | 설계(Phase 0) 재사용 | feature-plan/ 구조, Worker 프롬프트 70% |
| `continuous-qa-loop` | 검증 루프 패턴 참조 | convergence-log, 메시지 형식 |
| `playwright-qa-expert` | Playwright 도구 사용법 참조 | browser_* 도구 호출 패턴 |
| `_core/team-patterns.md` | 4번째 패턴으로 등록 | Reactive Observer-Worker |
| `_core/protocols.md` | 환각 방지 프로토콜 | Read Before Write, [검증됨] 마커 |
| `_core/roles.md` | 역할 정의 참조 | 전문가 역할 신호 3종 |

### 사용 시나리오 구분

| 시나리오 | 추천 스킬 |
|---------|----------|
| 새 기능 구현 (검증 불필요) | `agent-teams-feature-dev` |
| 새 기능 구현 + 실시간 Playwright 검증 | **`agent-teams-reactive-dev`** |
| 기존 페이지 QA 검증만 | `continuous-qa-loop` |
| UI/UX 감사 | `playwright-uiux-audit` |

---

## 행동 채택 표준 (Behavioral Adoption Standards)

> **전문가 역할 정의**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/roles.md` (플러그인 동봉 _core) 참조
> **Agent-Teams 패턴**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/team-patterns.md` (플러그인 동봉 _core) 참조

### 이 스킬 고유 역할 구성

| TM | 역할 | 핵심 관점 | 출력 [A] | 출력 [B] | 출력 [C] |
|:--:|------|----------|----------|----------|----------|
| Observer | QA Navigator | Playwright 3유형 검증 | 검증 결과 JSON + 스크린샷 | 심각도별 이슈 목록 + 수렴 추이 | "검증 관점에서, 이 라운드는..." |
| FE-Worker | FE Driver | React 컴포넌트 구현 | UI 파일들 | Observer 피드백 반영 이력 | "프론트엔드 관점에서, 이 구현은..." |
| BE-Worker | BE Driver | API 구현 | API 파일들 | Observer 피드백 반영 이력 | "백엔드 관점에서, 이 API는..." |

---

## Observer "상주" 메커니즘

Agent-Teams에서 TM은 idle 상태에서 메시지를 받으면 자동 활성화됩니다.
Observer의 생명주기:

```
spawn → Playwright 접속 확인 → idle 대기
    ↓ (검증 요청 메시지 수신)
활성화 → browser_navigate → 3유형 검증 실행
    → 결과 파일 저장 (verification-state/results/v{N}.json)
    → 피드백 메시지 전송 (심각도 + 수정 지침)
    → idle 대기
    ↓ (다음 검증 요청 수신)
활성화 → 이전 PASS 항목 회귀 검증 + 신규 검증
    → ...반복...
    ↓ (shutdown_request 수신)
종료
```

**핵심**: Observer는 "종료되지 않고 상주"하는 것이 아니라,
**idle↔활성 전환을 반복**하며 논리적으로 상주합니다.
각 활성화 시 이전 컨텍스트가 보존되어 연속적 검증이 가능합니다.

---

## 환각 방지 프로토콜

> **공통 프로토콜**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md` (플러그인 동봉 _core) 참조

**이 스킬 고유 규칙**:
- Observer는 **실제 Playwright 결과**만 보고 (추측 피드백 금지)
- Worker는 **실제 코드 변경**만 보고 (가상 수정 보고 금지)
- 검증 결과는 **파일로 저장** 후 참조 (메모리 의존 금지)
- 스크린샷은 **실제 캡처본** 참조 (상상 금지)
- verification-spec.json의 기준만 검증 (임의 기준 추가 금지)

---

## 10단계 파이프라인 View (인사이트 1 매핑, 2026-05-25 P2-4a 추가)

> 본 스킬은 Observer-Worker 폐쇄 루프 — Playwright Observer가 상주하며 Worker 코드 변경을 즉시 검증. 인사이트 1의 Step 6(Tool Executor) + Step 8(Critic/Verifier)이 가장 강하게 매핑.

| Step | 인사이트 1 단계 | 본 스킬 매핑 |
|:-:|---|---|
| 1 | Input Normalizer | 기능 spec + verification-spec.json 정규화 |
| 2 | Intent Classifier | 검증 유형 (시각 / 인터랙션 / API / 통합) |
| 3 | Task Router | Observer (Playwright) + Worker (Coder) 역할 분리 |
| 4 | Context Builder | 페이지 구조 + verification 기준 + DOM 상태 |
| 5 | Planner | 폐쇄 루프 반복 계획 — Worker 변경 → Observer 검증 → 피드백 |
| 6 | **Tool Executor (강함)** | Worker: Read/Edit/Write / Observer: mcp__playwright__* (browser_*) — 우선순위는 rules/uncompromising-rigor §1 |
| 7 | Draft Generator | Worker가 코드 변경 + Observer가 검증 결과 캡처 |
| 8 | **Critic / Verifier (강함)** | Observer가 즉시 검증 — verification-spec.json 기준만 (임의 기준 추가 금지) |
| 9 | Refiner | 설계 불일치 시 Worker에게 즉시 피드백 → Worker 재변경 |
| 10 | Output Renderer | 폐쇄 루프 종료 시 통합 보고서 + Observer 캡처 증거 |

### Uncompromising Rigor §1 정합

본 스킬의 Step 6 브라우저 도구 우선순위는 rules/uncompromising-rigor §1(2026-07-07 Playwright MCP 전역 우선)을 따른다 — Observer는 Playwright MCP(browser_*)로 검증.

### 확립 패턴 (P1-4) — 폐쇄 루프 특화

본 스킬은 폐쇄 루프 구조이므로 Step 6-9 반복 (Worker 변경 → Observer 검증 → Worker 재변경) 명시.

> **참조**: 인사이트 1 — `.thoughts/2026-05-25-harness-insights-round1.md` / 회고 — `.thoughts/2026-05-25-harness-application-completed.md`
