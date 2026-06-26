# Selection Gate Template (가이드 §10 인용 사본)

> 출처: `realizesoft/realizesoft-cross-runtime-skill-guide.md` §10 Selection Gate Template. 원본 가이드 파일은 수정하지 않으며, 본 파일은 인용 사본 + AskUserQuestion 도구로의 매핑 명세다.

---

## 가이드 §10 원문 (인용)

> Use this format in any runtime.
>
> ```text
> <Stage> Selection Gate
>
> Goal:
> <what this choice controls>
>
> Option 1. <name> (Recommended)
> Why recommended:
> Pros:
> Cons:
> Cost/speed/risk:
> Expected artifacts:
> UserChoice record:
>
> Option 2. <name>
> Pros:
> Cons:
> Cost/speed/risk:
>
> Choose:
> 1. Option 1
> 2. Option 2
> ```
>
> Rules:
> - put the recommended option first
> - explain why it is recommended
> - explain tradeoffs, not just labels
> - stop until the user chooses
> - record the result after selection

---

## Claude Code AskUserQuestion 매핑

Claude Code 환경에서는 위 텍스트 템플릿을 그대로 출력하지 않고, `AskUserQuestion` 도구의 구조화된 필드로 매핑한다 (Question Gate Mandate 정합):

### 매핑 규칙

| 가이드 §10 필드 | AskUserQuestion 필드 |
|---|---|
| `<Stage> Selection Gate` | `question` (예: "Workspace Detection 후 어느 helper 로 진입할까요?") |
| `Goal` | `question` 의 부연 또는 `header` |
| `Option N. <name> (Recommended)` | `options[0].label` ("<name> (Recommended)") |
| `Why recommended` + `Pros` + `Cons` + `Cost/speed/risk` | `options[N].description` (한 줄로 압축 또는 줄바꿈) |
| `Expected artifacts` + `UserChoice record` | `description` 끝부분 또는 결정 후 별도 표시 |
| `Option 2`, `Option 3`, ... | `options[1]`, `options[2]`, ... |
| `Choose:` | (자동 — AskUserQuestion 의 UI 가 처리) |

### 옵션 수 제약

- AskUserQuestion 의 `options` 는 **최대 4개** + "Other" 자동 제공
- 가이드 §10 은 옵션 수 제약 없음 → 5개 이상의 helper 후보가 있으면:
  - (a) 가장 중요한 4개로 압축 (덜 중요한 helper 는 description 에 "see also" 로 언급)
  - (b) 2단계 gate 로 분할 (1st: 카테고리 → 2nd: 카테고리 안의 helper)

### Anti-Pattern (절대 금지)

- 텍스트로 "Option 1. ... Option 2. ... 어느 것을 선택하시겠습니까?" 출력하고 채팅 응답 대기 → §11.2 위배 ("do not rely on a casual 맞나요? loop if the workflow requires a gate")
- 옵션 위치 무작위 → 첫 옵션 = Recommended (가이드 §10 명시)
- Pros/Cons/Cost 생략 → 가이드 명시 "explain tradeoffs, not just labels"

---

## Sample (Workspace Detection 후 첫 Selection Gate)

```typescript
AskUserQuestion({
  questions: [{
    question: "Workspace Detection 후 어느 helper 로 Requirements Analysis 를 시작할까요?",
    header: "Discovery Helper",
    multiSelect: false,
    options: [
      {
        label: "domain-researcher (Recommended)",
        description: "도메인 지식이 부족할 때. 시장·경쟁사·기술 스택·규제 5개 모듈 자동 실행. Pros: 체계적 리서치 / Cons: 시간 ~15분 / Cost: medium / Artifacts: domain-knowledge/*.md"
      },
      {
        label: "ux-pattern-researcher",
        description: "도메인별 UX 패턴·유저 플로우·전환율 가이드라인 수집. Pros: UX 특화 / Cons: 시장 전체 시야 부족 / Cost: medium"
      },
      {
        label: "what (구조화된 사고)",
        description: "Why-What-How-So What 4단계로 목적부터 명확히. Pros: 빠름 (~5분), 외부 검색 없음 / Cons: 도메인 데이터 수집 안 함"
      },
      {
        label: "Skip — baseline 의 Requirements Analysis 로 직진",
        description: "별도 helper 없이 baseline 본문 진행. Pros: 가장 빠름 / Cons: 도메인 지식 부족 위험"
      }
      // "Other" 자동 제공
    ]
  }]
})
```

### Sample 후 UserChoice 기록

사용자 선택 후:

```markdown
# UserChoice / Discovery / helper-selection / decision.md

## Pipeline Stage
INCEPTION → Requirements Analysis

## Gate
Discovery Helper Selection

## Options Presented
1. domain-researcher (Recommended)
2. ux-pattern-researcher
3. what (구조화된 사고)
4. Skip — baseline 직진

## Recommended Option
domain-researcher

## Why Recommended
도메인 지식 5개 모듈 자동 수집 → baseline 의 Requirements Analysis 가 검증된 데이터 기반으로 진행 가능

## User Selection
<사용자가 선택한 옵션>

## Tradeoffs
<선택 이유 + 절약된 시간 / 추가 비용>

## Files Created
- aidlc-docs/domain-knowledge/<...>.md

## Remaining Risks
<추후 검토 필요한 부분>
```
