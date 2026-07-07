---
name: web-design-guidelines
description: Review UI code for Web Interface Guidelines compliance. Use when asked to "review my UI", "check accessibility", "audit design", "review UX", or "check my site against best practices".
argument-hint: <file-or-pattern>
---

# Web Interface Guidelines

Review files for compliance with Web Interface Guidelines.

## How It Works

1. Fetch the latest guidelines from the source URL below
2. Read the specified files (or prompt user for files/pattern)
3. Check against all rules in the fetched guidelines
4. Output findings in the terse `file:line` format

## Guidelines Source

Fetch fresh guidelines before each review:

```
https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md
```

Use WebFetch to retrieve the latest rules. The fetched content contains all the rules and output format instructions.

## Usage

When a user provides a file or pattern argument:
1. Fetch guidelines from the source URL above
2. Read the specified files
3. Apply all rules from the fetched guidelines
4. Output findings using the format specified in the guidelines

If no files specified, ask the user which files to review.

## 참조

- 전문가 역할: `_core` 스킬(플러그인 형제)의 `roles.md`
- 문제 해결 프로토콜: `_core` 스킬(플러그인 형제)의 `protocols.md`


## 검사 영역

Web Interface Guidelines는 다음 핵심 영역을 검사한다:

### 1. 접근성 (Accessibility)

- **키보드 탐색**: 모든 인터랙티브 요소가 Tab으로 접근 가능한지
- **ARIA 속성**: 적절한 role, aria-label, aria-describedby 사용
- **색상 대비**: WCAG 2.1 AA 기준 (일반 텍스트 4.5:1, 대형 텍스트 3:1)
- **스크린 리더**: 의미론적 HTML 구조, alt 텍스트, 실시간 영역
- **포커스 관리**: 가시적 포커스 링, 논리적 탐색 순서, 포커스 트랩 방지

### 2. 성능 (Performance)

- **이미지 최적화**: next/image 사용, lazy loading, 적절한 포맷
- **번들 크기**: 코드 스플리팅, 트리 쉐이킹, 동적 임포트
- **렌더링 전략**: SSR/SSG/ISR 적절한 선택
- **웹 폰트**: font-display: swap, 프리로드, 서브셋
- **Core Web Vitals**: LCP, FID, CLS 최적화

### 3. 반응형 디자인 (Responsive)

- **뷰포트 메타 태그**: 올바른 설정
- **미디어 쿼리**: 모바일 우선 접근
- **유연한 레이아웃**: Flexbox/Grid 활용
- **터치 타겟**: 최소 44x44px
- **텍스트 크기**: 상대 단위 (rem/em) 사용

### 4. 시맨틱 HTML (Semantic)

- **문서 구조**: header, main, nav, footer, section, article
- **제목 계층**: h1-h6 순서 준수
- **랜드마크**: 내비게이션 랜드마크 적절 배치
- **폼 요소**: label 연결, fieldset/legend 사용

### 5. 인터랙션 (Interaction)

- **애니메이션**: prefers-reduced-motion 존중
- **로딩 상태**: 스켈레톤 UI, 프로그레스 바
- **에러 처리**: 사용자 친화적 에러 메시지
- **피드백**: 클릭/호버/포커스 시각적 피드백

## 검사 프로세스

### Phase 1: 파일 수집
```
1. 사용자 지정 파일/패턴 확인
2. 없으면 src/ 디렉토리 자동 탐색
3. HTML, JSX, TSX, CSS, SCSS 파일 대상
```

### Phase 2: 규칙 적용
```
1. WebFetch로 최신 가이드라인 다운로드
2. 파일별 규칙 매칭
3. 위반 사항 수집
```

### Phase 3: 결과 보고
```
file:line — [severity] rule: description
```

심각도:
- **error**: 즉시 수정 필요 (접근성 위반, 보안 문제)
- **warning**: 권장 수정 (성능, 모범 사례)
- **info**: 참고 사항 (코드 스타일)

## 자동 수정 지원

일부 규칙은 자동 수정 제안을 포함한다:

| 규칙 | 자동 수정 | 설명 |
|------|:---------:|------|
| alt 텍스트 누락 | O | 이미지 컨텍스트 기반 제안 |
| 색상 대비 부족 | O | WCAG 충족 색상 제안 |
| 누락된 ARIA 속성 | O | 적절한 속성 추가 |
| 비효율적 이미지 | X | 수동 최적화 필요 |

## 일반적 위반 패턴

### React/Next.js 프로젝트
- `<img>` 대신 `<Image>` 사용
- `<a>` 대신 `<Link>` 사용
- `useEffect`에서 데이터 패칭 대신 서버 컴포넌트
- `onClick` 핸들러가 있는 `<div>` → `<button>` 변환

### CSS/스타일링
- `!important` 과다 사용
- 고정 픽셀 대신 상대 단위
- 다크 모드 미지원
- 미디어 쿼리 누락

## 모범 사례 체크리스트

- [ ] 모든 이미지에 alt 텍스트
- [ ] 모든 폼에 label 연결
- [ ] 키보드만으로 전체 탐색 가능
- [ ] 색상만으로 정보 전달하지 않음
- [ ] 애니메이션 감소 설정 존중
- [ ] 적절한 문서 언어 설정 (lang 속성)
- [ ] 충분한 색상 대비
- [ ] 반응형 레이아웃


## 프레임워크별 가이드

### React/Next.js

```tsx
// 접근성 높은 버튼 컴포넌트
function ActionButton({ onClick, children, isLoading }) {
  return (
    <button
      onClick={onClick}
      disabled={isLoading}
      aria-busy={isLoading}
      aria-label={isLoading ? 'Processing...' : undefined}
      className="btn-primary"
    >
      {isLoading ? <Spinner aria-hidden="true" /> : null}
      {children}
    </button>
  )
}

// 접근성 높은 모달
function Modal({ isOpen, onClose, title, children }) {
  return (
    <dialog
      open={isOpen}
      aria-modal="true"
      aria-labelledby="modal-title"
      onClose={onClose}
    >
      <h2 id="modal-title">{title}</h2>
      {children}
      <button onClick={onClose} aria-label="Close modal">X</button>
    </dialog>
  )
}
```

### Vue.js

```vue
<!-- 접근성 높은 내비게이션 -->
<template>
  <nav aria-label="Main navigation">
    <ul role="menubar">
      <li v-for="item in menuItems" :key="item.id" role="none">
        <router-link
          :to="item.path"
          role="menuitem"
          :aria-current="isActive(item) ? 'page' : undefined"
        >
          {{ item.label }}
        </router-link>
      </li>
    </ul>
  </nav>
</template>
```

### CSS 모범 사례

```css
/* 반응형 타이포그래피 */
:root {
  --font-size-base: clamp(1rem, 0.95rem + 0.25vw, 1.125rem);
  --line-height-base: 1.6;
  --font-family: system-ui, -apple-system, sans-serif;
}

/* 다크 모드 지원 */
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: #1a1a2e;
    --color-text: #e0e0e0;
  }
}

/* 모션 감소 존중 */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}

/* 포커스 가시성 */
:focus-visible {
  outline: 3px solid var(--color-focus, #4A90D9);
  outline-offset: 2px;
}
```

## WCAG 2.1 핵심 기준 요약

| 기준 | 레벨 | 설명 |
|------|:----:|------|
| 1.1.1 비텍스트 콘텐츠 | A | 모든 이미지에 alt 텍스트 |
| 1.3.1 정보와 관계 | A | 시맨틱 HTML 구조 |
| 1.4.3 색상 대비 | AA | 최소 4.5:1 대비 |
| 1.4.4 텍스트 크기 | AA | 200%까지 확대 가능 |
| 2.1.1 키보드 | A | 모든 기능 키보드 접근 |
| 2.4.7 포커스 가시 | AA | 포커스 인디케이터 표시 |
| 3.1.1 페이지 언어 | A | lang 속성 설정 |
| 4.1.2 이름, 역할, 값 | A | ARIA 속성 올바른 사용 |

## 검사 실행 예시

```bash
# 특정 파일 검사
/web-design-guidelines src/components/Header.tsx

# 패턴으로 검사
/web-design-guidelines src/**/*.tsx

# CSS 파일 검사
/web-design-guidelines src/styles/global.css
```


## 프레임워크별 구현 가이드

### React 접근성 패턴

```jsx
// 시맨틱 버튼 컴포넌트
function ActionButton({ label, onClick, disabled }) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      aria-label={label}
      className="btn-primary"
    >
      {label}
    </button>
  );
}

// 포커스 관리
function Modal({ isOpen, onClose, children }) {
  const modalRef = useRef(null);
  useEffect(() => {
    if (isOpen) modalRef.current?.focus();
  }, [isOpen]);
  return isOpen ? (
    <div role="dialog" aria-modal="true" ref={modalRef} tabIndex={-1}>
      {children}
      <button onClick={onClose}>Close</button>
    </div>
  ) : null;
}
```

### CSS 반응형 패턴

```css
/* 모바일 퍼스트 미디어 쿼리 */
.container {
  padding: 1rem;
  max-width: 100%;
}

@media (min-width: 768px) {
  .container {
    padding: 2rem;
    max-width: 720px;
    margin: 0 auto;
  }
}

@media (min-width: 1024px) {
  .container {
    max-width: 960px;
  }
}

/* 포커스 가시성 */
:focus-visible {
  outline: 2px solid #4A90D9;
  outline-offset: 2px;
}

/* 다크 모드 대응 */
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #1a1a2e;
    --text: #e0e0e0;
  }
}
```

### Vue 접근성 패턴

```vue
<template>
  <nav aria-label="Main Navigation">
    <ul role="menubar">
      <li v-for="item in menuItems" :key="item.id" role="none">
        <a :href="item.url" role="menuitem"
           :aria-current="item.active ? 'page' : undefined">
          {{ item.label }}
        </a>
      </li>
    </ul>
  </nav>
</template>
```

## WCAG 2.1 요약 테이블

| 원칙 | 레벨 | 핵심 기준 | 검사 방법 |
|------|------|----------|----------|
| 인식 가능 | A | 대체 텍스트 제공 | img에 alt 속성 확인 |
| 인식 가능 | A | 자막 제공 | 비디오에 자막 트랙 확인 |
| 인식 가능 | AA | 명암비 4.5:1 이상 | 색상 대비 검사 도구 사용 |
| 조작 가능 | A | 키보드 접근성 | Tab 키로 모든 기능 접근 테스트 |
| 조작 가능 | A | 충분한 시간 제공 | 자동 슬라이드 일시정지 기능 |
| 이해 가능 | A | 언어 명시 | html lang 속성 확인 |
| 이해 가능 | AA | 일관된 내비게이션 | 페이지간 메뉴 구조 동일성 |
| 견고한 | A | 유효한 마크업 | HTML 밸리데이터 통과 |

## 성능 최적화 가이드라인

### 이미지 최적화

- img 태그에 width, height 속성 명시 (CLS 방지)
- loading="lazy" 적용 (뷰포트 밖 이미지)
- WebP/AVIF 포맷 우선, picture 요소로 폴백 제공
- 아이콘은 SVG 인라인 또는 스프라이트 사용

### 폰트 최적화

- font-display: swap 적용
- WOFF2 포맷 우선 사용
- 서브셋 폰트로 파일 크기 최소화
- link rel="preload" 로 크리티컬 폰트 선로딩

### 핵심 웹 바이탈 (Core Web Vitals)

| 지표 | 기준 | 최적화 방법 |
|------|------|-----------|
| LCP | 2.5초 미만 | 히어로 이미지 최적화, 서버 응답 시간 단축 |
| FID | 100ms 미만 | JS 번들 크기 최소화, 코드 분할 |
| CLS | 0.1 미만 | 이미지 크기 명시, 동적 콘텐츠 공간 예약 |
| INP | 200ms 미만 | 이벤트 핸들러 최적화, 메인 스레드 블로킹 최소화 |

## 검사 도구 참조

| 도구 | 용도 | 실행 방법 |
|------|------|----------|
| Lighthouse | 종합 웹 품질 검사 | Chrome DevTools Lighthouse 탭 |
| axe DevTools | 접근성 자동 검사 | 브라우저 확장 프로그램 |
| WAVE | 접근성 시각적 검사 | wave.webaim.org |
| PageSpeed Insights | 성능 분석 | pagespeed.web.dev |
| Color Contrast Checker | 명암비 검사 | webaim.org/resources/contrastchecker |


## 폼 디자인 가이드라인

### 입력 필드 패턴

- 레이블은 항상 입력 필드 위에 배치 (floating label 가능)
- placeholder는 레이블 대체가 아닌 힌트로만 사용
- 필수 필드 표시: 별표(*) + aria-required="true"
- 에러 메시지는 해당 필드 바로 아래에 빨간색으로 표시
- 실시간 유효성 검사 피드백 제공

### 버튼 디자인 원칙

- 주요 액션 버튼은 시각적으로 돋보이게 (primary color)
- 파괴적 액션(삭제)은 빨간색 계열로 경고
- 버튼 최소 터치 영역: 44x44px (모바일 접근성)
- 로딩 상태: 스피너 + 비활성화로 이중 제출 방지
- 비활성 버튼은 회색 처리 + cursor: not-allowed

### 테이블 디자인

- 긴 테이블은 sticky header 적용
- 모바일에서는 카드 레이아웃으로 전환
- 정렬 가능한 컬럼에 정렬 아이콘 표시
- 행 호버 시 배경색 변경으로 가독성 향상

## 색상 시스템 가이드

### 색상 팔레트 구성

- Primary: 브랜드 주색상 (CTA 버튼, 링크, 강조)
- Secondary: 보조 색상 (배지, 태그, 보조 버튼)
- Neutral: 회색 계열 (텍스트, 테두리, 배경)
- Semantic: 성공(초록), 경고(노랑), 에러(빨강), 정보(파랑)

### 다크 모드 설계

- 순수 검정(#000) 대신 짙은 회색(#1a1a2e) 사용
- 텍스트는 순백(#fff) 대신 약간 어두운 흰색(#e0e0e0)
- 색상 반전이 아닌 별도의 다크 팔레트 설계
- 이미지와 아이콘의 밝기 조정 필요
