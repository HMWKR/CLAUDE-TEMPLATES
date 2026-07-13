---
description: 프로덕션 웹 5 도구 통합 검수 (Vercel + AccessLint + Lighthouse + Clarity + GA4) → P0~P3 단일 백로그
---

# /web-audit

프로덕션 웹사이트의 UI/UX + 접근성 + 성능 + 실사용자 행동 + 전환 퍼널을 **5 도구 통합 7단계**로 검수하고 **P0/P1/P2/P3 단일 백로그**를 자동 생성합니다.

## 사용 패턴

```
/web-audit <URL>
/web-audit <URL> --all
/web-audit <URL1>,<URL2>,<URL3>
/web-audit --ci
/web-audit --quick
```

## 동작

`web-audit-pipeline` 스킬을 호출하여 다음을 자동 실행:

1. **vercel-guidelines** — UI 코드 리뷰 (10 기준)
2. **accesslint** — WCAG 2.2 A/AA 라이브 audit
3. **lighthouse-ci** — 성능/A11y/BP/SEO + CrUX 실측
4. **clarity-tracker** — 세션 리플레이 / 히트맵 / Dead-Rage clicks (PROJECT_ID 있을 때)
5. **ga4-funnel** — 전환 퍼널 drop-off (Measurement ID 있을 때)
6. **백로그 통합** — P0/P1/P2/P3 우선순위 정렬 + Owner/Effort 매핑
7. **최종 보고** — 단일 백로그 + 실행 순서 + 시간 견적

## 옵션

| 옵션 | 효과 |
|---|---|
| `--all` (default) | 5 도구 모두 |
| `--skip=clarity,ga4` | 외부 ID 없을 때 |
| `--quick` | 코드 도구 3개만 (vercel + accesslint + lighthouse) |
| `--data-only` | 실사용자 2개만 (clarity + ga4) |
| `--ci` | PR 자동 검수 (lighthouse-ci threshold) |
| `--live-monitoring` | 운영 모니터링 (Clarity 7일 / GA4 30일) |
| `--threshold=strict` | Lighthouse Perf 90+ / A11y 100 |
| `--report-format=md\|html\|json` | 출력 형식 |

## 사전 조건

- `web-audit-pipeline` 스킬 활성화 (자동)
- 5 wrapper 스킬 활성화 (자동)
- 외부 도구:
  - Vercel Guidelines (npx 설치됨)
  - AccessLint plugin (claude plugin 설치됨)
  - Lighthouse + lhci (npm 글로벌 설치됨)
  - Clarity PROJECT_ID (사용자 직접 발급)
  - GA4 Measurement ID (사용자 직접 발급)

## Uncompromising Rigor §1~§4 정합

- §1 Chrome MCP 우선
- §2 자기 정당화 차단 ("이 정도면 충분" 금지)
- §3 모든 발견 P0~P3 등재 (사용자 명시 강등만 P3)
- §4 매 라운드 5단계 심층 분석

## 관련 스킬 / 커맨드

- 단일 도구만: `/web-interface-guidelines` / `/accesslint` / `lighthouse` CLI / Clarity 대시보드 / GA4 Explore
- 코드 PR: `/frontend-review` / `/backend-review` / `/fullstack-review`
- 무한 루프: `/live-verify`
- 경험 검수: `/experience-audit`
- 증거 기반 기능 완성도: `/project-ultra-audit`
