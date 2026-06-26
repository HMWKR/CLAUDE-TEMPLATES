# 페르소나 공통 스키마 — 정상 + Adversarial 양 모드

> STEP ④ 페르소나 부트스트랩에서 사용. 정상 페르소나와 Adversarial 페르소나 모두 본 공통 스키마 + 모드별 베이스 ([`_normal-base.md`](./_normal-base.md) / [`_adversarial-base.md`](./_adversarial-base.md))를 따른다.

---

## 페르소나 정의 형식

```yaml
---
name: <persona_name>           # 예: admin-realistic, customer-adversarial
mode: normal | adversarial     # 모드
role_signal: <라우트 prefix 또는 라이브러리>
---

# Persona: <persona_name>

## 정체성
- **역할**: <admin/seller/customer/guest/super-admin/...>
- **권한 수준**: <high/med/low/none>
- **시작 라우트**: <첫 진입 URL>
- **로그인 필요?**: yes/no

## 행동 원칙
<3-5줄 — 이 페르소나의 행동 철학>

## 여정 (Journey)
1. <시작 액션>
2. <중간 액션>
...
N. <종료 액션>

## 검수 우선 element
- <element 1>: <어떤 행동>
- <element 2>: <어떤 행동>

## 카오스 축 적용 (Adversarial 모드만)
- 축 #N: <적용 방식>
- ...

## 종료 조건
- <성공 조건>
- <실패 조건 — 결함 발견 시 라운드 컨텍스트 누적>
```

---

## 5컬럼 표 (STEP ④ 인터랙티브 출력)

```markdown
| 페르소나명 | 모드 | 시그널 출처 | 행동 패턴 요약 | 근거 |
|---|---|---|---|---|
| <name> | 정상/Adversarial | <라우트·라이브러리> | <여정 1줄> | <왜 이 프로젝트에 필요한가> |
```

---

## 자동 도출 매핑

STEP ② 디스커버리 시그널 → 페르소나 후보:

| 시그널 | 정상 페르소나 후보 | Adversarial 페르소나 후보 |
|---|---|---|
| 라우트 `/admin/*` | admin-realistic | admin-adversarial (권한 우회) |
| 라우트 `/seller/*` | seller-realistic | seller-adversarial (다른 seller 데이터) |
| 라우트 `/dashboard/*` (multi-role) | dashboard-power-user | dashboard-misuse |
| 라우트 `/customer/*` 또는 protected | customer-realistic | customer-careless (실수 잦음) |
| protected route + 비-로그인 시작점 | guest-realistic (회원가입 흐름) | guest-attacker (직접 admin URL) |
| `/api/*` (외부 호출) | (정상 페르소나 N/A — UI 검수만) | api-direct-caller (UI 우회 API) |
| 다국어 (`i18next`) | locale-switcher | locale-mismatch (잘못된 locale) |
| 결제 (`stripe`) | buyer-realistic | payment-race (빠른 연타) |

→ 이 표는 자동 1차 추천. STEP ④ 3+안 조합으로 사용자 선택 후 확정.

---

## 페르소나 자동 부트스트랩 안전성

페르소나 .md 자동 생성 시 (`<project>/.claude/agents/<name>.md`):

1. **3단계 승인**:
   - (a) 파일명 미리보기
   - (b) 내용 미리보기
   - (c) 최종 승인
2. **표준 스키마 검증**: 위 형식 따름
3. **lint**: 글로벌 `.claude/agents/*.md` 표준 검증

→ Poisoning(4대 실패 모드) 차단.

---

## live-verify-loop과의 차이

| 차원 | live-verify-loop `_personas/` | ultradetail-walk `_personas/` |
|---|---|---|
| 모드 | 9 검수 모드 (UI/UX·DB·코드 품질·API·a11y·perf·SEO·보안·통합) | 정상 + Adversarial 양 모드 |
| 페르소나 베이스 | 검수 모드별 9개 + _common | 정상·Adversarial 각 N개 + _common |
| 프로젝트 적응 | 9 모드 중 선택 | 6 시그널 채널에서 자동 도출 |
| Adversarial 행동 | 부분적 (보안 모드만) | **8축 카오스 전체** |
| 자동 부트스트랩 | 검수 모드별 표준 템플릿 | 시그널·페르소나·카오스 자동 |

→ 두 스킬은 페르소나 개념을 공유하지만 **각자 self-contained**. 본 디렉토리는 ultradetail-walk 전용.
