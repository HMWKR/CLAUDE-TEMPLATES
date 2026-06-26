---
name: accesslint
description: |
  AccessLint Claude plugin (accesslint@accesslint v0.5.0) wrapper. WCAG 2.2 A/AA 접근성 라이브 audit + 코드베이스 audit + diff/fix 3-모드 워크플로우.
  외부 plugin 호출 + Uncompromising Rigor §1 (Chrome MCP 우선) + §3 (All findings defects) 정합 wrapper.
  Use when "accesslint", "접근성 검수", "WCAG 검수", "a11y audit", "/accesslint", "screen reader 검수".
  NOT for: 정적 코드 접근성만 (use frontend-review Tier 3), CE 4대 실패 모드 (use ce-reviewer).
user_invocable: true
---

# AccessLint Wrapper

> **신설 (2026-05-26 web-audit-pipeline #2)** — AccessLint Claude plugin (accesslint@accesslint v0.5.0) wrapper.
> **외부 plugin**: claude plugin install accesslint@accesslint (user scope, enabled)
> **MCP 대안**: `~/.claude/mcpServers.json` 에 `@accesslint/mcp@latest` 등록 가능

## ⚠️ Uncompromising Rigor §1-§4 정합

- **§1 Chrome MCP 우선**: audit_live URL 호출 시 `mcp__claude-in-chrome__*` 우선 (AccessLint가 Chrome debug session 재사용)
- **§2 Self-Justification**: "이 정도면 충분" / "WCAG AA 까지는 안 봐도 됨" 등 차단
- **§3 All Findings Are Defects**: WCAG 위반은 자동 High (사용자 명시 강등 불가능)
- **§4 Per-Round Deep**: 매 라운드 5단계 분석

## 1. 책임 경계

| 자산 | 영역 |
|---|---|
| **`accesslint`** (본 wrapper) | WCAG 2.2 A/AA 라이브 audit + 코드 audit + diff/fix |
| `frontend-review` Tier 3 (3 sp) | 정적 코드 접근성 검수 (PR/diff) — 보완 관계 |
| `playwright-uiux-audit` | 라이브 UI/UX 감사 — accesslint와 결합 가능 |
| (외부) AccessLint plugin | WCAG 2.2 audit 엔진 원본 |

**라우팅 규칙**: 라이브 URL audit → 본 wrapper / 정적 코드만 → `frontend-review --focus=a11y` / 5 도구 통합 → `web-audit-pipeline`.

## 2. WCAG 2.2 검수 범위 (W3C 공식)

| 원칙 | 영역 | 예시 |
|:-:|---|---|
| **Perceivable** (인지 가능) | 텍스트 대체 / 시간 기반 미디어 / 적응 가능 / 식별 가능 | alt text / caption / 색상 대비 4.5:1 |
| **Operable** (운용 가능) | 키보드 접근 / 충분한 시간 / 발작 / 탐색 가능 / 입력 방식 | Tab 순서 / Skip link / 0 keyboard trap |
| **Understandable** (이해 가능) | 가독성 / 예측 가능 / 입력 지원 | 명확한 label / 오류 메시지 / 일관 navigation |
| **Robust** (견고함) | 호환성 / 의미적 마크업 | ARIA / role / 적절한 HTML |

## 3. 10단계 파이프라인 View

```
Step 1 Input   : URL 또는 코드 경로 + 모드 (audit / fix / verify)
Step 2 Classifier : 작업 유형 (live URL / code static / hybrid)
Step 3 Router : audit_live (URL) / audit (코드) / fix (자동 수정)
Step 4 Context : 로그인 세션 필요 시 Chrome MCP 세션 재사용
Step 5 Planner : WCAG 4원칙 검수 순서
Step 6 Tool : accesslint:audit / accesslint:audit_live / accesslint:fix
Step 7 Draft : 외부 plugin 출력 수집
Step 8 Critic : Severity 재분류 (§3 — WCAG 위반은 자동 High)
Step 9 Refiner : 중복 통합 + WCAG criterion 표시
Step 10 Output : 출력 형식 (아래 §5)
```

## 4. 3-모드 워크플로우

### 4.1 모드 A: 라이브 URL audit
```
Use accesslint:audit to audit this live page:
https://staging.example.com/pricing

Scope:
- WCAG 2.2 A/AA
- keyboard navigation / focus order / focus visibility
- forms and labels / accessible names
- ARIA misuse / color contrast / semantic structure

Return report only. Group by severity. Include exact selector/component.
```

**Chrome MCP 우선** (§1): AccessLint가 자동으로 `mcp__claude-in-chrome__*` 세션 재사용. 로그인 페이지는 `chrome-devtools-mcp` 폴백.

### 4.2 모드 B: 코드베이스 audit
```
Use accesslint:audit to review:
src/components/
src/app/

Find accessibility issues in React/Next.js components.
Return:
- severity / component:file / WCAG criterion
- issue / suggested fix / auto-fixable Y/N

Do not edit yet.
```

### 4.3 모드 C: 자동 수정 (P0/P1만)
```
Use accesslint:audit in fix mode for P0 and P1 accessibility issues only.

Target:
src/components/forms/
src/app/contact/page.tsx

Rules:
- Fix mechanical issues directly (alt / label / aria-* / tabindex)
- Do not change visual design unless required for accessibility
- Leave TODO comments for product/design judgment items
- After fixes, run verification and summarize before/after
```

## 5. 출력 형식 (P0/P1/P2 정합)

```markdown
## AccessLint Report — <date>

### Summary
- URL/경로: <X>
- WCAG criterion: 2.2 A/AA
- 발견: P0=X / P1=Y / P2=Z (총 N건)
- 자동 수정 가능: M건

### Findings

#### P0 (접근성 차단 — 사용 불가)
- **`<selector>`** — <Issue>
  - **WCAG**: <2.2.X 항목>
  - **Impact**: <스크린리더/키보드 사용자 영향>
  - **Fix**: <코드>
  - **Auto-fixable**: Y/N

#### P1 (큰 영향)
...

#### P2 (사용성 개선) — 사용자 명시 강등만
...
```

## 6. 옵션

| 옵션 | 효과 |
|---|---|
| `--wcag=2.2-AA` (default) | WCAG 2.2 A/AA |
| `--wcag=2.2-AAA` | WCAG 2.2 AAA (엄격) |
| `--with-login` | Chrome MCP 로그인 세션 재사용 (chrome-devtools-mcp) |
| `--fix-p0-p1` | P0/P1 자동 수정 |
| `--diff` | 이전 audit과 비교 |

## 7. Chrome MCP 통합 (Uncompromising Rigor §1 정합)

AccessLint 는 다음 우선순위로 브라우저 호출:

```
1순위: mcp__claude-in-chrome__*  (기본 진입로)
2순위: chrome-devtools-mcp        (로그인 세션 재사용)
3순위: AccessLint 자체 Chrome 최소화 모드
```

`mcp__playwright__*` 는 fallback only — 자동으로 우선되지 않음.

## 8. 라우팅 다른 스킬

| 작업 | 권고 스킬 |
|---|---|
| 정적 코드 접근성만 | `frontend-review --focus=a11y` |
| 라이브 UI/UX 통합 | `playwright-uiux-audit` + accesslint 결합 |
| 5 도구 통합 | `web-audit-pipeline` |
