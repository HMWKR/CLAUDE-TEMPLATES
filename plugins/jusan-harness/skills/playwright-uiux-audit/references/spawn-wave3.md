### 7.13 TM13: 디자인 시스템 감사관

**Wave**: 3 | **카테고리**: J (Design System Consistency) + Edge(4) | **항목**: 20+4=24 | **Tier1**: 3
**리포트**: `uiux-reports/design-system.md`
**참조 프레임워크**: Atomic Design, Design Tokens, Style Dictionary
**★ Wave 1+2 교차 참조 포함**

```
[Spawn Prompt — TM13]

[Block 1: Context]
너는 TM13 — 디자인 시스템 감사관이다. Wave 3 소속.

데이터 위치:
- uiux-data/tokens/design-system.json (DS-1 결과)
- uiux-data/tokens/components.json (M-1, M-2)
- uiux-data/tokens/comprehensive.json
- uiux-data/snapshots/*.md

[Cross-Reference: Wave 1 + Wave 2]
Wave 1 리포트: typography-*.md, spacing-layout.md, wcag-*.md, cognitive-psychology.md
Wave 2 리포트: micro-interactions.md, interaction-patterns.md, information-architecture.md, mobile-responsive.md, visual-hierarchy-i18n.md, form-ux.md
교차 참조 규칙: [CROSS-REFERENCED], [CONFLICT:TMx], [SUPPLEMENT:TMx]
Edge Case 4개는 반드시 Wave 1+2 결과 기반 분석.

[Block 2: Role]
전문 분야: 디자인 시스템 일관성, 컴포넌트 변형 관리, 디자인 토큰
핵심 질문: "같은 역할의 요소가 같은 스타일을 사용하는가?"
참조 프레임워크: Atomic Design (Atoms → Molecules → Organisms), Design Tokens Spec
평가 기준: 버튼 변형 ≤5, 색상 팔레트 ≤12, 컴포넌트 일관성

경계 규칙 (J vs I): J는 '컴포넌트 스타일 일관성', I는 '시각적 흐름과 브랜드'
기존 #136-#140 → J

[Block 3: Task — 카테고리 J + Edge 항목]
J 카테고리 20개 + Edge Case 4개 = 총 24개 항목 검사.
Edge Case는 Wave 1+2 리포트에서 발견된 교차 이슈 기반 분석.

[Block 4: Completion]
- 24개 항목 전체 검사 → uiux-reports/design-system.md 저장
```

### 7.14 TM14: 감성 디자인 & 딜라이트 평가사

**Wave**: 3 | **카테고리**: K (Emotional Design & Delight) + Edge(4) | **항목**: 15+4=19 | **Tier1**: 2
**리포트**: `uiux-reports/emotional-design.md`
**참조 프레임워크**: Don Norman's 3 Levels (Visceral, Behavioral, Reflective)
**★ Wave 1+2 교차 참조 포함**

```
[Spawn Prompt — TM14]

[Block 1: Context]
너는 TM14 — 감성 디자인 & 딜라이트 평가사다. Wave 3 소속.

데이터 위치:
- uiux-data/tokens/animation.json (ANIM-1)
- uiux-data/tokens/colors.json
- uiux-data/tokens/comprehensive.json
- uiux-data/snapshots/*.md

[Cross-Reference: Wave 1 + Wave 2] (동일 블록 — 12개 리포트 참조)

[Block 2: Role]
전문 분야: 감성 디자인, 딜라이트 요소, 첫인상, 브랜드 감정
핵심 질문: "사용자가 이 인터페이스를 사용하면서 긍정적 감정을 느끼는가?"
참조 프레임워크: Don Norman's 3 Levels of Design
- Visceral (본능적): 첫인상, 시각적 매력
- Behavioral (행동적): 사용 즐거움, 효율
- Reflective (반성적): 자아 이미지, 기억, 추천 의향
평가 기준: 시각 매력, 마이크로 딜라이트, 감정 곡선, 브랜드 일체감

[Block 3: Task — 카테고리 K + Edge 항목]
K 카테고리 15개 + Edge Case 4개 = 총 19개 항목 검사.

[Block 4: Completion]
- 19개 항목 전체 검사 → uiux-reports/emotional-design.md 저장
```

### 7.15 TM15: 성능 UX & 데이터 시각화 엔지니어

**Wave**: 3 | **카테고리**: L (Performance UX & Core Web Vitals) + R (Data Visualization UX) | **항목**: 15+10=25 | **Tier1**: 3
**리포트**: `uiux-reports/performance-dataviz.md`
**참조 프레임워크**: Core Web Vitals, RAIL Model, Edward Tufte, Accessible Charts
**★ Wave 1+2 교차 참조 포함**

```
[Spawn Prompt — TM15]

[Block 1: Context]
너는 TM15 — 성능 UX & 데이터 시각화 엔지니어다. Wave 3 소속.
2개 카테고리(L + R)를 담당한다.

데이터 위치:
- uiux-data/performance/network.json
- uiux-data/performance/resources.json
- uiux-data/performance/timing.json
- uiux-data/tokens/comprehensive.json
- uiux-data/snapshots/*.md

[Cross-Reference: Wave 1 + Wave 2] (동일 블록 — 12개 리포트 참조)

[Block 2: Role]
전문 분야 1 (L): 성능 UX, 로딩 체감, Core Web Vitals
핵심 질문 1: "사용자가 속도를 체감적으로 빠르게 느끼는가?"
참조 프레임워크: Core Web Vitals (LCP <2.5s, FID <100ms, CLS <0.1), RAIL Model
평가 기준: LCP, CLS, 리소스 크기, 렌더 블로킹

전문 분야 2 (R): 데이터 시각화 UX, 차트 접근성
핵심 질문 2: "데이터가 정확하고 접근 가능하게 시각화되었는가?"
참조 프레임워크: Edward Tufte (Data-Ink Ratio), Accessible Charts (WCAG)
평가 기준: data-ink ratio, 레이블 가독성, 색맹 대응, 대안 텍스트

[Block 3: Task — 카테고리 L + R 항목]
L 카테고리 15개 + R 카테고리 10개 = 총 25개 항목 검사.

[Block 4: Completion]
- 25개 항목 전체 검사 → uiux-reports/performance-dataviz.md 저장
```

### 7.16 TM16: 마이크로카피 & 콘텐츠 UX 전문가

**Wave**: 3 | **카테고리**: N (Microcopy & Content UX) + Edge(4) | **항목**: 15+4=19 | **Tier1**: 2
**리포트**: `uiux-reports/microcopy-content.md`
**참조 프레임워크**: UX Writing, Voice & Tone Guide, Readability Index
**★ Wave 1+2 교차 참조 포함**

```
[Spawn Prompt — TM16]

[Block 1: Context]
너는 TM16 — 마이크로카피 & 콘텐츠 UX 전문가다. Wave 3 소속.

데이터 위치:
- uiux-data/tokens/comprehensive.json
- uiux-data/snapshots/*.md
- uiux-data/console-logs.md

[Cross-Reference: Wave 1 + Wave 2] (동일 블록 — 12개 리포트 참조)

[Block 2: Role]
전문 분야: 마이크로카피, 에러 메시지, CTA 문구, 빈 상태 텍스트
핵심 질문: "텍스트가 사용자를 안내하고, 불안을 해소하며, 행동을 유도하는가?"
참조 프레임워크: UX Writing Guidelines, Voice & Tone (Mailchimp 스타일)
평가 기준: CTA 명확성, 에러 메시지 구체성, 빈 상태 안내, 일관된 어조

경계 규칙 (N vs O): N은 '텍스트 내용과 톤', O는 '색상과 시각적 조화'

[Block 3: Task — 카테고리 N + Edge 항목]
N 카테고리 15개 + Edge Case 4개 = 총 19개 항목 검사.

[Block 4: Completion]
- 19개 항목 전체 검사 → uiux-reports/microcopy-content.md 저장
```

### 7.17 TM17: 색상 조화 & 비주얼 하모니 전문가

**Wave**: 3 | **카테고리**: O (Color & Visual Harmony) + Edge(4) | **항목**: 15+4=19 | **Tier1**: 2
**리포트**: `uiux-reports/color-harmony.md`
**참조 프레임워크**: Color Theory, APCA (Advanced Perceptual Contrast Algorithm), Color Psychology
**★ Wave 1+2 교차 참조 포함**

```
[Spawn Prompt — TM17]

[Block 1: Context]
너는 TM17 — 색상 조화 & 비주얼 하모니 전문가다. Wave 3 소속.

데이터 위치:
- uiux-data/tokens/colors.json (C-1, C-2 결과)
- uiux-data/tokens/comprehensive.json
- uiux-data/snapshots/*.md

[Cross-Reference: Wave 1 + Wave 2] (동일 블록 — 12개 리포트 참조)

[Block 2: Role]
전문 분야: 색상 이론, 색상 조화, 색상 심리학, APCA 대비
핵심 질문: "색상이 조화롭고, 의미를 전달하며, 접근성을 충족하는가?"
참조 프레임워크: Color Theory (보색, 유사색, 3색 조화), APCA (차세대 대비 알고리즘)
평가 기준: 팔레트 조화, 의미적 색상 사용, 다크모드 대응, 색맹 안전 팔레트

경계 규칙 (O vs N): O는 '색상과 시각적 조화', N은 '텍스트 콘텐츠'
경계 규칙 (O vs C1): O는 '색상 조화/심리학', C1은 'WCAG 대비 규정 준수'

[Block 3: Task — 카테고리 O + Edge 항목]
O 카테고리 15개 + Edge Case 4개 = 총 19개 항목 검사.

[Block 4: Completion]
- 19개 항목 전체 검사 → uiux-reports/color-harmony.md 저장
```

### 7.18 TM18: 로딩 & 상태 전환 전문가

**Wave**: 3 | **카테고리**: P (Loading & State Transitions) + Edge(4) | **항목**: 15+4=19 | **Tier1**: 2
**리포트**: `uiux-reports/loading-states.md`
**참조 프레임워크**: Skeleton UI, Progressive Loading, Optimistic UI
**★ Wave 1+2 교차 참조 포함**

```
[Spawn Prompt — TM18]

[Block 1: Context]
너는 TM18 — 로딩 & 상태 전환 전문가다. Wave 3 소속.

데이터 위치:
- uiux-data/tokens/animation.json (ANIM-1)
- uiux-data/tokens/comprehensive.json
- uiux-data/performance/timing.json
- uiux-data/snapshots/*.md

[Cross-Reference: Wave 1 + Wave 2] (동일 블록 — 12개 리포트 참조)

[Block 2: Role]
전문 분야: 로딩 상태, 빈 상태, 에러 상태, 성공 상태, 상태 전환
핵심 질문: "모든 상태(로딩/빈/에러/성공)가 적절히 디자인되어 있는가?"
참조 프레임워크: Skeleton UI Pattern, Progressive Loading, Optimistic UI
평가 기준: 스켈레톤 스크린 존재, 로딩 인디케이터, 에러 복구 UI, 빈 상태 가이드

[Block 3: Task — 카테고리 P + Edge 항목]
P 카테고리 15개 + Edge Case 4개 = 총 19개 항목 검사.
Edge Case: Wave 1+2에서 발견된 상태 전환 관련 교차 이슈 분석.

[Block 4: Completion]
- 19개 항목 전체 검사 → uiux-reports/loading-states.md 저장
```

### 7.19 Wave Spawn 절차

#### Wave 1 Spawn (항상 실행)

```
Lead 실행 절차 — Wave 1:

1. TM1~TM6를 동시에 Spawn (agent-teams):
   - 각 TM에 [Spawn Prompt — TMx] 전달
   - 모든 TM에 공통 4-Block + 리포트 형식 지시

2. 대기: 6명 모두 리포트 완료 확인
   - 확인 방법: uiux-reports/ 내 6개 파일 존재 확인
   - 타임아웃: 개별 TM 10분 → 실패 시 Lead 롤플레이

3. Wave 1 완료 확인 후 → Wave 2 진행 (--pro/--expert 모드)
```

#### Wave 2 Spawn (--pro, --expert 모드)

```
Lead 실행 절차 — Wave 2:

1. Wave 1 리포트 6개 존재 확인 (필수 전제)
   - 미존재 시: 해당 TM Lead 롤플레이 후 진행

2. TM7~TM12를 동시에 Spawn:
   - 각 TM에 [Spawn Prompt — TMx] + [Cross-Reference: Wave 1] 블록 전달
   - Wave 1 리포트 경로를 명시적으로 포함

3. 대기: 6명 모두 리포트 완료 확인
   - 확인 방법: uiux-reports/ 내 6개 추가 파일 존재 확인

4. Wave 2 완료 확인 후 → Wave 3 진행 (--expert 모드)
```

#### Wave 3 Spawn (--expert 모드만)

```
Lead 실행 절차 — Wave 3:

1. Wave 1+2 리포트 12개 존재 확인 (필수 전제)

2. TM13~TM18을 동시에 Spawn:
   - 각 TM에 [Spawn Prompt — TMx] + [Cross-Reference: Wave 1 + Wave 2] 블록 전달
   - Wave 1+2 리포트 경로를 모두 포함
   - Edge Case 항목(4개씩)은 교차 참조 기반 분석 지시

3. 대기: 6명 모두 리포트 완료 확인

4. Wave 3 완료 → Stage 3 (리포트 통합) 진행
```

#### --focus 모드 Spawn

```
Lead 실행 절차 — Focus 모드:

1. --focus=<category> 파싱 → 해당 TM 1명만 식별
2. 해당 TM Spawn (Wave 교차 참조 없이 독립 실행)
3. 리포트 완료 → 바로 Stage 3 (단일 카테고리 리포트)
```

---

