# Verification Checklist (가이드 §18 인용 사본 — RealizeSoft 항목)

> 출처: `realizesoft/realizesoft-cross-runtime-skill-guide.md` §18 Verification Checklist. 원본 가이드 파일은 수정하지 않으며, 본 파일은 인용 사본 + 본 스킬이 통과해야 하는 항목 명세다.

---

## 가이드 §18 원문 (인용)

> Before calling the new runtime skill complete, check:
>
> - baseline source discovery was performed
> - missing `aidlc-codex` was handled honestly
> - baseline source was recorded
> - product inputs were excluded or explicitly justified
> - `requirements/` was not used as generic lifecycle source
> - baseline AI-DLC file was not modified
> - RealizeSoft layer is separate
> - helper routing is conditional
> - selection gates include recommendation, reason, pros, cons, and risk
> - Strict Gate Preservation is present
> - Q4 approval is mandatory
> - UserChoice path and `decision.md` template are present
> - deployment provider gate is not Vercel-only
> - explicit-only skills are separated
> - Claude/Kiro/Codex runtime differences are stated
> - no project-specific requirements are embedded into the generic skill
> - the generated layer states whether its baseline is native, ported, or reconstructed

---

## 본 스킬의 체크 항목 통과 명세 (RealizeSoft 항목 11개)

스킬 1 (aidlc-baseline) 에서 N/A 또는 "스킬 2 의 책임" 으로 미루었던 항목들이 본 스킬에서 통과:

| # | 가이드 §18 체크 | 본 스킬 결과 | 증거 |
|:-:|---|:-:|---|
| 1 | RealizeSoft layer is separate | **O** | 본 스킬이 별도 디렉토리 `aidlc-realizesoft/`. aidlc-baseline 파일 0% 수정 |
| 2 | helper routing is conditional | **O** | §6 Selection Gate 후만 helper 실행 |
| 3 | Selection gates include recommendation, reason, pros, cons, and risk | **O** | §6 + references/selection-gate-template.md (가이드 §10 원문) → AskUserQuestion options 의 description 매핑 |
| 4 | Strict Gate Preservation is present | **O** | §3 Rule 3 + §12 Universal AskUserQuestion Wrapper Layer 2 |
| 5 | Q4 approval is mandatory | **O** | §5 Explicit-Only Skills + references/explicit-only-skills.md 의 Q4 발동 시점 |
| 6 | UserChoice path and `decision.md` template are present | **O** | §9 + references/userchoice-standard.md (가이드 §12 템플릿 13개 필드 그대로) |
| 7 | Deployment provider gate is not Vercel-only | **O** | §8 + references/deployment-provider-gate.md (9 옵션 + Plan-only Recommended) |
| 8 | Explicit-only skills are separated | **O** | §5 + references/explicit-only-skills.md (사용자 환경 자동 차단 목록 명시) |
| 9 | Claude/Kiro/Codex runtime differences are stated | **O** | §2 Layer Relationship "Claude native" 명시 + references/runtime-gate-mapping.md (가이드 §11.2 한정 동작) + §4.6 Rule 6 |
| 10 | No project-specific requirements are embedded into the generic skill | **O** | §3 Rule 7 (Product Input Exclusion) + 본 스킬에 어떤 product requirements 도 없음 |
| 11 | Generated layer states whether its baseline is native, ported, or reconstructed | **O** | README §1 "RealizeSoft layer (helper routing extension) for Claude native baseline" 명시 |

---

## 스킬 1 에서 이미 통과한 항목 (참고)

다음 항목들은 스킬 1 의 README + 본 plan 의 STEP 4 So What 에서 통과 명시:

| 가이드 §18 체크 | 스킬 1 결과 | 본 스킬 영향 |
|---|:-:|---|
| baseline source discovery was performed | O | 본 스킬도 §10 Step 1 으로 동일 실행 |
| missing `aidlc-codex` was handled honestly | O | 본 스킬도 Claude native baseline 사용 명시 |
| baseline source was recorded | O | 본 스킬 README 에 baseline 출처 명시 |
| product inputs were excluded or explicitly justified | O | §3 Rule 7 + §10 Step 2 |
| `requirements/` was not used as generic lifecycle source | O | §3 Rule 7 명시 |
| baseline AI-DLC file was not modified | O | §2 Hard Constraint 명시 ("절대 수정 안 함") |

---

## 본 스킬의 추가 검증 (Universal AskUserQuestion Wrapper)

가이드 §18 에는 명시되지 않은 사용자 명시 추가 요구 (2026-05-14):

| 추가 검증 항목 | 본 스킬 결과 | 증거 |
|---|:-:|---|
| 모든 helper trigger 에서 AskUserQuestion 발동 | **O** | §12 Layer 1 (Pre-Helper Selection Gate) |
| helper 자체 gate 보존 | **O** | §12 Layer 2 |
| helper 자체 gate 없는 경우 wrapper 적용 | **O** | §12 Layer 3 (default for [미확인] helper) |
| Anti-pattern 명시 (텍스트 응답 대기 금지) | **O** | §12 Anti-Patterns 4개 명시 |
| Helper-by-Helper Mapping | **O** | §12 의 매핑 표 (12 개 helper, default Layer 3) |
