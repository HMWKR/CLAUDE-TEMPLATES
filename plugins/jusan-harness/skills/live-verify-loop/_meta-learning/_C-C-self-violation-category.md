# 카테고리 C-C — 자기 위반 함정 (Self-Violation Trap)

- **신설**: 2026-05-05 (R76 첫 등재 사례 발견 직후)
- **위치**: 메타 학습 카테고리 분류학 3번째 카테고리 (C-A 외부 도구 / C-B 도메인 코드 / **C-C 자기 위반**)
- **상위 참조**: `~/.claude/CLAUDE.md` Iron Law (글로벌 강제 패턴) — C-C는 그 마이크로화

---

## 정의

**"내가 만든 룰을 내가 어기는"** 함정. 스킬 본문 명시·메타 학습 인용에도 불구하고 라운드 진행 중 효율 최적화 본능·milestone 도달 욕구·자기 정당화 추론으로 명시 의무를 우회하는 패턴.

C-A (외부 도구 함정)는 *타인이 만든 도구·환경*에 속는 것이고, C-B (도메인 코드 함정)는 *코드 패턴*의 함정이다. **C-C는 자기 자신의 룰을 자기가 어기는 카테고리** — 가장 위험하다. 명시·인용으로는 차단 불가.

## 차단 메커니즘 (Iron Law 마이크로화)

C-C 카테고리는 **본문 명시 + 훅 강제** 양면 필요:

### Soft (본문 명시 — 1차 방어선)
1. **Pre-Round Layer Matrix Recall** (S-3) — 매 라운드 Step ② 시작 시 본문 자동 환기
2. **Pre-Step Body Recall** (S-4) — 각 Step 진입 시 본문 재참조 (3단계 환기: 호출 + 라운드 + Step)
3. **Layer Skip Protocol** (S-5) — 3-step 게이트 (사유 / 승인 / 기록)
4. **준수 검증 일반화 매트릭스** (S-6) — 모든 의무 항목에 동일 게이트
5. **Red Flags 5종 자기 정당화 키워드 명시 금지** (S-7)

### Hard (훅 강제 — 2차 방어선)
1. **`record-playwright-call.sh`** — Playwright MCP 호출 timestamp 누적 (PostToolUse 훅)
2. **`enforce-layer-matrix.sh`** — 라운드 태그 직전 Layer 2 호출 검증, 누락 시 `exit 2` 차단 (PreToolUse 훅)
3. **`detect-self-justification.sh`** — 자기 정당화 키워드 5종 출력 텍스트 감지 + stderr 경고 (PostToolUse 훅)
4. **`step-entry-recall.sh`** — 각 Step 본문 자동 출력 헬퍼

## 등재 기준 (D-1 메커니즘)

새 자기 위반 패턴 발견 시 C-C 카테고리 등재 기준:

| # | 기준 | 검증 |
|---|---|---|
| (a) | 다른 도메인 재현 가능 | 효율 본능은 systematic — 모든 프로젝트에서 발생 가능해야 |
| (b) | 기존 R45~R55 / R75 / R76과 다른 새 패턴 | 동일 함정 재발견 X, 새 자기 위반 형태 |
| (c) | "모르면 다시 빠진다"는 일반성 | 명시·인용으로 차단 불가, 훅·게이트 필요 |
| (d) | **C-C 추가 기준**: 본문 명시·인용에도 불구하고 발생 | 외부 도구 함정과 구분 |

## 등재 사례

| 코드 | 제목 | 등재일 | 본문 인용 |
|---|---|---|---|
| **R76** | 자기 정의 Layer 우회 (스킬 본문 명시 위반) | 2026-05-05 | `R76-self-defined-layer-bypass.md` |

## 향후 등재 채널 (R77+ 자동 슬롯)

D-1 메커니즘으로 자동 등재 가능한 후보 패턴 (예측):

| 슬롯 | 후보 함정 | 의무 항목 | 차단 메커니즘 |
|---|---|---|---|
| **R77** | "사용자가 빨리 끝내길 원할 거야" — 사용자 의도 환각 | 정착 7변수 declare | enforce-step-7-vars.sh (TBD) |
| **R78** | destructive 작업의 "이미 검토됐으니 OK" | safety.md 의무 | enforce-destructive-gate.sh (TBD) |
| **R79** | 인사이트 누적의 "이번엔 별로 중요 안 해" | R47 권고 | check-stale-insights.sh (기존) 강화 |
| **R80** | 페르소나 매핑의 "이미 매핑된 도메인 같은 거" | Iron Law #1 | record-agent-mapping.sh (기존) |
| **R81+** | (사용 중 발견 시 자동 등재) | 모든 의무 항목 | 의무 항목별 enforce-*.sh 추가 |

## 자기 정당화 키워드 5종 (R76 발견 직후)

본 카테고리 발동 트리거. 출력 텍스트에 등장 시 `detect-self-justification.sh` 훅이 stderr 경고:

1. "이미 비슷한 거 했으니 OK"
2. "유사 검증 완료"
3. "골든 패턴 검증 완료"
4. "이미 검증된 하부구조"
5. "효율 우선"

이런 추론이 떠오를 때 **즉시 정지** + 본문 재참조 + 3-step 게이트 의무.

## 메타 메타 — 본 카테고리 자체에 대한 메타 학습

본 C-C 카테고리 신설 자체가 **메타-메타 학습**: live-verify-loop의 D-1 (메타 학습 자동 누적) 메커니즘이 자기 자신을 진화시킨 evidence. R75 (C-B 첫 사례)에 이어 R76 (C-C 첫 사례)을 자동 등재하면서 **메타 학습 누적이 단발이 아닌 시스템임을 증명**.

향후 자기 위반 패턴 발견 시 동일 메커니즘으로 R77+ 자동 등재 → C-C 카테고리는 **살아있는 자산**.

## 관련 문서

- `R76-self-defined-layer-bypass.md` — C-C 첫 등재 사례
- `~/.claude/CLAUDE.md` Iron Law — 글로벌 강제 (마이크로화 원본)
- `~/.claude/skills/live-verify-loop/SKILL.md` "메타 학습 카테고리 분류학" 절
- `~/.claude/scripts/enforce-layer-matrix.sh` / `detect-self-justification.sh` / `step-entry-recall.sh` / `record-playwright-call.sh` — Hard 강제 4종
