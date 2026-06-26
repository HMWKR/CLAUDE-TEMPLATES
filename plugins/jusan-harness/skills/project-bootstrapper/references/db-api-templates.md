# DB 스키마 + API 설계 규칙 (STAGE 5 상세)

## DB 스키마 (PostgreSQL)

### 필수 테이블 패턴

**모든 프로젝트 공통**:
- `users` — id(UUID PK), email, name, provider, provider_id, created_at, updated_at
- `{핵심엔티티}` — 프로젝트의 핵심 데이터 (상품, 콘텐츠, 강의, 예약 등)
- `orders` 또는 `transactions` — 결제/거래가 있는 경우
- `reviews` — 리뷰/평가 시스템

**프로젝트별 추가**:
- 이커머스: products, size_charts, brands, order_items, returns
- SaaS: organizations, subscriptions, plans, usage_logs
- 교육: courses, lessons, enrollments, progress, certificates
- 커뮤니티: posts, comments, likes, reports, follows
- 예약: services, time_slots, bookings, cancellations

### 인덱스 규칙
- FK 컬럼에 반드시 인덱스
- 자주 필터/정렬되는 컬럼에 인덱스
- 복합 인덱스는 쿼리 패턴에 맞게
- 핵심 쿼리를 주석으로 예시

### 피드백 루프 테이블
프로젝트의 핵심 데이터 루프를 지원하는 테이블을 반드시 포함:
- 이커머스: returns(AI 추천 vs 실제 사이즈) → 추천 정확도 개선
- 교육: progress + quiz_results → 콘텐츠 난이도 조정
- 커뮤니티: reports + engagement → 추천 알고리즘 개선

## API 설계

### 응답 형식 표준
```json
{
  "success": true,
  "data": { ... },
  "error": null
}
// 에러 시
{
  "success": false,
  "data": null,
  "error": { "code": "RESOURCE_NOT_FOUND", "message": "상품을 찾을 수 없습니다" }
}
```

### 필수 엔드포인트 그룹
1. **인증**: POST /auth/social, POST /auth/refresh
2. **프로필/설정**: CRUD for 핵심 엔티티
3. **핵심 기능**: 프로젝트 메인 기능의 API
4. **목록/검색**: GET with 필터/정렬/페이지네이션
5. **주문/트랜잭션**: 결제가 있는 경우
6. **실시간**: WebSocket (해당 시)

### 에러 코드 테이블
모든 API 명세에 에러 코드 테이블을 포함:
| 코드 | HTTP | 설명 |
|------|------|------|
| AUTH_REQUIRED | 401 | 인증 필요 |
| RESOURCE_NOT_FOUND | 404 | 리소스 없음 |
| VALIDATION_ERROR | 422 | 입력 검증 실패 |
| RATE_LIMITED | 429 | 요청 제한 |
| SERVER_ERROR | 500 | 서버 오류 |
+ 프로젝트별 도메인 에러 코드 추가
