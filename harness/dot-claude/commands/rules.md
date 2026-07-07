---
description: 현행 하네스 규칙 참조 가이드
---

# 하네스 규칙 참조

> 2026-07-07 재작성: 구 `~/.claude/skills/_core/` SSoT 구조는 폐기됨. 현행 = **CLAUDE.md + ~/.claude/rules/ + 플러그인**.

## 계층 구조 (현행)

- **`~/.claude/CLAUDE.md`** — 글로벌 지침: 언어 · CE 원칙 · **착수 계약**(의도점검 · plan-first · 투두추적 · what→goal 자동트리거 · 빈칸처리 · 임의결정금지 · 정직보고) · **작업 방식**(고수준지시 · Explore 위임 · Playwright MCP 우선 · Serena · 이미지→codex · 크롤 가치 판정) · 검증 원칙 · 커밋 · Memory · Knot · **Operating mode(fablize)** · **레이어 서열** · bkit 하이브리드.
- **`~/.claude/rules/`** — 자동 적용 상세 규칙:
  - **always-on**(paths 없음): anti-hallucination · safety · karpathy-code-guidelines · uncompromising-rigor · live-feature-verify · loop-prevention · image-codex-routing · agent-teams-boundaries
  - **paths-scoped**: ui-ux-craft(`*.tsx·*.css…`) · agent-mapping(`.claude/agents`) · insight-distribution(`docs/domain-knowledge`)
- **플러그인**: fablize(operating block · `goals.py` · `gate_stop`) · jusan-harness(스킬·에이전트) · bkit · omc · superpowers.
- **`~/.claude/workflows/`** · **프로젝트별 CLAUDE.md/.claude/rules/**(nested — 해당 디렉토리 작업 시 로드).

## 핵심 규칙 위치

| 규칙 | 위치 |
|---|---|
| 언어 · CE · 착수계약 · 레이어 서열 | `~/.claude/CLAUDE.md` |
| 환각방지(검증마커 [검증됨]/[추정]/[미확인]) | `rules/anti-hallucination.md` |
| 파괴적 명령 · 손상 한글 · 시크릿 | `rules/safety.md` |
| 코드 4원칙(카파시) | `rules/karpathy-code-guidelines.md` |
| 검증 규율(발견=결함) · 브라우저 우선순위 | `rules/uncompromising-rigor.md` (2026-07-07: **Playwright MCP 전역 우선**) |
| feature 실동작 검증(Playwright) | `rules/live-feature-verify.md` |
| 멀티에이전트 경계 · 파일=기억 · 표준 파이프라인 | `rules/agent-teams-boundaries.md` |
| 이미지→codex · 크롤 가치 판정 | `rules/image-codex-routing.md` · CLAUDE.md 작업 방식 |
| 오케스트레이션 실행 템플릿 | `~/.claude/workflows/conductor-verify.js` |
| 완료 게이트 · goal 트리거 | fablize `gate_stop` · `goals.py`(CLAUDE.md Operating mode) |
| 루프 방지 · plan 체크마크 | `rules/loop-prevention.md` |
| 커밋 | 4섹션 What/Why/Impact + `Co-Authored-By:` |
| CE 사고여정 | `~/.thoughts/YYYY-MM-DD-{subject}.md` |
