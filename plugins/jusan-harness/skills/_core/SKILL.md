---
name: _core
description: "Shared SSoT (Single Source of Truth) resources referenced by multiple skills. Contains expert role definitions, problem-solving protocols, team orchestration patterns, and QA checklists. This skill should NOT be invoked directly — it provides foundational references for other skills via file paths."
---

# _core — 공유 리소스 허브

> 여러 스킬이 공통으로 참조하는 SSoT(Single Source of Truth) 리소스 디렉토리.
> 직접 호출되지 않으며, 다른 스킬의 SKILL.md에서 참조 경로로 사용된다.

---

## 목적

- **중복 제거**: 동일 내용이 여러 스킬에 복사되는 것을 방지
- **일관성 보장**: 역할 정의, 프로토콜 등을 한 곳에서 관리
- **유지보수 용이**: 변경 시 이 디렉토리만 수정하면 전체 반영

## 포함 리소스

| 파일 | 용도 | 참조 스킬 |
|------|------|-----------|
| `roles.md` | 9개 전문가 역할 정의 (트리거, 프레임워크, 필수 용어) | deep-analysis-mode, domain-expert-analysis, playwright-qa-expert |
| `protocols.md` | 문제 해결 5단계 프로토콜, 디버깅 워크플로우 | deep-analysis-mode, continuous-qa-loop |
| `team-patterns.md` | Agent Teams 오케스트레이션 4개 패턴 (Fan-Out, Pipeline, Hybrid, Reactive) | agent-teams-*, architect |
| `confirmation-loop.md` | 사용자 확인 루프 프로토콜, 자동 승인 조건 | continuous-qa-loop, playwright-qa-expert |
| `qa/` | QA 체크리스트 원본 (175항목 Tier 1-3) | playwright-qa-expert, playwright-qa-agent-teams |

## 참조 방법

다른 스킬의 SKILL.md에서 다음과 같이 참조:

```markdown
## 참조
- 전문가 역할: `~/.claude/skills/_core/roles.md`
- 문제 해결 프로토콜: `~/.claude/skills/_core/protocols.md`
```

실행 시 Claude가 해당 파일을 Read하여 컨텍스트에 로드한다.

## 변경 규칙

1. **이 디렉토리의 파일 수정 시**: 참조하는 모든 스킬에 영향이 있으므로 신중하게 변경
2. **새 리소스 추가 시**: 2개 이상의 스킬에서 공통으로 필요한 내용만 추가
3. **삭제 시**: 참조 스킬이 없는지 grep으로 확인 후 삭제
