# UserChoice Standard (가이드 §12 인용 사본)

> 출처: `realizesoft/realizesoft-cross-runtime-skill-guide.md` §12 UserChoice Standard. 원본 가이드 파일은 수정하지 않으며, 본 파일은 인용 사본이다.

---

## 가이드 §12 원문 (인용)

> Directory:
>
> ```text
> aidlc-docs/UserChoice/
> ├── orient/
> ├── requirements-discovery/
> ├── planning-design/
> ├── implementation/
> ├── verification/
> ├── deployment/
> └── uiux/
> ```
>
> Gate directory:
>
> ```text
> aidlc-docs/UserChoice/<stage>/<gate-slug>/
> ├── ascii-wireframe.txt
> ├── preview.html
> ├── external-input.txt
> └── decision.md
> ```
>
> Create only useful support artifacts. Do not create empty placeholders.
>
> `decision.md` template:
>
> ```md
> # User Choice Decision
>
> ## Pipeline Stage
>
> ## Gate
>
> ## Options Presented
>
> ## Recommended Option
>
> ## Why Recommended
>
> ## User Selection
>
> ## Evidence Flow
>
> ## Tradeoffs
>
> ## Input Gate Mode
>
> ## Triggered Skill Gates
>
> | Skill | Gate Profile | Applied As | Reason |
> |---|---|---|---|
>
> ## Resulting Pipeline Behavior
>
> ## Files Created
>
> ## Remaining Risks
> ```

---

## 본 스킬의 실현 명세

### 디렉토리 생성 시점

- **자동 생성 안 함**. 사용자가 어느 stage 의 첫 결정을 내릴 때 해당 stage 디렉토리 생성
- 빈 placeholder 디렉토리 만들지 않음 (가이드 §12 명시)

### Gate slug 명명 규칙

`<stage>` 내에서 게이트를 식별하는 짧은 kebab-case 슬러그. 예시:

| Stage | Gate Slug 예시 |
|---|---|
| orient | `purpose-clarification`, `complexity-classification` |
| requirements-discovery | `discovery-helper-selection`, `requirements-depth-decision` |
| planning-design | `architecture-approach`, `units-decomposition` |
| implementation | `code-generation-plan-approval`, `refactor-scope` |
| verification | `test-tier-selection`, `security-scan-scope` |
| deployment | `provider-selection`, `release-stage-approval` |
| uiux | `wireframe-format`, `style-direction` |

### decision.md 작성 절차

1. 사용자가 `AskUserQuestion` 결과로 선택을 완료
2. 본 스킬이 즉시 다음 파일 작성:
   - `aidlc-docs/UserChoice/<stage>/<gate-slug>/decision.md` (가이드 §12 템플릿 그대로)
   - (선택) `ascii-wireframe.txt` / `preview.html` / `external-input.txt` — UI/UX 게이트인 경우만
3. baseline lifecycle 의 audit.md 에도 결정 로그 append (baseline 본문이 명시한 "Log user's response in audit.md with complete raw input" 의무 충족)

### Anti-Pattern (절대 금지)

- 사용자 선택 전에 `decision.md` 생성 (가이드 §12: "Only create after the user has chosen")
- 빈 placeholder 디렉토리 생성 (가이드 §12: "Create only useful support artifacts")
- decision.md 의 필드 일부 생략 (가이드 §12 템플릿 13개 필드 모두 채움. 해당 없으면 "N/A" 명시)

### 본 스킬이 추가하는 메타 필드 (선택)

baseline 본문의 audit.md 의무와 정합하기 위해, decision.md 끝에 다음 추가 가능:

```markdown
## Audit Log Reference
**Timestamp**: <ISO 8601>
**Audit.md Append**: <audit.md 의 해당 entry 위치>
**Skill Wrapper**: aidlc-realizesoft §<관련 섹션 번호>
```

이 메타 필드는 가이드 §12 의 13개 필드를 변경하지 않고, 본 스킬의 추가 책임을 명시할 뿐이다.
