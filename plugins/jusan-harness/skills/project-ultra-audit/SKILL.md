---
name: project-ultra-audit
description: >
  증거 기반 초정밀 프로젝트 기능 완성도 검수 오케스트레이터. 어떤 프로젝트든 공개/사용자/관리자/슈퍼관리자 페이지, 권한·역할 정책,
  모든 버튼·입력창·링크·폼·상태, API/서버 처리 흐름, 데이터 저장/수정/삭제/복구, 테스트 케이스, 실제 작동 증거까지 검수한다.
  "화면 표시 ≠ 기능 작동"을 분리하고, 실행 증거 없이는 PASS를 쓰지 않으며, 빠진 페이지·작동 안 하는 기능·테스트 안 한 기능·
  임의 판단으로 완료 처리된 항목을 끝까지 찾아낸다. 직접 다 하지 않고 4개 작동 모드를 기존 하니스 스킬(live-verify-loop,
  ultradetail-walk, walk-all-deep, playwright-qa-expert, playwright-qa-agent-teams, continuous-qa-loop, harness-loop,
  domain-expert-analysis)에 라우팅하는 제어 계층이다.
  Use when "/project-ultra-audit", "전체 페이지 점검", "관리자 페이지 점검", "기능 누락 검출", "실제 작동 확인",
  "증거 기반 검수", "release readiness", "출시 준비 점검", "QA 전수 검수", "권한 테스트", "테스트 계획",
  "이거 실제로 작동하는지 검수", "완성도 검수".
  NOT for: 경험·UX 중심 검수(use universal-experience-audit), 단일 페이지 단발 QA(use playwright-qa-expert),
  코드 리팩토링, 단일 버그 수정, 단순 지식 질문.
  Codex 관련 변환/위임은 이 스킬 범위 밖이다 (Claude 네이티브 전용).
allowed-tools: ['*']
---

## ⚠️ Uncompromising Rigor (글로벌 룰 강제 적용)

이 스킬은 `~/.claude/rules/uncompromising-rigor.md` 4개 정책을 **무조건 준수**한다. blueprint §3 "절대 원칙"의 실행 강제 계층이다:

1. **Browser Tool Priority** — `mcp__claude-in-chrome__*` 우선, `mcp__playwright__*` 는 fallback only
2. **Self-Justification Red Flags** — "일반적으로 됩니다" / "작동할 것으로 보입니다" / "문제없어 보입니다" / "구현된 것 같습니다" / "이 정도면 충분합니다" / "확인은 못 했지만 정상일 것입니다" 등장 시 **즉시 자기 차단**
3. **All Findings Are Defects** — 모든 발견은 결함. 사용자 명시 강등만 Low
4. **Per-Round Deep Analysis** — Stage 5 라이브 검증 / Stage 7 루프 매 라운드 5단계 심층 분석 강제

훅 강제: `detect-self-justification.sh` + `block-on-self-justification.sh` + `check-chrome-mcp-priority.sh` + `anti-hallucination.md` ([검증됨]/[추정]/[미확인]).

---

# Project Ultra Audit — 증거 기반 초정밀 기능 완성도 검수

## Core Principle (blueprint §19)

> **이 스킬은 "예쁘게 정리하는 검수자"가 아니다. 빠진 것을 끝까지 찾고, 관리자 페이지를 절대 빼먹지 않고, 권한 테스트를 실제로 분리하고, 화면과 기능 작동을 구분하고, 테스트하지 않은 것을 테스트했다고 말하지 않고, 실행 증거 없이는 PASS를 쓰지 않으며, 미확인 항목을 숨기지 않고, 프로젝트 완성도를 냉정하게 판정한다.**

이 스킬은 **다른 검수 스킬 위에 올라가는 제어 계층(오케스트레이터)** 이다. 4개 작동 모드를 적합한 하니스 스킬에 라우팅하고 결과를 5상태 판정 + 22섹션 출력계약으로 수렴시킨다.

**universal-experience-audit 와의 차이**: 그쪽은 *경험 품질*(UX/서비스/CX), 이쪽은 *기능 작동 증거*(PASS=실행 증거). 둘은 짝을 이루는 보완 스킬.

**원천 명세**: `references/` (blueprint §3·§6·§7·§10·§12 원문 보존). 본문은 포인터만 유지.

---

## 절대 원칙 (blueprint §3 — 출력에 항상 적용)

> 상세 원문: `references/status-evidence.md`

1. **증거 없는 PASS 금지** (§3.1) — 브라우저 실행/명령어 출력/API 응답/DB 저장 확인/로그/스크린샷/콘솔/네트워크/실제 데이터 변경 중 하나 이상 없으면 PASS 불가.
2. **화면 표시 ≠ 기능 작동 분리** (§3.2) — 페이지 열림은 "표시 확인"일 뿐. 저장/수정/삭제/복구/검색/필터/정렬/페이지네이션/권한제한/알림/이메일/결제/업로드/다운로드/관리자 반영/사용자 반영/데이터 영속성은 각각 별도 검증.
3. **관리자 페이지 생략 금지** (§3.3) — 설명에 없어도 admin/dashboard/console/cms/backoffice/manager/operator/root/settings/users/roles/permissions/logs/billing 등 키워드 검토.
4. **권한 테스트 필수** (§3.4) — 비회원~슈퍼관리자 12역할 검토. 미해당은 NOT APPLICABLE(생략 금지).
5. **임의 판단 금지** (§3.5) — 화면 보인다고 작동 단정 / 테스트 안 했는데 완료 / API 응답만으로 UI 반영 PASS 금지. → rigor §2 훅 차단.
6. **추정과 확정 분리** (§3.6) — 확정 / 추정 / 확인 필요 / 확인 없이는 진행 불가 구분. → anti-hallucination 마커.

---

## 작동 모드 (blueprint §5 — Stage 1에서 자동 결정)

| 모드 | 사용 조건 | 라우팅 |
|---|---|---|
| **planning-only** | 실행 환경 없음 (설명/기획만) | domain-expert-analysis + 자료 기반 추정. 실행 항목 전부 NOT TESTED / BLOCKED |
| **repository-audit** | 저장소/코드 있음 | walk-all-deep / Explore (라우트·관리자경로·API·권한·데이터모델·테스트코드 탐색) |
| **runtime-verification** | 실행 환경 + 계정 있음 | Chrome MCP + live-verify-loop (실제 클릭·제출·API·저장·반영·차단 확인) |
| **regression-suite** | 테스트 자동화 생성/보강 | playwright-qa-expert / playwright-qa-agent-teams (TC 생성) |

여러 모드 동시 적용 가능. 환경에 따라 자동 분기.

---

## 8-Stage 파이프라인

```
[Stage 0 Pre-Flight & Rigor + 증거-PASS 규칙 부착]
        ↓
[Stage 1 입력 계약 + 작동 모드 결정] ── 부족분 질문(최대 5개)
        ↓
[Stage 2 프로젝트 이해 + 사용자 역할 정의] ── 확정/추정/확인필요 분리
        ↓
[Stage 3 전체 페이지/표면 인벤토리] ── 공개·사용자·관리자 + Discovery
        ↓
[Stage 4 전수 상세 검수] ── 페이지/버튼/입력/기능/관리자/데이터/API
        ↓
[Stage 5 라이브 작동 검증] ── Chrome MCP 증거 수집 → 5상태 판정
        ↓
[Stage 6 권한 테스트 매트릭스] ── 역할 × 접근대상 조합
        ↓
[Stage 7 테스트 케이스 / regression] ── (선택 --loop 수렴)
        ↓
[Stage 8 출력 계약 수렴] ── 22섹션 + 완료 기준 + 자체 점검
```

### Stage 0 — Pre-Flight & Rigor + 증거-PASS 규칙 부착
rigor §1~§4 + blueprint §3.1 증거-PASS 규칙 활성 선언. "실행하지 않은 것은 PASS가 아니라 NOT TESTED" 최상단 고정.

### Stage 1 — 입력 계약 + 작동 모드 결정
- **입력** (blueprint §4): 필수=프로젝트 설명/저장소/문서. 선택=프로젝트 형태/대상 사용자/필수·제외 기능/기술 스택/실행·테스트 명령어/관리자·일반 계정/테스트 데이터/배포 URL/API 문서/DB 접근/테스트 범위/금지 작업.
- **부족 시**: 멈추지 않고 가능 범위 검수 진행, 부족분 BLOCKED/NOT TESTED. 질문은 한 번에 최대 5개. 단 저장소/문서 있으면 질문 전 직접 탐색.
- **모드 결정**: 위 작동 모드 표 기준 자동 분기.

### Stage 2 — 프로젝트 이해 + 사용자 역할 정의
- blueprint §6.1 프로젝트 이해 정리 (한줄설명/문제/사용자/행동/시스템 역할/결과물/핵심가치/확정/추정/확인필요/검수가능범위/막힌항목).
- blueprint §6.2 사용자 역할 정의 (역할별 접근 가능·불가 페이지/행동/데이터/관리자 권한 차이/테스트 상태/증거).

### Stage 3 — 전체 페이지/표면 인벤토리
- blueprint §6.3 공개/사용자/관리자 페이지 전수 나열 (60+ 표준 페이지 후보). 미해당은 NOT APPLICABLE + 이유.
- **라우팅**: 저장소 있으면 `walk-all-deep`/`ultra-walk-deep` Discovery(6시그널 grep) → 매트릭스 → 사용자 승인. LLM 자기 판단 SKIP 금지.
  - **repository-audit 정적 모드 명확화**: 인터랙티브 매트릭스 승인이 필요 없는 단순 정적 탐색은 `Explore`/`Grep` 직접 수행으로 충분하다. `walk-all-deep`/`ultra-walk-deep` 위임은 (a) 사용자 승인 매트릭스가 필요하거나 (b) walk-fix-walk 무한 사이클로 확장할 때만 강제. 어느 경로든 "어떤 표면을 SKIP했는지 추측 금지" 원칙은 동일 적용.

### Stage 4 — 전수 상세 검수
blueprint §6.4~§6.10 체크리스트로 전수 검수:
- 6.4 페이지별 (40+ 항목) / 6.5 버튼별 / 6.6 입력창별 / 6.7 기능별 / 6.8 관리자별(더 엄격) / 6.9 데이터 구조 / 6.10 API·처리 흐름.
- **라우팅**: UI는 `ultradetail-walk` DOM 전수(임의 판단 0건). API 주소 모르면 임의 생성 금지 → "예상 API"/"확인 필요".
- **상세**: `references/audit-procedures.md`.

### Stage 5 — 라이브 작동 검증 (runtime-verification)
- blueprint §10 실제 작동 확인 계약. 각 기능: 확인한 기능/방법/계정·권한/입력값/실행 결과/기대 일치 여부/증거/남은 문제.
- **라우팅**: **Chrome MCP(1순위)** 실제 클릭·폼 제출·API 호출·저장 확인·관리자 반영·권한 차단. 실패 시 Playwright MCP. + `live-verify-loop`("코드 100% ≠ 라이브 100%").
- **판정**: 증거 수집 후 5상태(PASS/FAIL/BLOCKED/NOT TESTED/NOT APPLICABLE). OK/완료/확인됨/문제없음 등 표현 금지.
- **상태 분류 결정 규칙 (repository-audit ↔ runtime 경계)**: ① 코드상 구현은 확인됐으나 실제 실행/렌더/저장을 검증 안 함 → **NOT TESTED** (기본). ② 검증을 시도했으나 계정·권한·서버·실행환경·데이터 부재로 막힘 → **BLOCKED** (필요 조건 명시). ③ 런타임 실행 + 증거 확보 + 기대=실제 일치 → **PASS**. 즉 "코드 존재"는 절대 PASS 근거가 아니며, repository-audit 단독 결과의 기능 항목 기본값은 NOT TESTED다.
- **환경 없을 때**: blueprint §11 고정 문구 출력 + 필요 자료·계정·환경·명령어·URL·테스트 순서 정리, 실행 항목 BLOCKED/NOT TESTED.

### Stage 6 — 권한 테스트 매트릭스
- blueprint §9. 조합: 비회원/로그인/권한없음/정지/탈퇴/일반관리자/슈퍼관리자 × URL 직접입력·API 직접호출·타인 데이터 요청·삭제된 데이터 접근.
- 각: 테스트 항목/역할/접근 대상/사전조건/실행 행동/기대·실제 결과/상태/증거/미확인 사유.

### Stage 7 — 테스트 케이스 / regression (선택 --loop)
- blueprint §8 TC 표(13컬럼) + §11 test_type. 자동화 가능/수동 분리.
- **라우팅**: `playwright-qa-expert` / `playwright-qa-agent-teams`. 수렴 루프 시 `continuous-qa-loop`/`harness-loop` (발견→수정→재검증, rigor §4 5단계 증거).

### Stage 8 — 출력 계약 수렴
- blueprint §12 22섹션 보고서 + §13 완료 기준(15조건, 증거 없으면 완료 선언 금지) + §14 실패/미완료 보고 형식 + §15 자체 점검 12항목.
- **상세**: `references/output-format.md`.

---

## blueprint ↔ 하니스 매핑 (접목의 본질)

| blueprint 요소 | 하니스 자산 | 강제 수준 |
|---|---|:--:|
| §3.1 증거 없는 PASS 금지 | `live-verify-loop` R45/R54/R55 메타학습 + rigor §2 | 훅 + 스킬 |
| §3.5 임의 판단 금지 / §3.6 추정·확정 분리 | rigor §2 + `anti-hallucination.md` | 훅 exit2 |
| §7 5상태값 (OK/완료 금지) | rigor §3 All Findings Are Defects | 룰 강제 |
| §5.2 repository-audit | `walk-all-deep` / `ultra-walk-deep` Discovery / Explore | 스킬 위임 |
| §5.3 runtime-verification | Chrome MCP(1순위) / Playwright(fallback) + `live-verify-loop` | rigor §1 |
| §6.4~6.8 전수 검수 (페이지·버튼·입력·관리자) | `ultradetail-walk` DOM 전수 + 8축 카오스 | 스킬 위임 |
| §5.4 regression-suite / §8 TC | `playwright-qa-expert` / `playwright-qa-agent-teams` | 스킬 위임 |
| 수렴(발견→수정→재검증) | `continuous-qa-loop` / `harness-loop` | 스킬 위임 |
| planning-only 추정 | `domain-expert-analysis` | 스킬 위임 |

> **제외**: blueprint §16.3·compiler §5.2 Codex 변환 / §16.4·§5.4 custom-harness / §5.3 generic-agent / multi-target 컴파일 구조는 **이 스킬 범위 밖** (Claude 네이티브 전용).

---

## 테스트 상태 표기 규칙 (blueprint §7 — 절대 고정)

| 상태 | 의미 | 조건 |
|---|---|---|
| PASS | 실제 실행 + 기대=실제 일치 | 증거 필수 |
| FAIL | 실제 실행 + 기대≠실제 | 재현 절차 필수 |
| BLOCKED | 계정·권한·환경·서버·데이터로 막힘 | 필요 조건 명시 |
| NOT TESTED | 아직 미테스트 | PASS처럼 표현 금지 |
| NOT APPLICABLE | 미해당 | 이유 명시 |

**금지**: OK / 완료 / 확인됨 / 문제없음 / 대체로 가능 / 정상으로 보임.

---

## 최종 출력 (blueprint §12, 22섹션)

요약/확정·추정·확인필요/사용자 역할/전체 페이지/공개·사용자·관리자 페이지 상세/기능별 요구사항/데이터 구조/API/권한 정책/전체 TC/관리자 TC/예외 TC/보안 TC/실제 작동 확인 절차/테스트 결과 기록표/미확인 항목/실패·위험 항목/완료 기준/다음 작업/최종 자체 점검. → `references/output-format.md`.

---

## 옵션 플래그
- `--mode=planning|repository|runtime|regression` — 작동 모드 강제 (기본 자동 분기)
- `--loop` — Stage 7 수렴 루프 활성
- `--teams` — Agent-Teams 병렬 (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)
- `--focus=<page|admin|permission|api|data>` — 특정 표면 집중

---

## 자체 점검 (blueprint §15 — 최종 답변 전 필수)
관리자 페이지 빠짐없이? 모든 역할 검토? 모든 페이지 나열? 모든 버튼·입력창 검토? 권한 없는 접근 테스트 항목? 데이터 저장·수정·삭제 확인 방법? 실제 미확인을 PASS로 안 썼나? 추정·확정 구분? 실패 가능성 안 숨겼나? 완료 기준 명확? 미확인 분리? BLOCKED 조건 명시? — 하나라도 부족하면 수정 후 제출.

---

## 10단계 파이프라인 View (인사이트 1 매핑, 2026-05-25 P2-4c 추가)

> 본 스킬은 증거 기반 초정밀 기능 완성도 검수 오케스트레이터 — 4 작동 모드 (planning/repository/runtime/regression) + 기존 하니스 스킬 라우팅. 인사이트 1의 Step 6(Tool Executor 실행 증거) + Step 8(Critic 화면 표시 vs 기능 작동 분리)이 가장 강하게 매핑.

| Step | 인사이트 1 단계 | 본 스킬 매핑 |
|:-:|---|---|
| 1 | Input Normalizer | 프로젝트 상태 (PRD / repository / 실제 runtime / 회귀 베이스) 정규화 |
| 2 | Intent Classifier | 작동 모드 결정 (planning/repository/runtime/regression) — 자동 분기 |
| 3 | Task Router | 적합 하니스 스킬 라우팅 (live-verify-loop / ultradetail-walk / walk-all-deep / playwright-* / continuous-qa-loop / harness-loop / domain-expert-analysis) |
| 4 | Context Builder | 페이지/권한/역할/API/데이터 매트릭스 수집 |
| 5 | Planner | 각 페이지 + 모든 버튼/입력창/링크/폼/상태 체크 계획 |
| 6 | **Tool Executor (강함)** | **실행 증거 필수** — 라이브 호출 결과 / 스크린샷 / API 응답 (`mcp__claude-in-chrome__*` 우선) |
| 7 | Draft Generator | 페이지별 / 기능별 검수 결과 |
| 8 | **Critic / Verifier (강함)** | **화면 표시 ≠ 기능 작동** 분리 / 실행 증거 없으면 PASS 금지 / 임의 판단 PASS 금지 |
| 9 | Refiner | 우선순위 + 사용자 명시 강등만 Low (UR §3) + Stage 7 --loop 수렴 |
| 10 | Output Renderer | 통합 완성도 리포트 — 작동/미작동/테스트누락/임의완료 명확 분리 |

### Uncompromising Rigor 정합 (본 스킬 핵심)

- **§2 자기 합리화**: "화면 보이니까 OK" 차단 / "이 정도면 충분" 차단
- **§3 모든 발견 결함**: 실행 증거 없는 항목 = BLOCKED 등록
- **§4 매 라운드 5단계**: --loop 모드에서 의무

### 확립 패턴 (P1-6) — 증거 기반 오케스트레이션 특화

infra-audit(P1-6)와 동일 framing. 본 스킬은 "실행 증거 없이 PASS 금지"가 핵심 차이.

> **참조**: 인사이트 1 — `.thoughts/2026-05-25-harness-insights-round1.md` / 회고 — `.thoughts/2026-05-25-harness-application-completed.md`