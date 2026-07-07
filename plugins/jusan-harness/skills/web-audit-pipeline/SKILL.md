---
name: web-audit-pipeline
description: |
  프로덕션 웹 검수 5 도구 통합 오케스트레이터. Vercel UI Guidelines (코드 리뷰) → AccessLint (WCAG 2.2) → Lighthouse CI (성능/SEO/BP/A11y) → Clarity (실사용자 정성) → GA4 Funnel (정량 전환) 7단계 자동 라우팅 + P0/P1/P2/P3 통합 백로그 단일 출력.
  사각지대(실사용자 정량+외부 객관+비즈니스 임팩트) 메움. 기존 70 스킬과 책임 경계 매트릭스 정합.
  Use when "web audit", "웹 검수", "프로덕션 검수", "/web-audit", "5 도구 통합", "사이트 종합 검수".
  NOT for: 단일 도구만 (use 각 wrapper), 코드 PR만 (use frontend-review / backend-review), 라이브 시뮬레이션만 (use playwright-uiux-audit).
user_invocable: true
---

# Web Audit Pipeline — 5 도구 통합 오케스트레이터

> **신설 (2026-05-26 web-audit-pipeline #6 — 메타 오케스트레이터)** — 가이드 7단계 + P0~P3 백로그.
> **5 wrapper 라우팅**: vercel-guidelines → accesslint → lighthouse-ci → clarity-tracker → ga4-funnel

## ⚠️ Uncompromising Rigor §1-§4 정합

- **§1 브라우저 우선순위**: rules/uncompromising-rigor §1(2026-07-07 Playwright MCP 전역 우선)을 따른다. Lighthouse는 자체 Chrome 사용(별도 프로세스). Clarity 대시보드처럼 로그인 세션 재사용이 필요할 때만 Chrome MCP.
- **§2 Self-Justification**: "이 정도면 충분" / "사용자가 신경 안 씀" / "실사용자 데이터 없어도 됨" 등 차단
- **§3 All Findings Are Defects**: 5 도구 발견 모두 P0~P3 등재. 사용자 명시 강등만 P3
- **§4 Per-Round Deep Analysis**: 매 라운드 5단계 (이전 발견 재조회 → 미세 재스캔 → Adversarial → 자기 정당화 → 신규)

## 1. 책임 경계 매트릭스 (76 스킬 분담)

| 자산 | 영역 | 본 오케스트레이터와 관계 |
|---|---|---|
| **`web-audit-pipeline`** (본 메타) | 5 도구 통합 + P0~P3 백로그 | — |
| `vercel-guidelines` | UI 코드 리뷰 (Vercel 가이드) | 단계 2 호출 |
| `accesslint` | WCAG 2.2 라이브 audit | 단계 3 호출 |
| `lighthouse-ci` | 성능/SEO/BP/A11y 외부 객관 | 단계 4 호출 |
| `clarity-tracker` | 실사용자 정성 (세션/히트맵) | 단계 5 호출 |
| `ga4-funnel` | 정량 전환 퍼널 | 단계 6 호출 |
| `frontend-review` (자체 18 sp) | PR/diff 프론트엔드 정적 | 대안 — PR 단위라면 본 메타 대신 호출 |
| `playwright-uiux-audit` (라이브 18 sp) | Claude 라이브 walk | 보완 — clarity와 결합 가능 |
| `live-verify-loop` | 무한 검증 루프 | 대안 — 1회 종합 vs 무한 |
| `universal-experience-audit` | 8 청사진 프레임 (UI 무관) | 본 메타와 다른 차원 — UI 위주는 본 메타 |
| `project-ultra-audit` | 증거 기반 기능 완성도 | 본 메타와 결합 가능 |

**라우팅 규칙**:
- 5 도구 통합 1회 → 본 메타
- 단일 도구만 → 해당 wrapper
- 코드 PR 정적 → `frontend-review`
- 무한 루프 → `live-verify-loop`
- 경험 검수 (UI 무관) → `universal-experience-audit`

## 2. 7단계 파이프라인 (가이드 정합)

```
0. 검수 범위 선정 — 사용자 입력 URL/페이지 목록
   │
   ▼
1. vercel-guidelines     ← UI 코드 리뷰 (10 기준)
   │  결과 → P0~P3 (코드 영역)
   ▼
2. accesslint            ← WCAG 2.2 라이브 audit
   │  결과 → P0~P3 (접근성 영역)
   ▼
3. lighthouse-ci         ← 성능/A11y/BP/SEO + CrUX 실측
   │  결과 → P0~P3 (성능/객관 영역)
   ▼
4. clarity-tracker       ← 세션 리플레이 / 히트맵 / Dead-Rage clicks
   │  결과 → P0~P3 (실사용자 정성 영역)
   ▼
5. ga4-funnel            ← 전환 퍼널 drop-off
   │  결과 → P0~P3 (정량 영역)
   ▼
6. 백로그 통합 + 우선순위 정렬 — Owner / Effort / Page 그룹화
   │
   ▼
7. 최종 출력 — P0/P1/P2/P3 단일 백로그 + 실행 순서
```

## 3. 10단계 파이프라인 View (인사이트 1 매핑)

```
Step 1 Input   : URL 목록 + 검수 범위 + 모드 (one-shot / CI / live-monitoring)
Step 2 Classifier : 사이트 유형 (marketing / SaaS / e-commerce / admin)
Step 3 Router : 7단계 순차 → 5 wrapper 호출
Step 4 Context : 프로젝트 구조 / 핵심 페이지 / Clarity-GA4 ID 확인
Step 5 Planner : 단계별 시간 견적 + 의존성 (Clarity/GA4 ID 없으면 4-5 skip)
Step 6 Tool : 5 wrapper 호출 (vercel → accesslint → lighthouse → clarity → ga4)
Step 7 Draft : 각 wrapper 발견 수집
Step 8 Critic : §3 정합 — 5 영역 발견 모두 P0~P3 등재
Step 9 Refiner : 중복 통합 + 우선순위 정렬 + Owner 매핑
Step 10 Output : 통합 백로그 + 실행 plan (아래 §5)
```

## 4. 검수 범위 표준 (가이드 정합)

| 페이지 | URL | 핵심 목표 | 주요 CTA | 측정 이벤트 |
|---|---|---|---|---|
| 홈 | `/` | 서비스 이해 | 무료 상담, 회원가입 | `cta_click` |
| 가격 | `/pricing` | 요금제 비교 | 플랜 선택 | `select_plan` |
| 문의 | `/contact` | 리드 생성 | 문의 제출 | `generate_lead` |
| 회원가입 | `/signup` | 계정 생성 | 가입 완료 | `sign_up` |
| 결제 | `/checkout` | 구매 완료 | 결제 | `purchase` |
| 로그인 | `/login` | 재방문 사용자 | 로그인 | (auth) |
| 대시보드 | `/dashboard` | 서비스 사용 | 핵심 기능 | (app event) |

## 5. 통합 백로그 출력 형식

```markdown
## Web Audit Pipeline Report — <date>

### Summary
- 검수 페이지: N개 (홈 / 가격 / 문의 / 가입 / 결제)
- 사용 도구: 5/5 (vercel / accesslint / lighthouse / clarity / ga4)
- 발견: P0=X / P1=Y / P2=Z / P3=W (총 N건)
- 자동 수정 가능: M건

### Unified Backlog

| Priority | Source | Page | Issue | Evidence | Impact | Suggested Fix | Owner | Effort |
|----------|--------|------|-------|----------|--------|---------------|-------|--------|
| P0 | AccessLint | /contact | 폼 label 없음 | WCAG 1.3.1 | 스크린리더/폼 사용 불가 | label htmlFor 연결 | FE | S |
| P1 | Lighthouse | / | LCP 4.2s (CrUX Poor) | LCP 4.2s | 첫 화면 이탈 증가 | hero 이미지 optimize | FE | M |
| P1 | Clarity | /pricing | 플랜 CTA dead click | dead click 다수 | 전환 손실 | 클릭 영역/상태 수정 | FE | S |
| P1 | GA4 | /signup | 가입 2단계 이탈 높음 | funnel drop-off 65% | 가입 손실 | 필드 축소/오류 개선 | PM/FE | M |
| P2 | Vercel | / | CTA 위계 약함 | hero CTA 대비 낮음 | 클릭률 저하 | primary CTA 강조 | Design | M |
| P2 | Vercel | /pricing | 모바일 가격표 잘림 | 모바일 360px | 가격 비교 불가 | 카드 layout 조정 | FE | S |
| P3 | Lighthouse | /contact | meta description 누락 | SEO score 88 | 검색 노출 약화 | meta 추가 | FE | S |

### 우선순위 기준 (Uncompromising Rigor §3)
- **P0**: 핵심 전환/접근/결제 차단 (강등 불가)
- **P1**: 전환율/접근성/성능 큰 영향
- **P2**: 사용성 개선
- **P3**: polish (사용자 명시 강등만)

### 실행 순서 (시간 견적)
1. **P0 N건** (1~2일) — 가장 먼저
2. **P1 X건** (3~5일) — 다음 스프린트
3. **P2 Y건** (1주+) — 백로그
4. **P3 Z건** (시간 될 때) — polish

### 단계별 상세 결과
1. **Vercel Guidelines**: → `<vercel-guidelines 보고서 링크>`
2. **AccessLint**: → `<accesslint 보고서 링크>`
3. **Lighthouse CI**: → `<lighthouse 보고서 링크>`
4. **Clarity Tracker**: → `<clarity 분석 링크>`
5. **GA4 Funnel**: → `<funnel exploration 링크>`
```

## 6. 호출 패턴

### 6.1 1회성 빠른 진단 (가이드 권고)
```
/web-audit https://example.com /,/pricing,/contact,/signup,/checkout
```

### 6.2 단일 URL 종합
```
/web-audit https://example.com/pricing --all
```

### 6.3 도구 일부만
```
/web-audit https://example.com --skip=clarity,ga4
```
(Clarity/GA4 ID 없을 때 — 1,2,3 도구만)

### 6.4 CI 모드 (PR마다 자동)
```
/web-audit --ci
```
(lighthouse-ci + accesslint + frontend-review 결합)

### 6.5 라이브 모니터링 모드
```
/web-audit --live-monitoring https://example.com
```
(Clarity 7일 / GA4 funnel 30일 데이터 분석)

## 7. 옵션

| 옵션 | 효과 |
|---|---|
| `--all` (default) | 5 도구 모두 |
| `--skip=clarity,ga4` | 외부 ID 없을 때 |
| `--quick` | 코드 도구만 (vercel + accesslint + lighthouse) |
| `--data-only` | 실사용자만 (clarity + ga4) |
| `--ci` | PR 자동 검수 모드 |
| `--live-monitoring` | 운영 중 모니터링 모드 |
| `--threshold=strict` | Lighthouse Perf 90+ / A11y 100 |
| `--report-format=md\|html\|json` | 출력 형식 |

## 8. 의존성 체크 (Pre-flight)

```bash
# 5 도구 설치 확인
- vercel-guidelines: web-design-guidelines 스킬(플러그인 형제)의 SKILL.md 존재
- accesslint: claude plugin list | grep accesslint
- lighthouse: lighthouse --version (13.3.0+)
- lhci: lhci --version (0.15.1+)
- Clarity: PROJECT_ID env 또는 사용자 입력
- GA4: Measurement ID env 또는 사용자 입력
```

미설치/미설정 도구는:
- **자동 skip + 경고**: "Clarity ID 없음 — clarity-tracker 단계 skip"
- **자기 정당화 차단**: "이 정도면 충분" X — Clarity 미설정도 결함으로 백로그 등재

## 9. 실행 순서 권고 (가이드 정합)

### 9.1 1회성 빠른 진단
```
1. Lighthouse/PageSpeed 5 URL 측정 (10분)
2. AccessLint 5 URL 접근성 (15분)
3. Vercel Guidelines 핵심 컴포넌트 (10분)
4. Clarity 설치 (5분)
5. GA4 이벤트/퍼널 설계 확인 (10분)
6. P0/P1 백로그 작성 (15분)
총 ~1시간
```

### 9.2 개발팀 운영 방식
```
PR마다:
- vercel-guidelines (변경 UI 파일)
- accesslint
- lighthouse-ci (threshold)

운영 중 (주 1회):
- ga4-funnel (전환 퍼널)
- clarity-tracker (이탈 세션)
- 백로그 P0/P1/P2 정리
```

## 10. PII 방지 정책 (Uncompromising Rigor §3)

- GA4 이벤트: PII 절대 미전송 (`ga4-funnel` §5 정합)
- Clarity: 마스킹 Strict/Balanced (`clarity-tracker` §3 정합)
- Lighthouse: temporary-public-storage 는 임시 공개 — 민감 페이지는 lhci-server 자체 호스팅 권장

## 11. 라우팅 다른 스킬

| 작업 | 권고 스킬 |
|---|---|
| 단일 URL 단발 QA | `playwright-qa-expert` |
| 코드 PR/diff | `frontend-review` / `backend-review` / `fullstack-review` |
| 무한 검증 루프 | `live-verify-loop` |
| 경험 검수 (UI 무관) | `universal-experience-audit` |
| 증거 기반 기능 완성도 | `project-ultra-audit` |
| 보안 단독 | `security-review` |
| 컴플라이언스 (GDPR 등) | `legal-compliance-review` |
