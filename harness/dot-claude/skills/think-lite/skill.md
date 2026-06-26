---
name: think-lite
description: |
  적응형 사고 체인. Cynefin이 문제를 분류한 후 영역별로 필요한 스킬만 선택 실행.
  Clear는 3단계, Complex는 6단계 — 문제 복잡도에 비례한 사고 깊이.
  Use when "/think-lite", "가볍게 분석", "스마트하게 접근", "빠르게 생각 정리",
  "이거 어떻게 접근하지", or for everyday coding/analysis tasks.
  NOT for: maximum depth analysis (use /think-full), important design decisions (use /think-deep).
  think- 패밀리 중 가장 일상적. 토큰 3-20K.
user_invocable: true
version: 1.0.0
---

# Think-Lite — 적응형 사고 체인 파이프라인

> **핵심**: "문제의 복잡도만큼만 생각하라." Cynefin이 분류하고, 필요한 스킬만 실행한다.
> think- 패밀리의 **일상용**. 깊이가 필요하면 `/think-deep` 또는 `/think-full` 사용.

**Iron Law**: 경로 선택 결과를 사용자에게 제시하고 확인받은 후에만 실행한다.

## Announce Pattern

> "Think-Lite 적응형 파이프라인을 시작합니다.
> 먼저 Cynefin으로 문제를 분류하고, 복잡도에 맞는 사고 경로를 선택합니다.
> Clear(단순)→3단계, Complicated(난해)→4단계, Complex(복합)→6단계."

---

## Trigger Rules

### 트리거
- `/think-lite` (슬래시 커맨드)
- "가볍게 분석해줘", "스마트하게 접근해줘", "빠르게 생각 정리"
- "이거 어떻게 접근하지", "일단 정리 좀"
- 일상적 코딩/분석 작업에서 구조적 사고가 필요할 때

### 비트리거
- "깊이 분석해줘" (→ `/think-deep`)
- "전체 사고 체인 돌려줘" (→ `/think-full`)
- 단순 지식 질문, 이미 명확한 작업

---

## 파이프라인 아키텍처

```
[Announce] → [Cynefin 분류] → [영역 판정 + 경로 선택] → 사용자 확인
                                         │
              ┌──────────┬───────────┬────┴────┬──────────┐
           Clear    Complicated   Complex   Chaotic   Confusion
              │          │           │         │          │
           경로 A     경로 B      경로 C    경로 D     경로 E
              │          │           │         │          │
           [실행]     [실행]      [실행]    [실행]     [실행]
```

---

## 경로 A: Clear (단순) — 3단계

**적합**: 정답이 명확한 작업. 버그 수정, 변수 리네이밍, 설정 변경.

```
Cynefin(Clear) → What(fast mode) → CE(High-Signal) → 즉시 실행
```

### 실행 플로우
1. **Cynefin**: "이 문제는 Clear입니다. 베스트 프랙티스가 존재합니다."
2. **What(fast)**: Why-What-How-So What 4행을 **한 번에 제시**, 1회 확인
3. **CE(High-Signal)**: 핵심 목표 + 출력 형식만. 경량 프롬프트.
4. **실행**: 즉시 작업 시작

### Handoff A→What
```
| 항목 | 내용 |
|------|------|
| 분류 | Clear |
| 전략 | Sense-Categorize-Respond |
| 토큰 전략 | High-Signal (최소) |
```

**토큰**: ~3-5K | **시간**: ~2분

---

## 경로 B: Complicated (난해) — 4단계

**적합**: 전문가 분석이 필요한 작업. 리팩토링, 성능 최적화, 설계 개선.

```
Cynefin(Complicated) → What → CE(Context-Rich) → Deep Analysis → 실행
```

### 실행 플로우
1. **Cynefin**: "이 문제는 Complicated입니다. 전문가 분석이 필요합니다."
2. **What**: Why-What-How-So What 4단계 (각 단계 확인)
3. **CE(Context-Rich)**: 표준 프롬프트 — 목표 + 배경 + 제약 + 검증 기준
4. **Deep Analysis**: 전문가 롤플레잉 + 8단계 워크플로우로 심층 분석
5. **실행**: 분석 결과 기반 구현

### Handoff Cynefin→What
```
| 항목 | 내용 |
|------|------|
| 분류 | Complicated |
| 전략 | Sense-Analyze-Respond |
| 추천 전문가 | [Cynefin이 추천한 역할] |
```

### Handoff What→CE
```
| 프레임 | 확정 내용 |
|--------|----------|
| Why | [확정] |
| What | [확정] |
| How | [확정] |
| So What | [확정] |
| CE 매핑 | Goal←What, Constraints←How, Eval←So What |
```

**토큰**: ~15-20K | **시간**: ~10분

---

## 경로 C: Complex (복합) — 6단계 전체

**적합**: 해봐야 아는 작업. 새로운 아키텍처, AI 모델 전환, 시스템 전환.

```
Cynefin(Complex) → What → First Principles → CE(Multi-Turn) → Deep Analysis → OODA
```

### 실행 플로우
1. **Cynefin**: "이 문제는 Complex입니다. 안전한 실험(probe)이 필요합니다."
2. **What**: 4단계 목적 정립 (각 단계 확인)
3. **First Principles**: 기존 가정 해체 → 유효 전제만으로 재구성
4. **CE(Multi-Turn)**: 작업을 2-3단계로 분할, 각 턴별 프롬프트
5. **Deep Analysis**: 전문가 롤플레잉으로 Turn 1 심층 분석
6. **OODA**: 실행 중 적응 — Observe-Orient-Decide-Act 순환

### Handoff First Principles→CE
```
| 항목 | 내용 |
|------|------|
| 유효 전제 | [검증됨으로 확인된 전제 목록] |
| 무효 전제 | [무효화된 전제 + 이유] |
| 재구성 접근법 | [유효 전제 기반 새 접근] |
| 원래 What/How | [Stage 1에서 확정된 값] |
```

**토큰**: ~40-50K | **시간**: ~25분+

---

## 경로 D: Chaotic (긴급) — 2단계

**적합**: 즉각 안정화가 필요한 상황. 프로덕션 장애, 데이터 손실.

```
Cynefin(Chaotic) → 즉각 행동 → OODA(안정화 후 적응)
```

### 실행 플로우
1. **Cynefin**: "Chaotic입니다. 분석보다 행동이 먼저입니다."
2. **즉각 행동**: 가장 빠른 안정화 조치 실행
3. **OODA**: 안정화 후 Observe → Orient → 재분류 제안

**토큰**: ~3K | **시간**: ~1분

---

## 경로 E: Confusion (혼란) — 분해 경로

**적합**: 문제 자체가 불명확. 요구사항 모순, 방향 미정.

```
Cynefin(Confusion) → First Principles(분해) → What(재정립) → CE → 재분류
```

### 실행 플로우
1. **Cynefin**: "Confusion입니다. 문제를 먼저 분해해야 합니다."
2. **First Principles**: 기존 가정 해체 → 혼란의 근본 원인 식별
3. **What**: 해체된 전제 위에서 목적 재정립
4. **CE**: 재정립된 목적으로 실행 최적화
5. **재분류**: 분해된 각 부분을 Cynefin으로 재분류 → 각각 적절한 경로

**토큰**: ~20-30K | **시간**: ~15분

---

## Confirmation Loop

> **프로토콜 참조**: `_core/confirmation-loop.md`

### 경로 선택 확인 (공통)

Cynefin 분류 후:
```
header: "Think-Lite 경로"
question: "[영역] 경로로 진행합니다. 맞나요?"
options:
  1. "맞습니다 (경로 실행)" — 선택된 경로 시작
  2. "다른 영역 같습니다" — 재분류
  3. "더 깊게 하고 싶습니다" — /think-deep 또는 /think-full 추천
```

### 경로 내 Stage 간 확인
- 각 경로의 스킬 사이에 Handoff Object + 브리지 확인
- Fast Mode(`--fast`) 시 경로 A/D는 확인 생략, 경로 B/C는 최소 1회

---

## Edge Cases

| 상황 | 처리 |
|------|------|
| 분류 확신도 낮음 | 2개 영역 모두 제시, 사용자 선택 |
| "더 깊게" 요청 | `/think-deep` 또는 `/think-full` 추천 |
| 경로 C 도중 Complex가 아니었다 | OODA Orient에서 감지 → 경로 B로 다운그레이드 |
| "그냥 빨리 해줘" | Clear(경로 A)로 강제 전환 |

## Red Flags

**Never:**
- Cynefin 분류 없이 경로를 선택하지 않는다
- Clear 문제에 First Principles/Deep Analysis를 강제하지 않는다
- 사용자 확인 없이 경로를 변경하지 않는다

---

## 인사이트 체크포인트

최종 Stage 완료 시 `_core/protocols.md`의 인사이트 체크포인트를 실행:
- 적응형 사고 과정에서 발견된 인사이트가 있는가?
- 해당 시 `/insight-check` 호출하여 기록 제안

## 참조

- Cynefin: `~/.claude/skills/cynefin/skill.md`
- What: `~/.claude/skills/what/skill.md`
- First Principles: `~/.claude/skills/first-principles/skill.md`
- CE Advisor: `~/.claude/skills/ce-advisor/skill.md`
- Deep Analysis: `~/.claude/skills/deep-analysis-mode/skill.md`
- OODA: `~/.claude/skills/ooda/skill.md`
- 인사이트 감시: `~/.claude/skills/insight-sentinel/skill.md`
- Confirmation Loop: `~/.claude/skills/_core/confirmation-loop.md`
