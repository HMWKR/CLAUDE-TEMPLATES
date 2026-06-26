---
name: ga4-funnel
description: |
  GA4 + GTM 통합 이벤트 명세 + Funnel exploration wrapper. cta_click / view_pricing / select_plan / form_start / generate_lead / sign_up / purchase 핵심 이벤트 설계 + Enhanced Measurement + Key event + Funnel 시각화.
  PII 방지 (이메일/전화/이름/검색어 절대 미전송) 정책 의무.
  Use when "ga4", "google analytics 4", "gtm", "funnel", "퍼널", "전환", "이벤트 추적", "/ga4-funnel".
  NOT for: 행동 분석 정성 (use clarity-tracker), 정적 코드 검수 (use frontend-review).
user_invocable: true
---

# GA4 + GTM Funnel Wrapper

> **신설 (2026-05-26 web-audit-pipeline #5)** — GA4 + GTM 이벤트 명세 + Funnel exploration wrapper.
> **외부 도구**: analytics.google.com + tagmanager.google.com (계정 발급 필요 — 사용자 직접)
> **Claude 자동화**: GTM 코드 삽입 + 이벤트 명세 + Funnel 템플릿 + PII 방지 가드

## ⚠️ Uncompromising Rigor §1-§4 정합

- **§1**: GA4 대시보드 브라우저 작업 시 Chrome MCP 우선
- **§2**: PII 전송 합리화 ("그냥 이메일도 보내자") 절대 차단
- **§3**: PII 위반은 자동 High (강등 불가 — 법적 리스크). 이벤트 누락은 Medium
- **§4**: 매 라운드 5단계 (이전 funnel 재조회 → 새 drop-off → Adversarial → 자기 정당화 → 신규)

## 1. 책임 경계

| 자산 | 영역 |
|---|---|
| **`ga4-funnel`** (본 wrapper) | GA4 이벤트 명세 + Funnel + 정량 분석 |
| `clarity-tracker` | 정성 (세션 / 히트맵) — 보완 |
| `legal-compliance-review` Tier 1 (GDPR) | 동의 수집 컴플라이언스 |
| `frontend-review` Tier 1 (UI) | CTA 코드 검수 |
| `web-audit-pipeline` | 5 도구 통합 |

**라우팅**: 정량 퍼널 → 본 wrapper / 정성 세션 → `clarity-tracker` / GDPR 동의 → `legal-compliance-review` / 5 도구 → `web-audit-pipeline`.

## 2. 사용자 액션 (Claude 자동화 불가)

```
1. https://analytics.google.com/ 접속
2. GA4 Property 생성
3. Web Data Stream 생성 → Measurement ID 발급 (G-XXXXXXXXXX)
4. https://tagmanager.google.com/ 접속
5. GTM Container 생성 → GTM-XXXXXXX 발급
6. Claude 에게 G-XXX + GTM-XXX 전달
```

## 3. Claude 자동화 (ID 받은 후)

### 3.1 GTM 컨테이너 코드 삽입

`references/ga4-event-spec.md` 의 GTM 스니펫을 `app/layout.tsx` 에 삽입.

### 3.2 Enhanced Measurement 자동 활성

```
GA4 → Admin → Data streams → Web stream → Enhanced measurement
→ Page views / Scrolls / Outbound clicks / Site search ON
```

### 3.3 핵심 이벤트 설계 (7개 표준)

| 이벤트명 | 트리거 | 주요 파라미터 | 목적 |
|---|---|---|---|
| `cta_click` | 주요 CTA 클릭 | `cta_text`, `cta_location`, `page_path` | CTA 성과 |
| `view_pricing` | 가격 페이지 조회 | `page_path` | 가격 관심도 |
| `select_plan` | 요금제 선택 | `plan_name`, `plan_price` | 플랜 선호도 |
| `form_start` | 첫 입력 시작 | `form_name`, `page_path` | 폼 진입 |
| `generate_lead` | 문의/상담 제출 | `lead_source` | 리드 생성 (Google 추천) |
| `sign_up` | 회원가입 완료 | `method` | 가입 전환 (Google 추천) |
| `purchase` | 결제 완료 | `transaction_id`, `value`, `currency` | 매출 (Google 추천) |

### 3.4 Key Event 표시 (전환 측정)

```
GA4 → Admin → Data display → Events → 이벤트 선택 → Mark as key event
```

대상: `generate_lead` / `sign_up` / `purchase` (또는 `thank_you` 페이지 도달)

### 3.5 Funnel Exploration 템플릿

`references/funnel-templates.md` 참조 — 3가지 표준 퍼널:
- 상담 퍼널 (B2B SaaS)
- 회원가입 퍼널
- 이커머스 퍼널

## 4. 10단계 파이프라인 View

```
Step 1 Input   : Measurement ID + GTM Container ID + 비즈니스 유형
Step 2 Classifier : 도메인 (B2B / B2C SaaS / E-commerce / Lead Gen)
Step 3 Router : GTM 삽입 / 이벤트 설계 / Funnel 생성
Step 4 Context : 핵심 CTA + 폼 + 결제 흐름 파악 (코드 grep)
Step 5 Planner : 7 표준 이벤트 매핑 + 추적 속성 (data-track) 식별
Step 6 Tool : GTM 코드 Edit + data-track 속성 Edit
Step 7 Draft : 이벤트 명세 + Funnel 단계 작성
Step 8 Critic : §3 정합 — PII 전송 검증 (이메일/전화/이름/검색어 grep)
Step 9 Refiner : Key Event 표시 + Consent Mode v2 권고
Step 10 Output : 보고서 (아래 §6)
```

## 5. PII 방지 정책 (Uncompromising Rigor §3 정합, 강등 불가)

### 절대 금지

```
❌ email=user@example.com
❌ phone=01012345678
❌ name=홍길동
❌ query=홍길동 전화번호
❌ user_id=실제이메일주소
❌ search_term=주민번호
```

### 익명화 패턴 (필수)

```
✅ lead_type=demo_request
✅ plan_name=pro
✅ cta_location=hero
✅ form_name=consultation
✅ user_type=guest | logged_in
✅ user_id=hashed_id_abc123 (해시값)
```

### 자동 검증

Claude는 이벤트 명세 작성 후 다음 grep 실행:
- `email` / `phone` / `name` / `ssn` / `password` 키워드 검출 시 즉시 차단
- 사용자 명시 승인 후만 진행

## 6. 출력 형식

```markdown
## GA4 + GTM Funnel Report — <date>

### Setup
- Measurement ID: <G-XXX>
- GTM Container: <GTM-XXX>
- Enhanced Measurement: 활성
- Key Events: generate_lead / sign_up / purchase
- Consent Mode v2: 활성 / 비활성

### 핵심 이벤트 (7개)
- [ ] cta_click — 적용 페이지 X건
- [ ] view_pricing — /pricing
- [ ] select_plan — N개 플랜 매핑
- [ ] form_start — N개 폼 매핑
- [ ] generate_lead — Key Event
- [ ] sign_up — Key Event
- [ ] purchase — Key Event

### Funnel Drop-off (퍼널 분석)

#### P0 (전환 차단)
- **Funnel 4→5 (form_start → generate_lead)**: 65% 이탈
  - 추정: 전화번호 필드 부담

#### P1 (큰 영향)
- **Funnel 1→2 (page_view → cta_click)**: 92% 이탈
- **Funnel 3→4 (select_plan → page_view /signup)**: 40% 이탈

### PII 검증
- 검출된 PII 파라미터: 0건 ✓
- 익명화 파라미터: X건
```

## 7. 옵션

| 옵션 | 효과 |
|---|---|
| `--type=b2b` | 상담 퍼널 우선 |
| `--type=b2c-saas` | 회원가입 퍼널 우선 |
| `--type=ecommerce` | 이커머스 퍼널 우선 |
| `--with-consent-v2` | Google Consent Mode v2 자동 적용 |
| `--validate-pii` (default) | PII 검출 시 차단 |
| `--key-events=auto` | Key event 자동 표시 가이드 |

## 8. 라우팅 다른 스킬

| 작업 | 권고 스킬 |
|---|---|
| 세션 리플레이 / 히트맵 | `clarity-tracker` |
| GDPR / 동의 컴플라이언스 | `legal-compliance-review` |
| CTA 코드 검수 | `vercel-guidelines` / `frontend-review` |
| 5 도구 통합 | `web-audit-pipeline` |
