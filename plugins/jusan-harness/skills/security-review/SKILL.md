---
name: security-review
description: |
  보안 PR/diff 정적 검수 통합 스킬. 24 specialists 7 Tier 병렬 (인증/인가 4 + 입력검증 4 + 데이터보호 4 + 인프라보안 4 + 의존성 3 + 운영보안 3 + 컴플라이언스 2).
  ~600 체크리스트 + Security Score 0-100 (24차원 가중치) + 7등급 (S/A+/A/B+/B/C/F).
  Use when asked to "security review", "보안 리뷰", "보안 검수", "OWASP 리뷰", "취약점 검사", "PR 보안 검토", or "/security-review".
  NOT for: 라이브 침투 테스트 (별도 도구), 프론트엔드 보안만 (use frontend-review Tier 6), 단순 OWASP 전수 감사 (use security-audit), CE (use ce-reviewer).
  Modes: basic (~50 items) / --full (~200 items) / --all (~600 items 24 specialists). code-review 정합 effort=low/medium/high/max + --comment PR inline.
user_invocable: true
---

# Security Review — 보안 전수 코드 리뷰

> **원칙**: "보안은 후기에 발견할수록 비용이 기하급수적으로 증가 — Shift Left Security"
> **공통**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md` + `${CLAUDE_PLUGIN_ROOT}/skills/_core/roles.md`
> **P3-7a 신설 (2026-05-26)**: 사용자 명시 발화 "보안이나 그러한 것들" + /propose-skill 워크플로우 통과

## ⚠️ Uncompromising Rigor (글로벌 룰 강제)

§1 Browser Priority / §2 Self-Justification 차단 / §3 모든 발견 결함 / §4 Per-Round Deep Analysis 모두 정합.

---

## 1. 책임 경계 매트릭스 (Confusion 차단)

| 자산 | 시점 | 영역 |
|---|---|---|
| **`security-review` (본 스킬)** | **PR 정적** | **24 specialists 7 Tier 전수 보안 검수** |
| `security-reviewer` (agent, P0-3) | PR 정적 | OWASP Top 10 단일 에이전트 (단축형) |
| `security-audit` (스킬, 3 specialists) | 전수 감사 | OWASP App/Infra/Deps Agent-Teams |
| `frontend-review` Tier 6 (TM17 XSS / TM18 CSP) | PR 정적 | 프론트엔드 보안만 (XSS/CSP) |
| `code-review` (외부 플러그인) | PR 정적 | 백엔드 일반 코드 (보안 일부만) |
| `infra-audit` | 인프라 감사 | CLAUDE.md/hooks/skills 정합성 (보안 X) |

**핵심 분담**: 본 스킬 = **24 specialists 깊이 보안 PR 정적 검수**. 다른 자산은 단축형/감사형/도메인 한정.

---

## 2. 실행 모드

| 모드 | effort 별칭 | 팀 구성 | 항목 | 시간 |
|:----:|:----:|:-------:|:---:|:--:|
| basic | `--effort=low` | Lead 1 | ~50 | 8-12분 |
| --full | `--effort=medium` | Lead + 7 TM (Tier 대표) | ~200 | 20-35분 |
| --all | `--effort=high` | Lead + 24 TM (전수) | **~600** | 45-90분 |
| --effort=max | (신규) | Lead + 24 TM + uncertain | ~600+ | 60-120분 |

옵션: `--focus=<tier>` / `--loop` / `--comment --pr=N` / `--dry-run`

---

## 3. 24 Specialists 구성

```
Lead (Security Review Director) — 24 TM 통합 + Security Score 산정 + 등급 (S~F)

Tier 1: 인증/인가 (4 TM) — 가중치 20%
├─ TM1 Authentication (비밀번호 / MFA / 세션)
├─ TM2 Authorization (RBAC / ABAC / 권한 우회)
├─ TM3 Token & JWT (서명 / 만료 / refresh)
└─ TM4 OAuth/SSO (state / PKCE / redirect_uri 검증)

Tier 2: 입력 검증 (4 TM) — 가중치 18%
├─ TM5 SQL Injection (파라미터 바인딩 / Prepared)
├─ TM6 XSS (Reflected / Stored / DOM)
├─ TM7 CSRF (토큰 / SameSite / Origin)
└─ TM8 Command/Path Injection (exec / readFile / unsafe URLs)

Tier 3: 데이터 보호 (4 TM) — 가중치 18%
├─ TM9 At-Rest 암호화 (DB / 파일)
├─ TM10 In-Transit 암호화 (TLS / cert pinning)
├─ TM11 PII 처리 (수집 / 저장 / 삭제 / 마스킹)
└─ TM12 데이터 무결성 (서명 / 체크섬 / Audit log)

Tier 4: 인프라 보안 (4 TM) — 가중치 16%
├─ TM13 보안 헤더 (CSP / HSTS / X-Frame-Options)
├─ TM14 CORS (Origin 화이트리스트)
├─ TM15 Container 보안 (Docker / runAsRoot / capabilities)
└─ TM16 시크릿 관리 (환경변수 / vault / rotation)

Tier 5: 의존성 + 공급망 (3 TM) — 가중치 12%
├─ TM17 CVE 스캔 (npm audit / pip-audit)
├─ TM18 라이선스 (GPL/AGPL/MIT 호환)
└─ TM19 공급망 위험 (typosquatting / 악성 패키지)

Tier 6: 운영 보안 (3 TM) — 가중치 10%
├─ TM20 로깅 보안 (시크릿 마스킹 / PII 필터)
├─ TM21 감사 추적 (audit trail / immutable)
└─ TM22 Rate Limiting (DoS 방어 / abuse)

Tier 7: 컴플라이언스 (2 TM) — 가중치 6%
├─ TM23 데이터 규제 (GDPR/PIPA 핵심)
└─ TM24 산업 표준 (PCI-DSS/HIPAA 핵심)
```

---

> **24 TM 상세 (역할·Grep·~600 체크 항목)는 [references/checklists.md](references/checklists.md) 참조.** §3 Tier 구성이 24 TM 매핑, §6 가중치, §11 라우팅은 본문 유지.

## 5. Stage 0-2 작업 절차

```
Stage 0: 코드베이스 수집 (Lead)
- Glob 보안 관련 파일 (auth/middleware/api/config/.env*/secrets/)
- 의존성 매니페스트 (package.json/requirements.txt 등)
- 환경 설정 (CORS/CSP/Headers)
- 감사 데이터 / 로그 설정
→ audit-data/security-context.md

Stage 1: 24 specialists 병렬 분석 (Agent-Teams)
→ audit-reports/{tm-N}-{영역}.md 24개 보고서

Stage 2: Lead 통합 + Security Score 산정
→ SECURITY-REVIEW-{date}.md
```

---

## 6. Security Score (0-100, 24차원 가중치)

```
가중치 매트릭스:
- Tier 1 인증/인가:     20% (TM1~4 각 5%)
- Tier 2 입력 검증:     18% (TM5~8 각 4.5%)
- Tier 3 데이터 보호:   18% (TM9~12 각 4.5%)
- Tier 4 인프라 보안:   16% (TM13~16 각 4%)
- Tier 5 의존성:        12% (TM17~19 각 4%)
- Tier 6 운영 보안:     10% (TM20~22 각 3.3%)
- Tier 7 컴플라이언스:  6% (TM23~24 각 3%)
```

등급: S 95+ / A+ 90+ / A 85+ / B+ 80+ / B 70+ / C 50+ / F <50

---

## 7. 출력 형식

```markdown
# Security Review Report (YYYY-MM-DD)

## Security Score
- 총점: NN.N / 100 (등급: S~F)
- Tier별 점수 표

## 🚨 Blockers (Critical/High)
### B-1 [Tier 2 / TM5 SQL Injection] ...
- 파일/라인 / 위험 / 권장 조치

## ⚠️ Warnings (Medium)
## 💡 Suggestions (Low)
## Tier별 상세 보고서
## 라우팅 권고 (security-audit / playwright-* 등)
## 검토 결과 (Approve / Conditional Approve / Request Changes)
```

---

## 8. 10단계 파이프라인 View (인사이트 1 매핑)

Step 1 Input → Step 2 Classifier (effort level) → Step 3 Router (24 TM 분배) → Step 4 Context (audit-data) → Step 5 Planner (24 TM checklist) → Step 6 Tool Executor (Read/Grep/Bash + npm audit) → Step 7 Draft (24 reports) → Step 8 Critic (Lead 통합 + 24차원 점수) → Step 9 Refiner (Blockers/Warnings/Suggestions + 강등 정책) → Step 10 Output Renderer (SECURITY-REVIEW-{date}.md)

---

## 9. code-review 정합 옵션

| frontend-review 별칭 | effort | 항목 | 시간 |
|---|---|:--:|:--:|
| basic | low | ~50 | 8-12분 |
| --full | medium | ~200 | 20-35분 |
| --all | high | ~600 | 45-90분 |
| (신규) | max | ~600+ uncertain | 60-120분 |

`--comment` 옵션: PR inline 게시 — Blockers는 Request Changes / Warnings/Suggestions는 inline / Score+Tier는 PR Summary 본문. `--dry-run` 지원.

---

## 10. 옵션 플래그

- `--effort=low|medium|high|max` (code-review 정합)
- `--focus=<tier>` (authentication / input-validation / data-protection / infra / dependency / operations / compliance)
- `--loop` 수렴 루프
- `--comment --pr=N` PR inline 게시
- `--dry-run` 게시 안 함
- `--include=<glob>` / `--exclude=<glob>`

---

## 11. 라우팅 정책

| 발견 | 권고 |
|---|---|
| 의존성 CVE 대량 | `security-audit --deps-only` |
| 라이브 침투 필요 | (외부 도구 — ZAP / Burp) |
| Frontend 보안 추가 | `frontend-review --focus=security` |
| 인프라 정합성 | `infra-audit` |
| 백엔드 통합 | `backend-review` (P3-7b) |
| 풀스택 PR | `fullstack-review` (P3-7c) |
| 컴플라이언스 깊은 검토 | `legal-compliance-review` (P3-7k) |

---

## 12. Uncompromising Rigor 정합

§1 Browser Priority — 본 스킬은 정적, 라이브 침투는 외부 도구.
§2 Self-Justification 차단 — "이미 비슷한 보안 검토 했으니" 표현 차단.
§3 모든 발견 결함 — 사용자 명시 강등만 Low.
§4 Per-Round Deep Analysis — `--loop` 시 매 라운드 5단계 강제.

---

## 13. 환각 방지

- 파일:라인 명시 의무
- CVE 인용 시 NVD ID 명시 (CVE-YYYY-NNNNN)
- 추정 발견은 `[추정]` 마커 (effort=max 만 포함)
- 외부 라이브러리 동작 추측 X

---

## 14. 참조

- `${CLAUDE_PLUGIN_ROOT}/agents/security-reviewer.md` (단축형 PR 보안 검토 agent)
- `${CLAUDE_PLUGIN_ROOT}/skills/security-audit/SKILL.md` (전수 OWASP 감사 3 specialists)
- `${CLAUDE_PLUGIN_ROOT}/skills/frontend-review/SKILL.md` (Tier 6 FE 보안)
- `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md`
- 인사이트 1: `.thoughts/2026-05-25-harness-insights-round1.md`
- 회고: `.thoughts/2026-05-25-harness-application-completed.md`
- OWASP Top 10 2021 / CWE Top 25 / CIS Controls
