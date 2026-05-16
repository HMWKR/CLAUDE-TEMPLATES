# aidlc-realizesoft — RealizeSoft Layer Skill (v1.0)

## Overview

`aidlc-realizesoft` is **Skill 2** in the AI-DLC 2-Layer model defined by the cross-runtime guide (§3 Core Architecture). It attaches on top of `aidlc-baseline` (Skill 1) without modifying it, enforcing the 7 non-negotiable rules from guide §4 across all helper routing and user-choice gates.

**Source**: `realizesoft/realizesoft-cross-runtime-skill-guide.md`
**Baseline skill**: `aidlc-baseline` (must be installed at `~/.claude/skills/aidlc-baseline/`)

---

## 2-Layer Architecture

```
AI-DLC Workflow Invocation
        │
        ▼
┌─────────────────────────────────────────────────────┐
│  Layer 2: RealizeSoft Layer  (THIS SKILL)           │
│                                                     │
│  • §4 Non-Negotiable Rules (7) enforcement          │
│  • Selection Gate — AskUserQuestion before helper   │
│  • Strict Gate Preservation (§4.3)                  │
│  • Universal AskUserQuestion Wrapper (§12)          │
│  • UserChoice Records (aidlc-docs/UserChoice/)      │
│  • Provider-Neutral Deployment Gate                 │
│  • Explicit-Only Skills isolation                   │
│  • Product Input Exclusion                          │
│                                                     │
│  References: 10 guide §section verbatim files       │
└─────────────────────────────────────────────────────┘
        │ attaches on top of (never modifies)
        ▼
┌─────────────────────────────────────────────────────┐
│  Layer 1: Baseline Layer  (aidlc-baseline)          │
│                                                     │
│  • AI-DLC 3-Phase 14-stage lifecycle body           │
│  • Original CLAUDE.md byte-for-byte preserved       │
│  • references/ aws-aidlc-rule-details/ (29 files)   │
│  • 12 gate locations with Question Gate Mandate     │
│                                                     │
│  Location: ~/.claude/skills/aidlc-baseline/         │
└─────────────────────────────────────────────────────┘
        │ drives
        ▼
  Baseline AI-DLC Stage Continues
  (Inception → Construction → Operations)
```

### Activation Order

1. User invokes AI-DLC workflow (e.g., "start AI-DLC", "aidlc realizesoft")
2. This skill (Layer 2) activates and reads baseline from `~/.claude/skills/aidlc-baseline/SKILL.md`
3. Layer 2 gates (Selection Gate, UserChoice, Deployment Gate, UI/UX Gate) enforce §4 rules
4. Baseline lifecycle (Layer 1) continues under Layer 2 governance

---

## Contents

```
aidlc-realizesoft/
├── SKILL.md                              # Skill entrypoint (12 sections)
├── README.md                             # This file
└── references/                           # Guide §section verbatim citations
    ├── non-negotiable-rules.md           # Guide §4  — 7 non-negotiable rules
    ├── helper-routing-matrix.md          # Guide §9  — helper routing + user env mapping
    ├── selection-gate-template.md        # Guide §10 — Selection Gate + AskUserQuestion mapping
    ├── runtime-gate-mapping.md           # Guide §11.2 — Claude command skeleton
    ├── userchoice-standard.md            # Guide §12 — UserChoice path + decision.md template
    ├── uiux-decision-gate.md             # Guide §13 — UI/UX Decision Gate
    ├── deployment-provider-gate.md       # Guide §14 — Provider-neutral gate (9 options)
    ├── explicit-only-skills.md           # Guide §15 — Auto-spawn block list (user env)
    ├── minimal-cross-runtime-template.md # Guide §17 — Minimal Cross-Runtime Template
    └── verification-checklist.md         # Guide §18 — RealizeSoft verification (11 items)
```

---

## Prerequisites

`aidlc-baseline` must be installed globally before this skill is usable:

```powershell
# Install Skill 1 first (if not already done)
cd C:\Users\jusan\Desktop\claude-templates
.\scripts\install-aidlc-baseline.ps1
```

---

## Install

```powershell
cd C:\Users\jusan\Desktop\claude-templates
.\scripts\install-aidlc-realizesoft.ps1
```

The script:
1. Validates `SKILL.md` exists in the master copy
2. Backs up any existing global copy to `~/.claude/skills-backups/aidlc-realizesoft-<timestamp>` (outside `~/.claude/skills/` to prevent registry pollution)
3. Copies master → `~/.claude/skills/aidlc-realizesoft/`
4. Verifies file count + SHA256 hash equality

### Backup Note

Backups are stored in `~/.claude/skills-backups/` (not inside `~/.claude/skills/`) so the skill registry does not pick them up as duplicate skills.

---

## Invocation Triggers

Once installed, activate from any project with:

- `"aidlc realizesoft"`, `"start AI-DLC with realizesoft"`
- `"AI-DLC workflow"` (matches both layers; RealizeSoft layer governs)
- Any AI-DLC stage keyword when both skills are active

---

## Exclusions

Per guide §4.1·4.7:

| Excluded | Reason |
|---|---|
| `realizesoft/table-order-macos-claudecode/` original | Product source — never modified |
| `aidlc-baseline` skill (master + global) | Baseline layer — never modified (guide §4.1 Preserve The Baseline) |
| `requirements/table-order-requirements.md` | Product input — not generic skill source (guide §4.7) |
| `requirements/constraints.md` | Product input — not generic skill source (guide §4.7) |

---

## Guide §18 RealizeSoft Verification Checklist

All 11 RealizeSoft items from cross-runtime-guide §18 pass:

| # | Check Item | Status |
|:-:|---|:-:|
| 1 | RealizeSoft layer is separated from baseline | **O** |
| 2 | Helper routing is conditional (Selection Gate required) | **O** |
| 3 | Selection Gate includes recommendation, reason, pros, cons, risk | **O** |
| 4 | Strict Gate Preservation is present | **O** |
| 5 | Q4 approval is mandatory for explicit-only skills | **O** |
| 6 | UserChoice path and decision.md template are present | **O** |
| 7 | Deployment provider gate is not Vercel-only | **O** |
| 8 | Explicit-only skills are separated | **O** |
| 9 | Claude/Kiro/Codex runtime differences are stated | **O** |
| 10 | Project-specific requirements not embedded in generic skill | **O** |
| 11 | Generated layer type is stated (native/ported/reconstructed) | **O** |

See `references/verification-checklist.md` for full evidence per item.

---

## Related

- `aidlc-baseline/README.md` — Skill 1 documentation
- `realizesoft/realizesoft-cross-runtime-skill-guide.md` — Authoritative source guide (883 lines)
- `scripts/install-aidlc-baseline.ps1` — Skill 1 install
- `scripts/install-aidlc-realizesoft.ps1` — This skill's install
- Plan file: `.claude/plans/table-order-macos-claudecode-requirement-iridescent-leaf.md`
