---
name: security-audit
description: |
  OWASP-based security audit with 3 parallel specialists (App, Infra, Dependencies).
  Use when asked to "security audit", "check vulnerabilities", "OWASP scan",
  "check security", "보안 감사", "취약점 검사", or "보안 검토".
  Modes: full/--scope/--deps-only/--quick. Agent-Teams with AGENT_TEAMS=1.
user_invocable: true
---

# Security Audit — OWASP 기반 보안 오딧

## 사용하지 말아야 할 때 (NOT for)

- **PR/diff 단위 정적 코드 리뷰(보안 포함)** — 이 스킬은 코드베이스 전체 OWASP 감사 + 인프라/의존성 병렬 팀 검사 전용이다. 단일 변경분의 보안 관점 리뷰는 security-review(또는 frontend-review의 FE Security Tier / agent-teams-code-review의 Security 전문가)를 사용한다.
- **일반 코드 품질·아키텍처·성능 리뷰** — security-review / 해당 review 스킬 사용.
- **단일 파일·단일 함수의 빠른 보안 확인** — 본 감사를 돌릴 필요 없이 인라인으로 점검.
- **단순 보안 지식 질문** ("XSS가 뭐야?", "CSP 헤더 설명") — 감사 실행 없이 바로 답한다.
- **취약점 수정·패치 적용** — 감사로 발견된 항목의 실제 코드 수정은 별도 구현 작업.

트리거 충돌 해소: "security review"는 변경분 리뷰 의도가 강하므로 security-review로, "security audit / 보안 감사 / OWASP scan / 취약점 검사"처럼 전수 감사 의도일 때만 본 스킬을 활성화한다.

> **원칙**: "보안은 후기에 발견할수록 비용이 기하급수적으로 증가한다." — Shift Left Security
> **공통 프로토콜**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md` 참조
> **역할 정의**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/roles.md` 참조

---

## 1. 실행 모드

| 모드 | 호출 | 팀 구성 | 설명 |
|:----:|------|:-------:|------|
| **전체** | `/security-audit` | Lead + 3 TM | 전체 코드베이스 보안 감사 |
| **범위 지정** | `--scope=<경로>` | Lead + 3 TM | 특정 디렉토리/모듈 집중 |
| **의존성만** | `--deps-only` | Lead only | npm audit + CVE 스캔만 |
| **빠른 검사** | `--quick` | Lead only | 상위 15항목 빠른 점검 |

### 환경 확인

```
1. CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 확인 (전체/범위 모드)
2. 프로젝트 루트 확인 (package.json 또는 기타 매니페스트)
3. 기술 스택 파악 (Node.js / Python / Go 등)
4. 환경 미충족 → Fallback 안내 (--quick 모드로 자동 전환)
```

---

## 2. 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│  Stage 0: 코드베이스 수집 (Lead)                         │
│  - 프로젝트 구조 분석 (디렉토리, 기술 스택, 설정)        │
│  - 보안 관련 파일 식별 (auth, api, middleware, config)    │
│  - 의존성 매니페스트 수집 (package.json, requirements.txt)│
│  - audit-data/ 에 수집 결과 저장                         │
└───────────────────────┬─────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  Stage 1: 병렬 보안 분석 (Teammates)                     │
│                                                         │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │
│  │TM1: 앱 보안  │ │TM2: 인프라   │ │TM3: 의존성   │    │
│  │              │ │보안          │ │보안          │    │
│  │OWASP Top 10  │ │시크릿 관리   │ │npm audit     │    │
│  │인증/인가     │ │CORS/헤더     │ │CVE 데이터    │    │
│  │입력 검증     │ │환경 설정     │ │라이선스      │    │
│  │데이터 보호   │ │Docker/CI     │ │공급망 위험   │    │
│  │세션 관리     │ │              │ │              │    │
│  │25항목        │ │15항목        │ │10항목        │    │
│  └──────────────┘ └──────────────┘ └──────────────┘    │
└───────────────────────┬─────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  Stage 2: 통합 오딧 리포트 (Lead)                        │
│  - 3개 리포트 수집 + 중복 통합                           │
│  - 심각도 재분류 + CVSSv3 교차 검증                      │
│  - SECURITY-AUDIT-{date}.md 통합 리포트 생성             │
└─────────────────────────────────────────────────────────┘
```

---

## 2a. 10단계 파이프라인 View (인사이트 1 매핑)

> 본 스킬의 Stage 0-2 흐름을 인사이트 1(CLI LLM 하네스 10단계)의 보편 원리와 매핑한 **명시적 framing**. 기존 Stage 0-2 본문은 그대로 보존하며, 호출자가 어느 단계에 있는지 명확히 인지할 수 있도록 한다.

### 10단계 매핑 표

| Step | 인사이트 1 단계 | 본 스킬 매핑 | 출력 계약 |
|:-:|---|---|---|
| **1** | Input Normalizer | 보안 검토 요청 정규화 — scope / 모드 (full/scope/deps-only/quick) / 우선순위 | `{ scope, mode, priority, source_files[] }` |
| **2** | Intent Classifier | 작업 유형 분류 — Agent-Teams 가능 여부 (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1) → full/scope (Lead+3TM) / deps-only/quick (Lead only) | `{ classified_mode, team_required: bool }` |
| **3** | Task Router | TM 분배 — TM1(앱 보안 25항목) / TM2(인프라 보안 15항목) / TM3(의존성 보안 10항목). 모드별 단축 (quick은 상위 15항목만) | `{ tm_assignments }` |
| **4** | Context Builder | Stage 0 = 컨텍스트 수집 — audit-data/project-structure / security-files / dependencies / config-files | audit-data/*.md 산출 |
| **5** | Planner | 각 TM별 검사 계획 + 보안 키워드 grep 패턴 + Read 대상 파일 매트릭스 | TM별 plan.md |
| **6** | Tool Executor | Stage 1 = 병렬 분석 실행 — Read / Grep / `npm audit` / CVE 조회 | TM별 raw findings |
| **7** | Draft Generator | 각 TM 보고서 작성 — `audit-reports/{app,infra,dependency}-security.md` (모드별 출력 계약 고정) | 3개 TM 보고서 |
| **8** | Critic / Verifier | Stage 2 = Lead 통합 검증 — 심각도 재분류 + CVSSv3 교차 검증 + 위양성 제거 | `verified_findings[]` |
| **9** | Refiner | 중복 통합 + 우선순위 정렬 + 권장 조치 정제 | `refined_findings[]` with priority |
| **10** | Output Renderer | `SECURITY-AUDIT-{date}.md` 통합 리포트 렌더링 — Markdown / 표 / Blockers·Warnings·Suggestions 구조 | 최종 리포트 |

### 단계별 검증/분기/재시도

| Step | 검증 조건 | 실패 시 분기 |
|:-:|---|---|
| 1 | scope/mode 명확 | 불명확 → 사장 질의 |
| 2 | Agent-Teams 환경 OK | NO → quick 모드 자동 전환 (fallback) |
| 3 | TM 분배 균등 | 25/15/10 비율 어긋남 → 재분배 |
| 4 | audit-data 4종 모두 수집됨 | 누락 → 재실행 |
| 5 | 각 TM plan 검사 항목 ≥ 50% 커버 | 미달 → 보강 |
| 6 | grep/Read 실행 0 에러 | 에러 → 부분 결과 + 재시도 |
| 7 | 3개 보고서 모두 생성됨 | 누락 TM → Lead 직접 보강 또는 재호출 |
| 8 | 심각도 분류 일관성 | 모순 → Lead 재검토 |
| 9 | Blockers 0건 또는 권장조치 모두 명시 | 누락 → 재정제 |
| 10 | Markdown valid + 표 구조 정상 | 깨짐 → 재렌더 |

### 인사이트 1 vs 본 스킬 — Confusion 방지

- 인사이트 1의 fast/normal/pro 모드 ↔ 본 스킬의 full/scope/deps-only/quick **다른 체계**. 충돌 시 본 스킬의 모드 우선.
- 인사이트 1의 "한 모델 vs 다단계 호출" 원리 → 본 스킬은 이미 **Agent-Teams 다단계 호출 + Lead 통합** 구조로 실현됨.
- 본 스킬의 Stage 0/1/2 = 인사이트 1의 Step 4 / Step 6+7 / Step 8+9+10 **그룹화 View**.

---

## 3. 데이터 구조

```
{project-root}/
├── audit-data/                      # Lead가 생성, TM이 읽기
│   ├── project-structure.md         # 디렉토리 구조, 기술 스택
│   ├── security-files.md            # 보안 관련 파일 목록 + 경로
│   ├── dependencies.md              # 의존성 목록 + 버전
│   └── config-files.md              # 설정 파일 내용 (.env 패턴, CORS 등)
│
└── audit-reports/                   # 각 TM이 자기 파일만 작성
    ├── app-security.md              # TM1
    ├── infra-security.md            # TM2
    ├── dependency-security.md       # TM3
    └── SECURITY-AUDIT-{date}.md     # Lead 통합
```

---

## 4. Stage 0: 코드베이스 수집 (Lead)

```
[Step 1] 디렉토리 생성
mkdir -p audit-data audit-reports

[Step 2] 프로젝트 구조 분석
- Glob으로 전체 구조 파악
- 기술 스택 식별 (package.json, pyproject.toml, go.mod 등)
- 보안 관련 디렉토리 식별: auth/, middleware/, api/, config/
→ audit-data/project-structure.md 저장

[Step 3] 보안 관련 파일 식별
Grep으로 보안 키워드 검색:
- "password", "secret", "token", "api_key", "auth", "jwt"
- "cors", "csrf", "helmet", "sanitize", "validate"
- "exec(", "eval(", "innerHTML", "dangerouslySetInnerHTML"
→ audit-data/security-files.md 저장

[Step 4] 의존성 수집
- package.json / package-lock.json 읽기
- 또는 requirements.txt / Pipfile / go.mod
→ audit-data/dependencies.md 저장

[Step 5] 설정 파일 수집
- .env.example, .env.local 패턴 (실제 .env는 읽지 않음)
- CORS 설정, 보안 헤더, CSP 정책
- Docker 설정 (Dockerfile, docker-compose.yml)
→ audit-data/config-files.md 저장
```

**--scope 모드**: Step 2-3에서 지정 경로만 탐색.
**--deps-only 모드**: Step 4만 실행 후 npm audit 바로 실행.

---

> TM1(앱 보안 25항목)·TM2(인프라 보안 15항목)·TM3(의존성 보안 10항목)의 Spawn 프롬프트 전문은 `references/team-definitions.md` 참조. Stage 1 병렬 분석 시 각 TM은 해당 프롬프트로 spawn.

## 6. Stage 2: 통합 오딧 리포트 (Lead)

### 6.1 통합 절차

```
[Step 1] 3개 리포트 수집
audit-reports/{app-security,infra-security,dependency-security}.md 읽기

[Step 2] 중복 이슈 통합
같은 코드/설정에 대한 여러 관점의 지적 → 하나로 통합
예: TM1(시크릿 노출) + TM2(시크릿 관리) → 통합

[Step 3] 심각도 재분류
- 여러 TM이 지적한 이슈 → 심각도 상향 고려
- Critical은 Lead가 코드 직접 확인하여 교차 검증
- CVSSv3 스코어 통일

[Step 4] 통합 리포트 생성
audit-reports/SECURITY-AUDIT-{date}.md 작성
```

### 6.2 통합 리포트 형식

```markdown
# 보안 오딧 통합 리포트

## 개요
| 항목 | 값 |
|------|-----|
| 대상 프로젝트 | {프로젝트명} |
| 감사 범위 | {전체 / 특정 경로} |
| 실행 일시 | {YYYY-MM-DD} |
| 팀 구성 | Lead + 3 Specialists |
| 취약점 총계 | Critical:{N} High:{N} Medium:{N} Low:{N} |

## 보안 점수
| 영역 | Critical | High | Medium | 점수 |
|------|:--------:|:----:|:------:|:----:|
| 앱 보안 | {N} | {N} | {N} | {/10} |
| 인프라 보안 | {N} | {N} | {N} | {/10} |
| 의존성 보안 | {N} | {N} | {N} | {/10} |
| **종합** | | | | **{/10}** |

## Critical 취약점 (즉시 수정 필수)
### C-1: {취약점 제목}
- **영역**: {앱/인프라/의존성}
- **파일**: `{경로}:{라인}`
- **CVSSv3**: {스코어} ({벡터})
- **공격 시나리오**: {설명}
- **수정안**: ```{코드}```
- **검증**: [교차검증됨]

## High 취약점 (1주 내 수정 권장)
(동일 형식)

## Medium/Low 취약점
| # | 영역 | 파일 | 취약점 | CVSSv3 | 수정안 |
|:-:|------|------|--------|:------:|--------|

## 양호 사항
- {보안 모범 사례가 적용된 사례}

## 권장 액션 플랜
1. [즉시] {Critical 수정 항목}
2. [1주] {High 수정 항목}
3. [1개월] {Medium 개선 항목}
4. [지속] {보안 모니터링 항목}
```

---

## 7. --quick 모드 (빠른 검사)

Agent-Teams 없이 Lead가 상위 15항목만 빠르게 점검:

```
[앱 보안 상위 5]
□ SQL/NoSQL Injection
□ XSS (Stored, Reflected)
□ 인증 우회 경로
□ IDOR (직접 객체 참조)
□ Command Injection

[인프라 보안 상위 5]
□ 하드코딩된 시크릿
□ .env .gitignore 누락
□ 보안 헤더 미설정
□ 디버그 모드 프로덕션 노출
□ CORS 과도한 허용

[의존성 보안 상위 5]
□ npm audit Critical/High
□ 폐기된 패키지 사용
□ 메이저 2버전+ 뒤처진 패키지
□ lock 파일 미커밋
□ GPL 라이선스 오염
```

---

## 8. 에러 핸들링 & Fallback

### TM 실패 시

| 실패 유형 | 대처 |
|----------|------|
| Spawn 실패 | Lead가 해당 영역 상위 5항목 직접 검사 |
| 분석 중 에러 | Lead가 미완료 부분만 보충 |
| 리포트 미생성 | Lead가 해당 영역 핵심 3개만 검사 |

### 전체 Fallback

```
agent-teams 불가 시:
1. Lead가 --quick 모드 자동 실행 (상위 15항목)
2. npm audit 실행 (의존성 부분)
3. 통합 리포트 동일 형식으로 생성
4. 리포트에 "Fallback: 단일 에이전트 모드 (상위 15항목)" 표시
```

---

## 9. 환각 방지 프로토콜

> **공통 프로토콜**: `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md` 참조

**이 스킬 고유 규칙**:
- Critical/High 이슈는 반드시 실제 코드에서 `[검증됨]` 마커로 입증
- 추정 기반 Critical 이슈 금지 (Medium 이하만 허용)
- CVSSv3 스코어 산정 시 실제 공격 벡터 확인 필수
- 실제 .env 파일은 절대 읽지 않음 (코드 내 참조 패턴만 분석)
- 의존성 CVE는 반드시 `npm audit` 또는 공식 CVE 데이터베이스로 확인

---

## 10. code-review vs security-audit 비교

| 항목 | agent-teams-code-review | security-audit |
|------|:-----------------------:|:--------------:|
| 대상 | git diff (변경분) | 전체 코드베이스 |
| 초점 | 4관점 (보안 1/4) | 보안 100% (3영역) |
| 의존성 | X | npm audit / CVE |
| 체크리스트 | 25항목 (보안) | 50항목 (OWASP+ASVS) |
| 시점 | PR/커밋 리뷰 | 릴리스 전, 정기 감사 |
| 추천 | 일상적 코드 리뷰 | 보안 감사, 릴리스 전 |
