# 에이전트 역할 자동 분류 알고리즘

> SSOT: 파싱된 에이전트 메타데이터를 4가지 역할(Lead/Director/Evaluator/QA)로 분류하는 규칙

## 4가지 역할 정의

| 역할 | 핵심 특성 | 행동 |
|------|---------|------|
| **Lead** | 직접 작업 안 함, 위임만 | 오케스트레이션, 우선순위 결정 |
| **Director** | 실제 코드/문서 작업 수행 | Agent tool로 호출, 결과물 생성 |
| **Evaluator** | Read-only 검증, 채점 | 이슈 보고, 점수 산출 |
| **QA** | 테스트 실행, 동작 확인 | Playwright/코드 테스트, 버그 보고 |

## 분류 알고리즘

### Step 1: constraints 기반 1차 분류 (가장 강한 시그널)

```
if "[CONSTRAINTS]"에 "직접 작업 금지" 또는 "직접 코드 작성 금지" 또는 "위임만":
    → Lead
    
elif "[CONSTRAINTS]"에 "코드 수정 금지" 또는 "Read-only" 또는 "이슈 보고만":
    if "[TASK]"에 "테스트" 또는 "QA" 또는 "앱 테스트" 또는 "동작 확인":
        → QA
    else:
        → Evaluator
        
else:
    → Director (기본값)
```

### Step 2: tools 기반 2차 검증

```
if tools에 "Edit" 또는 "Write" 포함:
    → Director 확인 (Lead/Evaluator는 Edit/Write를 가질 수 없음)
    
if tools에 "Agent" 포함:
    → Lead 가능성 높음 (하위 에이전트 위임 가능)
    → 단, Director도 Sub-Agent를 가질 수 있으므로 Step 1과 교차 검증
```

### Step 3: description/role 키워드 3차 보강

| 키워드 | 매핑 역할 | 우선순위 |
|--------|---------|---------|
| "총괄", "오케스트레이터", "프로젝트 리드" | Lead | 높음 |
| "Director", "개발", "구현", "설계", "빌드" | Director | 중간 |
| "검증", "평가", "채점", "감사", "리뷰" | Evaluator | 중간 |
| "테스트", "QA", "품질", "버그", "앱 테스트" | QA | 중간 |
| "인사이트", "분석", "도출" | Director (분석형) | 낮음 |
| "발표", "PPT", "영상", "미디어" | Director (미디어형) | 낮음 |

### Step 4: 충돌 해결

동일 에이전트가 복수 역할에 매칭될 때:
1. `constraints` 기반 분류가 최우선
2. `tools` 기반 검증이 차순위
3. 키워드는 보조 참고

예외: `Agent` 도구를 가진 Director는 하위 에이전트를 spawn할 수 있으므로 정상.

## 작업-에이전트 매칭 알고리즘

### 매칭 프로세스

```
사용자 요청: "UI/UX 개선해줘"
    ↓
1. 요청 키워드 추출: ["UI", "UX", "개선"]
    ↓
2. 각 Director의 [ACTIVATION] 섹션과 매칭:
   - frontend-director: ["앱 개발", "UI/UX 개선", "데모 앱"] → 매칭 점수 높음
   - data-eng-director: ["데이터 파이프라인", "적재"] → 매칭 낮음
   - ml-director: ["모델 학습", "예측"] → 매칭 낮음
    ↓
3. 최고 점수 Director 선택: frontend-director
    ↓
4. 관련 QA/Evaluator 자동 매핑:
   - QA: 역할이 QA인 에이전트 전부 (보통 1개)
   - Evaluator: 역할이 Evaluator인 에이전트 전부 (또는 --full 시)
```

### 매칭 점수 계산

```
score = 0
for keyword in user_keywords:
    if keyword in agent.activation_keywords:
        score += 10  # 정확 매칭
    elif keyword in agent.task_keywords:
        score += 5   # 작업 키워드 매칭
    elif keyword in agent.role_keywords:
        score += 3   # 역할 키워드 매칭
    elif keyword in agent.description:
        score += 1   # 설명 내 포함
```

### 매칭 실패 시

어떤 Director도 매칭되지 않을 때:
1. 사용자에게 에이전트 목록을 보여주고 수동 선택 요청
2. 또는 Lead 에이전트가 있으면 Lead에게 판단 위임

## QA/Evaluator 자동 선택

### 기본 모드
- QA 역할 에이전트 1개만 선택 (첫 번째)
- Evaluator 역할 에이전트 1개만 선택 (가장 범용적인 것)

### --full 모드
- QA 역할 에이전트 전부
- Evaluator 역할 에이전트 전부 (병렬 실행)

### Evaluator 우선순위 (여러 개일 때)

1. 채점/스코어링 관련 → 항상 포함
2. 일관성/정합성 관련 → --full 시 포함
3. 사실 검증 관련 → --full 시 포함
4. 인사이트 관련 → 선택적

## 에이전트 의존성 파악

### 단방향 의존 탐지

`[CONTEXT]`에서 "관련 파일" 또는 "[CONSTRAINTS]"의 쓰기 범위를 분석하여 의존성 그래프 구성:

```
예시 (Snow 프로젝트):
architect → data-eng-director → ml-director → frontend-director
                                    ↓
                              insight-director → presentation-director
```

이 그래프를 Phase 2 루프에서 Director 실행 순서 결정에 활용.
동일 파일을 수정하는 Director 2개가 있으면 → 순차 실행 (병렬 금지).
