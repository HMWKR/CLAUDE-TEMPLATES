## 9. Stage 2: Three-Wave 병렬 분석 실행

### 9.1 Wave 실행 프로토콜

```
┌─────────────────────────────────────────────────────────────────┐
│ Stage 2A: Wave 1 — Foundation (TM1-TM6)                        │
│ ├─ 6 Teammates 동시 spawn                                      │
│ ├─ 각 TM: uiux-data/ 읽기 → 분석 → uiux-reports/{file}.md 쓰기│
│ ├─ 완료 대기 (모든 TM 완료 또는 타임아웃)                      │
│ └─ Lead: Wave 1 리포트 6개 수집 확인                           │
├─────────────────────────────────────────────────────────────────┤
│ Stage 2B: Wave 2 — Interaction (TM7-TM12) [--pro/--expert]     │
│ ├─ 6 Teammates 동시 spawn (★ Wave 1 리포트 참조 지시)          │
│ ├─ 각 TM: uiux-data/ + uiux-reports/W1 읽기 → 분석 → 쓰기    │
│ ├─ 중복 발견 시 [CROSS-REF:W1] 태그 표시                      │
│ └─ Lead: Wave 2 리포트 6개 수집 확인                           │
├─────────────────────────────────────────────────────────────────┤
│ Stage 2C: Wave 3 — Expert (TM13-TM18) [--expert]              │
│ ├─ 6 Teammates 동시 spawn (★ Wave 1+2 리포트 참조 지시)       │
│ ├─ 각 TM: uiux-data/ + uiux-reports/W1+W2 읽기 → 분석 → 쓰기 │
│ ├─ 중복 발견 시 [CROSS-REF:W1], [CROSS-REF:W2] 태그 표시     │
│ └─ Lead: Wave 3 리포트 6개 수집 확인                           │
└─────────────────────────────────────────────────────────────────┘
```

### 9.2 Wave 완료 게이트

각 Wave 완료 후 Lead가 검증:

```
[Wave Gate Checklist]
□ 모든 TM 리포트 파일 존재 확인
□ 각 리포트 최소 구조 충족 (헤더 + 발견사항 + 요약)
□ 실패한 TM 식별 → Fallback 롤플레이 결정
□ 교차 참조 태그 존재 확인 (Wave 2+)
□ 다음 Wave spawn 준비
```

### 9.3 중복 제거 프로토콜

Stage 3에서 Lead가 수행하는 중복 제거:

```
1. [CROSS-REF:W1] 태그된 항목 수집
2. [CROSS-REF:W2] 태그된 항목 수집
3. [OVERLAP:E/F] 태그된 항목 수집
4. 동일 이슈 → 가장 상세한 분석 유지, 나머지 참조로 변환
5. 유사 이슈 → 통합 + 출처 TM 모두 표기
6. 최종: 중복 제거 후 고유 이슈 목록 생성
```

### 9.4 모드별 Wave 실행 매트릭스

| 모드 | Wave 1 | Wave 2 | Wave 3 | 체크항목 | TM 수 |
|:----:|:------:|:------:|:------:|:-------:|:-----:|
| basic | T1만 | ✗ | ✗ | ~22 | 6 |
| --pro | 전체 | T1+T2 | ✗ | ~216 | 12 |
| --expert | 전체 | 전체 | 전체 | 360 | 18 |
| --focus=`<cat>` | 해당 TM만 | - | - | 15-25 | 1 |
