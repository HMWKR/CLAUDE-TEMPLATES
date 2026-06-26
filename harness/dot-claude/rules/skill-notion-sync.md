---
paths:
  - "**/skills/**/SKILL.md"
  - "**/skills/**/skill.md"
---

# 스킬 → Notion 자동 동기화 규칙

## 트리거 조건
`~/.claude/skills/` 하위에 `skill.md` 또는 `SKILL.md` 파일을 **생성(Write)** 또는 **수정(Edit)** 했을 때.

## 실행 프로토콜

### 1. 카테고리 판별
새/수정 스킬의 description을 읽고 아래 카테고리 중 하나를 결정한다:

| 카테고리 | 판별 키워드 | Notion 서브페이지 |
|---------|-----------|-----------------|
| 사고 프레임워크 | 사고, thinking, framework, 분류, 분석 프레임워크 | "1. 사고 프레임워크 상세" |
| 프로젝트 부트스트래핑 | 프로젝트, bootstrapper, kickstart, 리서치 | "2. 프로젝트 부트스트래핑 상세" |
| 분석/감사 | analysis, audit, 감사, 분석 | "3. 분석/감사 + Agent Teams 상세" |
| Agent Teams | agent-teams, orchestrat | "3. 분석/감사 + Agent Teams 상세" |
| QA/테스트 | playwright, QA, test, 테스트 | "4. QA/테스트 + 코드품질 + 문서 + 배포 + 인프라" |
| 기타 | 위에 해당 없음 | "4. QA/테스트 + 코드품질 + 문서 + 배포 + 인프라" |

### 2. Notion 업데이트 내용
해당 카테고리 서브페이지에 다음을 추가한다:

```
## /스킬명 — 한줄 설명 {color="카테고리색_bg"}

<callout icon="적절한이모지">
**버전**: X.X.X | **이론**: 해당 시 | 핵심 원리 1문장
</callout>

### 파이프라인 구조
(Mermaid 다이어그램 — 스킬의 단계별 흐름)

### 트리거/비트리거
### 단계별 상세
### CE 기여 매핑
### 연동 스킬
```

### 3. 메인 인덱스 업데이트
메인 카탈로그 페이지 "Claude Code 스킬 카탈로그 v2.0"의 해당 카테고리 테이블에도 한 줄 추가.

### 4. 업데이트 완료 알림
"Notion 카탈로그 업데이트 완료: [스킬명] → [카테고리]" 메시지를 사용자에게 출력.

## 참조
- 메인 카탈로그: notion page id `330cd25f-b9c3-81b5-9ce5-dd1270eababf`
- 사고 프레임워크: `331cd25f-b9c3-818d-a0cf-efa1ae6e9d63`
- 부트스트래핑: `331cd25f-b9c3-8133-8909-f822312f173d`
- 분석/Agent Teams: `331cd25f-b9c3-81b1-9064-e7cdb7108e7b`
- QA/코드/문서/배포: `331cd25f-b9c3-81a3-b95e-db6c57a93f57`
