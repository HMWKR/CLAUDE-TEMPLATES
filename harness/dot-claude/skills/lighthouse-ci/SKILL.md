---
name: lighthouse-ci
description: |
  Lighthouse + Lighthouse CI + PageSpeed Insights 통합 wrapper. 성능(LCP/INP/CLS) + 접근성 + Best Practices + SEO 4축 자동 감사 + 점수 threshold assertion + PR마다 CI 자동 검사.
  외부 npm 글로벌: lighthouse 13.3.0 + lhci 0.15.1 (Node 22+ 충족).
  Use when "lighthouse", "lighthouse ci", "PageSpeed", "Core Web Vitals", "LCP/INP/CLS", "성능 검수", "/lighthouse-ci", "/lighthouse".
  NOT for: 코드 정적 성능 (use frontend-review Tier 4 / performance-review), 실사용자 행동 (use clarity-tracker).
user_invocable: true
---

# Lighthouse CI Wrapper

> **신설 (2026-05-26 web-audit-pipeline #3)** — Lighthouse + Lighthouse CI + PageSpeed Insights 통합 wrapper.
> **외부 도구**: `lighthouse@13.3.0` + `@lhci/cli@0.15.1` (npm 글로벌, Node 22+)

## ⚠️ Uncompromising Rigor §1-§4 정합

- **§1**: Lighthouse가 Chrome headless 자체 사용. Chrome MCP와 충돌 X (별도 프로세스)
- **§2**: 점수 80 미만 "이 정도면 충분" 차단 — Performance 85+ / A11y 95+ / SEO 90+ / BP 90+ 디폴트
- **§3**: 모든 audit 실패는 Medium 이상. CrUX 실측 미달은 High
- **§4**: 매 라운드 5단계 (이전 점수 재조회 → 디바이스/지역 다양화 → 회귀 분석 → 자기 정당화 자가 검증 → 신규 결함)

## 1. 책임 경계

| 자산 | 영역 |
|---|---|
| **`lighthouse-ci`** (본 wrapper) | 외부 객관 점수 (Lab data + CrUX 실측) + CI 자동화 |
| `frontend-review` Tier 4 (3 sp) | 정적 코드 성능 검수 (PR/diff) |
| `performance-review` (24 sp) | 서버 성능 (메모리/I/O/CPU/캐싱/동시성/네트워크) |
| `clarity-tracker` | 실사용자 정성 (세션 / 히트맵) |
| `web-audit-pipeline` | 5 도구 통합 |

**라우팅**: 외부 객관 + CI → 본 wrapper / 코드 정적 → `frontend-review --focus=performance` / 서버 성능 → `performance-review` / 실사용자 행동 → `clarity-tracker`.

## 2. 10단계 파이프라인 View

```
Step 1 Input   : URL 목록 + 모드 (mobile / desktop / both) + threshold
Step 2 Classifier : 작업 유형 (one-shot / CI / PageSpeed only / CrUX 실측)
Step 3 Router : lighthouse CLI / lhci autorun / pagespeed.web.dev fetch
Step 4 Context : 프로젝트 빌드 명령 (npm run start / build) 파악
Step 5 Planner : URL 순서 결정 (홈 → 가격 → 가입 → 결제)
Step 6 Tool : lighthouse / lhci autorun
Step 7 Draft : 4축 점수 수집 (Performance/A11y/BP/SEO)
Step 8 Critic : §3 정합 — 미달은 Medium+, CrUX 미달은 High
Step 9 Refiner : Opportunities/Diagnostics 우선순위
Step 10 Output : 보고서 (아래 §5)
```

## 3. 4축 점수 + Threshold (Uncompromising Rigor §3 default)

| 축 | 디폴트 임계 | 강등 조건 |
|:-:|:-:|---|
| **Performance** | ≥ 85 (warn) | 사용자 명시 강등만 |
| **Accessibility** | ≥ 95 (error) | 강등 불가 |
| **Best Practices** | ≥ 90 (warn) | 사용자 명시 강등만 |
| **SEO** | ≥ 90 (warn) | 사용자 명시 강등만 |

### Core Web Vitals (CrUX 실측)

| 지표 | 의미 | 임계 |
|:-:|---|---|
| **LCP** | Largest Contentful Paint | ≤ 2.5s (Good) / ≤ 4s (NI) / > 4s (Poor) |
| **INP** | Interaction to Next Paint | ≤ 200ms (Good) / ≤ 500ms (NI) / > 500ms (Poor) |
| **CLS** | Cumulative Layout Shift | ≤ 0.1 (Good) / ≤ 0.25 (NI) / > 0.25 (Poor) |

## 4. 호출 패턴

### 4.1 단일 URL 모바일
```bash
lighthouse https://example.com \
  --only-categories=performance,accessibility,best-practices,seo \
  --output=html \
  --output-path=./reports/lighthouse-home-mobile.html \
  --view
```

### 4.2 단일 URL 데스크톱
```bash
lighthouse https://example.com \
  --preset=desktop \
  --only-categories=performance,accessibility,best-practices,seo \
  --output=html \
  --output-path=./reports/lighthouse-home-desktop.html
```

### 4.3 Lighthouse CI autorun (PR마다)
```bash
# 프로젝트에 lighthouserc.js 배치 후
lhci autorun
```

### 4.4 PageSpeed Insights (브라우저)
```
https://pagespeed.web.dev/analysis?url=<URL>&form_factor=mobile
```

## 5. 출력 형식

```markdown
## Lighthouse Report — <date>

### Summary
- URL: <X>
- Device: mobile / desktop
- 점수: Perf=X / A11y=Y / BP=Z / SEO=W
- Core Web Vitals: LCP=X.Xs / INP=YYYms / CLS=Z.ZZ
- 발견: P0=X / P1=Y / P2=Z

### Findings

#### P0 (CrUX Poor)
- **LCP > 4s** (실측) — Hero 이미지 최적화 필요
- **INP > 500ms** — 메인 스레드 차단

#### P1 (Lighthouse score < threshold)
- Performance 78 < 85 — JS 번들 1.2MB, code splitting 필요
- Accessibility 92 < 95 — alt text 누락 5건

#### P2 (Opportunities / Diagnostics)
...
```

## 6. CI 통합 (lighthouserc.js + GitHub Actions)

`references/lighthouserc.js` 와 `references/lighthouse-ci.yml` 참조.

## 7. PageSpeed Insights 우선순위 (가이드 정합)

| 우선순위 | 이유 |
|:-:|---|
| **LCP** | 첫인상 / 이탈률 |
| **INP** | 답답함 / 조작감 |
| **CLS** | 오클릭 / 신뢰도 |
| **A11y score** | 장애/고령/키보드 사용자 |
| **SEO score** | 유입 품질 |

## 8. 옵션

| 옵션 | 효과 |
|---|---|
| `--mobile` (default) | 모바일 preset |
| `--desktop` | 데스크톱 preset |
| `--both` | 모바일 + 데스크톱 |
| `--ci` | lhci autorun (lighthouserc.js 필요) |
| `--pagespeed` | PageSpeed Insights URL 자동 열기 |
| `--threshold=strict` | Perf 90 / A11y 100 / BP 95 / SEO 95 |
| `--threshold=relaxed` | Perf 70 / A11y 90 / BP 80 / SEO 80 (사용자 명시 강등) |

## 9. 라우팅 다른 스킬

| 작업 | 권고 스킬 |
|---|---|
| 정적 코드 성능 | `frontend-review --focus=performance` |
| 서버 성능 | `performance-review` |
| 실사용자 행동 | `clarity-tracker` |
| 5 도구 통합 | `web-audit-pipeline` |
