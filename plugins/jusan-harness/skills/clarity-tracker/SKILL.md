---
name: clarity-tracker
description: |
  Microsoft Clarity 통합 설치 + 운영 wrapper. 세션 리플레이 / 히트맵 / Dead clicks / Rage clicks / Excessive scrolling / Quick backs / Form interaction 실사용자 행동 분석.
  Next.js Script 컴포넌트 자동 삽입 + PII 마스킹 (Strict/Balanced) + Consent API v2 (EU/UK/CH) + GA4 통합.
  Use when "clarity", "session replay", "히트맵", "dead click", "사용자 행동 분석", "/clarity-tracker", "마이크로소프트 클래리티".
  NOT for: 정량 퍼널 (use ga4-funnel), 라이브 시뮬레이션 (use playwright-uiux-audit), AI UI 리뷰 (use vercel-guidelines).
user_invocable: true
---

# Microsoft Clarity Tracker Wrapper

> **신설 (2026-05-26 web-audit-pipeline #4)** — Clarity 설치 + 마스킹 + 운영 wrapper.
> **외부 도구**: clarity.microsoft.com (계정 발급 필요 — 사용자 직접)
> **Claude 자동화**: Next.js Script 컴포넌트 삽입 + 마스킹 정책 + Consent API + GA4 통합

## ⚠️ Uncompromising Rigor §1-§4 정합

- **§1**: 브라우저 우선순위는 rules/uncompromising-rigor §1(2026-07-07 Playwright MCP 전역 우선)을 따른다. Clarity 대시보드처럼 Microsoft 로그인 세션 재사용이 필요할 때만 Chrome MCP.
- **§2**: 마스킹 "이 정도면 충분" 차단 — 이메일/전화/카드/SSN/검색어/메모는 무조건 마스킹
- **§3**: PII 마스킹 누락은 자동 High. Dead/Rage clicks 1건이라도 발견은 Medium 이상
- **§4**: 매 라운드 5단계 분석 (이전 세션 재조회 → 새 friction 식별 → Adversarial walk → 자기 정당화 → 신규)

## 1. 책임 경계

| 자산 | 영역 |
|---|---|
| **`clarity-tracker`** (본 wrapper) | Clarity 설치 + 마스킹 + 행동 분석 운영 |
| `ga4-funnel` | 정량 퍼널 (이탈률 / 전환율) — 보완 |
| `playwright-uiux-audit` | 라이브 시뮬레이션 (Claude가 직접 walk) |
| `frontend-review` Tier 1 (UI 4 sp) | UI 코드 검수 |
| `web-audit-pipeline` | 5 도구 통합 |

**라우팅**: 실사용자 정성 (세션) → 본 wrapper / 정량 (퍼널) → `ga4-funnel` / Claude 시뮬레이션 → `playwright-uiux-audit`.

## 2. 사용자 액션 (Claude 자동화 불가)

```
1. https://clarity.microsoft.com/ 접속
2. Microsoft 계정 로그인
3. 새 프로젝트 생성 (프로젝트 이름 / 사이트 URL)
4. PROJECT_ID 발급 받기 (예: abc123xyz)
5. PROJECT_ID 를 Claude 에게 전달
```

## 3. Claude 자동화 (PROJECT_ID 받은 후)

### 3.1 Next.js Script 컴포넌트 삽입

`references/clarity-script.tsx` 참조 — `app/layout.tsx` 에 자동 삽입.

### 3.2 마스킹 정책 의무

| 마스킹 레벨 | 설정 | 적용 영역 |
|:-:|---|---|
| **Strict** (권장) | 모든 텍스트 + 입력 마스킹 | 의료 / 금융 / 법률 |
| **Balanced** (기본) | 입력 + 민감 텍스트 마스킹 | 커머스 / SaaS |
| **Relaxed** | 명시 영역만 마스킹 | 마케팅 페이지 |

**무조건 마스킹** (강등 불가):
- 이메일 / 전화번호 / 카드번호 / SSN / 주민번호
- 비밀번호 / API key / 토큰 / 검색어 / 개인 메모
- `data-clarity-mask="true"` 속성으로 명시

### 3.3 Consent API v2 (EU/UK/CH 의무)

```typescript
// EU/UK/CH 방문자 동의 신호
window.clarity('consentv2', {
  ad_storage: 'granted' | 'denied',
  analytics_storage: 'granted' | 'denied'
});
```

### 3.4 GA4 통합

Clarity 대시보드에서 Google Analytics integration:
```
Settings → Setup → Google Analytics integration → Get Started
→ Google 로그인 → GA4 property 선택 → Save
```

## 4. 10단계 파이프라인 View

```
Step 1 Input   : PROJECT_ID + 사이트 도메인 + 마스킹 레벨
Step 2 Classifier : 도메인 유형 (의료/금융 → Strict, 커머스 → Balanced)
Step 3 Router : Script 삽입 / 마스킹 설정 / Consent / GA4 통합
Step 4 Context : 프로젝트 구조 (Next.js App Router / Pages Router / 기타)
Step 5 Planner : 마스킹 영역 자동 식별 (input / form / textarea / 이메일 grep)
Step 6 Tool : Script 컴포넌트 Edit + 마스킹 속성 추가
Step 7 Draft : 변경 파일 목록 + 마스킹 적용 항목
Step 8 Critic : §3 정합 — 마스킹 누락 자동 High
Step 9 Refiner : Consent API + GA4 통합 추가 권고
Step 10 Output : 보고서 + 검증 체크리스트
```

## 5. Clarity 대시보드 7대 분석 항목 (가이드 정합)

| 항목 | 보는 이유 |
|---|---|
| **Heatmaps** | CTA, 메뉴, 가격표, 폼 중 실제 클릭 위치 |
| **Session recordings** | 사용자가 어디서 망설이고 되돌아가는지 |
| **Dead clicks** | 눌렀는데 아무 반응 없는 요소 |
| **Rage clicks** | 답답해서 반복 클릭하는 구간 |
| **Excessive scrolling** | 정보 구조가 너무 길거나 핵심 CTA 못 찾음 |
| **Quick backs** | 들어왔다가 바로 돌아가는 페이지 |
| **Form interaction** | 입력 중단, 오류 메시지, 필드 순서 문제 |

## 6. 분석 질문 (Claude → 사용자)

```
1. 사용자가 첫 화면에서 핵심 CTA 클릭하는가?
2. 가격/문의/가입 버튼 찾는 데 시간이 오래 걸리는가?
3. 모바일 메뉴 열고 원하는 페이지로 이동하는가?
4. 폼 입력 중 어느 필드에서 멈추는가?
5. 버튼처럼 보이지만 클릭되지 않는 요소가 있는가?
6. 결제/가입 직전에 되돌아가는가?
7. 스크롤은 깊게 하지만 CTA 클릭은 없는가?
```

## 7. 출력 형식

```markdown
## Clarity Report — <date>

### Setup
- PROJECT_ID: <X>
- 마스킹 레벨: Strict / Balanced / Relaxed
- 마스킹 적용 영역: N건
- Consent API v2: 활성 / 비활성
- GA4 integration: 활성 / 비활성

### Behavior Findings (Clarity 대시보드)

#### P0 (전환 차단)
- **Dead clicks on "구매" 버튼** — 시간/세션 X건
  - 추정: 클릭 이벤트 미바인딩 또는 z-index 충돌

#### P1 (큰 영향)
- **Rage clicks on 가격표** — X건
- **Form abandonment at "전화번호" 필드** — X%
- **Quick backs at /signup** — X% (3초 이내)

#### P2 (사용성 개선)
...
```

## 8. 옵션

| 옵션 | 효과 |
|---|---|
| `--masking=strict` | Strict 마스킹 |
| `--masking=balanced` (default) | Balanced 마스킹 |
| `--with-consent` | Consent API v2 코드 자동 삽입 |
| `--with-ga4` | GA4 integration 가이드 |
| `--exclude-admin` | /admin/* tracking 제외 |

## 9. 라우팅 다른 스킬

| 작업 | 권고 스킬 |
|---|---|
| 정량 퍼널 분석 | `ga4-funnel` |
| Claude 라이브 시뮬레이션 | `playwright-uiux-audit` |
| 코드 UI 리뷰 | `vercel-guidelines` / `frontend-review` |
| 5 도구 통합 | `web-audit-pipeline` |
