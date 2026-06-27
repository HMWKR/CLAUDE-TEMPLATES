# Structural Loop Runner — 결정론적 루프 제어 (control plane = 스크립트, not 스킬 프로세)

> **궁극형 루프 하네스**: 루프의 제어(반복·종료·예산·정체감지)를 스킬 본문(모델이 "지켜야 하는" 프로세)에서 빼내 **결정론적 스크립트로 강제**한다. 모델은 payload(작업·방법론)만 담당. 모델이 루프를 건너뛰거나 자기 정당화로 조기 종료할 수 없다 — 루프가 모델의 일이 아니라 하네스의 일이기 때문.
>
> 근거: 루프 하네스 전수조사(적대검증 24/25 confirmed, 2026-06). 출처는 §근거 참조.

## 왜 스킬이 아니라 구조인가
- `live-verify-loop`가 R76·`detect-self-justification.sh`로 "모델이 자기 루프 프로세를 안 지킴"과 싸우는 것 자체가 프로세-기반 루프의 약점.
- 검증된 베스트프랙티스는 전부 **구조적**: Ralph=bash `while` / claude-loop=Stop훅 / OpenHands=`run_goal` judge 게이트 / frankbria=서킷브레이커 스크립트.
- Microsoft Agentic Failure Taxonomy: "모델 자율이 아니라 **결정론적 control-flow로 제약**하라."

## 분리 원칙
| 평면 | 담당 | 위치 |
|---|---|---|
| **Control plane** (반복·종료게이트·예산·정체·재투입) | 결정론적 스크립트 | `loop.sh` / `loop.ps1` (이 디렉토리) |
| **Payload** (무엇을 할지·검수 방법론·9모드·메타학습) | 스킬/프롬프트 | `prompt.md` + `live-verify-loop`/`harness-loop` 스킬 |
| **State / memory** (계획·진척·러닝) | 디스크 파일 | `.harness-loop/{plan.md,status.json,progress.log}` |

## 검증된 안전 게이트 (스크립트가 강제)
1. **Deterministic backpressure**(Ralph 3-0): 이터마다 `gate.sh`(tests/typecheck/lint/build) **exit 0** 필수. LLM 자기선언으로 진행 불가.
2. **Dual-condition exit**(frankbria 3-0): 완료 = 휴리스틱 완료지표 **AND** `status.json`의 `exit_signal:true` **AND** gate exit 0. 셋 다 충족해야 종료.
3. **Circuit-breaker stagnation**(frankbria 3-0): 무진척(git diff 0) 3회 OR 동일 에러 5회 → OPEN(정지) → cooldown 후 HALF_OPEN 재시도.
4. **Budget**(frankbria 3-0): 시간당 호출 상한(기본 100/h) + 누적 호출 상한 + 선택 토큰 상한. (frankbria는 iteration cap 대신 rate-limit 사용 — 그대로 채택.)
5. **Fresh-context per iteration**(Ralph 3-0): 매 이터 새 `claude -p` 프로세스 = 새 컨텍스트. 상태는 `.harness-loop/` 디스크로만 인계 → 컨텍스트 오염 누적 차단.
6. **Objective completion criterion**(LoopTrap 3-0 함의): 퍼지 목표("until done")는 Termination-Poisoning 최고위험. 종료는 **객관 검증 가능한 gate.sh** 에 바인딩(주관 LLM-judge 단독 금지).

## 사용
```bash
# 1) 작업 폴더에서 초기화 (.harness-loop/ 생성: prompt.md, plan.md, gate.sh 스텁)
bash harness/loop-runner/loop.sh --init

# 2) prompt.md(작업 지시) + plan.md([ ] 체크박스 백로그) + gate.sh(검증 명령) 작성

# 3) 실행 — plan 소진 + gate 0 + exit_signal 까지 결정론적 반복
bash harness/loop-runner/loop.sh --run --max-calls-per-hour 100 --cooldown 30
#   Windows:  pwsh harness/loop-runner/loop.ps1 -Run
```

## .harness-loop/ 상태 스키마
- `prompt.md` — 매 이터 `claude -p`에 투입되는 고정 지시(payload). "plan.md에서 가장 중요한 미완 1건만 구현 → plan 갱신 → commit → 완료 시 status.json에 exit_signal".
- `plan.md` — `[ ]`/`[x]` 백로그(디스크 메모리). 미완 0건 = plan 소진.
- `gate.sh` — 결정론적 backpressure(프로젝트별: `npm test && tsc --noEmit && npm run lint`). exit 0 = 통과.
- `status.json` — `{iteration, exit_signal, last_error_sig, no_progress_count, same_error_count, breaker_state, calls_this_hour}`.
- `progress.log` — append-only 이터별 결과(감사 추적).

## 기존 자산과의 관계
- `/loop`·`ScheduleWakeup` = 페이싱(외부). 이 러너 = **제어 게이트의 결정론적 강제**(내부). 병용 가능.
- `ralph-loop` 플러그인(Stop훅) = 인-세션 재투입. 이 러너 = 외부 프로세스 fresh-context. 용도 분리.
- `live-verify-loop`/`harness-loop` 스킬 = 이 러너의 `prompt.md` payload(방법론)로 호출 가능 — 스킬은 "무엇을", 러너는 "반복·종료·예산"을 담당.

## 근거 (적대검증 출처)
- Ralph: `ghuntley.com/ralph`, `github.com/ghuntley/how-to-ralph-wiggum` (3-0)
- frankbria/ralph-claude-code: dual-exit + circuit-breaker(3/5/30min) + rate(100/h) (3-0)
- OpenHands SDK `run_goal` evidence-gate + condenser: `github.com/OpenHands/software-agent-sdk` (3-0)
- sour4bh/claude-loop: Stop-hook 구동 (3-0)
- LoopTrap / Termination Poisoning: `arxiv.org/abs/2605.05846` (3-0, medium — 단일 preprint)
- mini-swe-agent ~100줄 >74% SWE-bench: 과설계 금지 (3-0)
- **반증**: "Ralph 170k 토큰 예산" 통념 → 적대검증 기각(1-2). 채택 안 함.
