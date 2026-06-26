# Deployment Provider Gate (가이드 §14 인용 사본)

> 출처: `realizesoft/realizesoft-cross-runtime-skill-guide.md` §14 Deployment Provider Gate. 원본 가이드 파일은 수정하지 않으며, 본 파일은 인용 사본 + AskUserQuestion 4 옵션 한도 처리 명세다.

---

## 가이드 §14 원문 (인용)

> Use this gate before any deployment plan or execution.
>
> ```text
> Deployment Provider Gate
>
> 1. Plan only (Recommended when credentials/tools are unclear)
> 2. AWS
> 3. Google Cloud
> 4. Azure
> 5. Cloudflare
> 6. Firebase
> 7. Supabase
> 8. Vercel
> 9. Self-hosted / VPS
> ```
>
> Selection criteria:
>
> | Criterion | Consider |
> |---|---|
> | App shape | static, SSR, API server, container, serverless, worker |
> | Runtime | Node, Python, Go, JVM, Docker, edge runtime |
> | Data | database, auth, storage, queue, cache |
> | Traffic | PoC, startup, enterprise, regional needs |
> | Operations | managed service vs user-managed infra |
> | Cost | free tier, low-cost preview, scaling cost |
> | Region/regulation | data residency, privacy, compliance |
> | Tool availability | CLI, token, MCP, CI/CD, IaC |
> | Rollback | preview, staged rollout, rollback path |
>
> Actual deploys, production changes, domain changes, external writes, credentials, or cost-impacting work require explicit safety approval.

---

## AskUserQuestion 4 옵션 한도 — 2단계 Gate 분할

가이드 §14 는 9 개 후보를 명시. AskUserQuestion 의 4 옵션 한도 (+ Other) 때문에 2단계로 분할:

### 1st Gate — 카테고리 선택

```typescript
AskUserQuestion({
  questions: [{
    question: "어디에 배포할까요? (먼저 카테고리 선택)",
    header: "Deploy Category",
    multiSelect: false,
    options: [
      {
        label: "Plan only (Recommended)",
        description: "credentials/tools 가 불명확할 때 기본. 실제 배포 없이 deployment plan 만 작성. 가이드 §4.5 Provider-Neutral 권장 default"
      },
      {
        label: "Major cloud — AWS / GCP / Azure",
        description: "Enterprise·복잡한 인프라·전세계 지역·실제 IaC. Pros: 가장 유연 / Cons: 학습 곡선·비용"
      },
      {
        label: "PaaS / BaaS — Cloudflare / Firebase / Supabase / Vercel",
        description: "관리형 서비스·빠른 배포·BaaS (auth/db). Pros: 빠름 / Cons: vendor lock-in"
      },
      {
        label: "Self-hosted / VPS",
        description: "VPS / 자체 데이터센터 / Docker 직접 관리. Pros: 풀 컨트롤 / Cons: 운영 부담"
      }
      // "Other" 자동
    ]
  }]
})
```

### 2nd Gate — 카테고리 안의 구체 선택 (1st 가 "Plan only" 아닐 때)

#### Major cloud 선택 시:
```typescript
AskUserQuestion({
  questions: [{
    question: "어느 cloud 인가요?",
    options: [
      { label: "AWS", description: "..." },
      { label: "Google Cloud", description: "..." },
      { label: "Azure", description: "..." }
      // "Other" 자동 (다른 cloud)
    ]
  }]
})
```

#### PaaS/BaaS 선택 시:
```typescript
AskUserQuestion({
  questions: [{
    question: "어느 PaaS/BaaS 인가요?",
    options: [
      { label: "Cloudflare", description: "Edge / Workers / Pages" },
      { label: "Firebase", description: "Google BaaS" },
      { label: "Supabase", description: "Open-source Firebase 대안" },
      { label: "Vercel", description: "Next.js / Edge functions" }
    ]
  }]
})
```

---

## Selection Criteria 표시 (사용자 결정 도움)

본 스킬이 1st Gate 호출 시, `question` 또는 `description` 에 가이드 §14 의 Selection Criteria 표 요약 포함:

> "선택 기준: App shape (static/SSR/API/container/serverless) / Runtime (Node/Python/Go/JVM/Docker) / Data (DB/auth/storage) / Traffic (PoC/startup/enterprise) / Cost (free tier/scaling) / Region (data residency) / Tool (CLI/MCP/CI) / Rollback (preview/staged)"

---

## Q4 Explicit Approval (절대 skip 금지)

가이드 §14 끝의 명시 인용:

> "Actual deploys, production changes, domain changes, external writes, credentials, or cost-impacting work require explicit safety approval."

본 스킬은 다음 행위 전 별도 Q4 AskUserQuestion 발동:

| 행위 | Q4 질문 형식 |
|---|---|
| 실제 deploy (production) | "이 변경을 production 에 배포할까요? (취소 가능 여부 명시)" |
| domain 변경 | "도메인 <domain> 을 변경할까요?" |
| credential 입력 | "credential <type> 을 사용해도 될까요? (보안 범위 명시)" |
| 외부 write (API call) | "외부 서비스 <name> 에 write 호출할까요?" |
| cost-impacting | "이 작업의 예상 비용은 <amount>. 진행할까요?" |

Q4 게이트는 §4.3 의 "Q4 gates must never be skipped or merged" 와 정합.
