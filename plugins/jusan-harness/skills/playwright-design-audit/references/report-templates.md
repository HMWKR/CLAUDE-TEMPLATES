# 리포트 템플릿

> 최종 리포트와 diff 비교 리포트 형식 정의.

---

## 1. 최종 리포트 구조

```markdown
# UI/UX Design Audit Report

## 1. 감사 개요
| 항목 | 값 |
|------|-----|
| URL | {url} |
| 일시 | {YYYY-MM-DD HH:MM} |
| 모드 | {basic/pro/expert/--focus=<cat>} |
| 검사 항목 | {검사수}/{전체수} ({비율}%) |
| 뷰포트 | 1920, 1366, 768, 390, 320px |
| TM 수 | {수} |
| 소요 시간 | {분:초} |

## 2. UX Score
**{점수}/100 ({등급})**

{18차원 레이더 차트 텍스트}

### 차원별 점수
| # | 차원 | 점수 | PASS | FAIL | N/T | 가중치 |
|:-:|------|:----:|:----:|:----:|:---:|:------:|
| 1 | Typography Fundamentals | {n} | {n} | {n} | {n} | 6% |
| ... | ... | ... | ... | ... | ... | ... |

## 3. 프로젝트 컨텍스트 (Stage 0)
- **브랜드 컬러**: {CLAUDE.md에서 추출}
- **폰트**: {CLAUDE.md에서 추출}
- **톤**: {CLAUDE.md에서 추출}
- **도메인**: {자동 파악}
- **페르소나**: {3명 생성 결과}
- **전문가 선택**: {자동 선택 결과}

## 4. 이슈 요약
| 심각도 | 건수 | 감점 |
|--------|:----:|:----:|
| CRITICAL | {n} | -{n×3} |
| MAJOR | {n} | -{n×1} |
| MINOR | {n} | 0 |
| SUGGESTION | {n} | 0 |

## 5. 상세 이슈 목록

### CRITICAL

#### {ISS-C-001} {제목}
| 필드 | 값 |
|------|-----|
| 카테고리 | {A-V} |
| 항목 ID | {A-01} |
| TM | TM{n} |
| 위치 | {CSS 선택자 or 페이지 영역} |
| 검증 마커 | {[DATA-VERIFIED] 등} |
| 뷰포트 | {해당 뷰포트} |

**현상**: {구체적 설명}
**영향**: {사용자 영향}
**권장 수정**: {코드 레벨 수정 제안}
**스크린샷**: {있는 경우 경로}

### MAJOR
...

### MINOR
...

### SUGGESTION
...

## 6. 카테고리별 분석

### A. Typography Fundamentals (TM1)
- 점수: {n}/100
- PASS: {n}/{total}
- 주요 발견: {요약}
- [A] 구조 분석: {매트릭스}
- [B] 메트릭: {수치}
- [C] 전문가 총평: "{역할}으로서..."

### B. Typography Advanced (TM2)
...

## 7. Design Quality 분석 (신규 S/T/U)

### S. Typography & Color Quality (TM7)
- 폰트 품질 점수: {n}/100
- 색상 전략 점수: {n}/100
- 주요 발견:
  - 제네릭 폰트 사용: {건수}
  - Display/Body 페어링: {있음/없음}
  - 주조색 지배도: {n}%
  - Accent 날카로움: {Hue 차이}도

### T. Layout & Brand Coherence (TM19)
...

### U. Memorability & Emotional Impact (TM19)
...

## 8. 검증 로그
[HH:MM:SS] browser_navigate → {url} [DATA-VERIFIED]
[HH:MM:SS] browser_snapshot → 1920px [SNAPSHOT-VERIFIED]
[HH:MM:SS] browser_evaluate → T-1 body font → {결과} [DATA-VERIFIED]
...

## 9. 종합 권고사항

### P0 — 즉시 수정 (CRITICAL)
1. {이슈 요약 + 수정 방향}

### P1 — 조속 수정 (MAJOR)
1. {이슈 요약 + 수정 방향}

### P2 — 개선 제안 (MINOR)
1. {이슈 요약}

### P3 — 장기 제안 (SUGGESTION)
1. {이슈 요약}
```

---

## 2. Diff 비교 리포트

### 파일명 규칙

```
{project-root}/.qa-audit/run-{timestamp}/FINAL-REPORT.md
```

### 비교 로직

```
1. .qa-audit/ 폴더 검색
2. 현재 run 제외 가장 최신 run의 FINAL-REPORT.md 식별
3. 이전 리포트의 이슈 목록 파싱
4. 이슈 매칭 (카테고리 + 항목 ID + 위치 기준)
5. 분류: 해결됨 / 신규 / 악화 / 유지
```

### 비교 섹션 (리포트 끝에 추가)

```markdown
## 10. 이전 리포트 대비 변화

### 비교 기준
| 항목 | 이전 | 현재 |
|------|------|------|
| 리포트 일시 | {이전 일시} | {현재 일시} |
| 모드 | {이전 모드} | {현재 모드} |
| UX Score | {이전 점수} ({등급}) | {현재 점수} ({등급}) |
| 점수 변화 | — | {+/-n점} {화살표} |

### 심각도별 변화
| 심각도 | 이전 | 현재 | 변화 |
|--------|:----:|:----:|:----:|
| CRITICAL | {n} | {n} | {+/-} |
| MAJOR | {n} | {n} | {+/-} |
| MINOR | {n} | {n} | {+/-} |

### 해결된 이슈 ({n}건)
| 이슈 ID | 심각도 | 제목 | 해결 확인 |
|---------|--------|------|-----------|
| {id} | {sev} | {title} | [DATA-VERIFIED] |

### 신규 발견 이슈 ({n}건)
| 이슈 ID | 심각도 | 제목 | 카테고리 |
|---------|--------|------|----------|
| {id} | {sev} | {title} | {cat} |

### 악화된 이슈 ({n}건)
| 이슈 ID | 이전 심각도 | 현재 심각도 | 제목 |
|---------|:----------:|:----------:|------|
| {id} | {prev} | {curr} | {title} |

### 개선 추이
Run 1: ████████░░ 80
Run 2: █████████░ 85 (+5)
Run 3: █████████░ 87 (+2)
```

---

## 3. TM 개별 리포트 형식

각 TM은 `.qa-audit/run-{ts}/reports/tm{n}-{category}.md`에 작성:

```markdown
# TM{n} Report: {카테고리명}

## 검사 결과 요약
| PASS | FAIL | NOT-TESTABLE | 점수 |
|:----:|:----:|:------------:|:----:|
| {n} | {n} | {n} | {n}/100 |

## 상세 결과

| ID | 항목 | 결과 | 검증 마커 | 비고 |
|:--:|------|:----:|:---------:|------|
| {id} | {title} | PASS/FAIL/N-T | {marker} | {note} |

## 발견 이슈

### {ISS-{sev}-{num}} {제목}
- 카테고리: {cat}
- 항목: {id}
- 심각도: {CRITICAL/MAJOR/MINOR/SUGGESTION}
- 검증 마커: {marker}
- 현상: {description}
- 영향: {impact}
- 권장 수정: {fix}

## [A] 구조 분석
{카테고리별 매트릭스/맵}

## [B] 메트릭
{수치 데이터}

## [C] 전문가 총평
"{역할}으로서, 이 인터페이스는..."
```

---

## 4. 이슈 ID 규칙

```
ISS-{심각도약어}-{3자리순번}

심각도약어:
  C = CRITICAL
  M = MAJOR
  N = MINOR
  S = SUGGESTION

예: ISS-C-001, ISS-M-003, ISS-N-012, ISS-S-005
```

---

## 5. 검증 마커 (6종)

| 마커 | 의미 | 사용 조건 |
|------|------|-----------|
| `[DATA-VERIFIED]` | CSS evaluate 데이터로 확인 | 스니펫 반환값 기반 |
| `[SNAPSHOT-VERIFIED]` | DOM 스냅샷으로 확인 | browser_snapshot 기반 |
| `[PATTERN-INFERRED]` | 패턴에서 추론 | 여러 데이터 포인트 종합 |
| `[CROSS-REFERENCED]` | 다른 TM 결과와 교차 검증 | Wave 간 참조 |
| `[FRAMEWORK-BASED]` | 이론/프레임워크 기반 판단 | Nielsen, WCAG 등 |
| `[NOT-TESTABLE]` | 자동 테스트 불가 | 주관적 판단 필요 항목 |
