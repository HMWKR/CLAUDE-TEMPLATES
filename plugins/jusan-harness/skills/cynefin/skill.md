---
name: cynefin
description: |
  Cynefin Framework 기반 문제 분류 + 스킬 라우터.
  문제를 Clear/Complicated/Complex/Chaotic/Confusion 5개 영역으로 분류하고,
  각 영역에 맞는 전략과 스킬을 자동 라우팅한다.
  Use when "/cynefin", "문제 분류", "어떤 접근이 맞을까", "이거 복잡한 문제야?",
  "어떻게 접근해야 해", "분류해줘", or when facing an ambiguous problem.
  NOT for: simple knowledge questions, already-clear tasks, direct skill invocations.
user_invocable: true
version: 1.0.0
---

# Cynefin Framework — 문제 분류 + 스킬 라우터

> **핵심 원리** (Dave Snowden, 1999): "모든 문제를 같은 방식으로 풀지 마라."
> 문제의 성격에 따라 근본적으로 다른 의사결정 전략이 필요하다.

**Iron Law**: 분류 결과를 사용자에게 제시하고 확인받은 후에만 라우팅을 실행한다.

## Announce Pattern

> "Cynefin Framework로 문제를 분류합니다.
> Clear/Complicated/Complex/Chaotic/Confusion 5개 영역 중 어디에 해당하는지 판단하고,
> 최적의 접근 전략과 스킬을 추천합니다."

---

## Trigger Rules

### 트리거 (작동)

- `/cynefin` (슬래시 커맨드)
- "문제 분류해줘", "어떤 접근이 맞을까", "이거 복잡한 문제야?"
- "어떻게 시작해야 할지 모르겠어", "접근법을 모르겠어"
- "단순한 건지 복잡한 건지 판단해줘"
- 모호한 요청에서 접근법이 불명확한 경우

### 비트리거 (작동 안 함)

- 사용자가 이미 명확한 작업을 지시한 경우 ("이 함수 수정해줘")
- 다른 스킬을 명시적으로 호출한 경우 ("/what", "/deep-analysis")
- 단순 지식 질문 ("Cynefin이 뭐야?")

---

## 5개 영역 정의

| 영역 | 인과관계 | 전략 | 키워드 |
|------|---------|------|--------|
| **Clear** (명확) | 명백한 인과관계. 누구나 알 수 있음 | 감지-분류-대응. 베스트 프랙티스 적용 | "정답이 있다", "문서에 있다", "패턴이 명확하다" |
| **Complicated** (난해) | 인과관계 존재하나 전문가 분석 필요 | 감지-분석-대응. 전문가 판단 | "분석이 필요하다", "여러 옵션이 있다", "트레이드오프가 있다" |
| **Complex** (복합) | 인과관계가 사후에만 파악됨 | 탐색-감지-대응. 안전한 실험(probe) 먼저 | "해봐야 안다", "예측 불가", "창발적 행동" |
| **Chaotic** (혼돈) | 인과관계 없음. 긴급 | 행동-감지-대응. 즉각 안정화 | "지금 터졌다", "프로덕션 장애", "당장 멈춰야" |
| **Confusion** (혼란) | 어느 영역인지 판단 불가 | 분해 → 부분별 재분류 | "뭐가 문제인지 모르겠다", "너무 얽혀있다" |

---

## 실행 플로우

### STEP 0: 문제/상황 기술 수집

Information Pipeline으로 정보 수집:

| Priority | 소스 | 설명 |
|:--------:|------|------|
| 1 | 현재 대화 | 사용자 입력 + 이전 대화 맥락 |
| 2 | 프로젝트 파일 | CLAUDE.md, 에러 로그, 관련 코드 |
| 3 | 외부 도구 | 웹 검색, 문서 참조 (있을 때만) |
| 4 | 사용자 질문 | 위 1~3으로 부족할 때 AskUserQuestion |

### STEP 1: 영역 분류

다음 판별 트리를 순서대로 적용한다:

```
Q1. 긴급 안정화가 필요한가? (프로덕션 장애, 데이터 손실 위험)
    → YES: Chaotic

Q2. 인과관계를 파악할 수 있는가?
    → NO: Complex 또는 Confusion
        Q2-1. 문제를 부분으로 분해할 수 있는가?
              → YES: Confusion (분해 후 각 부분 재분류)
              → NO: Complex
    → YES: Clear 또는 Complicated
        Q3. 전문가 분석 없이 해결 가능한가?
              → YES: Clear
              → NO: Complicated
```

분류 결과를 표로 제시:

| 항목 | 판단 |
|------|------|
| **문제 요약** | [1-2문장] |
| **분류 영역** | [Clear / Complicated / Complex / Chaotic / Confusion] |
| **판단 근거** | [판별 트리 Q1-Q3 경로 설명] |
| **확신도** | [높음 / 보통 / 낮음] |

→ Confirmation Loop 진입

### STEP 2: 영역별 전략 제시

#### Clear → 즉시 실행
- 기존 코드 패턴, 공식 문서, 베스트 프랙티스 참조
- 스킬 라우팅: **없음** (직접 실행이 가장 효율적)
- 토큰 전략: **High-Signal** (최소 토큰)

#### Complicated → 전문가 분석
- 2개+ 접근 옵션 제시 + 트레이드오프 비교
- 스킬 라우팅: **deep-analysis-mode** (전문가 롤플레잉 + 8단계 워크플로우)
- 또는: **domain-expert-analysis** (도메인 전문가 관점)
- 토큰 전략: **Context-Rich** (충분한 분석)

#### Complex → 안전한 실험
- Probe-Sense-Respond: 작은 실험 설계 → 결과 관찰 → 방향 조정
- 스킬 라우팅: **OODA Loop** (`/ooda`) (적응적 실행)
- 또는: **what** → **architect** (목적 정립 후 프로토타입 설계)
- 토큰 전략: **Multi-Turn** (턴별 분할, 실험 사이 관찰)

#### Chaotic → 즉각 안정화
- Act-Sense-Respond: 먼저 행동하여 안정화, 분석은 이후
- 스킬 라우팅: **없음** (즉각 행동이 최우선)
- 안정화 후 → **Complicated** 또는 **Complex**로 재분류
- 토큰 전략: **High-Signal** (최소 토큰, 최대 속도)

#### Confusion → 분해
- 문제를 2-5개 부분으로 분해
- 각 부분을 이 판별 트리로 개별 재분류
- 스킬 라우팅: **what** (Why 역추적으로 문제 구조 파악)
- 또는: **first-principles** (`/first-principles`) (전제 해체로 분해)

전략 + 라우팅 추천을 제시 → Confirmation Loop

### STEP 3: 라우팅 실행

사용자 확인 후:
- 추천 스킬이 있으면 해당 스킬 호출
- 직접 실행이 적합하면 즉시 작업 시작
- 사용자가 다른 접근을 원하면 존중

---

## CE 기여

| CE 실패 모드 | Cynefin의 방어 |
|:------------:|:--------------|
| **Distraction** | Clear 문제에 과도한 분석을 방지. "이건 단순한 문제니 바로 실행합시다" |
| **Confusion** | 영역 분류로 접근법 혼동 제거. "이 문제는 Complex이므로 실험이 필요합니다" |
| **Poisoning** | Complex 영역에서 "확실한 답이 있는 것처럼" 행동하는 것을 차단 |
| **토큰 효율** | Clear→최소, Complicated→적정, Complex→분산(Multi-Turn) |

---

## Confirmation Loop

> **프로토콜 참조**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/confirmation-loop.md`

### 훅 오버라이드

| 훅 | 값 |
|:--:|-----|
| `PRESENT_FORMAT` | 분류 결과 표 + 영역별 전략 + 라우팅 추천 |
| `CONFIRM_OPTIONS` | ["맞습니다 (라우팅 실행)", "영역 재분류 필요", "직접 실행할게요"] |
| `STEP_LABEL` | "Cynefin 분류" |

---

## Edge Cases

| 상황 | 처리 |
|------|------|
| 경계에 있는 문제 (Complicated vs Complex) | 두 영역 모두 제시, 사용자 선택 |
| 분류 확신도가 낮음 | "확신도 낮음"으로 명시 + 2가지 시나리오 제시 |
| 사용자가 "그냥 해줘" | Clear로 간주하고 즉시 실행 |
| 이미 다른 스킬이 진행 중 | Cynefin을 STEP 0으로만 사용 (중단 없이) |
| Chaotic + 안정화 완료 | 재분류 제안 (→ Complicated/Complex) |

## Red Flags

**Never:**
- Clear 문제에 deep-analysis를 강제하지 않는다
- Complex 문제에 "정답"을 제시하지 않는다 (실험 설계를 제시한다)
- Chaotic 상황에서 분석에 시간을 쓰지 않는다 (즉각 행동)
- 사용자의 긴급도를 무시하고 느긋하게 분류하지 않는다

---

## 참조

- Confirmation Loop 프로토콜: `${CLAUDE_PLUGIN_ROOT}/skills/_core/confirmation-loop.md`
- 전문가 역할: `${CLAUDE_PLUGIN_ROOT}/skills/_core/roles.md`
- 문제 해결 프로토콜: `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md`
