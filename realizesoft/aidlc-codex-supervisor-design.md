# AI-DLC Codex 확장 스킬 설계 문서

## 1. 목적

이 문서는 원본 `aidlc-codex` 스킬을 수정하지 않고, 그 파이프라인 구조 위에 사용자의 기존 스킬들을 조건부 모듈로 덧붙이는 새 Codex 전용 스킬의 설계 기준이다.

핵심 목표는 다음과 같다.

- 원본 `~/.codex/skills/aidlc-codex`는 그대로 보존한다.
- 새 스킬은 `aidlc-codex`의 AI-DLC lifecycle을 기준 파이프라인으로 사용한다.
- 사용자의 기존 스킬은 각 AI-DLC 단계에 조건부 보조 모듈로 연결한다.
- 조건부 스킬 실행 전에는 추천 이유, 장점, 단점, 비용/리스크를 제시하고 사용자가 선택하게 한다.
- 하위 스킬이 원래 요구하는 `request_user_input`, `Question Gate`, `user-input` 흐름은 생략하지 않는다.
- 선택 지원 자료와 최종 결정 기록은 `aidlc-docs/UserChoice/` 아래에 분리한다.
- 배포는 Vercel 중심으로 고정하지 않고 AWS, Google Cloud, Azure, Cloudflare, Firebase, Supabase, Vercel, self-hosted 등을 선택 가능한 provider-neutral 구조로 둔다.

## 2. 원칙

### 2.1 원본 보존

`aidlc-codex` 원본 스킬은 수정하지 않는다. 새 스킬은 별도 이름과 별도 디렉토리로 생성한다.

### 2.2 기준 파이프라인 유지

새 스킬은 `aidlc-codex`를 대체하지 않는다. 역할은 원본 AI-DLC 단계에 추가 스킬을 언제, 왜, 어떤 조건으로 붙일지 결정하는 상위 라우팅 레이어다.

### 2.3 사용자 선택 우선

조건부 스킬은 조용히 자동 실행하지 않는다. 실행 여부가 결과 품질, 비용, 외부 도구 사용, 파일 생성, 배포, sub-agent 실행에 영향을 주면 선택 게이트를 연다.

### 2.4 Codex 런타임 현실성

이 스킬은 Claude Code의 `.claude/CLAUDE.md` 자동 로딩이나 Kiro steering 동작을 그대로 복제한다고 주장하지 않는다.

Codex에서의 제어 지점은 다음이다.

- 명시적 스킬 호출
- 현재 대화 컨텍스트
- 프로젝트 `AGENTS.md`
- `SKILL.md`
- 사용 가능한 도구
- sandbox 권한
- `update_plan`
- 사용자 승인

## 3. 전역 규칙

### 3.1 Selection Gate UX Rule

중요한 조건부 분기마다 다음 형식을 사용한다.

```text
Selection Gate
- 추천 선택지
- 추천 이유
- 각 선택지의 장점
- 각 선택지의 단점
- 예상 비용/속도/리스크
- 사용자 선택 입력
```

규칙:

- 추천안은 항상 1번에 두고 `(Recommended)`를 표시한다.
- `request_user_input` 도구가 가능하면 tool 기반으로 처리한다.
- 현재 모드에서 도구가 unavailable이면 `Text fallback Question Gate`를 사용한다.
- 사용자가 선택하기 전에는 다음 단계, 파일 생성, 외부 서비스 호출, 배포, destructive action, real sub-agent 실행을 진행하지 않는다.

### 3.2 UI/UX Decision Gate

UI/UX 관련 선택이 필요한 경우 다음 선택지를 제공한다.

```text
1. ASCII Wireframe
   - 빠르게 구조를 비교하기 좋음
   - 실제 시각 품질과 반응형 판단은 약함

2. HTML Preview
   - 실제 레이아웃과 흐름 판단에 좋음
   - 파일 생성과 검증 시간이 더 필요함

3. External Reference Input
   - Figma, Notion, 이미지, 참고 사이트, 설명을 사용자가 제공할 수 있음
   - 외부 자료 품질에 따라 판단이 흔들릴 수 있음
```

### 3.3 UserChoice Artifact Rule

사용자 선택을 돕기 위해 생성되는 자료는 앱 코드나 일반 AI-DLC 산출물과 섞지 않는다.

기본 루트:

```text
aidlc-docs/UserChoice/
├── orient/
├── requirements-discovery/
├── planning-design/
├── implementation/
├── verification/
├── deployment/
└── uiux/
```

각 선택 게이트는 하위 디렉토리를 가진다.

```text
aidlc-docs/UserChoice/<stage>/<gate>/
├── ascii-wireframe.txt
├── preview.html
├── external-input.txt
└── decision.md
```

`decision.md`는 사용자가 최종 선택한 뒤 생성한다.

필수 내용:

```md
# User Choice Decision

## Pipeline Stage
## Gate
## Options Presented
## Recommended Option
## Why Recommended
## User Selection
## Evidence Flow
## Tradeoffs
## Resulting Pipeline Behavior
## Triggered Skill Gates
## Remaining Risks
```

### 3.4 Skill Trigger Input Gate Mode

기본값:

```text
Strict Gate Preservation
```

의미:

- 트리거된 하위 스킬의 Q1/Q2/Q3/Q4 게이트를 가능한 한 보존한다.
- Q4 안전 게이트는 절대 생략하거나 병합하지 않는다.
- 유사한 Q2/Q3 게이트를 병합하는 `Consolidated Gate`는 옵션으로만 제공한다.
- Q4만 강제하고 나머지를 추천값으로 진행하는 `Fast Gate`는 기본값으로 쓰지 않는다.

## 4. 확정된 단계별 매핑

### 4.1 Orient / Purpose

확정안:

- 조건부 `cynefin`
- 조건부 `what`

사용 조건:

- 요구사항이 모호함
- 프로젝트 범위가 큼
- 설계/아키텍처 판단이 포함됨
- 사용자가 `$what`, "왜부터", "심층 검토", "객관적으로" 같은 표현을 씀
- AI-DLC 단계 선택 전에 성공 기준이 불명확함

역할:

- `cynefin`: 작업 성격과 복잡도 분류
- `what`: Why / What / How / So What 목적 정렬

### 4.2 Requirements / Discovery

확정안:

- 기본 `to-prd`
- 조건부 `domain-researcher`
- 조건부 `ux-pattern-researcher`

사용 조건:

- `to-prd`: 대화, repo 맥락, 기능 논의를 PRD/요구사항 구조로 정리할 때
- `domain-researcher`: 시장, 경쟁사, 규제, 도메인 데이터, 기술 스택 근거가 필요할 때
- `ux-pattern-researcher`: 화면 설계, 유저 플로우, 전환율, 도메인 UI 패턴이 중요할 때

### 4.3 Planning / Design

확정안:

- 조건부 `grill-me`
- 조건부 `architect`
- 고위험 조건부 `first-principles`

사용 조건:

- `grill-me`: 실행 계획에 결정되지 않은 핵심 분기가 있을 때
- `architect`: Application Design, Infrastructure Design, 구조 설계가 실제로 필요할 때
- `first-principles`: 기술 선택, 아키텍처 전환, 인프라 선택처럼 전제가 틀리면 전체가 무너지는 경우

제외 기준:

- `architect`를 기본 실행하지 않는다. 자체 7단계 조직/스캐폴딩 흐름이 원본 AI-DLC를 덮어쓸 수 있기 때문이다.

### 4.4 Implementation / Construction

확정안:

- 원본 `aidlc-codex` Code Generation 유지
- 조건부 `tdd`
- 조건부 `diagnose`
- 조건부 `js-refactor-cleanup-skill`

사용 조건:

- `tdd`: 새 기능, 버그 수정, 관찰 가능한 동작, 테스트 러너가 있는 경우
- `diagnose`: 버그, 실패 로그, 성능 저하, 재현 루프가 필요한 경우
- `js-refactor-cleanup-skill`: JavaScript/TypeScript 코드 정리, 리네이밍, 리팩터링인 경우

주의:

- 원본 Code Generation의 계획 승인, 단계별 체크박스, 코드 위치 규칙을 대체하지 않는다.
- 보조 스킬은 구현 방식 선택에만 관여한다.

### 4.5 Verification / QA

확정안:

- 원본 Build/Test 유지
- 조건부 `webapp-testing`
- 조건부 `security-audit`
- 조건부 `web-design-guidelines`
- 조건부 `live-verify-loop`

사용 조건:

- `webapp-testing`: 로컬 웹앱, 화면, 브라우저 동작, 스크린샷, 콘솔 확인이 필요한 경우
- `security-audit`: 인증/인가, 입력 검증, 의존성, OWASP 검토가 필요한 경우
- `web-design-guidelines`: UI 코드, 접근성, 반응형, 시맨틱 HTML, 성능 검토가 필요한 경우
- `live-verify-loop`: 실제 브라우저에서 통과할 때까지 반복 검증이 필요한 경우

주의:

- `live-verify-loop`는 작은 작업의 기본값으로 쓰지 않는다.
- 종료 기준, 라운드 제한, 대상 URL/역할/브라우저 도구를 선택 게이트로 확정한다.

### 4.6 Deployment / Operations

확정안:

- Provider-neutral Deployment Gate
- 조건부 `vercel-deploy`

Provider 후보:

```text
1. AWS
2. Google Cloud
3. Azure
4. Cloudflare
5. Firebase
6. Supabase
7. Vercel
8. Self-hosted / VPS
9. Plan only
```

규칙:

- Vercel을 기본값으로 고정하지 않는다.
- `vercel-deploy`는 사용자가 Vercel을 선택했을 때만 실행 후보로 둔다.
- AWS/GCP/Azure/Cloudflare/Firebase/Supabase/self-hosted는 우선 배포 계획, 환경변수, IaC/CLI 필요 조건, 롤백 전략을 만든다.
- 실제 외부 배포, production 변경, 도메인 변경, 비용 발생 가능 작업은 Q4 승인 없이는 실행하지 않는다.

## 5. 명시 요청 시만 노출할 스킬

다음 스킬은 기본 AI-DLC 확장 파이프라인에 항상 노출하지 않는다. 사용자가 명시적으로 요청하거나 해당 상황이 강하게 드러날 때만 선택지로 제시한다.

- `harness-loop`
- `agent-teams-*`
- `agent-teams-orchestrator`
- `think-teams`
- `playwright-qa-agent-teams`
- `playwright-uiux-audit`
- `continuous-qa-loop`
- `ultradetail-walk`
- `ultradetail-loop`
- `agent-architect`

이유:

- 실제 sub-agent 실행 또는 병렬 실행 권한이 필요할 수 있음
- Q4 승인 게이트가 강함
- 원본 `aidlc-codex`의 순차 lifecycle을 별도 오케스트레이션 구조로 바꿀 수 있음
- 비용과 시간이 큼

## 6. 기본 제외, 필요 시 별도 호출할 스킬

다음 스킬은 AI-DLC 본류와 목적이 다르거나, 원본 pipeline을 덮어쓸 위험이 있어 기본 라우팅에서 제외한다.

- `project-kickstart`: 질문 없이 전체 자동 생성이라 Strict Gate Preservation과 충돌
- `project-bootstrapper`: 별도 7단계 프로젝트 패키지 생성기라 AI-DLC를 덮어쓸 수 있음
- `pipeline-orchestrator`: 자체 프로젝트 파이프라인 PM 성격이 강함
- `think-full`, `think-deep`, `think-lite`: `cynefin`, `what`, `first-principles`와 중복 가능
- `ce-advisor`, `what-ce`: 프롬프트 최적화 요청이 있을 때만 사용
- `pdf`, `docx`, `xlsx`, `ppt-study`, `imagegen`: 파일/미디어 작업일 때만 사용
- `cantos-write`, `source-command-journal`: 기록, ADR, DDR, 사고여정을 사용자가 원할 때만 사용

## 7. Sub-agent 정책

새 스킬은 하위 스킬 설명에 Agent Teams가 있다고 해서 자동으로 `spawn_agent`를 실행하지 않는다.

규칙:

- 사용자가 sub-agent, 병렬, 위임, Agent Teams, worker/evaluator 실행을 명시한 경우에만 실제 spawn을 고려한다.
- 실제 spawn 전에는 Agent Execution Plan을 작성한다.
- Agent Execution Plan에는 Agent, Role, Methodology sources, Applied methodology, Model, Reasoning, Scope, Write set, Verification, Dependency를 포함한다.
- Worker write set은 겹치지 않게 한다.
- Q4 승인 전에는 logical role mapping 또는 Lead-only 실행으로 제한한다.

## 8. UserChoice 디렉토리 정책

`UserChoice`는 실제 앱 코드가 아니다. 결정 지원 자료와 결정 기록 전용이다.

경로:

```text
aidlc-docs/UserChoice/<stage>/<gate>/
```

원칙:

- 선택 전 자료는 사용자가 판단할 수 있을 만큼만 생성한다.
- 최종 선택 후 `decision.md`를 생성한다.
- `decision.md`에는 추천 이유와 사용자가 선택한 이유의 차이를 모두 남긴다.
- 외부 입력 링크나 참고 자료는 `external-input.txt` 또는 `decision.md`에 기록한다.
- UI/UX 선택에서 HTML preview를 선택한 경우 `preview.html`을 같은 게이트 디렉토리에 둔다.

## 9. 예상 새 스킬 구조

새 스킬 이름은 아직 최종 확정하지 않는다.

후보:

| 후보 이름 | 장점 | 주의점 |
|---|---|---|
| `aidlc-RealizeSoft` | 사용자가 확정한 RealizeSoft 명칭을 사용하면서 `aidlc` 기반임을 유지 | 대소문자 포함 이름이므로 호출 시 정확히 써야 함 |
| `aidlc-codex-router` | 단계별 스킬 라우팅 역할이 명확함 | 라우팅에만 좁아 보일 수 있음 |
| `aidlc-codex-supervisor` | 감독 레이어 의미가 분명함 | 이전 `aidlc-supervisor` 흔적과 혼동 가능 |
| `aidlc-codex-workflow` | workflow 확장 느낌이 자연스러움 | 보조 스킬 연결성이 덜 드러남 |

추천 후보:

```text
aidlc-RealizeSoft
```

이유:

- 사용자가 확정한 RealizeSoft 명칭을 반영함
- `aidlc` 접두어를 유지해 AI-DLC 계열 스킬임이 드러남
- 원본을 수정하지 않고 확장한다는 역할은 본문과 description에서 명시함

예상 구조:

```text
~/.codex/skills/aidlc-RealizeSoft/
├── SKILL.md
├── agents/
│   └── openai.yaml
└── references/
    ├── routing-map.md
    ├── selection-gates.md
    ├── userchoice-artifacts.md
    ├── deployment-providers.md
    └── excluded-skills.md
```

## 10. 검증 기준

새 스킬 생성 전 검증해야 할 사항:

- 원본 `aidlc-codex` 무수정
- 새 스킬 이름 확정
- Selection Gate UX Rule 반영
- UserChoice Artifact Rule 반영
- Strict Gate Preservation 반영
- 단계별 확정 매핑 반영
- 고비용/병렬/sub-agent 스킬 기본 제외
- provider-neutral deployment gate 반영
- Vercel은 조건부 adapter로만 유지
- 프로젝트 요구사항을 스킬 내부에 내장하지 않음
- `SKILL.md`는 짧게 유지하고 상세는 `references/`로 분리

## 11. 다음 단계

1. 이 설계 문서 검토
2. 새 스킬 이름 확정
3. 새 스킬 디렉토리 생성 승인
4. `SKILL.md`와 `references/` 작성
5. 원본 `aidlc-codex` 무수정 확인
6. 새 스킬이 skill list에 인식 가능한 구조인지 확인
