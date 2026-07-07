# 실동작 검증 게이트 (Live Feature Verify) — feature 완료 정의

> 프론트/백엔드 **기능 구현**의 "완료"는 코드 작성·요소 존재가 아니라 **Playwright MCP로 실제 동작이 검증된 상태**다. 표면 PASS·임의 PASS 금지. (근거: live-verify-loop 메타학습 R54 code≠live, R77 surface≠functional, R55 playwright-test가 아니라 MCP로 직접.)

## 발동 트리거
- UI 컴포넌트·버튼·폼·모달·라우팅·상태변경 구현/수정
- API·엔드포인트·서버 핸들러·DB 연동 기능 구현/수정
- "완료"·"다음 작업으로" 선언 **직전** (항상)

## 기본 도구 (이 영역의 정본)
- **Playwright MCP(`mcp__playwright__*`)가 기본 도구다** (전역 기본과 동일 — uncompromising-rigor §1이 2026-07-07부터 Playwright 우선). Chrome MCP(`mcp__claude-in-chrome__*`)는 시각·수동·세션 재사용 보조로만.
- 검증 실행 절차는 `live-verify-loop` 또는 `webapp-testing` 스킬에 위임한다(중복 신설 금지) — 이 규약은 게이트 기준만 강제.

## 검증 3계층 — 전부 통과해야 PASS (임의 판단 금지)
1. **상호작용**: 요소가 "있다"가 아니라 실제 클릭/입력/제출이 **실행**됨 (Playwright로 직접 조작).
2. **기능 결과**: 의도한 상태변화 확인 — UI 반영 + 네트워크 2xx·응답 본문 + 데이터/DB 반영 + 라우팅. (`browser_network_requests`·`browser_console_messages`·`browser_snapshot`으로 증거 확보.)
3. **케이스 전수**: 정상 경로 + 실패·엣지·경계(빈 입력·잘못된 값·권한 거부·에러 응답).

## 완료 규칙 (엄격)
- 각 항목 PASS/FAIL을 step-by-step 기록한다. **FAIL이 1개라도 있으면 미완료** → 고치고 재검증한다.
- "완료" 선언에는 **Playwright MCP 실행 증거(스냅샷/네트워크/콘솔/응답) ≥1개를 첨부**한다. 증거 없는 완료는 완료가 아니다.
- 발견된 미동작은 결함으로 등재한다 — 강등 불가(`uncompromising-rigor §2` 정합).
- 서버 미기동·환경 미비로 실검증이 불가능하면: 먼저 **스스로 해소를 시도**한다(dev 서버 기동, `run` 스킬 등 가역 범위 — 2026-07-02 Fable 정합). 그래도 불가하면 **추측 PASS 금지** → 차단 사유를 보고한다.
