# Team Topologies 패턴 참조

> 출처: Matthew Skelton & Manuel Pais, "Team Topologies" (2019)

---

## 4가지 팀 유형

### 1. Stream-Aligned Team (가치 흐름 정렬 팀)

**정의**: 단일 비즈니스 가치 흐름에 정렬된 팀. 기능의 시작부터 끝까지 자율적으로 딜리버리.

**특성**:
- 외부 의존성 최소화
- 자체 빌드/테스트/배포 역량 보유
- 비즈니스 도메인 전문성

**Claude Code 매핑**: Worker 에이전트 (frontend, backend, ai-pipeline 등)
- 각 에이전트가 단일 도메인에 정렬
- 자율적 코드 생성/수정 권한
- 도메인 내 완전한 책임

**적용 기준**:
- 프로젝트의 핵심 가치 흐름 수 = Stream-Aligned Team 수
- 2~4개가 일반적 (소규모), 4~8개 (중규모), 8개+ (대규모)

---

### 2. Platform Team (플랫폼 팀)

**정의**: Stream-Aligned Team이 자율적으로 작업할 수 있도록 내부 서비스를 제공하는 팀.

**특성**:
- 셀프서비스 API/도구 제공
- 인프라, 공통 라이브러리, 공유 서비스 관리
- Stream-Aligned Team의 인지 부하 감소

**Claude Code 매핑**: Lead의 shared/ 관리 역할 또는 별도 platform 에이전트
- `shared/types/`, `shared/lib/`, `shared/config/` 관리
- 공통 유틸리티, 타입 정의, 설정 파일

**주의점**:
- Lead가 Orchestrator + Platform Team을 겸임하면 **과적재** 위험
- 프로젝트 규모에 따라 분리 여부 결정:
  - 소규모: Lead가 겸임 가능 (shared/ 수정 시 "Platform Team 모드" 명시)
  - 중규모 이상: 별도 에이전트 또는 명시적 역할 분리 권장

---

### 3. Enabling Team (지원 팀)

**정의**: Stream-Aligned Team의 역량 향상을 돕는 전문가 팀. 직접 코드를 작성하지 않고 가이드 제공.

**특성**:
- 기술 컨설팅/멘토링
- 새로운 기술/도구 도입 지원
- 일시적 협업 (목적 달성 후 철수)

**Claude Code 매핑**: Evaluator 에이전트에 Enabling 역할 부여
- 단순 pass/fail 판정이 아닌 **개선 가이드** 제공
- "왜 위반인지" + "어떻게 수정하면 좋은지" 구체적 피드백
- 반복되는 패턴 위반 시 Worker에게 학습 자료 제공

**적용 기준**:
- 모든 프로젝트에 최소 1개의 Enabling 역할 필요
- Evaluator에게 부여하면 별도 팀 불필요

---

### 4. Complicated Subsystem Team (복잡 하위 시스템 팀)

**정의**: 고도의 전문 지식이 필요한 서브시스템을 전담하는 팀.

**특성**:
- 수학/과학/알고리즘 등 전문 지식 필요
- 높은 격리 수준
- 다른 팀이 이해하기 어려운 내부 구조

**Claude Code 매핑**: 가장 강한 격리를 가진 에이전트
- 예: ai-pipeline (Deepgram SDK + Claude API)
- `shared/` 외 다른 도메인 import 완전 금지
- 결과만 반환, 저장은 다른 도메인 책임

**적용 기준**:
- 외부 SDK 3개 이상 사용하는 도메인
- 특수 프로토콜/알고리즘이 핵심인 도메인
- 전문 지식 없이는 코드 리뷰가 어려운 도메인

---

## 3가지 상호작용 모드

### 1. Collaboration (협업)

**정의**: 두 팀이 긴밀히 협력하여 공동 작업. 양방향 커뮤니케이션.

**Claude Code 적용**:
- Phase 초기에 Lead + Worker가 함께 인터페이스 설계
- 도메인 경계가 불명확한 초기 단계에서 사용
- 기간 제한 필수 (장기 Collaboration은 인지 부하 증가)

**적용 시점**: 새로운 도메인 추가, 대규모 리팩토링, 아키텍처 변경

---

### 2. X-as-a-Service (서비스 제공)

**정의**: 한 팀이 다른 팀에게 명확한 인터페이스로 서비스를 제공. API처럼 사용.

**Claude Code 적용**:
- Worker 에이전트 간의 기본 상호작용 모드
- `shared/types/`의 타입 계약 = 서비스 인터페이스
- 직접 import 금지, Server Action/API 통해서만 접근
- Platform Team의 기본 제공 방식

**적용 시점**: 안정된 도메인 경계, 명확한 인터페이스, 일상적 개발

---

### 3. Facilitating (촉진)

**정의**: 한 팀이 다른 팀의 작업을 도움. 직접 코드 변경 없이 가이드/리뷰.

**Claude Code 적용**:
- Evaluator → Worker 관계의 기본 모드
- 코드 리뷰 + 개선 가이드 제공
- Worker의 자율성을 해치지 않으면서 품질 향상

**적용 시점**: 평가/리뷰 단계, 새로운 패턴 도입 시 가이드

---

## Conway's Law 역적용

> "시스템의 구조는 그것을 설계하는 조직의 커뮤니케이션 구조를 반영한다."

**역적용 원리**: 원하는 시스템 아키텍처를 먼저 설계하고, 그에 맞는 팀(에이전트) 구조를 결정한다.

**적용 방법**:
1. 파이프라인 레이어 설계 (원하는 아키텍처)
2. 레이어 간 경계 = 에이전트 간 경계
3. 경계가 명확할수록 에이전트 자율성 향상
4. 경계가 불명확하면 Collaboration 모드로 일시 해결 후 안정화

---

## 팀 규모 가이드라인

| 프로젝트 규모 | Stream-Aligned | Platform | Enabling | Complicated Subsystem |
|:---:|:---:|:---:|:---:|:---:|
| 소규모 (MVP) | 2~3 | Lead 겸임 | Evaluator 겸임 | 0~1 |
| 중규모 (Production) | 3~5 | 1 (또는 Lead 분리) | 1 (Evaluator 강화) | 1~2 |
| 대규모 (Enterprise) | 5~10 | 1~2 | 1~2 | 2~4 |

> 에이전트 수는 제한 없음. 정밀도와 완성도가 핵심 기준.
