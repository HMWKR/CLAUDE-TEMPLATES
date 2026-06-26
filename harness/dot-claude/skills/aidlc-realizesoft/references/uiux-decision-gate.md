# UI/UX Decision Gate (가이드 §13 인용 사본)

> 출처: `realizesoft/realizesoft-cross-runtime-skill-guide.md` §13 UI/UX Decision Gate. 원본 가이드 파일은 수정하지 않으며, 본 파일은 인용 사본 + AskUserQuestion 매핑이다.

---

## 가이드 §13 원문 (인용)

> When a UI/UX decision needs representation, ask the user how to review it.
>
> ```text
> UI/UX Decision Gate
>
> 1. ASCII Wireframe (Recommended for quick structure)
>    Pros: fast, readable in chat, good for information architecture.
>    Cons: weak for visual polish and responsive judgment.
>
> 2. HTML Preview
>    Pros: closer to real layout, flow, and visual state.
>    Cons: requires file creation and more verification time.
>
> 3. External Reference Input
>    Pros: can use Figma, Notion, screenshots, URLs, or user-provided style direction.
>    Cons: quality depends on provided references.
> ```
>
> If option 3 is selected, accept:
>
> - Figma link
> - Notion page
> - screenshot or image path
> - reference website URL
> - free-form style description

---

## AskUserQuestion 매핑

```typescript
AskUserQuestion({
  questions: [{
    question: "UI/UX 결정을 어떤 형식으로 검토할까요?",
    header: "UI/UX Format",
    multiSelect: false,
    options: [
      {
        label: "ASCII Wireframe (Recommended)",
        description: "빠르고 채팅에서 읽기 좋음, 정보 설계 (IA) 에 최적. Cons: 비주얼·반응형 판단 약함"
      },
      {
        label: "HTML Preview",
        description: "실제 layout / flow / visual state 와 가까움. Cons: 파일 생성·검증 시간 추가"
      },
      {
        label: "External Reference Input",
        description: "Figma 링크 / Notion 페이지 / 스크린샷 경로 / 참조 웹사이트 URL / 자유 텍스트 스타일. Cons: 입력 품질에 의존"
      }
      // "Other" 자동
    ]
  }]
})
```

### External Reference Input 선택 후 follow-up

옵션 3 선택 시, 본 스킬이 두 번째 `AskUserQuestion` 으로 reference 형태 확인:

```typescript
AskUserQuestion({
  questions: [{
    question: "External reference 의 형태는?",
    header: "Reference Type",
    multiSelect: false,
    options: [
      { label: "Figma link", description: "Figma 파일 URL 제공 예정" },
      { label: "Notion page", description: "Notion 페이지 URL 제공 예정" },
      { label: "Screenshot / Image path", description: "로컬 이미지 경로 또는 첨부" },
      { label: "Reference website URL", description: "유사 웹사이트 URL" }
      // "Other" — free-form style description 등
    ]
  }]
})
```

이후 사용자가 실제 URL / 경로 / 텍스트를 input 으로 제공 → `aidlc-docs/UserChoice/uiux/<gate-slug>/external-input.txt` 에 기록.

---

## UserChoice 파일 매핑

| 사용자 선택 | 생성 파일 |
|---|---|
| ASCII Wireframe | `aidlc-docs/UserChoice/uiux/<gate-slug>/ascii-wireframe.txt` |
| HTML Preview | `aidlc-docs/UserChoice/uiux/<gate-slug>/preview.html` |
| External Reference | `aidlc-docs/UserChoice/uiux/<gate-slug>/external-input.txt` |
| (공통) | `aidlc-docs/UserChoice/uiux/<gate-slug>/decision.md` |

가이드 §12 의 원칙대로 "Create only useful support artifacts. Do not create empty placeholders."
