# R55: `npx playwright test` ≠ Playwright MCP 도구

- 등재: 2026-05-05

## 함정
"`npx playwright test`로 spec 파일 통과 = Playwright MCP 검증 완료"라는 가정.

## 진단 트리거
- spec 파일은 통과 (`npx playwright test` exit 0)
- 그러나 실제 라이브 검증을 요청하면:
  - 인터랙션 클릭이 작동 안 함
  - 모달이 열리지 않음
  - 폼 제출 후 응답이 반영 안 됨
  - 시각 보존(스크린샷)이 누락됨

## Fix 패턴
- **`npx playwright test`는 testing framework** — assertion 통과만 검증
- **Playwright MCP는 실제 브라우저 인터랙션 시연 도구** — 다른 카테고리
- Layer 2 의무 도구는 **MCP 함수 직접 호출**:
  - `mcp__playwright__browser_navigate`
  - `mcp__playwright__browser_click`
  - `mcp__playwright__browser_fill_form`
  - `mcp__playwright__browser_evaluate`
  - `mcp__playwright__browser_console_messages`
  - `mcp__playwright__browser_take_screenshot`

## 일반성 검증
- ✅ 다른 도메인 재현: Playwright 사용 모든 프로젝트
- ✅ 기존과 다른 패턴: "spec 통과 ≠ 인터랙션 시연"
- ✅ "모르면 다시 빠진다": MCP와 testing framework를 동일시하면 매번 false positive

## 관련 결함 케이스북
- `_casebook.md` §1~6 모두 — Layer 2 검증 시 MCP 도구 필수

## 본문 인용 위치
- SKILL.md "Meta-Learning 상단 인용"
- SKILL.md "Failure Modes 하단 인용"
