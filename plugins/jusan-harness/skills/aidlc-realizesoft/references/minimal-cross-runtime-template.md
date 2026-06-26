# Minimal Cross-Runtime Template (가이드 §17 인용 사본)

> 출처: `realizesoft/realizesoft-cross-runtime-skill-guide.md` §17 Minimal Cross-Runtime Template. 원본 가이드 파일은 수정하지 않으며, 본 파일은 인용 사본 + 본 스킬이 따르는 구조 매핑이다.

---

## 가이드 §17 원문 (인용)

> Use this as the starting Markdown when creating a new RealizeSoft layer.
>
> ```md
> # aidlc-RealizeSoft
>
> ## Purpose
>
> Run the baseline AI-DLC lifecycle with conditional helper skill routing.
>
> ## Runtime Boundary
>
> - Preserve the baseline lifecycle.
> - If the target runtime lacks `aidlc-codex`, discover or reconstruct the baseline first.
> - Do not claim exact equivalence with other runtimes.
> - Use this runtime's actual question, file, agent, and tool capabilities.
> - Do not use product requirements as generic lifecycle rules.
>
> ## Baseline Discovery
>
> 1. Search for runtime-native lifecycle files.
> 2. Search for portable AI-DLC rule bundles.
> 3. Exclude product inputs such as `requirements/`.
> 4. If no lifecycle source exists, ask before generating a reconstructed baseline.
>
> ## Baseline Rule
>
> Read the original AI-DLC lifecycle first. Do not edit it by default.
>
> Record the selected baseline source:
>
> Baseline source:
> Excluded product inputs:
> Runtime adaptations:
> Confidence:
>
> ## Global Rules
>
> 1. Use Selection Gates before conditional helpers.
> 2. Preserve helper input gates under Strict Gate Preservation.
> 3. Write user decisions under `aidlc-docs/UserChoice/`.
> 4. Keep deployment provider-neutral.
> 5. Require explicit approval for destructive actions, external writes, production changes, credentials, deploys, and real agent execution.
>
> ## Routing
>
> | Stage | Baseline | Conditional Helpers |
> |---|---|---|
> | Orient | baseline orient | cynefin, what |
> | Requirements | baseline requirements | to-prd, domain-researcher, ux-pattern-researcher |
> | Planning / Design | baseline planning/design | grill-me, architect, first-principles |
> | Implementation | baseline construction | tdd, diagnose, refactor helper |
> | Verification | baseline build/test | webapp-testing, security-audit, UI guidelines, live verify |
> | Deployment | baseline infra/ops | provider-neutral gate, provider adapter |
>
> ## Completion
>
> Report baseline source, excluded product inputs, stages used, helpers selected, UserChoice records, files changed, verification, runtime limits, and next step.
> ```

---

## 본 스킬 SKILL.md 와의 매핑

| 가이드 §17 섹션 | 본 스킬 SKILL.md 섹션 |
|---|---|
| `## Purpose` | §1 Purpose |
| `## Runtime Boundary` | §2 Layer Relationship + §3 Non-Negotiable Rules |
| `## Baseline Discovery` | §10 Workflow Step 1-3 |
| `## Baseline Rule` | §2 Hard Constraint + Operational Notes 의 사전 조건 |
| `## Global Rules` 1 (Selection Gates) | §6 Selection Gate Protocol + §12 Layer 1 |
| `## Global Rules` 2 (Strict Gate Preservation) | §12 Layer 2 |
| `## Global Rules` 3 (UserChoice records) | §9 UserChoice Standard |
| `## Global Rules` 4 (provider-neutral) | §8 Deployment Provider Gate |
| `## Global Rules` 5 (explicit approval) | §5 Explicit-Only Skills + Q4 게이트 |
| `## Routing` | §4 Helper Routing Matrix (사용자 환경 매핑) |
| `## Completion` | §11 Completion Report |

본 스킬은 가이드 §17 의 minimal template 을 시작점으로, Claude Code 환경의 구체 매핑 + 사용자 명시 Universal AskUserQuestion Wrapper (§12) 를 추가하여 확장된 구조다.
