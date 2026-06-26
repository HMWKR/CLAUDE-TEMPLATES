# UX Score 18차원 가중치 모델

> SSOT: 모든 차원 정의, 가중치, 등급 기준을 이 파일에서 관리한다.

---

## 1. 차원 정의 (18개)

| # | 차원 ID | 차원명 | 가중치 | 담당 TM | 카테고리 | 산출 기준 |
|:-:|:-------:|--------|:------:|:-------:|:--------:|-----------|
| 1 | TYPO_FUND | Typography Fundamentals | 6% | TM1 | A | 본문 크기, 행간, 줄 길이, 폰트 스택 |
| 2 | TYPO_ADV | Typography Advanced | 5% | TM2 | B | 타입 스케일, 반응형 타이포, 가독성 심화 |
| 3 | LAYOUT | Spacing & Layout | 7% | TM3 | C | 그리드 시스템, 간격 일관성, 여백 활용 |
| 4 | A11Y_CORE | WCAG Core Accessibility | **10%** | TM4 | D | 색상 대비, 키보드, ARIA, 시맨틱 |
| 5 | A11Y_ADV | WCAG Advanced Accessibility | 5% | TM5 | E | 스크린리더, 인지 접근성, 운동 장애 |
| 6 | PSYCH | Cognitive Psychology & UX Laws | 7% | TM6 | F | Nielsen, Fitts, Hick, Miller, Gestalt |
| 7 | **TYPO_COLOR** | **Typography & Color Quality** | **4%** | **TM7** | **S** | **폰트 품질, 색상 전략, 팔레트 감정** |
| 8 | MICRO | Micro-interactions & Animation | 5% | TM8 | G | 전환, 피드백, prefers-reduced-motion |
| 9 | INTERACT | Interaction Patterns & Feedback | 7% | TM9 | H | 인터랙션 일관성, 에러 복구, 상태 피드백 |
| 10 | IA_NAV | IA & Navigation | 6% | TM10 | I | 정보 구조, 네비게이션, 검색, 브레드크럼 |
| 11 | MOBILE | Mobile & Responsive | 6% | TM11 | J | 터치 타겟, 썸존, 뷰포트, 반응형 |
| 12 | VISUAL | Visual Hierarchy & Brand | 5% | TM12 | K | 시각 계층, CTA 강조, 브랜드 일관성 |
| 13 | FORM | Form UX & Data Entry | 6% | TM13 | L | 폼 유효성, 레이블, 자동완성, 에러 |
| 14 | DS | Design System Consistency | 4% | TM14 | M | 토큰 일관성, 컴포넌트 재사용, 변형 제한 |
| 15 | EMOTION | Emotional Design & Delight | 3% | TM15 | N | 마이크로 딜라이트, 빈 상태, 감정 연결 |
| 16 | PERF | Performance UX & Data Viz | 4% | TM16 | O+R | CWV, 로딩 전략, 차트 접근성 |
| 17 | CONTENT | Microcopy & Content UX | 3% | TM17 | P | 에러 메시지, CTA 카피, 톤 일관성 |
| 18 | **BRAND_MEM** | **Layout·Brand + Memorability** | **4%** | **TM18-19** | **Q+V+T+U** | **색상 조화, i18n, 레이아웃 독창성, 기억성** |
| | | **합계** | **~102%** → 정규화 | | | |

> 가중치 합계가 100%를 약간 초과할 수 있다. 최종 점수는 활성 가중치 합으로 정규화한다.

---

## 2. 점수 산출 공식

```
차원_점수(d) = PASS_항목(d) / (전체_항목(d) - NOT_TESTABLE(d)) × 100

UX_총점 = Σ(차원_점수(d) × 가중치(d)) / Σ(활성_가중치(d))

활성_가중치(d) = 0  (해당 차원 전체가 NOT-TESTABLE인 경우)
              = 가중치(d)  (그 외)
```

### 심각도 보정 (Severity Penalty)

| 심각도 | FAIL 1건당 감점 | 적용 범위 |
|--------|:--------------:|-----------|
| CRITICAL | -3점 | 총점에서 직접 감점 |
| MAJOR | -1점 | 총점에서 직접 감점 |
| MINOR | 0점 | 차원 점수에만 반영 |
| SUGGESTION | 0점 | 점수 미반영 |

```
최종_점수 = max(0, UX_총점 - CRITICAL_감점 - MAJOR_감점)
```

---

## 3. 등급 체계 (7단계)

| 등급 | 점수 | 의미 | 권장 조치 |
|:----:|:----:|------|-----------|
| **S** | 90-100 | 탁월한 UX + 디자인 품질 | 유지 + 미세 조정 |
| **A+** | 80-89 | 우수한 UX | 소규모 개선 |
| **A** | 70-79 | 양호한 UX | 중점 영역 개선 |
| **B+** | 60-69 | 평균 이상 UX | 구조적 개선 필요 |
| **B** | 50-59 | 평균 UX | 상당한 개선 필요 |
| **C** | 40-49 | 미흡한 UX | 전면 재설계 고려 |
| **F** | 0-39 | 심각한 UX 문제 | 긴급 개선 필요 |

---

## 4. 레이더 차트 텍스트 시각화

```
Lead는 아래 형식으로 18차원 레이더를 텍스트로 렌더링:

TYPO_FUND   ████████░░ 80%
TYPO_ADV    ███████░░░ 70%
LAYOUT      █████████░ 90%
A11Y_CORE   ██████░░░░ 60%
...
BRAND_MEM   ████████░░ 80%
─────────────────────────
총점: 76/100 (A)
```

---

## 5. 모드별 차원 활성화

| 모드 | 활성 차원 | 항목 수 |
|------|-----------|:-------:|
| basic | 1-7 (Wave 1) | ~65 |
| pro | 1-13 (Wave 1+2) | ~220 |
| expert | 1-18 (전체) | ~450 |
| --focus=<cat> | 지정 카테고리만 | 가변 |

basic/pro 모드에서 비활성 차원은 `활성_가중치 = 0`으로 처리하여 정규화.

---

## 6. Tier 분류 기준

| Tier | 포함 모드 | 특성 |
|:----:|-----------|------|
| T1 (Essential) | basic, pro, expert | WCAG 필수, 사용성 핵심, 15초 내 판별 가능 |
| T2 (Professional) | pro, expert | 전문가 수준 품질, 심층 분석 필요 |
| T3 (Expert) | expert only | 디자인 시스템, 감성, 기억성, 고급 최적화 |

각 카테고리 내 항목은 T1/T2/T3으로 분류되며, 모드에 따라 해당 Tier 이하만 검사.
