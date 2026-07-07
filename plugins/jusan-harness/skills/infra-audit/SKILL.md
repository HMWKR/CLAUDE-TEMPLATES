---
name: infra-audit
description: >-
  This skill should be used when the user asks to "audit infra", "infra audit",
  "인프라 감사", "인프라 검사", "check infrastructure", "health check",
  "infra health", "설정 검사", or "인프라 건강도".
  Claude Code 인프라(CLAUDE.md, hooks, skills, rules, scripts, agents, MCP)의
  종합 건강도를 점수(0-100) + 등급(S/A/B/C/F)으로 진단하고,
  하니스 5축(CE/AC/GC/EL/SI) 기여도를 매핑한다.
user_invocable: true
version: 1.0.0
---

# Infra Audit — Claude Code 종합 인프라 검사

> `~/.claude/` 인프라 전체를 7개 영역 × 42개 항목으로 검사하고,
> 정량 점수(0-100)와 하니스 5축 기여도를 산출한다.

## 역할 분담

- **이 스킬**: 검사 워크플로우, 점수 공식, 보고서 형식 정의
- **infra-auditor 에이전트**: 실제 파일 읽기/검사 실행 (Task tool로 위임 가능)
- **`scripts/infra-audit.sh`**: 자동화 가능한 구조 검사 (JSON 유효성, 파일 존재 등)

## 실행 모드

| 모드 | 명령 | 설명 |
|------|------|------|
| **full** | `/infra-audit` | 7영역 전체 검사 (기본) |
| **quick** | `/infra-audit --quick` | 핵심 3영역만 (CLAUDE.md, Hooks, Skills) |
| **focus** | `/infra-audit --focus=hooks` | 특정 영역 심층 검사 |

## 검사 워크플로우

### Phase 1: 자동화 검사

`scripts/infra-audit.sh` 실행으로 기계적 검사 항목을 먼저 수집한다.

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/infra-audit/scripts/infra-audit.sh
```

출력: JSON 형식의 PASS/WARN/FAIL 결과.

### Phase 2: 정성 검사

자동화로 판단 불가능한 항목을 Claude가 직접 검사한다:
- CLAUDE.md 내용 품질 (중복, 일관성)
- Skills description 트리거 품질
- Hooks prompt 훅의 판단 적절성
- _core 참조 정합성

### Phase 3: 점수 산출

각 영역별 점수를 가중 합산한다.

## 7개 검사 영역 + 가중치

| # | 영역 | 가중치 | 항목 수 | 하니스 주요 축 |
|:-:|------|:-----:|:------:|:------------:|
| 1 | CLAUDE.md | 20% | 8 | CE |
| 2 | Hooks | 20% | 8 | AC, SI |
| 3 | Skills | 20% | 8 | CE, GC |
| 4 | Rules | 10% | 5 | GC, EL |
| 5 | Scripts | 15% | 6 | AC, EL |
| 6 | Agents | 10% | 4 | AC, SI |
| 7 | MCP | 5% | 3 | SI |
| | **합계** | **100%** | **42** | |

상세 체크리스트: **`references/checklist.md`** 참조.

## 점수 공식

```
총점 = Σ (영역별_점수 × 가중치)

영역별_점수 = (PASS 항목 수 × 10 + WARN 항목 수 × 5) / (전체 항목 수 × 10) × 100
```

## 등급 체계

| 점수 | 등급 | 의미 | 조치 |
|:----:|:----:|------|------|
| 95+ | **S** | 완벽한 인프라 | 유지 |
| 85+ | **A** | 우수 | 미세 조정 |
| 70+ | **B** | 양호 | 개선 권고 |
| 50+ | **C** | 기능적이나 문제 다수 | 수정 필요 |
| <50 | **F** | 긴급 수정 필요 | 즉시 조치 |

## 하니스 5축 매핑

각 검사 항목에 하니스 축 태그가 붙어 있다. 검사 완료 후 축별 기여도를 집계한다:

```
하니스 기여도
├── CE (Context Engineering): CLAUDE.md 품질 + Skills 구조 + _core 참조
├── AC (Agentic Coding):      Hooks 안전성 + Scripts 실행성 + Agents 정합성
├── GC (Generation Control):   Skills 트리거 + Rules 커버리지
├── EL (Evaluation Loop):      Rules 검증 + Scripts 자동화
└── SI (System Integration):   Hooks 이벤트 + Agents 도구 + MCP 연동
```

축별 점수 = 해당 축 태그가 붙은 항목들의 PASS 비율 × 10 (0.0-10.0 스케일).

## 보고서 출력 형식

```markdown
# Infra Audit Report

## 요약
| 항목 | 값 |
|------|-----|
| 검사 항목 | 42개 |
| PASS | N개 |
| WARN | N개 |
| FAIL | N개 |
| **총점** | **N/100** |
| **등급** | **[S/A/B/C/F]** |

## 영역별 점수
| 영역 | 점수 | 가중 점수 | 상태 |
|------|:----:|:--------:|:----:|
| CLAUDE.md | N | N×0.2 | [상태] |
| Hooks | N | N×0.2 | [상태] |
| Skills | N | N×0.2 | [상태] |
| Rules | N | N×0.1 | [상태] |
| Scripts | N | N×0.15 | [상태] |
| Agents | N | N×0.1 | [상태] |
| MCP | N | N×0.05 | [상태] |

## 하니스 5축 기여도
| 축 | 점수 | 해당 항목 |
|----|:----:|:--------:|
| CE | N/10 | N개 |
| AC | N/10 | N개 |
| GC | N/10 | N개 |
| EL | N/10 | N개 |
| SI | N/10 | N개 |

## 상세 결과
### [영역명]
- [PASS] 항목: 설명
- [WARN] 항목: 설명 → 권장 조치
- [FAIL] 항목: 설명 → 필수 조치

## 권장 조치 (우선순위순)
1. [FAIL] ...
2. [WARN] ...
```

## 참조 리소스

### Reference Files
- **`references/checklist.md`** — 42개 검사 항목 상세 (기준, 방법, 하니스 태그)

### Scripts
- **`scripts/infra-audit.sh`** — 자동화 구조 검사 (Bash)

### 연동 에이전트
- **`${CLAUDE_PLUGIN_ROOT}/agents/infra-auditor.md`** — 실제 검사 실행 에이전트


## 42개 검사 항목 요약

### 1. CLAUDE.md (8항목, 20%)

| # | 항목 | PASS 기준 | 하니스 축 |
|:-:|------|----------|:---------:|
| 1-1 | 글로벌 CLAUDE.md 존재 | 파일 존재 + 50단어 이상 | CE |
| 1-2 | 프로젝트별 CLAUDE.md | 활성 프로젝트에 존재 | CE |
| 1-3 | 중복 없음 | rules/와 내용 중복 20% 미만 | CE |
| 1-4 | 구조화 | 마크다운 헤딩 3개 이상 | CE |
| 1-5 | 코드 규칙 포함 | 코딩 컨벤션 섹션 존재 | GC |
| 1-6 | 프로젝트 컨텍스트 | 프로젝트별 기술스택/구조 명시 | CE |
| 1-7 | 적정 길이 | 200-2000 단어 | CE |
| 1-8 | 버전/날짜 | 최근 갱신일 기록 | CE |

### 2. Hooks (8항목, 20%)

| # | 항목 | PASS 기준 | 하니스 축 |
|:-:|------|----------|:---------:|
| 2-1 | settings.json 존재 | 유효한 JSON | SI |
| 2-2 | PreToolUse 훅 | 최소 1개 존재 | AC |
| 2-3 | 안전 훅 | 파괴적 명령 차단 | AC |
| 2-4 | timeout 설정 | 모든 훅에 timeout | SI |
| 2-5 | PostToolUse 훅 | 최소 1개 존재 | AC |
| 2-6 | Notification 훅 | 알림 훅 존재 | SI |
| 2-7 | 에러 처리 | 훅 스크립트 에러 핸들링 | AC |
| 2-8 | 적정 수량 | 5-15개 | AC |

### 3. Skills (8항목, 20%)

| # | 항목 | PASS 기준 | 하니스 축 |
|:-:|------|----------|:---------:|
| 3-1 | SKILL.md 존재 | 모든 스킬에 존재 | CE |
| 3-2 | YAML 프론트매터 | name + description 필수 | GC |
| 3-3 | 트리거 품질 | Use when + NOT for 패턴 | GC |
| 3-4 | _core 참조 | roles.md + protocols.md 참조 | CE |
| 3-5 | 콘텐츠 충실도 | 1,500-3,000 단어 (PASS) | CE |
| 3-6 | references/ 존재 | 참조 디렉토리 + 파일 | CE |
| 3-7 | 스크립트 연동 | scripts/ 내 실행 파일 | AC |
| 3-8 | 예제 포함 | 코드 블록 2개 이상 | GC |

### 4. Rules (5항목, 10%)

| # | 항목 | PASS 기준 | 하니스 축 |
|:-:|------|----------|:---------:|
| 4-1 | rules/ 디렉토리 | 존재 + 파일 2개 이상 | GC |
| 4-2 | 안전 규칙 | safety.md 존재 | GC |
| 4-3 | 환각 방지 | anti-hallucination.md 존재 | EL |
| 4-4 | 루프 방지 | loop-prevention.md 존재 | EL |
| 4-5 | 프로젝트 규칙 | 활성 프로젝트에 규칙 존재 | GC |

### 5. Scripts (6항목, 15%)

| # | 항목 | PASS 기준 | 하니스 축 |
|:-:|------|----------|:---------:|
| 5-1 | scripts/ 존재 | 디렉토리 + 파일 존재 | AC |
| 5-2 | 실행 권한 | chmod +x 설정 | AC |
| 5-3 | shebang | #!/bin/bash 또는 동등 | AC |
| 5-4 | 유틸리티 | 3개 이상 유틸 스크립트 | EL |
| 5-5 | 에러 처리 | set -e 또는 동등 | EL |
| 5-6 | 문서화 | 사용법 주석/도움말 | AC |

### 6. Agents (4항목, 10%)

| # | 항목 | PASS 기준 | 하니스 축 |
|:-:|------|----------|:---------:|
| 6-1 | agents/ 존재 | 디렉토리 + 파일 존재 | AC |
| 6-2 | 에이전트 정의 | 유효한 마크다운 구조 | SI |
| 6-3 | 도구 매핑 | 사용 도구 목록 명시 | SI |
| 6-4 | 적정 수량 | 2-10개 | AC |

### 7. MCP (3항목, 5%)

| # | 항목 | PASS 기준 | 하니스 축 |
|:-:|------|----------|:---------:|
| 7-1 | .mcp.json 존재 | 파일 존재 | SI |
| 7-2 | 유효한 설정 | JSON 파싱 성공 + mcpServers 키 | SI |
| 7-3 | 임시 파일 정리 | 캐시/임시 파일 100개 미만 | SI |

## 개선 우선순위 가이드

FAIL 항목 수정 순서:
1. **안전 관련** (2-3, 4-2): 파괴적 명령 차단, 안전 규칙
2. **핵심 구조** (1-1, 3-1, 3-2): CLAUDE.md, SKILL.md 기본 구조
3. **품질 향상** (3-3, 3-5): 트리거 품질, 콘텐츠 충실도
4. **자동화** (5-2, 5-5): 스크립트 실행성, 에러 처리
5. **연동** (7-1, 7-2): MCP 설정

WARN 항목은 가중치 높은 영역부터 우선 수정한다.


## 자동화 스크립트 사용법

### 기본 실행

```bash
# 전체 검사
bash ${CLAUDE_PLUGIN_ROOT}/skills/infra-audit/scripts/infra-audit.sh

# 출력 예시
{
  "area": "CLAUDE.md",
  "items": [
    {"id": "1-1", "status": "PASS", "detail": "글로벌 CLAUDE.md 존재 (523 단어)"},
    {"id": "1-2", "status": "WARN", "detail": "프로젝트 2/3에 CLAUDE.md 존재"}
  ]
}
```

### 커스텀 검사

infra-auditor 에이전트를 Task tool로 위임하여 정성 검사를 수행할 수 있다:

```
Task(subagent_type="infra-auditor", prompt="Skills 영역 심층 검사")
```

## 점수 계산 예시

```
CLAUDE.md: PASS 7개, WARN 1개
  = (7×10 + 1×5) / (8×10) × 100 = 93.75
  가중: 93.75 × 0.20 = 18.75

Hooks: PASS 8개
  = (8×10) / (8×10) × 100 = 100.00
  가중: 100.00 × 0.20 = 20.00

총점 = 18.75 + 20.00 + ... = N/100
```

## FAQ

**Q: 특정 항목이 프로젝트에 해당되지 않으면?**
A: N/A로 표시하고 해당 영역의 전체 항목 수에서 제외한다.

**Q: WARN과 FAIL의 차이는?**
A: WARN은 기능적이나 개선 필요 (5점), FAIL은 누락/에러 (0점).

**Q: 오탐(false positive)이 발생하면?**
A: 자동화 스크립트 결과를 정성 검사에서 보정한다. 예를 들어 훅 수가 정확히 경계값인 경우.

---

## 10단계 파이프라인 View (인사이트 1 매핑, 2026-05-25 P1-6 추가)

> 인프라 감사의 보편 원리를 인사이트 1(CLI LLM 하네스 10단계)과 매핑한 명시적 framing. 기존 본문 변경 없이 View만 추가. **infra-audit 가 대표 패턴** — 나머지 2개 (`universal-experience-audit`, `project-ultra-audit`) 는 P2에서 동일 패턴 적용.

### 인프라 감사 10단계 매핑

| Step | 인사이트 1 단계 | 본 스킬 매핑 | 산출물 |
|:-:|---|---|---|
| **1** | Input Normalizer | 감사 범위 정규화 — full / --quick / --focus=AREA | `{ scope, mode }` |
| **2** | Intent Classifier | 영역 7개 분류 (CLAUDE.md / Hooks / Skills / Rules / Scripts / Agents / MCP) | `{ areas[] }` |
| **3** | Task Router | 42개 검사 항목 분배 — 영역별 가중치 (20%/20%/20%/10%/15%/10%/5%) | `{ checks_per_area }` |
| **4** | Context Builder | 영역별 파일 수집 — Glob + Read 메타데이터 | `audit-data/*` |
| **5** | Planner | 검사 순서 + Phase 1(자동) / Phase 2(정성) / Phase 3(점수) 매트릭스 | `audit-plan.md` |
| **6** | Tool Executor | Phase 1: `infra-audit.sh` 실행 (JSON 출력) / Phase 2: Read/Grep 정성 검사 | `phase1.json` + `phase2.md` |
| **7** | Draft Generator | 각 항목 PASS(10) / WARN(5) / FAIL(0) 판정 → 영역별 raw 점수 | `raw-scores.json` |
| **8** | Critic / Verifier | 영역별_점수 = (PASS×10 + WARN×5) / (전체×10) × 100 / 가중치 적용 | `weighted-scores.json` |
| **9** | Refiner | 총점 계산 + 등급 (S/A/B/C/F) + 하니스 5축 매핑 (CE/AC/GC/EL/SI) | `verdict.md` |
| **10** | Output Renderer | 보고서 — 요약 / 영역별 점수 / 5축 기여도 / 상세 결과 / 권장 조치 | `INFRA-AUDIT-{date}.md` |

### 단계별 검증/분기

| Step | 검증 | 실패 분기 |
|:-:|---|---|
| 1 | scope 명확 | 불명확 → full 기본 |
| 2 | 7개 영역 모두 포함 (full 모드) | 누락 → 보강 |
| 3 | 42개 항목 분배 OK | 미달 → 체크리스트 재확인 |
| 4 | 파일 수집 0 에러 | 누락 파일 → 부분 결과 + 명시 |
| 5 | 검사 순서 의존성 정합 | 충돌 → 재정렬 |
| 6 | Phase 1 자동화 성공 | 실패 → Phase 2만 진행 (부분 점수) |
| 7 | 모든 항목 판정됨 | 누락 → 재실행 |
| 8 | 가중치 합 = 100% | 불일치 → 재계산 |
| 9 | 등급 일관 | 모순 → 재검토 |
| 10 | Markdown 보고서 + 7영역 점수 + 5축 매핑 | 누락 → 보강 |

### 인사이트 1 vs 본 스킬 — Confusion 방지

- 인사이트 1의 fast/normal/pro 모드 ↔ 본 스킬의 full / --quick / --focus 모드 — 다른 체계.
- 인사이트 1의 "한 모델 vs 다단계 호출" → 본 스킬은 **Phase 1 자동(스크립트) + Phase 2 정성(LLM) + Phase 3 점수** 3-Phase 다단계로 실현.

### 다른 감사 스킬과의 정합 (P1-6 패턴 확립)

본 스킬에 framing 추가 → **대표 패턴**. `universal-experience-audit` (245줄) 과 `project-ultra-audit` (184줄) 은 **P2 단계에서 동일 패턴 적용** 예정.

> **참조**: 인사이트 1 원문 — `.thoughts/2026-05-25-harness-insights-round1.md` / 라운드 3 합의안 — `.thoughts/2026-05-25-harness-insights-round2-round3.md`
