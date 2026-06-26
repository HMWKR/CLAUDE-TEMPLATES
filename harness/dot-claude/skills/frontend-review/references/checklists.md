# frontend-review — 분리 레퍼런스 (harness-diet 2026-06-06)

> SKILL.md 본문에서 분리된 상세. 원본은 archive/harness-diet-2026-06-06/file-backups 참조.

## 4. Specialist 상세

### Tier 1: UI/UX (4 TM, 가중치 22%)

#### TM1 — UI Heuristics Specialist (Nielsen 10원칙)

**역할**: Jakob Nielsen의 10대 사용성 원칙으로 코드를 검사.

**핵심 책임**:
- 시스템 상태 가시성 (로딩 / 진행률 / 결과 표시)
- 실세계 매칭 (사용자 멘탈 모델 정합)
- 사용자 통제 + 자유 (취소 / 되돌리기 / 뒤로가기)
- 일관성 + 표준 (플랫폼 컨벤션)
- 오류 방지 (입력 검증 / 확인 모달)
- 인식 > 회상 (UI에 옵션 노출)
- 유연성 + 효율 (단축키 / 자동완성)
- 미니멀 디자인 (불필요한 정보 제거)
- 오류 인식·복구·복원
- 도움말 + 문서

**Grep 패턴**:
- 로딩 상태: `loading|isLoading|pending|isPending|Spinner|Skeleton`
- 에러 메시지: `error|onError|errorBoundary|catch`
- 확인 모달: `confirm|Dialog|Modal.*confirm|alert`
- 되돌리기: `undo|cancel|Cancel|취소`
- 단축키: `KeyboardEvent|onKeyDown|hotkey`

**체크리스트 (25 항목)**:
1. 비동기 작업에 로딩 상태 표시
2. 진행률 / Skeleton / Spinner 적절 배치
3. 에러 메시지가 구체적 + 복구 안내
4. 위험 작업에 확인 모달 (삭제/공유 등)
5. 뒤로가기 / 취소 / 되돌리기 가능
6. 폼 검증이 입력 즉시 (blur 또는 onChange)
7. 같은 동작은 같은 라벨/아이콘 일관
8. 플랫폼 컨벤션 준수 (iOS/Android/Web)
9. 입력 형식 명시 (예: "010-0000-0000")
10. 자동완성 / 자동 저장
11. UI에 최근 선택 / 추천 / 히스토리 노출
12. 단축키 + 마우스 + 터치 모두 지원
13. 키보드 단축키 가이드 (? 또는 ⌘/)
14. 빈 상태 (Empty state) 안내
15. 404 / 에러 페이지 친화적
16. 로딩 실패 시 retry 버튼
17. 파괴적 작업 후 토스트 (예: "삭제됨 — 되돌리기")
18. 폼 자동 저장 (input → localStorage)
19. 중요 동작 dwell time (200ms+ hover 후 active)
20. 불필요한 정보 제거 (필수만 노출)
21. 옵션 그룹화 (Fitts's Law 정합)
22. 에러 색상 빨강만 사용 X (icon + 텍스트 병행)
23. 로딩 메시지 ("불러오는 중..." 구체적)
24. 도움말 inline (툴팁 / "?" 아이콘)
25. FAQ / 안내 페이지 링크

#### TM2 — Interaction Design Specialist

**역할**: 인터랙션 패턴 + 마이크로 인터랙션 + 상태 변화 검사.

**핵심 책임**:
- 상태 변화 (hover / focus / active / disabled / loading)
- 마이크로 인터랙션 (피드백 / transition / 애니메이션)
- 입력 인터랙션 (touch / click / keyboard / drag)
- 컴포넌트 상태 일관성

**Grep 패턴**:
- 이벤트: `onClick|onMouseEnter|onFocus|onBlur|onSubmit|onKeyDown`
- 상태: `disabled=|aria-busy|aria-disabled|data-state`
- 애니메이션: `transition|animation|framer-motion|@keyframes|transform`
- 컴포넌트 상태: `useState|useReducer|Set.*State`

**체크리스트 (25 항목)**:
1. 모든 클릭 가능 요소에 hover 상태
2. 키보드 focus 상태 visible (focus-visible)
3. active 상태 (눌렀을 때 시각 피드백)
4. disabled 상태 명확 (cursor + opacity + aria-disabled)
5. loading 상태 (Spinner + aria-busy)
6. transition 200-300ms 적정
7. 불필요한 애니메이션 (motion-reduce 미적용)
8. 클릭 영역 최소 44×44px (모바일 권장)
9. 더블 클릭 / 중복 클릭 방지 (debounce)
10. 폼 제출 시 버튼 disabled + Spinner
11. 토글 상태 명확 (aria-pressed / aria-expanded)
12. 드롭다운 / 모달 outside click 닫기
13. ESC 키로 모달 닫기
14. 드래그 시 ghost / placeholder 표시
15. 스와이프 / 핀치 등 제스처 지원 (모바일)
16. 토스트 / 알림 자동 사라짐 (5초+)
17. 토스트 영구 (에러는 사용자 dismiss)
18. 입력 자동 포커스 (모달 열릴 때 첫 입력)
19. Tab 키 이동 순서 자연
20. 컴포넌트 상태 일관 (예: open / closed)
21. 폼 dirty 상태 감지 (변경 시 leave 경고)
22. 인라인 검증 (blur 시점)
23. 자동완성 / 추천 (debounce + 키보드 navigation)
24. 멀티 스텝 폼 (진행률 + 뒤로가기)
25. 인터랙션 후 결과 명확 (이전 vs 이후 차이)

#### TM3 — Information Architecture Specialist

**역할**: 정보 계층 / 네비게이션 / 라벨링 / 검색.

**Grep 패턴**: `nav|Navigation|Breadcrumb|menu|MenuItem|route|Link|<a |sitemap`

**체크리스트 (20 항목)**:
1. 1차 네비 + 2차 네비 명확 분리
2. Breadcrumb 깊이 3+ 페이지에 적용
3. 메뉴 항목 자명 (모호 X)
4. 검색 기능 noindex 페이지 식별
5. 라벨 + 아이콘 병행 (아이콘만 X)
6. URL 구조 RESTful + 의미 있는 slug
7. 404 페이지 사이트맵 + 검색 제공
8. 검색 결과 highlighting
9. 필터 + 정렬 명확
10. 페이지네이션 vs 무한 스크롤 적절
11. 카테고리 / 태그 일관
12. 사이트맵.xml + robots.txt
13. 메뉴 active 상태 표시
14. 하위 메뉴 mega menu vs flyout
15. 모바일 네비 햄버거 vs 탭바
16. CTA 위치 일관 (상단 우측 등)
17. 푸터 sitemap 미러
18. 로그인/로그아웃 위치 일관
19. 알림 / 메시지 위치 일관
20. 사용자 메뉴 (아바타 / 설정) 일관

#### TM4 — User Flow Specialist

**역할**: 사용자 여정 / 화면 전환 / 에러 복구 / Empty state.

**Grep 패턴**: `redirect|navigate|router\.push|router\.replace|<Redirect|empty|fallback|notFound|Suspense`

**체크리스트 (25 항목)**:
1. 모든 페이지에 Loading state
2. 모든 페이지에 Empty state
3. 모든 페이지에 Error boundary
4. 404 페이지 친화적 + 사이트맵
5. 로그인 후 redirect 의도된 URL로
6. 권한 거부 페이지 명확 (403)
7. 네트워크 오프라인 감지
8. 폼 제출 실패 시 입력 보존
9. 결제 / 가입 등 중요 흐름 단계 표시
10. Multi-step 폼 뒤로가기 데이터 보존
11. 세션 만료 시 데이터 저장 + redirect
12. Optimistic UI (성공 가정 + 실패 시 rollback)
13. 검색 결과 0건 시 추천
14. 필터 결과 0건 시 해제 안내
15. 페이지 진입 first paint < 1s
16. CTA 클릭 후 즉시 피드백
17. 폼 dirty 상태 leave 경고
18. 로그아웃 시 확인 + redirect to home
19. 결제 후 영수증 페이지
20. 이메일 인증 흐름 명확
21. 비밀번호 재설정 흐름
22. 회원가입 후 환영 + 다음 행동
23. 알림 / 메시지 클릭 → 해당 위치 deep link
24. 검색어 URL에 동기화 (공유 가능)
25. 뒤로가기 → 스크롤 위치 복원

### Tier 2: Design Quality (4 TM, 가중치 22%)

#### TM5 — Design Tokens Specialist

**역할**: 디자인 토큰 / CSS 변수 / 테마 일관성.

**Grep 패턴**: `--color-|--spacing-|--radius-|--font-|theme|designTokens|tailwind\.config|tokens\.|theme\.extend`

**체크리스트 (25 항목)**:
1. 디자인 토큰 단일 출처 (theme.ts / tokens.css / tailwind.config)
2. 색상 매직 값 X (모두 토큰 참조)
3. 간격(spacing) 4의 배수 또는 8의 배수 (예: 4/8/16/24/32)
4. 폰트 크기 스케일 일관 (12/14/16/20/24/32/48)
5. 보더 라디우스 토큰 (sm/md/lg/full)
6. 그림자 토큰 (sm/md/lg/xl)
7. z-index 토큰 (모달 1000 / 토스트 1100 등)
8. Breakpoint 토큰 (sm/md/lg/xl/2xl)
9. Transition duration 토큰 (fast/normal/slow)
10. Easing 토큰 (linear/ease-in-out)
11. 다크 모드 토큰 분리
12. 시맨틱 토큰 (primary/secondary/danger/success)
13. 컴포넌트별 토큰 (Button / Card / Modal)
14. 토큰 네이밍 BEM 또는 의미 기반
15. CSS-in-JS 토큰 vs CSS 변수 일관
16. Tailwind config 확장 적절
17. CSS reset / normalize 적용
18. Box-sizing border-box 전역
19. 이미지 max-width 100% 기본
20. 폰트 시스템 fallback chain
21. 사용자 폰트 크기 설정 존중 (rem)
22. CSS custom properties fallback
23. 디자인 토큰 문서화 (Storybook 등)
24. 토큰 변경 시 영향 범위 추적
25. 의미 없는 inline style 차단

#### TM6 — Color & Typography Specialist

**역할**: 색상 시스템 + 타이포 hierarchy + 가독성.

**Grep 패턴**: `color:|background:|fill:|stroke:|font-size|line-height|font-weight|letter-spacing|font-family`

**체크리스트 (25 항목)**:
1. 컬러 대비 4.5:1 (본문) / 3:1 (큰 텍스트)
2. 컬러만으로 정보 전달 X (icon + 텍스트 병행)
3. 다크 모드 대비 별도 검증
4. 색상 system primary / secondary / tertiary 명확
5. 의미 색상 (danger / warning / success / info) 일관
6. 폰트 가족 시스템 폰트 우선
7. 한글 폰트 별도 fallback
8. 폰트 두께 (300/400/500/600/700) 일관
9. line-height 본문 1.5-1.7 / 헤딩 1.2-1.4
10. letter-spacing 헤딩 -0.02em / 본문 0
11. 모바일 본문 16px+ (iOS 줌 방지)
12. 헤딩 hierarchy h1 ~ h6 일관
13. 단락 max-width 65ch (가독성)
14. justified text 회피 (한글 X)
15. 강조 (bold) 남용 X
16. 이탤릭 한글 회피
17. 모노스페이스 코드 / 숫자
18. 텍스트 색상 본문 vs 보조 명확
19. 링크 색상 + 밑줄 일관
20. 호버 색상 일관
21. 비활성 색상 명확 (opacity 또는 muted)
22. 텍스트 그림자 회피 (가독성 ↓)
23. 폰트 로딩 strategy (swap / fallback)
24. 시스템 폰트 활용 (성능 ↑)
25. variable font 활용 (가능 시)

#### TM7 — Layout & Spacing Specialist

**역할**: 그리드 + 간격 + 반응형 레이아웃.

**Grep 패턴**: `display:\s*(grid|flex|inline-grid|inline-flex)|grid-template|gap|margin|padding|breakpoint|@media|container`

**체크리스트 (25 항목)**:
1. 컨테이너 max-width (1280px / 1440px 등)
2. 그리드 12 컬럼 또는 CSS Grid auto
3. Gap 토큰 사용 (4/8/16/24/32)
4. margin 보다 gap 우선 (Flex/Grid)
5. 반응형 모바일 우선 (mobile-first)
6. Breakpoint sm 640 / md 768 / lg 1024 / xl 1280 / 2xl 1536
7. Container queries (CSS Container) 활용
8. Flexbox 1차 / Grid 2차 layout
9. 정렬 baseline / center / start 일관
10. 카드 / 섹션 padding 일관
11. 모달 / 시트 max-width / max-height
12. 사이드바 / 메인 너비 비율 명확
13. 푸터 위치 sticky bottom (짧은 페이지)
14. 헤더 sticky 적절
15. 이미지 aspect-ratio 명시
16. 동영상 컨테이너 aspect-ratio
17. 텍스트 오버플로우 처리 (ellipsis / line-clamp)
18. 가로 스크롤 회피 (모바일)
19. 세이프 영역 (notch / 홈 인디케이터)
20. 인쇄 미디어 쿼리
21. orientation 미디어 쿼리 (가로/세로)
22. prefers-reduced-motion 존중
23. prefers-color-scheme 존중
24. RTL 지원 (사용자 다국어 시)
25. 컴포넌트 최소 너비 / 최소 높이 설정

#### TM8 — Visual Hierarchy Specialist

**역할**: 시각 우선순위 / 강조 / 대비.

**Grep 패턴**: `font-weight|z-index|opacity|scale|transform|filter|box-shadow|background-image|gradient`

**체크리스트 (20 항목)**:
1. F-pattern / Z-pattern 정합 레이아웃
2. CTA 시각 강조 (색상 + 크기)
3. Primary CTA 페이지당 1개
4. Secondary CTA 명확 구분
5. 제목 > 부제목 > 본문 > 캡션 명확
6. 폰트 weight 차이 (400 → 700) 활용
7. 색상 대비 contrast hierarchy
8. 크기 대비 (1:1.2 또는 1:1.5)
9. 간격 차이 (관련 항목 가깝게)
10. 그룹화 명확 (게슈탈트 원리)
11. 카드 / 섹션 구분 명확
12. 시각 무게 균형 (좌우)
13. 백색 공간 충분
14. 강조 (highlight) 일관
15. 아이콘 크기 일관
16. 이미지 컴포지션 (subject 중앙)
17. 헤더 / 푸터 시각 위계
18. 사이드바 vs 메인 명확
19. focal point 명확 (중요한 것 먼저 보임)
20. 시각 노이즈 (불필요한 디테일) 제거

### Tier 3: Accessibility (3 TM, 가중치 18%)

#### TM9 — WCAG AA Specialist

**역할**: WCAG 2.1 AA 4원칙 (POUR) 준수.

**Grep 패턴**: `alt=|aria-|role=|tabIndex|<img|<svg|<video|<audio|<input|<button`

**체크리스트 (30 항목)**:
1. 모든 이미지 alt 속성 (장식 이미지는 `alt=""`)
2. 컬러 대비 4.5:1 (본문) / 3:1 (큰 텍스트)
3. 색상만으로 정보 전달 X
4. 텍스트 크기 200% 확대 가능
5. 키보드만으로 모든 기능 접근
6. 포커스 visible (focus-visible)
7. 포커스 trap (모달 / 드롭다운)
8. 포커스 순서 자연 (DOM 순서 정합)
9. 스킵 링크 ("본문으로 건너뛰기")
10. 페이지 제목 명확 (`<title>`)
11. Landmark roles (header / nav / main / footer)
12. 헤딩 hierarchy h1 → h6 순서
13. 폼 라벨 명시 (`<label for=>` 또는 `aria-label`)
14. 폼 에러 명시 (`aria-invalid` + `aria-describedby`)
15. 필수 입력 표시 (`aria-required` + 시각)
16. 동적 콘텐츠 라이브 영역 (`aria-live`)
17. 동영상 자막 + 트랜스크립트
18. 오디오 트랜스크립트
19. 깜박임 / 자동 재생 회피 (3 Hz+ 차단)
20. 시간 제한 작업 연장 가능
21. 자동 새로고침 회피
22. 마우스 호버 외 기능 (touch / keyboard)
23. 더블 탭 외 기능
24. 캡차 대안 (오디오 / 인지)
25. 다국어 lang 속성
26. 약어 (`<abbr>`)
27. 사용자 정의 콘텐츠 (`role=`)
28. 폼 자동완성 (`autocomplete=`)
29. 입력 유형 명시 (`inputmode=` / `type=`)
30. 에러 복구 안내

#### TM10 — Semantic HTML & ARIA Specialist

**역할**: 시맨틱 마크업 + ARIA 정확성.

**Grep 패턴**: `<div onClick|<span onClick|<button|role=|aria-|<nav|<main|<header|<footer|<aside|<article|<section`

**체크리스트 (25 항목)**:
1. `<button>` vs `<div onClick>` (전자 우선)
2. `<a href>` vs `<div onClick>` (네비는 전자)
3. `<nav>` 메인 네비 사용
4. `<main>` 페이지당 1개
5. `<header>` / `<footer>` 시맨틱
6. `<article>` 자기완결 콘텐츠
7. `<section>` 의미 그룹
8. `<aside>` 보조 콘텐츠
9. `<figure>` + `<figcaption>` 이미지
10. `<time datetime=>` 날짜
11. `<address>` 연락처
12. `<dl>` / `<dt>` / `<dd>` 정의 목록
13. `<details>` / `<summary>` 토글
14. `<dialog>` 모달
15. `<output>` 계산 결과
16. `role=` 적절 (남용 X)
17. `aria-label` vs `aria-labelledby` (후자 우선)
18. `aria-describedby` 보조 설명
19. `aria-hidden=true` 장식 요소만
20. `aria-expanded` 토글 상태
21. `aria-current` 현재 페이지
22. `aria-pressed` 토글 버튼
23. `aria-selected` 선택 항목
24. `aria-controls` 제어 관계
25. `<input type=>` 정확 (email / tel / url / number)

#### TM11 — Keyboard & Screen Reader Specialist

**역할**: 키보드 navigation + 스크린 리더 호환.

**Grep 패턴**: `tabIndex|autoFocus|focus-visible|aria-live|onKeyDown|onKeyUp|preventDefault|stopPropagation`

**체크리스트 (25 항목)**:
1. Tab 키 이동 순서 자연
2. Shift+Tab 역순 이동
3. Enter / Space 활성화
4. ESC 모달 / 드롭다운 닫기
5. Arrow keys (메뉴 / 탭 / 리스트)
6. Home / End (리스트 / 입력)
7. Page Up / Down (긴 목록)
8. tabIndex 0 (포커스 가능) / -1 (프로그래밍만)
9. 양수 tabIndex 회피
10. 첫 입력 자동 포커스 (모달 열릴 때)
11. 모달 닫힐 때 trigger로 포커스 복원
12. 포커스 trap (모달 내부 순환)
13. 스킵 링크 ("본문으로 건너뛰기")
14. 라이브 영역 (`aria-live=polite|assertive`)
15. 알림 / 토스트 라이브 영역
16. 로딩 상태 `aria-busy`
17. 진행률 `aria-valuenow` / `aria-valuemin` / `aria-valuemax`
18. 검색 결과 카운트 라이브 영역
19. 폼 에러 라이브 영역 + 포커스
20. 키보드 단축키 가이드
21. 스크린 리더 전용 텍스트 (`.sr-only`)
22. 시각 숨김 + 스크린 리더 노출
23. 아이콘 + 텍스트 (스크린 리더 친화)
24. 동적 콘텐츠 announce
25. SPA route 변경 announce

### Tier 4: Performance (3 TM, 가중치 18%)

#### TM12 — React Rendering Specialist

**역할**: React 렌더링 최적화.

**Grep 패턴**: `useMemo|useCallback|React\.memo|useEffect|useLayoutEffect|useRef|key=`

**체크리스트 (25 항목)**:
1. `React.memo` 적절 사용 (얕은 비교)
2. `useMemo` 비용 큰 계산만
3. `useCallback` 자식 컴포넌트에 전달 시
4. `useEffect` dependency 정확
5. `useEffect` cleanup 함수 (subscription)
6. `useLayoutEffect` 동기 측정만
7. `useRef` 렌더링 외부 값
8. `key=` 안정적 ID (index X)
9. 컴포넌트 분리 (renders 격리)
10. Context Provider 분리 (불필요 re-render 방지)
11. State 위치 적정 (lifting state up)
12. Derived state 회피
13. props drilling 회피 (Context / Compound)
14. Suspense + lazy
15. ErrorBoundary 적절
16. React 18 concurrent (startTransition)
17. useTransition 무거운 업데이트
18. useDeferredValue 입력
19. 이펙트 in 렌더 회피
20. 무한 루프 회피 (deps 점검)
21. 인라인 함수 children prop 회피
22. 인라인 객체 prop 회피 (memo 무력화)
23. children prop으로 분리 (re-render 격리)
24. 컴포넌트 trees 평탄화
25. Profiler API 활용 권장

#### TM13 — Bundle & Loading Specialist

**역할**: 번들 크기 + 로딩 최적화.

**Grep 패턴**: `dynamic|lazy|Suspense|next\/dynamic|import\(|preload|prefetch|fetchPriority`

**체크리스트 (20 항목)**:
1. 라우트별 코드 스플리팅
2. `next/dynamic` 큰 컴포넌트
3. `React.lazy` 컴포넌트
4. 외부 라이브러리 lazy (chart / editor)
5. preload 중요 리소스
6. prefetch 다음 페이지
7. Critical CSS inline
8. 비핵심 CSS lazy
9. 이미지 lazy (`loading="lazy"`)
10. above-fold 이미지 `fetchPriority="high"`
11. 폰트 preload + display=swap
12. 트리 쉐이킹 (import 부분만)
13. CommonJS → ESM
14. 큰 라이브러리 대안 (moment → date-fns)
15. polyfills 조건부 로드
16. dynamic import + retry
17. 번들 분석 (`@next/bundle-analyzer`)
18. Source maps production 노출 X
19. 압축 (gzip / brotli)
20. CDN 활용 (정적 자산)

#### TM14 — Core Web Vitals Specialist

**역할**: Core Web Vitals (LCP/INP/CLS/TTFB).

**Grep 패턴**: `next\/image|<img|width=|height=|aspect-ratio|loading=|decoding=|fetchPriority|priority`

**체크리스트 (25 항목)**:
1. LCP < 2.5s (75th percentile)
2. 가장 큰 콘텐츠 요소 식별
3. above-fold 이미지 `priority` (Next.js)
4. width / height 명시 (CLS 0)
5. aspect-ratio CSS
6. font-display swap (FOIT 회피)
7. 이미지 next-gen 포맷 (WebP / AVIF)
8. 이미지 responsive (`srcset` / `sizes`)
9. 이미지 placeholder (blur / color)
10. INP < 200ms (interaction next paint)
11. 무거운 작업 startTransition
12. Web Worker 무거운 계산
13. CLS < 0.1 (cumulative layout shift)
14. 광고 / 임베드 슬롯 고정
15. 동적 콘텐츠 위에 스페이서
16. TTFB < 600ms
17. SSR / SSG 활용
18. CDN edge caching
19. Hydration 부분 (Partial)
20. Server Components (App Router)
21. Streaming SSR
22. Resource hints (`<link rel=preconnect>`)
23. DNS prefetch
24. HTTP/2 또는 HTTP/3
25. 캐시 헤더 적절

### Tier 5: Framework Best Practices (2 TM, 가중치 12%)

#### TM15 — React Patterns Specialist

**역할**: React 패턴 + Hooks 규칙 + 상태 관리.

**Grep 패턴**: `useState|useEffect|useContext|useReducer|createContext|Provider|Zustand|Redux|Jotai|Recoil`

**체크리스트 (30 항목)**:
1. Hooks 규칙 (Top level / React function 내부만)
2. ESLint react-hooks 활성
3. Custom hooks `use` 접두사
4. Hooks deps 배열 정확
5. Hooks 무한 루프 회피
6. Functional component 우선 (class 회피)
7. Compound Component 패턴 (Tab / Accordion)
8. Render Props 적절
9. HOC vs Custom Hook (후자 우선)
10. Children prop 활용
11. Context 분리 (read vs write)
12. Context default value 의미 있게
13. State machine (xstate 등) 복잡 상태
14. 전역 상태 라이브러리 (Zustand / Jotai 권장, Redux 신중)
15. 서버 상태 vs 클라 상태 분리 (TanStack Query / SWR)
16. Optimistic update 라이브러리 활용
17. Form 라이브러리 (React Hook Form 권장)
18. Form 검증 (Zod / Yup)
19. Error Boundary 컴포넌트
20. Suspense boundary 적절
21. PropTypes 또는 TypeScript
22. Default props 명시
23. forwardRef 적절 (DOM 노출 시)
24. useImperativeHandle 신중
25. Portal (모달 / 토스트)
26. Refs callback 패턴
27. 컴포넌트 합성 > 상속
28. JSX 조건 렌더 명확 (`&&` vs ternary)
29. Fragment 활용
30. Strict Mode 활성 (개발)

#### TM16 — Next.js / SSR Specialist

**역할**: Next.js App Router + RSC + SSR/SSG.

**Grep 패턴**: `'use client'|'use server'|generateStaticParams|generateMetadata|layout\.tsx|page\.tsx|loading\.tsx|error\.tsx|not-found\.tsx|middleware\.ts`

**체크리스트 (30 항목)**:
1. App Router 사용 (Pages Router → 마이그레이션)
2. Server Components 기본
3. 'use client' 최소 사용
4. Client Component 잎(leaf) 가까이
5. Server Actions 활용
6. layout.tsx 공통 UI
7. loading.tsx 페이지별
8. error.tsx 페이지별
9. not-found.tsx 페이지별
10. generateMetadata 동적 메타
11. generateStaticParams SSG
12. Dynamic SSG (`revalidate`)
13. `fetch` 캐싱 옵션
14. `cache` / `revalidatePath` / `revalidateTag`
15. middleware.ts 인증 / 리다이렉트
16. `<Link>` prefetch
17. `<Image>` 항상 사용 (`<img>` 회피)
18. `<Script>` strategy 명시
19. `<Font>` next/font
20. metadata Open Graph
21. metadata Twitter Card
22. JSON-LD structured data
23. sitemap.xml / robots.txt
24. Edge Runtime 적절 (지역 가까운)
25. Streaming SSR + Suspense
26. Parallel Routes (대시보드 등)
27. Intercepting Routes (모달)
28. Route Groups `()`
29. 환경 변수 NEXT_PUBLIC 신중
30. tRPC / Server Actions 형식 안전

### Tier 6: Frontend Security (2 TM, 가중치 8%)

#### TM17 — XSS & Injection Specialist

**역할**: XSS / 인젝션 / 위험 함수.

**Grep 패턴**: `dangerouslySetInnerHTML|innerHTML|outerHTML|insertAdjacentHTML|eval\(|new Function\(|document\.write|setTimeout\(.*string|setInterval\(.*string`

**체크리스트 (20 항목)**:
1. `dangerouslySetInnerHTML` 최소화
2. `dangerouslySetInnerHTML` 시 DOMPurify
3. `innerHTML` 직접 할당 회피
4. `eval()` 절대 금지
5. `new Function()` 금지
6. `document.write` 금지
7. setTimeout/setInterval 문자열 인자 금지
8. 사용자 입력 sanitize (DOMPurify / sanitize-html)
9. URL 입력 검증 (javascript: / data: 차단)
10. iframe src 검증
11. img src 검증
12. SVG sanitize (XSS 가능)
13. Markdown 렌더 시 sanitize
14. JSON.parse try/catch
15. URL 파라미터 escape
16. HTML 엔티티 escape
17. CSS injection 회피 (style 속성 검증)
18. 외부 URL rel="noopener noreferrer"
19. Postmessage origin 검증
20. SSRF (서버 쪽이지만 클라 호출 시 검증)

#### TM18 — CSP & Client Secrets Specialist

**역할**: CSP / 클라이언트 시크릿 노출.

**Grep 패턴**: `process\.env\.NEXT_PUBLIC|process\.env\.|localStorage|sessionStorage|document\.cookie|API_KEY|SECRET|TOKEN`

**체크리스트 (20 항목)**:
1. `NEXT_PUBLIC_*` 환경변수 최소화
2. 서버 시크릿 (API_KEY / DB_URL) NEXT_PUBLIC X
3. JWT secret 클라 노출 X
4. OAuth client_secret 클라 노출 X
5. localStorage 시크릿 저장 X (XSS 취약)
6. sessionStorage 시크릿 저장 X
7. httpOnly 쿠키 (JWT 권장)
8. SameSite=Strict 또는 Lax
9. Secure 쿠키 (HTTPS만)
10. CSP `default-src 'self'`
11. CSP `script-src` nonce / hash
12. CSP `style-src` 'unsafe-inline' 회피
13. CSP `img-src` 화이트리스트
14. CSP `connect-src` API 도메인만
15. CSP `frame-ancestors 'none'`
16. CSP `report-uri` 위반 모니터링
17. HSTS 헤더
18. X-Frame-Options: DENY (clickjacking)
19. X-Content-Type-Options: nosniff
20. Referrer-Policy: strict-origin-when-cross-origin

---

