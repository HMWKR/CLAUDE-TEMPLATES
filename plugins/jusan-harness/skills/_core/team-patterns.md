# Agent-Teams 패턴 정의 (Single Source of Truth)

> 모든 agent-teams-* 스킬이 참조하는 팀 구성 패턴.
> 요구: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

---

## 패턴 4종

### 1. Parallel Specialists

```
Lead → spawn(TM1, TM2, TM3, ...) → 병렬 실행 → 결과 수집 → 통합
```

| 항목 | 설명 |
|:----:|------|
| 용도 | 동일 대상을 다른 관점에서 병렬 분석 |
| TM 수 | 3-6명 |
| 사용 스킬 | agent-teams-code-review, agent-teams-deep-analysis |
| 장점 | 독립 컨텍스트로 균일한 분석 품질 |
| 단점 | 토큰 비용 3-6x |

### 2. Pipeline

```
Lead → TM1(설계) → TM2+TM3(병렬 구현) → TM4(테스트) → 통합
```

| 항목 | 설명 |
|:----:|------|
| 용도 | 단계적 의존성이 있는 작업 |
| TM 수 | 3-5명 |
| 사용 스킬 | agent-teams-feature-dev |
| 장점 | 인터페이스 정의 후 병렬 구현으로 충돌 방지 |
| 단점 | 병목 단계에 의존 |

### 3. Hybrid (Lead 수집 + Parallel 분석)

```
Lead(데이터 수집) → spawn(TM1, TM2, ...) → 병렬 분석 → 통합
```

| 항목 | 설명 |
|:----:|------|
| 용도 | 데이터 수집과 분석이 분리된 작업 |
| TM 수 | 4-18명 |
| 사용 스킬 | playwright-qa-agent-teams, playwright-uiux-audit |
| 장점 | Lead가 1회 수집, 다수 TM이 병렬 분석 |
| 단점 | 수집 단계가 병목 |

### 4. Reactive Observer-Worker (Closed-Loop)

```
Lead(설계+조율) → spawn(Observer, Worker1, Worker2)
  Worker: 구현 → Observer: 즉시 검증 → FAIL? → Worker: 수정 → Observer: 재검증
  (반복: BLOCKER+CRITICAL = 0 될 때까지)
```

| 항목 | 설명 |
|:----:|------|
| 용도 | 구현과 검증을 실시간 양방향 피드백 루프로 연결 |
| TM 수 | 2-4명 (Observer 1 + Worker 1-3) |
| 사용 스킬 | agent-teams-reactive-dev |
| 장점 | 구현 즉시 검증 — 결함 조기 발견 (Shift Left), 회귀 방지 |
| 단점 | Observer Playwright 상주 비용, 라운드 반복 시 토큰 증가 |

**기업 패턴 매핑**:

| 기업 패턴 | 적용 요소 |
|----------|----------|
| CI/CD 게이트키퍼 | Observer의 BLOCKER/CRITICAL/MAJOR/MINOR 심각도 게이트 |
| Pair Programming | Observer = Navigator, Worker = Driver |
| DevOps ∞ Loop | 검증→피드백→수정→재검증 무한 순환 |
| Visual Regression | 스크린샷 비교 (디자인 기준선 vs 실제 화면) |

**검증 3유형**: 구조(DOM snapshot) / 시각(스크린샷) / 동작(클릭·입력·네비게이션)

**핵심 차별점**: 기존 3패턴은 단방향 흐름. 이 패턴만 **역방향 피드백**(Observer→Worker)이 존재하는 폐쇄 루프.

---

## 공통 Teammate 프롬프트 구조

```
당신은 [역할/전문 분야] 전문가입니다.

분석 대상: [파일/코드/시스템]
프레임워크: [적용할 프레임워크]

출력 형식:
[A] 전용 분석 섹션
[B] 정량 메트릭 (표)
[C] 1문장 요약

환각 방지: Read Before Write. [검증됨] 마커 필수.
분석 결과는 [지정 파일]에 저장하세요.
```

## 통합 리포트 구조

```markdown
# [작업명] 통합 리포트

## 요약
| TM | 핵심 발견 | 위험도 |
|----|----------|:------:|

## 교차 분석 (2명+ 공통 지적)
- [이슈]

## 우선순위 이슈
| # | 이슈 | 발견자 | 우선순위 | 조치 |
|:-:|------|:------:|:--------:|------|

## 각 TM 상세 분석
[TM별 [A][B][C]]
```

## Fallback (AGENT_TEAMS 미활성)

```
환경 감지 → AGENT_TEAMS=1?
  ├─ Yes → 팀 모드
  └─ No  → "agent-teams 미활성. 단일 에이전트 모드로 진행합니다."
            → 해당 스킬의 단일 에이전트 fallback 로직 실행
```

## 팀 관리 규칙

| 규칙 | 내용 |
|:----:|------|
| TM 최대 | 8명 (uiux-audit 제외: 18명) |
| 타임아웃 | TM이 5분 무응답 시 결과 수집 마감 |
| 실패 TM | 실패 TM 제외하고 나머지 결과로 리포트 |
| 결과 저장 | 각 TM이 자기 파일만 작성 (충돌 방지) |
