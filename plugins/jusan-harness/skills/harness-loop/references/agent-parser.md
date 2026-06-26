# 에이전트 정의 파싱 로직

> SSOT: `.claude/agents/*.md` 파일에서 에이전트 메타데이터를 추출하는 규칙

## 파싱 대상

각 에이전트 정의 파일은 다음 구조를 따른다:

```markdown
---
name: agent-name
description: "에이전트 설명"
tools:
  - Read
  - Write
  - Edit
  - ...
---

[ROLE]
역할 설명

[PERSONA]
전문 분야, 경력, 사고 방식

[CONTEXT]
프로젝트 컨텍스트, 작업 범위, 관련 파일

[TASK]
1. 작업 1
2. 작업 2

[SUB-AGENTS]
하위 에이전트 목록

[CONSTRAINTS]
제약 조건

[ACTIVATION]
트리거 키워드/상황
```

## 파싱 절차

### Step 1: Glob으로 파일 목록 수집
```
Glob(".claude/agents/*.md")
```

### Step 2: 각 파일 Read + 메타데이터 추출

**frontmatter 추출** (YAML `---` 블록):
- `name` → Agent tool의 `subagent_type` 파라미터로 사용
- `description` → 에이전트 역할 요약
- `tools` → 사용 가능한 도구 목록 (역할 분류에 활용)

**섹션 추출** (대괄호 헤더 `[SECTION]`):
- `[ROLE]` → 역할 키워드 추출 (분류에 사용)
- `[TASK]` → 담당 업무 목록 (작업 매핑에 사용)
- `[CONSTRAINTS]` → 제약 조건 (도메인 경계 + 역할 분류에 사용)
- `[ACTIVATION]` → 트리거 키워드 (작업-에이전트 매칭에 사용)
- `[SUB-AGENTS]` → 하위 에이전트 (위임 체인 파악)

### Step 3: 구조화된 에이전트 객체 생성

```
{
  "name": "frontend-director",
  "description": "프론트엔드부 총괄",
  "tools": ["Read", "Write", "Edit", "Glob", "Grep", "Bash", "Agent"],
  "role_keywords": ["Streamlit 앱 개발", "데이터 시각화"],
  "task_keywords": ["앱 구조 설계", "대시보드", "필터/컨트롤"],
  "constraints": ["백엔드 로직 수정 금지", "src/data/ 쓰기 금지"],
  "activation_keywords": ["앱 개발", "UI/UX 개선", "데모 앱"],
  "write_scope": ["src/app/", "domain-knowledge/frontend/"],
  "has_edit_tools": true,
  "has_sub_agents": true
}
```

## 에이전트 미정의 시 처리

`.claude/agents/` 디렉토리가 없거나 `*.md` 파일이 0개인 경우:

```
⚠️ 이 프로젝트에는 에이전트가 정의되어 있지 않습니다.

에이전트 조직을 설계하려면:
1. /agent-architect — 대화형으로 에이전트 조직 자동 구축
2. 수동으로 .claude/agents/*.md 파일 생성

에이전트 없이 진행하려면 일반 작업 모드를 사용하세요.
```

## frontmatter가 없는 에이전트 파일

일부 에이전트 파일이 frontmatter 없이 본문만 있을 수 있다.
이 경우:
- `name` → 파일명에서 `.md` 제거 (예: `qa-lead.md` → `qa-lead`)
- `description` → `[ROLE]` 섹션 첫 줄 사용
- `tools` → 알 수 없으므로 기본값 `["Read", "Glob", "Grep"]` 적용
