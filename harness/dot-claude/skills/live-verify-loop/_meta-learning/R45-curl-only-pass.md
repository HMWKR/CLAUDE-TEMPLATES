# R45: curl-only PASS = 라이브 작동 가정의 위험

- 등재: 2026-05-05

## 함정
"curl `/health` → 200 OK = 라이브 작동"이라는 단순 가정.

## 진단 트리거
- curl로 헬스 체크는 통과
- 그러나 실제 브라우저로 같은 라우트 진입 시:
  - Hydration mismatch 폭발
  - `Rendered more hooks` 에러
  - 페이지 자체는 200으로 응답하지만 ErrorBoundary가 폭발

## Fix 패턴
- curl은 **Layer 1 health 검증만**으로 한정 (서버 응답 200 확인)
- **Layer 2 Playwright MCP 의무**:
  - `browser_navigate` + `browser_evaluate({hasErrorBoundary})` + `browser_console_messages({level:'error'})`
  - 실제 브라우저 컨텍스트에서 hydration / hook / DOM 검증

## 일반성 검증
- ✅ 다른 도메인 재현: 모든 Next.js / SSR 프레임워크에서 발생
- ✅ 기존과 다른 패턴: "HTTP 응답 OK ≠ 클라이언트 측 작동"
- ✅ "모르면 다시 빠진다": curl을 신뢰하면 매 프로젝트 반복

## 관련 결함 케이스북
- `_casebook.md` §1 Hydration mismatch
- `_casebook.md` §5 cross-cutting

## 본문 인용 위치
- SKILL.md "Meta-Learning 상단 인용" (Token Position 첫 위치)
- SKILL.md "Failure Modes 하단 인용" (Token Position 마지막 위치)
