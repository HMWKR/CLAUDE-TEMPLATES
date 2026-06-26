// Microsoft Clarity Next.js Script 컴포넌트 템플릿
// app/layout.tsx 에 통합 (App Router)
// YOUR_PROJECT_ID 를 clarity.microsoft.com 에서 발급받은 값으로 교체

import Script from 'next/script';

interface RootLayoutProps {
  children: React.ReactNode;
}

const CLARITY_PROJECT_ID = process.env.NEXT_PUBLIC_CLARITY_PROJECT_ID || 'YOUR_PROJECT_ID';

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="ko">
      <body>
        {children}

        {/*
          Microsoft Clarity 설치
          - strategy: afterInteractive (Hydration 후 로드)
          - id 명시 (중복 로드 방지)
          - dangerouslySetInnerHTML 사용 (Clarity 공식 스니펫)
        */}
        {CLARITY_PROJECT_ID !== 'YOUR_PROJECT_ID' && (
          <Script
            id="microsoft-clarity"
            strategy="afterInteractive"
            dangerouslySetInnerHTML={{
              __html: `
                (function(c,l,a,r,i,t,y){
                  c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
                  t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
                  y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
                })(window, document, "clarity", "script", "${CLARITY_PROJECT_ID}");
              `,
            }}
          />
        )}

        {/*
          Consent API v2 (EU/UK/CH 의무)
          - 사용자 동의 후 호출
          - GTM/CMP에서 호출하는 게 일반적
        */}
        <Script
          id="clarity-consent-v2"
          strategy="afterInteractive"
          dangerouslySetInnerHTML={{
            __html: `
              window.addEventListener('clarity-consent', function(e) {
                if (window.clarity && e.detail) {
                  window.clarity('consentv2', {
                    ad_storage: e.detail.ad_storage || 'denied',
                    analytics_storage: e.detail.analytics_storage || 'denied'
                  });
                }
              });
            `,
          }}
        />
      </body>
    </html>
  );
}

/*
=== 마스킹 사용 예시 ===

PII 영역에 data-clarity-mask="true" 속성 추가:

<input
  type="email"
  name="email"
  data-clarity-mask="true"   // ← 마스킹 강제
/>

<div className="user-name" data-clarity-mask="true">
  {userName}
</div>

=== 환경변수 (.env.local) ===

NEXT_PUBLIC_CLARITY_PROJECT_ID=abc123xyz

=== 제외 영역 (관리자/내부) ===

if (pathname.startsWith('/admin') || pathname.startsWith('/internal')) {
  return null; // Clarity 로드 안 함
}
*/
