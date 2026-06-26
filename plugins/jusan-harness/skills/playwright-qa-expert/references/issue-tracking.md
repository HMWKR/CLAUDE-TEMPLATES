## 17. 이슈 추적 시스템 (Issue Tracking)

### 17.1 이슈별 디렉토리 구조

4단계(리포트 생성) 완료 후, 발견된 FAIL 이슈를 개별 디렉토리로 관리합니다.

```
{project-root}/
├── qa-issues/
│   ├── _index.json                        # 전체 이슈 인덱스
│   ├── CRIT-001-{slug}/                   # Critical 이슈
│   │   ├── issue.md                       # 이슈 상세 (심각도, 재현경로, 수정안)
│   │   ├── screenshot-before.png          # 발견 시점 스크린샷 (아래 노트 참조)
│   │   └── metadata.json                  # 상태 추적
│   ├── MAJ-002-{slug}/
│   └── MIN-003-{slug}/
```

**issue.md 생성 기준**: Critical/Major 심각도 이슈에 `issue.md` 생성. Minor/Suggestion은 `metadata.json`만 생성.

**screenshot 제약 노트**: Playwright MCP `browser_take_screenshot`은 대화 내 인라인 이미지로 반환하며, 프로젝트 디렉토리에 PNG 파일을 직접 저장하는 기능이 없음. 로컬 파일 저장 불가 시, 리포트 내 인라인 스크린샷으로 대체.

### 17.2 metadata.json 스키마

```json
{
  "id": "CRIT-001",
  "title": "색상 대비비 미달",
  "status": "open",
  "severity": "Critical",
  "checklistItem": "#56",
  "page": "/login",
  "element": "p.description",
  "currentValue": "3.2:1",
  "expectedValue": "4.5:1",
  "discoveredBy": "접근성 전문가",
  "discoveredAt": "2026-02-21T10:30:00Z",
  "runId": "FINAL-REPORT-20260221-1030",
  "history": [
    {"status": "open", "timestamp": "2026-02-21T10:30:00Z", "note": "발견"}
  ]
}
```

### 17.3 상태 전이

```
open → fixing → verify-requested → verified → closed
                                  → reopened → fixing (회귀 시)
```

| 상태 | 의미 | 트리거 |
|------|------|--------|
| `open` | 발견됨, 미수정 | QA 테스트 실행 |
| `fixing` | 수정 작업 중 | 사용자 표시 |
| `verify-requested` | 재검증 요청 | `--verify` 명령 |
| `verified` | 재검증 통과 | Playwright 재검증 성공 |
| `reopened` | 재검증 실패 | Playwright 재검증 실패 |
| `closed` | 최종 확인 | verified 후 사용자 승인 |

### 17.4 재검증 워크플로우 (--verify)

```
[Step 1] 이슈 메타데이터 로드
  qa-issues/{ID}/metadata.json 읽기
  → page, element, checklistItem 추출

[Step 2] 타겟 데이터 수집 (최소한)
  browser_navigate → 해당 페이지만
  browser_evaluate → 해당 CSS 속성만
  browser_snapshot → 해당 요소 확인

[Step 3] 항목 재검증
  기존 체크리스트 항목의 기준값으로 PASS/FAIL 판정

[Step 4] 상태 업데이트
  PASS → metadata.json.status = "verified", screenshot-after.png 저장
  FAIL → metadata.json.status = "reopened", 변경된 값 기록

[Step 5] 결과 출력
  "CRIT-001: 색상 대비비 → PASS (현재 4.8:1, 기준 4.5:1) [verified]"
```

### 17.5 _index.json 구조

```json
{
  "version": "1.0",
  "lastRun": "FINAL-REPORT-20260221-1030",
  "stats": {
    "total": 15,
    "open": 5,
    "fixing": 3,
    "verified": 4,
    "closed": 3
  },
  "issues": [
    {"id": "CRIT-001", "status": "open", "severity": "Critical", "title": "색상 대비비 미달"}
  ]
}
```

### 17.6 .gitignore 추가 안내

QA 실행 시 프로젝트의 .gitignore에 다음이 포함되어야 합니다:
```
qa-data/
qa-reports/
qa-issues/
```
