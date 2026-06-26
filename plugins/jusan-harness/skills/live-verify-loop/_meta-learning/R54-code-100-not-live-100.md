# R54: 코드 100% = 라이브 100% 가정의 위험

- 등재: 2026-05-05

## 함정
"`tsc --noEmit` 0 errors + `next lint` 0 + 모든 spec 통과 = 라이브에서 작동"이라는 가정.

## 진단 트리거
- 코드 품질 게이트(Layer 4) 모두 PASS
- 그러나 실제 브라우저:
  - Server HTML과 CSR 분기 결과 다름
  - Hook Rules 위반 (조건부 Hook / 순서 다름)
  - 환경변수 차이로 production 빌드만 깨짐
  - 동적 import / ssr:false 누락

## Fix 패턴
- Layer 4(코드 품질)는 **필요 조건이지 충분 조건 아님**
- **Layer 2(Playwright MCP) 의무**: 실제 브라우저 SSR + CSR 전체 사이클 검증
- 동적 import / ssr:false / Shell wrap 패턴 적용 (`_casebook.md` §1)
- 환경변수 mode C SSoT (`_casebook.md` §2)

## 일반성 검증
- ✅ 다른 도메인 재현: SSR 프레임워크 전반
- ✅ 기존과 다른 패턴: "정적 분석 PASS ≠ 런타임 작동"
- ✅ "모르면 다시 빠진다": 빌드 그린 = 배포 안전이라는 미신

## 관련 결함 케이스북
- `_casebook.md` §1 Hydration mismatch
- `_casebook.md` §2 BE_URL 이중 prefix
- `_casebook.md` §3 enum mismatch

## 본문 인용 위치
- SKILL.md "Meta-Learning 상단 인용"
- SKILL.md "Failure Modes 하단 인용"
