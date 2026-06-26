# Non-Negotiable Rules (가이드 §4 인용 사본)

> 출처: `realizesoft/realizesoft-cross-runtime-skill-guide.md` §4 Non-Negotiable Rules. 원본 가이드 파일은 절대 수정하지 않으며, 본 파일은 인용 사본이다.

본 스킬이 활성화된 모든 워크플로우에서 이하 7개 규칙은 **하드 제약**. 어떤 helper routing 결정도 위배 불가.

---

## §4.1 Preserve The Baseline

> Do not edit or rewrite the original AI-DLC lifecycle file unless the user explicitly asks to update that source.
>
> Create a separate RealizeSoft layer file, skill, command, or steering document.

**본 스킬의 실현**: `aidlc-baseline` 의 `SKILL.md` 와 `references/aws-aidlc-rule-details/` 는 절대 수정하지 않는다. 본 스킬은 별도 디렉토리 `aidlc-realizesoft/`.

---

## §4.2 No Hidden Helper Execution

> Do not silently run every available helper skill.
>
> Before using a helper that changes scope, cost, file writes, external calls, deployment, verification depth, or agent execution, present a user-choice gate.

**본 스킬의 실현**: §6 Selection Gate Protocol (Layer 1 of Universal AskUserQuestion Wrapper). helper 호출 전 반드시 `AskUserQuestion` 으로 blocking gate.

---

## §4.3 Preserve Input Gates

> If a helper skill says it requires a user question, confirmation loop, requestInput, approval, or safety gate, preserve that gate.
>
> Default mode: **Strict Gate Preservation**
>
> Meaning:
> - Q0: proceed unless target or safety boundary is unclear
> - Q1: ask when interface, scope, or artifact path affects behavior
> - Q2: expose as a user-choice gate
> - Q3: expose as a blocking stage or decision gate
> - Q4: always require explicit approval
>
> Q4 gates must never be skipped or merged.

**본 스킬의 실현**: §12 Universal AskUserQuestion Wrapper 의 Layer 2 (보존) + Layer 3 (helper 가 자체 gate 없으면 본 스킬이 wrapper). Q4 게이트는 절대 skip / merge 안 함.

---

## §4.4 UserChoice Records

> Decision support artifacts and final user decisions must be separated from application code.
>
> Default path:
> ```
> aidlc-docs/UserChoice/<stage>/<gate-slug>/
> ```
>
> Only create `decision.md` after the user has chosen.

**본 스킬의 실현**: §9 UserChoice Standard. 사용자 선택 후만 `decision.md` 생성. 빈 placeholder 만들지 않음.

---

## §4.5 Provider-Neutral Deployment

> Do not treat Vercel, AWS, GCP, Azure, Cloudflare, Firebase, Supabase, or any other platform as universally default.
>
> Open a deployment provider gate first.

**본 스킬의 실현**: §8 Deployment Provider Gate. 9개 옵션 (Plan-only 가 Recommended) + AskUserQuestion 4 옵션 한도로 2단계 gate 분할.

---

## §4.6 No Fake Runtime Equivalence

> Do not claim that Claude, Kiro, and Codex execute skills the same way.
>
> Write runtime-specific notes:
> - what is equivalent in outcome
> - what is not guaranteed
> - which local files/tools control behavior in that runtime

**본 스킬의 실현**: frontmatter 가 Claude Code 전용 명시. `references/runtime-gate-mapping.md` 에 Claude 한정 동작 명시.

---

## §4.7 Separate Lifecycle Sources From Product Inputs

> When creating a generic RealizeSoft skill, command, or steering workflow, do not use product requirements as the baseline lifecycle.
>
> Lifecycle sources define how the AI-DLC process operates:
>
> ```
> .claude/CLAUDE.md
> .aws-aidlc-rule-details/
> .kiro/steering/
> .kiro/aws-aidlc-rule-details/
> codex-skills/aidlc-codex/SKILL.md
> codex-skills/aidlc-codex/references/
> ~/.codex/skills/aidlc-codex/
> ```
>
> Product inputs define what a specific app should do:
>
> ```
> requirements/
> docs/prd*
> docs/product*
> constraints.md
> feature specs
> app source code
> sample project files
> ```
>
> Product inputs are valid when applying a finished skill to a specific project. They are not valid when generating the generic RealizeSoft skill itself, unless the user explicitly requests a project-specific adapter.

**본 스킬의 실현**: §10 Workflow Step 2 — Classify and exclude product inputs. 워크스페이스의 `requirements/` 등은 generic lifecycle source 로 사용 안 함.

---

## §4.8 Missing Baseline Protocol (참고)

> If `aidlc-codex` or another expected baseline is missing:
> 1. Do not fail immediately.
> 2. Search for other AI-DLC lifecycle sources in the current workspace.
> 3. If a Claude/Kiro rule bundle exists, extract the lifecycle from that bundle.
> 4. If only product requirements exist, do not treat them as lifecycle rules.
> 5. If no lifecycle source exists, present a Baseline Source Gate:
>    - import or provide an AI-DLC lifecycle package
>    - generate a reconstructed generic baseline
>    - stop and keep the guide as planning-only
> 6. Record which path was used in the generated RealizeSoft layer.

**본 스킬의 실현**: `aidlc-baseline` 스킬이 baseline 으로 사전 설치되어 있다고 가정. 미설치 시 본 스킬은 사용자에게 baseline 설치 안내 (Baseline Source Gate 와 동등).
