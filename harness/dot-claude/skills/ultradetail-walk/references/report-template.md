# ultradetail-walk — 분리 레퍼런스 (harness-diet 2026-06-06)

> SKILL.md 본문에서 분리된 상세. 원본은 archive/harness-diet-2026-06-06/file-backups 참조.

### STEP ⑦ 결함 리포트 생성

#### Step ⑦-1: markdown 리포트

`<project>/.thoughts/walk-audit-YYYY-MM-DD.md`:

```markdown
# Ultradetail Walk Audit — YYYY-MM-DD

## 대상
- 프로젝트: <slug>
- 라운드 트리거: <commit hash> 또는 사용자 명시
- 페르소나 셋: <안 명> (정상 N + Adversarial M)
- 결함 카테고리 셋: <안 명> (10+개)

## 환경
- Playwright MCP: connected
- Supabase MCP / Cantos MCP: connected/missing
- 디스커버리 결과: 라우트 N / 입력 N / 라이브러리 N / 컴포넌트 N

## 발견 매트릭스
| # | 카테고리 | 페르소나 | element | 카오스 축 | 응답·UI | 영향도 |
|:-:|---|---|---|---|---|---|
| 1 | 권한 분기 우회 | guest | /admin/users URL 직접 | (정상 walk N/A) | 401 미반환, 페이지 로드됨 | **critical** |
| 2 | 결제 race | customer | "구매" 버튼 ×5 빠른 연타 | 동시성 | 중복 결제 2건, 환불 unclear | **high** |
| ... | ... | ... | ... | ... | ... | ... |

## 카테고리별 발견 통계
- 권한 분기 우회: N건 (critical N / high N)
- 결제 race condition: N건
- ...

## 다음 행동 (사용자 책임)
1. <발견 1>: <fix 제안 1줄>
2. <발견 2>: <fix 제안 1줄>
...

## live-verify-loop 체이닝 가능 결함
다음 N건은 live-verify-loop의 N라운드 fix 사이클로 자동 수렴 가능:
- ...

## 메타 학습 등재 후보
다음 발견은 R-등재 후보(meta-learning-governance 4 게이트 적용 후):
- ...
```

#### Step ⑦-2: HTML 리포트

`<project>/.thoughts/walk-audit-YYYY-MM-DD.html`:

- 발견 매트릭스 시각화 (정렬·필터·필드별 색상)
- 페르소나·카테고리 히트맵
- 스크린샷 첨부 (Playwright `browser_take_screenshot` 결과)
- Mermaid 시퀀스 다이어그램 (페르소나·카오스 흐름)

#### Step ⑦-3: Cantos 통합 (있을 때만)

Cantos MCP connected 시:
- 발견된 critical/high 결함 → DDR 자동 생성 후보 표시
- 시각 캡처 → cantos `_screenshots/` 동기화

미연결 시 silent skip.

---

