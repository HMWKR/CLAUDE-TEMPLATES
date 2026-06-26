# R75: TypeScript cursor self-reference cycle (TS7022)

- 등재: 2026-05-05

## 함정
BE export endpoint에 cursor pagination + where 조건 self-reference 패턴 사용 시 TS7022 implicit any cycle 발생.

## 함정 패턴
```typescript
let cursor: string | null = null;
while (true) {
  const items = await fastify.prisma.entity.findMany({
    where: cursor ? { id: { gt: cursor } } : {},  // ← self-reference 추론기 cycle
    orderBy: { id: 'asc' },
    take: PAGE_SIZE,
  });
  if (items.length === 0) break;
  cursor = items[items.length - 1].id;  // ← cursor → items.id → cursor cycle
}
```

## 컴파일러 메시지
`error TS7022: 'items' implicitly has type 'any' because it does not have a type annotation and is referenced directly or indirectly in its own initializer.`

## 위험
- 단일 endpoint 작성 시점엔 잡히지 않음 (PASS)
- 여러 endpoint 누적 + dual usage 시점에 cycle 감지로 회귀
- live-verify-loop Layer 4 typecheck 단계에서 검출 가능

## 회피
where 조건을 별도 const로 분리:
```typescript
let cursor: string | null = null;
while (true) {
  const itemWhere: { id?: { gt: string } } = cursor ? { id: { gt: cursor } } : {};
  const items = await fastify.prisma.entity.findMany({
    where: itemWhere,  // ← cycle 차단
    orderBy: { id: 'asc' },
    take: PAGE_SIZE,
  });
  ...
}
```

## 추가 함정 — Decimal 직렬화
Prisma Decimal 필드를 escape() 함수에 직접 전달 시 TS2345 (Decimal not assignable to string | number | null). `s.commissionRate.toString()`로 명시적 string 변환 필요.

## 재현 가능성 (등재 기준 충족)
- (a) 다른 도메인: 모든 BE export endpoint (orders/settlements/banners/promotions/coupons/notices) 추가 시마다 발생 가능
- (b) 새 패턴: R45/R54/R55와 다른 컴파일러 추론 cycle 함정
- (c) '모르면 다시 빠진다': cursor pagination은 메모리 안전 stream에 필수 패턴이라 반복 작성됨

## 적용 범위

cursor pagination + where 조건 self-reference 패턴이 다중 endpoint에 반복 사용된 경우 — TS7022 cycle 동시 발생 가능. live-verify-loop Layer 4 typecheck 단계에서 검출.

## 진단 트리거
- BE export endpoint 신규 추가 후 typecheck 3+ errors
- error TS7022 + 'cursor' 변수 self-reference 메시지

## 진단 트리거
(라이브 검증 시 어떤 신호가 보이면 의심? — 본 함정 발견 시 채움)

## Fix 패턴
(어떻게 차단·수정하는가? — 본 함정 발견 시 채움)

## 일반성 검증
- ✅ 다른 도메인 재현 가능
- ✅ 기존 R45~R55와 다른 새 패턴
- ✅ "모르면 다시 빠진다"는 일반성

## 관련 결함 케이스북
- (해당하는 _casebook.md 항목 참조)

## 본문 인용 위치
- SKILL.md "Meta-Learning 상단 인용" (필요 시 추가)
- SKILL.md "Failure Modes 하단 인용" (필요 시 추가)
