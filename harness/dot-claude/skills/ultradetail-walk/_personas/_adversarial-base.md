# Adversarial 페르소나 베이스 템플릿

> STEP ④ 페르소나 부트스트랩에서 Adversarial 페르소나 .md 생성 시 본 베이스 사용.
> [`_common.md`](./_common.md) 스키마를 따른다. Adversarial 모드는 [`_chaos-axes.md`](../_chaos-axes.md) 8축 적용.

---

## Adversarial 페르소나 행동 원칙

1. **"이런거 못 막을걸?"** 마인드셋 — 일부러 오류 유발 시도
2. **8축 카오스 매트릭스 적용** — 입력·순서·동시성·권한·상태·경계값·환경·history
3. **DOM 전수 + 카오스 곱** — 모든 element × 8축 행동
4. **destructive는 confirm까지만** — 실제 0건 보장 (안전 가드레일)
5. **결함 발견 즉시 카테고리 매핑** — STEP ③ 카테고리 표에 누적

---

## 5개 핵심 Adversarial 페르소나 (자동 도출 가능 시)

### admin-adversarial (R77 직접 적용)
```yaml
---
name: admin-adversarial
mode: adversarial
role_signal: /admin/* + multi-role 시스템
---

# Persona: admin-adversarial

## 정체성
- **역할**: 권한 우회 시도하는 관리자 또는 가짜 admin
- **권한 수준**: high (실제) 또는 none (시도)
- **시작 라우트**: /admin (또는 /login 우회)
- **로그인 필요?**: 시나리오별

## 행동 원칙
관리자 페이지의 권한 분기를 적극 우회 시도.
R77 (multi-role 호환성) 직접 동기 페르소나.

## 여정
1. 로그아웃 상태 /admin/dashboard URL 직접 → 401? 200?
2. seller로 로그인 후 /admin URL 직접 → role 검증?
3. admin 다른 사용자 ID 직접 (`/admin/users/<other-admin-id>`) → IDOR?
4. token 만료 후 액션 → silent fail?
5. cookie/header 조작 (devtools) → server 재검증?

## 카오스 축 적용
- 축 #4 (권한): 모든 행동 4.1-4.8
- 축 #1 (입력): SQL `' OR 1=1 --` to admin 검색
- 축 #6 (boundary): user list pagination 마지막 +1

## 검수 우선 element
- /admin/* 모든 라우트 직접 입력 (네비 우회)
- API 직접 호출 (UI 우회) — 권한 검증 누락 시도

## 종료 조건
- 모든 권한 우회 시도 완료
- destructive 시도 → confirm 안 누름
---
```

### seller-adversarial (R77 직접 적용)
```yaml
---
name: seller-adversarial
mode: adversarial
role_signal: /seller/* multi-tenant
---

## 여정
1. 다른 seller ID 데이터 직접 (`/seller/<other-id>/products`) → tenant 격리?
2. seller가 admin URL 직접 → role 분기?
3. 본인 매출에 -1 입력 / 매우 큰 수
4. 상품 이미지에 .exe 또는 매우 큰 파일

## 카오스 축 적용
- 축 #4 (권한): 다른 seller 데이터 / admin 페이지
- 축 #2 (입력): 파일 업로드 chaos
- 축 #6 (boundary): 가격 -1 / Infinity
```

### customer-adversarial
```yaml
---
name: customer-adversarial
mode: adversarial
role_signal: /customer/* 또는 protected route
---

## 여정
1. 다른 customer 주문 직접 (`/orders/<other-id>`) → IDOR?
2. 결제 액션 ×5 빠른 연타 → 중복 결제?
3. 결제 중 새로고침 → 부분 결제?
4. 회원가입 폼 SQL injection → 서버 검증?
5. 비밀번호 변경 → 즉시 로그아웃 → 새 비밀번호?

## 카오스 축 적용
- 축 #3 (동시성): 결제 연타
- 축 #1 (입력): SQL/XSS
- 축 #2 (순서): 회원가입 중간 이탈 / 결제 race
```

### guest-attacker
```yaml
---
name: guest-attacker
mode: adversarial
role_signal: 비-로그인 사용자
---

## 여정
1. /admin URL 직접 → redirect or 401?
2. /api/* 직접 호출 (curl 또는 fetch) → 인증 검증?
3. CSRF 시도 (다른 origin 폼)
4. 회원가입 폼에 XSS payload

## 카오스 축 적용
- 축 #4 (권한): 4.1, 4.5, 4.8
- 축 #1 (입력): 1.5, 1.6, 1.7
```

### chaos-monkey
```yaml
---
name: chaos-monkey
mode: adversarial
role_signal: 모든 페이지 (페르소나 무관)
---

## 여정
"환경"·"history"·"동시성" 축 위주 — 페르소나 무관.

1. 모든 viewport 변경 (375 / 768 / 1280 / 1920)
2. network throttle 3G + 모든 액션
3. offline 중 액션 시도
4. 새로고침 / 뒤로가기 인터럽트 모든 폼
5. 두 탭 동시 같은 데이터 수정

## 카오스 축 적용
- 축 #3 (동시성): 모든 행동
- 축 #5 (상태): loading·error·disabled chaos
- 축 #7 (환경): 7.1-7.10 모두
- 축 #8 (history): 8.1-8.7 모두

## 검수 우선
- 환경별 레이아웃 결함
- offline UX
- 인터럽트 시 데이터 손실
```

---

## 자동 부트스트랩 가이드

STEP ④ 3+안 조합 생성 시:

| 안 | Adversarial 페르소나 셋 |
|---|---|
| 안 A Realistic | admin-adversarial 1 / chaos-monkey 1 (균형) |
| 안 B Coverage | admin-adversarial / seller-adversarial / customer-adversarial / guest-attacker / chaos-monkey (전 권한) |
| 안 C Adversarial-heavy | 위 5개 + 추가 변형 (예: super-admin-adversarial, multi-tenant-adversarial) — 7개 |
| 안 D Custom | 사용자 직접 추가 |

→ 라우트 `/admin/*`이 없으면 admin-adversarial 자동 제외. `/seller/*`이 없으면 seller-adversarial 자동 제외 (객관 도출).

→ chaos-monkey는 페르소나 무관이므로 모든 안에 기본 포함.

---

## destructive 가드레일 (Adversarial 모드 강제)

Adversarial 페르소나가 destructive 시도 시:
1. 버튼 click까지 진행
2. confirm dialog `browser_handle_dialog({ accept: false })` 자동
3. 실제 destructive 0건 보장
4. confirm dialog 텍스트 = 검수 대상 (UX 명료성)

→ 위반 시 즉시 STEP ⑦ 종료 + 안전 리포트.
