# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 1. 프로젝트 개요

[TODO: 프로젝트 설명을 작성하세요]

**[프로젝트명]**은 [핵심 기능/목적]을 제공하는 [기술 스택] 애플리케이션입니다.

### 핵심 기능

1. **[기능 1]** - [설명]
2. **[기능 2]** - [설명]
3. **[기능 3]** - [설명]

### 기술 스택

- [프레임워크] ([버전])
- [언어] ([버전])
- [DB] ([버전])

---

## 2. Quick Start

### 설치 및 실행

```bash
# [TODO: 설치 명령어]
npm install
npm run dev
```

### 주요 명령어

| 명령어 | 설명 |
|--------|------|
| `npm run dev` | 개발 서버 실행 |
| `npm run build` | 프로덕션 빌드 |
| `npm test` | 테스트 실행 |

### 환경 변수

| 변수 | 필수 | 설명 |
|------|:----:|------|
| `[TODO]` | O | [설명] |

---

## 3. 아키텍처

### 폴더 구조

```
[TODO: 프로젝트 구조]
src/
├── components/
├── pages/
├── lib/
└── types/
```

### 데이터 흐름

```
[TODO: 데이터 흐름 다이어그램]
사용자 → API → DB → 응답
```

---

## 4. 핵심 모듈

### [모듈 1]

**위치**: `src/[경로]`
**역할**: [설명]

### [모듈 2]

**위치**: `src/[경로]`
**역할**: [설명]

---

## 5. 타입 시스템

[TODO: 핵심 타입/인터페이스 정의]

---

## 6. 테스트

```bash
npm test              # 전체 테스트
npm run test:watch    # 워치 모드
```

---

## 6a. 검증 사다리 (의무 — verification ladder)

> 코드 변경 후 **반드시 아래 4단계를 순차** 수행. UI/API 작업은 4단계 실행 의무. 사장 명시 강등 없이는 단계 스킵 금지.

### 4단계 검증 절차

| 단계 | 명령 (예시) | 의무 | 통과 기준 |
|:-:|---|:--:|---|
| **① 단위 테스트** | `npm test` / `pytest` / `go test ./...` | 항상 | 영향 받는 단위 테스트 0 실패 |
| **② 린트 / 타입체크** | `npm run lint` / `npm run typecheck` / `ruff check` / `mypy` | 항상 | 0 error (warning은 사장 검토) |
| **③ 빌드** | `npm run build` / `cargo build` / `go build` | 영향 시 | 빌드 성공 |
| **④ UI(Playwright) / API(curl)** | `mcp__claude-in-chrome__navigate` 우선 (Uncompromising Rigor §1) / `curl <endpoint>` | UI·API 변경 시 의무 | 화면 정상 렌더 / 응답 200 + 페이로드 검증 |

### 모드별 의무 매트릭스

| 작업 모드 | ① 단위 | ② 린트/타입 | ③ 빌드 | ④ UI/API |
|---|:--:|:--:|:--:|:--:|
| UI 컴포넌트 변경 | ✅ | ✅ | ✅ | **✅ Playwright 의무** |
| API 엔드포인트 변경 | ✅ | ✅ | ✅ | **✅ curl/요청 의무** |
| 백엔드 로직 (내부) | ✅ | ✅ | ✅ | — |
| 문서/주석만 | — | — | — | — |
| 설정 파일 (config) | — | ✅ | ✅ | 영향 시 |
| DB 마이그레이션 | ✅ | ✅ | ✅ | 영향 시 |

### 검증 결과 보고 (의무)

작업 완료 시 Claude는 다음 표를 출력:

| 단계 | 명령 | 결과 | 증거 |
|:-:|---|:--:|---|
| ① | `<실행 명령>` | PASS / FAIL | `<로그/스크린샷>` |
| ② | `<실행 명령>` | PASS / FAIL | `<로그>` |
| ③ | `<실행 명령>` | PASS / FAIL / N/A | `<로그>` |
| ④ | `<실행 명령>` | PASS / FAIL / N/A | `<로그/스크린샷>` |

**실패 보고 정책**: 단 한 단계라도 FAIL → "작업 완료" 보고 금지. 원인 분석 + 재시도 또는 사장 명시 보류 요청 후 진행.

### 검증 명령 채우기 ([TODO])

이 템플릿을 새 프로젝트에 복사한 직후 아래 명령들을 프로젝트별 실제 명령으로 교체:

```bash
# [TODO: 프로젝트별 ① 단위 테스트 명령]
npm test

# [TODO: 프로젝트별 ② 린트/타입체크 명령]
npm run lint && npm run typecheck

# [TODO: 프로젝트별 ③ 빌드 명령]
npm run build

# [TODO: 프로젝트별 ④ UI/API 검증 방식]
# UI: Playwright MCP — mcp__claude-in-chrome__navigate + browser_take_screenshot
# API: curl http://localhost:3000/api/<endpoint>
```

### 우회 금지 조항

- "이 정도면 충분"으로 단계 스킵 → rules/uncompromising-rigor.md §2(검증 종결 합리화 금지) 위반
- 코드로만 검증 ≠ UI/API 실제 동작 검증 (Simon Willison: "테스트 가능한 환경이 전부")
- 사장 명시 강등 발화 없이 ④ 단계 SKIP 금지

---

## 7. 환경 설정

[TODO: 개발 환경, 의존성, 설정 파일 목록]

---

## 8. 알려진 이슈 & TODO

- [ ] [TODO: 현재 이슈]
- [ ] [TODO: 향후 계획]

---

## 9. 병렬 작업 워크플로우 (선택 — Boris식 다중 Claude)

> Boris Cherny(Claude Code 창시자) 실사용 패턴. **대규모 변경 / 리뷰 분리 / 동시 탐색** 시 활용. 의무 아님.

### 사용 시점

| 상황 | 병렬 권장? | 이유 |
|---|:--:|---|
| 단일 파일 수정 | ❌ | 오버헤드 > 이득 |
| 다중 파일 리팩터링 (10+) | ✅ | 분담 + 컨텍스트 격리 |
| 큰 기능 구현 + 별도 리뷰 | ✅ | writer/reviewer 분리 |
| 광범위 코드베이스 탐색 | ✅ | 영역별 병렬 탐색 |
| 긴급 패치 (10분 내) | ❌ | 단일 세션 빠름 |

### git worktree 기반 병렬 세팅

```bash
# 1. 메인 작업 (현재 디렉토리, feature/X 브랜치)
git worktree add ../project-feature-X -b feature/X

# 2. 리뷰 작업 (별도 디렉토리, 같은 커밋)
git worktree add ../project-review-X

# 3. 두 디렉토리에서 각각 Claude Code 실행
cd ../project-feature-X && claude  # writer Claude
cd ../project-review-X && claude   # reviewer Claude
```

### writer / reviewer 분리 패턴

| 역할 | 호출 키워드 | 사용 스킬/에이전트 |
|---|---|---|
| **Writer Claude** | `/architect` 또는 `/orchestrate` | `architect`, `aidlc-baseline`, `live-verify-loop` |
| **Reviewer Claude** | "코드 리뷰", "보안 검토" | `ce-reviewer`, `security-reviewer`, `code-reviewer subagent` |

### 다중 Claude 협업 규칙

1. **writer는 본 매장 (feature 브랜치) 작업**, reviewer는 별도 매장 (review worktree) 읽기 전용
2. reviewer가 발견한 결함 → writer 에게 인용 형식으로 전달 (`> 파일:라인 — 문제 설명`)
3. writer 가 수정 → reviewer 가 재검토 → 합의 시 커밋
4. 두 Claude 모두 같은 `CLAUDE.md` + `.thoughts/` 참조 (정합 보장)
5. 충돌 결정 시 사장님 1차 판단

### 비권장 패턴

- 동일 파일을 두 Claude가 동시 수정 (race condition)
- writer 가 reviewer 결함을 반박 없이 거절 (반박은 reviewer 발화 인용 + 사장 판단 요청)
- 3+ Claude 동시 실행 (조율 비용 ↑)

### compound learnings (Every 식)

작업 완료 시 매 Claude 가:
1. `.thoughts/YYYY-MM-DD-{subject}.md` 에 CE 6단계 사고여정 자동 기록 (`thoughts-writer` 에이전트)
2. 반복 패턴·실수를 직접 점검 (자동 Stop hook 스캔은 현 하네스에서 제거 — 수동/`.thoughts/`)
3. 발견된 패턴/실수 → CLAUDE.md 또는 rules/ 에 누적

> **참조**: 인사이트 2의 "Compound Engineering" (Every의 Dan Shipper) — 매 실수가 다음 라운드 자재.

---

## 10. 프로덕션 검수 파이프라인 (선택)

> 글로벌 `web-audit-pipeline` 스킬 + `/web-audit` 슬래시 커맨드 사용. 5 외부 도구 통합으로 사각지대(실사용자 정량+외부 객관+비즈니스 임팩트) 0.

### 검수 5축

| # | 도구 | 영역 | 출력 |
|:-:|---|---|---|
| 1 | **Vercel Web Design Guidelines** | UI 코드 리뷰 (10 기준) | P0~P3 코드 |
| 2 | **AccessLint** | WCAG 2.2 A/AA 라이브 audit | P0~P3 접근성 |
| 3 | **Lighthouse CI** | 성능/A11y/BP/SEO + CrUX 실측 | LCP/INP/CLS + 4축 |
| 4 | **Microsoft Clarity** | 세션 리플레이 / 히트맵 / Dead-Rage clicks | 실사용자 정성 |
| 5 | **GA4 + GTM** | 전환 퍼널 drop-off | 정량 전환 |

### 사용자 액션 (1회만)

```
[TODO] 1. https://clarity.microsoft.com/ → 프로젝트 생성 + PROJECT_ID 발급
[TODO] 2. https://analytics.google.com/ → GA4 Property + Measurement ID (G-XXXXXXXXXX)
[TODO] 3. https://tagmanager.google.com/ → GTM Container + GTM-XXXXXXX
[TODO] 4. .env.local 환경변수:
        NEXT_PUBLIC_CLARITY_PROJECT_ID=<발급값>
        NEXT_PUBLIC_GA4_ID=<G-XXXXXXXXXX>
        NEXT_PUBLIC_GTM_ID=<GTM-XXXXXXX>
```

### Claude 호출

```
# 5 도구 모두 (ID 발급 후)
/web-audit https://example.com /,/pricing,/contact,/signup,/checkout

# 도구 1,2,3 만 (ID 없을 때)
/web-audit https://example.com --quick

# 단일 도구
/web-interface-guidelines src/app/page.tsx   # Vercel UI
/accesslint                                   # WCAG
lighthouse https://example.com --view         # Lighthouse
```

### 출력 — P0/P1/P2/P3 단일 백로그

| Priority | Source | Page | Issue | Suggested Fix | Owner | Effort |
|---|---|---|---|---|---|---|
| P0 | AccessLint | /contact | 폼 label 없음 | label htmlFor 연결 | FE | S |
| P1 | Lighthouse | / | LCP 4.2s (CrUX Poor) | hero 이미지 optimize | FE | M |
| P1 | Clarity | /pricing | dead click | 클릭 영역 수정 | FE | S |
| P1 | GA4 | /signup | 가입 2단계 65% 이탈 | 필드 축소 | PM/FE | M |
| P2 | Vercel | / | CTA 위계 약함 | primary CTA 강조 | Design | M |

### 우선순위 기준 (Uncompromising Rigor §3)

- **P0**: 전환/접근/결제 차단 (강등 불가)
- **P1**: 전환율/접근성/성능 큰 영향
- **P2**: 사용성 개선
- **P3**: polish (사용자 명시 강등만)

### 실행 순서

```
1회성 빠른 진단 (~1시간):
  1. Lighthouse 5 URL → 10분
  2. AccessLint 5 URL → 15분
  3. Vercel Guidelines 핵심 컴포넌트 → 10분
  4. Clarity 설치 → 5분
  5. GA4 이벤트/퍼널 → 10분
  6. P0/P1 백로그 → 15분

개발팀 운영:
  PR마다: vercel + accesslint + lighthouse-ci threshold
  운영 주 1회: ga4-funnel + clarity-tracker → 백로그
```

### PII 방지 (의무)

- GA4 이벤트: 이메일/전화/이름/검색어 **절대 미전송** (익명화 파라미터만)
- Clarity: 마스킹 Strict/Balanced (입력 필드 자동)
- Lighthouse: 민감 페이지는 lhci-server 자체 호스팅

### 책임 경계 (76 스킬 분담)

| 작업 | 권고 |
|---|---|
| 5 도구 통합 1회 | `/web-audit` (본 §10) |
| PR 코드 정적 | `/frontend-review` / `/backend-review` |
| Claude 라이브 walk | `/playwright-uiux-audit` |
| 무한 검증 루프 | `/live-verify` |
| 경험 검수 (UI 무관) | `/experience-audit` |

---

# 작업 지침

> 공통 규칙(언어, 환각 방지, 코드 작성, 보안 등)은 **글로벌 `~/.claude/CLAUDE.md`** 참조.
> 아래는 이 프로젝트에만 해당하는 보충 지침.

## 커밋 메시지 (4개 필수 섹션)

| # | 섹션 | 용도 |
|:-:|------|------|
| 1 | `[type]:` 헤더 | Conventional Commits |
| 2 | `## What` | 변경된 파일/기능 |
| 3 | `## Why` | 변경 이유 |
| 4 | `## Impact` | 영향 범위, 위험도, Breaking |
| - | `Co-Authored-By:` | AI 협업 표시 |

> Husky + Commitlint가 4개 섹션을 자동 검증합니다.

## CE 사고 여정 (.thoughts/)

커밋 후 `.thoughts/YYYY-MM-DD-{subject}.md`에 CE 관점 사고 과정을 기록합니다.

---

# End of CLAUDE.md
