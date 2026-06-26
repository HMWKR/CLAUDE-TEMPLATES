---
name: architect
description: |
  Architecture scaffolding and project structure design skill.
  This skill should be used when the user asks to "design architecture",
  "scaffold project", "아키텍처 설계", "프로젝트 구조 잡아줘", "파이프라인 설계",
  "팀 구성 설계", "에이전트 팀 편성", or "프로젝트 초기 설정".
  NOT for: "architect" as person/role reference, code containing "architect" as variable name.
  7-step execution flow with expert role-playing system and built-in improvement proposals.
user_invocable: true
---

# Architecture Scaffolding Skill

## Trigger Rules

### Trigger (activate)
- `/architect` (slash command)
- "아키텍처 설계", "프로젝트 구조 잡아줘", "파이프라인 설계"
- "architecture design", "scaffold architecture", "project structure"
- "팀 구성 설계", "에이전트 팀 편성", "프로젝트 초기 설정"
- User prefixes request with "architect" in structural design context

### Non-trigger (do NOT activate)
- "architect" as a person/role reference in conversation
- Code containing "architect" as variable/class name
- Simple folder creation without structural design intent
- Questions about architecture concepts without design request

---

## Shared References

- 역할 정의: `~/.claude/skills/_core/roles.md`
- 프로토콜: `~/.claude/skills/_core/protocols.md`
- 팀 패턴: `~/.claude/skills/_core/team-patterns.md`

---

## Announce Pattern

Skill starts with:

> "아키텍처 스캐폴딩 스킬을 시작합니다. 프로젝트 분석 → 전문가 패널 구성 → 산업 패턴 매칭 → 파이프라인 설계 → 에이전트 팀 편성 → 피드백 루프 설계 → 산출물 생성의 7단계로 진행합니다."

---

## Core Principles

- **에이전트 수 제한 없음**: 프로젝트 복잡도와 도메인 깊이에 따라 자동 결정. 정밀도와 완성도가 핵심 기준.
- **전문가 자동 롤 플레잉**: 프로젝트 도메인 분석 후 해당 분야 전문가 패널을 자동 구성하여 각 관점에서 아키텍처를 검증.
- **산업 표준 기반**: Team Topologies, Anthropic 에이전트 패턴, 검증된 파이프라인 아키텍처를 참조 DB로 활용.
- **사전 예방 > 사후 감지**: 도메인 경계 자동 강제, 품질 게이트 자동 설계, 에스컬레이션 정책 기본 포함.

---

## Information Pipeline

### Priority 1: 현재 대화 컨텍스트
- 사용자 요구사항에서 프로젝트 도메인, 핵심 기능, 규모 파악
- 이전 대화 기록에서 기술 제약/선호도 추출

### Priority 2: 프로젝트 내부 파일
- `CLAUDE.md`, `README.md`, `package.json` — 기술스택, 의존성
- `src/` 구조 탐색 — 기존 코드 패턴
- `.claude/agents/`, `.claude/rules/` — 기존 에이전트/규칙 확인
- `session-handoff.md`, `checkpoint.md` — 진행 상태

### Priority 3: 외부 도구 (있을 때만)
- 웹 검색: 도메인별 산업 표준 아키텍처 참조
- Context7: 사용 라이브러리 최신 문서 확인
- Greptile: 코드베이스 깊이 분석

### Priority 4: 사용자 질문
- 위 1~3으로 부족한 정보만 AskUserQuestion으로 확인
- 구체적 선택지 형태로 제시 (열린 질문 최소화)

---

## Execution Flow (7 Steps)

### STEP 1: 프로젝트 분석

**목적**: 프로젝트의 도메인, 기술스택, 핵심 기능, 규모를 파악한다.

**프로세스**:
1. Information Pipeline으로 정보 수집
2. 다음 항목을 정리:
   - **도메인**: 프로젝트가 속한 산업/분야 (예: 음성 AI, 핀테크, 교육)
   - **핵심 기능**: 사용자에게 전달하는 핵심 가치 (3~7개)
   - **기술스택**: 프론트엔드/백엔드/DB/외부 서비스
   - **규모 추정**: 예상 파일 수, 에이전트 수, 복잡도 등급 (소/중/대)
   - **핵심 제약**: 성능, 보안, 규제 등 프로젝트 고유 제약
3. 사용자에게 분석 결과 제시 → 확인

**출력**:
```
| 항목 | 내용 |
|------|------|
| 도메인 | [분석 결과] |
| 핵심 기능 | [기능 목록] |
| 기술스택 | [스택 요약] |
| 규모 | [소/중/대] + 근거 |
| 핵심 제약 | [제약 목록] |
```

→ "이 분석이 맞나요?" (Confirmation)

---

### STEP 2: 전문가 패널 자동 구성

**목적**: 프로젝트 도메인에 맞는 전문가 N명을 자동 선정하여 아키텍처 검토에 활용한다.

**자동 구성 로직**:
1. STEP 1의 도메인 분석 결과를 기반으로 필수 전문가 역할 식별
2. 각 전문가의 **페르소나**(이름, 전문 분야, 검토 관점) 정의
3. 전문가 간 **상호 보완 관계** 확인 (중복 방지, 사각지대 방지)

**도메인별 전문가 자동 구성 예시**:

| 도메인 | 전문가 | 검토 관점 |
|--------|--------|----------|
| 음성 AI | STT 엔지니어, NLP 연구원, DSP 전문가, UX 리서치어 | 지연시간, 정확도, 사용자 경험 |
| 핀테크 | 결제 아키텍트, 보안 엔지니어, 규제 전문가, DBA | PCI-DSS, 트랜잭션 무결성, 감사 추적 |
| 교육 | 학습 설계자, 접근성 전문가, 콘텐츠 엔지니어, 분석가 | 학습 효과, WCAG, 콘텐츠 구조 |
| 의료 | HIPAA 전문가, 임상 워크플로 분석가, EMR 통합 전문가 | 규제 준수, 워크플로 효율 |
| 이커머스 | 카탈로그 아키텍트, 결제 전문가, 검색/추천 엔지니어 | 상품 구조, 전환율, 개인화 |
| SaaS | 멀티테넌시 아키텍트, DevOps 엔지니어, 과금 전문가 | 격리, 확장성, 과금 모델 |
| 게임 | 게임 서버 엔지니어, 물리 엔진 전문가, 네트워크 엔지니어 | 틱레이트, 동기화, 지연보상 |

**에이전트 수 정책**: **제한 없음**. 프로젝트 복잡도에 비례하여 자동 결정.
- 소규모 (MVP): 3~5명
- 중규모 (Production): 5~8명
- 대규모 (Enterprise): 8~15명+

**출력**: 전문가 패널 목록 + 각 전문가의 역할/관점 → 사용자 확인

---

### STEP 3: 산업 패턴 매칭

**목적**: 검증된 산업 패턴에서 프로젝트에 최적인 조합을 선택한다.

**참조 패턴 DB**: (상세는 `patterns/` 디렉토리 참조)

#### 팀 구조 패턴 (Team Topologies)
→ `patterns/team-topologies.md` 참조
- 4유형: Stream-Aligned, Platform, Enabling, Complicated Subsystem
- 3상호작용: Collaboration, X-as-a-Service, Facilitating
- Conway's Law 역적용: 원하는 아키텍처 → 팀 구조 결정

#### 에이전트 패턴 (Anthropic)
→ `patterns/agent-patterns.md` 참조
- 6패턴: Prompt Chaining, Routing, Parallelization, Orchestrator-Workers, Evaluator-Optimizer, Context Augmentation
- 하이브리드 조합 규칙

#### 파이프라인 패턴
→ `patterns/pipeline-patterns.md` 참조
- ETL/ELT, 이벤트 기반, Lambda Architecture, Circuit Breaker

**프로세스**:
1. 프로젝트 특성에 맞는 팀 구조 패턴 선택
2. 데이터 흐름에 맞는 파이프라인 패턴 선택
3. 에이전트 오케스트레이션 패턴 선택
4. 선택 근거를 STEP 2의 전문가 관점에서 교차 검증
5. 사용자에게 선택 결과 + 근거 제시 → 확인

---

### STEP 4: 파이프라인 레이어 설계

**목적**: 데이터 흐름 기반으로 파이프라인 레이어를 분해하고 인터페이스를 정의한다.

**프로세스**:
1. 핵심 기능을 데이터 흐름으로 변환 (입력 → 변환 → 처리 → 출력)
2. 각 단계를 독립 레이어로 분해
3. 레이어 간 인터페이스(타입 계약) 초안 작성
4. 실시간 vs 배치 전략 결정:
   - **실시간**: 사용자 대면 레이어 (입력, 스트리밍, UI 업데이트)
   - **배치**: 정밀 분석, 대량 처리, 비동기 작업
   - **하이브리드**: 실시간 경량 처리 + 종료 후 정밀 분석 (Lambda Architecture)
5. 레이어 다이어그램 + 타입 계약 초안 → 사용자 확인

**출력 형식**:
```
[L0] ──▶ [L1] ──▶ [L2] ──▶ ... ──▶ [LN]
  │                  │
  └── 실시간 ────────┘── 배치 ──▶
```

+ 레이어별 역할 테이블 + 타입 인터페이스 초안

---

### STEP 5: 에이전트 팀 편성

**목적**: 도메인별 에이전트를 정의하고 Lead/Worker/Evaluator 역할을 배분한다.

**프로세스**:
1. 파이프라인 레이어를 도메인 단위로 그룹화
2. 각 도메인에 Worker 에이전트 배정:
   - 에이전트 정의: 전문가 페르소나 + 수정 범위 + import 규칙 + 핵심 제약
   - `.claude/agents/{domain}-agent.md` 형식
3. Lead 역할 정의:
   - Orchestrator: Phase 관리, 작업 위임, 결과 합성
   - shared/ 관리: 타입 계약, 유틸리티, 설정
4. Evaluator 팀 구성:
   - QA Agent: 기능 정확성, 테스트 커버리지
   - Security Agent: OWASP Top 10, 인증/인가, 데이터 보호
   - Architect Agent: 도메인 경계, 타입 정합, 패턴 일관성
   - 도메인 특화 평가자: 프로젝트에 따라 추가 (예: 성능 평가자, 접근성 평가자)
5. 에이전트 간 통신 프로토콜 정의:
   - Worker 간 직접 통신 금지
   - shared/types의 타입 계약으로 간접 통신
   - Lead를 통한 작업 위임/결과 수집
6. 전문가 패널의 교차 검증 → 사용자 확인

**에이전트 정의 템플릿**: `templates/agent-definition.md` 참조

---

### STEP 6: 피드백 루프 설계

**목적**: Phase 구분, 품질 게이트, 재작업 정책, 자동 강제 메커니즘을 설계한다.

**프로세스**:
1. **Phase 구분**:
   - Phase 0: 인프라/스캐폴딩 (Lead 단독)
   - Phase 1~N: 기능 구현 (Workers 병렬)
   - Phase N+1: 평가 (Evaluators 병렬)
   - Phase N+2: 통합/최종 검증 (Lead)
2. **품질 게이트** (각 Phase 종료 조건):
   - `npm run build` 성공
   - `npm run lint` 통과
   - 도메인 경계 위반 0건
   - 테스트 통과 (설정된 경우)
3. **재작업 정책**:
   - Evaluator 피드백 → Worker 재작업 (최대 2회)
   - 2회 초과 시 에스컬레이션: Lead → 사용자 판단 요청
   - 무한 루프 방지 장치 내장
4. **자동 강제 메커니즘**:
   - `eslint-plugin-boundaries` 또는 커스텀 lint 규칙
   - import 검증 스크립트
   - pre-commit hook으로 도메인 경계 자동 검증
5. **Enabling Team 역할**:
   - Evaluator가 단순 pass/fail이 아닌 **개선 가이드** 제공
   - "왜 위반인지" + "어떻게 수정하면 좋은지" 피드백
6. 사용자 확인

---

### STEP 7: 산출물 생성

**목적**: 설계 결과를 실행 가능한 파일로 생성한다.

**생성 파일 목록**:

| # | 파일 | 내용 |
|:-:|------|------|
| 1 | `CLAUDE.md` | 프로젝트 지침 + 아키텍처 명세 + 도메인 구조 |
| 2 | `.claude/agents/*.md` | 에이전트 정의 파일들 (Worker + Evaluator) |
| 3 | `.claude/rules/*.md` | 도메인 경계 + 품질 규칙 |
| 4 | `session-handoff.md` | 실행 계획 (Phase별 작업 + 에이전트 배정) |
| 5 | `src/shared/types/` | 타입 계약 (레이어 간 인터페이스) |
| 6 | 폴더 구조 | `src/` 하위 도메인별 디렉토리 스캐폴딩 |

**생성 시 원칙**:
- 기존 파일이 있으면 **병합** (덮어쓰기 금지, 사용자 확인)
- 각 파일 생성 전 목적과 내용 요약 → 사용자 확인
- 모든 산출물은 한국어 주석

**GAP 추적 테이블 자동 생성**:
- 설계 vs 구현 차이를 체계적으로 추적
- `session-handoff.md`에 GAP 매트릭스 포함
- 각 GAP에 우선순위(Critical/Minor) + 해결 Phase 배정

---

## Expert Role-Playing System

스킬 내부에서 STEP 2에서 구성된 전문가 패널이 이후 모든 단계에 개입한다.

### 전문가 개입 방식

1. **설계 검토**: 각 STEP의 산출물을 전문가 관점에서 검토
2. **트레이드오프 분석**: 전문가 간 의견 충돌 시 양측 근거 제시
3. **위험 식별**: 각 전문가가 자신의 도메인에서 위험 요소 식별
4. **개선 제안**: 산업 경험 기반 개선 사항 제안

### 출력 형식

```
### [전문가명] 검토 의견
- **판정**: [적합/부분적합/부적합]
- **근거**: [구체적 이유]
- **개선 제안**: [있을 경우]
```

### 전문가 간 충돌 처리

충돌 발생 시:
1. 양측 주장을 객관적으로 정리
2. 트레이드오프 테이블 제시 (기준: 성능, 유지보수성, 보안, UX)
3. 추천안 + 근거 제시
4. 최종 결정은 사용자

---

## Built-in Improvement Proposals

스킬이 기본적으로 체크하고 제안하는 항목:

| # | 제안 | 설명 |
|:-:|------|------|
| P1 | 도메인 경계 자동 강제 | ESLint 규칙 또는 import 검증 스크립트 자동 생성 |
| P2 | 에이전트 간 통신 프로토콜 | shared/types 타입 계약을 명시적 "계약서"로 문서화 |
| P3 | Evaluator 에이전트 정의 자동 생성 | Worker와 동일 수준의 명시적 지침 |
| P4 | 에스컬레이션 정책 기본 포함 | 재작업 N회 초과 시 "Lead → 사용자 판단 요청" |
| P5 | Phase 간 품질 게이트 자동 설계 | build + lint + 도메인 경계 + 테스트 조건 명시 |
| P6 | Enabling Team 역할 포함 | Evaluator에게 pass/fail + 개선 가이드 역할 부여 |
| P7 | 실시간/배치 전략 자동 판별 | 데이터 흐름 분석 후 자동 결정 |
| P8 | GAP 추적 테이블 자동 생성 | 설계 vs 구현 차이 체계적 추적 |

---

## Confirmation Protocol

각 STEP 완료 시 사용자 확인을 받는다.

**확인 옵션**:
- "맞습니다 (다음 단계로)"
- "수정이 필요합니다" → 구체적 수정 사항 논의

**Backtrack**: 이후 단계에서 이전 단계의 오류 발견 시 사용자에게 알리고 돌아갈지 결정.

---

## When to Stop

- 사용자가 "중단", "스킵", "그냥 해줘" 등을 요청한 경우 → 즉시 중단, 확정된 내용 요약 후 직접 실행
- 정보가 극도로 부족하여 추측에 의존해야 할 때 → 사용자에게 질문
- Backtrack이 3회 이상 발생 시 → 근본적 방향 재설정 제안

---

## Red Flags

**Never:**
- 사용자 확인 없이 다음 STEP으로 넘어가지 않는다
- 정보 부족 시 추측으로 아키텍처를 설계하지 않는다
- 기존 파일을 확인 없이 덮어쓰지 않는다
- 도메인 경계 규칙 없이 에이전트를 배치하지 않는다

**Don't:**
- 에이전트 수를 임의로 제한하지 않는다 (복잡도에 비례)
- 전문가 롤 플레잉을 생략하지 않는다
- 산업 패턴 참조 없이 독자적 구조를 제안하지 않는다
- 피드백 루프/에스컬레이션 정책을 생략하지 않는다
