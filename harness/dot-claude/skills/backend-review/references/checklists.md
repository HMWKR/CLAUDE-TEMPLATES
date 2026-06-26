# backend-review — 분리 레퍼런스 (harness-diet 2026-06-06)

> SKILL.md 본문에서 분리된 상세. 원본은 archive/harness-diet-2026-06-06/file-backups 참조.

## 4. Specialists 상세

### TM1 REST 설계 (체크 25)
**Grep**: `app\.(get|post|put|delete|patch)|router\.|@Get|@Post|status\(|res\.send`
1. HTTP 메소드 적합 (GET 멱등 / POST 생성 / PUT 전체 / PATCH 부분)
2. Status code 정확 (200/201/204 / 400/401/403/404/409 / 500)
3. URI 명사 (verb 회피)
4. 컬렉션 vs 단일 자원 명확 (`/users` vs `/users/:id`)
5. 중첩 자원 명확
6. Query parameter 표준 (`?page=1&limit=10&sort=name`)
7. Pagination (cursor 또는 page)
8. Filter 표준
9. Content-Type 명시
10. CORS preflight 처리
11. ETag / Last-Modified (캐싱)
12. HTTP/2 활용
13. Compression (gzip / brotli)
14. 응답 envelope 일관
15. 에러 응답 표준 (RFC 7807 problem+json)
16. PATCH 부분 업데이트 시맨틱
17. 멱등성 헤더 (Idempotency-Key)
18. 비동기 응답 (202 Accepted + Location)
19. Webhook 서명 + 재시도
20. Rate limit 헤더 (X-RateLimit-*)
21. Deprecation 헤더
22. OPTIONS 처리
23. HEAD 메소드 지원
24. 304 Not Modified
25. HATEOAS (선택)

### TM2 GraphQL/gRPC 계약 (체크 20)
**Grep**: `typeDefs|resolvers|Schema|gql|graphql|@Resolver|proto|grpc`
1. Schema 명확 (type/input/enum)
2. N+1 방지 (DataLoader)
3. 필드 해석자 안전
4. Mutation 멱등성
5. Subscription 정리
6. 깊이 제한 (depth limiting)
7. 복잡도 제한 (cost analysis)
8. Federation 신중
9. Error format 일관
10. Nullable 명확
11. gRPC proto 버전
12. gRPC backward 호환
13. gRPC streaming (server/client/bidi)
14. gRPC deadline / timeout
15. gRPC interceptor (auth / log)
16. gRPC error code 표준
17. gRPC reflection (개발만)
18. gRPC-Web 지원 (필요 시)
19. Schema 문서화
20. Schema diff 자동

### TM3 API 버전 호환성 (체크 15)
**Grep**: `/v1/|/v2/|version|deprecated|breaking`
1. URI 버전 (`/api/v1/`)
2. Header 버전 (`Accept-Version`)
3. Breaking change 식별
4. Deprecation 기간 6+ 개월
5. Deprecation 헤더 (Sunset)
6. Migration 가이드
7. 클라이언트 SDK 자동 업데이트
8. 백워드 호환 default
9. Forward 호환 (unknown field 무시)
10. 응답 필드 추가만 (제거 X)
11. 응답 필드 타입 유지
12. enum 추가만
13. Required → Optional 가능 / 역은 X
14. 의무 필드 추가 시 default
15. Major version 별도 라우트

### TM4 API 문서 (체크 12)
**Grep**: `OpenAPI|swagger|@ApiOperation|@ApiResponse|jsdoc`
1. OpenAPI/Swagger 자동 생성
2. 모든 엔드포인트 문서
3. 요청/응답 스키마
4. 예시 명시
5. 에러 응답 명시
6. 인증 명시
7. Rate limit 명시
8. 호환성 정책 명시
9. SDK 자동 생성 (openapi-generator)
10. Mock 서버 가능
11. CI에 docs 검증
12. Changelog 자동

### TM5 쿼리 품질 (체크 25)
**Grep**: `find|findOne|select|join|include|populate|leftJoin|raw`
1. N+1 방지 (eager loading / DataLoader)
2. SELECT 컬럼 명시 (`*` 회피)
3. WHERE 인덱스 활용
4. JOIN 인덱스 활용
5. LIKE prefix만 (`abc%` ✓, `%abc%` X)
6. Pagination LIMIT/OFFSET (큰 OFFSET 회피)
7. Cursor-based pagination
8. EXISTS vs IN
9. UNION ALL vs UNION
10. DISTINCT 회피 (GROUP BY 우선)
11. Subquery vs JOIN
12. Window function 활용
13. Index hint 신중
14. Query plan 검토
15. Slow query 로깅
16. Connection pool 적정
17. Read replica 활용
18. Sharding 키 일관
19. Bulk insert (executeMany)
20. Bulk update (transaction)
21. Bulk delete (chunk)
22. UPSERT 활용
23. Materialized view
24. Query timeout
25. Prepared statement 캐시

### TM6 트랜잭션 (체크 20)
**Grep**: `transaction|BEGIN|COMMIT|ROLLBACK|SERIALIZABLE|isolation`
1. 명시적 트랜잭션 시작/종료
2. try/catch + ROLLBACK
3. 격리 수준 적정 (READ COMMITTED / REPEATABLE READ / SERIALIZABLE)
4. 트랜잭션 범위 최소
5. 외부 호출 트랜잭션 외부
6. Deadlock 재시도
7. Lock timeout
8. Optimistic locking (version field)
9. Pessimistic locking (SELECT FOR UPDATE)
10. 분산 트랜잭션 회피 (Saga 패턴)
11. Outbox pattern
12. Compensating transaction
13. 2PC 신중
14. Idempotent 트랜잭션
15. Savepoint 활용
16. Nested transaction 명확
17. Transaction log 모니터
18. Long-running 차단
19. Connection 누수 차단
20. Auto-commit 회피

### TM7 스키마 (체크 20)
**Grep**: `CREATE TABLE|ALTER TABLE|migration|schema|column`
1. 정규화 (1NF/2NF/3NF) 적정
2. 비정규화 신중 (성능 우선 시)
3. Primary key (UUID v7 권장)
4. Foreign key + ON DELETE 정책
5. UNIQUE 제약
6. CHECK 제약
7. NOT NULL 의무
8. Default value 명확
9. Index 적정 (PK / FK / WHERE / ORDER BY)
10. Composite index 순서 (가장 자주 사용 first)
11. Partial index
12. Index size 모니터
13. Column 타입 적정 (BIGINT vs INT)
14. Timestamp UTC 저장
15. Soft delete 컬럼 (deleted_at)
16. Audit 컬럼 (created_at / updated_at / created_by)
17. JSON/JSONB 적정 사용
18. Enum vs Lookup table
19. Computed column
20. Partition 활용 (대용량)

### TM8 ORM 패턴 (체크 15)
**Grep**: `Sequelize|Prisma|TypeORM|Mongoose|@Entity|@Column`
1. Lazy vs Eager 명확
2. N+1 자동 감지
3. ORM 캐싱 (first-level / second-level)
4. Migration auto-generate
5. Migration rollback 테스트
6. Seed data 분리
7. Connection pool 설정
8. Read replica 라우팅
9. Transaction propagation
10. Soft delete 글로벌
11. Audit 자동 (hook)
12. Validation hook
13. ORM raw 회피
14. Multi-tenant (schema vs row)
15. ORM 버전 호환

### TM9 도메인 모델 (체크 20)
**Grep**: `class|entity|aggregate|domain|model|valueObject`
1. Entity vs Value Object 명확
2. Aggregate root 명확
3. Aggregate boundary (트랜잭션 단위)
4. Repository pattern
5. Domain Service vs Application Service
6. Anemic Domain Model 회피
7. Rich Domain Model (행위 포함)
8. Bounded Context
9. Ubiquitous Language
10. Domain Event
11. Event Sourcing 신중
12. CQRS 신중
13. Specification pattern
14. Factory pattern
15. Builder pattern
16. Strategy pattern
17. State pattern (상태 머신)
18. Visitor pattern (이중 dispatch)
19. Domain primitive (예: Email / Money)
20. Aggregate 크기 적정

### TM10 상태 머신 (체크 12)
**Grep**: `status|state|transition|enum|workflow`
1. 가능 상태 enum
2. 가능 전이 명시 (matrix)
3. 불가능 전이 차단
4. 전이 이력 audit
5. State machine 라이브러리 (xstate)
6. Guard condition (전이 조건)
7. Side effect (action)
8. Compound state
9. Parallel state
10. History state
11. State 시각화
12. State 테스트 (모든 경로)

### TM11 검증 (체크 18)
**Grep**: `validate|Zod|Joi|class-validator|@IsString|schema|input`
1. 입력 스키마 검증 (Zod/Joi/class-validator)
2. Type-safe 검증
3. 비즈니스 규칙 검증 분리
4. 검증 에러 명확
5. 다국어 에러 메시지
6. 부분 검증 (PATCH)
7. 중첩 객체 검증
8. 배열 검증
9. Custom validator
10. Async validator (DB lookup)
11. 검증 성능 (early exit)
12. 검증 결과 캐싱
13. 검증 우회 차단
14. Type coercion 명확
15. Strict mode (unknown field 거부)
16. 검증 라이브러리 최신
17. Schema reuse (DRY)
18. 검증 vs sanitization 분리

### TM12 멱등성 (체크 15)
**Grep**: `idempotent|idempotency|Idempotency-Key|retry|duplicate`
1. Idempotency-Key 헤더 지원
2. 중복 요청 24h+ 캐시
3. POST 멱등성 (key 기반)
4. PUT 멱등성 기본
5. DELETE 멱등성 기본 (404 OK)
6. 재시도 안전 (at-most-once)
7. 결제 멱등성 (필수)
8. Webhook 멱등성
9. 큐 메시지 멱등성
10. 동일 결과 보장
11. 부분 실패 처리
12. Idempotency token 만료
13. 충돌 시 409 응답
14. 비동기 작업 멱등성
15. 멱등성 audit

### TM13 동시성 (체크 18)
**Grep**: `lock|mutex|semaphore|atomic|race|deadlock|async|concurrent`
1. Race condition 식별
2. Critical section lock
3. Lock granularity (row vs table)
4. Deadlock 방지 (lock order)
5. Lock timeout
6. Optimistic vs Pessimistic
7. CAS (Compare-And-Swap)
8. Atomic operation
9. Read-write lock
10. Distributed lock (Redis / ZooKeeper)
11. Lock renewal
12. Lock leak 방지 (finally)
13. Spurious wakeup 처리
14. Thread-safe collection
15. Immutable data
16. Actor model
17. CSP (channels)
18. Lock-free 자료구조

### TM14 에러 처리 (체크 20)
**Grep**: `try|catch|throw|error|errorHandler|onError|CircuitBreaker`
1. 모든 async 함수 try/catch
2. Error class 계층 (custom)
3. Error context (원인 / 위치 / 사용자)
4. Error 로깅 (stack trace)
5. 사용자에게 안전한 메시지
6. 에러 응답 표준 (RFC 7807)
7. 재시도 (exponential backoff)
8. Circuit Breaker (Hystrix / opossum)
9. Bulkhead (격리)
10. Timeout
11. Fallback
12. Graceful degradation
13. Panic 회피 (Go)
14. Unhandled rejection 처리
15. SIGTERM 처리 (graceful shutdown)
16. Health check (liveness / readiness)
17. Error budget
18. Error rate alert
19. Error grouping (Sentry)
20. Error replay

### TM15 큐/이벤트 (체크 15)
**Grep**: `kafka|rabbitmq|sqs|pubsub|consumer|producer|topic|exchange`
1. At-least-once delivery
2. Idempotent consumer
3. Dead Letter Queue
4. Retry policy (exponential backoff)
5. Poison message 처리
6. Message ordering (partition key)
7. Message size 제한
8. Backpressure
9. Consumer lag 모니터
10. Producer acks
11. Schema registry (Avro / Protobuf)
12. Schema evolution
13. Saga pattern
14. Event Sourcing
15. Outbox pattern

### TM16 메모리/I/O 효율 (체크 15)
**Grep**: `Buffer|stream|pipe|readFile|writeFile|memory|gc`
1. Stream 활용 (대용량 파일)
2. Buffer 크기 적정
3. Memory leak (closure / event listener)
4. WeakMap / WeakRef
5. GC 압박 감소 (Object pool)
6. Off-heap memory
7. Native module 신중
8. Cluster / Worker thread
9. CPU profiling
10. Heap snapshot 분석
11. RSS 모니터
12. OOM 방지 (limit)
13. Pagination 청크
14. Batch processing
15. Background job

### TM17 캐싱 (체크 18)
**Grep**: `cache|redis|memcached|ttl|invalidate|stale`
1. 캐시 키 명확 (namespace)
2. TTL 적정
3. Cache stampede 방어 (lock)
4. Stale-while-revalidate
5. Cache invalidation 정책
6. Write-through / Write-back / Write-around
7. CDN 캐싱 (static)
8. ETag / If-None-Match
9. Vary 헤더
10. Cache aside pattern
11. Distributed cache
12. Cache warming
13. Cache hit ratio 모니터
14. Cache size limit (LRU / LFU)
15. Cache poisoning 차단
16. Cache key collision
17. Cache invalidation cascade
18. Cache vs Source of Truth 명확

### TM18 비동기/병렬 (체크 12)
**Grep**: `async|await|Promise|Promise\.all|Promise\.allSettled|setImmediate|setTimeout`
1. async/await 일관
2. Promise.all (병렬 가능 시)
3. Promise.allSettled (부분 실패 허용)
4. Sequential vs Parallel 의도
5. Concurrency limit (p-limit)
6. async 함수 try/catch
7. Unhandled rejection
8. Promise leak (no await)
9. Event loop 블로킹 회피
10. Worker thread (CPU-bound)
11. Generator / iterator
12. Backpressure

### TM19 입력 검증 (TM11과 일부 겹침, 보안 중점 — 체크 10)
1. SQL injection 방어 (TM5 정합)
2. NoSQL injection
3. Command injection
4. Path traversal
5. ReDoS 방어
6. Prototype pollution
7. SSRF 방어
8. XXE 방어
9. Type confusion
10. Large payload 차단

### TM20 인증/인가 (TM 보안 중점 — 체크 12)
1. 미들웨어 일관
2. JWT 검증
3. Session 검증
4. CSRF 토큰
5. RBAC 명확
6. IDOR 방어
7. Auth fail-closed
8. Auth 로그
9. Brute force 차단
10. API key 검증
11. mTLS
12. OAuth 2.0

### TM21 시크릿 관리 (체크 10)
1. .env 모든 시크릿
2. .env Git ignore
3. Vault / Secrets Manager
4. 환경별 분리
5. Rotation
6. 로그 마스킹
7. 메모리 zeroization (가능 시)
8. 클라이언트 노출 X
9. .env.example placeholder
10. CI/CD masking

### TM22 로깅 (체크 15)
**Grep**: `winston|pino|bunyan|console\.log|logger`
1. 구조화 (JSON)
2. 로그 레벨 명확 (trace/debug/info/warn/error/fatal)
3. Correlation ID (request ID)
4. Span ID (트레이싱)
5. 시크릿 마스킹 자동
6. PII 마스킹
7. 외부 저장 (CloudWatch / Datadog / Loki)
8. 보관 기간
9. 로그 검색 인덱스
10. 로그 ingestion rate
11. 샘플링 (대용량)
12. 동기 vs 비동기
13. Throughput
14. 비용 모니터
15. 보안 로그 분리

### TM23 메트릭 (체크 12)
**Grep**: `prometheus|metric|gauge|counter|histogram|summary`
1. RED metrics (Rate / Errors / Duration)
2. USE metrics (Utilization / Saturation / Errors)
3. SLI (Service Level Indicator)
4. SLO (Objective)
5. Error budget
6. Counter 단조 증가
7. Gauge 정확성
8. Histogram bucket
9. Cardinality 제어 (label)
10. Push vs Pull
11. Aggregation 정확
12. 대시보드 자동

### TM24 트레이싱 (체크 10)
**Grep**: `opentelemetry|jaeger|trace|span|tracer`
1. OpenTelemetry SDK
2. Span 생성 (단위 작업)
3. Span attribute
4. Parent-child 관계
5. Sampling
6. W3C Trace Context 헤더
7. 외부 호출 propagation
8. DB 쿼리 span
9. Error span 표시
10. Trace 검색

---

