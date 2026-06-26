# 에이전트 정의 파일 템플릿

> `.claude/agents/{domain}-agent.md`로 저장

---

## Worker 에이전트 템플릿

```markdown
# {도메인명} 에이전트

## Role
{역할과 전문 분야 1~2문장}

## Tech Stack
{핵심 기술/라이브러리}

## Scope
- 수정 허용: `src/{도메인}/` 하위 전체
- {도메인 고유 추가 범위}

## Rules

### Import Rules
| 허용 | 금지 |
|------|------|
| `shared/*` | {금지 도메인} |

### Core Constraints
1. {핵심 제약 1}
2. {핵심 제약 2}

### Naming Convention
- 파일: kebab-case
- 컴포넌트: PascalCase
- 함수/변수: camelCase

## Quality Gate
- [ ] `npm run build` 성공
- [ ] `npm run lint` 통과
- [ ] 도메인 경계 위반 0건
```

---

## Evaluator 에이전트 템플릿

Evaluator는 단순 pass/fail이 아닌 **개선 가이드**를 포함해야 한다 (Enabling Team 역할).

```markdown
# {평가 분야} 에이전트

## Role
{평가 관점과 전문 분야 1~2문장}

## Evaluation Criteria

### Critical (불합격)
- [ ] {즉시 수정 필요 항목}

### Major (재작업 권고)
- [ ] {중요 개선 항목}

### Minor (개선 제안)
- [ ] {선택적 개선 항목}

## Feedback Format
1. **판정**: Critical / Major / Minor
2. **위치**: 파일명:라인번호
3. **설명**: 무엇이 문제인지
4. **개선 가이드**: 어떻게 수정하면 좋은지
5. **근거**: 왜 이것이 문제인지

## Escalation
- 1차 재작업: 구체적 피드백 + Worker에게 반환
- 2차 재작업: 상세 가이드 + 코드 예시 제공
- 3차 이상: Lead 에스컬레이션 → 사용자 판단 요청
```

---

## 에이전트 수 가이드

| 규모 | Worker | Evaluator | 총계 |
|:---:|:---:|:---:|:---:|
| 소규모 | 2~3 | 1~2 | 4~6 |
| 중규모 | 3~5 | 2~3 | 6~9 |
| 대규모 | 5~8+ | 3~5+ | 9~14+ |

> 제한 없음. 정밀도와 완성도가 핵심 기준.
