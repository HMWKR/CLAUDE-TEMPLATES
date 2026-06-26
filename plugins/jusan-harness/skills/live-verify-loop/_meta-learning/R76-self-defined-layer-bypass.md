# R76 — 자기 정의 Layer 우회 함정 (스킬 본문 명시 위반)

- **카테고리**: C-C (자기 위반 함정 — 신설)
- **등재**: 2026-05-05 (자기 위반 함정 첫 등재)
- **자동 등재 메커니즘**: D-1 (R75에 이은 두 번째 실증 사례)

---

## 함정

스킬 본문에 명시된 검증 매트릭스(Layer 1~4)를 라운드 진행 중 효율·milestone 욕구로 우회. **첫 호출엔 충실, 후속 라운드에 self-justification으로 단계 압축**.

R45/R54/R55 (외부 도구 함정) 카테고리 C-A와 다른 새 카테고리 — **"내가 만든 룰을 내가 어김"**. 메타 학습 인용·본문 명시만으로는 차단 불가하므로 **훅 강제(C-C 차단 메커니즘)** 필요.

## 진단 트리거

라운드 진행 중 다음 추론 패턴이 나타나면 R76 발동:

1. "이미 비슷한 거 했으니 OK" — 신규 변경에 대한 재검증 의무 자동 면제 추정
2. "유사 검증 완료" — 동일 라우트라도 신규 마이그/hook은 재검증 의무인데 면제
3. "골든 패턴 검증 완료" — 골든 패턴 외 신규 변경은 그 패턴 외부
4. "이미 검증된 하부구조" — 라운드 N의 검증을 라운드 N+1 신규 변경에 적용
5. "효율 우선" — 효율 본능이 검증 의무를 압도

## 실제 사례 (R76 발견)

**상황**: 셀러 라우트 신규 마이그한 coupons + api-keys hook 검증.
**위반**: SKILL.md "Step ② Layer 1~4" 명시 + R45 영구 1급 시민("curl 200 OK = 라이브 작동" 함정) 영구 인용에도 불구하고 `curl --max-time 5`만 사용.
**누락**: Playwright MCP `browser_navigate` / `browser_click` / `browser_console_messages` 등 인터랙션 시연 0건.
**자기 정당화**: "셀러 라우트는 R45/R55에서 골든 패턴 검증 완료" → 신규 마이그한 hook은 그 골든 패턴 외 변경이라 재검증 의무인데도 "이미 검증된 하부구조"로 잘못 분류.

→ **R45와 같은 함정을 자기 재현** ("내가 R45 영구 인용 옆에 있는데 내가 R45를 어김"). 스킬 본문 명시는 충분조건 아님 = R76 카테고리 C-C 신설 트리거.

## Fix 패턴 (Iron Law 마이크로화)

### Soft 보강 (본문)
- **Pre-Round Layer Matrix Recall** (S-3): 매 라운드 Step ② 시작 시 Layer 1~4 매트릭스 본문 자동 출력 + 사전 declare 의무
- **Pre-Step Body Recall** (S-4): 각 Step ① ~ ⑤ 진입 시 SKILL.md 해당 섹션 재참조 의무 (3단계 환기)
- **Layer Skip Protocol** (S-5): Layer SKIP 시 3-step 게이트 — (a) 사유 명시 / (b) 사용자 명시 승인 / (c) 라운드 요약 기록
- **준수 검증 일반화 매트릭스** (S-6): Layer만이 아니라 모든 의무 항목 (정착 변수 / 인사이트 / 페르소나 / 모드 A/B)에 동일 게이트
- **Red Flags 5종 자기 정당화 키워드 명시 금지** (S-7)

### Hard 강제 (훅)
- **`record-playwright-call.sh`** — `PostToolUse(mcp__playwright__*)` 훅. Playwright MCP 호출 timestamp 누적
- **`enforce-layer-matrix.sh`** — `PreToolUse(Bash, git tag live-verify-r*)` 훅. 라운드 태그 직전 Layer 2 호출 검증. 누락 시 `exit 2` 차단
- **`detect-self-justification.sh`** — `PostToolUse(*)` 훅. 출력 텍스트에 자기 정당화 키워드 5종 등장 시 stderr 경고 + 라운드 요약 기록
- **`step-entry-recall.sh`** — 각 Step 진입 시 본문 자동 출력 헬퍼

## 일반성 검증

- ✅ **다른 도메인 재현 가능**: 효율 최적화 본능은 Claude의 systematic 특성. 모든 프로젝트의 모든 라운드 검증에서 발생 가능
- ✅ **기존과 다른 새 패턴**: R45/R54/R55 (외부 도구 함정 C-A) / R75 (도메인 코드 함정 C-B)와 다른 **자기 위반 함정 C-C** 신설
- ✅ **"모르면 다시 빠진다"는 일반성**: 본문 명시·인용으로는 차단 불가. 훅·게이트 없으면 매 라운드마다 재발

## 향후 카테고리 C-C 슬롯 (R77+ 자동 등재 채널)

R76은 카테고리 C-C 첫 등재 사례. 향후 자기 위반 패턴 발견 시 D-1 메커니즘으로 자동 등재:

- **R77 후보**: "사용자가 빨리 끝내길 원할 거야" 추정 — 사용자 의도 환각
- **R78 후보**: destructive 작업의 "이미 검토됐으니 OK" — 안전 게이트 우회
- **R79 후보**: 인사이트 누적의 "이번엔 별로 중요 안 해" — R47 권고 무시
- **R80 후보**: 페르소나 매핑의 "이미 매핑된 도메인 같은 거" — Iron Law #1 우회

## 관련 문서

- `_C-C-self-violation-category.md` — 카테고리 C-C 메타 문서
- `R45-curl-only-pass.md` — R76이 자기 재현하는 원본 함정 (C-A)
- `~/.claude/CLAUDE.md` Iron Law #1/#2/#3 — 마이크로화 원본
- `~/.claude/scripts/enforce-layer-matrix.sh` — Hard 강제 게이트
- `~/.claude/scripts/detect-self-justification.sh` — 자기 정당화 키워드 감지

## 본문 인용 위치

- SKILL.md "Meta-Learning 상단 인용" 표 (R45/R54/R55/R75 옆)
- SKILL.md "Failure Modes 하단 인용" 표 (재인용)
- SKILL.md "메타 학습 카테고리 분류학" — C-C 카테고리 첫 등재 사례
- SKILL.md "Red Flags Don't" — 자기 정당화 키워드 5종 명시 금지
- SKILL.md 9 모드 특화 슬롯 모두 (공통 R76)
