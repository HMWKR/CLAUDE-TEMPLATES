## 섹션 6: Stage 1 — 데이터 수집 (Lead 단독, Playwright MCP)

> **소요 시간**: 약 5-8분 | **도구**: Playwright MCP (browser_navigate, browser_snapshot, browser_take_screenshot, browser_evaluate, browser_console_messages, browser_network_requests, browser_resize)

### 6.1 수집 절차 (25+ 단계)

```
[Step 1] browser_navigate → 대상 URL 접속
[Step 2] browser_snapshot → desktop(1920px) 스냅샷 → snapshots/desktop-1920.md
[Step 3] browser_take_screenshot → desktop 스크린샷 → screenshots/desktop-1920.png
[Step 4] browser_console_messages → console-logs.md
[Step 5] browser_network_requests → performance/network.json

[Step 6-9] CSS Evaluate 스니펫 실행 — Typography (T-1 ~ T-5)
  → tokens/typography.json

[Step 10-11] CSS Evaluate 스니펫 실행 — Spacing (S-1, S-2)
  → tokens/spacing.json

[Step 12-13] CSS Evaluate 스니펫 실행 — Color (C-1, C-2)
  → tokens/colors.json

[Step 14] CSS Evaluate 스니펫 실행 — Animation (ANIM-1)
  → tokens/animation.json

[Step 15-16] CSS Evaluate 스니펫 실행 — Components (M-1, M-2)
  → tokens/components.json

[Step 17] CSS Evaluate 스니펫 실행 — Design System (DS-1)
  → tokens/design-system.json

[Step 18] CSS Evaluate 스니펫 실행 — Forms (FORM-1)
  → tokens/forms.json

[Step 19] CSS Evaluate 스니펫 실행 — Comprehensive (A-1)
  → tokens/comprehensive.json

[Step 20] CSS Evaluate 스니펫 실행 — Navigation (NAV-1)
  → navigation/nav-structure.json

[Step 21] 링크 전수 조사 → navigation/links.json
[Step 22] 사이트맵 구조 분석 → navigation/sitemap.json

[Step 23] browser_resize(768, 1024) → tablet 스냅샷+스크린샷
[Step 24] browser_resize(390, 844) → mobile 스냅샷+스크린샷
[Step 25] browser_resize(320, 568) → mobile-small 스냅샷+스크린샷
[Step 26] browser_resize(1366, 768) → laptop 스냅샷+스크린샷
[Step 27] browser_resize(1920, 1080) → 원래 viewport 복원
```

### 6.2 도구 실패 대응표

| 도구 | 실패 시 대응 | 영향 TM |
|------|-------------|---------|
| browser_navigate | **중단** — URL 접근 불가 시 전체 감사 불가 | 전체 |
| browser_snapshot | 재시도 1회 → 실패 시 스크린샷만으로 진행 | 전체 |
| browser_take_screenshot | 재시도 1회 → 실패 시 스냅샷만으로 진행 | 전체 |
| browser_evaluate | 재시도 1회 → 실패 시 해당 토큰 `null` 기록 | 해당 TM |
| browser_console_messages | 스킵 가능 (TM15 성능 분석 제한) | TM15 |
| browser_network_requests | 스킵 가능 (TM15 성능 분석 제한) | TM15 |
| browser_resize | 재시도 1회 → 실패 시 가용 viewport만 사용 | TM10 |

### 6.3 CSS Evaluate 스니펫 (16개)

> CSS 검증 스니펫은 [references/css-evaluate-snippets.md](references/css-evaluate-snippets.md) 참조.
> Lead가 Stage 1 데이터 수집 시 해당 파일을 Read하여 사용.

| ID | 이름 | 토큰 파일 |
|:--:|------|----------|
| T-1 | Body Font Size | typography.json |
| T-2 | Heading Ratio | typography.json |
| T-3 | Input Font Size | typography.json |
| T-4 | Line-Height Ratios | typography.json |
| T-5 | Paragraph Max-Width | typography.json |
| S-1 | Component Padding Consistency | spacing.json |
| S-2 | Grid/Spacing System | spacing.json |
| C-1 | Text-Background Contrast | colors.json |
| C-2 | Focus Ring Visibility | colors.json |
| M-1 | Modal/Dialog Detection | components.json |
| M-2 | Component Variety | components.json |
| ANIM-1 | Animation/Transition Metrics | animation.json |
| DS-1 | Design System Consistency | design-system.json |
| NAV-1 | Navigation Structure | nav-structure.json |
| FORM-1 | Form UX Analysis | forms.json |
| A-1 | Comprehensive CSS Snapshot | comprehensive.json |
