# security-review — 분리 레퍼런스 (harness-diet 2026-06-06)

> SKILL.md 본문에서 분리된 상세. 원본은 archive/harness-diet-2026-06-06/file-backups 참조.

## 4. Specialists 상세 (24 TM)

### TM1 — Authentication
**역할**: 비밀번호 정책 / MFA / 세션 관리 검사.
**Grep**: `password|bcrypt|argon2|scrypt|hash|session|cookie|mfa|2fa|otp`
**체크 (25)**:
1. 비밀번호 해시 bcrypt/argon2/scrypt (MD5/SHA1 금지)
2. 솔트 자동 생성
3. 비밀번호 최소 길이 8+
4. 비밀번호 정책 (대소문자/숫자/특수)
5. 비밀번호 변경 시 기존 확인
6. 비밀번호 reset token 일회용 + 짧은 만료
7. MFA 옵션 제공
8. TOTP 시크릿 안전 저장
9. SMS OTP rate limit
10. 세션 ID 안전 생성 (crypto random)
11. 세션 만료 적정 (idle / absolute)
12. 세션 고정 공격 방어 (regenerate on login)
13. 로그아웃 시 세션 무효화
14. 동시 세션 제한
15. 무차별 대입 차단 (account lockout / captcha)
16. 로그인 실패 메시지 일반 ("사용자 또는 비밀번호 오류")
17. 비밀번호 변경 통보
18. 의심 활동 알림
19. password reveal toggle (UX)
20. autocomplete 적절 (`new-password` / `current-password`)
21. credential stuffing 방어
22. 비밀번호 복원 질문 회피
23. 매직 링크 사용 시 짧은 만료
24. 패스키 (passkey) 지원 고려
25. 세션 cookie httpOnly + Secure + SameSite

### TM2 — Authorization
**역할**: 권한 체크 / RBAC / 권한 우회.
**Grep**: `role|permission|authorize|isAdmin|canEdit|hasAccess|@auth|requireRole`
**체크 (25)**:
1. 모든 보호 라우트에 권한 체크
2. 권한 체크 위치 (middleware / handler 시작)
3. IDOR 방어 (자기 데이터만 접근)
4. 권한 escalation 방어
5. RBAC 명확 (admin/user/guest)
6. ABAC 사용 시 정책 명확
7. 권한 데이터 캐시 invalidation
8. 다중 권한 AND/OR 명확
9. 권한 상속 (organization → team → user)
10. 임시 권한 만료
11. 권한 변경 audit log
12. 슈퍼관리자 동작 audit
13. API 키 권한 범위 (scopes)
14. OAuth scopes 최소 권한
15. 권한 거부 응답 403 (404 가짜 X)
16. 익명 접근 명시
17. 권한 체크 fail-closed (default deny)
18. 권한 우회 가능 paths 검사
19. 프론트엔드 권한 체크는 보조만 (백엔드 우선)
20. Multi-tenant isolation
21. 행 단위 권한 (Row-Level Security)
22. 컬럼 단위 권한 (sensitive fields)
23. 권한 위임 (Impersonation) 감사
24. 권한 만료 자동
25. 권한 검토 주기적

### TM3 — Token & JWT
**역할**: JWT / 토큰 서명 / 만료 / refresh.
**Grep**: `jwt|jsonwebtoken|sign|verify|exp|iat|refresh|Bearer|access_token`
**체크 (20)**:
1. JWT 서명 알고리즘 명시 (RS256 권장, HS256 신중)
2. `alg=none` 차단
3. JWT secret 안전 (32+ bytes random)
4. JWT 만료 (`exp`) 짧게 (15분-1시간)
5. Refresh token 별도 + 더 김
6. Refresh token rotation
7. Token blacklist (logout / revoke)
8. Token in URL 회피 (Header만)
9. Token storage (httpOnly cookie 권장)
10. Token type (`typ`) 검증
11. Audience (`aud`) 검증
12. Issuer (`iss`) 검증
13. JWT payload PII 회피
14. JWT 크기 적정 (header size limit)
15. Refresh token sliding window
16. CSRF 방어 (SameSite + Origin)
17. Token leak 감지 (다중 IP / UA)
18. Token revocation API
19. Token introspection (OAuth)
20. JWT 라이브러리 최신 버전

### TM4 — OAuth/SSO
**역할**: OAuth 2.0 / OIDC / SAML.
**Grep**: `oauth|oidc|saml|client_secret|redirect_uri|state|PKCE|code_verifier`
**체크 (20)**:
1. OAuth state 파라미터 (CSRF)
2. PKCE (mobile/SPA 필수)
3. redirect_uri 화이트리스트
4. client_secret 서버만 (SPA 노출 X)
5. Authorization code 짧은 만료 (10분 이하)
6. Authorization code 일회용
7. Access token / Refresh token 분리
8. Scope 최소 권한
9. Scope 사용자 동의 명시
10. ID token nonce
11. ID token aud/iss 검증
12. ID token 서명 검증
13. OAuth provider 신뢰성
14. SSO 세션 통합 + 분리 정책
15. Logout 시 SSO 로그아웃 (RP-initiated)
16. SSO 메타데이터 안전
17. SAML 서명 검증
18. SAML XML Injection 방어
19. SAML Replay 방어 (NotBefore/NotOnOrAfter)
20. SSO 실패 시 fallback

### TM5 — SQL Injection
**역할**: SQL 인젝션 방어.
**Grep**: `query|exec|raw|sequelize\.literal|knex\.raw|\$\{.*\}.*SELECT|UNION|DROP|INSERT`
**체크 (20)**:
1. 모든 쿼리 파라미터 바인딩 (`?` / `$1`)
2. ORM 사용 시 raw 회피
3. 동적 테이블/컬럼명 화이트리스트
4. LIKE 쿼리 `%` 이스케이프
5. ORDER BY 화이트리스트
6. LIMIT 정수 검증
7. 사용자 입력 직접 concat 금지
8. Stored procedure 사용 시 입력 검증
9. NoSQL Injection (MongoDB `$where`, `$regex`)
10. ORM injection (Sequelize literal / Prisma raw)
11. Error message DB 정보 노출 X
12. DB 권한 최소 (앱 user 별도)
13. DB 연결 문자열 시크릿
14. 쿼리 timeout
15. Connection pool 제한
16. Prepared statement 캐시
17. Multiple statements 차단
18. Comment injection (`--`, `/* */`)
19. Hex/Unicode escape 검증
20. SQL audit log

### TM6 — XSS
**역할**: Reflected / Stored / DOM XSS.
**Grep**: `dangerouslySetInnerHTML|innerHTML|outerHTML|insertAdjacentHTML|document\.write|v-html|x-html`
**체크 (25)**:
1. dangerouslySetInnerHTML 최소화
2. DOMPurify 또는 sanitize-html
3. innerHTML 직접 할당 회피
4. 사용자 입력 HTML escape
5. URL 입력 검증 (`javascript:` 차단)
6. iframe src 검증
7. img src 검증
8. SVG sanitize (XSS 가능)
9. Markdown 렌더 시 sanitize
10. JSON in HTML escape
11. 이벤트 핸들러 인라인 회피
12. CSP `script-src` 'unsafe-inline' 회피
13. CSP nonce/hash 활용
14. Template injection (Handlebars / Pug)
15. SSR XSS (React renderToString → escape)
16. URL 파라미터 escape
17. HTTP 헤더 인젝션 (CRLF)
18. Open Redirect (Location 헤더)
19. PostMessage origin 검증
20. WebSocket 메시지 검증
21. Clipboard API 검증
22. Drag&Drop 입력 검증
23. File upload preview escape
24. Search highlighting escape
25. 동적 CSS 인젝션 회피

### TM7 — CSRF
**역할**: CSRF 토큰 / SameSite / Origin.
**Grep**: `csrf|XSRF|SameSite|Origin|Referer|withCredentials`
**체크 (15)**:
1. CSRF 토큰 모든 state-changing 요청
2. CSRF 토큰 일회용 또는 세션 단위
3. SameSite=Strict 또는 Lax
4. Origin/Referer 검증
5. Cookie Secure 플래그
6. Cookie httpOnly (XSS 차단)
7. CSRF 토큰 DOM 노출 X
8. CSRF + JWT 조합 신중
9. Double-submit cookie 패턴
10. Custom header (X-Requested-With)
11. Safe HTTP methods (GET) 차단
12. CSRF 검증 fail-closed
13. SPA CSRF 처리
14. 파일 업로드 CSRF
15. Logout CSRF 방어

### TM8 — Command/Path Injection
**역할**: Command injection / Path traversal / SSRF.
**Grep**: `exec|spawn|shell|child_process|readFile|writeFile|\.\./|fetch\(|axios\(|request\(`
**체크 (20)**:
1. shell:true 회피 (spawn 인자 배열)
2. exec → spawn 권장
3. 사용자 입력 명령 인자 검증
4. Path traversal 방어 (`../`)
5. Path normalization (path.resolve)
6. Path 화이트리스트
7. 파일 확장자 검증
8. 파일 크기 제한
9. 파일 MIME 검증 (magic bytes)
10. Symlink follow 회피
11. Zip slip 방어
12. SSRF — URL 화이트리스트
13. SSRF — 내부 IP 차단 (127.0.0.1 / 169.254 / 10.0/8 등)
14. SSRF — DNS rebinding 방어
15. Open redirect — URL 화이트리스트
16. XXE 방어 (XML 외부 entity 비활성)
17. XML bomb 방어 (entity expansion 제한)
18. Deserialization 안전 (pickle / Java serialization 회피)
19. ReDoS (Regular Expression DoS) — catastrophic backtracking
20. Format string injection

### TM9 — At-Rest 암호화
**역할**: 저장 데이터 암호화.
**Grep**: `encrypt|decrypt|AES|RSA|crypto|bcrypt|argon2`
**체크 (15)**:
1. 민감 데이터 AES-256-GCM
2. 키 derivation (PBKDF2/scrypt/argon2)
3. IV / nonce 매번 random
4. 키 로테이션 정책
5. 키 별도 저장 (KMS / vault)
6. DB 컬럼 단위 암호화 (PII)
7. 파일 암호화 (업로드 / 백업)
8. 백업 암호화
9. 로그 암호화 (시크릿 마스킹 후 저장)
10. 암호화 알고리즘 최신
11. 약한 알고리즘 차단 (DES/3DES/RC4)
12. 키 길이 충분 (AES 256 / RSA 2048+)
13. 알고리즘 명시 (auto-detect 회피)
14. HMAC 메시지 무결성
15. envelope encryption (대용량)

### TM10 — In-Transit 암호화
**역할**: TLS / mTLS / Cert pinning.
**Grep**: `https|tls|ssl|cert|key|pinning`
**체크 (15)**:
1. HTTPS 강제 (HSTS preload)
2. TLS 1.2+ (1.0/1.1 차단)
3. 강한 cipher suite
4. Certificate 유효성 검증
5. Certificate 만료 모니터링
6. Let's Encrypt 자동 갱신
7. mTLS (서비스 간)
8. Certificate pinning (mobile)
9. Mixed content 차단
10. WebSocket WSS만
11. gRPC TLS
12. DB 연결 TLS
13. SMTP TLS (STARTTLS)
14. Redis TLS (네트워크 격리 외)
15. CA 인증서 최소 신뢰

### TM11 — PII 처리
**역할**: 개인정보 수집/저장/삭제/마스킹.
**Grep**: `email|phone|ssn|jumin|address|birth|userId.*name|firstName|lastName`
**체크 (20)**:
1. PII 수집 최소 원칙
2. PII 수집 동의 명시
3. PII 저장 암호화
4. PII 마스킹 (UI / 로그)
5. PII 삭제 권리 구현
6. PII 익명화 / pseudonymization
7. PII 보관 기간 명시 + 자동 삭제
8. PII 백업 보호
9. PII 로그 마스킹 자동
10. PII 검색 권한 제한
11. PII 내보내기 (이식성 권리)
12. PII 정정 권리
13. PII 처리 audit log
14. PII 제3자 공유 명시
15. PII 국경간 전송 동의
16. PII 자동 의사결정 옵트아웃
17. PII 아동 (13세 미만) 동의
18. PII 민감 정보 분리 (건강/금융/생체)
19. PII 데이터 매핑 문서
20. PII 침해 통보 절차

### TM12 — 데이터 무결성
**역할**: 서명 / 체크섬 / Audit log immutable.
**Grep**: `signature|HMAC|checksum|hash|sha256|integrity|audit`
**체크 (15)**:
1. 중요 데이터 HMAC
2. 다운로드 파일 SHA256
3. API 응답 서명
4. Webhook 서명 검증
5. Audit log immutable (append-only)
6. Audit log 외부 저장 (DB 분리)
7. 데이터 변경 추적 (history table)
8. Soft delete (감사 추적)
9. 데이터 복원 절차
10. 데이터 검증 정기 (체크섬)
11. Git commit 서명 (GPG)
12. Container image 서명 (cosign)
13. CI/CD artifact 서명
14. 데이터 마이그 후 검증
15. 백업 무결성 검증

### TM13 — 보안 헤더
**역할**: CSP / HSTS / X-Frame-Options / Permissions-Policy.
**Grep**: `Content-Security-Policy|Strict-Transport-Security|X-Frame-Options|Permissions-Policy|helmet`
**체크 (15)**:
1. CSP `default-src 'self'`
2. CSP `script-src` nonce/hash
3. CSP `style-src` 'unsafe-inline' 회피
4. CSP `img-src` 화이트리스트
5. CSP `connect-src` API 도메인
6. CSP `frame-ancestors 'none'` (clickjacking)
7. CSP `form-action 'self'`
8. CSP `report-uri` / `report-to`
9. HSTS max-age 31536000+ + preload
10. X-Content-Type-Options: nosniff
11. X-Frame-Options: DENY
12. Referrer-Policy: strict-origin-when-cross-origin
13. Permissions-Policy (camera/microphone/geolocation)
14. helmet.js (Node.js) 사용
15. 보안 헤더 자동 테스트 (securityheaders.com)

### TM14 — CORS
**역할**: CORS 정책 / Origin 화이트리스트.
**Grep**: `Access-Control-Allow-Origin|cors|Origin`
**체크 (10)**:
1. CORS Origin 화이트리스트 (별표 `*` 회피)
2. credentials: true 시 Origin 동적 + 검증
3. Allowed methods 최소
4. Allowed headers 명시
5. Preflight cache 적정
6. Subdomain wildcard 신중
7. localhost 개발 환경만
8. CORS 정책 docs 화
9. CSRF 방어 결합
10. Public API CORS 정책 명확

### TM15 — Container 보안
**역할**: Docker / Kubernetes 보안.
**Grep**: `FROM|RUN|USER|capabilities|privileged|runAsRoot|securityContext`
**체크 (15)**:
1. Non-root user (USER 1000)
2. Privileged mode 회피
3. Capabilities drop ALL + 필요한 것만 add
4. readOnlyRootFilesystem
5. Base image distroless 또는 alpine
6. Image scan (Trivy / Snyk)
7. Multi-stage build
8. .dockerignore 적정
9. Secrets in env 회피 (mount)
10. Health check 명시
11. Resource limits (CPU/Mem)
12. NetworkPolicy (K8s)
13. PodSecurityPolicy/PodSecurityStandards
14. ServiceAccount 최소 권한
15. Image tag :latest 회피

### TM16 — 시크릿 관리
**역할**: 환경변수 / vault / rotation.
**Grep**: `API_KEY|SECRET|TOKEN|PASSWORD|process\.env\.|vault|kms`
**체크 (15)**:
1. 시크릿 .env (Git ignore)
2. 시크릿 vault (HashiCorp / AWS Secrets Manager / Doppler)
3. 시크릿 rotation 정책
4. 시크릿 로깅 X (마스킹)
5. 시크릿 git history 검색 (git-secrets / gitleaks)
6. 시크릿 CI/CD masking
7. 시크릿 environment per env (dev/stage/prod)
8. 시크릿 access audit
9. 시크릿 최소 접근 권한
10. 시크릿 만료 모니터링
11. NEXT_PUBLIC 시크릿 노출 X
12. 클라이언트 사이드 시크릿 X
13. README / 문서에 시크릿 X
14. .env.example placeholder만
15. 시크릿 leak 발생 시 즉시 rotation

### TM17 — CVE 스캔
**역할**: 의존성 취약점.
**Grep**: `package\.json|requirements\.txt|Gemfile|go\.mod|pom\.xml|Cargo\.toml`
**체크 (10)**:
1. `npm audit` / `pip-audit` / `bundler-audit`
2. Dependabot / Renovate 활성
3. Critical CVE 즉시 패치
4. Lock file 커밋 (package-lock.json)
5. 의존성 trees 분석
6. Transitive dependency 점검
7. CVE 데이터베이스 자동 확인
8. EOL (End-of-Life) 라이브러리 차단
9. 의존성 업데이트 주기
10. CI에 audit 단계

### TM18 — 라이선스
**역할**: 오픈소스 라이선스 호환.
**Grep**: `license|LICENSE|MIT|Apache|GPL|AGPL|BSD`
**체크 (8)**:
1. GPL/AGPL 의존성 식별
2. 상용 라이선스 호환 확인
3. 라이선스 의존성 자동 스캔
4. SBOM (Software Bill of Materials) 생성
5. 라이선스 변경 추적
6. 자체 코드 라이선스 명시
7. 의존성 EULA 검토
8. 라이선스 위반 통지 프로세스

### TM19 — 공급망 위험
**역할**: Typosquatting / 악성 패키지.
**Grep**: `dependencies|devDependencies|peerDependencies`
**체크 (7)**:
1. 패키지명 typo 검사
2. 새 의존성 추가 시 검토
3. Maintainer 수 (단일 = 위험)
4. Download 통계 (소량 = 위험)
5. 최근 업데이트 (오래된 = 위험)
6. lock file integrity (npm sha)
7. Package signing (Sigstore)

### TM20 — 로깅 보안
**역할**: 로그 시크릿 마스킹 / PII 필터.
**Grep**: `console\.log|logger|winston|pino|log4j`
**체크 (10)**:
1. 시크릿 자동 마스킹 (winston format)
2. PII 자동 마스킹
3. 로그 구조화 (JSON)
4. 로그 레벨 명확 (debug/info/warn/error)
5. 로그 외부 저장 (CloudWatch / Datadog)
6. 로그 보관 정책 (90일+ 감사 / 30일 운영)
7. 로그 접근 권한
8. 로그 검색 인덱스
9. 로그 ingestion rate limit
10. 로그 무결성 (immutable)

### TM21 — 감사 추적
**역할**: Audit trail / immutable.
**Grep**: `audit|trail|history|changelog`
**체크 (10)**:
1. 모든 권한 변경 감사
2. 모든 데이터 삭제 감사
3. 모든 admin 동작 감사
4. 모든 로그인/로그아웃 감사
5. 모든 시크릿 접근 감사
6. Audit log immutable
7. Audit log 외부 저장
8. Audit log 보관 기간 (1년+)
9. Audit log 검색 가능
10. Audit log alert (이상 패턴)

### TM22 — Rate Limiting
**역할**: DoS 방어 / abuse.
**Grep**: `rateLimit|throttle|express-rate-limit|burst|concurrent`
**체크 (10)**:
1. 로그인 시도 rate limit
2. API rate limit (per user / IP)
3. SMS / Email 발송 rate limit
4. 파일 업로드 rate limit
5. 무료 tier rate limit
6. Burst capacity 적정
7. Rate limit 헤더 (X-RateLimit-Remaining)
8. Captcha (반복 실패 시)
9. CDN rate limit (CloudFlare)
10. WAF rule

### TM23 — GDPR/PIPA
**역할**: 데이터 규제 기본.
**체크 (15)**:
1. 동의 명시 (opt-in)
2. 동의 철회 옵션
3. 데이터 처리 목적 명시
4. 데이터 제3자 공유 명시
5. 데이터 보관 기간
6. 데이터 삭제 권리
7. 데이터 이식성
8. 데이터 정정 권리
9. 데이터 처리 audit
10. 개인정보 처리방침 (공개)
11. DPO (Data Protection Officer)
12. 침해 통보 72시간
13. 어린이 동의 (13세 미만)
14. 자동 의사결정 옵트아웃
15. 데이터 매핑 문서

### TM24 — 산업 표준
**역할**: PCI-DSS / HIPAA 핵심.
**체크 (10)**:
1. PCI-DSS: 카드 번호 저장 회피 (tokenization)
2. PCI-DSS: 카드 결제 외부 위임 (Stripe / Toss)
3. PCI-DSS: 보안 코드 (CVV) 저장 X
4. HIPAA: PHI 암호화
5. HIPAA: Access log
6. HIPAA: BAA (Business Associate Agreement)
7. SOC 2: 5 trust services criteria
8. ISO 27001: ISMS
9. NIST CSF: Identify/Protect/Detect/Respond/Recover
10. 컴플라이언스 정기 audit

---

