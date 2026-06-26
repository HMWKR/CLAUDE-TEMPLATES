# frontend-review — 분리 레퍼런스 (harness-diet 2026-06-06)

> SKILL.md 본문에서 분리된 상세. 원본은 archive/harness-diet-2026-06-06/file-backups 참조.

## 16. code-review 플러그인 정합 옵션 (2026-05-26 보강)

> 외부 `code-review@claude-plugins-official` 플러그인과 사용자 호환성 정합을 위한 별칭 + PR 통합. 기존 frontend-review 모드/옵션은 모두 보존.

### 16.1 Effort Level 별칭 (code-review 정합)

frontend-review의 모드는 외부 `code-review` 의 `effort level` 4단계와 정합:

| frontend-review 기존 | code-review 정합 별칭 | 항목 수 | 시간 | 동작 차이 |
|---|---|:--:|:--:|---|
| `basic` (기본) | **`--effort=low`** | ~30 | 5-8분 | 핵심 Tier 항목만 (high-confidence findings) |
| `--full` | **`--effort=medium`** | ~150 | 15-25분 | Tier별 1 specialist + 중간 신뢰도 |
| `--all` | **`--effort=high`** | ~450 | 30-60분 | 18 specialists 전수 (high-confidence) |
| (신규) | **`--effort=max`** | ~450+ | 45-90분 | 18 specialists 전수 + **uncertain findings 포함** (broader coverage, 추정 영역 포함) |

**Effort level 행동 차이**:

- **low / medium / high**: 확실한 발견만 (확신도 ≥ 7/10) 보고
- **max**: 확실한 발견 + **uncertain findings** (확신도 4-6/10) 추가 보고. `[추정]` 마커 명시. 사용자가 직접 검토하여 강등/유효 결정.

### 16.2 `--comment` PR Inline 게시 옵션

외부 `code-review` 의 `--comment` 와 정합. PR inline 코멘트 자동 게시.

#### 사용법

```bash
# GitHub PR 번호 지정
/frontend-review --all --teams --comment --pr=123

# PR URL 지정
/frontend-review --effort=max --comment --pr-url=https://github.com/owner/repo/pull/123

# dry-run (게시 안 함, 출력만)
/frontend-review --all --comment --pr=123 --dry-run
```

#### 게시 정책

| 발견 카테고리 | 게시 방식 | 위치 |
|---|---|---|
| **Blockers (Critical/High)** | PR Review (Request Changes) | PR 상단 review |
| **Warnings (Medium)** | Inline Comment | 해당 파일:라인 |
| **Suggestions (Low)** | Inline Comment (collapsed) | 해당 파일:라인 |
| **Frontend Quality Score** | PR Summary | PR 본문 |
| **18 Tier 점수표** | PR Summary | PR 본문 |
| **라우팅 권고** | PR Summary 하단 | PR 본문 |

#### 실행 명령 (내부)

```bash
# Blockers (Request Changes)
gh api repos/{owner}/{repo}/pulls/{N}/reviews \
  -X POST -f event=REQUEST_CHANGES -f body="..."

# Warnings/Suggestions (Inline)
gh api repos/{owner}/{repo}/pulls/{N}/comments \
  -X POST -f path="src/X.tsx" -f line=42 -f body="..."

# PR Summary 본문 업데이트
gh pr edit {N} --body "..."
```

#### dry-run 모드

`--dry-run` 시 게시 명령 출력만 (실제 API 호출 X). 사장님이 검토 후 직접 실행 또는 그대로 진행 결정.

#### 우회 금지

- 사용자 명시 승인 없이 자동 PR 게시 X (Uncompromising Rigor §3 — 모든 발견은 결함, 사장 명시 강등만 Low)
- `--dry-run` 기본값 X — `--comment` 명시 시 사용자가 dry-run 옵션 별도 선택
- 외부 라이브러리 의존 작업 시 사전 사용자 확인 (gh CLI 설치 / GITHUB_TOKEN 설정)

### 16.3 외부 code-review 와의 분담 (Confusion 방지)

같은 PR에서 두 스킬 모두 호출 가능. 분담:

| 호출 | 영역 |
|---|---|
| `code-review --effort=high` | **백엔드/일반 코드** (Security/Performance/Correctness/Maintainability) |
| `frontend-review --effort=high --teams` | **프론트엔드 6 Tier 18 specialists** (UI/UX/Design/A11y/Performance/Framework/FE Security) |

→ 풀스택 PR에 두 스킬 병렬 호출 권장. PR 분담:
- `code-review` 가 백엔드 코멘트
- `frontend-review` 가 프론트엔드 코멘트

### 16.4 환경 요구사항 (--comment 사용 시)

- `gh` CLI 설치 + 인증 (`gh auth status` 통과)
- GITHUB_TOKEN 환경변수 또는 `gh auth login`
- 해당 PR 권한 (push access 또는 maintainer)
- `--dry-run` 시 환경 요구사항 X (출력만)

### 16.5 호환성 보존

- 기존 모드 (basic / --full / --all / --focus / --loop) **모두 보존** — Steward 정합
- 신규 옵션 (--effort= / --comment / --pr= / --pr-url= / --dry-run) **추가만** — 기존 호출 패턴 영향 X
- 다른 frontend-review 호출자는 기존 방식 그대로 사용 가능

> **참조**: 사용자 결정 2026-05-26 — "code-review 수준의 하이퍼 파이프라인 구조 보장, 부족한 점 보강" / 외부 code-review SKILL.md (45줄) 비교 분석 후 보강 2건 적용

