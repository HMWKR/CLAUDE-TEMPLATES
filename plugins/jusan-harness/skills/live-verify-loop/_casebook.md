# live-verify-loop — 결함 케이스북

> SKILL.md Step ③ "결함 즉시 fix" 단계에서 참조하는 결함 패턴 모음.
> 초기 R1~R55 라운드에서 누적된 6종 + 도메인 추가 결함은 사용자가 STEP ⑤ 정착 시 입력.

---

## 1. Hydration mismatch

### 진단 트리거
- 콘솔에 `Hydration failed because the initial UI does not match what was rendered on the server`
- 콘솔에 `Rendered fewer hooks than expected` / `Rendered more hooks`
- ErrorBoundary가 라우트 진입 즉시 폭발

### 원인
- `useState` / `useEffect` 분기로 SSR vs CSR 결과가 다름
- `typeof window !== 'undefined'` 분기가 첫 렌더 mismatch 유발
- 조건부 Hook 호출 (Hook Rules 위반)

### Fix 패턴

**A) mounted 가드** (가장 일반적):
```tsx
const [mounted, setMounted] = useState(false);
useEffect(() => setMounted(true), []);
if (!mounted) return null; // or <Skeleton />
return <RealComponent />;
```

**B) Shell 컴포넌트 wrap** (광범위 패턴, 1건 fix로 N건 해결):
```tsx
// AdminShell.tsx
export function AdminShell({ children }: { children: React.ReactNode }) {
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);
  if (!mounted) return <AdminSkeleton />;
  return <>{children}</>;
}
```

**C) `dynamic` import + ssr:false** (Next.js):
```tsx
const Heavy = dynamic(() => import('./Heavy'), { ssr: false });
```

---

## 2. BE_URL 이중 prefix (`/api/api/...`)

### 진단 트리거
- Network 탭에 `404` for URLs containing `/api/api/`
- 콘솔에 `Failed to fetch` for double-prefix URLs

### 원인
- env `NEXT_PUBLIC_API_URL=http://localhost:4000/api` (이미 /api 포함)
- 코드에서 `${API_URL}/api/users` (또 /api 추가) → `/api/api/users`

### Fix 패턴 (mode C SSoT import):

```ts
// src/lib/api-base.ts
const RAW = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000';
// /api 제거 후 origin만 보존
export const API_ORIGIN = RAW.replace(/\/api\/?$/, '');
export const API_BASE = `${API_ORIGIN}/api`;
export const WS_ORIGIN = API_ORIGIN.replace(/^http/, 'ws');

// 사용처에서 항상 import
import { API_BASE } from '@/lib/api-base';
fetch(`${API_BASE}/users`); // 절대 이중 prefix 안 됨
```

전체 코드베이스 grep으로 `${API_URL}/api` 패턴 일괄 치환.

---

## 3. enum mismatch (FE ↔ BE 다른 enum 값)

### 진단 트리거
- API 응답이 200인데 UI가 빈 상태
- `status === 'active'` 비교가 항상 false (실제로는 BE가 'APPROVED' 반환)

### 원인
- FE/BE 팀이 enum 값 합의 없이 별도 정의
- TS 타입은 `string`으로만 선언되어 컴파일러가 잡지 못함

### Fix 패턴 (매핑 객체):

```ts
// src/types/status-map.ts
export const STATUS_MAP_BE_TO_FE = {
  'APPROVED': 'active',
  'PENDING': 'pending',
  'REJECTED': 'inactive',
} as const;

export const STATUS_MAP_FE_TO_BE = Object.fromEntries(
  Object.entries(STATUS_MAP_BE_TO_FE).map(([k, v]) => [v, k])
) as Record<string, keyof typeof STATUS_MAP_BE_TO_FE>;

// queryFn 안에서 정규화
const sellers = res.map(s => ({
  ...s,
  status: STATUS_MAP_BE_TO_FE[s.status] ?? 'unknown',
}));
```

---

## 4. undefined data (`x.map is not a function`)

### 진단 트리거
- `TypeError: sellers.map is not a function`
- React Query: `Query data cannot be undefined`

### 원인
- BE 응답이 array 아님 (예: `{ data: [...], total: 100 }`)
- queryFn이 undefined 반환

### Fix 패턴 (정규화 + fallback):

```ts
const { data: sellers = [] } = useQuery({
  queryKey: ['sellers'],
  queryFn: async () => {
    const res = await fetch(`${API_BASE}/sellers`).then(r => r.json());
    // 응답 형식 정규화
    return Array.isArray(res) ? res : (res?.data ?? res?.sellers ?? []);
  },
});

// 사용처에서도 방어:
{sellers?.map(s => <Card key={s.id} {...s} />) ?? <Empty />}
```

---

## 5. cross-cutting (header/sidebar 무차별 노출)

### 진단 트리거
- `/admin/*` 진입 시 buyer header가 보임
- `/checkout` 진입 시 marketing footer가 보임
- 라우트 변경 시 layout이 깜빡임

### 원인
- `app/layout.tsx` (root)가 `<Header />`를 무조건 렌더
- 라우트 그룹 분리 미사용

### Fix 패턴 (path 분기 + early null):

**A) Header 자체에서 분기**:
```tsx
// components/Header.tsx
'use client';
import { usePathname } from 'next/navigation';

export function Header() {
  const pathname = usePathname();
  // 권한 분기 영역에서는 노출 안 함
  if (pathname.startsWith('/admin') || pathname.startsWith('/seller')) return null;
  return <header>...</header>;
}
```

**B) Route Group으로 layout 분리**:
```
app/
├── (public)/
│   ├── layout.tsx  # Header + Footer
│   └── page.tsx
└── (admin)/
    ├── layout.tsx  # AdminShell only
    └── admin/
        └── page.tsx
```

---

## 6. production DB 마이그레이션

### 진단 트리거
- 로컬 마이그레이션은 성공
- 프로덕션 배포 후 `column "X" does not exist` 에러
- `psql` 명령 실행 시 `command not found`

### 원인
- 로컬 환경에 psql 미설치
- CI/CD 파이프라인이 마이그레이션 단계 누락
- 권한 차단으로 직접 SQL 실행 불가

### Fix 패턴 (Supabase MCP `apply_migration`):

```
1. 사용자 명시 승인 후에만 실행
2. idempotent SQL 작성 (CREATE TABLE IF NOT EXISTS, ADD COLUMN IF NOT EXISTS)
3. 적용 후 list_tables / execute_sql로 검증
```

```ts
// MCP 호출 예시
await mcp__supabase__apply_migration({
  name: '058_add_seller_status_enum',
  query: `
    DO $$ BEGIN
      CREATE TYPE seller_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
    EXCEPTION
      WHEN duplicate_object THEN NULL;
    END $$;
    
    ALTER TABLE sellers
    ADD COLUMN IF NOT EXISTS status seller_status DEFAULT 'PENDING';
  `
});
```

---

## 도메인 추가 결함 (사용자 STEP ⑤에서 입력)

이커머스 / SaaS / 게임 / 핀테크 등 도메인별 결함 패턴은 STEP ⑤ 정착 시 사용자가 추가:

```markdown
## N. <도메인 결함 이름>
### 진단 트리거
### 원인
### Fix 패턴
```

새 결함이 (a) 다른 도메인 재현 가능, (b) R45~R55와 다른 패턴, (c) 일반성을 갖추면 → D-1 메타 학습 등재 후보.

---

## End of _casebook.md
