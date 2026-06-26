---
name: reference-match
description: 사용자가 레퍼런스(이미지·스크린샷·라이브 URL·Figma)를 주면 그것을 해부해 스펙으로 만들고, 구현 후 헤디드 브라우저로 캡처해 항목별로 대조하여 "레퍼런스는 X인데 구현은 Y" 갭을 전수 검출하는 참조 정합 스킬. reference-spec.md를 산출한다. Use when "이 레퍼런스처럼", "이거 참조해서 똑같이", "이 사이트처럼 만들어줘", "이 시안대로", "레퍼런스 대조", "reference match", "이미지대로 구현", or 레퍼런스 자료가 주어진 UI 작업. NOT for: 레퍼런스 없는 자유 디자인(use design-intent-lock + ui-ux-pro-max), 일반 코드 리뷰, 백엔드.
---

# Reference Match — 참조 정합 (해부 → 스펙 → 대조)

> 레퍼런스를 "분위기로 비슷하게"가 아니라 **측정값으로 일치**시킨다. 해부해서 스펙으로 고정하고, 구현 후 헤디드 캡처로 항목별 갭을 전수 검출한다. "딱 맞게"의 엔진.

## 입력 분류 (STEP 0)

| 레퍼런스 종류 | 해부 방법 |
|---|---|
| 이미지·스크린샷 (파일) | Read 도구로 시각 분석 (색·레이아웃·타이포·간격 관찰) |
| 라이브 URL | `mcp__claude-in-chrome__*`(우선) 또는 playwright **headed**로 캡처 + DOM/computed style 추출 |
| Figma | `mcp__claude_ai_Figma__*` MCP로 토큰·프레임 추출 |
| 여러 개 | 각각 해부 후 공통 패턴 + 우선순위 정리 |

## STEP 1 — 해부 (Deconstruct)

레퍼런스에서 다음 7개 차원을 **측정값으로** 추출한다. 추측한 값은 `[추정]` 표기.

1. **레이아웃 그리드** — 컬럼 수, 컨테이너 max-width, 거터, 정렬(좌/중앙)
2. **컬러** — 배경/표면/주색/강조/텍스트 hex (라이브는 computed style, 이미지는 관찰값 [추정])
3. **타이포** — 폰트 패밀리, 스케일(h1~body px), 굵기, 행간, 자간
4. **간격 리듬** — 섹션/요소 간 간격의 기본 단위 (4/8px 배수 추정)
5. **컴포넌트 패턴** — 버튼·카드·내비·폼의 형태(radius·그림자·패딩·테두리)
6. **모션** — 전환·호버·스크롤 효과 (라이브만 관찰 가능)
7. **톤** — 전체 인상 형용사 3개 (design-brief와 정합 확인)

## STEP 2 — reference-spec.md 산출

```markdown
# Reference Spec — <레퍼런스명> (YYYY-MM-DD)
- 출처: <파일경로/URL/Figma>
- 캡처: <스크린샷 경로>

| 차원 | 레퍼런스 측정값 | 비고 |
|---|---|---|
| 그리드 | 12col / max-w 1200 / gutter 24 | |
| 컬러 | bg #0B0B0F / 주색 #4F46E5 / 텍스트 #E5E7EB | [추정] 표기 |
| 타이포 | Inter / h1 48 / body 16 / lh 1.5 | |
| 간격 | 8px 단위 (섹션 96, 카드 24) | |
| 컴포넌트 | 버튼 radius 8 / shadow md / pad 12·24 | |
| 모션 | hover lift 2px / 150ms ease | |
| 톤 | 미니멀·다크·고급 | |
```

## STEP 3 — 구현 또는 기존 대조

- **신규 구현**: spec을 단일 진실로 삼아 구현. `rules/ui-ux-craft.md`(상태·토큰·접근성)를 병행 준수.
- **기존 구현 대조**: 구현물을 그대로 두고 STEP 4로.

## STEP 4 — 라이브 대조 (Gap Detection) ★핵심

구현물을 **헤디드 브라우저로 캡처**한다(레퍼런스와 동일 뷰포트). 레퍼런스 캡처와 나란히 놓고 7차원을 항목별 대조한다.

```markdown
## 갭 리포트
| 차원 | 레퍼런스 | 구현 | 갭 | 등급 |
|---|---|---|---|:--:|
| 주색 | #4F46E5 | #6366F1 | hex 불일치 | High |
| h1 크기 | 48px | 40px | -8px | High |
| 카드 간격 | 24px | 16px | -8px | Medium |
| 버튼 radius | 8px | 8px | 일치 | ✓ |
| 호버 모션 | lift 2px | 없음 | 누락 | Medium |
```

- 색 hex·크기 px·폰트·정렬·radius·그림자·**누락 요소**·상태·모션을 전수 비교한다.
- "비슷함"으로 닫지 않는다. 측정 가능한 차이는 전부 등재 (rules/uncompromising-rigor.md §2).
- 의도된 차이(design-brief가 레퍼런스를 일부만 차용)는 brief를 인용해 구분한다.

## STEP 5 — 수정 루프

갭을 등급순(High→Medium→Low)으로 수정 → 재캡처 → 재대조. **갭 0 또는 사용자 승인**까지 반복한다.

## 출력 계약

- `reference-spec.md` (해부 결과)
- 갭 리포트 표 (차원 × 레퍼런스/구현/갭/등급)
- 수정 후 최종 일치율 (대조 항목 중 ✓ 비율)

## 연계

- 의도 확정 먼저 → **design-intent-lock** (brief가 "레퍼런스의 무엇을 차용/제외"를 규정)
- 상시 디테일 강제 → `rules/ui-ux-craft.md`
- 심층 라이브 검수 → playwright-design-audit (디자인 19-agent) / playwright-uiux-audit
- 브라우저 우선순위: Chrome MCP → playwright headed (rules/uncompromising-rigor.md §1)
