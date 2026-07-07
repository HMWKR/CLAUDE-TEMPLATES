# Uncompromising Rigor — 검증 규율

> 검증·QA·검수 작업에서 결함이 자기 정당화로 살아남지 못하게 하는 규칙.
> 2026-06-11 재작성: §2 키워드 차단 기계(불발 실증)·§4 라운드 관료제·훅 매핑 표 제거. 구버전: `~/.claude/backups/pre-ultimate-2026-06-11/rules/`

## §1. Browser Tool Priority

1순위 `mcp__playwright__*` (Playwright MCP) → 2순위 `mcp__claude-in-chrome__*` (Chrome MCP) → 3순위 기타. (2026-07-07 전환: 기본 = Playwright — headless·사이트별 격리 컨텍스트·배치 자동화·스크린샷/DOM/CSS 추출·멀티탭에 적합.)

Chrome MCP 사용이 정당한 경우 (하나 충족 시):
1. 사용자의 실제 로그인/인증 세션 재사용이 필요 (Playwright는 세션 미상속)
2. 사용자가 "Chrome 직접 사용"을 지시
3. Playwright가 지원하지 않거나 Chrome 전용 기능 필요
4. Playwright 호출이 명시적으로 실패 (오류 메시지 캡처)

(구 `check-chrome-mcp-priority.sh` 훅 참조 제거 — 스크립트 부재·settings 미배선의 죽은 참조였고, Chrome-우선 강제는 더 이상 없다.)

## §2. All Findings Are Defects

> 발견된 모든 것은 결함이다. 사용자가 명시적으로 강등을 선언한 것만 강등된다.

| 발견 종류 | 기본 등급 | 강등 |
|---|:---:|---|
| 기능 작동 안 함 / 네트워크 4xx·5xx / 접근성(WCAG AA) 위반 | High | 불가 |
| 시각 결함·문구 모호·성능 임계 미달·Console error | Medium | 사용자 명시만 |
| 미세 픽셀 차이 (1-2px) | Low 자동 | 누적 시 Medium 승격 |

- "의도된 동작" 추정 금지 — 사용자 확인 또는 코드 주석의 의도 명시 인용 필수.
- 강등 시 사용자 발화를 인용한다: `> 사용자 강등 인용: "..."`
- 검증 종결 합리화("이 정도면 충분", "유사 검증 완료", "다음에 고치자")로 남은 검증 영역을 건너뛰지 않는다. 종결은 신규 발견 0 + 사용자 승인으로만 — 단 이 조건은 **명시적 검수·QA 세션에 한정**한다. 일반 작업의 완료는 fablize verification gate 통과(실행 증거)로 자율 선언 가능하다(2026-07-02 Fable 정합).

## 보고 형식

```markdown
### 발견 #N: <한줄 요약>
- 분류: High/Medium/Low (강등 시 출처 인용)
- 위치: <파일:라인 또는 URL:엘리먼트>
- 증거: <스크린샷/로그/캡처>
- 재현: <단계>
```
