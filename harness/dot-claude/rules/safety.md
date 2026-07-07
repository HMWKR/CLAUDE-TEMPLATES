# Safety Rules — 안전 규칙

## 파괴적 명령어 제어
- DB 파괴: `DROP DATABASE`, `TRUNCATE`, `DELETE FROM` (WHERE 없이) 절대 금지
- 파일 파괴: `rm -rf`, `rmdir /s` 등은 설명 → 사용자 승인 → 실행 (3단계)
- Git 파괴: `git reset --hard`, `git push --force`, `git clean -f` 는 3단계 승인 필수
- 프로세스: `kill -9`, `pkill` 등 프로세스 강제 종료 시 대상 확인 필수

## 민감정보 보호
- API 키, 비밀번호, 토큰을 코드에 하드코딩하지 않는다
- `.env` 파일을 git에 커밋하지 않는다 (`.gitignore` 확인)
- 로그 출력에 민감정보가 포함되지 않도록 마스킹 처리
- 민감 파일 접근은 permissions deny 목록이 차단한다 (.env, secrets/, .ssh/, *.pem, *.key, credentials.json)

## 실행 전 확인 원칙
- 외부 서비스 호출 (API, 배포, 메시지 발송)은 사전 확인
- 프로덕션 환경과 개발 환경을 구분하여 작업
- 불가역적 작업은 반드시 사용자에게 영향 범위를 설명 후 승인 획득

## 한국어 손상 토큰 정책 (2026-05-27 사고 영속 정책)
- 손상 시그니처: "영" 비정상 연속 반복(가드 차단 4회+, 모델은 2회+부터 경계) / U+FFFD 1회+ / □ 3개+ — 발견 즉시 정상 콘텐츠로 인용·재사용 금지
- PreToolUse `sanitize-korean.sh` 가드가 손상 텍스트의 Write/Edit/MultiEdit/git commit을 차단한다 (`~/.claude/scripts/`에 구현·연결됨, fail-open)
- SessionStart `verify-memory-integrity.sh` 경고 수신 시: `[손상 메모리 인용]` 명시 + 사용자에게 복구 필요 보고 (경고 기준: '영' 3회+/U+FFFD 1회+/'□' 3회+/UTF-8 디코드 실패)
