# GA4 + GTM 이벤트 명세 — 7 표준 이벤트

> Google 공식 추천 이벤트명 + 핵심 파라미터 정의.
> PII 절대 금지 — 익명화 파라미터만 사용.

---

## 1. GTM 컨테이너 코드 (app/layout.tsx 삽입)

```tsx
import Script from 'next/script';

const GTM_ID = process.env.NEXT_PUBLIC_GTM_ID || 'GTM-XXXXXXX';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <head>
        <Script
          id="gtm-head"
          strategy="afterInteractive"
          dangerouslySetInnerHTML={{
            __html: `
              (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
              new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
              j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
              'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
              })(window,document,'script','dataLayer','${GTM_ID}');
            `,
          }}
        />
      </head>
      <body>
        <noscript>
          <iframe
            src={`https://www.googletagmanager.com/ns.html?id=${GTM_ID}`}
            height="0"
            width="0"
            style={{ display: 'none', visibility: 'hidden' }}
          />
        </noscript>
        {children}
      </body>
    </html>
  );
}
```

## 2. 7 표준 이벤트 명세

### 2.1 cta_click — CTA 성과
```typescript
// 사용 예
<button
  data-track="consultation-cta"
  data-cta-location="hero"
  onClick={() => {
    window.dataLayer?.push({
      event: 'cta_click',
      cta_text: '무료 상담 신청',
      cta_location: 'hero',
      page_path: window.location.pathname,
    });
  }}
>
  무료 상담 신청
</button>
```

GTM Tag 설정:
```
Tag type: Google Analytics: GA4 Event
Event name: cta_click
Parameters: cta_text, cta_location, page_path
Trigger: Custom Event = cta_click
```

### 2.2 view_pricing — 가격 페이지 조회
```typescript
// useEffect 안에서
useEffect(() => {
  window.dataLayer?.push({
    event: 'view_pricing',
    page_path: '/pricing',
  });
}, []);
```

### 2.3 select_plan — 요금제 선택
```typescript
const handlePlanSelect = (plan) => {
  window.dataLayer?.push({
    event: 'select_plan',
    plan_name: plan.name,  // 'free' | 'pro' | 'business'
    plan_price: plan.price,
  });
};
```

### 2.4 form_start — 폼 첫 입력
```typescript
const handleFirstInput = () => {
  if (!formStarted.current) {
    window.dataLayer?.push({
      event: 'form_start',
      form_name: 'consultation',
      page_path: window.location.pathname,
    });
    formStarted.current = true;
  }
};
```

### 2.5 generate_lead — 리드 생성 (Google 공식 추천)
```typescript
const handleLeadSubmit = (formData) => {
  window.dataLayer?.push({
    event: 'generate_lead',
    lead_source: 'consultation_form',
    // ❌ 절대 금지: email, name, phone
  });
};
```

### 2.6 sign_up — 회원가입 완료 (Google 공식 추천)
```typescript
const handleSignUpSuccess = () => {
  window.dataLayer?.push({
    event: 'sign_up',
    method: 'email' | 'google' | 'kakao',
  });
};
```

### 2.7 purchase — 결제 완료 (Google 공식 추천)
```typescript
const handlePurchaseSuccess = (order) => {
  window.dataLayer?.push({
    event: 'purchase',
    transaction_id: order.id,  // 익명 ID
    value: order.total,
    currency: 'KRW',
    items: order.items.map(item => ({
      item_id: item.sku,
      item_name: item.name,
      price: item.price,
      quantity: item.quantity,
    })),
  });
};
```

## 3. PII 방지 검증 패턴 (Claude 자동 grep)

```bash
# 코드에서 PII 패턴 검출
grep -rEn '(email|phone|name|ssn|password|user_email|user_name|user_phone)' \
  --include='*.ts' --include='*.tsx' \
  src/ | grep -v 'test\|spec'
```

## 4. Consent Mode v2 (EU/UK/CH 의무)

```typescript
// GTM 첫 호출 전 default 설정
window.dataLayer?.push({
  event: 'default_consent',
  ad_storage: 'denied',
  ad_user_data: 'denied',
  ad_personalization: 'denied',
  analytics_storage: 'denied',
});

// 사용자 동의 후 update
window.dataLayer?.push({
  event: 'consent_update',
  ad_storage: 'granted',
  analytics_storage: 'granted',
});
```
