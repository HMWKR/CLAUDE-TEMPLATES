---
name: harness-merge-advisor
description: Use when installing jusan-harness / CLAUDE-TEMPLATES onto a machine (or project) that ALREADY has a Claude Code harness and the user chose "merge/overlay" instead of "replace". Deeply analyzes the target user's existing harness (~/.claude or <project>/.claude — CLAUDE.md, rules, skills, agents, settings, plugins, MCP) against jusan-harness, detects conflicts/overlaps/duplicate-functionality, and proposes a concrete per-item merge plan for approval before applying. Triggers — "하네스 병합", "하네스 충돌 분석", "merge harness", "harness conflict", "harness-merge-advisor", or after `install.sh --mode merge` / `install.ps1 -Mode merge` reports conflicts. NOT for clean installs (no existing harness) or replace-mode installs.
---

# Harness Merge Advisor

기존 하네스가 있는 환경에 jusan-harness(CLAUDE-TEMPLATES)를 **덧씌우기(merge)** 할 때, 무엇이 충돌·중복·안전추가인지 심층 분석하고 **항목별 병합안을 제안→승인→적용**한다. 절대 사용자 기존 파일을 말없이 덮지 않는다.

## 발동 맥락
- `install.sh --mode merge` / `install.ps1 -Mode merge` 가 충돌을 리포트했을 때 (`harness-merge-report-*.txt`).
- 사용자가 "기존 하네스에 우리 것을 더할 건데 충돌 봐줘"라고 할 때.
- GitHub 재현 키트 경로(파일 복사) **또는** 플러그인 경로(`jusan-harness@claude-templates` 설치) 양쪽 모두.

## 입력 좌표
- **타깃(사용자 기존)**: 글로벌 `~/.claude/` 또는 프로젝트 `<proj>/.claude/` + `<proj>/CLAUDE.md`.
- **우리(jusan-harness)**: 레포의 `harness/dot-claude/`(CLAUDE.md·rules·settings.reference.json) + `plugins/jusan-harness/`(skills·agents) + `harness/PLUGINS.md`·`harness/MCP.md`. 플러그인으로 설치된 경우 우리 스킬/에이전트는 `jusan-harness:` 네임스페이스로 이미 격리됨.

## 분석 프로토콜 (이 순서로 실행, 증거 기반 — 추측 금지)

1. **양측 인벤토리 수집** (Read/Glob/Bash로 실측):
   - CLAUDE.md 존재·내용, `rules/` 파일목록, `skills/` 디렉토리명, `agents/` 파일명, `settings.json`의 `env`·`permissions`·`enabledPlugins`·`hooks`, `claude plugin list`, `claude mcp list`.
2. **항목별 대조 분류**:
   | 분류 | 정의 | 기본 처분 |
   |---|---|---|
   | **safe-add** | 우리에만 있음(타깃에 동일 이름 없음) | 추가 |
   | **identical** | 이름·내용 동일 | 스킵 |
   | **conflict** | 같은 이름, **내용 다름** (rule 파일·skill 디렉토리·CLAUDE.md) | 덮지 않음 → 제안 |
   | **duplicate-function** | 이름은 다르나 기능 중복(예: 사용자 code-review류 vs 우리 것, 두 anti-hallucination 변형) | 제안(택1/공존) |
   | **behavioral-merge** | CLAUDE.md / rules 충돌 = 행동 규약 → 절대 자동병합 금지, 줄 단위 제안 | 수동 병합안 |
   | **settings-overlap** | `enabledPlugins`/`env`/`permissions`/`hooks` 키 겹침 | 키 단위 제안 |
   | **plugin/mcp-overlap** | 우리가 권장하는 플러그인/MCP를 타깃이 이미 보유(버전·활성상태 차이 포함) | 보고만 |
3. **충돌 깊이 분석**: 각 conflict에 대해 두 버전 diff를 읽고 *무엇이/왜* 다른지(상위호환·구버전·상이 의도)를 1–2줄로 규명. "의도된 차이" 추정 금지 — diff 증거로 말한다.
4. **위험 우선순위**: behavioral-merge(CLAUDE.md·rules) > settings(hooks·permissions) > skill/agent conflict > duplicate-function > plugin/mcp-overlap.

## 제안·적용

- 분석 결과를 표로 제시: `항목 | 분류 | 차이 요지 | 권장 처분`.
- 결정이 필요한 conflict/duplicate/behavioral는 **AskUserQuestion**으로 묻는다(옵션: 우리것 채택 / 기존 유지 / 공존[리네임] / 줄단위 병합). 한 번에 관련 항목 묶어 질문, 과도한 질문 지양.
- **behavioral(CLAUDE.md·rules)**: 통째 교체 대신 **섹션/줄 단위 통합안**을 보여주고 승인받아 적용. 사용자 고유 규칙은 보존.
- 승인된 처분만 적용. `*.harness-incoming` 파일은 적용 후 정리. 적용 전 타깃 백업(타임스탬프) 확인.
- 적용 후 **검증**: `claude plugin list`·`claude mcp list`·`ls ~/.claude/skills` 로 결과 확인하고 충돌 잔존 0 보고.

## 플러그인 경로 특이사항
- 플러그인으로 설치 시 우리 스킬/에이전트는 `jusan-harness:<이름>`으로 네임스페이스 격리 → **파일 충돌은 없음**. 대신 **기능 중복/트리거 경합**(같은 요청에 사용자 스킬과 우리 스킬이 동시 매칭)을 분석해 어느 쪽을 우선할지, 비활성·리네임이 필요한지 제안한다.
- 글로벌 `CLAUDE.md`·`rules/`는 플러그인이 자동주입하지 않으므로, 그 레이어 병합은 재현 키트(파일) 경로의 behavioral-merge 절차를 따른다.

## 금지
- 사용자 기존 CLAUDE.md·rules·skill을 **승인 없이 덮어쓰기 금지**.
- "어차피 우리 게 더 좋다"는 임의 판단으로 강등·생략 금지 — 모든 충돌을 등재하고 사용자 결정에 맡긴다.
