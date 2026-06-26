// Lighthouse CI 설정 템플릿
// 프로젝트 루트에 lighthouserc.js 로 복사 후 URL 조정
// 실행: lhci autorun

module.exports = {
  ci: {
    collect: {
      startServerCommand: 'npm run start',
      url: [
        'http://localhost:3000/',
        'http://localhost:3000/pricing',
        'http://localhost:3000/contact',
        'http://localhost:3000/signup'
      ],
      numberOfRuns: 3,
      settings: {
        preset: 'desktop'
      }
    },
    assert: {
      assertions: {
        'categories:performance': ['warn', { minScore: 0.85 }],
        'categories:accessibility': ['error', { minScore: 0.95 }],
        'categories:best-practices': ['warn', { minScore: 0.90 }],
        'categories:seo': ['warn', { minScore: 0.90 }],

        // Core Web Vitals
        'largest-contentful-paint': ['warn', { maxNumericValue: 2500 }],
        'interactive': ['warn', { maxNumericValue: 3500 }],
        'cumulative-layout-shift': ['warn', { maxNumericValue: 0.1 }],

        // 자주 위반되는 audit
        'unused-javascript': 'off',
        'render-blocking-resources': 'warn',
        'uses-text-compression': 'error',
        'uses-responsive-images': 'warn',
        'color-contrast': 'error',
        'image-alt': 'error',
        'label': 'error',
        'meta-description': 'warn',
        'document-title': 'error'
      }
    },
    upload: {
      // temporary-public-storage 는 임시 공개. 민감 페이지는 lhci-server 등 자체 호스팅 권장
      target: 'temporary-public-storage'
    }
  }
};
