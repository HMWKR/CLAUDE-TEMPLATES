---
name: agent-teams-feature-dev
description: |
  Full-stack feature development with Pipeline+Parallel pattern (Design, Implement, Test, Review).
  Use when asked to "build feature", "implement feature", "develop new functionality",
  "기능 개발", "기능 구현", or "풀스택 개발". Requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1.
---

# Agent-Teams 기능 개발 스킬

> **패턴**: Pipeline + Parallel
> **목적**: 풀스택 기능의 설계→구현→테스트→리뷰 파이프라인 자동화

## 목차
- [1. 실행 모드](#1-실행-모드)
- [2. 핵심 원칙](#2-핵심-원칙)
- [3. 파이프라인 아키텍처](#3-파이프라인-아키텍처)
- [4. 데이터 구조](#4-데이터-구조)
- [5. Stage 1: 설계](#5-stage-1-설계)
- [6. 팀 정의](#6-팀-정의)
- [7. Stage 2: 병렬 구현](#7-stage-2-병렬-구현)
- [8. Stage 3: 테스트 작성](#8-stage-3-테스트-작성)
- [9. Stage 4: 통합 & 검증](#9-stage-4-통합--검증)
- [10. 행동 채택 표준](#10-행동-채택-표준-behavioral-adoption-standards)
- [11. 에러 핸들링 & Fallback](#11-에러-핸들링--fallback)
- [12. 환각 방지 프로토콜](#12-환각-방지-프로토콜)
- [13. 단일 개발 vs Agent-Teams 비교](#13-단일-개발-vs-agent-teams-비교)

---

## 1. 실행 모드

| 모드 | 호출 | 팀 구성 | 설명 |
|:----:|------|:-------:|------|
| **풀스택** | `/agent-teams-feature-dev` | Lead + 3 TM | FE + BE + 테스트 병렬 |
| **프론트** | `--frontend-only` | Lead + 1 TM (FE) | 프론트엔드만 |
| **백엔드** | `--backend-only` | Lead + 1 TM (BE) | 백엔드만 |
| **리팩터** | `--refactor` | Lead + 2 TM (구현 + 테스트) | 리팩토링 + 테스트 |

### 환경 확인

```
1. CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 확인
2. Git 저장소 확인
3. 프로젝트 기술 스택 파악
4. 환경 미충족 → 순차 개발 안내
```

---

## 2. 핵심 원칙

| # | 원칙 | 설명 |
|:-:|------|------|
| 1 | **인터페이스 먼저** | Lead가 인터페이스 정의 후 TM이 구현 시작 |
| 2 | **파일 분리** | 각 TM은 자기 담당 파일만 수정 |
| 3 | **컨트랙트 준수** | 인터페이스/타입 정의는 수정 불가 (Lead만 수정) |
| 4 | **점진적 통합** | 구현 완료 → 테스트 → 통합 순서 엄수 |
| 5 | **기존 패턴 존중** | 프로젝트의 기존 코드 스타일/패턴 유지 |

---

## 3. 파이프라인 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│  Stage 1: 설계 (Lead 단독)                               │
│  • 요구사항 분석                                          │
│  • 기존 코드베이스 탐색                                   │
│  • 아키텍처 설계                                          │
│  • 인터페이스/타입 정의 작성                              │
│  • 파일 분배 결정                                         │
│  → feature-plan/ 폴더에 설계 문서 저장                   │
└───────────────────────┬─────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  Stage 2: 병렬 구현 (Teammates)                          │
│                                                         │
│  ┌────────────────────┐  ┌────────────────────┐        │
│  │TM1: 프론트엔드     │  │TM2: 백엔드         │        │
│  │                    │  │                    │        │
│  │컴포넌트 구현       │  │API 엔드포인트      │        │
│  │상태 관리           │  │비즈니스 로직       │        │
│  │UI 스타일링         │  │데이터 모델         │        │
│  │클라이언트 검증     │  │서버 검증           │        │
│  └────────────────────┘  └────────────────────┘        │
└───────────────────────┬─────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  Stage 3: 테스트 작성 (TM3)                              │
│  • TM1, TM2의 구현 코드 읽기                             │
│  • 단위 테스트 작성                                      │
│  • 통합 테스트 작성                                      │
│  • 엣지케이스 테스트                                     │
└───────────────────────┬─────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  Stage 4: 통합 & 검증 (Lead)                             │
│  • 구현 코드 통합 확인                                   │
│  • 테스트 실행                                           │
│  • 충돌 해결                                             │
│  • 최종 검증 리포트 생성                                 │
└─────────────────────────────────────────────────────────┘
```

---

## 4. 데이터 구조

```
{project-root}/
└── feature-plan/                   # Lead가 생성, TM이 읽기
    ├── requirements.md             # 요구사항 정리
    ├── architecture.md             # 아키텍처 설계
    ├── interfaces.ts (또는 .d.ts)  # 인터페이스/타입 정의
    ├── file-assignments.md         # TM별 담당 파일 분배
    └── integration-report.md       # 통합 결과 (Lead 작성)
```

---

## 5. Stage 1: 설계 (Lead 단독)

### 5.1 요구사항 분석

```
[Step 1] 사용자 요구사항 정리
- 기능 설명, 입력/출력, 제약 조건
→ feature-plan/requirements.md

[Step 2] 기존 코드베이스 탐색
- 관련 기존 코드 식별 (Glob, Grep)
- 사용 중인 패턴/라이브러리 파악
- 코드 스타일/컨벤션 확인

[Step 3] 아키텍처 설계
- 컴포넌트 구조, 데이터 흐름
- API 엔드포인트 설계
- 상태 관리 전략
→ feature-plan/architecture.md

[Step 4] 인터페이스 정의
- TypeScript 인터페이스/타입 작성
- API 요청/응답 스키마
- 컴포넌트 Props 타입
→ feature-plan/interfaces.ts

[Step 5] 파일 분배
- TM1(FE)이 작성할 파일 목록
- TM2(BE)가 작성할 파일 목록
- 공유 파일 (interfaces.ts) 표시
→ feature-plan/file-assignments.md
```

### 5.2 파일 분배 규칙

```
1. 각 TM은 자기에게 할당된 파일만 생성/수정
2. 인터페이스 파일(interfaces.ts)은 Lead만 수정 가능
3. 두 TM이 같은 파일을 수정하면 안 됨
4. 새 파일 생성은 허용, 기존 파일 삭제는 금지
5. import 경로가 아직 없는 파일을 참조할 수 있음 (컨트랙트 기반)
```

### 5.3 file-assignments.md 형식

```markdown
# 파일 분배

## 공유 (Lead만 수정)
- feature-plan/interfaces.ts

## TM1: 프론트엔드
- src/components/FeatureName/index.tsx (신규)
- src/components/FeatureName/styles.css (신규)
- src/hooks/useFeatureName.ts (신규)
- src/pages/feature-page.tsx (수정: 라우트 추가)

## TM2: 백엔드
- src/api/feature-name/route.ts (신규)
- src/services/feature-name.service.ts (신규)
- src/models/feature-name.model.ts (신규)

## TM3: 테스트
- src/components/FeatureName/__tests__/index.test.tsx (신규)
- src/api/feature-name/__tests__/route.test.ts (신규)
- src/services/__tests__/feature-name.test.ts (신규)
```

---

> 3개 TM(FE/BE/테스트) 4-Block Spawn 프롬프트 전문 + 체크리스트(UI/상태/접근성, API/데이터/보안, 단위/통합/품질)는 `references/spawn-prompts.md` 참조.

## 7. Stage 2: 병렬 구현

### 7.1 실행 규칙

```
1. TM1(FE)과 TM2(BE)가 동시 Spawn
2. 각 TM은 feature-plan/ 의 설계 문서를 먼저 읽음
3. feature-plan/interfaces.ts의 타입/인터페이스를 기준으로 구현
4. 자기 담당 파일만 생성/수정
5. 구현 완료 시 "구현 완료" 메시지 출력
```

### 7.2 충돌 방지 규칙

```
Lead의 인터페이스 정의가 "컨트랙트":
- TM1은 API 호출 시 interfaces.ts의 Response 타입을 믿고 구현
- TM2는 API 응답 시 interfaces.ts의 Response 타입대로 반환
- 인터페이스가 잘 정의되면 충돌 없이 병렬 구현 가능
```

---

## 8. Stage 3: 테스트 작성

### 8.1 실행 규칙

```
1. TM1, TM2 구현 완료 확인 후 TM3 Spawn
2. TM3은 TM1, TM2가 작성한 코드를 읽기
3. 테스트 케이스 작성:
   - 정상 케이스 (happy path)
   - 예외/에러 케이스
   - 경계값 테스트
   - 엣지케이스
4. 테스트 파일만 생성 (구현 코드 수정 금지)
5. 완료 시 "테스트 작성 완료" 메시지 출력
```

---

## 9. Stage 4: 통합 & 검증 (Lead)

### 9.1 통합 절차

```
[Step 1] 구현 코드 확인
- TM1, TM2가 생성한 파일 목록 확인
- interfaces.ts 대비 구현 일치 여부 확인

[Step 2] 테스트 실행
- TM3이 작성한 테스트 실행 (가능한 경우)
- 실패 테스트 → 원인 분석

[Step 3] 충돌 해결
- import 경로 불일치 수정
- 타입 불일치 해결
- 빌드 에러 수정

[Step 4] 통합 리포트 생성
→ feature-plan/integration-report.md
```

### 9.2 통합 리포트 형식

```markdown
# 기능 개발 통합 리포트

## 개요
| 항목 | 값 |
|------|-----|
| 기능명 | {feature name} |
| 실행 일시 | {YYYY-MM-DD HH:MM} |
| 팀 구성 | Lead + TM1(FE) + TM2(BE) + TM3(Test) |

## 구현 결과
| TM | 파일 수 | 줄 수 | 상태 |
|:--:|:-------:|:-----:|:----:|
| TM1 (FE) | {N} | {N} | 완료/부분 |
| TM2 (BE) | {N} | {N} | 완료/부분 |
| TM3 (Test) | {N} | {N} | 완료/부분 |

## 생성된 파일
- {파일1}: {설명}
- {파일2}: {설명}

## 테스트 결과
- 전체: {N}개 | 통과: {N} | 실패: {N} | 건너뜀: {N}

## 남은 작업
- [ ] {수동 확인 필요 항목}
- [ ] {추가 구현 필요 항목}

## 아키텍처 다이어그램
```
{구현된 아키텍처 ASCII 다이어그램}
```
```

---

## 10. 행동 채택 표준 (Behavioral Adoption Standards)

> **전문가 역할 정의**: `~/.claude/skills/_core/roles.md` 참조
> **Agent-Teams 패턴**: `~/.claude/skills/_core/team-patterns.md` 참조

### 이 스킬 고유 역할 구성

| TM | 역할 | 핵심 관점 | 출력 [A] | 출력 [B] | 출력 [C] |
|:--:|------|----------|----------|----------|----------|
| TM1 | 시니어 FE 엔지니어 | React 컴포넌트 설계, WCAG 접근성 | UI 컴포넌트, 스타일, 상태 관리 | 접근성, 반응형, 에러 UI, 로딩 상태, 성능 | "프론트엔드 관점에서, 이 구현은..." |
| TM2 | 시니어 BE 엔지니어 | RESTful API, DDD, 트랜잭션 | API 라우트, 비즈니스 로직, 데이터 모델 | API 응답 형식, 에러 핸들링, 보안, 트랜잭션, 성능 | "백엔드 관점에서, 이 API는..." |
| TM3 | QA/테스트 엔지니어 | 테스트 피라미드, AAA 패턴 | 단위/통합 테스트, Mock 설정, 엣지케이스 | 커버리지 80%+, 정상/예외 케이스, Mock 격리, 가독성 | "테스트 관점에서, 이 커버리지는..." |

---

## 11. 에러 핸들링 & Fallback

### 11.1 TM 실패 시

| 실패 유형 | 대처 |
|----------|------|
| TM1(FE) Spawn 실패 | Lead가 FE 직접 구현 |
| TM2(BE) Spawn 실패 | Lead가 BE 직접 구현 |
| TM3(Test) Spawn 실패 | Lead가 핵심 테스트만 작성 |
| 인터페이스 불일치 | Lead가 중재하여 수정 |

### 11.2 전체 Fallback

```
agent-teams 불가 시:
1. Lead가 순차적으로 설계 → FE → BE → 테스트 수행
2. 동일한 설계 문서 + 인터페이스 정의 사용
3. 소요 시간: 병렬 대비 2-3배 증가
```

---

## 12. 환각 방지 프로토콜

> **공통 프로토콜**: `~/.claude/skills/_core/protocols.md` 참조

**이 스킬 고유 규칙**:
- package.json에 없는 의존성 import 금지
- 프로젝트에 없는 유틸 함수 사용 금지 (직접 구현)
- 파일 경로는 실제 존재하는 디렉토리에만 생성
- interfaces.ts 타입 계약 준수 확인 필수

---

## 13. 단일 개발 vs Agent-Teams 비교

| 항목 | 순차 개발 | agent-teams-feature-dev |
|------|:---------:|:----------------------:|
| FE/BE | 순차 | 동시 |
| 소요 시간 | 1x | ~0.5-0.6x |
| 충돌 위험 | 없음 | 인터페이스로 방지 |
| 비용 | 1x | ~2-3x |
| 테스트 | 구현자가 작성 | 독립 TM이 작성 |
| 추천 상황 | 소규모/단순 기능 | 중규모+ 풀스택 기능 |

---

## 14. 10단계 파이프라인 View (인사이트 1 매핑, 2026-05-25 P2-4a 추가)

> 본 스킬은 Pipeline+Parallel 패턴 — Design → (FE + BE 병렬) → Test → Review. 인사이트 1의 10단계가 가장 자연스럽게 전체 매핑됨.

| Step | 인사이트 1 단계 | 본 스킬 매핑 (전체 강함) |
|:-:|---|---|
| 1 | Input Normalizer | 기능 요청 정규화 (사용자 1문장 → 상세 spec) |
| 2 | Intent Classifier | 기능 유형 (CRUD / 워크플로우 / 통합 / 외부 API) |
| 3 | Task Router | 풀스택 4 TM 분배 (Design / FE / BE / Test) — Pipeline+Parallel |
| 4 | Context Builder | 기존 코드베이스 + 인터페이스 contract + 의존성 |
| 5 | Planner | Design TM이 Pipeline 단계 + Parallel 분배 설계 |
| 6 | Tool Executor | FE + BE 동시 구현 (병렬, 인터페이스 contract로 충돌 방지) |
| 7 | Draft Generator | FE 산출물 + BE 산출물 + Test 산출물 (3 TM 병렬) |
| 8 | Critic / Verifier | Review TM이 통합 검증 (FE/BE 정합 + Test coverage) |
| 9 | Refiner | 충돌/누락 발견 시 해당 TM에 재작업 지시 |
| 10 | Output Renderer | 통합 기능 + 테스트 + 리뷰 리포트 |

### 확립 패턴 (P1-4) — 전체 10단계 자연 매핑

본 스킬은 이미 Pipeline+Parallel 명시. framing 추가로 10단계 명명 통일.

> **참조**: 인사이트 1 — `.thoughts/2026-05-25-harness-insights-round1.md` / 회고 — `.thoughts/2026-05-25-harness-application-completed.md`