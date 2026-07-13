---
description: 신규 스킬 신설 가치 있는 후보 식별 + 상세 분석 + 사용자 결정 요청 (Compound Engineering 메타 루프)
---

# /propose-skill — 신규 스킬 후보 제안

> **사용자 결정 (2026-05-25 P3-5)**: 옵션 E — insight-sentinel `skill-candidate` 유형 자동 감지 (Stop hook 알림) + 본 슬래시 커맨드 명시 호출 시 깊은 분석. Compound Engineering (Every의 Dan Shipper) 패턴 완성. ⑬ Compound Engineering Advocate 페르소나 권장.

## 실행 단계

### Step 1: 최근 작업 분석

- `.thoughts/` 최근 7일 파일 Read (CE 사고여정 + 인사이트)
- `git log -20 --oneline` (커밋 패턴)
- `~/.claude/runtime-state/<cwd-base>/agent-mappings.log` (매핑 빈도)
- `~/.claude/runtime-state/<cwd-base>/insight-collector.log` (있다면)

### Step 2: skill-candidate 트리거 충족 후보 식별

`~/.claude/skills/insight-sentinel/SKILL.md` 의 트리거 4개 중 하나라도 충족:

| 트리거 | 조건 |
|---|---|
| 반복 패턴 | 같은 작업 흐름 **3회 이상** 반복 (다른 도메인/프로젝트에서) |
| 도메인 검수 + 만족도 | 특정 도메인 검수 1회 + 사용자 만족도 ≥ 7 |
| 사용자 명시 | "이거 스킬화하자" 명시 발화 |
| CE Architect 권장 | 4대 실패 모드 완화 효과 + 신규 자산 ROI ≥ 7 |

### Step 3: 각 후보 상세 분석

```markdown
### 후보 [skill-name] — [한 줄 요약]

- **분류**: A/B/C 카테고리 (라운드 2-3 결과 정합)
  - A: 이미 파이프라인 성숙 (신설 불요)
  - B: 파이프라인화 ROI 높음 (framing 또는 신설 검토)
  - C: 사고 프레임 / 유틸 / SSoT (자산화 차단)
- **트리거 충족**: [반복 N회 / 도메인 검수 + 만족도 / 사용자 명시 / CE 권장]
- **인사이트 1 매핑**: Step X-Y (어느 단계 강함)
- **기존 스킬 중복 검사** (필수):
  - 글로벌 ~/.claude/skills/ 58개 + 외부 플러그인 18개 확인
  - 중복: 없음 / 일부 (기존 X와 부분 겹침 → 신설 대신 X 확장 권장)
  - 충돌: 없음 / 있음 (있으면 신설 차단)
- **예상 ROI**:
  - High: 매 작업 품질 즉시 향상 + 재사용 빈도 높음
  - Medium: 특정 작업에서만 활용
  - Low: 단발 / 시간 두고
- **신설 시 위험 (4대 실패 모드)**:
  - Poisoning: 외부 미신뢰 정보 유입 위험?
  - Distraction: 매 작업에 노출 시 주의 분산?
  - Confusion: 기존 스킬과 책임 경계 모호?
  - Clash: 글로벌 Iron Law / Uncompromising Rigor 와 충돌?
- **권장 결정**: 신설 / 보류 / 거절
```

### Step 4: C 카테고리 부적합 차단 (필수)

다음은 **후보 X**:
- 사고 프레임 (cynefin / first-principles / ooda / think-* 이미 충분)
- 단순 유틸 (docx / pdf / xlsx / 단일 파일 처리)
- SSoT 참조 (_core / _shared)
- 외부 의존 (vercel-deploy / supabase 같은 외부 서비스 1회성 호출)
- 일회성 fix / 단발 작업

### Step 5: 사용자 결정 요청 (AskUserQuestion)

식별된 후보 1-4개에 대해:
- 신설 진행
- 보류 (1-2주 후 재검토)
- 거절 (영구 제외)

신설 결정 시 **별도 plan 작성 → ExitPlanMode 승인 → 실제 신설**.

자동 신설 X (자산 폭증 차단 — 균형 톤).

## 출력 형식

```markdown
# Skill Candidate Proposals (YYYY-MM-DD)

## 분석 범위
- 분석 기간: 최근 7일 (또는 사용자 지정)
- 데이터 출처: .thoughts/ N개 / git log / agent-mappings.log
- 매핑 빈도 통계: [상위 5개 매핑된 페르소나/스킬]

## 발견 N개 후보

### 후보 1: [skill-name] — [한 줄 요약]
...
### 후보 2: ...

## C 카테고리 부적합 영역 (자동 제외)
- [영역 1]: 이유
- [영역 2]: 이유

## 사용자 결정 요청
(AskUserQuestion으로 N개 후보 각각 신설/보류/거절 선택)

## 다음 단계 (신설 결정 시)
1. 별도 plan 작성 (skill 이름 / SKILL.md 구조 / 트리거 키워드 / 도구 권한)
2. ExitPlanMode 승인 요청
3. 실제 신설 (Write `~/.claude/skills/<name>/SKILL.md`)
4. harness-eval.js 재실행 (자산 추가 후 영향 점검)
5. 회고 .md 추가
```

## Uncompromising Rigor 정합

- **§2 자기 합리화 차단**: "신설하면 좋을 것 같다" 같은 막연한 표현 차단. **트리거 명시 충족만** 후보화.
- **§3 모든 발견은 결함**: 모든 후보는 기본 **Medium**. 사용자 명시 강등 발화 인용 시만 Low.
- **§4 Per-Round Deep Analysis**: 후보 식별 시 5단계 적용 (이전 재조회 / 미세 재스캔 / Adversarial / 자기 정당화 자가 검증 / 신규+재현성).

## 우회 금지

- "스킬 후보 자동 신설" 시도 → 차단 (사용자 명시 승인 의무)
- C 카테고리 부적합 영역을 후보로 올림 → 차단
- 기존 스킬과 중복 명백한데 신설 권장 → 차단 (기존 스킬 확장 권장)

## 참조

- 스킬 본문: `~/.claude/skills/insight-sentinel/SKILL.md` (skill-candidate 유형 2026-05-25 P3-5 추가)
- 라운드 2-3 결과 (A/B/C 분류 + 트리거 기준): `.thoughts/2026-05-25-harness-insights-round2-round3.md`
- 회고: `.thoughts/2026-05-25-harness-application-completed.md`
- Compound Engineering 페르소나 ⑬: 라운드 1-2 페르소나 토론 결과
