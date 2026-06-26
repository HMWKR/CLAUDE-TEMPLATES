---
name: think-full
description: |
  최대 깊이 사고 체인. 6개 스킬을 항상 전부 순서대로 실행.
  Cynefin → What → First Principles → CE Advisor → Deep Analysis → OODA.
  각 Stage 사이 Handoff Object로 누적 전달. 어떤 문제든 6단계 전체를 돌림.
  Use when "/think-full", "전체 사고 체인", "최대 깊이로 분석", "완벽하게 생각해줘",
  "대형 프로젝트 설계", "전략적으로 접근", or for major architecture/strategy decisions.
  NOT for: everyday tasks (use /think-lite), standard design (use /think-deep).
  think- 패밀리 중 최대 깊이. 토큰 50K+.
user_invocable: true
version: 1.0.0
---

# Think-Full — 최대 깊이 사고 체인

> **핵심**: "중요한 결정에는 빠짐없는 사고가 필요하다."
> 6개 사고 스킬을 **항상 전부** 순서대로 실행. 단순한 문제에도 다각도 검토.
> think- 패밀리의 **최대 깊이**. 일상은 `/think-lite`, 균형은 `/think-deep`.

**Iron Law**: 각 Stage 사이 Handoff + 브리지 확인. 사용자 Yes 없이 넘어가지 않는다.

## Announce Pattern

> "Think-Full 6단계 사고 체인을 시작합니다.
> **Stage 1**: Cynefin (문제 분류)
> **Stage 2**: What (목적 정립)
> **Stage 3**: First Principles (전제 해체)
> **Stage 4**: CE Advisor (프롬프트 최적화)
> **Stage 5**: Deep Analysis (심층 분석)
> **Stage 6**: OODA (적응 실행)
> 6개 Stage를 전부 순서대로 실행하며, 각 사이에 확인을 받겠습니다."

---

## Trigger Rules

### 트리거
- `/think-full` (슬래시 커맨드)
- "전체 사고 체인 돌려줘", "최대 깊이로 분석"
- "완벽하게 생각해줘", "빠짐없이 검토"
- "대형 프로젝트 설계", "전략적으로 접근해야 해"
- 마이크로서비스 전환, 기술 스택 결정, 비즈니스 전략 등

### 비트리거
- 일상 작업 (→ `/think-lite`)
- 중간 깊이 (→ `/think-deep`)
- 개별 스킬 직접 호출

---

## 6단계 파이프라인

```
Stage 1          Stage 2          Stage 3          Stage 4          Stage 5          Stage 6
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ Cynefin │ ──▶ │  What   │ ──▶ │ First   │ ──▶ │   CE    │ ──▶ │  Deep   │ ──▶ │  OODA   │
│ (분류)  │  A  │ (목적)  │  B  │Princip. │  C  │(최적화) │  D  │Analysis │  E  │(적응)   │
└─────────┘     └─────────┘     └─────────┘     └─────────┘     └─────────┘     └─────────┘
     ↑               ↑               ↑               ↑               ↑               │
     └───────────────┴───────────────┴───────────────┴───────────────┴───────────────┘
                              (역방향 이동 가능)
```

---

## Stage 1: Cynefin (문제 분류)

**목적**: 문제의 성격을 5영역으로 분류. Think-Full에서는 분류 결과와 **무관하게 6단계 전부 실행**하되, 분류 정보가 이후 Stage의 깊이/전략에 영향.

### 실행
1. 판별 트리 (Q1→Q2→Q3) 적용
2. 분류 결과 + 확신도 제시
3. Confirmation Loop

### Handoff Object A
```
━━━ Stage 1 → Stage 2 ━━━
| 분류 | [영역] (확신도: [높/보/낮]) |
| 전략 | [Sense-X-Respond] |
| 추천 전문가 | [Stage 5에서 사용할 역할] |
| 토큰 전략 | [CE Stage 4에서 사용할 전략] |
━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Stage 2: What (목적 정립)

**목적**: Why-What-How-So What 4단계로 근본 목적 역추적.

### 실행
1. STEP 1: Why (역추적 깊이 = Cynefin 복잡도에 비례)
2. STEP 2: What (핵심 목표)
3. STEP 3: How (실행 방법)
4. STEP 4: So What (기대 가치 + 성공 기준)
5. 각 STEP 확인

### Handoff Object B
```
━━━ Stage 2 → Stage 3 ━━━
| 분류 | [Stage 1에서 계승] |
| Why | [확정] |
| What | [확정] |
| How | [확정] |
| So What | [확정 + 성공 기준] |
━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Stage 3: First Principles (전제 해체)

**목적**: Stage 2의 What/How에 숨겨진 전제를 해체하고 유효성 검증.

### 실행
1. STEP 1: How의 암묵적 가정 5-10개 도출
2. STEP 2: Why Chain 분해 → 기본 진실
3. STEP 3: 전제 검증 [유효/무효/조건부/미검증]
4. STEP 4: 무효 전제 기반 How 재구성 (필요 시)
5. Confirmation Loop

### Handoff Object C
```
━━━ Stage 3 → Stage 4 ━━━
| 이전 Handoff | [A + B 계승] |
| 유효 전제 | [N개] |
| 무효 전제 | [M개 + 이유] |
| 재구성 How | [무효 전제 제거 후 How] (변경 있을 시) |
| CE 매핑 | Goal←What, Constraints←재구성How, Eval←So What |
━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Stage 4: CE Advisor (최적화)

**목적**: 전제 검증된 목적/방법을 최적 실행 프롬프트로 변환.

### 실행
1. Phase 0: 컨텍스트 스냅샷 (Stage 1 토큰 전략 참조)
2. Phase 1: 7축 분석 (Stage 2-3 자동 매핑)
3. Phase 2: 4대 실패 모드 진단 (무효 전제 = Poisoning 위험)
4. 분석 확인
5. Phase 3: 3+1 제안 생성 (Stage 1 토큰 전략 반영)
6. 제안 선택

### Handoff Object D
```
━━━ Stage 4 → Stage 5 ━━━
| 이전 Handoff | [A + B + C 계승] |
| CE 제안 | [선택된 제안 유형 + 프롬프트] |
| 실패 모드 | P:[상태] D:[상태] C:[상태] CL:[상태] |
| Deep Analysis 매핑 |
|   전문가 역할 ← Stage 1 추천 |
|   분석 깊이 ← CE 제안 유형 |
|   유효 전제만 사용 ← Stage 3 |
━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Stage 5: Deep Analysis (심층 분석)

**목적**: CE 최적화된 프롬프트로 전문가 롤플레잉 + 8단계 워크플로우 실행.

### 실행
1. Stage 1이 추천한 전문가 역할 채택
2. CE 제안의 프롬프트를 작업 지시로 사용
3. 8단계: 요구사항→탐색→가설→원인→방안→구현→검증→문서화
4. 무효 전제 참조 금지 (Stage 3에서 확정된 유효 전제만)

### Handoff Object E
```
━━━ Stage 5 → Stage 6 ━━━
| 이전 Handoff | [A + B + C + D 계승] |
| 분석 결과 | [8단계 워크플로우 결과] |
| 구현 상태 | [완료/진행중/미시작] |
| 성공 기준 대비 | [So What 충족 여부] |
| OODA 매핑 |
|   Observe 대상 ← 구현 결과 + 테스트 |
|   Orient 기준 ← So What 성공 기준 |
━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Stage 6: OODA (적응 실행)

**목적**: Deep Analysis 결과를 기반으로 적응적 실행. 갭 있으면 조정.

### 실행
1. **Observe**: 구현 상태, 테스트 결과, 성공 기준 대비 현황
2. **Orient**: 갭 분석 — So What 대비 달성도
3. **Decide**: 완료/미세조정/추가작업/근본적 재설계
4. **Act**: 선택 실행

### 최종 산출물
- 6단계 전체 결과 요약
- 각 Stage의 핵심 결정사항
- 성공 기준(So What) 달성도
- 미충족 항목 있으면: 추가 루프 또는 후속 작업 제안

---

## Fast Mode

`/think-full --fast` 시:
- Stage 1-3: Cynefin 분류 + What 4행 + FP 핵심 전제 3개를 **한 번에 제시**, 1회 확인
- Stage 4: CE 분석 + 제안을 **한 번에 제시**, 1회 확인
- Stage 5-6: 일반 실행 (분석/적응은 축약 불가)
- **총 확인 횟수**: 일반 6회 → Fast 2회 + 실행 중 OODA

---

## 역방향 이동

어느 Stage에서든 이전으로 돌아갈 수 있다:

| 감지 시점 | 트리거 | 동작 |
|----------|--------|------|
| Stage 3 (FP) | 전제 해체 중 What이 부정확 | Stage 2로 복귀 |
| Stage 4 (CE) | 7축 분석과 Handoff 불일치 | Stage 2 또는 3으로 복귀 |
| Stage 5 (Deep) | 구현 중 분류 오류 발견 | Stage 1로 복귀 |
| Stage 6 (OODA) | Orient에서 근본적 전환 필요 | Stage 1-3 중 선택 |

역방향 이동 시:
1. 현재까지 결과 요약
2. 사용자에게 "어느 Stage로?" 질문
3. 선택된 Stage부터 재실행, 이후 Handoff 전부 갱신

---

## Confirmation Loop

> **프로토콜 참조**: `_core/confirmation-loop.md`

### 각 Stage 훅 오버라이드

| Stage | PRESENT_FORMAT | CONFIRM_OPTIONS |
|:-----:|:-------------|:---------------|
| 1 | 분류 결과표 | ["확인 (Stage 2로)", "재분류"] |
| 2 | Progressive Table (4프레임) | ["확인 (Stage 3로)", "수정 필요"] |
| 3 | 전제 검증표 + 재구성안 | ["확인 (Stage 4로)", "전제 수정", "Stage 2로"] |
| 4 | 7축표 + 실패모드 + 제안카드 | ["제안 선택 (Stage 5로)", "Stage 2로", "Stage 3로"] |
| 5 | 분석 결과 + 구현 상태 | ["확인 (Stage 6로)", "추가 분석"] |
| 6 | OODA 상태 + 달성도 | ["완료", "추가 루프", "Stage N로 복귀"] |

---

## Edge Cases

| 상황 | 처리 |
|------|------|
| 단순한 문제에 /think-full 호출 | Cynefin이 "Clear"로 분류해도 6단계 전부 실행 (사용자 의도 존중) |
| 토큰 부족 예상 | CE Phase 0에서 경고 + High-Signal 제안 우선 |
| Stage 3에서 전제 전부 유효 | "전제가 건전합니다" 1줄 + 빠르게 Stage 4로 |
| OODA 연속 3회 방향전환 | "근본적 재설계 필요 — Stage 1부터?" 제안 |
| "너무 오래 걸린다" | Fast Mode 전환 제안 또는 `/think-deep`으로 다운그레이드 |

## Red Flags

**Never:**
- 어떤 Stage도 스킵하지 않는다 (Clear 문제에도 6단계 전부)
- Handoff Object 없이 다음 Stage로 넘어가지 않는다
- Stage 3의 무효 전제를 Stage 5에서 사용하지 않는다
- 사용자 확인 없이 역방향 이동하지 않는다
- Fast Mode에서 Stage를 제거하지 않는다 (확인만 압축)

---

## 인사이트 체크포인트

Stage 6 (OODA) 완료 또는 "완료" 선택 시 `_core/protocols.md`의 인사이트 체크포인트를 실행:
- 6단계 사고 체인에서 발견된 인사이트가 있는가?
- 해당 시 `/insight-check` 호출하여 기록 제안

## 참조

- 개별 스킬: cynefin, what, first-principles, ce-advisor, deep-analysis-mode, ooda
- 인사이트 감시: `~/.claude/skills/insight-sentinel/skill.md`
- Confirmation Loop: `~/.claude/skills/_core/confirmation-loop.md`
- think- 패밀리: think-lite (적응형), think-deep (3단계)
