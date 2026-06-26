---
name: backend-review
description: |
  백엔드 코드 PR/diff 정적 검수 통합 스킬. 24 specialists 7 Tier 병렬 (API 4 + DB 4 + 비즈니스로직 4 + 동시성/에러 3 + 성능 3 + 보안 3 + Observability 3).
  ~600 체크리스트 + Backend Quality Score 0-100 (24차원 가중치) + 7등급.
  Use when asked to "backend review", "백엔드 리뷰", "백엔드 검수", "서버 코드 리뷰", "API 리뷰", "/backend-review".
  NOT for: 프론트엔드 (use frontend-review), 보안만 (use security-review), CE (use ce-reviewer), 외부 일반 (use code-review plugin).
  Modes: basic (~50) / --full (~200) / --all (~600 24 specialists). code-review 정합 effort=low/medium/high/max + --comment PR inline.
user_invocable: true
---

# Backend Review — 백엔드 전수 코드 리뷰

> **P3-7b 신설 (2026-05-26)**: 외부 code-review (45줄) 자체 대체. frontend-review 짝.
> **공통**: `~/.claude/skills/_core/protocols.md` + `_core/roles.md`

## ⚠️ Uncompromising Rigor §1-§4 정합

---

## 1. 책임 경계

| 자산 | 영역 |
|---|---|
| **`backend-review`** (본) | **백엔드 PR 정적 24 specialists** (API/DB/비즈니스/동시성/에러/성능/보안/Observability) |
| `frontend-review` | 프론트엔드 PR 정적 18 specialists |
| `security-review` (P3-7a) | 보안 전수 24 specialists |
| `code-review` (외부 플러그인) | 일반 정적 (45줄 짧음) |
| `db-review` (P3-7f) | DB 전수 24 specialists (본 스킬 Tier 2 확장) |
| `api-review` (P3-7e) | API 전수 24 specialists (본 스킬 Tier 1 확장) |
| `performance-review` (P3-7h) | 서버 성능 전수 24 specialists |

본 스킬 = **백엔드 통합** / 다른 스킬 = 특정 영역 깊이.

---

## 2. 실행 모드

| 모드 | effort | TM | 항목 | 시간 |
|:--:|:--:|:--:|:--:|:--:|
| basic | low | 1 | ~50 | 10분 |
| --full | medium | 7 | ~200 | 25분 |
| --all | high | 24 | ~600 | 60분 |
| (신규) | max | 24+uncertain | ~600+ | 90분 |

---

## 3. 24 Specialists

```
Tier 1: API 계약 (4 TM) — 20%
├─ TM1 REST 설계 (HTTP semantics / status codes / verbs)
├─ TM2 GraphQL/gRPC 계약 (schema / federation)
├─ TM3 API 버전 호환성 (deprecation / breaking changes)
└─ TM4 API 문서 (OpenAPI / 예시 / 에러 명세)

Tier 2: 데이터 계층 (4 TM) — 18%
├─ TM5 쿼리 품질 (N+1 / 인덱스 / Join)
├─ TM6 트랜잭션 (격리 수준 / 락 / 분산)
├─ TM7 스키마 (정규화 / 제약 / 마이그)
└─ TM8 ORM 패턴 (lazy/eager / 캐싱)

Tier 3: 비즈니스 로직 (4 TM) — 16%
├─ TM9 도메인 모델 (DDD / Entity / VO)
├─ TM10 상태 머신 (status transitions)
├─ TM11 검증 (입력 / 비즈니스 규칙)
└─ TM12 멱등성 (idempotency / 재시도 안전)

Tier 4: 동시성/에러 (3 TM) — 14%
├─ TM13 동시성 (Race / Deadlock / Lock)
├─ TM14 에러 처리 (try/catch / 재시도 / Circuit Breaker)
└─ TM15 큐/이벤트 (Kafka/SQS / at-least-once)

Tier 5: 성능 (3 TM) — 12%
├─ TM16 메모리/I/O 효율
├─ TM17 캐싱 전략 (Redis / CDN / 메모리)
└─ TM18 비동기/병렬 (async/await / Promise.all / Worker)

Tier 6: 보안 (3 TM) — 12%
├─ TM19 입력 검증 (Zod/Joi / SQL injection)
├─ TM20 인증/인가 (미들웨어 / RBAC)
└─ TM21 시크릿 관리 (env / vault)

Tier 7: Observability (3 TM) — 8%
├─ TM22 로깅 (구조화 / 레벨 / 마스킹)
├─ TM23 메트릭 (Prometheus / SLI)
└─ TM24 트레이싱 (OpenTelemetry / span)
```

---

> 24 TM(TM1-TM24) 전체 체크리스트 ~600항목 + grep 패턴은 `references/checklists.md` 참조. Tier 개요는 §3, 가중치는 §6 참조.

## 5. Stage 0-2 작업 절차

```
Stage 0: 백엔드 코드베이스 수집
- Glob 백엔드 (routes/ controllers/ services/ models/ migrations/)
- 의존성 (Express/Fastify/Nest/Django/Rails)
- DB 스키마 + 마이그
- middleware / interceptor

Stage 1: 24 specialists 병렬 분석

Stage 2: Lead 통합 + Backend Quality Score
```

---

## 6. Backend Quality Score (24차원 가중치)

| Tier | 가중 | TMs |
|---|:--:|---|
| 1 API 계약 | 20% | TM1-4 |
| 2 데이터 계층 | 18% | TM5-8 |
| 3 비즈니스 로직 | 16% | TM9-12 |
| 4 동시성/에러 | 14% | TM13-15 |
| 5 성능 | 12% | TM16-18 |
| 6 보안 | 12% | TM19-21 |
| 7 Observability | 8% | TM22-24 |

등급: S 95+ / A+ 90+ / A 85+ / B+ 80+ / B 70+ / C 50+ / F <50

---

## 7. 출력 형식 (frontend-review/security-review 동일 패턴)

Blockers / Warnings / Suggestions + Tier별 점수 + 라우팅 권고 + Approve/Conditional/Request Changes

---

## 8. 10단계 파이프라인 View

Step 1 Input → 2 Classifier (effort) → 3 Router (24 TM) → 4 Context (audit-data) → 5 Planner → 6 Tool (Read/Grep/Bash) → 7 Draft (24 reports) → 8 Critic (Lead + 24D Score) → 9 Refiner → 10 Output

---

## 9. code-review 정합 옵션

- `--effort=low|medium|high|max` (basic / --full / --all / +uncertain)
- `--comment --pr=N` PR inline (Blockers=Request Changes / 나머지=inline)
- `--dry-run`

---

## 10. 옵션 플래그

- `--focus=<tier>` (api / data / domain / concurrency / performance / security / observability)
- `--loop` 수렴 루프
- `--include=<glob>` / `--exclude=<glob>`

---

## 11. 라우팅 정책

| 발견 | 권고 |
|---|---|
| 보안 깊은 | `security-review` (24 sp) |
| 프론트엔드 영향 | `frontend-review` |
| 라이브 검증 | `playwright-qa-expert` |
| API 깊은 | `api-review` (P3-7e) |
| DB 깊은 | `db-review` (P3-7f) |
| 성능 깊은 | `performance-review` (P3-7h) |
| 풀스택 | `fullstack-review` (P3-7c) |

---

## 12. Uncompromising Rigor §1-§4 정합 (frontend-review/security-review 동일)

## 13. 환각 방지 — 파일:라인 명시 의무

## 14. 참조

- `code-review` (외부 플러그인, 45줄 — 본 스킬이 대체)
- `frontend-review` (P3-6, 18 sp, FE 짝)
- `security-review` (P3-7a, 24 sp, 보안 깊은)
- 인사이트 1 / 회고 .thoughts/
