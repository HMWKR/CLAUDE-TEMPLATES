# 메시지 템플릿 6종

> Observer-Worker 간 통신에 사용되는 표준 메시지 형식.
> 모든 메시지는 SendMessage 도구를 통해 전송.

---

## 1. 부분 검증 요청 (Worker → Observer/Lead)

Worker가 기능 단위 구현 완료 후 Observer에게 검증을 요청할 때 사용.

```
구현 완료: [{feature-id}] — 부분 검증 요청

구현 파일:
- {파일1 경로}
- {파일2 경로}

구현 내용 요약:
{1-2문장으로 구현한 내용 설명}

검증 요청 범위:
- 페이지: {URL 경로}
- 관련 기준: {criteria-id 목록}
- 상태 검증: {초기/로딩/성공/에러 중 해당 항목}
```

### 사용 예시

```
구현 완료: [login-form] — 부분 검증 요청

구현 파일:
- src/app/(auth)/login/page.tsx
- src/frontend/components/auth/login-form.tsx

구현 내용 요약:
이메일/비밀번호 입력 폼 + 유효성 검증 + 에러 메시지 UI 구현

검증 요청 범위:
- 페이지: /login
- 관련 기준: LF-01, LF-02, LF-03, LF-04
- 상태 검증: 초기, 에러
```

---

## 2. 전체 검증 요청 (Lead → Observer)

Phase 2에서 Lead가 Observer에게 전체 기준 검증을 요청할 때 사용.

```
전체 검증 요청 — 라운드 {N}

검증 범위: verification-spec.json 전체 기준
이전 결과: verification-state/results/v{N-1}.json 참조

요청 사항:
1. 전체 기준 검증 (3유형: 구조/시각/동작)
2. 이전 PASS 항목 회귀 검증
3. 상태별 검증 (states 배열)
4. 뷰포트별 검증 (desktop/tablet/mobile)

결과 저장: verification-state/results/v{N}.json
스크린샷: verification-state/screenshots/v{N}-{viewport}.png

완료 후 결과 요약 메시지 전송 바랍니다.
```

---

## 3. 검증 결과 — PASS (Observer → Lead/Worker)

모든 기준이 통과했을 때 Observer가 전송.

```
검증 결과: [{feature-id 또는 "전체"}] — ✅ ALL PASS

라운드: {N}
검증 기준: {총 N}개
결과: PASS {N} / FAIL 0

뷰포트별:
- desktop (1280×720): ✅ PASS
- tablet (768×1024): ✅ PASS
- mobile (375×812): ✅ PASS

상태별:
- 초기: ✅ | 로딩: ✅ | 성공: ✅ | 에러: ✅

회귀: 없음

결과 파일: verification-state/results/v{N}.json
스크린샷: verification-state/screenshots/v{N}-*.png
```

---

## 4. 피드백 — FAIL (Observer → Lead/Worker)

검증 실패 항목이 있을 때 Observer가 전송. **6요소 필수.**

```
검증 결과: [{feature-id 또는 "전체"}] — ❌ FAIL 있음

라운드: {N}
검증 기준: {총 N}개
결과: PASS {P} / BLOCKER {B} / CRITICAL {C} / MAJOR {M} / MINOR {m}

---

### FAIL 항목 상세

#### [{criteria-id}] {심각도}

1. **심각도**: {BLOCKER | CRITICAL | MAJOR | MINOR}
2. **위치**: {페이지 경로} — {요소 설명}
3. **현재 상태**: {지금 어떻게 되어 있는지}
4. **기대 상태**: {어떻게 되어야 하는지}
5. **수정 파일**: {수정해야 할 파일 경로}
6. **수정 방법**: {구체적인 수정 지침}

스크린샷: verification-state/screenshots/v{N}-{항목}-{viewport}.png

---

(FAIL 항목별 반복)

---

게이트 판정:
- BLOCKER + CRITICAL = {B+C}개 → {통과 불가 | 통과}
- Worker 조치 필요: {즉시 수정 필요 항목 요약}

결과 파일: verification-state/results/v{N}.json
```

### FAIL 피드백 예시

```
검증 결과: [login-form] — ❌ FAIL 있음

라운드: 1
검증 기준: 8개
결과: PASS 5 / BLOCKER 0 / CRITICAL 2 / MAJOR 1 / MINOR 0

---

### FAIL 항목 상세

#### [LF-02] CRITICAL

1. **심각도**: CRITICAL
2. **위치**: /login — 비밀번호 입력 필드
3. **현재 상태**: input[type='text'] — 비밀번호가 평문으로 노출됨
4. **기대 상태**: input[type='password'] — 비밀번호 마스킹 처리
5. **수정 파일**: src/frontend/components/auth/login-form.tsx
6. **수정 방법**: password 필드의 type 속성을 'text'에서 'password'로 변경

스크린샷: verification-state/screenshots/v001-LF02-desktop.png

---

#### [LF-05] CRITICAL

1. **심각도**: CRITICAL
2. **위치**: /login — 로그인 버튼
3. **현재 상태**: 버튼 클릭 시 아무 반응 없음 (onClick 미연결)
4. **기대 상태**: 버튼 클릭 시 폼 제출 → API 호출 → 결과 처리
5. **수정 파일**: src/frontend/components/auth/login-form.tsx
6. **수정 방법**: handleSubmit 함수를 form의 onSubmit에 연결하고, 버튼 type을 'submit'으로 설정

스크린샷: verification-state/screenshots/v001-LF05-desktop.png

---

#### [LF-03] MAJOR

1. **심각도**: MAJOR
2. **위치**: /login — 모바일 뷰포트(375px)
3. **현재 상태**: 폼 컨테이너가 화면 너비의 60%만 차지, 좌우 여백 과다
4. **기대 상태**: 폼 컨테이너가 화면 너비의 90% 이상 차지
5. **수정 파일**: src/frontend/components/auth/login-form.tsx
6. **수정 방법**: 모바일 브레이크포인트에서 max-w-sm → w-full px-4로 변경

스크린샷: verification-state/screenshots/v001-LF03-mobile.png

---

게이트 판정:
- BLOCKER + CRITICAL = 2개 → 통과 불가
- Worker 조치 필요: LF-02 (비밀번호 마스킹), LF-05 (폼 제출 연결) 즉시 수정

결과 파일: verification-state/results/v001.json
```

---

## 5. 회귀 알림 (Observer → Lead + Worker)

이전 라운드에서 PASS였던 기준이 FAIL로 변경된 경우 즉시 전송.

```
⚠️ 회귀 발생: [{criteria-id}] — PASS → FAIL

라운드: {N} (이전 PASS: 라운드 {N-x})

회귀 상세:
1. **심각도**: CRITICAL (회귀 자동 격상)
2. **위치**: {페이지} — {요소}
3. **이전 상태 (PASS)**: {라운드 N-x에서 정상이었던 상태}
4. **현재 상태 (FAIL)**: {지금 깨진 상태}
5. **추정 원인**: {최근 수정된 파일/기능과의 관계}
6. **수정 방향**: {회귀 없이 수정하는 방법 제안}

관련 수정 이력:
- 라운드 {N-1}에서 [{다른 criteria-id}] 수정 시 영향 추정

스크린샷:
- 이전 PASS: verification-state/screenshots/v{N-x}-{criteria}-{viewport}.png
- 현재 FAIL: verification-state/screenshots/v{N}-{criteria}-{viewport}.png

⚠️ 회귀 수정 시 기존 PASS 항목 재검증 필수.
재검증 범위: [{영향받을 수 있는 criteria-id 목록}]
```

---

## 6. 최종 승인 (Observer → Lead)

전체 검증이 완료되고 BLOCKER+CRITICAL = 0일 때 Observer가 전송.

```
🎉 최종 검증 완료: ALL VERIFIED

라운드: {N} (총 {N}라운드 소요)
검증 기준: {총 N}개
결과: PASS {P} / MAJOR {M} (미해결) / MINOR {m} (미해결)
BLOCKER: 0 / CRITICAL: 0

수렴 추이:
- 라운드 1: PASS {P1}/{Total} ({Rate1}%)
- 라운드 2: PASS {P2}/{Total} ({Rate2}%)
- ...
- 라운드 {N}: PASS {PN}/{Total} ({RateN}%)

뷰포트별 최종 상태:
- desktop: ✅ ALL PASS
- tablet: ✅ ALL PASS
- mobile: ✅ ALL PASS

미해결 항목 (비차단):
- [{criteria-id}] MAJOR: {설명}
- [{criteria-id}] MINOR: {설명}

회귀 이력:
- 총 {R}회 발생, 모두 해결됨

최종 스크린샷:
- verification-state/screenshots/final-desktop.png
- verification-state/screenshots/final-tablet.png
- verification-state/screenshots/final-mobile.png

결과 파일: verification-state/FINAL-VERIFICATION.md
수렴 로그: verification-state/convergence-log.json

게이트: ✅ BLOCKER + CRITICAL = 0 → 통과
```

---

## 수정 완료 재검증 요청 (Worker → Observer/Lead)

Worker가 FAIL 항목을 수정한 후 재검증을 요청할 때 사용.

```
수정 완료: [{criteria-id}] — 재검증 요청

수정 파일:
- {수정한 파일 경로}: {변경 내용 요약}

수정 내용:
{구체적으로 무엇을 어떻게 고쳤는지}

재검증 요청 범위:
- 수정 대상: [{criteria-id}]
- 회귀 확인: [{영향받을 수 있는 criteria-id 목록}]
```
