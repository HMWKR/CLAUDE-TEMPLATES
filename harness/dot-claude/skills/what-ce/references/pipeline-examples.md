# What-CE 파이프라인 예시

> 3개 도메인(코딩/기획/분석)별 Stage 1 → Handoff → Stage 2 흐름 예시.
> 실제 파이프라인 실행 시 참조용. 축약 표기.

---

## 예시 1: 코딩 — "API 성능 최적화"

### 사용자 입력

```
/what-ce API 응답 속도가 너무 느려서 최적화하고 싶어
```

### Stage 1: What Framework

| 축 | 내용 |
|-----|------|
| **Why** | 사용자 이탈률 15% → 5% 이하로 줄이기 위해 |
| **What** | p95 응답시간 2초 → 500ms 이하 달성 |
| **How** | DB 쿼리 최적화 + 캐시 레이어 + 병렬 처리 |
| **So What** | 이탈률 감소 → 전환율 상승 → 매출 증가 |

### Handoff Object

```
────── HANDOFF: Stage 1 → Stage 2 ──────
| 축       | Stage 1 결론              | CE 매핑        |
|----------|--------------------------|----------------|
| Why      | 이탈률 감소               | Background     |
| What     | p95 ≤ 500ms             | Goal           |
| How      | 쿼리+캐시+병렬            | Constraints    |
| So What  | 전환율 → 매출             | Eval Criteria  |
──────────────────────────────────────────
```

### Stage 2: CE Advisor 핵심 출력

- **Goal**(←What): "p95 응답시간 500ms 이하 달성"
- **Constraints**(←How): 기존 API 구조 유지, DB 스키마 변경 최소화
- **Eval**(←So What): 부하 테스트 통과 여부, 이탈률 지표 개선
- **3+1 제안**: (1) N+1 쿼리 제거 + Redis 캐시, (2) CDN + Edge Function, (3) 비동기 큐 분리, (+1) 위 1+3 조합

---

## 예시 2: 기획 — "신규 온보딩 플로우 설계"

### 사용자 입력

```
/what-ce --fast 신규 유저 온보딩 개선하고 싶어
```

### Stage 1: What Framework (Fast Mode — 1회 확인)

| 축 | 내용 |
|-----|------|
| **Why** | Day-7 리텐션 25% → 40%로 끌어올리기 위해 |
| **What** | 첫 세션에서 핵심 가치(AHA moment) 도달률 80% |
| **How** | 3단계 인터랙티브 튜토리얼 + 개인화 질문 |
| **So What** | 리텐션 → LTV 증가 → CAC 회수 기간 단축 |

> Fast Mode: 4행 표를 한 번에 제시 → 사용자 확인 1회로 Stage 2 진입.

### Handoff → Stage 2 요약

- **7축 자동 매핑**: Goal="AHA moment 도달률 80%", Constraints="3단계+개인화", Eval="Day-7 리텐션 40%"
- **실패 모드 진단**: Distraction 위험 — 온보딩 단계가 많아지면 핵심 가치 희석
- **제안**: (1) 프로그레시브 디스클로저형, (2) 게이미피케이션형, (3) 소셜 프루프형, (+1) 1+3 하이브리드

---

## 예시 3: 분석 — "경쟁사 분석 보고서"

### 사용자 입력

```
/what-ce 우리 SaaS 서비스의 경쟁사 분석 보고서 만들어줘
```

### Stage 1: What Framework

| 축 | 내용 |
|-----|------|
| **Why** | Q2 가격 정책 리뉴얼 의사결정 근거 확보 |
| **What** | 상위 경쟁사 5개 기능·가격·포지셔닝 비교표 |
| **How** | 공개 데이터 수집 → 기능 매트릭스 → 포지셔닝 맵 |
| **So What** | 가격 정책 조정안 도출 → 경영진 보고 |

### Stage 2에서 Backtrack 발생 시나리오

```
[Stage 2 Phase 1 분석 후]

Claude: "7축 분석 결과입니다. 확인해주세요."
  - [1] 승인 → Phase 2로
  - [2] 수정 요청
  - [3] Stage 1 재작업  ← 사용자 선택

사용자: "3번 — 경쟁사 5개가 아니라 직접 경쟁 3개에 집중하고 싶어"

→ Stage 1 STEP 2(What)부터 재실행
→ 새로운 Handoff Object 생성
→ Stage 2 Phase 0부터 재시작
```

---

## 흐름 요약

```
[입력] → Stage 1 (STEP 1~4)
           ↓ 확인
       Handoff Object 생성
           ↓
       Stage 2 (Phase 0~3)
           ↓ 확인
       실행 또는 TodoWrite 추적
```

**Fast Mode 차이**: Stage 1 확인이 4회 → 1회로 압축. 4행 표는 동일하게 생성.
**Backtrack**: Stage 2 어느 확인 지점에서든 "Stage 1 재작업" 선택 가능.
