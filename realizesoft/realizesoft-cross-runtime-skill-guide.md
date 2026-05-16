# RealizeSoft Cross-Runtime Skill Guide

## 1. Purpose

This document explains how to create a RealizeSoft-style AI-DLC skill, command, or steering workflow in Codex, Claude, Kiro, or any similar AI runtime when equivalent local skill files, command files, steering files, or lifecycle rule documents may exist in different forms.

`aidlc-codex` is one possible Codex-native baseline implementation. It is not a universal prerequisite. Claude and Kiro environments usually will not have `aidlc-codex`, so the first job is to discover, extract, or reconstruct the baseline AI-DLC lifecycle from the runtime's own local rule package before adding the RealizeSoft layer.

The goal is not to copy one runtime's mechanics into another. The goal is to preserve the same operating philosophy:

- discover the original AI-DLC lifecycle source before treating anything as the baseline
- keep the original AI-DLC lifecycle as the baseline when it exists
- reconstruct a documented generic baseline only when no original baseline package exists
- attach helper skills only as conditional modules
- show user-choice gates before important branches
- preserve each helper skill's own input or approval gates
- record user choices and evidence in a dedicated `UserChoice` area
- keep deployment provider-neutral
- avoid silently spawning agents, deploying, or writing externally
- exclude product-specific requirements from generic skill generation unless the user explicitly wants a project-specific adapter

## 2. Scope

This guide is for building a cross-runtime RealizeSoft layer from Markdown instructions. It supports three source situations:

| Situation | Meaning | Required behavior |
|---|---|---|
| Native baseline exists | The runtime already has a local AI-DLC lifecycle package, such as Codex `aidlc-codex`, Claude `.claude/CLAUDE.md` plus rule details, or Kiro steering plus rule details. | Extract that lifecycle and preserve it. |
| Portable source baseline exists | The current runtime lacks `aidlc-codex`, but a Claude/Kiro/Codex AI-DLC rule bundle is present in the workspace. | Convert that bundle into the current runtime's skill/command/steering format without importing product requirements. |
| No baseline exists | No recognizable AI-DLC lifecycle package exists. | Ask for approval to create a generic minimal AI-DLC baseline from this guide's stage model and mark it as reconstructed, not original. |

It assumes at least one of these is true:

- a baseline AI-DLC lifecycle exists in the current runtime
- a portable AI-DLC lifecycle package exists in the workspace
- the user explicitly approves creation of a generic reconstructed baseline
- helper skills or equivalent command/agent/steering files exist, or the user only wants the RealizeSoft shell first
- each helper has at least a name, trigger description, workflow, and gate/safety rules when it is routed
- the runtime can read Markdown files and follow local project instructions

It does not assume:

- `aidlc-codex` is available outside Codex
- Codex `SKILL.md` is available in Claude or Kiro
- Claude `.claude/CLAUDE.md` auto-loading exists in Codex
- Kiro steering behavior exists in Codex or Claude
- sub-agent tools are always available
- deployment credentials are available
- project `requirements/`, PRDs, app constraints, or sample specs are valid sources for generic skill generation

## 3. Core Architecture

RealizeSoft is a thin extension layer over a discovered AI-DLC lifecycle.

```text
User Request
  ↓
Baseline Source Discovery
  ├─ find runtime lifecycle files
  ├─ classify lifecycle vs helper vs product input
  ├─ exclude product-specific requirements
  ├─ extract stage model and gates
  └─ create baseline capability manifest
  ↓
RealizeSoft Layer
  ├─ read baseline lifecycle
  ├─ classify current AI-DLC stage
  ├─ propose helper skills only when useful
  ├─ open user-choice gates
  ├─ preserve helper input gates
  └─ record choices under UserChoice
  ↓
Baseline AI-DLC Stage Continues
```

The RealizeSoft layer must not replace the baseline lifecycle. It only decides whether a helper skill should be attached to a stage.

If no baseline lifecycle can be discovered, RealizeSoft must not pretend one exists. It must either stop for user input or create a clearly labeled reconstructed baseline after approval.

## 4. Non-Negotiable Rules

### 4.1 Preserve The Baseline

Do not edit or rewrite the original AI-DLC lifecycle file unless the user explicitly asks to update that source.

Create a separate RealizeSoft layer file, skill, command, or steering document.

### 4.2 No Hidden Helper Execution

Do not silently run every available helper skill.

Before using a helper that changes scope, cost, file writes, external calls, deployment, verification depth, or agent execution, present a user-choice gate.

### 4.3 Preserve Input Gates

If a helper skill says it requires a user question, confirmation loop, requestInput, approval, or safety gate, preserve that gate.

Default mode:

```text
Strict Gate Preservation
```

Meaning:

- Q0: proceed unless target or safety boundary is unclear
- Q1: ask when interface, scope, or artifact path affects behavior
- Q2: expose as a user-choice gate
- Q3: expose as a blocking stage or decision gate
- Q4: always require explicit approval

Q4 gates must never be skipped or merged.

### 4.4 UserChoice Records

Decision support artifacts and final user decisions must be separated from application code.

Default path:

```text
aidlc-docs/UserChoice/<stage>/<gate-slug>/
```

Only create `decision.md` after the user has chosen.

### 4.5 Provider-Neutral Deployment

Do not treat Vercel, AWS, GCP, Azure, Cloudflare, Firebase, Supabase, or any other platform as universally default.

Open a deployment provider gate first.

### 4.6 No Fake Runtime Equivalence

Do not claim that Claude, Kiro, and Codex execute skills the same way.

Write runtime-specific notes:

- what is equivalent in outcome
- what is not guaranteed
- which local files/tools control behavior in that runtime

### 4.7 Separate Lifecycle Sources From Product Inputs

When creating a generic RealizeSoft skill, command, or steering workflow, do not use product requirements as the baseline lifecycle.

Lifecycle sources define how the AI-DLC process operates:

```text
.claude/CLAUDE.md
.aws-aidlc-rule-details/
.kiro/steering/
.kiro/aws-aidlc-rule-details/
codex-skills/aidlc-codex/SKILL.md
codex-skills/aidlc-codex/references/
~/.codex/skills/aidlc-codex/
```

Product inputs define what a specific app should do:

```text
requirements/
docs/prd*
docs/product*
constraints.md
feature specs
app source code
sample project files
```

Product inputs are valid when applying a finished skill to a specific project. They are not valid when generating the generic RealizeSoft skill itself, unless the user explicitly requests a project-specific adapter.

### 4.8 Missing Baseline Protocol

If `aidlc-codex` or another expected baseline is missing:

1. Do not fail immediately.
2. Search for other AI-DLC lifecycle sources in the current workspace.
3. If a Claude/Kiro rule bundle exists, extract the lifecycle from that bundle.
4. If only product requirements exist, do not treat them as lifecycle rules.
5. If no lifecycle source exists, present a Baseline Source Gate:
   - import or provide an AI-DLC lifecycle package
   - generate a reconstructed generic baseline
   - stop and keep the guide as planning-only
6. Record which path was used in the generated RealizeSoft layer.

## 5. Baseline AI-DLC Stages

Use the baseline lifecycle's own stage names when available. If not, map to this generic structure:

| Generic Stage | Purpose |
|---|---|
| Orient / Workspace Detection | understand repo, objective, constraints |
| Requirements / Discovery | clarify requirements, PRD, domain, UX |
| Planning / Design | decide stages, architecture, assumptions |
| Implementation / Construction | generate or modify code safely |
| Verification / QA | build, test, browser, security, UI checks |
| Deployment / Operations | provider choice, runbook, deploy approval |
| Knowledge / Handoff | decisions, ADR/DDR, session continuity |

## 6. Baseline Source Discovery

Before writing any runtime-specific RealizeSoft file, identify what counts as the baseline lifecycle.

### 6.1 Source Priority

Use this priority order.

| Priority | Source Type | Use As Baseline? | Notes |
|---|---|---:|---|
| 1 | Runtime-native AI-DLC lifecycle package | Yes | Best source because it already matches the runtime. |
| 2 | Portable AI-DLC lifecycle bundle from another runtime | Yes, after porting | Preserve behavior but adapt entrypoints and gates. |
| 3 | Existing generated AI-DLC artifacts | Limited | Use only to infer stage names/state; avoid product content. |
| 4 | Product requirements or app specs | No | Use later as project input, not as generic skill source. |
| 5 | Generic stage model from this guide | Only with approval | Mark as reconstructed baseline. |

### 6.2 Runtime Source Matrix

| Runtime Target | Preferred Baseline Sources | Helper Sources | Excluded By Default For Generic Skill Generation |
|---|---|---|---|
| Codex | `~/.codex/skills/aidlc-codex/SKILL.md`, `~/.codex/skills/aidlc-codex/references/`, repo `codex-skills/aidlc-codex/` | other `~/.codex/skills/*`, repo skill copies, plugin skills | app `requirements/`, PRDs, unrelated `aidlc-docs/`, source code |
| Claude | `.claude/CLAUDE.md`, `.aws-aidlc-rule-details/`, `.aidlc-rule-details/`, `.aidlc/aidlc-rules/aws-aidlc-rule-details/` | `.claude/commands/`, `.claude/agents/`, `.claude/rules/` | `requirements/`, project constraints, app-specific docs, sample feature specs |
| Kiro | `.kiro/steering/*.md`, `.kiro/aws-aidlc-rule-details/`, `.aidlc-rule-details/` | `.kiro/specs/*` only as project-specific context unless it contains reusable process rules | `requirements/`, `design/`, `tasks/` when they describe a specific product or feature |
| Unknown Markdown Runtime | top-level lifecycle/rules docs that describe process, gates, stages, artifacts, approvals | command/agent/prompt files with reusable triggers and safety rules | product docs, generated artifacts, example app requirements |

### 6.3 Product Requirement Exclusion Rule

When the goal is "create a reusable RealizeSoft-style skill", these files are ignored by default:

```text
requirements/
requirements/*.md
docs/requirements*
docs/prd*
docs/product*
constraints.md
feature.md
spec.md
user-stories.md
```

They may be read only in these cases:

- the user explicitly asks for a project-specific RealizeSoft adapter
- the task is to apply an already-created RealizeSoft skill to the project
- a generated lifecycle artifact must be checked for contamination
- the file contains process rules, not product requirements, and this is verified from its content

### 6.4 Concrete Example: `table-order-macos-claudecode`

For this input package:

```text
/Users/leesungmin/Desktop/AWS/table-order-macos-claudecode
```

Use these as baseline lifecycle sources:

```text
table-order-macos-claudecode/.claude/CLAUDE.md
table-order-macos-claudecode/.aws-aidlc-rule-details/
```

Ignore these for generic RealizeSoft skill generation:

```text
table-order-macos-claudecode/requirements/
```

Reason:

- `.claude/CLAUDE.md` defines workflow priority, stage order, loading rules, extension loading, approval behavior, and file writing discipline.
- `.aws-aidlc-rule-details/` defines reusable lifecycle stage rules.
- `requirements/` defines the table-order product. It is a project input for applying a skill, not a source for creating the generic skill.

## 7. Baseline Lifecycle Extraction Algorithm

Use this algorithm before creating any RealizeSoft layer.

### Step 1. Inventory Candidate Files

List candidate files and classify them.

| Classification | Meaning | Examples |
|---|---|---|
| `baseline-lifecycle` | reusable process, stage, approval, artifact, or workflow rules | `CLAUDE.md`, `SKILL.md`, steering rules, AI-DLC rule details |
| `helper-module` | optional workflow that can be routed into a stage | command files, agent files, skills, QA helpers |
| `project-input` | product-specific requirement, constraint, PRD, or sample app content | `requirements/`, `constraints.md`, feature docs |
| `generated-artifact` | output from a previous lifecycle run | `aidlc-docs/`, generated designs, generated tasks |
| `runtime-config` | runtime behavior or permissions | `AGENTS.md`, tool config, sandbox notes |

Only `baseline-lifecycle` and selected `helper-module` files can shape the generic RealizeSoft skill.

### Step 2. Resolve Baseline Root

Pick one baseline root and record why.

Recommended order:

1. Runtime-native AI-DLC root.
2. Portable AI-DLC rule bundle.
3. Reconstructed generic baseline with explicit approval.

Do not merge multiple lifecycle roots unless the user explicitly wants a composite runtime. Merging can create conflicting stage orders and approval rules.

### Step 3. Extract Stage Model

For each lifecycle stage, extract:

| Field | Required? | Description |
|---|---:|---|
| Stage name | Yes | Original local name when available. |
| Purpose | Yes | What the stage is supposed to decide or produce. |
| Trigger | Yes | Always, conditional, opt-in, or explicit-only. |
| Inputs | Yes | Which files/context the stage reads. |
| Outputs | Yes | Which artifacts the stage writes. |
| Approval gate | Yes | Whether the user must approve before continuing. |
| Question format | Yes | requestInput, text gate, question file, multiple choice, etc. |
| Validation rules | Yes | Content, test, security, diagram, or consistency checks. |
| Runtime-specific behavior | Yes | What must be adapted in another runtime. |

### Step 4. Normalize Without Erasing

Map local stage names to generic areas only for routing.

```text
local stage name -> generic area -> RealizeSoft helper candidates
```

Do not rename the user's original lifecycle internally unless the target runtime requires it. The generated layer should preserve local terminology and only add a generic cross-reference.

### Step 5. Extract Gate Model

Identify every gate.

| Source Gate | RealizeSoft Handling |
|---|---|
| "Wait for explicit approval" | Q3 blocking stage gate |
| "AskUserQuestion" or question file | Runtime-native question gate or blocking text fallback |
| Extension opt-in | Q2/Q3 selection gate depending on impact |
| Destructive/external/deploy/credential action | Q4 explicit approval |
| Agent/team/task execution | Q4 if it creates real delegation or external effects |

### Step 6. Create Baseline Capability Manifest

Before writing the final skill/command/steering file, create a mental or written manifest:

```md
# Baseline Capability Manifest

## Source Root

## Runtime Target

## Extracted Stages

| Stage | Trigger | Inputs | Outputs | Gate | Validation |
|---|---|---|---|---|---|

## Excluded Product Inputs

## Missing Baseline Pieces

## Runtime Adaptations Needed

## Confidence

High / Medium / Low
```

Low confidence requires a user gate before implementation.

### Step 7. Attach RealizeSoft Layer

Only after the baseline manifest is clear, add:

- conditional helper routing
- Selection Gates
- Strict Gate Preservation
- UserChoice records
- provider-neutral deployment gate
- explicit-only exclusions
- runtime boundary notes

## 8. Missing `aidlc-codex` Decision Tree

Use this decision tree whenever the intended RealizeSoft design mentions `aidlc-codex`, but the target runtime does not have it.

```text
Does target runtime have aidlc-codex?
  ├─ Yes
  │   └─ Use aidlc-codex as native baseline.
  └─ No
      ├─ Does workspace contain Claude AI-DLC rules?
      │   └─ Use .claude/CLAUDE.md + rule details as portable baseline.
      ├─ Does workspace contain Kiro AI-DLC steering/rules?
      │   └─ Use .kiro steering + rule details as portable baseline.
      ├─ Does workspace contain another process lifecycle?
      │   └─ Extract if it defines stages, gates, artifacts, and validation.
      ├─ Does workspace contain only requirements/product docs?
      │   └─ Do not create generic skill from them. Ask for baseline or approval to reconstruct.
      └─ No lifecycle source
          └─ Offer reconstructed generic baseline with clear lower-confidence label.
```

Generated wording should be honest:

```text
This RealizeSoft layer is based on the Claude AI-DLC rule bundle, not on aidlc-codex.
```

or:

```text
No original AI-DLC baseline was found. This layer uses a reconstructed generic baseline from the cross-runtime guide.
```

## 9. Recommended Helper Routing

Use these as a starting routing map. Rename skills to match the local runtime if needed.

| AI-DLC Area | Helper Type | Use When |
|---|---|---|
| Orient / Purpose | `cynefin`, `what` | objective, complexity, or success criteria is unclear |
| Requirements / Discovery | `to-prd` | known context should become product requirements |
| Requirements / Discovery | `domain-researcher` | market, competitor, regulation, domain data, or tech evidence matters |
| Requirements / Discovery | `ux-pattern-researcher` | user flow, conversion, screen IA, or UI patterns matter |
| Planning / Design | `grill-me` | a load-bearing decision is unresolved |
| Planning / Design | `architect` | real architecture or project structure design is needed |
| Planning / Design | `first-principles` | assumptions behind a major choice could invalidate the plan |
| Implementation | `tdd` | observable behavior and a test runner exist |
| Implementation | `diagnose` | bug, failure, performance regression, or unclear behavior exists |
| Implementation | JS/TS refactor helper | JavaScript/TypeScript cleanup or rename is requested |
| Verification | `webapp-testing` | browser behavior, screenshots, console, or local web flow must be checked |
| Verification | `security-audit` | auth, input validation, dependencies, or OWASP concerns exist |
| Verification | UI guidelines helper | accessibility, semantic HTML, responsive, UI quality checks matter |
| Verification | `live-verify-loop` | live browser proof must repeat until criteria pass |
| Deployment | provider-neutral gate | deployment or operations is in scope |
| Deployment | provider adapter | user chooses a provider and approves external writes |

## 10. Selection Gate Template

Use this format in any runtime.

```text
<Stage> Selection Gate

Goal:
<what this choice controls>

Option 1. <name> (Recommended)
Why recommended:
Pros:
Cons:
Cost/speed/risk:
Expected artifacts:
UserChoice record:

Option 2. <name>
Pros:
Cons:
Cost/speed/risk:

Choose:
1. Option 1
2. Option 2
```

Rules:

- put the recommended option first
- explain why it is recommended
- explain tradeoffs, not just labels
- stop until the user chooses
- record the result after selection

## 11. Runtime Gate Mapping

### 11.1 Codex

Codex implementation usually maps to:

```text
~/.codex/skills/<skill-name>/SKILL.md
~/.codex/skills/<skill-name>/references/*.md
~/.codex/skills/<skill-name>/agents/openai.yaml
```

Codex baseline handling:

1. If `aidlc-codex` exists, use it as the native baseline.
2. If `aidlc-codex` is missing but a Claude/Kiro AI-DLC bundle is present in the repo, extract a portable baseline from that bundle.
3. If no AI-DLC lifecycle exists, open the Baseline Source Gate before creating a reconstructed generic baseline.
4. Never use product `requirements/` as a substitute for missing `aidlc-codex`.

Codex gate behavior:

- use `request_user_input` when available
- use text fallback only when project/session/global policy permits it
- use `update_plan` for multi-step work
- do not use `spawn_agent` unless the user explicitly asks for sub-agents, parallel work, delegation, Agent Teams, worker/evaluator execution, or harness loop

Codex skill frontmatter example:

```md
---
name: aidlc-RealizeSoft
description: AI-DLC extension layer that preserves the baseline lifecycle, routes helper skills through user-choice gates, records UserChoice decisions, and keeps deployment provider-neutral.
---
```

### 11.2 Claude

Claude implementation may map to one or more of:

```text
.claude/commands/<command>.md
.claude/agents/<agent>.md
.claude/rules/*.md
CLAUDE.md
.aws-aidlc-rule-details/
.aidlc-rule-details/
```

Claude baseline handling:

1. Prefer `.claude/CLAUDE.md` when it defines workflow priority, stage order, loading rules, approvals, and artifact rules.
2. Resolve the rule details directory using the source workflow's own priority order, for example `.aws-aidlc-rule-details/`, `.aidlc-rule-details/`, or `.aidlc/aidlc-rules/aws-aidlc-rule-details/`.
3. Treat `.claude/commands/` and `.claude/agents/` as helper sources unless they define the primary lifecycle.
4. Ignore `requirements/` for generic skill generation. Use it only when applying the finished command to that specific project.

Claude gate behavior:

- if the source workflow says `AskUserQuestion`, convert it to an explicit blocking question
- do not rely on a casual "맞나요?" loop if the workflow requires a gate
- if Claude has task/agent tools, do not treat textual "Agent" labels as permission to spawn real agents
- record selected decisions under the same `aidlc-docs/UserChoice/` convention

Claude command skeleton:

```md
# aidlc-RealizeSoft

Use this command to run the baseline AI-DLC workflow with RealizeSoft helper routing.

## Runtime Boundary

- Preserve the original lifecycle.
- If no Codex `aidlc-codex` exists, use the Claude AI-DLC rule bundle as the baseline.
- Do not auto-run all helper commands.
- Ask blocking user-choice questions before conditional helpers.
- Preserve each helper's own approval/input flow.
- Do not import product requirements into this reusable command.

## Workflow

1. Resolve baseline sources from `.claude/CLAUDE.md` and rule details.
2. Classify and exclude product inputs such as `requirements/`.
3. Extract stage, gate, artifact, and validation rules.
4. Detect current AI-DLC stage.
5. Open Selection Gate for matching helpers.
6. Execute selected helper instructions.
7. Continue the baseline lifecycle.
8. Write `aidlc-docs/UserChoice/.../decision.md` after the user chooses.
```

### 11.3 Kiro

Kiro implementation may map to:

```text
Reusable baseline sources:
.kiro/steering/*.md
.kiro/aws-aidlc-rule-details/

Project artifacts, not generic baseline by default:
.kiro/specs/<feature>/*.md
requirements/
design/
tasks/
```

Kiro baseline handling:

1. Prefer `.kiro/steering/*.md` and `.kiro/aws-aidlc-rule-details/` when they define reusable lifecycle behavior.
2. Treat `.kiro/specs/<feature>/`, `requirements/`, `design/`, and `tasks/` as project artifacts by default.
3. Use project artifacts only to infer a project-specific adapter or current stage, not to generate the generic RealizeSoft steering file.
4. If no reusable Kiro steering or rule details exist, open the Baseline Source Gate.

Kiro gate behavior:

- map RealizeSoft rules into steering documents
- keep steering and reusable rule details as the baseline lifecycle
- keep requirements/design/tasks as target project artifacts unless explicitly building a project-specific adapter
- use steering to require selection gates before optional helper workflows
- record decisions under `aidlc-docs/UserChoice/` or a Kiro project-equivalent decision folder

Kiro steering skeleton:

```md
# RealizeSoft Steering

## Baseline

Use Kiro steering and reusable AI-DLC rule details as the lifecycle baseline.

Do not use product `requirements/`, `design/`, or `tasks/` as generic skill-generation sources unless the user asks for a project-specific adapter.

## Helper Routing

Optional helper workflows must be proposed through Selection Gates.

## Strict Gate Preservation

If a helper requires user input, confirmation, or approval, preserve it.

## UserChoice

After the user chooses, write:

aidlc-docs/UserChoice/<stage>/<gate>/decision.md
```

## 12. UserChoice Standard

Directory:

```text
aidlc-docs/UserChoice/
├── orient/
├── requirements-discovery/
├── planning-design/
├── implementation/
├── verification/
├── deployment/
└── uiux/
```

Gate directory:

```text
aidlc-docs/UserChoice/<stage>/<gate-slug>/
├── ascii-wireframe.txt
├── preview.html
├── external-input.txt
└── decision.md
```

Create only useful support artifacts. Do not create empty placeholders.

`decision.md` template:

```md
# User Choice Decision

## Pipeline Stage

## Gate

## Options Presented

## Recommended Option

## Why Recommended

## User Selection

## Evidence Flow

## Tradeoffs

## Input Gate Mode

## Triggered Skill Gates

| Skill | Gate Profile | Applied As | Reason |
|---|---|---|---|

## Resulting Pipeline Behavior

## Files Created

## Remaining Risks
```

## 13. UI/UX Decision Gate

When a UI/UX decision needs representation, ask the user how to review it.

```text
UI/UX Decision Gate

1. ASCII Wireframe (Recommended for quick structure)
   Pros: fast, readable in chat, good for information architecture.
   Cons: weak for visual polish and responsive judgment.

2. HTML Preview
   Pros: closer to real layout, flow, and visual state.
   Cons: requires file creation and more verification time.

3. External Reference Input
   Pros: can use Figma, Notion, screenshots, URLs, or user-provided style direction.
   Cons: quality depends on provided references.
```

If option 3 is selected, accept:

- Figma link
- Notion page
- screenshot or image path
- reference website URL
- free-form style description

## 14. Deployment Provider Gate

Use this gate before any deployment plan or execution.

```text
Deployment Provider Gate

1. Plan only (Recommended when credentials/tools are unclear)
2. AWS
3. Google Cloud
4. Azure
5. Cloudflare
6. Firebase
7. Supabase
8. Vercel
9. Self-hosted / VPS
```

Selection criteria:

| Criterion | Consider |
|---|---|
| App shape | static, SSR, API server, container, serverless, worker |
| Runtime | Node, Python, Go, JVM, Docker, edge runtime |
| Data | database, auth, storage, queue, cache |
| Traffic | PoC, startup, enterprise, regional needs |
| Operations | managed service vs user-managed infra |
| Cost | free tier, low-cost preview, scaling cost |
| Region/regulation | data residency, privacy, compliance |
| Tool availability | CLI, token, MCP, CI/CD, IaC |
| Rollback | preview, staged rollout, rollback path |

Actual deploys, production changes, domain changes, external writes, credentials, or cost-impacting work require explicit safety approval.

## 15. Explicit-Only Skills

Do not include these in the normal path unless the user explicitly asks or the scenario directly requires them.

| Skill Type | Why explicit-only |
|---|---|
| harness loop | broad orchestration and repeated quality rounds |
| agent teams / sub-agents | real delegation requires explicit user authorization |
| continuous QA loop | repeated automated fix and verify can be expensive |
| ultradetail walk/loop | exhaustive browser inspection is high cost |
| full project bootstrap/kickstart | may overwrite the baseline lifecycle |
| deep/full/team thinking chains | can duplicate selected `cynefin`, `what`, `first-principles` flow |
| external record writers | ADR/DDR/journal writes need separate user intent |

## 16. Build Procedure For A New Runtime

Follow these steps to build a RealizeSoft-style skill from this MD.

1. Inventory candidate files in the source package.
2. Classify files as `baseline-lifecycle`, `helper-module`, `project-input`, `generated-artifact`, or `runtime-config`.
3. Exclude product inputs by default, especially `requirements/` and app-specific constraints.
4. Identify the baseline lifecycle root.
5. If no root exists, open the Baseline Source Gate before reconstructing anything.
6. Extract the stage model, gate model, artifact paths, validation rules, and runtime-specific behaviors.
7. Create or record a Baseline Capability Manifest.
8. Identify helper skill, command, agent, or steering files and their gate rules.
9. Create a new RealizeSoft layer file, not a patch to the baseline.
10. Add the non-negotiable rules from this guide.
11. Add the routing map with local helper names.
12. Add the Selection Gate template.
13. Add Strict Gate Preservation.
14. Add UserChoice artifact rules.
15. Add provider-neutral deployment rules.
16. Add explicit-only skill exclusions.
17. Add runtime-specific notes for Codex, Claude, or Kiro.
18. Verify the new file does not claim unsupported runtime behavior.
19. Verify no product requirements leaked into the generic skill.

## 17. Minimal Cross-Runtime Template

Use this as the starting Markdown when creating a new RealizeSoft layer.

```md
# aidlc-RealizeSoft

## Purpose

Run the baseline AI-DLC lifecycle with conditional helper skill routing.

## Runtime Boundary

- Preserve the baseline lifecycle.
- If the target runtime lacks `aidlc-codex`, discover or reconstruct the baseline first.
- Do not claim exact equivalence with other runtimes.
- Use this runtime's actual question, file, agent, and tool capabilities.
- Do not use product requirements as generic lifecycle rules.

## Baseline Discovery

1. Search for runtime-native lifecycle files.
2. Search for portable AI-DLC rule bundles.
3. Exclude product inputs such as `requirements/`.
4. If no lifecycle source exists, ask before generating a reconstructed baseline.

## Baseline Rule

Read the original AI-DLC lifecycle first. Do not edit it by default.

Record the selected baseline source:

Baseline source:
Excluded product inputs:
Runtime adaptations:
Confidence:

## Global Rules

1. Use Selection Gates before conditional helpers.
2. Preserve helper input gates under Strict Gate Preservation.
3. Write user decisions under `aidlc-docs/UserChoice/`.
4. Keep deployment provider-neutral.
5. Require explicit approval for destructive actions, external writes, production changes, credentials, deploys, and real agent execution.

## Routing

| Stage | Baseline | Conditional Helpers |
|---|---|---|
| Orient | baseline orient | cynefin, what |
| Requirements | baseline requirements | to-prd, domain-researcher, ux-pattern-researcher |
| Planning / Design | baseline planning/design | grill-me, architect, first-principles |
| Implementation | baseline construction | tdd, diagnose, refactor helper |
| Verification | baseline build/test | webapp-testing, security-audit, UI guidelines, live verify |
| Deployment | baseline infra/ops | provider-neutral gate, provider adapter |

## Completion

Report baseline source, excluded product inputs, stages used, helpers selected, UserChoice records, files changed, verification, runtime limits, and next step.
```

## 18. Verification Checklist

Before calling the new runtime skill complete, check:

- baseline source discovery was performed
- missing `aidlc-codex` was handled honestly
- baseline source was recorded
- product inputs were excluded or explicitly justified
- `requirements/` was not used as generic lifecycle source
- baseline AI-DLC file was not modified
- RealizeSoft layer is separate
- helper routing is conditional
- selection gates include recommendation, reason, pros, cons, and risk
- Strict Gate Preservation is present
- Q4 approval is mandatory
- UserChoice path and `decision.md` template are present
- deployment provider gate is not Vercel-only
- explicit-only skills are separated
- Claude/Kiro/Codex runtime differences are stated
- no project-specific requirements are embedded into the generic skill
- the generated layer states whether its baseline is native, ported, or reconstructed

## 19. Expected Outcome

If this guide is followed, Claude, Kiro, Codex, or another Markdown-driven agent runtime can produce a RealizeSoft-style skill that behaves the same in principle:

```text
baseline source discovered
  + product requirements excluded
  + baseline lifecycle preserved or clearly reconstructed
  + conditional helper routing
  + explicit user choices
  + preserved helper gates
  + recorded decisions
  + provider-neutral deployment
  + honest runtime boundaries
```
