# 이미지 자산 → codex MCP 라우팅

> CLAUDE.md "작업 방식" 보강. 이미지 관련 산출물이 필요한 작업은 codex MCP를 교차벤더 워커로 활용한다. (사용자 지침 2026-07-06)

## 발동
로고·아이콘·SVG·다이어그램·일러스트·이미지 생성/편집 등 **이미지 자산이 산출물에 포함**되거나 이미지를 활용한 UI·문서·브랜딩 작업.

## 라우팅 규칙
- **코드/벡터형(로고·아이콘·SVG·다이어그램)**: codex MCP(`mcp__codex__codex`)에 위임해 SVG/코드로 생성한다 — codex는 벡터·코드 자산에 강하다.
- **래스터/사진형**: codex가 도구(스크립트·CLI)로 생성 가능하면 codex, 불가하면 대안 제시(Figma MCP `mcp__claude_ai_Figma__*` 또는 외부 이미지 모델) — 추측 생성 금지.
- **호출·회수**: codex는 기본 read-only, 산출물(SVG/코드)은 응답으로 회수 → 오케스트레이터가 파일에 반영한다. 워커는 외부에 직접 쓰지 않는다([[agent-teams-boundaries]] 정합).
- **승인**: 외부·유료 이미지 도구 호출은 별도 승인 대상.

## 왜
- MultiAgent 2.2: codex-main 역할에 "이미지 생성" 포함 — 교차벤더 분업. 벤더 독립 원칙과 정합.
- 근거 분석: `~/.thoughts/2026-07-06-harness-multiagent-v2.2-analysis.md`.
