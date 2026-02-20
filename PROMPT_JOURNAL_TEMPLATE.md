# CE 사고 여정 템플릿 (Context Engineering Thinking Journal)

> `.thoughts/` 폴더에 저장. Claude가 작업 완료 시 직접 작성.

## 파일명: `.thoughts/YYYY-MM-DD-{subject}.md`

## 템플릿

```markdown
---
date: YYYY-MM-DD
commit: [hash]
type: [feat/fix/docs/...]
subject: "[커밋 제목]"
ce_strategies: []
---

# [커밋 제목]

## 1. 컨텍스트 수집 (Gather)
| 파일 | 이유 | 유용했는가 |
|------|------|:----------:|

## 2. 정보 선택/폐기 (Select)
- 채택: [무엇을, 왜]
- 폐기: [무엇을, 왜]
- 컨텍스트 예산: 수집 ~?% | 구현 ~?%

## 3. 실패 모드 감지 (Detect)
| 실패 모드 | 감지 | 회피 전략 |
|----------|:----:|----------|
| Poisoning | | |
| Distraction | | |
| Confusion | | |
| Clash | | |

## 4. 대안 비교 및 결정 (Decide)
| 대안 | 장점 | 단점 | 채택 |
|------|------|------|:----:|

## 5. 적용된 CE 전략
- [ ] Write | Select | Compress | Isolate

## 6. 핵심 통찰
> [CE 교훈]
```

## 검증: `node scripts/validate-journals.js`
