# GA4 Funnel Exploration 템플릿 — 3 표준 퍼널

> Explore → Funnel exploration → Template 선택 후 단계 정의

---

## 1. B2B SaaS 상담 퍼널

```
Step 1: page_view, page_path = /
Step 2: cta_click, cta_location = hero
Step 3: page_view, page_path = /contact
Step 4: form_start, form_name = consultation
Step 5: generate_lead, lead_source = consultation_form
```

### 측정 포인트
- Step 1→2 (홈 진입 후 CTA 클릭률) — 보통 5~15%
- Step 2→3 (CTA 클릭 후 폼 도달) — 보통 70~90%
- Step 3→4 (폼 진입 후 입력 시작) — 보통 40~60%
- Step 4→5 (폼 시작 후 제출) — 보통 30~60%
- 전체 전환율 — 보통 0.5~3%

---

## 2. B2C SaaS 회원가입 퍼널

```
Step 1: page_view, page_path = /
Step 2: page_view, page_path = /pricing
Step 3: select_plan
Step 4: page_view, page_path = /signup
Step 5: sign_up, method = email/google/kakao
```

### 측정 포인트
- Step 1→2 (홈 → 가격) — 보통 20~40%
- Step 2→3 (가격 페이지 → 플랜 선택) — 보통 15~30%
- Step 3→4 (플랜 선택 → 가입 페이지) — 보통 80~95%
- Step 4→5 (가입 페이지 → 가입 완료) — 보통 40~70%
- 전체 전환율 — 보통 1~5%

---

## 3. 이커머스 퍼널

```
Step 1: view_item
Step 2: add_to_cart
Step 3: begin_checkout
Step 4: add_payment_info
Step 5: purchase
```

### 측정 포인트
- Step 1→2 (상품 조회 → 장바구니) — 보통 5~15%
- Step 2→3 (장바구니 → 체크아웃) — 보통 50~70%
- Step 3→4 (체크아웃 → 결제 정보) — 보통 60~80%
- Step 4→5 (결제 정보 → 구매 완료) — 보통 70~90%
- 전체 전환율 — 보통 1~3%

---

## 4. 퍼널 설정 방법 (GA4 UI)

```
1. GA4 → Reports → Explore → Blank
2. Technique: Funnel exploration
3. Steps 영역에 위 단계 추가
4. Breakdown: device / source / country 등 차원 추가
5. Filter: 날짜 / segment / 디바이스
6. Save (이름: "Consultation Funnel" 등)
7. 공유: PDF / CSV / 링크
```

## 5. 단계별 이탈 분석 (Drop-off Analysis)

각 단계에서 이탈한 사용자를 Audience 로 만들어 Clarity 에서 세션 확인:

```
GA4 → Audiences → New audience
→ Conditions: form_start AND NOT generate_lead (지난 30일)
→ Save as "Form Abandoners"

Clarity → Filters → Custom GA4 audience
→ "Form Abandoners" 선택
→ 해당 세션 리플레이 확인
```

이 흐름이 **양적 (GA4) + 정성 (Clarity)** 결합의 핵심.
