# 6 시그널 채널 — 결함 카테고리 객관 도출

> STEP ② 디스커버리에서 본 매핑을 사용. 각 채널은 객관 시그널 → 카테고리 후보 매핑.
> LLM 임의 판단 X. 시그널이 발견되면 카테고리 강제 도출.

---

## 채널 #1: 라우트

| 시그널 (감지 방법) | 도출 카테고리 |
|---|---|
| `/admin/*` 라우트 발견 | 권한 분기 우회 / admin 전용 기능 호환성 |
| `/seller/*` 또는 `/dashboard/*` | seller 권한 분기 / multi-role 데이터 격리 |
| `/checkout/*`, `/payment/*` | 결제 race condition / 중복 결제 / 환불 unclear |
| `/auth/*`, `/login`, `/signup` | CSRF / 세션 만료 / 로그아웃 후 protected 접근 |
| `/api/*` (Next.js API routes) | API status drift / pagination boundary / rate limit |
| `/[slug]` 또는 dynamic segment | 잘못된 slug / 404 처리 / 권한 없는 slug 접근 |
| protected route + middleware | 미들웨어 우회 / token 조작 |

**감지 명령**:
```bash
# Next.js app router
ls app/ 2>/dev/null
# Pages router
ls pages/ 2>/dev/null
# React Router
grep -rE "<Route\s+path=" src/ 2>/dev/null
```

---

## 채널 #2: 입력 type

| 시그널 (DOM 검사) | 도출 카테고리 |
|---|---|
| `<input type="text">` | 길이 chaos (max+1, 빈값) / SQL injection / XSS payload |
| `<input type="number">` | 음수 / overflow / NaN / Infinity / 소수점 |
| `<input type="email">` | 형식 위반 / 매우 긴 도메인 / + alias |
| `<input type="password">` | 길이 / 특수문자 / paste 차단 / autofill |
| `<input type="file">` | 크기 boundary / MIME 위장 / extension mismatch / 0byte |
| `<input type="date">`, `time` | 미래/과거 boundary / 잘못된 형식 |
| `<input type="search">` | 검색 query escape / 무한 스크롤 |
| `<select>`, `<textarea>` | option 외 값 / 매우 긴 텍스트 |
| `[contenteditable]` | XSS / paste HTML |

**감지 명령**:
```javascript
mcp__playwright__browser_evaluate({
  function: `() => Array.from(document.querySelectorAll('input, select, textarea, [contenteditable]')).map(e => ({type: e.type, name: e.name, required: e.required}))`
})
```

---

## 채널 #3: 라이브러리 (package.json)

| 라이브러리 | 알려진 함정 | 도출 카테고리 |
|---|---|---|
| `next-auth` (NextAuth) | CSRF / 세션 race / OAuth callback | 인증 chaos |
| `@supabase/supabase-js` | RLS 우회 / anon key 노출 / signed URL 만료 | 권한 chaos |
| `@stripe/stripe-js` | 결제 race / webhook 누락 / refund unclear | 결제 chaos |
| `swr` 또는 `@tanstack/react-query` | cache stale / mutation race / optimistic 실패 | 캐시 chaos |
| `react-hook-form` | re-render trigger / validation timing | 폼 chaos |
| `framer-motion` | animation 중 클릭 / layout shift | 인터랙션 timing |
| `socket.io-client`, `pusher-js` | 연결 끊김 중 액션 / 메시지 순서 | 동시성 chaos |
| `i18next` 또는 `next-intl` | 미번역 키 / RTL / 긴 번역 overflow | 다국어 chaos |
| `zod`, `yup` | schema 우회 / type coercion | 검증 chaos |
| `dayjs`, `date-fns` | timezone / DST / locale 차이 | 시간 chaos |
| `react-pdf`, `pdf-lib` | 큰 파일 / 메모리 / iframe 보안 | 파일 chaos |

**감지 명령**:
```bash
jq '.dependencies, .devDependencies' package.json 2>/dev/null
```

---

## 채널 #4: 컴포넌트 패턴

| 컴포넌트 패턴 (DOM/소스 grep) | 도출 카테고리 |
|---|---|
| `<dialog>`, `[role=dialog]`, `Modal` | focus trap 누락 / Escape 미처리 / scroll lock 미해제 / 배경 클릭 |
| `<form>`, `<form onSubmit>` | 빠른 submit 연타 / 검증 timing / 페이지 이탈 시 데이터 |
| `<table>`, `[role=grid]` | 정렬·필터 race / 페이징 경계 / 빈 결과 처리 |
| pagination ("Next", "Prev", page numbers) | 첫 페이지 -1 / 마지막 페이지 +1 / URL 직접 |
| Tooltip, Popover | 호버 race / 모바일 long-press / 키보드 미지원 |
| Toast / Notification | 동시 다발 / 자동 닫힘 timing / 닫기 race |
| Tabs (`[role=tablist]`) | 키보드 nav / 활성 tab 상태 유지 |
| Accordion / Collapse | 다중 열림 / 애니메이션 중 클릭 |
| Infinite scroll | 스크롤 끝 / 새로고침 시 위치 / 데이터 중복 |
| Drag·Drop (`draggable=true`) | 드래그 중 페이지 이탈 / 잘못된 drop target |

**감지 명령**:
```bash
grep -rE "Modal|Dialog|Tooltip|Popover|Toast" src/ 2>/dev/null | head -20
```

---

## 채널 #5: 표준 (WCAG / OWASP / Web Vitals)

| 표준 | 결함 카테고리 |
|---|---|
| **WCAG 2.1 AA** — 1.4.3 Contrast | text/background contrast < 4.5:1 |
| WCAG 2.1.1 Keyboard | 모든 인터랙션 키보드 접근 가능 |
| WCAG 2.4.3 Focus Order | tab 순서 논리적 |
| WCAG 2.4.7 Focus Visible | focus indicator 보임 |
| WCAG 4.1.2 Name, Role, Value | aria-label 누락 / role 잘못 |
| **OWASP Top 10 #1** Broken Access Control | IDOR / 권한 분기 우회 |
| OWASP #3 Injection | SQL / XSS / command injection |
| OWASP #4 Insecure Design | 비즈니스 로직 우회 (결제 race 등) |
| OWASP #7 ID & Auth Failures | 세션 / brute force |
| OWASP #8 Software & Data Integrity | CSRF / signed cookie 조작 |
| **Web Vitals — LCP** | Largest Contentful Paint > 2.5s |
| Web Vitals — INP | Interaction to Next Paint > 200ms |
| Web Vitals — CLS | Cumulative Layout Shift > 0.1 |
| Web Vitals — TTFB | Time to First Byte > 800ms |

**감지 도구**: 
- WCAG: axe-core (Playwright `browser_evaluate` 주입)
- OWASP: 스킬 행동 자체로 검수 (라이브 검증)
- Web Vitals: Playwright trace + Lighthouse CI

---

## 채널 #6: 메타 학습 (R45-R77)

본 스킬과 live-verify-loop의 메타 학습 lineage 적용 가능성 검사.

| 코드 | 본 프로젝트 적용 가능성 검사 |
|:-:|---|
| **R45** | curl 또는 fetch에 의존하는 health check 코드 있는가? → "API 200 OK = 라이브" 함정 카테고리 |
| **R54** | `.env.example` ≠ `.env`? → "환경 변수 채워짐 = 환경 정상" 카테고리 |
| **R55** | `playwright.config.ts` 존재? → "테스트 PASS = 라이브 PASS" 카테고리 |
| **R75** | TypeScript 코드에 self-reference 패턴? → 도메인 코드 함정 카테고리 |
| **R76** | 본 스킬 자체가 룰 어김 (자기 위반)? → 자기 위반 카테고리 (메타) |
| **R77** | 다중 페르소나 분기(multi-role 등) 있고 권한 미들웨어? → 표면 검증 함정 카테고리 (**본 스킬 직접 동기**) |

---

## 매핑 통합 흐름

```
[STEP ② 디스커버리]
     ↓
6 채널 평행 실행
     ↓
각 채널이 발견된 시그널 → 카테고리 후보 자동 추가
     ↓
중복 제거 + 영향도 자동 평가 (라이브러리 위험도 / 라우트 critical / OWASP severity)
     ↓
10+개 카테고리 풀 → STEP ③ 3+안 조합 생성
```

→ 채널 4개 미만 활성 시 디스커버리 부족 진단 (Red Flag).
