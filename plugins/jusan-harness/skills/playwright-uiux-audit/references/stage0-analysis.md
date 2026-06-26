## 섹션 5: Stage 0 — 프로젝트 & UX 컨텍스트 분석

> Lead 단독 수행. TM spawn 전 필수.

### 5.1 프로젝트 분석 절차

```
Step 0-1: 프로젝트 루트에서 기술 스택 식별
  - package.json, tsconfig.json, vite.config, next.config 등 확인
  - 프레임워크: React/Vue/Angular/Svelte/Next.js/Nuxt 등
  - CSS: Tailwind/styled-components/CSS Modules/Sass 등
  - UI 라이브러리: MUI/Ant Design/Chakra/shadcn 등

Step 0-2: 프로젝트 구조 파악
  - src/ 또는 app/ 디렉토리 구조
  - 컴포넌트 조직 패턴 (Atomic? Feature-based? Flat?)
  - 디자인 토큰/테마 파일 존재 여부

Step 0-3: 기존 디자인 시스템 확인
  - theme.ts, tokens.ts, design-tokens.json 등
  - CSS 변수 (--color-primary, --spacing-*, --font-* 등)
  - 브레이크포인트 정의

Step 0-4: 타겟 사용자 페르소나 생성 (3명)
  - 프로젝트 특성에 맞춘 자동 생성
  - uiux-data/personas.md에 저장
```

### 5.2 페르소나 템플릿

```markdown
# 타겟 사용자 페르소나

## 페르소나 1: [이름] — [역할]
- **연령대**: [XX대]
- **기기**: [주 사용 기기]
- **기술 숙련도**: [초급/중급/고급]
- **접근성 요구**: [있음/없음 — 구체적 내용]
- **핵심 목표**: [이 서비스에서 달성하려는 것]
- **불편 포인트**: [현재 겪는 UX 문제]

## 페르소나 2: [이름] — [역할]
...

## 페르소나 3: [이름] — [역할]
...
```

### 5.3 프로젝트 분석 결과 저장

분석 결과를 `uiux-data/project-analysis.md`에 저장:

```markdown
# 프로젝트 분석

## 기술 스택
- **프레임워크**: [예: Next.js 14]
- **CSS 시스템**: [예: Tailwind CSS 3.4]
- **UI 라이브러리**: [예: shadcn/ui]
- **상태 관리**: [예: Zustand]

## 디자인 시스템 현황
- **토큰 파일**: [존재/부재]
- **CSS 변수**: [개수]
- **브레이크포인트**: [값들]
- **컬러 팔레트**: [Primary/Secondary/Accent 등]

## 컴포넌트 구조
- **패턴**: [Atomic/Feature-based/Flat]
- **주요 컴포넌트**: [목록]

## 특이사항
- [프로젝트 특수 상황, 제약 등]
```
