# 통합 리포트 템플릿

> Reactive Observer-Worker 스킬의 최종 통합 리포트 형식.
> Lead가 Phase 3에서 생성. Observer 검증 결과 + Worker 구현 이력 통합.

---

## 리포트 형식

```markdown
# [기능명] Reactive Dev 통합 리포트

## 1. 개요

| 항목 | 값 |
|------|-----|
| 기능명 | {feature name} |
| 실행 일시 | {YYYY-MM-DD HH:MM} |
| 실행 모드 | {기본 / 풀스택 / 경량 / 검증만} |
| 팀 구성 | Lead + Observer + {Worker 목록} |
| 총 라운드 | {N}회 |
| 최종 결과 | {ALL_VERIFIED / MAX_ROUNDS / ...} |

## 2. 수렴 추이

### 라운드별 결과

| 라운드 | PASS | BLOCKER | CRITICAL | MAJOR | MINOR | 통과율 | 게이트 |
|:------:|:----:|:-------:|:--------:|:-----:|:-----:|:------:|:------:|
| 1 | {P} | {B} | {C} | {M} | {m} | {%} | {통과/불가} |
| 2 | {P} | {B} | {C} | {M} | {m} | {%} | {통과/불가} |
| ... | | | | | | | |
| {N} | {P} | 0 | 0 | {M} | {m} | {%} | ✅ 통과 |

### 수렴 차트 (ASCII)

```
통과율
100% │                              ████████
 90% │                        ██████
 80% │                  ██████
 70% │            ██████
 60% │      ██████
 50% │██████
     └──────────────────────────────────────
      R1    R2    R3    R4    R5    R{N}
```

### 수렴 속도

- 평균 개선율: {+X.XX%/라운드}
- 최대 개선 라운드: R{X} → R{X+1} ({+Y%})
- 정체 라운드: {없음 또는 R{X}}

## 3. 검증 유형별 결과

### 구조 검증 (Structure)

| ID | 설명 | 최종 결과 | 첫 PASS 라운드 |
|:--:|------|:---------:|:--------------:|
| {id} | {설명} | ✅ PASS | R{N} |
| {id} | {설명} | ⚠️ MAJOR | 미통과 |

### 시각 검증 (Visual)

| ID | 설명 | 뷰포트 | 최종 결과 | 비고 |
|:--:|------|:------:|:---------:|------|
| {id} | {설명} | desktop | ✅ PASS | |
| {id} | {설명} | mobile | ⚠️ MAJOR | {차이 설명} |

### 동작 검증 (Behavioral)

| ID | 설명 | 액션 | 최종 결과 | 비고 |
|:--:|------|------|:---------:|------|
| {id} | {설명} | {click/fill/...} | ✅ PASS | |

## 4. 뷰포트별 최종 상태

| 뷰포트 | 해상도 | PASS | FAIL | 상태 |
|:------:|:------:|:----:|:----:|:----:|
| desktop | 1280×720 | {P} | {F} | ✅ / ⚠️ |
| tablet | 768×1024 | {P} | {F} | ✅ / ⚠️ |
| mobile | 375×812 | {P} | {F} | ✅ / ⚠️ |

## 5. 상태별 검증 결과

| 상태 | 검증 완료 | 결과 |
|------|:---------:|:----:|
| 초기 (initial) | ✅ | PASS |
| 로딩 (loading) | ✅ | PASS |
| 성공 (success) | ✅ | PASS |
| 에러 (error) | ✅ | PASS |
| 빈 데이터 (empty) | ✅ | PASS |
| 인터랙션 (interaction) | ✅ | PASS |

## 6. 회귀 이력

| 라운드 | 기준 ID | 변화 | 원인 | 해결 라운드 |
|:------:|:-------:|:----:|------|:----------:|
| R{N} | {id} | PASS→FAIL | {수정된 다른 기준이 영향} | R{N+1} |

- 총 회귀 발생: {R}회
- 모두 해결됨: {예/아니오}

## 7. 미해결 항목 (비차단)

### MAJOR

| ID | 설명 | 뷰포트 | 비고 |
|:--:|------|:------:|------|
| {id} | {설명} | {viewport} | {후속 조치 제안} |

### MINOR

| ID | 설명 | 비고 |
|:--:|------|------|
| {id} | {설명} | {개선 제안} |

## 8. Worker 구현 요약

### FE-Worker

| 항목 | 값 |
|------|-----|
| 구현 파일 수 | {N}개 |
| Observer 피드백 수신 | {N}건 |
| BLOCKER/CRITICAL 수정 | {N}건 |
| 회귀 수정 | {N}건 |

주요 구현 결정:
- {결정 1}: {이유}
- {결정 2}: {이유}

### BE-Worker (해당 시)

| 항목 | 값 |
|------|-----|
| 구현 파일 수 | {N}개 |
| API 관련 FAIL 수정 | {N}건 |

## 9. 안전장치 발동 이력

| 조건 | 발동 여부 | 상세 |
|------|:---------:|------|
| maxRounds 초과 | {예/아니오} | |
| 동일 기준 5회 연속 FAIL | {예/아니오} | |
| Worker 10분 무응답 | {예/아니오} | |
| 컨텍스트 40% 초과 | {예/아니오} | |
| 회귀 3회 발생 | {예/아니오} | |
| Observer 연결 끊김 | {예/아니오} | |

## 10. 스크린샷 참조

| 단계 | 파일 | 설명 |
|------|------|------|
| 라운드 1 | verification-state/screenshots/v001-desktop.png | 초기 검증 |
| 라운드 1 | verification-state/screenshots/v001-mobile.png | 모바일 초기 |
| 라운드 {N} | verification-state/screenshots/v{N}-desktop.png | 최종 데스크톱 |
| 최종 | verification-state/screenshots/final-desktop.png | 최종 승인 데스크톱 |
| 최종 | verification-state/screenshots/final-tablet.png | 최종 승인 태블릿 |
| 최종 | verification-state/screenshots/final-mobile.png | 최종 승인 모바일 |

## 11. 게이트 최종 판정

```
BLOCKER: 0 / CRITICAL: 0 / MAJOR: {M} / MINOR: {m}

게이트 규칙: BLOCKER + CRITICAL = 0
판정: ✅ 통과 (또는 ❌ 미통과)
```

## 12. 산출물 목록

| 파일 | 경로 | 설명 |
|------|------|------|
| 검증 스펙 | feature-plan/verification-spec.json | Observer 검증 기준 |
| 라운드 결과 | verification-state/results/v*.json | 라운드별 상세 결과 |
| 수렴 로그 | verification-state/convergence-log.json | 수렴 추이 데이터 |
| 회귀 추적 | verification-state/regression-tracker.json | 회귀 발생/해결 이력 |
| Observer 로그 | verification-state/observer-log.md | 검증 전체 히스토리 |
| 스크린샷 | verification-state/screenshots/*.png | 뷰포트별 스크린샷 |
| 최종 검증 | verification-state/FINAL-VERIFICATION.md | 최종 승인 문서 |
```

---

## 사용법

Lead가 Phase 3에서 이 템플릿을 기반으로 `feature-plan/integration-report.md`를 생성합니다.

### 데이터 소스

| 섹션 | 데이터 소스 |
|------|-----------|
| 수렴 추이 | verification-state/convergence-log.json |
| 검증 결과 | verification-state/results/v*.json |
| 회귀 이력 | verification-state/regression-tracker.json |
| Worker 요약 | Worker 구현 완료 메시지 |
| 스크린샷 | verification-state/screenshots/ |
| 게이트 판정 | Observer 최종 승인 메시지 |

### 종료 코드별 리포트 차이

| 종료 코드 | 리포트 특이사항 |
|----------|---------------|
| `ALL_VERIFIED` | 정상 리포트 — 모든 섹션 완성 |
| `MAX_ROUNDS` | 미해결 항목 강조 + "추가 라운드 필요" 표시 |
| `PERSISTENT_FAIL` | 반복 실패 기준 분석 + 아키텍처 재검토 제안 |
| `WORKER_TIMEOUT` | Worker 무응답 시점 + 완료된 범위만 리포트 |
| `CONTEXT_LIMIT` | 현재까지 결과로 부분 리포트 생성 |
| `REGRESSION_LOOP` | 회귀 패턴 분석 + 설계 결함 가능성 제시 |
| `OBSERVER_CRASH` | Observer 장애 시점 + Lead 직접 검증 결과 |
