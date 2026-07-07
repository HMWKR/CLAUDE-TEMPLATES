---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.css"
  - "**/*.scss"
  - "**/*.vue"
  - "**/*.svelte"
---

# UI/UX Craft — 디자인 작업 상시 규율

> UI·디자인 코드 작업 시 자동 적용. "사람 디자이너처럼" 디테일·일관성·의도 정합을 강제한다.

## 상태 전수 (모든 인터랙티브 요소)

default 하나만 만들고 끝내지 않는다. hover / focus-visible / active / disabled / loading / empty / error — 해당되는 상태 누락은 결함이다.

## 디자인 토큰 일관성

- 색·간격·폰트·radius·shadow는 토큰/변수로. 하드코딩 hex·px 발견 시 토큰화한다.
- 한 화면에 임의 색·간격 난립 금지 — 4/8px 그리드와 타이포 스케일을 따른다.

## 반응형

모바일(375)·데스크톱(1280) 최소 2뷰포트를 의도한다. 브레이크포인트 누락·오버플로·터치타깃(44px 미만) 위반을 검출한다.

## 접근성 (비협상)

대비 WCAG AA, 포커스 링 보존, 시맨틱·aria, 키보드 순회 — 위반은 High.

## 의도·참조 대조 (있으면 의무)

- `design-brief.md` 존재 시: 매 산출 후 brief의 목적·톤·필수요소·제약에서 이탈(drift)했는지 대조한다.
- `reference-spec.md` 존재 시: 레퍼런스 스펙(그리드·색·타이포·간격)과 구현을 항목별로 대조하고 갭을 전수 보고한다.

## 레퍼런스 수집 — 웹크롤링 (참조 요청 시, 사용자 지침 2026-07-07)

사용자가 UI/UX 작업에서 레퍼런스 사이트 참조를 요청하면:
1. **능동 확장**: 사용자 지정 사이트 + 같은 카테고리 **경쟁사·우수 레퍼런스 3~5개를 발굴**(WebSearch/insane-search)해 목록을 1줄 제시(공개 페이지 대상, 과잉 크롤 금지).
2. **크롤링(도구: Playwright MCP 우선)**: 배치·다사이트·격리 캡처에는 **Playwright MCP(`mcp__playwright__*`)가 적합**(headless·사이트별 클린 컨텍스트·`browser_evaluate`로 DOM/CSS 추출·`browser_take_screenshot`·멀티탭). 로그인·유료·세션 필요 페이지만 Chrome MCP(사용자 세션 재사용), 정적 텍스트만이면 WebFetch. (Playwright가 전역 기본이므로 이 크롤 영역도 동일 — uncompromising-rigor §1.) 각 사이트에서 **스크린샷 + HTML/핵심 CSS + 디자인 토큰(색·타이포·간격·radius·shadow) 추출**.
3. **저장**: 프로젝트 루트 `web-crawling/<site-slug>/` 에 저장 — `screenshot.png` · `page.html` · `notes.md`(추출 패턴·차용/회피 포인트). git 미추적 권장(`.gitignore`에 `web-crawling/`).
4. **참조·대조**: 이후 UI/UX 설계·구현을 이 크롤 자산 기준으로 진행하고, `reference-spec.md`가 있으면 항목별 대조에 반영.

**파이프라인 결선**(conductor-verify와 동일 구조): 크롤링은 독립 단계가 아니라 파이프라인의 일부다 — ① 계획: 어느 사이트를 크롤할지 결정 → ② **Execute: 사이트당 1 teammate 병렬 크롤**(Playwright) → ③ 종합: 크롤 자산에서 레퍼런스 인사이트(공통 패턴·차별점) 추출 → ④ 설계·구현 → ⑤ **최종검증: 완성 UI를 크롤 레퍼런스 대비 대조**(reference-spec 항목별, 교차벤더 게이트는 main). crawl→design→verify가 한 파이프라인.
- 공개 페이지·저작권 존중(디자인 참고 목적이지 무단 복제 아님). 로그인·유료·robots 차단 페이지는 크롤하지 않고 사용자에 보고.

## 자기 종결 금지

"대충 비슷하면 됨"으로 닫지 않는다. 디테일 갭은 결함으로 등재한다 (rules/uncompromising-rigor.md §2). 종결은 의도·참조 충족 + 사용자 승인으로만.
