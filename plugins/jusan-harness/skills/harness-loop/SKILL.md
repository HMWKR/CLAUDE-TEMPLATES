---
name: harness-loop
description: |
  CE 기반 멀티 에이전트 오케스트레이션 + 품질 게이트 루프.
  프로젝트의 .claude/agents/*.md를 자동 탐지하여 에이전트 역할을 동적 분류하고,
  사용자 요청에 맞는 에이전트를 선택하여 개선→검증→채점→수정→재검증 루프를 자동 실행.
  **Mega Loop**: N라운드(기본 20) = 1 Mega Loop 단위. 진행률과 잔여 이슈를 Mega Loop 단위로 추적.
  **Insight Gate**: 매 라운드 후 부서별 인사이트 파일에 자동 분배 + 누락 체크.
  **Playwright Final Gate**: 마지막 라운드에서 Playwright MCP 직접 브라우저 검증 필수.
  **Task Router**: 단발 작업(감사/구축/분석/정리 등)도 에이전트 매핑 + 검증 + 인사이트 축적을 거침.
  Use when "/harness", "하니스", "에이전트 루프", "품질 게이트 루프",
  "에이전트 오케스트레이션", "CE 루프", "개선 루프 돌려",
  "/harness --task", "에이전트로 작업", "감사해줘", "인사이트 정리",
  or when a task requires multi-agent orchestration with quality gates.
  NOT for: single-file edits, simple questions, projects without .claude/agents/.
---

## ⚠️ Uncompromising Rigor (글로벌 룰 강제 적용)

이 스킬은 `~/.claude/rules/uncompromising-rigor.md` 의 4개 정책을 **무조건 준수**한다:

1. **Browser Tool Priority** — 브라우저 우선순위는 `rules/uncompromising-rigor` §1(2026-07-07 Playwright MCP 전역 우선)을 따른다. 사용자의 실제 로그인 세션 재사용이 필요할 때만 Chrome MCP(`mcp__claude-in-chrome__*`).
2. **Self-Justification Red Flags** — "이 정도면 충분" / "사소함" / "사용자가 신경 안 씀" / "베타니까 OK" / "fetch 진행 중이라 정상" 등장 시 **즉시 자기 차단**
3. **All Findings Are Defects** — 모든 발견은 결함. 사용자가 명시적으로 "강등"한 것만 Low
4. **Per-Round Deep Analysis** — 매 라운드 5단계 심층 분석 강제 (이전 재조회 → 미세 재스캔 → Adversarial walk → 자기 정당화 자가 검증 → 신규+재현성)

---

# Harness — CE 멀티 에이전트 오케스트레이션 엔진

> **철학**: "적절한 에이전트에게 위임하고, 검증하고, 반복한다"
> **원칙**: 에이전트 이름은 하드코딩하지 않는다 — 프로젝트에서 동적으로 읽는다
> **범용**: PetFit 전용이 아닌, 어떤 프로젝트든 에이전트만 정의되면 자동 작동
> **2가지 모드**: Mega Loop (반복 개선) + Task Router (단발 작업)

---

## 핵심 개념

### Mega Loop
- **1 Mega Loop = N라운드** (기본 20, `--rounds N`으로 조절)
- 진행률 표시: `"Mega Loop 1 / Round 5 of 20"`
- Mega Loop 완료 시 전체 보고서 생성
- 연속 실행: `"Mega Loop 2 시작"` → 이전 Mega Loop의 잔여 이슈 자동 이월
- 사용자가 "20번 루프 돌아줘"라고 하면 → 1 Mega Loop (20 라운드)

### Insight Gate
- 에이전트 도메인 기반으로 인사이트 파일을 **자동 탐지/생성**
- 매 라운드 후 Director가 해당 부서 인사이트에 기록했는지 체크
- **범용**: 어떤 프로젝트든 에이전트만 정의되면 인사이트 구조가 자동으로 따라옴

### Playwright Final Gate
- 마지막 라운드에서 **Playwright MCP 직접 브라우저 검증 필수**
- `browser_navigate` + `browser_snapshot` — 정적 분석이 아닌 실제 렌더링 확인
- 콘솔 에러 0건 목표, 스크린샷 촬영

---

## 실행 모드

### Mega Loop (반복 개선)

| 모드 | 명령어 | 설명 |
|:----:|--------|------|
| **기본** | `/harness "작업 설명"` | 1 Mega Loop (20라운드) |
| **반복** | `/harness "작업 설명" --rounds N` | 1 Mega Loop (N라운드) |
| **메가** | `/harness "작업 설명" --mega M` | M Mega Loops (각 20라운드) |
| **전체** | `/harness --full` | 전체 품질 게이트 (Evaluator 전원 호출) |
| **점검** | `/harness --status` | 에이전트 + 인사이트 탐지 결과만 출력 (실행 안 함) |

### Task Router (단발 작업)

| 모드 | 명령어 | 설명 |
|:----:|--------|------|
| **작업** | `/harness --task "작업 설명"` | 단발 작업 라우팅 (루프 없음) |
| **감사** | `/harness --audit [보안/성능/접근성/인프라]` | 특화 감사 실행 |
| **생성** | `/harness --create [에이전트/인사이트/스킬]` | 구조물 자동 생성 |
| **정리** | `/harness --cleanup` | 인사이트 정리 + 교차 부서 전파 + 중복 병합 |

### 자동 모드 판별

사용자가 `/harness` 뒤에 작업 설명만 제공하면 **자동 판별**:
```
"20번 루프 돌아줘", "반복 개선해줘" → Mega Loop
"보안 감사해줘", "에이전트 만들어줘" → Task Router
"인사이트 정리해줘", "스킬 업데이트해줘" → Task Router
```

---

## Task Router: 단발 작업 오케스트레이션 (범용)

> **원칙**: 루프가 아닌 작업도 에이전트 매핑 + 품질 검증 + 인사이트 축적을 거친다.

### TR-1. 작업 유형 자동 분류

| 카테고리 | 키워드 | 실행 패턴 |
|----------|--------|----------|
| **구축** | "만들어줘", "생성", "구축", "설계", "create" | Director(병렬) → Evaluator |
| **감사** | "감사", "검사", "점검", "audit", "review" | Evaluator(병렬) → 보고서 |
| **수정** | "수정", "고쳐", "fix", "update" | Director → QA → Evaluator |
| **분석** | "분석", "조사", "리서치", "analyze" | Evaluator(병렬) → 종합 |
| **정리** | "정리", "통합", "cleanup", "organize" | Director → Evaluator |
| **마이그레이션** | "마이그레이션", "이전", "migrate" | Director → QA(검증) |

### TR-2. 에이전트 자동 매핑

```
1. Phase 0에서 파싱된 에이전트 목록 로드
2. 작업 설명의 키워드와 각 에이전트의 description/activation 매칭
3. 매칭 점수 상위 에이전트 선택:
   - 구축: Director 1-3명 병렬
   - 감사: Evaluator 2-4명 병렬
   - 수정: Director 1명 + QA 1명 순차
   - 분석: Evaluator 2-3명 병렬
4. 관련 Evaluator 자동 추가 (감사가 아니어도 품질 검증)
```

### TR-3. 실행

```
┌─ Step 1: 작업 실행 ───────────────────────────┐
│ 선택된 에이전트에게 작업 위임                    │
│ 병렬 가능한 작업은 병렬로 실행                   │
└───────────────────────────────────────────────┘
                     ↓
┌─ Step 2: 품질 검증 ───────────────────────────┐
│ QA 또는 Evaluator가 결과 검증                   │
└───────────────────────────────────────────────┘
                     ↓
┌─ Step 3: 인사이트 축적 ──────────────────────┐
│ Insight Gate 실행 (Phase 0.5 참조)             │
│ 작업 영역 인사이트 파일에 기록 확인              │
└───────────────────────────────────────────────┘
                     ↓
┌─ Step 4: 빌드/검증 게이트 ───────────────────┐
│ 코드 변경 있으면 → npm run build 검증           │
│ 웹 앱이면 → Playwright MCP 검증 (선택)         │
│ 변경 없으면 → 보고서만 출력                     │
└───────────────────────────────────────────────┘
```

> **Task Router 작업 보고 템플릿**은 [references/report-templates.md](references/report-templates.md) 의 "Task Router 결과" 섹션 참조.

### TR-5. 예시

**"에이전트 조직 만들어줘"** → 구축
- Director 투입 → 에이전트 파일 생성 → Evaluator 검증 → 인사이트 기록

**"보안 감사해줘"** → 감사
- 보안 Evaluator + BE리드 병렬 → PASS/FAIL 리포트 → security-insights에 기록

**"인사이트 정리해줘"** → 정리
- 각 부서 리드 병렬 → 중복 병합 + 교차 전파 → 메타 인사이트 기록

**"스킬 업데이트해줘"** → 수정
- Director → 스킬 파일 수정 → QA 검증 → 인사이트 기록

---

## Phase 0: 에이전트 자동 탐지 + 역할 분류

### 0-1. 에이전트 파일 탐색

```
Glob(".claude/agents/*.md")
```

**에이전트가 없는 경우:**
> "이 프로젝트에는 `.claude/agents/` 에이전트가 정의되어 있지 않습니다.
> 에이전트 조직을 먼저 설계하세요 (`/agent-architect` 또는 수동 생성)."
→ 스킬 종료

### 0-2. 에이전트 정의 파싱

각 `*.md` 파일에서 추출:

| 필드 | 소스 | 용도 |
|------|------|------|
| `name` | frontmatter `name:` | Agent tool의 `subagent_type` |
| `description` | frontmatter `description:` | 역할 요약 |
| `tools` | frontmatter `tools:` | 실행 가능 도구 목록 |
| `role` | `[ROLE]` 섹션 | 역할 상세 |
| `tasks` | `[TASK]` 섹션 | 담당 업무 |
| `constraints` | `[CONSTRAINTS]` 섹션 | 제약 조건 |
| `activation` | `[ACTIVATION]` 섹션 | 트리거 키워드 |
| `sub_agents` | `[SUB-AGENTS]` 섹션 | 하위 에이전트 |

> **참조**: 파싱 로직 상세는 [references/agent-parser.md](references/agent-parser.md)

### 0-3. 역할 자동 분류

> **참조**: 분류 알고리즘 상세는 [references/role-classifier.md](references/role-classifier.md)

파싱된 에이전트를 4가지 역할로 분류:

| 역할 | 분류 기준 (키워드) | 특성 |
|------|-----------------|------|
| **Lead** | "총괄", "오케스트레이터", "직접 작업 금지", "위임" | 조율만, 실행 안 함 |
| **Director** | "개발", "구현", "설계", tools에 `Edit`/`Write` 포함 | 실행자 |
| **Evaluator** | "검증", "평가", "채점", "Read-only", "코드 수정 금지" | 검증자 |
| **QA** | "테스트", "QA", "품질", "앱 테스트" | 테스터 |

분류 우선순위: 복수 매칭 시 `constraints`의 "수정 금지" → Evaluator, "직접 작업 금지" → Lead

### 0-4. 에이전트 맵 출력

```
## 에이전트 탐지 결과

| 역할 | 에이전트 | 도메인 |
|------|---------|--------|
| Lead | {name} | {description} |
| Director | {name} | {description} |
| ... | ... | ... |

총 {N}개 에이전트 탐지됨.
Lead {N}개 / Director {N}개 / Evaluator {N}개 / QA {N}개
```

---

## Phase 0.5: Insight Gate — 부서별 인사이트 자동 탐지/생성 (범용)

> **범용 원칙**: PetFit 전용이 아닌, 어떤 프로젝트든 에이전트만 정의되면 인사이트 구조가 자동으로 따라온다.

### 0-5-1. 인사이트 경로 탐지

프로젝트에서 인사이트 디렉토리를 자동 탐색:
```
1. CLAUDE.md에 "domain-knowledge" 또는 "인사이트" 경로가 정의되어 있으면 → 해당 경로 사용
2. 없으면 → Glob("**/domain-knowledge/") 또는 Glob("**/insights/") 탐색
3. 없으면 → "docs/domain-knowledge/" 기본 경로로 자동 생성
```

### 0-5-2. 에이전트→인사이트 매핑 자동 생성

Phase 0에서 파싱된 에이전트 목록을 기반으로:
```
각 고유 도메인(FE, BE, AI, QA, UX, 데이터, 비즈니스, 보안, ...)에 대해:
1. 해당 도메인의 인사이트 파일이 존재하는지 확인
   예: FE 에이전트 있으면 → fe-insights.md 존재 확인
2. 없으면 → 자동 생성 (헤더 + 에이전트 이름 + 빈 템플릿)
3. 매핑 테이블 생성:
   | 도메인 | 인사이트 파일 | 담당 에이전트 |
   |--------|-------------|-------------|
   | FE | fe-insights.md | {FE 에이전트들} |
   | UX | ux-insights.md | {UX 에이전트들} |
   | ... | ... | ... |
```

### 0-5-3. 라운드별 인사이트 체크 (Phase 2에서 매 라운드 후 실행)

```
매 라운드 완료 후:
1. Director가 작업한 영역의 인사이트 파일을 확인
2. 해당 파일에 이번 라운드 날짜의 인사이트가 기록되었는지 확인
3. 누락 시 → Director에게 인사이트 기록 지시:
   "작업 완료 시 {insight_file}에 발견/결정 사항을 기록하세요."
4. 교차 영향 확인 → 관련 부서 인사이트에도 전파 지시
```

### 0-5-4. Mega Loop 완료 시 인사이트 보고

```
Mega Loop 완료 시:
- 각 인사이트 파일에 추가된 항목 수 집계
- 누락된 부서 인사이트 경고
- 교차 부서 인사이트 전파 상태 확인

## 인사이트 축적 현황
| 부서 | 파일 | 이번 Mega Loop 추가 | 총 항목 |
|------|------|:-------------------:|:-------:|
| FE | fe-insights.md | +3건 | 15건 |
| UX | ux-insights.md | +1건 | 4건 |
| ... | ... | ... | ... |
```

---

## Phase 1: 작업 매핑

### 1-1. 사용자 요청 분석

사용자의 작업 설명에서 키워드를 추출하여 각 에이전트의 `[ACTIVATION]` 섹션과 매칭.

매칭 알고리즘:
1. 사용자 요청의 키워드 추출
2. 각 Director의 `[ACTIVATION]` 키워드와 비교
3. 가장 높은 매칭 점수의 Director 선택
4. 해당 Director와 관련된 QA/Evaluator 자동 매핑

### 1-2. 실행 계획 생성

```
## 실행 계획

작업: "{사용자 요청}"
라운드: {N}회

| 단계 | 에이전트 | 역할 | 실행 방식 |
|------|---------|------|---------|
| 1. 구현 | @{director_name} | {description} | background |
| 2. 검증 | @{qa_name} | {description} | background |
| 3. 채점 | @{evaluator_names} | {descriptions} | 병렬 background |
| 4. 수정 | @{director_name} | 이슈 기반 수정 | background |
| 5. 재검증 | @{qa_name} | 수정 확인 | background |
```

사용자에게 계획 확인 후 실행.

---

## Phase 2: Mega Loop 실행

### 2-0. Mega Loop 구조 (범용)

```
1 Mega Loop = N 라운드 (기본 20)

for mega_loop in range(1, M+1):
    announce: "🔄 Mega Loop {mega_loop} 시작 (총 {N}라운드)"
    
    if mega_loop > 1:
        이전 Mega Loop 잔여 이슈 자동 이월
    
    for round in range(1, N+1):
        announce: "Mega Loop {mega_loop} / Round {round} of {N}"
        
        [Step 1-5: Director→QA→Evaluator→수정→재검증]
        
        [Step 6: Insight Gate 체크 (Phase 0.5 참조)]
        
        if round == N:  # 마지막 라운드
            [Playwright Final Gate 실행]
    
    [Mega Loop 보고서 생성]
    [인사이트 축적 현황 출력]
```

### 2-1. 라운드 구조

```
for round in range(1, N+1):
    
    ┌─ Step 1: Director 실행 ──────────────────────────┐
    │ Agent(subagent_type=director_name,                │
    │       prompt=작업지시+이전라운드이슈,              │
    │       run_in_background=True)                     │
    └───────────────────────────────────────────────────┘
                          ↓ 완료 대기
    ┌─ Step 2: QA 검증 (Director 결과 기반) ────────────┐
    │ Agent(subagent_type=qa_name,                      │
    │       prompt=검증지시+Director결과요약,             │
    │       run_in_background=True)                     │
    └───────────────────────────────────────────────────┘
                          ↓ 완료 대기
    ┌─ Step 3: Evaluator 채점 (병렬) ──────────────────┐
    │ 각 Evaluator를 병렬 Agent로 실행                  │
    │ 결과: 점수 + 이슈 목록                            │
    └───────────────────────────────────────────────────┘
                          ↓ 이슈 있으면
    ┌─ Step 4: Director 수정 (이슈 기반) ──────────────┐
    │ QA/Evaluator가 발견한 이슈를 Director에게 전달    │
    │ Director가 수정 → QA 재검증                       │
    └───────────────────────────────────────────────────┘
                          ↓
    ┌─ Step 5: 라운드 보고 ────────────────────────────┐
    │ | Round N | 작업 | 이슈 N건 | 점수 변화 |         │
    └───────────────────────────────────────────────────┘
```

### 2-2. 라운드 간 이슈 전달

이전 라운드에서 발견된 이슈 중 미해결 항목은 다음 라운드의 Director 프롬프트에 포함:

```
## 이전 라운드 미해결 이슈
- [Major] {이슈 설명} (Round {N}에서 발견)
- [Minor] {이슈 설명}

이 이슈들을 우선 수정한 후 새로운 개선을 진행하세요.
```

### 2-3. 종료 조건

다음 중 하나를 만족하면 루프 종료:
1. 지정된 라운드 수 완료
2. QA에서 이슈 0건 (완벽 상태)
3. 연속 2라운드 점수 변화 없음 (수렴)
4. 사용자가 중단 요청

> **종료·예산 강화 (루프 하네스 조사 반영 2026-06-26)** — 가능하면 프로세스(훅/스크립트)로 **결정론적 강제**, 스킬 프로세는 그 스펙 문서일 뿐:
> - #2 "이슈 0건"은 **자기 선언만으로 종료 금지** — 외부 검증 명령 **exit 0**(빌드/`tsc --noEmit`/Playwright Final Gate) **AND** 명시 종료신호 이중조건 충족 시에만. 자기평가 단독 종료는 정지오염(평균 3.57x·최대 25x 비용폭주, arxiv:2605.05846 / ralph-claude-code) 공격면.
> - **서브에이전트 호출 예산**: 라운드당 8 / 전체 60 초과 시 정지 + 진단요청(자원고갈 방어, Microsoft Agentic AI Failure Taxonomy).
> - **다신호 stagnation**: 동일 에러 5라운드 / 산출 70% 감소 2연속 → cooldown 1회 후 정체면 인간 개입.
> - **컨텍스트 오염** 누적 시 다음 라운드를 fresh-context 서브에이전트로(Ralph: 1이터=새컨텍스트=1커밋, 상태는 디스크 인계). 상세: `live-verify-loop` "Loop Hardening" 섹션.

---

> ## Phase 3: 최종 보고 — **최종 보고서 템플릿**(라운드별 추적 표 + 점수 변화 그래프 + 잔여 이슈 handoff)은 [references/report-templates.md](references/report-templates.md) 참조.

## Phase 3.5: Playwright Final Gate (범용 — 마지막 라운드 필수)

> **원칙**: 마지막 라운드에서 반드시 Playwright MCP로 **실제 브라우저**를 열어 검증한다.
> 정적 분석(파일 읽기)이 아닌, 실제 HTTP 응답 + 렌더링 상태를 확인한다.

### 3-5-1. 웹 앱 검증 (dev 서버가 있는 프로젝트)

```
마지막 라운드(Round N of N)에서:

1. dev 서버 실행 여부 확인 (curl로 HTTP 응답 체크)
2. 서버 미실행 시 → 시작 명령 실행 (CLAUDE.md 또는 package.json scripts 참조)
3. Playwright MCP로 핵심 페이지 순회:
   - browser_navigate("{url}") → 페이지 로드
   - browser_snapshot() → 렌더링 상태 확인 (빈화면/에러/정상)
   - 콘솔 에러 확인
4. 결과를 테이블로 정리:
   | # | 페이지 | URL | 상태 | 비고 |
5. FAIL 발견 시 → Director에게 즉시 수정 지시 → 재검증
```

### 3-5-2. 검증 범위 자동 결정

```
1. CLAUDE.md에 라우트/페이지 목록이 있으면 → 전체 순회
2. 없으면 → package.json의 dev 서버 포트 + 주요 경로 추론:
   - "/" (홈)
   - "/login" 또는 "/auth" (인증)
   - 기타 src/app/ 또는 src/pages/ 에서 추출
3. 인증 필요 페이지 → 307 리다이렉트가 정상 동작인지 확인
```

### 3-5-3. 모바일 뷰포트 검증 (선택)

```
핵심 4페이지를 375px 뷰포트로도 확인:
- 홈, 목록, 상세, 로그인
- 반응형 깨짐 여부 확인
```

### 3-5-4. 비웹 프로젝트

웹 앱이 아닌 프로젝트(CLI, 라이브러리, API 전용)는:
- Playwright 대신 **빌드 + 타입 검사 + 테스트 실행**으로 대체
- `npm run build` / `tsc --noEmit` / `npm test` 결과를 Final Gate로 사용

### 3-5-5. 절대 금지

```
- taskkill, kill -9, pkill 등 프로세스 강제 종료 금지 (Claude Code 크래시 원인)
- 포트별 PID만 타겟팅: netstat -ano | grep ":PORT" → taskkill //PID {PID} //F
```

---

## 에이전트 프롬프트 템플릿

### Director 프롬프트

```
당신은 {project_name} 프로젝트의 {agent_name}입니다.

## 작업 지시
{user_request}

## 이전 라운드 피드백 (있을 경우)
{previous_issues}

## 제약 조건
{parsed_constraints}

## 결과 형식
수정한 파일 목록과 변경 내용을 보고하세요.
```

### QA 프롬프트

```
당신은 {project_name} 프로젝트의 {agent_name}입니다.

## 검증 대상
{director_result_summary}

## 검증 항목
1. 코드 수정 정상 동작 확인
2. 에러/경고 없음 확인
3. 기존 기능 회귀 확인

## 결과 형식
각 이슈별: [Critical/Major/Minor] + 설명 + 검증 마커
코드 수정은 절대 하지 마세요.
```

### Evaluator 프롬프트

```
당신은 {project_name} 프로젝트의 {agent_name}입니다.

## 평가 대상
{director_result_summary}

## 평가 기준
{parsed_tasks_from_agent_definition}

## 결과 형식
항목별 점수 + 근거 + 개선 제안
```

---

## 주의사항

### 에이전트가 1개뿐인 경우
- Director 1개만 있으면 → QA/Evaluator 없이 Director만 실행 + 자체 검증
- Evaluator가 없으면 → QA 결과만으로 루프 진행

### 에이전트 충돌 방지
- 동일 파일을 수정하는 Director가 2개 이상이면 → 순차 실행 (병렬 금지)
- 각 에이전트의 `[CONSTRAINTS]` 쓰기 범위를 확인하여 충돌 회피

### 환각 방지
- Director 결과를 "믿지 말고 검증": 반드시 QA/Evaluator로 확인
- Evaluator 점수를 "절대값으로 해석하지 말 것": 상대 변화 추적이 핵심
- 에이전트가 보고한 파일 경로는 Glob으로 존재 확인 후 사용

### CLAUDE.md와의 관계
- CLAUDE.md에 에이전트 조직도가 있으면 참조하되, `.claude/agents/*.md`가 SSOT
- CLAUDE.md의 품질 게이트 규칙이 있으면 Phase 2 루프에 반영
- domain-knowledge/ 인사이트 축적 규칙이 있으면 Director에게 전달

---

## debug-failure 모드 (2026-05-25 추가 — 인사이트 2의 debug-failure skill 통합)

> 사용자 P1-1 결정: 별도 `debug-failure` 스킬 신설 X. **본 스킬에 모드로 통합** (Senior Engineer 권장 — `harness-eval.js`와 자연 연동).

### 트리거

| 트리거 | 조건 |
|---|---|
| `/harness-loop --mode=debug-failure` | 명시 호출 |
| 테스트/빌드/명령 실패 발생 | 자동 모드 전환 권장 |
| 사용자 발화 | "디버그", "실패 분석", "에러 원인" |

### 5-Step 실패 분석 워크플로우

| Step | 작업 | 산출물 |
|:-:|---|---|
| **1. 실패 캡처** | 정확한 실행 명령 + 전체 에러 메시지 캡처 (요약 X) | `failure-{N}.log` |
| **2. 첫 의미 있는 에러 식별** | 마지막 cascade 에러가 아닌 **첫 root 에러** 찾기. 스택 트레이스 역추적 | `root-cause-{N}.md` |
| **3. 가설 1개 수립** | 다수 가설 비교 X — **가장 가능성 높은 1개**부터. (다수 가설은 다음 라운드) | `hypothesis-{N}.md` |
| **4. 가설 검증** | 가설을 빠르게 검증할 최소 변경 (예: 1라인 수정, 1 조건 출력) | `verify-{N}.log` |
| **5. 최소 수정 + 재실행** | 검증된 원인만 수정 (인접 코드 정리 X). 재실행하여 ① 단위 통과 확인 | `fix-{N}.diff` + 재실행 로그 |

### 다음 라운드 분기

- **수정 통과** → 종료 + harness-eval.js 에 실패 패턴 누적
- **수정 실패** → Step 3으로 (다른 가설 1개)
- **3회 실패 후** → 가설 매트릭스 작성 + 사장 질의

### harness-eval.js 통합

- 매 실패 → `harness-eval.js` 의 5축 평가 데이터에 실패 패턴 누적
- 누적된 패턴 → 다음 라운드에서 **유사 실패 회피** 우선 검사
- 회피 권장 패턴 표시: `[harness] 이전 라운드 실패 패턴과 유사 — 가설 X 우선 검토`

### 인사이트 1 매핑 (Step 1~10)

| Step | 인사이트 1 단계 | 본 모드 매핑 |
|:-:|---|---|
| 1 | Input Normalizer | 실패 명령 + 에러 로그 정규화 |
| 2 | Intent Classifier | 실패 유형 분류 (테스트/빌드/런타임/네트워크/...) |
| 3 | Task Router | 단순 실패 (단일 가설) vs 복잡 실패 (다중 가설 매트릭스) |
| 4 | Context Builder | 관련 파일 + 최근 커밋 + 환경 변수 수집 |
| 5 | Planner | 가설 1개 + 검증 명령 |
| 6 | Tool Executor | 최소 수정 + 재실행 |
| 7 | Draft Generator | 수정 diff |
| 8 | Critic / Verifier | 재실행 로그 + ① 단위 통과 확인 (CLAUDE_TEMPLATE.md 검증 사다리 §6a 연동) |
| 9 | Refiner | 통과 시 인접 영향 점검 + 다른 테스트 회귀 없음 확인 |
| 10 | Output Renderer | 실패 → 수정 → 검증 결과 정리 (`fix-{N}.md`) + harness-eval 누적 |

### 우회 금지

- "비슷한 에러라서 패스" → 자기 합리화 차단 (Uncompromising Rigor §2)
- "원인 추측만 하고 검증 안 함" → Step 4 의무 실행
- "cascade 마지막 에러를 root 처리" → Step 2 의무 (첫 의미 있는 에러)
