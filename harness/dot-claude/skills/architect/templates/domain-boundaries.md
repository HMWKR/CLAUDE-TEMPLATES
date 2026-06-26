# 도메인 경계 규칙 템플릿

> `.claude/rules/domain-boundaries.md`로 저장

---

## Import 허용 매트릭스 템플릿

```markdown
# 도메인 경계 규칙

## Import 허용 매트릭스

| 도메인 | import 허용 | import 금지 |
|--------|-------------|-------------|
| **shared** | 외부 라이브러리만 | 모든 도메인 (순환 방지) |
| **{도메인A}** | shared, {허용 목록} | {금지 목록} |
| **{도메인B}** | shared, {허용 목록} | {금지 목록} |

## 규칙

### 기본 원칙
1. `shared/`는 어떤 도메인도 import하지 않는다 (순환 방지)
2. Worker 에이전트 간 직접 import 금지
3. 모든 도메인 간 통신은 `shared/types/`의 타입 계약을 통해 수행

### 예외
- `app/` 라우트는 모든 도메인을 import 가능 (thin adapter 역할)
- {프로젝트 고유 예외}

### 자동 강제
- `eslint-plugin-boundaries` 또는 커스텀 lint 규칙 적용
- pre-commit hook으로 도메인 경계 검증
- CI/CD 파이프라인에 경계 검증 단계 포함
```

---

## 경계 설계 원칙

### 1. 격리 수준 결정

| 수준 | 설명 | 적용 대상 |
|:---:|------|----------|
| 완전 격리 | shared/ 외 import 완전 금지 | 복잡 하위 시스템 (예: AI 파이프라인) |
| 부분 격리 | 특정 도메인만 제한적 허용 | 일반 Worker 도메인 |
| 개방 | 대부분 import 허용 | app/ 라우트 (thin adapter) |

### 2. 통신 방식

| 방식 | 설명 | 적용 |
|------|------|------|
| 타입 계약 | `shared/types/`로 인터페이스 정의 | 모든 도메인 간 |
| Server Action | 함수 호출 형태의 서버 통신 | frontend → backend |
| API Route | HTTP 엔드포인트 | 외부 서비스 연동 |

### 3. 위반 감지

```
[사전 예방] eslint-plugin-boundaries → import 시 경고/에러
[사전 예방] pre-commit hook → 커밋 전 검증
[사후 감지] Architect Evaluator → 코드 리뷰 시 검증
[사후 감지] CI/CD → 빌드 파이프라인에서 검증
```
