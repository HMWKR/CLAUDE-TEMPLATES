## 섹션 7: 18명 Teammate 정의 & Spawn 프롬프트

### 7.0 공통 Spawn 템플릿 (4-Block)

모든 TM spawn 프롬프트는 다음 4-Block 구조를 따름:

```
[Block 1: Context Priming]
- 팀 역할, 데이터 위치, Wave 교차 참조 정보

[Block 2: Role Definition]
- 전문 분야, 핵심 질문, 평가 기준, 참조 프레임워크

[Block 3: Task Instructions]
- 5단계 분석 절차:
  Step 1: 데이터 파일 읽기
  Step 2: Tier별 체크리스트 항목 순회
  Step 3: 항목별 PASS/FAIL/SKIP 판정 + 검증 마커
  Step 4: 발견 사항 심각도 분류 (Critical/Major/Minor/Info)
  Step 5: 리포트 작성 → 지정 파일에 저장

[Block 4: Completion Conditions]
- 모든 Tier 항목 검사 완료
- 각 항목에 검증 마커 필수
- 리포트 파일 저장 확인
```

### 7.0.1 Wave 교차 참조 블록

#### Wave 2 TM에 추가되는 블록 (TM7-TM12)

```
[Cross-Reference: Wave 1]
Wave 1 리포트를 읽고 교차 참조하라:
- uiux-reports/typography-fundamentals.md (TM1)
- uiux-reports/typography-advanced.md (TM2)
- uiux-reports/spacing-layout.md (TM3)
- uiux-reports/wcag-core.md (TM4)
- uiux-reports/wcag-advanced.md (TM5)
- uiux-reports/cognitive-psychology.md (TM6)

교차 참조 규칙:
1. Wave 1에서 발견된 이슈와 관련된 항목은 [CROSS-REFERENCED] 마커 사용
2. Wave 1 결과와 모순되는 발견 시 [CONFLICT:TMx] 태그로 명시
3. Wave 1에서 놓친 관련 이슈 발견 시 [SUPPLEMENT:TMx] 태그로 보완
```

#### Wave 3 TM에 추가되는 블록 (TM13-TM18)

```
[Cross-Reference: Wave 1 + Wave 2]
Wave 1 + Wave 2 리포트를 모두 읽고 교차 참조하라:
- Wave 1: uiux-reports/typography-*.md, spacing-layout.md, wcag-*.md, cognitive-psychology.md
- Wave 2: uiux-reports/micro-interactions.md, interaction-patterns.md, information-architecture.md, mobile-responsive.md, visual-hierarchy-i18n.md, form-ux.md

교차 참조 규칙:
1. Wave 1+2에서 발견된 이슈와 관련된 항목은 [CROSS-REFERENCED] 마커 사용
2. 모순 발견 시 [CONFLICT:TMx] 태그
3. 보완 발견 시 [SUPPLEMENT:TMx] 태그
4. Edge Case 항목(4개)은 반드시 Wave 1+2 결과 기반으로 분석
```

### 7.0.2 리포트 출력 형식 (모든 TM 공통)

```markdown
# [카테고리명] 분석 리포트 — [TM역할]

## 요약
- **검사 항목**: X/Y (PASS: A, FAIL: B, SKIP: C)
- **심각도 분포**: Critical: X, Major: Y, Minor: Z, Info: W
- **카테고리 점수**: XX/100
- **교차 참조**: [해당 Wave만] N건 참조, M건 보완

## 상세 결과

### [항목 ID] [항목명] — [Tier]
- **결과**: PASS / FAIL / SKIP
- **검증**: [DATA-VERIFIED] / [SNAPSHOT-VERIFIED] / [NOT-TESTABLE]
- **데이터**: [실제 측정값]
- **기준**: [프레임워크 기준값]
- **심각도**: Critical / Major / Minor / Info
- **권장사항**: [구체적 수정 방법]
- **교차참조**: [CROSS-REFERENCED:TMx] / [SUPPLEMENT:TMx] (해당 시)

## 교차 참조 요약 (Wave 2/3만)
| 원본 TM | 관련 항목 | 태그 | 내용 |
|---------|----------|------|------|
| TMx | #ID | [SUPPLEMENT] | ... |
```

### 7.1-7.18 TM Spawn 프롬프트 (Progressive Disclosure)

> **모드별 로딩**: 해당 Wave의 references 파일만 Read하여 컨텍스트 절약.

| 모드 | 로드할 파일 | TM 수 |
|:----:|-----------|:-----:|
| basic | [references/spawn-wave1.md](references/spawn-wave1.md) | TM1-6 |
| --pro | 위 + [references/spawn-wave2.md](references/spawn-wave2.md) | TM1-12 |
| --expert | 위 + [references/spawn-wave3.md](references/spawn-wave3.md) | TM1-18 |
| --focus | 해당 TM이 포함된 Wave 파일에서 해당 TM만 | 1 |
