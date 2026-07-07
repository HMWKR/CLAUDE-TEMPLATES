---
name: what-ce
description: |
  2단계 파이프라인: What 목적 정립 → CE 프롬프트 최적화.
  Stage 1이 Why-What-How-So What 4단계로 진짜 목적을 정립하고,
  그 결과가 자동으로 Stage 2 CE+PE 최적화의 입력이 된다.
  Use when "what-ce", "목적 정립 후 최적화", "what then ce",
  "what ce", "프롬프트 최적화 전에 목적부터", or
  when user wants to clarify purpose before optimizing execution.
  Fast mode: add "--fast" to compress Stage 1 confirmation.
  NOT for: "what is X?" knowledge questions, standalone CE advice (use ce-advisor),
  standalone purpose analysis (use what).
user_invocable: true
argument-hint: "[--fast] <요청 또는 프롬프트>"
version: 1.0.0
---

# What-CE 파이프라인 — 목적 정립 + 프롬프트 최적화

## Core Principle

사용자의 요청에 대해 **"왜 하려는 것인지"를 먼저 정립**(Stage 1)하고, 그 정립된 목적을 **최적의 실행 프롬프트로 변환**(Stage 2)한다. 두 단계의 출력이 Handoff Object를 통해 구조적으로 연결된다.

**Iron Law**: 사용자의 Yes 없이는 다음 단계로 넘어가지 않는다.

---

## Announce Pattern

스킬 시작 시 반드시 출력:

> "2단계 파이프라인을 시작합니다.
> **Stage 1** (What Framework): Why → What → How → So What 4단계로 진짜 목적을 정립합니다.
> **Stage 2** (CE Advisor): 정립된 목적을 바탕으로 실행 프롬프트를 최적화합니다.
> 각 단계마다 확인을 받겠습니다."

Fast Mode일 때:

> "Fast Mode로 2단계 파이프라인을 시작합니다.
> Stage 1의 4단계 분석을 한 번에 제시하고 일괄 확인 후 CE 최적화로 넘어갑니다."

---

## Trigger Rules

### 트리거 (작동)

- `/what-ce` (슬래시 커맨드 직접 호출)
- `"what-ce"`, `"what ce"`, `"what then ce"`
- `"목적 정립 후 최적화"`, `"목적부터 정리하고 실행"`, `"what 다음 ce"`
- `"프롬프트 최적화 전에 목적부터"`

### 비트리거 (작동 안 함)

- `"what is X?"`, `"what does X do?"` (영어 의문사 질문)
- `/what` 단독 → what 스킬로
- `/ce-advisor` 단독 → ce-advisor 스킬로
- 단순 지식 질문

---

## Fast Mode

### 진입 조건

- `/what-ce --fast <요청>`
- Stage 1 진행 중 사용자가 "빠르게", "한 번에", "스킵" 등 요청 시 전환

### 행동 규칙

1. Information Pipeline(Priority 1~2)에서 정보를 수집한다
2. Why/What/How/So What 4행을 **한 번에 추론**하여 완성된 표로 제시한다
3. **단 1회의 확인**: "이 분석이 맞나요?"
4. Yes → Handoff Object 생성 → Stage 2 진입
5. 수정 요청 → 수정 반영 후 다시 1회 확인

**Fast Mode ≠ 단계 생략**. 4행 표는 항상 완성된다. 확인 루프만 1회로 압축한다.

---

## Pipeline Architecture

```
[Announce]
    │
    ├── --fast? → [4행 일괄 제시 → 1회 확인] ──┐
    │                                           │
    └── 일반 → [STEP 1: Why] → 확인             │
                  │                              │
              [STEP 2: What] → 확인              │
                  │                              │
              [STEP 3: How] → 확인               │
                  │                              │
              [STEP 4: So What] → 확인           │
                  │                              │
                  ├──────────────────────────────┘
                  ▼
          [Handoff Object 생성]
          [브리지 확인: "Stage 2로 진행?"]
                  │
                  ▼
          [Stage 2: CE Advisor]
          [Phase 0: 컨텍스트 스냅샷]
          [Phase 1: 7축 분석 (Handoff 자동 매핑)]
          [Phase 2: 실패 모드 진단]
          [분석 확인]
                  │
          [Phase 3: 3+1 제안 생성]
          [제안 선택]
                  │
                  ▼
          [선택된 제안으로 즉시 실행]
```

---

## Stage 1: What Framework

### Stage 1 = `what` 스킬 위임

Stage 1은 **`what` 스킬의 Why → What → How → So What 4-STEP**을 그대로 적용한다. 각 STEP의 출력 형식·역추적 깊이 기준·Information Pipeline 은 `what` 스킬 본문(SSoT)을 따른다 — 여기서 복제하지 않는다(동기화 부채 방지).

**what-ce 차이점**: `what` 의 "실행 방식 선택"은 생략하고, 4-STEP 확정 후 바로 아래 Handoff Object 를 생성한다(실행 방식은 Stage 2 가 결정).

### Stage 1 Backtrack Protocol

STEP 진행 중 이전 STEP의 오류 발견 시:

1. 사용자에게 알림: "STEP [N]의 [부분]이 현재 분석과 맞지 않습니다"
2. AskUserQuestion: "이전 단계로 돌아가서 수정" / "현재대로 진행"
3. 돌아간 경우: 해당 STEP부터 재진행, 이후 STEP 리셋

---

### Stage 1 완료 조건

`what` 스킬과 달리 "실행 방식 선택" 없이 **바로 Handoff Object를 생성**한다. Stage 2가 실행 방식을 결정하기 때문이다.

---

## Handoff Bridge

### Handoff Object 형식

Stage 1 완료 시 아래 블록을 출력한다. Stage 2는 이를 "원본 프롬프트"로 취급한다.

```
━━━ Stage 1 완료 → Stage 2 시작 ━━━

## 목적 정립 완료

| 프레임 | 확정 내용 |
|--------|----------|
| **Why** | [확정된 근본 동기] |
| **What** | [확정된 핵심 목표] |
| **How** | [확정된 실행 방법] |
| **So What** | [확정된 기대 가치 + 성공 기준] |

**CE 자동 매핑:**
- Goal ← What
- Constraints ← How
- Eval ← So What
- Output ← What + How

이제 Stage 2에서 최적의 실행 프롬프트를 설계합니다.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 브리지 확인

Handoff Object 출력 후 AskUserQuestion:

```
header: "파이프라인 브리지"
question: "목적 정립이 완료되었습니다. Stage 2(CE 최적화)로 진행할까요?"
options:
  1. "Stage 2로 진행" — CE 프롬프트 최적화 시작
  2. "Stage 1 재작업" — 목적 정립 다시
```

**이 확인은 Fast Mode에서도 생략 불가.** 파이프라인 연결의 가시적 증거이자 사용자 통제 지점.

---

### Stage 간 역방향 이동

Stage 2에서 Stage 1으로 돌아가는 경로:

**트리거:**
- Stage 2 분석 확인에서 "Stage 1 재작업" 선택
- 7축 분석 결과가 Handoff와 불일치
- 사용자가 명시적으로 "목적부터 다시" 요청

**프로세스:**
1. 현재 Stage 2 분석 상태 요약
2. AskUserQuestion: "어느 단계부터?" (Why / What / How / So What)
3. 선택된 STEP부터 Stage 1 재진행
4. 새 Handoff Object 생성
5. Stage 2 처음부터 재실행

---

## Stage 2: CE Advisor (Handoff 기반)

### Phase 0: 컨텍스트 스냅샷

```
컨텍스트 스냅샷
├── 예상 사용량: [현재 대화 길이 기반 추정]
├── 여유도: [충분 / 보통 / 부족]
├── 활성 도구: [사용 가능한 도구 수]
└── 권장 전략: [경량 / 표준 / 풍부]
```

**판단 기준:**
- 초반 (1~5턴): 여유 → Context-Rich 권장
- 중반 (6~15턴): 보통 → High-Signal 권장
- 후반 (16턴+): 부족 → 최소 토큰 필수

---

### Phase 1: 7축 분석 — Handoff 자동 매핑

| 축 | 출처 | 내용 |
|:--:|:----:|------|
| **Goal** | Stage 1 | What에서 자동 도출 |
| **Output** | Stage 2 | 산출물 형식 새로 분석 (How에서 힌트) |
| **Input** | Stage 2 | 필요 데이터 새로 분석 |
| **Constraints** | Stage 1 | How에서 자동 도출 |
| **Eval** | Stage 1 | So What에서 자동 도출 |
| **Risks** | Stage 2 | 4대 실패 모드 새로 진단 |
| **Context Arch** | Stage 2 | 도구/메모리/RAG 새로 평가 |

"Stage 1" 표시된 항목은 이미 확정 — "Stage 2" 항목만 새로 분석한다.

---

### Phase 2: CE 실패 모드 진단

```
CE 실패 모드 진단
├── Poisoning:   [안전/주의/위험] — [이유]
├── Distraction: [안전/주의/위험] — [이유]
├── Confusion:   [안전/주의/위험] — [이유]
└── Clash:       [안전/주의/위험] — [이유]
```

---

### Stage 2 분석 확인

Phase 0~2 완료 후 AskUserQuestion:

```
header: "CE 분석"
question: "분석 결과를 확인해주세요."
options:
  1. "분석 OK, 제안 보여줘" — Phase 3 진행
  2. "Stage 2 항목 수정" — Output/Input/Risks 등 보완
  3. "Stage 1 재작업" — 목적 정립부터 다시
```

---

### Phase 3 = `ce-advisor` 스킬 위임

7축 분석(위 Handoff 자동 매핑 표) 이후의 **3+1 제안 생성(High-Signal / Context-Rich / Multi-Turn / 함께 구체화) · 토큰 예산 표시 · 토큰 위치 최적화 시각화**는 `ce-advisor` 스킬 본문(SSoT)을 그대로 따른다 — 여기서 복제하지 않는다. what-ce 고유 가치는 Handoff Object 의 Goal/Constraints/Eval 을 7축에 자동 매핑하는 브리지뿐이다.

### 제안 선택

AskUserQuestion:

```
header: "CE 제안"
question: "어떤 제안으로 실행할까요?"
options:
  1. "제안 1: High-Signal" — 경량, 핵심만
  2. "제안 2: Context-Rich" — 표준, 상세
  3. "제안 3: Multi-Turn" — 분할 실행
  4. "제안 4: 함께 구체화" — 질문으로 정교화
```

---

## Confirmation Loop

> **프로토콜 참조**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/confirmation-loop.md`

### Stage 1 훅 오버라이드

| 훅 | 값 |
|:--:|-----|
| `PRESENT_FORMAT` | Progressive Table + 자연어 요약 |
| `CONFIRM_OPTIONS` | ["맞습니다 (다음 단계로)", "수정이 필요합니다"] |
| `STEP_LABEL` | "Stage 1 / STEP N" |

### 브리지 훅 오버라이드

| 훅 | 값 |
|:--:|-----|
| `PRESENT_FORMAT` | Handoff Object 블록 전체 |
| `CONFIRM_OPTIONS` | ["Stage 2로 진행", "Stage 1 재작업"] |
| `STEP_LABEL` | "파이프라인 브리지" |

### Stage 2 분석 확인 훅 오버라이드

| 훅 | 값 |
|:--:|-----|
| `PRESENT_FORMAT` | 출처 구분 7축 표 + 실패 모드 진단 + 스냅샷 |
| `CONFIRM_OPTIONS` | ["분석 OK, 제안 보여줘", "Stage 2 항목 수정", "Stage 1 재작업"] |
| `STEP_LABEL` | "Stage 2 / CE 분석" |

### Stage 2 제안 선택 훅 오버라이드

| 훅 | 값 |
|:--:|-----|
| `PRESENT_FORMAT` | 3+1 제안 카드 + 토큰 예산표 + 위치 배치도 |
| `CONFIRM_OPTIONS` | ["제안 1", "제안 2", "제안 3", "제안 4"] |
| `STEP_LABEL` | "Stage 2 / CE 제안" |

---

## Post-Pipeline Execution

선택 후 동작:
- **제안 1/2 선택** → 해당 프롬프트를 사용자 지시로 간주하여 **즉시 실행**
- **제안 3 선택** → Turn 1부터 순차 실행
- **제안 4 선택** → 질문 → 답변 반영 → 제안 재생성 → 2턴 반복

실행 완료 후:
- So What의 **기대 가치**와 실제 결과를 대조
- 갭 있으면: 부족한 점 보고 + 추가 작업 여부 질문
- 갭 없으면: 완료 선언 + 성공 기준 충족 확인

---

## Edge Cases

| 상황 | 처리 |
|------|------|
| 이미 명확한 목적이 있음 | STEP 1에서 "Fast Mode로 전환할까요?" 제안 |
| 중간에 "빠르게" 요청 | 남은 STEP 일괄 추론 → 1회 확인 → Handoff |
| Stage 2에서 What이 비현실적 | Goal 분석에서 경고 → "Stage 1 재작업" 선택지 |
| "그냥 실행해줘" 요청 | Handoff의 What+How를 직접 프롬프트로 변환 → 즉시 실행 |
| 극도로 짧은 요청 (1~2단어) | STEP 1 전 AskUserQuestion으로 컨텍스트 확보 |
| 파이프라인 전체 중단 요청 | 즉시 중단 + 확정 내용 요약 + 원래 요청 직접 수행 |
| 2회 이상 backtrack 발생 | 근본적 방향 재설정 필요 — 사용자에게 알리고 재시작 제안 |

---

## Red Flags

**Never:**
- 사용자의 Yes 없이 다음 STEP으로 넘어가지 않는다
- 정보 부족 시 추측으로 STEP을 채우지 않는다
- 4단계를 축약하거나 병합하지 않는다 (Fast Mode도 4행 표 완성)
- Stage 1 결과 없이 Stage 2를 시작하지 않는다
- Handoff Object 없이 Stage 2로 넘어가지 않는다

**Don't:**
- Confirmation Loop에서 같은 내용 단순 반복 (피드백 반영 필수)
- 외부 도구 없다고 스킬 거부 (Priority 1~2로 충분)
- Stage 1에서 실행 방식 선택을 제시하지 않는다 (Stage 2가 담당)

---

## 참조

- Confirmation Loop 프로토콜: `${CLAUDE_PLUGIN_ROOT}/skills/_core/confirmation-loop.md`
- 전문가 역할: `${CLAUDE_PLUGIN_ROOT}/skills/_core/roles.md`
- 문제 해결 프로토콜: `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md`
