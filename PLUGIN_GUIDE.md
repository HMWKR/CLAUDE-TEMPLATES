# Claude Code 플러그인 완전 가이드

설치된 24개 플러그인의 모든 기능을 정리한 문서입니다.

---

## 1. 슬래시 명령어 (Commands)

직접 `/명령어`로 실행할 수 있는 기능입니다.

### Git 워크플로우
| 명령어 | 플러그인 | 설명 |
|--------|---------|------|
| `/commit` | commit-commands | Git 커밋 생성 |
| `/commit-push-pr` | commit-commands | 커밋 → 푸시 → PR 생성 한번에 |
| `/clean-gone` | commit-commands | 삭제된 원격 브랜치 로컬 정리 |

### 코드 리뷰
| 명령어 | 플러그인 | 설명 |
|--------|---------|------|
| `/code-review <PR번호>` | code-review | PR 코드 리뷰 (5개 에이전트 병렬) |
| `/review-pr [aspects]` | pr-review-toolkit | 종합 PR 리뷰 (6가지 측면) |

**review-pr 옵션:**
- `comments` - 코드 주석 분석
- `tests` - 테스트 커버리지
- `errors` - 에러 핸들링
- `types` - 타입 설계
- `code` - 일반 코드 품질
- `simplify` - 코드 단순화
- `all parallel` - 전체 병렬 실행

### 개발 워크플로우
| 명령어 | 플러그인 | 설명 |
|--------|---------|------|
| `/feature-dev <설명>` | feature-dev | 7단계 기능 개발 가이드 |
| `/ralph-loop "<프롬프트>"` | ralph-loop | 반복 자동화 루프 |
| `/cancel-ralph` | ralph-loop | Ralph 루프 취소 |

**ralph-loop 옵션:**
```bash
/ralph-loop "TODO API 구현" --max-iterations 50 --completion-promise "COMPLETE"
```

### 플러그인 개발
| 명령어 | 플러그인 | 설명 |
|--------|---------|------|
| `/create-plugin` | plugin-dev | 새 플러그인 생성 |
| `/new-sdk-app` | agent-sdk-dev | Agent SDK 앱 생성 |

### 훅 관리
| 명령어 | 플러그인 | 설명 |
|--------|---------|------|
| `/hookify` | hookify | 훅 설정 시작 |
| `/hookify:configure` | hookify | 훅 설정 관리 |
| `/hookify:list` | hookify | 설정된 훅 목록 |
| `/hookify:help` | hookify | 훅 도움말 |

### Stripe 결제
| 명령어 | 플러그인 | 설명 |
|--------|---------|------|
| `/stripe:explain-error` | stripe | Stripe 에러 설명 |
| `/stripe:test-cards` | stripe | 테스트 카드 정보 |

---

## 2. 스킬 (Skills)

관련 요청 시 **자동으로 적용**되는 지침입니다.

| 스킬 | 플러그인 | 트리거 | 효과 |
|------|---------|--------|------|
| `frontend-design` | frontend-design | UI/웹 페이지 생성 요청 | 고품질 독창적 디자인 코드 생성 |
| `stripe-best-practices` | stripe | Stripe 결제 구현 요청 | Stripe 모범 사례 적용 |
| `writing-rules` | hookify | 훅 규칙 생성 요청 | 대화에서 규칙 추출 |

### plugin-dev 스킬 (7개)
| 스킬 | 설명 |
|------|------|
| `plugin-structure` | 플러그인 구조 가이드 |
| `skill-development` | 스킬 개발 가이드 |
| `command-development` | 명령어 개발 가이드 |
| `agent-development` | 에이전트 개발 가이드 |
| `hook-development` | 훅 개발 가이드 |
| `mcp-integration` | MCP 통합 가이드 |
| `plugin-settings` | 플러그인 설정 가이드 |

---

## 3. 에이전트 (Agents)

명령어/스킬 내부에서 **서브작업**으로 실행됩니다.

### PR 리뷰 에이전트 (pr-review-toolkit)
| 에이전트 | 역할 |
|---------|------|
| `code-reviewer` | 일반 코드 품질 및 CLAUDE.md 준수 |
| `comment-analyzer` | 코드 주석 정확성 검증 |
| `pr-test-analyzer` | 테스트 커버리지 분석 |
| `silent-failure-hunter` | 무시된 에러/조용한 실패 탐지 |
| `type-design-analyzer` | 타입 설계 및 불변성 분석 |
| `code-simplifier` | 코드 단순화 제안 |

### 기능 개발 에이전트 (feature-dev)
| 에이전트 | 역할 |
|---------|------|
| `code-architect` | 아키텍처 설계 (여러 접근법 제안) |
| `code-explorer` | 코드베이스 탐색 및 패턴 분석 |
| `code-reviewer` | 구현 후 검토 |

### 플러그인 개발 에이전트 (plugin-dev)
| 에이전트 | 역할 |
|---------|------|
| `agent-creator` | 에이전트 생성 |
| `plugin-validator` | 플러그인 검증 |
| `skill-reviewer` | 스킬 리뷰 |

### Agent SDK 에이전트 (agent-sdk-dev)
| 에이전트 | 역할 |
|---------|------|
| `agent-sdk-verifier-py` | Python SDK 검증 |
| `agent-sdk-verifier-ts` | TypeScript SDK 검증 |

### 기타 에이전트
| 에이전트 | 플러그인 | 역할 |
|---------|---------|------|
| `conversation-analyzer` | hookify | 대화 분석하여 규칙 추출 |
| `code-simplifier` | code-simplifier | 코드 단순화 전용 |

---

## 4. 훅 (Hooks)

특정 이벤트 발생 시 **자동 실행**됩니다.

| 훅 | 플러그인 | 트리거 | 효과 |
|----|---------|--------|------|
| SessionStart | explanatory-output-style | 세션 시작 | 교육적 인사이트 추가 |
| SessionStart | learning-output-style | 세션 시작 | 대화형 학습 모드 |
| Stop | ralph-loop | 세션 종료 시도 | 루프 계속 또는 종료 |
| SecurityReminder | security-guidance | 코드 작성 시 | 보안 가이드라인 상기 |

---

## 5. 출력 스타일 플러그인

### explanatory-output-style
- **효과**: 코드 작성 전후 교육적 인사이트 제공
- **출력 형식**:
```
★ Insight ─────────────────────────────────────
[2-3개 교육 포인트]
─────────────────────────────────────────────────
```
- **주의**: 토큰 비용 증가

### learning-output-style
- **효과**: 대화형 학습 + 교육적 인사이트
- **특징**:
  - 5-10줄 코드 직접 작성 요청
  - 비즈니스 로직, 에러 핸들링 등 결정 지점에서 참여 유도
  - 보일러플레이트는 자동 처리
- **주의**: 토큰 비용 증가 + 대화형

---

## 6. 외부 서비스 MCP (13개)

### 연결 상태
| 서비스 | 상태 | 용도 |
|--------|------|------|
| **playwright** | ✓ 연결됨 | 브라우저 자동화, 웹 테스트 |
| **greptile** | ✓ 연결됨 | AI 코드 검색 |
| **context7** | ✓ 연결됨 | 컨텍스트 관리 |
| **gitlab** | ⚠ 인증 필요 | GitLab API |
| **linear** | ⚠ 인증 필요 | 이슈 트래커 |
| **asana** | ⚠ 인증 필요 | 프로젝트 관리 |
| **supabase** | ⚠ 인증 필요 | 백엔드/DB |
| **stripe** | ⚠ 인증 필요 | 결제 API |
| **github** | ✗ 연결 실패 | GitHub API |
| **slack** | ✗ 연결 실패 | 메시지 |
| **firebase** | ✗ 연결 실패 | Firebase |
| **serena** | ✗ 연결 실패 | AI 에이전트 |
| **laravel-boost** | ✗ 연결 실패 | Laravel 지원 |

### 인증 방법
```bash
/mcp
# → 서버 선택 → 브라우저에서 로그인
```

---

## 7. 사용 예시

### Git 워크플로우
```bash
/commit                      # 변경사항 커밋
/commit-push-pr              # 커밋 + 푸시 + PR 한번에
```

### 코드 리뷰
```bash
/code-review 123             # PR #123 전체 리뷰
/review-pr tests errors      # 테스트/에러만 집중 리뷰
/review-pr all parallel      # 전체 병렬 리뷰
```

### 기능 개발
```bash
/feature-dev 로그인 기능 구현  # 7단계 가이드 시작
```

### 자동화 루프 (Ralph)
```bash
/ralph-loop "REST API 구현. CRUD, 테스트 포함. 완료 시 <promise>DONE</promise> 출력" --max-iterations 30 --completion-promise "DONE"
```

### 디자인
```
웹 페이지 디자인해줘         # frontend-design 스킬 자동 적용
랜딩 페이지 만들어줘         # 독창적 UI 코드 생성
```

### 플러그인 개발
```bash
/create-plugin               # 새 플러그인 생성 가이드
```

---

## 8. 플러그인 관리 명령어

```bash
# 목록 확인
claude plugin list

# 플러그인 비활성화 (코드 유지)
claude plugin disable <이름>

# 플러그인 활성화
claude plugin enable <이름>

# 플러그인 제거
claude plugin uninstall <이름>

# 플러그인 업데이트
claude plugin update <이름>
```

---

## 9. 요약 테이블

| 카테고리 | 개수 | 예시 |
|---------|------|------|
| 슬래시 명령어 | 15+ | /commit, /review-pr, /feature-dev |
| 스킬 | 10+ | frontend-design, stripe-best-practices |
| 에이전트 | 16+ | code-reviewer, code-architect |
| 훅 | 4 | SessionStart, Stop, SecurityReminder |
| MCP 서버 | 13 | playwright, github, slack |

---

## 10. 설치된 플러그인 전체 목록 (24개)

### 개발 워크플로우 (11개)
1. **commit-commands** - Git 커밋/푸시/PR 자동화
2. **pr-review-toolkit** - 종합 PR 리뷰 (6가지 측면)
3. **code-review** - PR 코드 리뷰 (5개 에이전트)
4. **code-simplifier** - 코드 단순화 에이전트
5. **feature-dev** - 7단계 기능 개발 가이드
6. **frontend-design** - 고품질 UI/UX 코드 생성
7. **security-guidance** - 보안 가이드라인 훅
8. **hookify** - 훅 자동 설정
9. **plugin-dev** - 플러그인 개발 도구
10. **agent-sdk-dev** - Agent SDK 개발
11. **ralph-loop** - 반복 자동화 루프

### 출력 스타일 (2개)
12. **explanatory-output-style** - 교육적 인사이트 모드
13. **learning-output-style** - 대화형 학습 모드

### 외부 서비스 통합 (11개)
14. **github** - GitHub API
15. **gitlab** - GitLab API
16. **slack** - Slack 메시지
17. **linear** - Linear 이슈 트래커
18. **asana** - Asana 프로젝트 관리
19. **firebase** - Firebase 서비스
20. **supabase** - Supabase 백엔드
21. **stripe** - Stripe 결제
22. **playwright** - 브라우저 자동화
23. **greptile** - AI 코드 검색
24. **context7** - 컨텍스트 관리

---

**참고**: Claude Code 재시작 후 모든 기능이 완전히 적용됩니다.

---

*작성일: 2026-01-18*
*Claude Code 버전: 2.1.12*
