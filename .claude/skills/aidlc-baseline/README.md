# aidlc-baseline — AI-DLC Baseline Lifecycle Skill

> AI-DLC 3-Phase 14-stage 적응적 워크플로우의 **baseline lifecycle 원본** 을 보존한 Claude Code 스킬.

---

## 1. Origin (출처)

| 항목 | 값 |
|---|---|
| **원본 baseline 디렉토리** | `realizesoft/table-order-macos-claudecode/` |
| **참조 가이드** | `realizesoft/realizesoft-cross-runtime-skill-guide.md` |
| **가이드 §6.4 (Concrete Example)** | 본 baseline 을 명시적으로 예시로 채택 |
| **Baseline 유형** | Claude **native** baseline (가이드 §11.2 매핑) |
| **본 스킬 위치** | `claude-templates/.claude/skills/aidlc-baseline/` (마스터 사본, git 추적) |
| **활성 글로벌 위치** | `~/.claude/skills/aidlc-baseline/` (install 스크립트로 배포) |

---

## 2. What's included / excluded (포함·제외)

### Included (baseline-lifecycle, 30 파일)

| 파일/디렉토리 | 역할 |
|---|---|
| `SKILL.md` | Claude Code 스킬 진입점. frontmatter + Skill Bundle Note + 원본 `.claude/CLAUDE.md` byte-for-byte body |
| `references/original-CLAUDE.md` | 원본 `.claude/CLAUDE.md` byte-for-byte 100% 보존 사본 (감사·비교용) |
| `references/aws-aidlc-rule-details/common/` (11 파일) | process-overview, content-validation, question-format-guide, session-continuity, terminology, welcome-message, depth-levels, error-handling, overconfidence-prevention, ascii-diagram-standards, workflow-changes |
| `references/aws-aidlc-rule-details/inception/` (7 파일) | workspace-detection, reverse-engineering, requirements-analysis, user-stories, workflow-planning, application-design, units-generation |
| `references/aws-aidlc-rule-details/construction/` (6 파일) | functional-design, nfr-requirements, nfr-design, infrastructure-design, code-generation, build-and-test |
| `references/aws-aidlc-rule-details/operations/` (1 파일) | operations (placeholder) |
| `references/aws-aidlc-rule-details/extensions/security/baseline/` (2 파일) | security-baseline + opt-in |
| `references/aws-aidlc-rule-details/extensions/testing/property-based/` (2 파일) | property-based-testing + opt-in |

### Excluded (product-input, 가이드 §4.7·6.4 에 따라 제외)

| 파일 | 제외 사유 |
|---|---|
| `requirements/table-order-requirements.md` | 테이블오더 product 요구사항 — generic skill 의 source 가 아님 |
| `requirements/constraints.md` | 테이블오더 제외 기능 목록 — generic skill 의 source 가 아님 |

가이드 §4.7 직접 인용:
> "Lifecycle sources define how the AI-DLC process operates. Product inputs define what a specific app should do. Product inputs are valid when applying a finished skill to a specific project. They are **not valid when generating the generic RealizeSoft skill itself**."

본 스킬은 generic baseline skill 이므로 product input 제외 원칙을 정확히 따른다.

---

## 3. Preservation Discipline (보존 무결성)

| 항목 | 상태 |
|---|---|
| 30개 baseline-lifecycle md 파일 byte-for-byte 보존 | **O** (diff -r 검증 통과) |
| `.aws-aidlc-rule-details/` 디렉토리 구조 보존 | **O** (common/inception/construction/operations/extensions 5개 폴더 + 2개 extension subdir) |
| `.claude/CLAUDE.md` 원문 보존 | **O** (`references/original-CLAUDE.md` + `SKILL.md` body 양쪽 모두 byte-for-byte 동일) |
| 가이드 §4.1 ("Do not edit or rewrite the original AI-DLC lifecycle file") | **준수** |

`SKILL.md` 의 wrapping (frontmatter + Skill Bundle Note + `---` 구분자) 은 본문 위에 추가된 메타 정보이며, 원본 본문(line 40 이후) 은 byte-for-byte 100% 동일하다. 본문 1글자도 변경되지 않았다.

---

## 4. Skill Bundle Note 의 역할

`SKILL.md` 의 본문은 line 14-19 에서 다음 4개 워크스페이스 경로 후보를 명시한다:

```
- `.aidlc/aidlc-rules/aws-aidlc-rule-details/`
- `.aidlc-rule-details/`
- `.kiro/aws-aidlc-rule-details/`
- `.amazonq/aws-aidlc-rule-details/`
```

이 4개는 워크스페이스(사용자 프로젝트 루트) 기준. 본 스킬은 추가로 **스킬 번들 내장** 경로를 제공:

```
<SKILL.md 위치한 디렉토리>/references/aws-aidlc-rule-details/
```

Skill Bundle Note 가 이 경로를 4개 워크스페이스 경로보다 **최우선으로** 검색하라고 명시한다. 결과:

- 워크스페이스에 `.aidlc-rule-details/` 가 없는 신규 프로젝트도 **Zero-setup** 으로 즉시 작동
- 워크스페이스에 자체 룰 디렉토리가 있어도 스킬 번들이 우선 → 일관된 워크플로우 보장
- 본문은 원본 그대로이므로 가이드 §4.1 "do not edit" 원칙 준수

---

## 5. Installation (글로벌 배포)

본 스킬은 **마스터 사본** (`claude-templates/.claude/skills/aidlc-baseline/`) 과 **활성 글로벌 사본** (`~/.claude/skills/aidlc-baseline/`) 의 hybrid 배치를 사용한다.

### 글로벌 install (PowerShell)

```powershell
cd C:\Users\jusan\Desktop\claude-templates
.\scripts\install-aidlc-baseline.ps1
```

스크립트 동작:
1. 글로벌 위치 (`~/.claude/skills/aidlc-baseline/`) 에 기존 사본 있으면 `aidlc-baseline.backup-<timestamp>/` 로 백업
2. 마스터 사본을 글로벌 위치로 재귀 복사
3. byte-for-byte 검증 (Compare-Object)

### 글로벌 install 후

어느 프로젝트에서나 다음 키워드로 본 스킬을 호출 가능:
- "AI-DLC workflow", "aidlc baseline", "워크플로우 시작"
- "inception phase", "construction phase"
- "workspace detection", "requirements analysis"
- "user stories", "code generation", "build and test"

---

## 6. Verification (가이드 §18 baseline 항목)

| 가이드 §18 체크 항목 | 본 스킬 결과 |
|---|---|
| Baseline source discovery 가 수행되었나 | **O** — cross-runtime-guide §6.4 의 Concrete Example 을 참조 |
| 누락된 `aidlc-codex` 가 정직하게 처리되었나 | **N/A** — Claude native baseline 으로 시작 (가이드 §6.2 Runtime Source Matrix 의 Claude 행) |
| Baseline source 가 기록되었나 | **O** — 본 README §1 |
| Product input 이 제외되었나 | **O** — `requirements/` 2 파일 본 스킬에 미포함 |
| `requirements/` 가 generic lifecycle source 로 사용되지 않았나 | **O** — 미사용 |
| Baseline AI-DLC 파일이 수정되지 않았나 | **O** — body byte-for-byte 100% 보존 (wrapping note 는 SKILL 형식의 일부이지 baseline 본문이 아님) |
| RealizeSoft 레이어가 분리되었나 | **분리 예정** — 본 스킬에는 RealizeSoft 레이어 포함 안 함 (별도 스킬 2 의 책임, 가이드 §3 Core Architecture 2-Layer 모델) |
| 생성된 layer 가 baseline 의 native/ported/reconstructed 중 어디인지 명시 | **O** — "Claude **native** baseline" 본 README §1 명시 |

---

## 7. Future: Skill 2 (RealizeSoft Layer)

가이드 §3 Core Architecture 의 2-Layer 모델:

```
Baseline Source Discovery → RealizeSoft Layer → Baseline AI-DLC Stage Continues
        ↑                          ↑
        |                          |
  본 스킬 (aidlc-baseline)      별도 스킬 (예: aidlc-realizesoft)
                                  - Selection Gate
                                  - UserChoice records
                                  - Strict Gate Preservation
                                  - Provider-Neutral Deployment
                                  - Explicit-Only Skills 격리
                                  - Conditional Helper Routing
```

본 스킬(스킬 1) 은 baseline 만 제공한다. 비협상 규칙·게이트·helper routing 은 향후 RealizeSoft 레이어 스킬(스킬 2) 이 본 baseline 위에 부착될 때 도입된다. 가이드 §4.1 "Create a separate RealizeSoft layer file, **not a patch to the baseline**" 원칙에 따라 두 스킬은 명확히 분리된다.

---

## 8. License & Attribution

본 baseline 의 원본은 외부 저장소 `HMWKR/realizesoft-skills` 의 `table-order-macos-claudecode/` 에서 추출됨. 본 스킬은 원본의 byte-for-byte 보존 사본이며, 라이선스와 저작권 표기는 원본 저장소를 따른다.
