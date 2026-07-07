# Explicit-Only Skills (가이드 §15 인용 사본 + 사용자 환경 자동 차단 목록)

> 출처: `realizesoft/realizesoft-cross-runtime-skill-guide.md` §15 Explicit-Only Skills. 원본 가이드 파일은 수정하지 않으며, 본 파일은 인용 사본 + Claude Code 글로벌 스킬 환경의 자동 spawn 차단 목록이다.

---

## 가이드 §15 원문 (인용)

> Do not include these in the normal path unless the user explicitly asks or the scenario directly requires them.
>
> | Skill Type | Why explicit-only |
> |---|---|
> | harness loop | broad orchestration and repeated quality rounds |
> | agent teams / sub-agents | real delegation requires explicit user authorization |
> | continuous QA loop | repeated automated fix and verify can be expensive |
> | ultradetail walk/loop | exhaustive browser inspection is high cost |
> | full project bootstrap/kickstart | may overwrite the baseline lifecycle |
> | deep/full/team thinking chains | can duplicate selected `cynefin`, `what`, `first-principles` flow |
> | external record writers | ADR/DDR/journal writes need separate user intent |

---

## 사용자 환경 매핑 (자동 spawn 차단 목록)

본 스킬은 다음 helper 들의 **자동 spawn 시도를 차단**. 사용자가 직접 트리거 키워드를 입력할 때만 호출됨 (Q4 explicit approval).

| 가이드 §15 카테고리 | 사용자 환경 실제 스킬 | 자동 차단 처리 |
|---|---|---|
| **Harness loops** | `harness-loop` | 자동 추천 X. 사용자 명시 "/harness" 키워드 입력 시만 |
| **Agent teams / sub-agents** | `agent-teams-code-review` / `agent-teams-deep-analysis` / `agent-teams-feature-dev` / `agent-teams-orchestrator` / `agent-teams-reactive-dev` / `agent-teams-orchestrator` | 자동 추천 X. 사용자가 명시 키워드 입력 시만. Agent 도구 호출 시점 Q4 발동 |
| **Continuous QA** | `continuous-qa-loop` | 자동 추천 X. "continuous QA", "반복 QA", "QA 루프" 등 명시 시만 |
| **Ultradetail walks** | `ultradetail-walk`, `ultradetail-loop`, `ultra-walk-deep`, `walk-all-deep` | 자동 추천 X. "ultradetail", "전수 검수", "walk" 등 명시 시만. 비용 경고 동반 |
| **Full project bootstrap** | `project-bootstrapper`, `project-kickstart`, `pipeline-orchestrator` | 자동 추천 X. "/kickstart", "/bootstrap", "/파이프라인" 등 명시 시만. baseline 덮어쓰기 위험 경고 동반 |
| **Thinking chains** | `think-lite`, `think-full`, `first-principles` | 자동 추천 X. "/think-lite" 등 명시 시만. `cynefin` / `what` / `first-principles` 와 중복 가능성 안내 |
| **External record writers** | Cantos MCP (`mcp__cantos__create_adr` / `mcp__cantos__create_ddr` 등), `journal` 커맨드 | 자동 호출 X. 사용자가 ADR/DDR/journal 명시 요청 시만 |

---

## Q4 Approval 발동 시점

가이드 §10 의 Gate Model:

> | Source Gate | RealizeSoft Handling |
> |---|---|
> | "Wait for explicit approval" | Q3 blocking stage gate |
> | "AskUserQuestion" or question file | Runtime-native question gate or blocking text fallback |
> | Extension opt-in | Q2/Q3 selection gate depending on impact |
> | Destructive/external/deploy/credential action | Q4 explicit approval |
> | Agent/team/task execution | Q4 if it creates real delegation or external effects |

본 스킬은 위 매핑대로:
- Explicit-only skill 호출 = "Agent/team/task execution" = **Q4 explicit approval 필수**
- AskUserQuestion 의 question 에 "이 작업은 비용/시간이 큽니다. 정말 진행할까요?" 포함

---

## Spawn 차단 메커니즘 (실제 동작)

본 스킬이 활성화된 상태에서 explicit-only helper 가 호출되는 경로는 3가지:

1. **사용자 명시 키워드 입력** → 본 스킬은 그 호출을 인지하고 Q4 AskUserQuestion 으로 확인 (예: "harness-loop 을 호출하셨습니다. 비용 ~30분 / 라운드 20+. 진행할까요?") → 사용자 승인 후만 실제 invoke
2. **본 스킬의 Selection Gate 가 추천** → **금지** (본 스킬은 explicit-only 를 추천 후보에 포함시키지 않음)
3. **다른 helper 가 spawn 시도** → 본 스킬이 가로채서 Q4 AskUserQuestion 으로 사용자 승인 받기

### 차단 실패 시 (현실적 한계)

본 스킬은 hook / settings.json 레벨 차단이 아닌 SKILL.md 정책 차단이므로, AI 모델이 본 스킬의 정책을 무시하고 직접 helper 를 invoke 하면 차단 못 함. 다만:
- AI 가 본 스킬을 인지한 상태에서 정책 위반은 self-justification 으로 분류 (글로벌 룰 §2 위배)
- 사용자가 위반 발견 시 명시 지적 → 다음 라운드부터 차단 강화
