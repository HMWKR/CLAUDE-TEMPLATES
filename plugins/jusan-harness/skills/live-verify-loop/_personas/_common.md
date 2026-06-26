---
name: _common
description: live-verify-loop 모든 페르소나 공통 베이스. 매핑 워크플로우, 인사이트 기록, Iron Law 준수 규칙. 직접 호출되지 않음 — 다른 페르소나 .md가 본 파일을 reference.
---

# _common — 공통 베이스 (모든 페르소나 reference)

## 매핑 워크플로우 (Iron Law #1 충족)

라운드 시작 시 다음 순서로 매핑:

```
1. .claude/agents/<persona>.md Read (자동 timestamp 기록)
   └ 또는 bash ~/.claude/scripts/record-agent-mapping.sh <name> "ctx"
2. 페르소나 ".담당 범위" 적용
3. 작업 수행
4. 인사이트 기록 (도메인 발견 가치 있을 때만)
```

## 인사이트 기록 규칙 (Iron Law #2 R47 정책)

- **의무 아님** — "정말 좋은 도메인 발견" 시에만 기록
- 기준: (a) 다른 영역 영향 / (b) 반복 사용 / (c) 기존과 모순
- 경로: `docs/domain-knowledge/<persona>-insights.md`
- 형식:

```markdown
## YYYY-MM-DD: 제목
- **발견**: 무엇을 발견/결정했는지
- **이유**: 왜 그렇게 했는지
- **영향**: 다른 영역에 미치는 영향
- **출처**: 어떤 작업 중 발견했는지
- **다음**: 후속 작업
```

## 메타 학습 자동 환기

매 라운드 Step ② 시작 시 본 스킬 SKILL.md 상단 메타 학습(R45/R54/R55+) 자동 참조:
- curl PASS = 라이브 작동 가정 차단
- 코드 100% = 라이브 100% 가정 차단
- npx playwright test = MCP 가정 차단

## 페르소나 충돌 시 조정

다중 페르소나 매핑 시 결정 충돌:
- 일반: 상류 Lead가 1차 결정 (예: ux-lead가 ux-ui-designer / qa-a11y-expert 사이 조정)
- 광범위 충돌: `coherence-reviewer` 페르소나 매핑 (있으면) 또는 사용자 명시

## 출력 형식 공통

- 발견 매트릭스: 표 형태
- 코드 변경: file_path:line_number 명시
- 라이브 검증 결과: Layer 1~4 매트릭스
- 시각 검증 (UI 작업): 스크린샷 경로 명시
