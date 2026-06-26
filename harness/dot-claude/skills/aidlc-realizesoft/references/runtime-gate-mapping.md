# Runtime Gate Mapping (가이드 §11.2 인용 사본 + AskUserQuestion 매핑)

> 출처: `realizesoft/realizesoft-cross-runtime-skill-guide.md` §11.2 Claude. 원본 가이드 파일은 수정하지 않으며, 본 파일은 인용 사본 + Claude Code 환경에서의 AskUserQuestion 도구 매핑 명세다.

---

## 가이드 §11.2 Claude 원문 (인용)

> Claude implementation may map to one or more of:
>
> ```
> .claude/commands/<command>.md
> .claude/agents/<agent>.md
> .claude/rules/*.md
> CLAUDE.md
> .aws-aidlc-rule-details/
> .aidlc-rule-details/
> ```
>
> Claude baseline handling:
>
> 1. Prefer `.claude/CLAUDE.md` when it defines workflow priority, stage order, loading rules, approvals, and artifact rules.
> 2. Resolve the rule details directory using the source workflow's own priority order, for example `.aws-aidlc-rule-details/`, `.aidlc-rule-details/`, or `.aidlc/aidlc-rules/aws-aidlc-rule-details/`.
> 3. Treat `.claude/commands/` and `.claude/agents/` as helper sources unless they define the primary lifecycle.
> 4. Ignore `requirements/` for generic skill generation. Use it only when applying the finished command to that specific project.
>
> Claude gate behavior:
>
> - if the source workflow says `AskUserQuestion`, convert it to an explicit blocking question
> - do not rely on a casual "맞나요?" loop if the workflow requires a gate
> - if Claude has task/agent tools, do not treat textual "Agent" labels as permission to spawn real agents
> - record selected decisions under the same `aidlc-docs/UserChoice/` convention
>
> Claude command skeleton:
>
> ```md
> # aidlc-RealizeSoft
>
> Use this command to run the baseline AI-DLC workflow with RealizeSoft helper routing.
>
> ## Runtime Boundary
>
> - Preserve the original lifecycle.
> - If no Codex `aidlc-codex` exists, use the Claude AI-DLC rule bundle as the baseline.
> - Do not auto-run all helper commands.
> - Ask blocking user-choice questions before conditional helpers.
> - Preserve each helper's own approval/input flow.
> - Do not import product requirements into this reusable command.
>
> ## Workflow
>
> 1. Resolve baseline sources from `.claude/CLAUDE.md` and rule details.
> 2. Classify and exclude product inputs such as `requirements/`.
> 3. Extract stage, gate, artifact, and validation rules.
> 4. Detect current AI-DLC stage.
> 5. Open Selection Gate for matching helpers.
> 6. Execute selected helper instructions.
> 7. Continue the baseline lifecycle.
> 8. Write `aidlc-docs/UserChoice/.../decision.md` after the user chooses.
> ```

---

## 본 스킬의 Claude Code 매핑

가이드 §11.2 의 명세를 본 스킬에서 다음과 같이 실현:

### 매핑

| 가이드 명세 | 본 스킬 실현 |
|---|---|
| `.claude/CLAUDE.md` 우선 사용 | `aidlc-baseline` 스킬이 그 본문을 보존 → 본 스킬이 참조 |
| Rule details 우선순위 (`.aws-aidlc-rule-details/` 등) | `aidlc-baseline` 의 references/aws-aidlc-rule-details/ 가 첫 우선 (baseline 의 Skill Bundle Note 가 명시) |
| `.claude/commands/`, `.claude/agents/` 를 helper sources 로 | 본 스킬의 §4 Helper Routing Matrix 가 글로벌 `~/.claude/skills/` 의 스킬들을 helper sources 로 매핑 |
| `requirements/` 무시 (generic skill 생성 시) | 본 스킬의 §3 Rule 7 + §10 Workflow Step 2 |
| AskUserQuestion 으로 변환 | **본 스킬의 §12 Universal AskUserQuestion Wrapper** |
| "맞나요?" loop 의존 금지 | §12 Anti-Patterns 명시 |
| 텍스트 "Agent" 라벨을 real agent spawn 권한으로 해석 금지 | §5 Explicit-Only Skills 격리 (agent-teams-* 자동 차단) |
| `aidlc-docs/UserChoice/` 기록 | §9 UserChoice Standard |

### Claude command skeleton → 본 스킬 본문 매핑

| skeleton 섹션 | 본 스킬 섹션 |
|---|---|
| Runtime Boundary | §2 Layer Relationship + §3 Non-Negotiable Rules |
| Workflow Step 1 (Resolve baseline) | §10 Step 1 |
| Workflow Step 2 (Exclude product inputs) | §10 Step 2 |
| Workflow Step 3 (Extract stage/gate rules) | §10 Step 3 |
| Workflow Step 4 (Detect current stage) | §10 Step 4 |
| Workflow Step 5 (Selection Gate) | §10 Step 5 + §6 + §12 Layer 1 |
| Workflow Step 6 (Execute helper) | §10 Step 6 + §12 Layer 2/3 |
| Workflow Step 7 (Continue baseline) | §10 Step 7 |
| Workflow Step 8 (Write decision.md) | §10 Step 8 + §9 |

### Claude Code 한정 동작 (가이드 §4.6 No Fake Runtime Equivalence 정합)

- 본 스킬은 **Claude Code 전용**. frontmatter 가 description 에 명시
- Codex / Kiro 환경에서는 동등한 동작 보장 없음. 그 런타임에서는 본 가이드 §11.1 (Codex) 또는 §11.3 (Kiro) 의 별도 매핑이 필요
- 본 스킬의 `AskUserQuestion` 매핑은 Claude Code 의 native gate 도구. Codex 는 `request_user_input`, Kiro 는 별도 매핑
