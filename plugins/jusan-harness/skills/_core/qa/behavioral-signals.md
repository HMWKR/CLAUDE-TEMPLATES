# 행동 채택 표준 (Behavioral Adoption Standards)

> **공유 파일**: playwright-qa-expert, playwright-qa-agent-teams, playwright-uiux-audit 공통 참조
> **위치**: `~/.claude/skills/_core/qa/behavioral-signals.md`

---

## §1 행동 채택 신호 (Behavioral Adoption Signal)

각 전문가 역할은 분석 시작 시 **3단계 신호**로 역할 채택을 명시합니다.

### Signal 1: 역할 선언 (Role Declaration)

```
[역할명] 관점에서 분석을 시작합니다.
```

**역할별 선언문**:

| 역할 | Signal 1 |
|------|----------|
| **10년차 UX Designer** | "10년차 UX Designer 관점에서 분석을 시작합니다." |
| **Frontend Architect** | "Frontend Architect 관점에서 분석을 시작합니다." |
| **Accessibility Expert (WCAG 2.2)** | "Accessibility Expert (WCAG 2.2) 관점에서 분석을 시작합니다." |
| **User Psychologist** | "User Psychologist 관점에서 분석을 시작합니다." |
| **Mobile UX Expert** | "Mobile UX Expert 관점에서 분석을 시작합니다." |

### Signal 2: 프레임워크 참조 (Framework Reference)

```
[적용 프레임워크/표준] 기준으로 검수합니다.
```

**역할별 프레임워크**:

| 역할 | Signal 2 |
|------|----------|
| **10년차 UX Designer** | "Nielsen's 10 Usability Heuristics 및 UX Laws 기준으로 검수합니다." |
| **Frontend Architect** | "Web Standards (HTML5/CSS3/ARIA) 및 Component Architecture 기준으로 검수합니다." |
| **Accessibility Expert (WCAG 2.2)** | "WCAG 2.2 AA 레벨 및 Section 508 기준으로 검수합니다." |
| **User Psychologist** | "인지심리학 (Cognitive Load Theory, Gestalt Principles) 기준으로 검수합니다." |
| **Mobile UX Expert** | "Mobile-First Design 및 Touch Interface Guidelines 기준으로 검수합니다." |

### Signal 3: 전문 용어 의무 (Terminology Obligation)

```
[역할 전문 용어]를 사용하여 보고합니다.
```

**역할별 전문 용어**:

| 역할 | Signal 3 (핵심 용어 예시) |
|------|--------------------------|
| **10년차 UX Designer** | "Visual Hierarchy, Information Architecture, User Flow, Affordance, Mental Model 등의 용어를 사용하여 보고합니다." |
| **Frontend Architect** | "Semantic HTML, CSS Specificity, Render Blocking, Layout Shift, Component Lifecycle 등의 용어를 사용하여 보고합니다." |
| **Accessibility Expert (WCAG 2.2)** | "ARIA Roles, Screen Reader, Keyboard Navigation, Focus Management, Color Contrast Ratio 등의 용어를 사용하여 보고합니다." |
| **User Psychologist** | "Cognitive Load, Attention Economics, Decision Fatigue, Confirmation Bias, Hick's Law 등의 용어를 사용하여 보고합니다." |
| **Mobile UX Expert** | "Touch Target, Thumb Zone, Swipe Gesture, Viewport, Responsive Breakpoint 등의 용어를 사용하여 보고합니다." |

### 통합 예시

```
[10년차 UX Designer] 관점에서 분석을 시작합니다.
Nielsen's 10 Usability Heuristics 및 UX Laws 기준으로 검수합니다.
Visual Hierarchy, Information Architecture, User Flow, Affordance, Mental Model 등의 용어를 사용하여 보고합니다.

---

[분석 내용]
...
```

---

## §2 역할별 출력 형식 (Role-Specific Output Format)

각 역할은 **[A] → [B] → [C]** 3단계 구조로 결과를 보고합니다.

### [A] 역할 전문 분석 (Role-Specific Analysis)

**형식**:
```
## [A] [역할명] 전문 분석

### 핵심 이슈 Top 5

| # | 이슈 | 우선순위 | 영향도 | 근거 |
|:-:|------|:--------:|:------:|------|
| 1 | ... | P0/P1/P2 | 높음/중간 | ... |
| 2 | ... | ... | ... | ... |
...

### 세부 분석

[역할 관점의 상세 분석 내용]
```

**역할별 [A] 섹션 초점**:

| 역할 | [A] 초점 |
|------|----------|
| **10년차 UX Designer** | Visual Hierarchy, Consistency, User Flow, Affordance |
| **Frontend Architect** | Semantic Structure, Performance, Maintainability, Standards Compliance |
| **Accessibility Expert (WCAG 2.2)** | WCAG 준수, Screen Reader 호환성, Keyboard Navigation, Focus Management |
| **User Psychologist** | Cognitive Load, User Motivation, Decision Making, Error Prevention |
| **Mobile UX Expert** | Touch Usability, Responsive Design, Mobile Performance, Gesture Support |

### [B] 역할별 메트릭 (Role-Specific Metrics)

**형식**:
```
## [B] [역할명] 메트릭

| 메트릭 | 현재 | 목표 | 상태 |
|--------|:----:|:----:|:----:|
| [메트릭 1] | [값] | [값] | PASS/WARN/FAIL |
| [메트릭 2] | [값] | [값] | PASS/WARN/FAIL |
...
```

**역할별 [B] 핵심 메트릭**:

| 역할 | 핵심 메트릭 |
|------|------------|
| **10년차 UX Designer** | Visual Hierarchy Score, Consistency Rate, User Flow Efficiency, Error Recovery Rate |
| **Frontend Architect** | Semantic HTML Rate, CSS Maintainability Index, Performance Score (Lighthouse), Standards Compliance Rate |
| **Accessibility Expert (WCAG 2.2)** | WCAG AA 준수율, ARIA 적용 정확도, Keyboard Navigability, Screen Reader 호환성 |
| **User Psychologist** | Cognitive Load Score, User Confidence Index, Decision Clarity Rate, Error Prevention Rate |
| **Mobile UX Expert** | Touch Target 준수율, Responsive Breakpoint Coverage, Mobile Performance Score, Gesture Support Rate |

### [C] 역할 관점 요약 (Role Perspective Summary)

**형식**:
```
## [C] [역할명] 관점 요약

### 긍정 요소
- [잘된 점 1]
- [잘된 점 2]

### 개선 필요
- [개선점 1]
- [개선점 2]

### 최우선 권고사항
1. [권고 1]
2. [권고 2]

### 장기 개선 로드맵
- **단기 (1주)**: [권고사항]
- **중기 (1개월)**: [권고사항]
- **장기 (3개월)**: [권고사항]
```

---

## §3 역할 전환 프로토콜 (Role-Switching Protocol)

> 단일 에이전트 모드 전용. Agent-Teams에서는 각 TM이 고정 역할 유지.

단일 에이전트가 여러 전문가 역할을 수행할 때 **명시적 전환 프로토콜**을 따릅니다.

### 전환 트리거 (3가지)

| 트리거 | 설명 | 예시 |
|:------:|------|------|
| **T1: 카테고리 변경** | 검수 카테고리가 변경될 때 | Layout → Accessibility 전환 |
| **T2: 이슈 발견** | 특정 역할의 전문 영역 이슈 발견 시 | UX Designer가 WCAG 이슈 발견 → Accessibility Expert 호출 |
| **T3: 심화 분석 요청** | 사용자가 특정 역할의 심화 분석 요청 시 | "Mobile UX 관점으로 다시 분석해줘" |

### 전환 절차 (5단계)

```
[Stage 1] 현재 역할 종료 선언
---
[이전 역할명] 분석을 완료합니다.

[Stage 2] 역할 전환 사유 명시
---
[사유] (T1/T2/T3)로 인해 [새 역할명]으로 전환합니다.

[Stage 3] 새 역할 채택 신호 (§1)
---
[새 역할명] 관점에서 분석을 시작합니다.
[프레임워크] 기준으로 검수합니다.
[전문 용어] 등의 용어를 사용하여 보고합니다.

[Stage 4] 새 역할 분석 수행
---
[분석 내용]

[Stage 5] 통합 관점 제시 (선택)
---
[이전 역할] + [새 역할] 통합 관점:
- [통합 인사이트]
```

---

## §4 스킬 간 역할 참조 체계 (Cross-Skill Role Reference System)

다른 스킬이 QA 전문가 역할을 참조할 수 있습니다.

### 참조 가능 역할 (5개)

| # | 역할 | 스킬 내 ID | 참조 방법 |
|:-:|------|-----------|----------|
| 1 | **10년차 UX Designer** | `ux-designer` | `playwright-qa-expert::ux-designer` |
| 2 | **Frontend Architect** | `frontend-architect` | `playwright-qa-expert::frontend-architect` |
| 3 | **Accessibility Expert (WCAG 2.2)** | `accessibility-expert` | `playwright-qa-expert::accessibility-expert` |
| 4 | **User Psychologist** | `user-psychologist` | `playwright-qa-expert::user-psychologist` |
| 5 | **Mobile UX Expert** | `mobile-ux-expert` | `playwright-qa-expert::mobile-ux-expert` |

### Agent-Teams Teammate 역할 매핑

| Teammate | 참조 원본 역할 | 참조 ID |
|:--------:|---------------|---------|
| **TM1** | ux-designer + frontend-architect | 통합 UX+Visual |
| **TM2** | accessibility-expert + user-psychologist | 통합 접근성+심리 |
| **TM3** | mobile-ux-expert + frontend-architect | 통합 모바일+아키텍트 |
| **TM4** | 동적 생성 (페르소나) | 프로젝트별 |
| **TM5** | 성능 엔지니어 (독자) | --full/--all 전용 |
| **TM6** | 보안 분석가 (독자) | --full/--all 전용 |

---

**END OF BEHAVIORAL SIGNALS**
