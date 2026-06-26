# 8축 카오스 — Adversarial 페르소나 행동 추상 프레임워크

> STEP ⑥ Adversarial walk에서 각 element에 적용할 행동 매트릭스.
> 8축은 추상. 구체 행동은 프로젝트 디스커버리(STEP ②)에서 자동 도출.
> LLM 임의 판단 X — 모든 축을 모든 element에 시도.

---

## 축 #1: 입력 (Input Chaos)

대상: `<input>`, `<textarea>`, `<select>`, `[contenteditable]`, `[role=combobox]`, `[role=searchbox]`.

### 행동 패턴

| # | 행동 | 예시 값 | 기대 결함 |
|:-:|---|---|---|
| 1.1 | 빈 값 submit | `""` | required 무시 / 기본값 처리 결함 |
| 1.2 | 최대 길이 +1 | `"a".repeat(maxLen + 1)` | overflow / silent truncation |
| 1.3 | 특수문자 | `<>'"&\\;|` | escape 누락 / 깨진 표시 |
| 1.4 | emoji | `🔥💥🚀` | 인코딩 / 길이 계산 결함 |
| 1.5 | SQL injection | `' OR 1=1 --` | DB 쿼리 직조 (서버 측 결함) |
| 1.6 | XSS payload | `<script>alert(1)</script>`, `<img src=x onerror=alert(1)>` | innerHTML 직접 삽입 |
| 1.7 | null byte | `\0`, `%00` | 파일 경로·DB 결함 |
| 1.8 | RTL override | `‮` | 시각 spoofing |
| 1.9 | 매우 긴 IDN 도메인 | `subdomain.subdomain.subdomain.domain.tld` × N | URL parser 결함 |
| 1.10 | escape sequence | `\n`, `\r`, `\t`, `\\` | 줄바꿈·tab 처리 결함 |

### 적용 우선순위 (안 B Security weighted 시)
- 1.5, 1.6, 1.7 ×2

---

## 축 #2: 순서 (Sequence Chaos)

대상: 다중 단계 워크플로우 (회원가입·결제·CRUD).

### 행동 패턴

| # | 행동 | 기대 결함 |
|:-:|---|---|
| 2.1 | 결제 → 장바구니 비우기 → 결제 재시도 | 비어있는 장바구니 결제 |
| 2.2 | 폼 단계 ① 채움 → 직접 단계 ③ URL | 단계 검증 우회 |
| 2.3 | 회원가입 중간 이탈 → 다시 시작 | 부분 데이터 / 중복 ID |
| 2.4 | 비밀번호 변경 → 즉시 로그아웃 | 세션 만료 timing |
| 2.5 | 댓글 작성 → 부모 게시물 삭제 → 댓글 submit | orphan 데이터 |
| 2.6 | 시간 역순 액션 (최신 먼저 → 과거) | 정렬 결함 |
| 2.7 | 폼 절반 채우고 다른 페이지 이동 | beforeunload 누락 / 데이터 유실 |

---

## 축 #3: 동시성 (Concurrency Chaos)

대상: 모든 액션 element + 비동기 흐름.

### 행동 패턴

| # | 행동 | 기대 결함 |
|:-:|---|---|
| 3.1 | 같은 버튼 빠른 연타 (×5, 100ms 간격) | 중복 submit / race condition |
| 3.2 | 두 탭 동시 같은 데이터 수정 | last-write-wins / lost update |
| 3.3 | 새로고침 중간 인터럽트 (request 중) | 부분 상태 / 락 유지 |
| 3.4 | 네트워크 throttle 3G + 빠른 액션 | optimistic UI 실패 / pending 누적 |
| 3.5 | 페이지 닫기 → 즉시 재오픈 | 세션 / unsaved warning |
| 3.6 | 두 탭 다른 페르소나 동시 액션 | 권한 격리 결함 |
| 3.7 | 폼 submit 중 네비게이션 | 중복 submit / 부분 commit |

---

## 축 #4: 권한 (Permission Chaos)

대상: 권한 분기, multi-role 시스템 (R77 직접 적용 영역).

### 행동 패턴

| # | 행동 | 기대 결함 |
|:-:|---|---|
| 4.1 | 로그아웃 상태 admin URL 직접 입력 | 401/403 미반환 / 페이지 로드 |
| 4.2 | seller가 admin 페이지 접근 | role 검증 누락 |
| 4.3 | 다른 사용자 ID 데이터 직접 (`/users/<other-id>`) | IDOR / OWASP #1 |
| 4.4 | 만료된 token으로 액션 | refresh 미처리 / silent fail |
| 4.5 | role 미들웨어 우회 (cookie 조작) | server-side 재검증 누락 |
| 4.6 | guest가 결제 시도 | 회원만 가능한 액션 분기 |
| 4.7 | 다른 회사·테넌트 데이터 (multi-tenant) | tenant 격리 결함 |
| 4.8 | API 직접 호출 (UI 우회) | API에만 있는 권한 검증 누락 |

→ **R77 직접 동기 영역**. 안 B Security weighted에서 ×2.

---

## 축 #5: 상태 (State Chaos)

대상: loading / error / empty / disabled / busy 상태.

### 행동 패턴

| # | 행동 | 기대 결함 |
|:-:|---|---|
| 5.1 | loading 중 같은 버튼 다시 클릭 | 중복 요청 |
| 5.2 | error 상태에서 다른 액션 | error 정리 누락 |
| 5.3 | empty 상태에서 액션 시도 | empty UX 미흡 |
| 5.4 | disabled 버튼 강제 클릭 (devtools `removeAttribute('disabled')`) | server 재검증 누락 |
| 5.5 | busy 상태에서 페이지 닫기 | unsaved 경고 누락 |
| 5.6 | 로딩 중 새로고침 | 부분 데이터 |
| 5.7 | optimistic UI 표시 후 server 실패 | rollback UI 미흡 |
| 5.8 | session 만료 후 첫 액션 | 401 처리 / 자동 재로그인 |

---

## 축 #6: 경계값 (Boundary Chaos)

대상: 숫자·길이·개수 입력.

### 행동 패턴

| # | 행동 | 기대 결함 |
|:-:|---|---|
| 6.1 | 0개 (empty list 처리) | empty UX |
| 6.2 | 1개 (singular handling) | 복수형 텍스트 결함 |
| 6.3 | 1000개 (대량) | pagination / 무한 스크롤 / perf |
| 6.4 | max+1 | overflow / silent truncation |
| 6.5 | -1 (음수 허용?) | 음수 검증 누락 |
| 6.6 | Infinity, NaN | type coercion |
| 6.7 | 0.1 + 0.2 (부동소수점) | 결제 금액 계산 |
| 6.8 | 매우 작은 시간 (1ms) | timer / animation |
| 6.9 | 매우 큰 시간 (10000년 후) | date overflow |

---

## 축 #7: 환경 (Environment Chaos)

대상: 모든 페이지·페르소나.

### 행동 패턴

| # | 환경 변수 | 기대 결함 |
|:-:|---|---|
| 7.1 | viewport 375×667 (모바일) | 반응형 결함 / overflow |
| 7.2 | viewport 1280×720 (데스크톱) | hover-only UX |
| 7.3 | viewport 1920×1080 (와이드) | 빈 공간 처리 |
| 7.4 | viewport 768×1024 (태블릿) | breakpoint 결함 |
| 7.5 | network throttle 3G | timeout / loading 처리 |
| 7.6 | offline | offline UX / cache |
| 7.7 | 다른 언어 locale (ko-KR ↔ en-US ↔ ja-JP) | 미번역 / RTL / 긴 번역 overflow |
| 7.8 | 시스템 dark mode | theme 분기 |
| 7.9 | reduced motion | animation 미흡 |
| 7.10 | 화면 크기 100% / 200% (zoom) | 레이아웃 깨짐 |

---

## 축 #8: history (History Chaos)

대상: 브라우저 history 조작.

### 행동 패턴

| # | 행동 | 기대 결함 |
|:-:|---|---|
| 8.1 | 뒤로가기 → 페이지 상태 복원? | useEffect cleanup 결함 |
| 8.2 | 새로고침 중간 → 진행 손실 | 자동 저장 미흡 |
| 8.3 | 탭 닫고 다시 열기 → 세션 회복 | persistent state |
| 8.4 | `history.replaceState` 조작 (devtools) | URL ≠ state mismatch |
| 8.5 | 두 번 뒤로 → 두 번 앞으로 | popstate 결함 |
| 8.6 | 외부 링크 → 뒤로 → 페이지 상태 | scroll position 복원 |
| 8.7 | beforeunload 무시 (Discard) | unsaved data 손실 |

---

## 적용 매트릭스

각 페르소나 × 각 페이지 × 각 element × 각 축 = 매우 큰 행렬.
**LLM 임의 판단 0건** — 모든 조합 시도. 결과는 STEP ⑦ 리포트에 누적.

가중치 적용 (STEP ③ 안 선택에 따라):

| 안 | 가중 ×2 축 |
|---|---|
| 안 A Balanced | 모든 축 ×1 |
| 안 B Security | #1(SQL/XSS) #4(권한) #6(boundary) |
| 안 C UX | #5(상태) #7(환경) #8(history) |
| 안 D Performance | #3(동시성) #7(네트워크) |

---

## destructive 가드레일

8축 행동 중 destructive 시도 (삭제·결제·외부 API):
- 버튼 click까지 진행
- confirm dialog 떠지면 `browser_handle_dialog({ accept: false })`
- 실제 destructive 0건 보장

→ confirm dialog 텍스트 자체가 검수 대상 (UX 명료성).
