# 프로토타입 코드 규칙 (STAGE 6 상세)

## 기본 스택

- Next.js 14+ (App Router)
- TypeScript
- Tailwind CSS + shadcn/ui
- Zustand (상태관리)
- TanStack Query (API 호출, 실서비스 연동 시)
- React Hook Form + Zod (폼 밸리데이션)

사용자가 다른 스택(Vue, Svelte, React Native 등)을 요청하면 해당 스택으로 변환.

## 타입 정의 (types/index.ts)

DB 스키마의 모든 테이블에 대응하는 TypeScript interface를 생성.
추가로:
- 상태 타입 (status enum)
- 필터 타입 (검색/필터 파라미터)
- 에러 타입

## Zustand 스토어

핵심 도메인별로 스토어를 분리:
- 인증/사용자 스토어
- 핵심 엔티티 스토어 (상품, 콘텐츠 등)
- 핵심 기능 스토어 (피팅, 검색, 예약 등)
- 장바구니/트랜잭션 스토어 (해당 시)
- 카탈로그/필터 스토어 (해당 시)

각 스토어에:
- 상태(state)
- 액션(actions)
- 파생 값(getters)

## 목업 데이터 (lib/)

- 프로젝트 도메인에 맞는 현실적 목업 데이터 6~10개
- 필터링/검색 유틸리티 함수
- 도메인 특화 유틸리티 (가격 포맷, 사이즈 매핑, 날짜 처리 등)

## 인터랙티브 프로토타입 (.jsx)

- React 단일 파일로 전체 유저 저니 구현
- 온보딩 → 등록 → 홈 → 핵심기능 → 결과 → 완료까지
- 목업 데이터로 동작 (백엔드 불필요)
- 하단 탭 네비게이션
- 에러 시뮬레이션 버튼 포함
- 브랜드 컬러 적용

## package.json

프로젝트에 필요한 의존성만 포함.
devDependencies: TypeScript, Tailwind, ESLint, Vitest.
