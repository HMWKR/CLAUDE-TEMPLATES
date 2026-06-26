# Helper Routing Matrix (가이드 §9 인용 + 사용자 환경 매핑)

> 출처: `realizesoft/realizesoft-cross-runtime-skill-guide.md` §9 Recommended Helper Routing. 원본 가이드 파일은 수정하지 않으며, 본 파일은 인용 사본 + Claude Code 글로벌 스킬 환경의 실제 매핑이다.

---

## 가이드 §9 원문 (인용)

> Use these as a starting routing map. Rename skills to match the local runtime if needed.
>
> | AI-DLC Area | Helper Type | Use When |
> |---|---|---|
> | Orient / Purpose | `cynefin`, `what` | objective, complexity, or success criteria is unclear |
> | Requirements / Discovery | `to-prd` | known context should become product requirements |
> | Requirements / Discovery | `domain-researcher` | market, competitor, regulation, domain data, or tech evidence matters |
> | Requirements / Discovery | `ux-pattern-researcher` | user flow, conversion, screen IA, or UI patterns matter |
> | Planning / Design | `grill-me` | a load-bearing decision is unresolved |
> | Planning / Design | `architect` | real architecture or project structure design is needed |
> | Planning / Design | `first-principles` | assumptions behind a major choice could invalidate the plan |
> | Implementation | `tdd` | observable behavior and a test runner exist |
> | Implementation | `diagnose` | bug, failure, performance regression, or unclear behavior exists |
> | Implementation | JS/TS refactor helper | JavaScript/TypeScript cleanup or rename is requested |
> | Verification | `webapp-testing` | browser behavior, screenshots, console, or local web flow must be checked |
> | Verification | `security-audit` | auth, input validation, dependencies, or OWASP concerns exist |
> | Verification | UI guidelines helper | accessibility, semantic HTML, responsive, UI quality checks matter |
> | Verification | `live-verify-loop` | live browser proof must repeat until criteria pass |
> | Deployment | provider-neutral gate | deployment or operations is in scope |
> | Deployment | provider adapter | user chooses a provider and approves external writes |

---

## 사용자 환경 (Claude Code 글로벌) 매핑

가이드가 명시한 helper 중 사용자 환경에 **존재** 하는 것 vs **미존재** 인 것:

| AI-DLC Area | 가이드 §9 helper | 사용자 환경 매핑 | 본 스킬 추천 |
|---|---|---|:-:|
| Orient | `cynefin` | ✓ `cynefin` | O |
| Orient | `what` | ✓ `what` | O |
| Discovery | `to-prd` | ✗ 미존재 (가이드의 가상 helper) | — |
| Discovery | `domain-researcher` | ✓ `domain-researcher` | O |
| Discovery | `ux-pattern-researcher` | ✓ `ux-pattern-researcher` | O |
| Design | `grill-me` | ✗ 미존재 | — |
| Design | `architect` | ✓ `architect` | O |
| Design | `first-principles` | ✓ `first-principles` | O |
| Implementation | `tdd` | ✗ 미존재 | — |
| Implementation | `diagnose` | ✗ 미존재 | — |
| Implementation | JS/TS refactor | ✓ `js-refactor-cleanup-skill` | O (JS/TS 한정) |
| Verification | `webapp-testing` | ✓ `webapp-testing` | O |
| Verification | `security-audit` | ✓ `security-audit` | O |
| Verification | UI guidelines | ✓ `web-design-guidelines` | O |
| Verification | `live-verify-loop` | ✓ `live-verify-loop` | O |
| Deployment | provider-neutral gate | (본 스킬 §8 으로 구현) | O |
| Deployment | provider adapter | (사용자가 명시 선택 시 발동) | — |

---

## Selection Gate 호출 형식 (Layer 1 / §12)

각 stage 에서 `AskUserQuestion` 호출 시:

```
question: "What helper should run for <stage>?"
options:
  - { label: "<Recommended> (Recommended)", description: "<Why> + <Pros/Cons/Cost>" }
  - { label: "<Alt1>", description: "<...>" }
  - { label: "<Alt2>", description: "<...>" }
  - { label: "Skip helper", description: "Continue baseline without helper" }
  # "Other" 자동 제공
```

---

## 미존재 helper 가 사용자 환경에 추가될 때

가이드가 명시한 helper (`to-prd`, `grill-me`, `tdd`, `diagnose`) 가 사용자 환경에 추가되면:
- 본 스킬을 수정하여 추천 helper 에 포함
- routing matrix 업데이트
- §12 Helper-by-Helper Mapping 에 해당 helper 추가 (Layer 2 vs Layer 3 결정)
