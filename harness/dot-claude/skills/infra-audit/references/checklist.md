# Infra Audit 체크리스트 — 42개 항목 상세

> 7개 영역 × 42개 검사 항목. 각 항목에 하니스 5축 태그가 부여됨.
> PASS(10점) / WARN(5점) / FAIL(0점)

---

## 1. CLAUDE.md (8항목, 가중치 20%)

| # | 항목 | 기준 | 검사 방법 | 하니스 축 |
|:-:|------|------|-----------|:---------:|
| 1-1 | 글로벌 CLAUDE.md 존재 | `~/.claude/CLAUDE.md` 파일 존재 | `ls` 확인 | CE |
| 1-2 | 줄 수 적정성 | 50-120줄 권장 (PASS), 30-150줄 (WARN), 범위 밖 (FAIL) | `wc -l` | CE |
| 1-3 | 필수 섹션 존재 | 언어, 사고 방식, 코드 작성, 커밋 메시지 섹션 포함 | Grep 키워드 | CE |
| 1-4 | rules/ 중복 없음 | CLAUDE.md 내용이 `~/.claude/rules/`와 겹치지 않음 | 내용 비교 | CE, GC |
| 1-5 | _core/ 참조 존재 | `_core/roles.md`, `_core/protocols.md` 참조 링크 포함 | Grep | CE |
| 1-6 | 프로젝트별 CLAUDE.md | 활성 프로젝트에 각각 CLAUDE.md 존재 | Glob 확인 | CE |
| 1-7 | Memory 섹션 | auto memory 활용 지침 포함 | Grep | CE, EL |
| 1-8 | CE 원칙 반영 | "최소 토큰", "최대 신호", "적정 고도" 등 CE 키워드 포함 | Grep | CE |

---

## 2. Hooks (8항목, 가중치 20%)

| # | 항목 | 기준 | 검사 방법 | 하니스 축 |
|:-:|------|------|-----------|:---------:|
| 2-1 | JSON 유효성 | `settings.local.json` 파싱 가능 | `python -m json.tool` | SI |
| 2-2 | 필수 이벤트 커버리지 | SessionStart, PreToolUse, PostToolUse, Stop 이벤트 존재 | 키 확인 | AC, SI |
| 2-3 | 참조 스크립트 존재 | command 필드의 스크립트 경로가 모두 실존 | `ls` 각 경로 | AC |
| 2-4 | 안전 훅 존재 | Bash PreToolUse에 파괴적 명령 감지 훅 존재 | Grep | AC, SI |
| 2-5 | prompt 훅 존재 | `type: "prompt"` 판단형 검증 훅 1개 이상 | Grep | AC, GC |
| 2-6 | timeout 설정 | command 훅에 timeout 설정 존재 (무한 대기 방지) | Grep | AC |
| 2-7 | 루프 방지 훅 | anti-loop-guard 또는 유사 루프 감지 훅 존재 | Grep | AC, EL |
| 2-8 | 훅 수 적정성 | 총 훅 수 5-15개 (PASS), 3-20개 (WARN), 범위 밖 (FAIL) | 카운트 | SI |

---

## 3. Skills (8항목, 가중치 20%)

| # | 항목 | 기준 | 검사 방법 | 하니스 축 |
|:-:|------|------|-----------|:---------:|
| 3-1 | SKILL.md 존재 | 모든 스킬 디렉토리에 SKILL.md 파일 존재 | Glob `skills/*/SKILL.md` | GC |
| 3-2 | YAML frontmatter | 필수 필드 존재: name, description | Grep 패턴 | GC |
| 3-3 | description 품질 | "This skill should be used when" + 트리거 문구 포함 | Grep | GC, CE |
| 3-4 | _core 참조 정합성 | 직접 제작 스킬이 `_core/` 참조 (roles.md, protocols.md) | Grep | CE |
| 3-5 | 파일 크기 적정성 | SKILL.md 본문 1,500-3,000 단어 (PASS), 1,000-5,000 (WARN) | `wc -w` | CE, GC |
| 3-6 | Progressive Disclosure | 상세 내용이 `references/`로 분리되어 있음 | Glob 하위 디렉토리 | CE |
| 3-7 | 참조 파일 존재 | SKILL.md에서 언급된 references/, scripts/ 파일이 실존 | 경로 추출 + `ls` | GC |
| 3-8 | _core SSoT 구조 | `_core/` 디렉토리에 roles.md, protocols.md 존재 | `ls` | CE, GC |

---

## 4. Rules (5항목, 가중치 10%)

| # | 항목 | 기준 | 검사 방법 | 하니스 축 |
|:-:|------|------|-----------|:---------:|
| 4-1 | 글로벌 rules 존재 | `~/.claude/rules/` 디렉토리에 .md 파일 1개 이상 | Glob | GC |
| 4-2 | 핵심 규칙 커버리지 | 환각 방지, 안전, 루프 방지 규칙 존재 | 파일명/내용 확인 | GC, EL |
| 4-3 | CLAUDE.md 중복 없음 | rules/ 내용이 CLAUDE.md에 그대로 중복되지 않음 | 내용 비교 | GC, CE |
| 4-4 | 파일 크기 적정성 | 각 규칙 파일 5-30줄 (PASS), 3-50줄 (WARN) | `wc -l` | GC |
| 4-5 | 프로젝트별 rules | 프로젝트 `.claude/rules/` 존재 여부 (선택적, 있으면 검사) | Glob | GC, EL |

---

## 5. Scripts (6항목, 가중치 15%)

| # | 항목 | 기준 | 검사 방법 | 하니스 축 |
|:-:|------|------|-----------|:---------:|
| 5-1 | 스크립트 존재 | `~/.claude/scripts/` 디렉토리에 스크립트 1개 이상 | Glob | AC |
| 5-2 | 문법 유효성 | Python: `py_compile`, JS: `node --check`, Bash: `bash -n` | 각 명령어 실행 | AC, EL |
| 5-3 | 훅 참조 정합성 | hooks에서 참조하는 스크립트가 모두 `scripts/`에 존재 | 경로 교차 확인 | AC, SI |
| 5-4 | 중복 스크립트 없음 | 동일 기능의 스크립트가 중복 존재하지 않음 | 파일명/내용 분석 | AC |
| 5-5 | 에러 핸들링 | 스크립트에 기본 에러 처리 존재 (exit code, try/except) | Grep 패턴 | AC, EL |
| 5-6 | GC/평가 스크립트 존재 | claude-gc.sh, harness-eval.js 등 유지보수 스크립트 존재 | `ls` 확인 | EL |

---

## 6. Agents (4항목, 가중치 10%)

| # | 항목 | 기준 | 검사 방법 | 하니스 축 |
|:-:|------|------|-----------|:---------:|
| 6-1 | 에이전트 정의 존재 | `~/.claude/agents/` 디렉토리에 .md 파일 1개 이상 | Glob | AC |
| 6-2 | YAML frontmatter | 필수 필드: name, description, tools | Grep 패턴 | AC, SI |
| 6-3 | description 품질 | 구체적 트리거 문구 포함 ("Use when asked to...") | Grep | AC, GC |
| 6-4 | 도구 적정성 | tools 목록이 에이전트 역할에 적합 (Read-only vs Full) | 내용 분석 | AC, SI |

---

## 7. MCP (3항목, 가중치 5%)

| # | 항목 | 기준 | 검사 방법 | 하니스 축 |
|:-:|------|------|-----------|:---------:|
| 7-1 | MCP 설정 존재 | `.mcp.json` 또는 MCP 관련 설정 파일 존재 | Glob | SI |
| 7-2 | JSON 유효성 | MCP 설정 파일 파싱 가능 | `python -m json.tool` | SI |
| 7-3 | 불필요 MCP 없음 | 미사용/비활성 MCP 서버가 등록되어 있지 않음 | 내용 분석 | SI |

---

## 하니스 5축별 항목 집계

| 축 | 약어 | 해당 항목 | 설명 |
|:--:|:----:|:---------:|------|
| Context Engineering | CE | 1-1~1-8, 3-3~3-6, 3-8, 4-3 | 컨텍스트 품질, 구조, 참조 체계 |
| Agentic Coding | AC | 2-2~2-7, 5-1~5-5, 6-1~6-4 | 훅 안전성, 스크립트 실행성, 에이전트 |
| Generation Control | GC | 1-4, 2-5, 3-1~3-3, 3-5, 3-7~3-8, 4-1~4-5, 6-3 | 스킬 트리거, 규칙 커버리지 |
| Evaluation Loop | EL | 1-7, 2-7, 4-2, 4-5, 5-2, 5-5~5-6 | 검증, 루프 방지, 자동화 |
| System Integration | SI | 2-1~2-2, 2-4, 2-8, 5-3, 6-2, 6-4, 7-1~7-3 | 훅 이벤트, MCP, 에이전트 도구 |

---

## 점수 산출 방법

### 영역별 점수

```
영역별_점수 = (PASS_수 × 10 + WARN_수 × 5) / (전체_항목_수 × 10) × 100
```

### 총점

```
총점 = Σ (영역별_점수 × 가중치)

예시:
  CLAUDE.md: 87.5 × 0.20 = 17.5
  Hooks:     90.0 × 0.20 = 18.0
  Skills:    75.0 × 0.20 = 15.0
  Rules:     80.0 × 0.10 =  8.0
  Scripts:   83.3 × 0.15 = 12.5
  Agents:    87.5 × 0.10 =  8.75
  MCP:       66.7 × 0.05 =  3.33
  ─────────────────────────
  총점:                    = 83.08 → B등급
```

### 하니스 축별 점수

```
축별_점수 = (해당 축 PASS 항목 수 / 해당 축 전체 항목 수) × 10.0
```

0.0-10.0 스케일. 8.0 이상이 양호.

### 등급 체계

| 점수 범위 | 등급 | 의미 |
|:---------:|:----:|------|
| 95-100 | S | 완벽한 인프라 |
| 85-94 | A | 우수 |
| 70-84 | B | 양호 |
| 50-69 | C | 기능적이나 문제 다수 |
| 0-49 | F | 긴급 수정 필요 |
