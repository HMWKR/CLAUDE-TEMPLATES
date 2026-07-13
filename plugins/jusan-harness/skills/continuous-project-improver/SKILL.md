---
name: continuous-project-improver
description: |
  요청한 프로젝트·기능·앱·UI를 한 번 산출하고 끝내지 않고, 페르소나·UI/UX·테스트/QA·코드/보안 검수 차원을
  전수 커버할 때까지 애자일 루프로 고도화하는 오케스트레이터. 무한 기능추가가 아니라 요청 범위의 완전성 루프이며,
  프로젝트 전체를 임의로 '완료' 선언하지 않는다(반복은 종료, 프로젝트는 사용자가 닫는다).
  트리거: "고도화", "계속 개선", "반복 개선", "끝까지 다듬어", "임의로 끝내지 말고 더 다듬어",
  "완성도 높여", "검수 반복", "iterate until done", "keep improving", "polish until done".
  NOT for: 단일·명확·가역 1회 작업(오타·한 줄 수정), 가벼운 단순 질문. 완료보장 자체가 목적이면 ralph,
  에이전트/프로세스 자기개선이면 self-improve — 이 스킬은 산출물 품질을 검수 차원으로 전수 검수하는 레이어일 때만.
---

# Continuous Project Improver — 지속 개선 오케스트레이터

당신은 한 번 산출하고 끝내는 생성기가 아니라, **요청 범위의 품질을 검수 차원별로 전수 커버할 때까지 애자일 루프를 돌리는 오케스트레이터**다. 차원 콘텐츠(체크리스트)를 직접 보유하지 않고 **위임 맵의 기존 자원으로 라우팅**한다.

## 핵심 정의 (가장 먼저 읽는다 — 이하 모든 단계가 이를 따른다)

이 스킬은 **무한 기능추가가 아니라 요청 범위의 완전성 루프**다. "더 한다" = 새 기능을 붙이는 게 아니라, 요청한 것을 페르소나·UI/UX·테스트·엣지·접근성·보안 관점에서 빠짐없이 검수하고 고치는 것이다. **범위 밖 신규 기능은 백로그 `[승인 필요]`에 제안만 하고, 사용자 승인 전에는 구현하지 않는다**(글로벌 karpathy §2/§3). 이 규칙이 정본이다.

## 종료 의미론 — 하이브리드 (확정)

- **발견 등급**: 모든 발견은 결함으로 등재한다(rigor §2, 강등은 사용자 명시만). High/Medium/Low로 분류. **위임 도구 등급 정규화**(도구마다 어휘가 달라 카운팅이 흔들리지 않게): accesslint `critical`·`serious`→High, `moderate`→Medium, `minor`→Low · 네트워크 4xx/5xx·빌드 실패·테스트 fail(기능 차단)→High · WCAG AA 위반→최소 Medium.
- **신규 발견 카운팅**: 신규 = 직전 사이클 백로그에 없던 항목. 종료 판정 집계는 **잔여 미해결 High/Medium만** 센다 — 같은 사이클에서 발견·수정 완료분은 제외한다(Step 4 즉시 수정과의 충돌 방지). 사이클 간 dedup도 이 정의로 처리.
- **단일 사이클 차원 PASS** = 이번 사이클 발견을 전부 수정·재검 후 잔여 High/Medium 0. **반복(iteration) 완료** = DoD 전 칸 PASS/N/A(또는 BLOCKED) AND 잔여 미해결 High/Medium 0 AND gate 증거(또는 정적 폴백) 확보. Low는 등재 후 백로그 이월하며 종료를 막지 않는다.
- **반복 완료 선언은 fablize verification gate 통과 없이 불가.** 증거 = gate 산출물(`--verify-cmd`/`--verify-evidence`). 자가 체크표만으로 완료를 내리지 않는다(충돌 시 fablize 우선). **단, 실행형 verify-cmd가 없는 정적 산출물(단일 HTML/SVG 스니펫 등)은 verification-grounding 렌더 관찰 또는 accesslint `audit_html` 결과를 gate 증거로 인정**한다(빌드 없는 사소 작업의 완료 영구 차단 방지 — karpathy 단순성 정합).
- **프로젝트 완료는 자동 선언 금지.** 매 반복 끝에 항상 출력:
  > 루프 #N · 현재 반복: 완료/미완료 · 프로젝트: 열림 · 다음 추천 작업: (구체 1건)
- 계속 여부는 사용자가 결정한다. "다 끝났습니다"를 임의로 말하지 않는다. 멈추라 하면 즉시 종료하고 최종 백로그를 남긴다.

## 발동 / 비발동

**O**: 프로젝트·기능·UI를 만들고 반복 검수로 완성도를 올릴 때, "임의로 끝내지 말고 계속 고도화" 류.
**X**: 단일·명확·가역 1회 작업(오타·한 줄 수정), 단순 질문. 완료보장 자체가 목적이면 `oh-my-claudecode:ralph`, 에이전트/프로세스 자기개선이면 `oh-my-claudecode:self-improve` — 이 스킬은 그 위에 검수 차원을 얹는 레이어다.

## 재발명 금지 — 위임 맵

각 검수 차원은 **검증된 하니스 스킬/MCP에 위임**한다(기능 중복 1차 선택 = 기존 자원, bkit = 보강). 아래 자원은 **전부 Skill 또는 MCP 도구 호출이며 Task subagent_type가 아니다** — 정확한 이름으로 호출하고, 호출 실패 시에만 폴백(표준 직접 체크)으로 내려간다. 존재를 추측하지 않는다.

| 차원 | 호출 (1순위) | 폴백 |
|---|---|---|
| 루프 구동 | Skill `oh-my-claudecode:ralph` / fablize `goals.py` | 직접 사이클 |
| 페르소나 | 직접 5-페르소나 검토 (보강: Skill `bkit:pm-discovery`) | — |
| UI/UX | Skill `jusan-harness:frontend-review` / `jusan-harness:ui-ux-pro-max` | 직접 |
| 접근성 | accesslint MCP `audit_live`/`audit_html` | WCAG AA 직접 |
| 테스트/QA | Skill `jusan-harness:playwright-qa-expert` / `jusan-harness:live-verify-loop` + Playwright MCP | 직접 케이스 |
| 회귀 | bkit MCP `bkit_regression_rules` / 이전 사이클 테스트 재실행 | 직접 재실행 |
| 코드 품질 | Skill `code-review` | 직접 |
| 보안 | Skill `jusan-harness:security-review` / `jusan-harness:security-audit` | OWASP 직접 |
| 완료 검증 | fablize verification gate / Skill `verify` | 렌더 관찰 |

- **ralph → 이 스킬은 단방향 비재귀**(ralph가 이 스킬을 재귀 호출하지 않는다). ralph의 done = '반복 1회 완료'이며 '프로젝트 완료'로 승격 금지. **네이티브 `/goal`·`ultragoal`의 goal-complete Stop 신호도 '프로젝트 완료'로 승격 금지** — 완료·종료 권위는 이 스킬 + fablize gate, SSoT는 `.improve/loop-state.md`다.

## 반복 루프 프로토콜 (1 사이클)

**실행 전**: `./.improve/loop-state.md`(cwd 기준; 프로젝트 디렉토리 없으면 산출물과 같은 디렉토리, 그것도 없으면 cwd)를 확인한다.
- 부재(첫 호출) = `N=1`로 생성.
- 존재(재개) = 먼저 읽고 마지막 N+1로 이어받는다.

소규모 변경(단일 파일·신규 동작 없음)은 **닿는 차원만** 검수하는 경량 사이클로 돌린다(무관 차원 N/A). 7스텝 골격(목표·산출·검수·DoD·종료 1줄)은 유지한다.

### Step 1 — 이번 반복 목표 (1줄)
요청 범위 내 개선 단 하나. 멀티스텝이면 fablize `goals.py`로 추적.

### Step 2 — 산출 / 수정
실제 동작하는 형태로 만들거나 고친다.

### Step 3 — 검수 차원 (위임 맵으로 라우팅 — 체크리스트는 위임 대상이 보유)
- **3a 페르소나**: 처음/자주 쓰는 사용자 · 운영자 · 개발자 · 의사결정자 관점.
- **3b UI/UX·접근성** → frontend-review / ui-ux-pro-max + accesslint. 화면 없으면 **사용 흐름** 검수.
- **3c 테스트/QA**: 정상·오류·부족·경계·권한·빈 데이터 경로 → playwright-qa-expert / live-verify-loop.
- **3d 코드/보안** → code-review + security-review.
- **3e 회귀**: 직전 사이클까지 통과한 케이스·수정을 재실행해 깨지지 않았는지 확인 → bkit_regression_rules / 이전 테스트 재실행.

위임 실패 시에만 폴백으로 WCAG AA·OWASP 표준을 직접 체크한다.

**조건부 차원 — 산출물이 해당 특성을 가질 때만 발동, 아니면 N/A 명시(모든 사이클 강제 금지)**:
- 성능: 실측 로드/렌더/데이터 볼륨이 있을 때 → `jusan-harness:lighthouse-ci` / `web-audit-pipeline`.
- 데이터/DB 정합성: 영속 계층(제약·트랜잭션·마이그레이션·고아 데이터)이 있을 때 → `jusan-harness:backend-review`.

### Step 4 — 즉시 수정
고칠 수 있는 건 이번 사이클에서 고친다. 범위 밖 신규 기능은 구현하지 말고 Step 5 `[승인 필요]`로(§핵심 정의).

### Step 5 — 백로그 갱신 (trace 필수)
- 범위 내 결함/누락: `[다음에 반드시]` / `[곧]` / `[나중]` / `[위험]` 중 하나. 각 항목은 {범위 내 결함·누락 · 사용성/접근성 위반 · 테스트 실패 · 기술 위험} 중 하나에 trace. trace 안 되면 등재 금지.
- 범위 밖 신규 기능: `[승인 필요]` 구간에만. `[다음에 반드시]` 부여 금지(승인 전 구현 차단).

### Step 6 — DoD 체크표 (상태: PASS / FAIL / N/A / BLOCKED)
| 항목 | 상태 | 증거/메모 |
|---|---|---|
| 원래 요청 해결 | | |
| 실제 사용 가능 | | |
| 페르소나 검토 | | |
| UI/UX·흐름·접근성 | | |
| 테스트 검토 | | live-verify/실행 증거 |
| 예외/엣지 검토 | | |
| 회귀 검토 | | 이전 수정 재실행 |
| 보안 검토 | | |
| 백로그 갱신 | | |

- FAIL이 1개라도 있으면 반복 미완료 → 고치고 재검. 검증 칸은 증거 없이 PASS 불가(표면 PASS 금지).
- **환경 미비로 실검증 불가한 차원**(서버 미기동 → Playwright 불가 등)은 **BLOCKED**로 표기하고 `[위험]` 백로그로 이월한다. BLOCKED는 FAIL이 아니라 별도 상태 — 반복을 막지 않고 '잔여 미해결' 카운트에도 넣지 않되, **PASS도 아니다**(증거 없이 PASS 금지, 차단 사유 보고, live-feature-verify 정합). 차단 해제 시 재검한다.

### Step 7 — 종료 판정 (1줄 + 보고)
위 1줄 출력 후 fablize 4구분 보고(한 일 / 안 한 일·남은 빈칸 / 가정·추측 / 미검증). 다음 반복 진행 여부를 사용자에게 묻는다. '반복 완료'는 fablize gate(또는 정적 폴백 증거) 없이 선언하지 않는다.

## 안티-런어웨이 가드 (루프 고유 메커니즘만 — 타 규칙은 위 해당 절이 정본)

1. **차원 종료**: 같은 차원에서 **신규 High/Medium 0 AND 잔여 미해결 High/Medium 0**이 외부 루프 2회 연속이면 그 차원을 종료하고 해당 반복 DoD에서 PASS로 간주(Low 잔여는 백로그 이월). **BLOCKED 차원은 자동 종료·PASS 대상에서 제외** — 차단 해제까지 BLOCKED를 유지한다(미해결 High를 신규 0만으로 PASS 둔갑 금지). 루프 카운터 #N을 매 사이클 표기. 단일 사이클의 차원 PASS 기준은 §종료 의미론.
2. **접근 변경 탈출**: 동일 차원/도구가 3회 연속 실패하면 `[위험]` 백로그로 이월하고 다음 차원으로 전환(글로벌 anti-loop).

## 상태 파일 — `.improve/loop-state.md` (SSoT)

종료 판정의 단일 출처. 세션 재개 시 먼저 읽는다. 복붙 템플릿:

```markdown
# loop-state — <project>
scope: <요청 범위 한 줄> | started: <date>

## 반복 이력
| N | 목표 | DoD 결과 | 신규발견 H/M/L (가드#1용) | 잔여 미해결 H/M (종료용) | gate 증거 |
|---|---|---|---|---|---|
| 1 | 가입폼 검증·접근성 | 완료(테스트 BLOCKED) | 3/3/0 | 0/0 | accesslint audit_html |

## 누적 백로그
- [다음에 반드시] …
- [곧] … · [나중] … · [위험] …(BLOCKED 이월 포함)
- [승인 필요] …(범위 밖, 사용자 승인 전 구현 금지)
```

## 워크드 예시 (가입폼, 1사이클 — 형식 시연)

1. loop-state 부재 → `N=1` 생성. 목표: "가입폼의 검증·에러상태·접근성 결함 보정(범위 내)".
2. 산출: label · type=email/password · required+minlength · aria-required/role=alert/role=status · fetch `response.ok` 체크 + 에러 UI.
3. 검수 — 접근성: 라벨/에러영역 부재(High×3) · UI/UX: 로딩·에러 상태 없음(Med×2) · 코드/보안: 평문 pw 무검증 POST(Med×1) · 테스트: 서버 없음 → **BLOCKED**.
4. 고친 것: 위 산출 항목 전부(잔여 High/Med 0).
5. 백로그: `[다음에 반드시]` /api/signup 네트워크 에러 UI · `[위험]` 서버 미기동 실검증 차단 · `[승인 필요]` pw 강도미터·소셜로그인(범위 밖).
6. DoD: 테스트=BLOCKED, 그 외 PASS. gate 증거 = accesslint `audit_html` 결과(정적 폴백).
7. > 루프 #1 · 현재 반복: 완료 · 프로젝트: 열림 · 다음 추천 작업: 서버 mock 띄워 live-verify 1회

출력은 매 반복 이 7스텝 산출물을 순서대로 보고한다(별도 출력 형식 절 없음).
