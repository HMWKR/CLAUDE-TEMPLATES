# 정상 페르소나 베이스 템플릿

> STEP ④ 페르소나 부트스트랩에서 정상 페르소나 .md 생성 시 본 베이스 사용.
> [`_common.md`](./_common.md) 스키마를 따른다. 정상 모드는 합리적·정상 흐름.

---

## 정상 페르소나 행동 원칙

1. **합리적 순서** — 사용자가 자연스럽게 클릭하는 흐름
2. **정상 입력값** — 의미 있는 텍스트, 정상 범위 숫자, 유효 형식
3. **한 페이지 한 번에** — 한 페이지의 모든 element를 한 번씩 시도 후 다음
4. **권한 내** — 페르소나 권한 범위 내 라우트만 접근
5. **destructive는 confirm까지** — 실제 destructive 0건

---

## 5개 핵심 정상 페르소나 (자동 도출 가능 시)

### admin-realistic
```yaml
---
name: admin-realistic
mode: normal
role_signal: /admin/* 라우트 + role-based 미들웨어
---

# Persona: admin-realistic

## 정체성
- **역할**: 관리자
- **권한 수준**: high
- **시작 라우트**: /admin
- **로그인 필요?**: yes

## 행동 원칙
관리자가 일상 운영 중 가장 자주 하는 흐름을 합리적 순서로 수행.
대시보드 → 사용자 관리 → 통계 → 설정 → 로그아웃.

## 여정 (Journey)
1. /login에서 admin 계정 로그인
2. /admin/dashboard 통계 carousel 모든 위젯 클릭
3. /admin/users 목록 정렬·필터 모든 옵션 시도
4. 사용자 1명 상세 진입 → 모든 탭 클릭 → 정상 수정 → 저장
5. /admin/settings 모든 토글 / 입력 한 번씩
6. 로그아웃

## 검수 우선 element
- 통계 위젯: 클릭 시 상세 페이지 이동 검증
- 사용자 목록: 정렬·필터·페이징 정상 작동
- 폼 submit: 성공 토스트·리디렉션
- 로그아웃: 세션 정리 + /login 리디렉션

## 종료 조건
- 모든 element 호출 완료
- 결함 발견 시 라운드 컨텍스트 누적 후 다음 페르소나
---
```

### seller-realistic
```yaml
---
name: seller-realistic
mode: normal
role_signal: /seller/* 라우트
---

## 여정
1. /login에서 seller 계정 로그인
2. /seller/dashboard 본인 매출 위젯 모든 클릭
3. /seller/products 상품 목록 → 신규 등록 흐름 (정상 입력)
4. 상품 수정 → 이미지 업로드 (정상 파일) → 저장
5. /seller/orders 주문 목록 정렬·필터·상세
6. 로그아웃

## 검수 우선
- 본인 매출만 보임 (다른 seller 데이터 격리)
- 상품 등록 폼 검증·저장
- 이미지 업로드 정상 파일 type/size
```

### customer-realistic
```yaml
---
name: customer-realistic
mode: normal
role_signal: /customer/* 또는 protected route
---

## 여정
1. 회원가입 → 이메일 검증 → 로그인
2. 메인에서 상품 검색 → 결과 페이지 → 상세
3. 장바구니 추가 → 수량 변경 → 결제 페이지
4. 결제 폼 정상 입력 → confirm dialog까지
5. 주문 내역 → 상세
6. 로그아웃

## 검수 우선
- 회원가입 흐름 검증
- 검색·필터·결과 정상
- 결제 confirm dialog 명료성
```

### guest-realistic
```yaml
---
name: guest-realistic
mode: normal
role_signal: 비-로그인 사용자
---

## 여정
1. 메인 진입 → 모든 공개 페이지 탐색
2. 회원가입 시작 → 폼 정상 입력
3. 로그인 시도 → 잘못된 비밀번호 → 정상 비밀번호
4. (회원만 가능한 액션 시도 시 로그인 유도 검증)

## 검수 우선
- 회원가입·로그인 흐름
- 보호된 페이지 redirect to /login
- "회원만 가능" 토스트 명료성
```

### power-user-realistic (선택)
```yaml
---
name: power-user-realistic
mode: normal
role_signal: 다중 권한 + 키보드 nav
---

## 여정
1. 키보드 단축키 사용 (Tab, Enter, Esc, ⌘+K 검색 등)
2. 빠른 작업 (한 번에 여러 폼)
3. URL 직접 입력 (북마크 사용자)
4. 다중 탭 동시 작업 (정상)

## 검수 우선
- 키보드 nav 모든 element
- 검색 단축키 / quick action
- URL state 유지
```

---

## 자동 부트스트랩 가이드

STEP ④ 3+안 조합 생성 시:

| 안 | 정상 페르소나 셋 |
|---|---|
| 안 A Realistic | admin 1 / seller 2 / customer 3 (실 분포) |
| 안 B Coverage | admin / sub-admin / seller / sub-seller / customer / power-user / guest (모든 권한 레벨) |
| 안 C Adversarial-heavy | 정상 3 (admin / customer / guest) + Adversarial 7 |
| 안 D Custom | 사용자 직접 추가 |

→ 라우트 `/seller/*`이 없는 프로젝트에서는 seller 페르소나 자동 제외 (객관 도출 원칙).
