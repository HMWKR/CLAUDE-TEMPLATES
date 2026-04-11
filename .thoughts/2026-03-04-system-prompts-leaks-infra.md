---
date: 2026-03-04
commit: N/A (로컬 인프라 변경, 프로젝트 외부)
type: chore
subject: "system_prompts_leaks 분석 → _core/ 인프라 4개 항목 반영"
ce_strategies: [select, compress]
---

# system_prompts_leaks 분석 → _core/ 인프라 개선

## 1. 컨텍스트 수집 (Gather)

### 읽은 파일과 이유
| 파일 | 이유 | 유용했는가 |
|------|------|:----------:|
| asgeirtj/system_prompts_leaks (GitHub) | 경쟁사 시스템 프롬프트 인사이트 추출 | O — 6개 인사이트 |
| claude-code.md | Anthropic 공식 Claude Code 프롬프트 | O — 도구 호출 패턴 |
| claude-opus-4.6.md | Opus 4.6 시스템 프롬프트 | O — 예산 패턴 |
| codex-cli.md | OpenAI Codex CLI 프롬프트 | O — 샌드박스/예산 |
| gemini-cli.md | Google Gemini CLI 프롬프트 | O — No Self-Narration |
| gpt-5.md | OpenAI GPT-5 프롬프트 | O — Verbosity Level |
| claude.ai-injections.md | Claude.ai 조건부 주입 | O — 패턴 참조 |
| ~/.claude/skills/_core/roles.md | 기존 역할 정의 확인 | O — 매트릭스 삽입 위치 |
| ~/.claude/skills/_core/protocols.md | 기존 프로토콜 확인 | O — 예산/응답 효율 삽입 위치 |

### 사용한 도구
- WebFetch: GitHub 저장소 구조 파악
- Bash (gh api): 파일 목록 + 내용 다운로드
- Read: _core/ 기존 파일 확인

## 2. 정보 선택/폐기 (Select)

### 추출된 6개 인사이트
| # | 인사이트 | 출처 | 채택 |
|:-:|----------|------|:----:|
| 1 | Verbosity Level 정량화 (기본 3/10) | Codex CLI + GPT-5 | X — 사용자 선호와 비호환 |
| 2 | No Self-Narration 원칙 | Gemini CLI | **O** |
| 3 | 4단계 Sandbox 모델 | Codex CLI | X — 기존 safety.md 충분 |
| 4 | 도구 호출 예산 정량화 | Opus 4.6 | **O** |
| 5 | 조건부 주입 패턴 6종 | claude.ai-injections | X — 참조용, 인프라 반영 불필요 |
| 6 | 에이전트 도구 접근 격리 매트릭스 | Claude Cowork | **O** |
| 7 | 메모리 회상 메타 언급 금지 | GPT-5 패턴 | **O** |

### 폐기 근거
- Verbosity Level: 한국어 기술문서 스타일이 이미 간결성 보장
- 4단계 Sandbox: `~/.claude/rules/safety.md`의 3단계(설명→승인→실행)로 충분
- 조건부 주입: 방어가 아닌 공격 패턴 — 참조만 가치

### 컨텍스트 예산
- 수집(GitHub 탐색): ~40%
- 분석(인사이트 추출): ~35%
- 구현(3파일 수정): ~25%

## 3. 실패 모드 감지 (Detect)

| 실패 모드 | 감지 | 회피 전략 |
|----------|:----:|----------|
| Poisoning (오염) | X | — |
| Distraction (산만) | **O** | 6개 인사이트 중 4개만 선택, 나머지 폐기 |
| Confusion (혼란) | X | — |
| Clash (충돌) | X | 기존 _core/ 구조 유지, 추가만 수행 |

## 4. 대안 비교 및 결정 (Decide)

| 대안 | 장점 | 단점 | 채택 |
|------|------|------|:----:|
| 새 스킬로 제작 | 독립 관리 | 반복 사용 안 됨, 참조 자료일 뿐 | X |
| _core/에 직접 반영 | 전체 스킬에 자동 전파, 최소 변경 | 없음 | **O** |
| CLAUDE.md에 전부 추가 | 항상 로드 | 토큰 낭비, 적정 고도 위반 | X |

### 결정 근거
- 경쟁사 프롬프트는 일회성 참조 자료 → 스킬(반복 도구)로 부적합
- _core/는 Single Source of Truth → 여기 추가하면 모든 스킬이 자동 참조
- 총 ~26줄 추가로 CE 예산 내 (roles.md +12, protocols.md +18, CLAUDE.md +1)

## 5. 적용된 CE 전략

- [x] Select: 6개 인사이트 중 실질 가치 4개만 선별
- [x] Compress: 각 인사이트를 표/불릿 형태로 최소 줄수 반영

## 6. 변경 내역

| 파일 | 변경 | 줄수 |
|------|------|:----:|
| `~/.claude/skills/_core/roles.md` | 서브에이전트 도구 접근 매트릭스 추가 | +12 |
| `~/.claude/skills/_core/protocols.md` | 도구 호출 예산 + No Self-Narration | +18 |
| `~/.claude/CLAUDE.md` | 메모리 회상 메타 언급 금지 1줄 | +1 |

## 7. 핵심 통찰

> **경쟁사 시스템 프롬프트의 가치는 "새로운 스킬"이 아니라 "기존 인프라의 빈 칸 채우기"에 있다.** 도구 예산, 응답 효율, 에이전트 격리는 이미 암묵적으로 적용되고 있었으나 명시적 정량화가 없었다.
> **"명시하지 않으면 일관되지 않는다"** — Gemini의 No Self-Narration, Opus의 도구 예산은 모두 암묵적 행동을 명문화한 것.

---
*수동 생성: 2026-03-04 | 대상: ~/.claude/ 로컬 인프라*
