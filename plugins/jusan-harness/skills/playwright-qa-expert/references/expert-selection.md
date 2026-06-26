## 7. 자동 전문가 선택 알고리즘

### 7.1 3단계 분석 프로세스

```
[Step 1] 프로젝트 시그널 수집 (Signal Collection)
├─ 파일 구조 분석 (Glob 패턴 매칭)
├─ 소스 코드 키워드 탐지 (Grep 검색)
├─ 설정 파일 분석 (package.json, config 파일)
├─ 페이지/컴포넌트 구조 분석
└─ URL 경로 패턴 분석

[Step 2] 전문가 매칭 점수 계산 (Scoring)
├─ 각 전문가별 트리거 조건 평가
├─ 시그널 가중치 합산 → 점수 계산
└─ 임계값(threshold) 이상인 전문가 식별

[Step 3] 전문가 추가 결정 (Decision)
├─ 점수 ≥ 70점: 자동 추가
├─ 점수 50-69점: 권장 (리포트에 표시)
├─ 점수 < 50점: 추가 안 함
└─ 최대 추가 전문가 수: 3명
```

### 7.2 전문가별 트리거 조건 (100점 만점)

#### 국제화(i18n) 전문가
| 시그널 | 탐지 방법 | 점수 |
|--------|----------|:----:|
| `i18n/`, `locales/`, `translations/` 폴더 존재 | Glob | +30 |
| `next-i18next`, `react-intl`, `i18next` 의존성 | package.json | +25 |
| `t()`, `useTranslation`, `<Trans>` 사용 | Grep | +20 |
| 다국어 JSON 파일 (ko.json, en.json 등) | Glob | +15 |
| `lang`, `locale` 속성 사용 | Grep | +10 |

#### 성능 최적화 전문가
| 시그널 | 탐지 방법 | 점수 |
|--------|----------|:----:|
| 데이터 테이블/그리드 컴포넌트 | Grep: `DataTable`, `DataGrid` | +25 |
| 가상화 라이브러리 | package.json: `react-virtual`, `react-window` | +20 |
| 무한 스크롤/페이지네이션 | Grep: `InfiniteScroll`, `usePagination` | +20 |
| 대용량 상태 관리 | Grep: `useReducer`, `Redux`, `Zustand` | +15 |
| 이미지 최적화 컴포넌트 | Grep: `next/image`, `lazy` | +10 |
| API 호출 빈도 높음 | Grep count | +10 |

#### 이커머스 UX 전문가
| 시그널 | 탐지 방법 | 점수 |
|--------|----------|:----:|
| 장바구니 컴포넌트 | Grep: `cart`, `basket`, `checkout` | +30 |
| 결제 연동 | package.json: Stripe, PayPal, Toss | +25 |
| 상품 관련 스키마 | Grep: `product`, `price`, `sku` | +20 |
| 주문/배송 관련 | Grep: `order`, `shipping`, `delivery` | +15 |
| 위시리스트/즐겨찾기 | Grep: `wishlist`, `favorite` | +10 |

#### 대시보드 전문가
| 시그널 | 탐지 방법 | 점수 |
|--------|----------|:----:|
| 차트 라이브러리 | package.json: Chart.js, Recharts, D3 | +30 |
| 대시보드 경로 | Glob: `/dashboard/`, `/admin/`, `/analytics/` | +25 |
| 필터/정렬 컴포넌트 | Grep: `Filter`, `Sort`, `DateRange` | +20 |
| 통계/KPI 컴포넌트 | Grep: `Stats`, `KPI`, `Metric` | +15 |
| 데이터 내보내기 | Grep: `export`, `download`, `csv` | +10 |

#### 시각 디자이너
| 시그널 | 탐지 방법 | 점수 |
|--------|----------|:----:|
| 브랜드 관련 파일 (logo, brand, theme) | Glob | +25 |
| 커스텀 디자인 시스템 (`/design/`, `/theme/`) | Glob | +25 |
| CSS 변수/테마 정의 (`:root`, `--brand`) | Grep | +20 |
| 랜딩 페이지 존재 (`landing`, `home`, `hero`) | Glob/Grep | +15 |
| 마케팅 페이지 (`/about`, `/pricing`) | URL 분석 | +15 |

#### 콘텐츠 전략가
| 시그널 | 탐지 방법 | 점수 |
|--------|----------|:----:|
| 블로그/아티클 구조 (`/blog/`, `/posts/`, `/articles/`) | Glob | +30 |
| CMS 연동 (Contentful, Sanity, Strapi) | package.json | +25 |
| Markdown 파일 다수 (10개+) | Glob count: `**/*.md` | +20 |
| 에디터 컴포넌트 (`Editor`, `RichText`, `WYSIWYG`) | Grep | +15 |
| SEO 관련 설정 (`next-seo`, `meta`, `og:`) | Grep | +10 |

#### 게이미피케이션 전문가
| 시그널 | 탐지 방법 | 점수 |
|--------|----------|:----:|
| 포인트/배지/레벨 시스템 | Grep: `points`, `badge`, `level`, `xp` | +30 |
| 리더보드/랭킹 | Grep: `leaderboard`, `ranking`, `score` | +25 |
| 진행 표시 (`progress`, `streak`, `achievement`) | Grep | +20 |
| 보상 시스템 (`reward`, `bonus`, `unlock`) | Grep | +15 |
| 알림/축하 애니메이션 (`confetti`, `celebration`) | Grep/package.json | +10 |

#### SaaS UX 전문가
| 시그널 | 탐지 방법 | 점수 |
|--------|----------|:----:|
| 구독/플랜 시스템 (`subscription`, `plan`, `tier`) | Grep | +25 |
| 온보딩 플로우 (`onboarding`, `welcome`, `tour`) | Grep | +25 |
| 멀티테넌시 (`tenant`, `organization`, `workspace`) | Grep | +20 |
| 역할/권한 (`role`, `permission`, `rbac`) | Grep | +15 |
| 설정 페이지 (`/settings/`, `preferences`) | Glob | +15 |
