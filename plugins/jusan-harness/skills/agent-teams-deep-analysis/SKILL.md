---
name: agent-teams-deep-analysis
description: |
  Deep codebase analysis with 3 parallel specialists (Structure, Patterns, Dependencies).
  Use when asked to "analyze codebase", "analyze architecture", "analyze project structure",
  "dependency analysis", "코드 분석", "아키텍처 분석", or "구조 분석".
  Requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1.
trigger: auto
---

# Agent Teams 코드베이스 심층 분석 스킬

## conductor-verify 정합

이 스킬은 conductor-verify 파이프라인 하위의 `<agent-teams-deep-analysis>` 전문 진입점이다. **완료권위·최종검증은 conductor-verify(계획→검수→실행→종합→독립검증→승인)·codex 교차벤더 게이트·verify-lock을 따른다** — 자체 스코어링/완료보고는 그 단계에 종속(경쟁 권위 아님). 이 스킬의 고유 기여(읽기전용 심층분석 Lead+3TM 병렬 분업·데이터 디렉토리 계약)는 유지한다.

## 목차
- [1. 실행 모드](#1-실행-모드)
- [2. 핵심 원칙](#2-핵심-원칙)
- [3. Parallel Specialists 아키텍처](#3-parallel-specialists-아키텍처)
- [4. 데이터 디렉토리 구조](#4-데이터-디렉토리-구조)
- [5. Stage 0: Lead — 코드베이스 탐색](#5-stage-0-lead--코드베이스-탐색)
- [6. 팀 정의 & Spawn 시스템](#6-팀-정의--spawn-시스템)
- [7. Stage 1: 병렬 전문가 분석](#7-stage-1-병렬-전문가-분석)
- [8. Stage 2: Lead — 리포트 통합](#8-stage-2-lead--리포트-통합)
- [9. 행동 채택 표준](#9-행동-채택-표준)
- [10. 에러 핸들링 & Fallback](#10-에러-핸들링--fallback)
- [11. 환각 방지 프로토콜](#11-환각-방지-프로토콜)
- [12. 단일 에이전트 vs Agent-Teams 비교](#12-단일-에이전트-vs-agent-teams-비교)

## 1. 실행 모드

| 모드 | 명령어 | 분석 범위 | 팀 구성 |
|:----:|--------|----------|--------|
| 기본 | `/agent-teams-deep-analysis` | 핵심 구조 + 주요 패턴 | Lead + 3 TM |
| 심층 | `--deep` | 전체 코드베이스 정밀 분석 | Lead + 3 TM |
| 집중 | `--focus=<area>` | 특정 디렉토리/모듈만 | Lead + 2 TM |

### 자동 감지 트리거
- 사용자가 "코드베이스 분석", "아키텍처 분석", "프로젝트 구조 분석", "의존성 분석", "패턴 분석" 등을 요청할 때 자동 활성화

---

## 2. 핵심 원칙

### 2.1 Analysis-First (분석 우선)
- 코드를 수정하지 않음 — 오직 **읽기와 분석**만 수행
- 모든 발견사항에 파일 경로와 라인 번호 포함
- 추측이 아닌 실제 코드에서 확인된 사실만 보고

### 2.2 Multi-Perspective (다관점)
- 3명의 전문가가 동일 코드베이스를 독립적 관점으로 분석
- 각 전문가는 자신의 도메인에만 집중하되, 교차 영역도 표시
- Lead가 관점 간 연결고리와 충돌을 식별하여 통합

### 2.3 Evidence-Based (증거 기반)
- 모든 판단에 코드 근거(파일:라인) 필수
- 패턴 식별 시 최소 3개 이상의 인스턴스 필요
- 정량화 가능한 메트릭 우선 (파일 수, 줄 수, 함수 수 등)

---

## 3. Parallel Specialists 아키텍처

```
┌──────────────────────────────────────────────────────────┐
│  Stage 0: 코드베이스 탐색 (Lead 단독)                     │
│  • Glob/Grep으로 프로젝트 구조 파악                       │
│  • 기술 스택 식별                                         │
│  • 분석 범위 결정 + 핵심 파일 목록 작성                    │
│  → analysis-data/project-overview.md 생성                 │
└───────────────────────┬──────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│  Stage 1: 병렬 전문가 분석 (Teammates)                    │
│                                                          │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐         │
│  │ Teammate 1 │  │ Teammate 2 │  │ Teammate 3 │         │
│  │ 구조 분석가│  │ 패턴 분석가│  │ 의존성     │         │
│  │            │  │            │  │ 분석가     │         │
│  │ analysis-  │  │ analysis-  │  │ analysis-  │         │
│  │ data/ 읽기 │  │ data/ 읽기 │  │ data/ 읽기 │         │
│  │     ↓      │  │     ↓      │  │     ↓      │         │
│  │ analysis-  │  │ analysis-  │  │ analysis-  │         │
│  │ reports/   │  │ reports/   │  │ reports/   │         │
│  │ structure  │  │ patterns   │  │ dependency │         │
│  │ .md        │  │ .md        │  │ .md        │         │
│  └────────────┘  └────────────┘  └────────────┘         │
└───────────────────────┬──────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│  Stage 2: 리포트 통합 (Lead)                              │
│  • analysis-reports/*.md 수집 → 통합 리포트 생성          │
│  • 교차 관점 연결고리 식별                                 │
│  • 종합 권고사항 + 액션 플랜 작성                          │
│  → analysis-reports/ANALYSIS-{timestamp}.md 생성          │
└──────────────────────────────────────────────────────────┘
```

---

## 4. 데이터 디렉토리 구조

```
{project-root}/
├── analysis-data/                    # Lead가 생성, Teammates가 읽기
│   ├── project-overview.md           # 프로젝트 개요 (기술스택, 구조, 규모)
│   ├── file-tree.md                  # 전체 파일 트리
│   ├── key-files.md                  # 핵심 파일 목록 + 요약
│   ├── tech-stack.md                 # 기술 스택 상세
│   └── metrics.md                    # 정량 메트릭 (파일수, LOC 등)
└── analysis-reports/                 # 각 Teammate가 자기 파일만 작성
    ├── structure.md                  # TM1: 구조 분석
    ├── patterns.md                   # TM2: 패턴 분석
    ├── dependency.md                 # TM3: 의존성 분석
    └── ANALYSIS-{timestamp}.md       # Lead: 통합 리포트
```

### 파일 충돌 방지 규칙
- `analysis-data/`: Lead만 쓰기, Teammates는 읽기 전용
- `analysis-reports/`: 각 Teammate는 자기 전용 파일에만 쓰기
- Lead는 통합 리포트(`ANALYSIS-*.md`)에만 쓰기

---

## 5. Stage 0: Lead — 코드베이스 탐색

### 5.1 실행 절차

```
[Step 1] 프로젝트 루트 확인
- package.json, pyproject.toml, Cargo.toml, go.mod 등 확인
- 기술 스택 식별

[Step 2] 파일 트리 수집
- Glob으로 전체 구조 파악
- .gitignore 패턴 존중
- 디렉토리별 파일 수 집계

[Step 3] 핵심 파일 식별
- 엔트리포인트 (main, index, app)
- 설정 파일 (config, env)
- 라우터/컨트롤러
- 모델/스키마 정의
- 테스트 파일

[Step 4] 정량 메트릭 수집
- 총 파일 수 / 총 LOC
- 언어별 분포
- 디렉토리별 규모
- 테스트 커버리지 파일 존재 여부

[Step 5] analysis-data/ 파일 생성
- project-overview.md: 1-2페이지 프로젝트 요약
- file-tree.md: 전체 파일 트리 (depth 3)
- key-files.md: 핵심 파일 목록 + 각 파일의 역할 요약
- tech-stack.md: 기술 스택 + 버전 정보
- metrics.md: 정량 메트릭 테이블
```

### 5.2 프로젝트 개요 템플릿 (project-overview.md)

```markdown
# 프로젝트 개요

## 기본 정보
- **이름**: {프로젝트명}
- **경로**: {경로}
- **기술 스택**: {언어/프레임워크/라이브러리}
- **프로젝트 유형**: {웹앱/CLI/라이브러리/모노레포 등}

## 규모
| 항목 | 값 |
|------|-----|
| 총 파일 수 | {n} |
| 총 LOC | {n} |
| 소스 파일 수 | {n} |
| 테스트 파일 수 | {n} |
| 설정 파일 수 | {n} |

## 주요 디렉토리
| 디렉토리 | 역할 | 파일 수 |
|----------|------|:-------:|
| src/ | 소스 코드 | {n} |
| tests/ | 테스트 | {n} |
| ... | ... | ... |

## 엔트리포인트
- {파일:라인} - {설명}

## 분석 범위 결정
- **기본 모드**: {핵심 디렉토리 목록}
- **심층 모드**: {전체 디렉토리}
```

### 5.3 팀 구성 결정

| 모드 | 팀 구성 | 설명 |
|:----:|--------|------|
| 기본 | Lead + TM1 + TM2 + TM3 | 3명 전원 |
| --focus | Lead + 관련 TM 2명 | 영역에 따라 선택 |

**--focus 자동 선택 규칙:**
| focus 영역 | 선택 Teammate | 이유 |
|------------|:------------:|------|
| 구조/폴더/레이어 | TM1 + TM2 | 구조 + 패턴 연관 |
| 패턴/스타일/일관성 | TM2 + TM3 | 패턴 + 의존성 연관 |
| 의존성/결합도/순환참조 | TM1 + TM3 | 의존성 + 구조 연관 |

---

> 3개 TM(구조/패턴/의존성) 역할 정의 + Spawn 프롬프트 4-Block 전문 + 25항목 체크리스트는 `references/spawn-prompts.md` 참조.

## 7. Stage 1: 병렬 전문가 분석

### 7.1 Teammate 실행 규칙

각 Teammate는 다음 규칙을 준수합니다:

1. **읽기 우선**: `analysis-data/` 파일을 먼저 읽고 프로젝트 이해
2. **직접 탐색**: 자신의 체크리스트에 관련된 소스 코드를 직접 Glob/Grep/Read로 탐색
3. **증거 기반**: 모든 발견에 `파일:라인` 근거 필수
4. **정량화**: 가능한 모든 항목에 수치 메트릭 포함
5. **자기 파일만**: `analysis-reports/{자기파일}.md`에만 쓰기
6. **환각 방지**: 실제 확인하지 않은 내용에 `[추정]` 마커 표시

### 7.2 분석 깊이 기준

| 모드 | 체크리스트 | 코드 탐색 범위 | 예상 시간 |
|:----:|:---------:|:-------------:|:---------:|
| 기본 | 각 TM 15항목 | 핵심 파일만 | TM당 3-5분 |
| --deep | 각 TM 25항목 | 전체 소스 | TM당 7-10분 |
| --focus | 선택 TM 25항목 | 지정 영역 | TM당 5-7분 |

---

## 8. Stage 2: Lead — 리포트 통합

> 정합: 이 단계의 통합 리포트는 파이프라인의 **종합 산출물**이며 완료 선언이 아니다 — 최종검증·승인은 conductor-verify 승인 단계에 위임한다(자체 완료권위 아님).

### 8.1 통합 절차

```
[Step 1] 개별 리포트 수집
- analysis-reports/structure.md 읽기
- analysis-reports/patterns.md 읽기
- analysis-reports/dependency.md 읽기

[Step 2] 교차 분석
- 구조 약점 ↔ 패턴 안티패턴 연결
- 결합도 이슈 ↔ 구조 개선안 매핑
- 패턴 일관성 ↔ 의존성 정리 연관

[Step 3] 이슈 통합 & 중복 제거
- 동일 이슈 다른 관점 → 하나로 병합 (모든 관점 표시)
- 심각도 재분류 (교차 관점 고려)
- 우선순위 통합 (비용/효과 기반)

[Step 4] 통합 리포트 작성
- analysis-reports/ANALYSIS-{timestamp}.md 생성
```

### 8.2 통합 리포트 템플릿

```markdown
# 코드베이스 심층 분석 리포트

**프로젝트**: {프로젝트명}
**분석 일시**: {YYYY-MM-DD HH:MM}
**분석 모드**: {기본|심층|집중}
**분석팀**: Lead + {n}명 Teammate

---

## Executive Summary
{3-5줄 핵심 요약}

## 프로젝트 건강도 점수

| 영역 | 점수 | 등급 | 비고 |
|:----:|:----:|:----:|------|
| 구조 | /100 | {A-F} | {한줄 설명} |
| 패턴 | /100 | {A-F} | {한줄 설명} |
| 의존성 | /100 | {A-F} | {한줄 설명} |
| **종합** | **/100** | **{A-F}** | |

### 등급 기준
| 등급 | 점수 | 의미 |
|:----:|:----:|------|
| A | 90+ | 우수 — 모범 프로젝트 |
| B | 75-89 | 양호 — 경미한 개선 필요 |
| C | 60-74 | 보통 — 리팩토링 권장 |
| D | 40-59 | 미흡 — 구조적 개선 필요 |
| F | <40 | 위험 — 즉시 조치 필요 |

## 핵심 발견사항 (Top 10)

| # | 발견 | 영역 | 심각도 | 위치 |
|:-:|------|:----:|:------:|------|
| 1 | {발견} | 구조/패턴/의존성 | Critical | {파일:라인} |
| ... | ... | ... | ... | ... |

## 상세 분석

### 구조 분석 요약
{TM1 리포트 핵심 요약 + 교차 관점 보충}

### 패턴 분석 요약
{TM2 리포트 핵심 요약 + 교차 관점 보충}

### 의존성 분석 요약
{TM3 리포트 핵심 요약 + 교차 관점 보충}

## 교차 분석: 관점 간 연결

### 구조 ↔ 패턴
{구조적 문제가 패턴 품질에 미치는 영향}

### 패턴 ↔ 의존성
{패턴 선택이 의존성에 미치는 영향}

### 의존성 ↔ 구조
{의존성 문제가 구조에 미치는 영향}

## 이슈 전체 목록

| # | 이슈 | 영역 | 심각도 | 위치 | 권장 수정 |
|:-:|------|:----:|:------:|------|----------|
| 1 | ... | ... | ... | ... | ... |

## 액션 플랜

### 즉시 (1주 내)
- [ ] {Critical 이슈 수정}

### 단기 (1개월 내)
- [ ] {Major 이슈 수정}

### 중장기 (분기 내)
- [ ] {구조적 개선}

## 부록
- [구조 분석 상세](structure.md)
- [패턴 분석 상세](patterns.md)
- [의존성 분석 상세](dependency.md)
```

> 정합: 위 건강도 점수·등급은 이 스킬의 자체 진단 기여일 뿐 **자체 최종 게이트가 아니다** — 점수 확정·최종검증·승인은 conductor-verify 승인 단계에 위임한다.

---

## 9. 행동 채택 표준 (Behavioral Adoption Standards)

> **전문가 역할 정의**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/roles.md` (플러그인 동봉 _core) 참조
> **Agent-Teams 패턴**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/team-patterns.md` (플러그인 동봉 _core) 참조

### 이 스킬 고유 역할 구성

| TM | 역할 | 핵심 관점 | 출력 [A] | 출력 [B] | 출력 [C] |
|:--:|------|----------|----------|----------|----------|
| TM1 | 구조 분석가 | SOLID, Clean Architecture | 아키텍처 레이어 다이어그램 + SOLID 위반 매핑 | 결합도/응집도 점수, 레이어 위반 수 | "구조적 관점에서..." |
| TM2 | 패턴 분석가 | GoF 디자인 패턴, 리팩토링 카탈로그 | 패턴 카탈로그 + 안티패턴 목록 | 패턴 적용률, 안티패턴 빈도 | "패턴 관점에서..." |
| TM3 | 의존성 분석가 | 의존성 역전 원칙, 모듈 응집도 분석 | 의존성 그래프 + 순환 의존성 맵 | 의존성 깊이, 순환 참조 수, 외부 의존성 비율 | "의존성 관점에서..." |

---

## 10. 에러 핸들링 & Fallback

### 10.1 Fallback 계층

| 상황 | Fallback 동작 |
|------|---------------|
| agent-teams 비활성 | Lead가 3명 전문가를 순차 롤플레이 (단일 에이전트) |
| Teammate 생성 실패 | Lead가 해당 전문가 역할 수행 |
| 특정 TM 분석 실패 | 해당 영역 `[미분석]` 표시, 나머지로 통합 리포트 |
| 코드베이스 너무 큼 | 자동으로 --focus 모드 전환 (핵심 디렉토리만) |

### 10.2 Agent-Teams 비활성 시 단일 에이전트 모드

```
환경 변수 CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS 미설정 시:
→ "/agent-teams-deep-analysis 스킬이 단일 에이전트 모드로 실행됩니다"
→ Lead가 순차적으로 3개 관점을 롤플레이:
   1. [구조 분석가 역할] → analysis-reports/structure.md
   2. [패턴 분석가 역할] → analysis-reports/patterns.md
   3. [의존성 분석가 역할] → analysis-reports/dependency.md
   4. [통합] → 최종 리포트 생성
→ 동일한 체크리스트와 산출물 형식 유지
→ 실행 시간만 증가 (병렬 → 순차)
```

### 10.3 대형 코드베이스 대응

| 규모 | 기준 | 대응 |
|:----:|------|------|
| 소형 | <50 파일 | 전체 분석 |
| 중형 | 50-500 파일 | 핵심 디렉토리 우선 |
| 대형 | 500+ 파일 | 자동 --focus 전환 + 샘플링 |

**샘플링 전략 (대형):**
- 각 디렉토리에서 대표 파일 3-5개 선택
- 가장 최근 수정된 파일 우선
- 가장 큰 파일 포함 (잠재적 God Module)
- 가장 많이 import되는 파일 포함 (Fan-in 높은 모듈)

---

## 11. 환각 방지 프로토콜 (Anti-Hallucination)

> **공통 프로토콜**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md` (플러그인 동봉 _core) 참조

**이 스킬 고유 규칙**:
- 패턴 식별 시 최소 3개 파일에서 근거 제시 필수 (예: "MVC 사용" 주장 시 3개 이상 파일 증거)
- 메트릭 수치 제시 시 산출 근거 명시 (예: "Glob 결과 127개 파일")
- 추정 기반 Critical 이슈 금지 (Minor/Info만 허용)
- 교차 검증: Lead 통합 시 TM 간 동일 파일 관점 비교 및 수치 불일치 재확인

---

## 12. 단일 에이전트 vs Agent-Teams 비교

| 항목 | 단일 에이전트 (deep-analysis-mode) | Agent-Teams (이 스킬) |
|------|:---------------------------------:|:---------------------:|
| 분석가 수 | 1 (순차 롤플레이) | 3 (병렬 독립) |
| 컨텍스트 | 1개 공유 | 팀원별 독립 |
| 실행 시간 (기본) | 10-15분 | 5-8분 (예상) |
| 실행 시간 (심층) | 25-40분 | 12-20분 (예상) |
| 비용 | 1x | ~2-3x |
| 분석 품질 | 후반부 감소 가능 | 균일한 깊이 |
| 교차 분석 | 제한적 | Lead 통합 시 수행 |
| 추천 상황 | 빠른 진단, 비용 절약 | 철저한 분석, 시간 절약 |

---

## 10단계 파이프라인 View (인사이트 1 매핑, 2026-05-25 P2-4a 추가)

> 본 스킬은 3 specialists(Structure/Patterns/Dependencies) 병렬 분석 — 인사이트 1의 Step 4(Context) + Step 5(Planner) + Step 6(Tool)이 가장 강하게 매핑.

| Step | 인사이트 1 단계 | 본 스킬 매핑 |
|:-:|---|---|
| 1 | Input Normalizer | 분석 대상 코드베이스 정규화 |
| 2 | Intent Classifier | 분석 유형 (구조 / 패턴 / 의존성 / 종합) |
| 3 | Task Router | 3 specialists 병렬 분배 |
| 4 | **Context Builder (강함)** | 각 TM이 자기 영역 컨텍스트 수집 (디렉토리 트리 / AST / package 트리) |
| 5 | **Planner (강함)** | 분석 깊이 결정 + 샘플링 전략 + 깊이 vs 효율 trade-off |
| 6 | **Tool Executor (강함)** | Glob / Read / Grep 병렬 (각 TM 독립) |
| 7 | Draft Generator | 3개 분석 보고서 (구조도 / 패턴 목록 / 의존성 그래프) |
| 8 | Critic / Verifier | Lead 통합 — 분석 결과 모순 점검 |
| 9 | Refiner | 핵심 발견 우선순위 정렬 + 권장 조치 |
| 10 | Output Renderer | 통합 분석 리포트 + 시각화 (선택) |

### 확립 패턴 (P1-4) — Step 4-6 강조

분석 중심 스킬이므로 Context Builder + Planner + Tool Executor 3단계 강화. Step 7-10은 P1-4 패턴 그대로.

> **참조**: 인사이트 1 — `.thoughts/2026-05-25-harness-insights-round1.md` / 회고 — `.thoughts/2026-05-25-harness-application-completed.md`
