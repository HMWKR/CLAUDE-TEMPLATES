---
name: owner-friendly-explainer
description: 사장/비전공자가 5분 안에 기술 의제를 이해할 수 있도록 HTML 자료를 자동 생성한다. 식당/일상 비유 + 3단 설명 (무엇/어떻게/왜) + 카드 레이아웃 + 결정 트리 + FAQ + 용어집 + 인터랙티브 토글. 트리거: "사장 설명 HTML", "비전공자 설명", "owner-friendly", "/explain-owner".
model: opus
---

# Owner-Friendly Explainer HTML 스킬

> **Use case**: 사장님이 잔존 의제 / 신규 기능 / 보안 결함 / 일정 등을 5분 안에 이해할 수 있도록 HTML 시각 자료 자동 생성.
>
> **트리거**:
> - "잔존 의제를 사장님께 설명하는 HTML 만들어줘"
> - "비전공자가 이해 가능한 HTML"
> - "owner-friendly-explainer"
> - "/explain-owner <주제>"
>
> **출력 위치 정책** (사장 명시 2026-05-24):
> - 원본 파일 디렉토리 **바로 밑이 아닌** `<원본_디렉토리>/설명/N차/` 구조에 저장
> - **N차 = 자동 증분 폴더** — 같은 원본 파일에 대해 새 HTML 생성 시 1차 → 2차 → 3차 ... 순서로 신설
> - **각 N차 폴더 안에 HTML 단일 파일** (폴더당 1 HTML 원칙)
> - 예시:
>   - 원본: `docs/next-session-2026-05-24-ultra-audit-handoff.md`
>   - 1차 HTML: `docs/설명/1차/next-session-2026-05-24-ultra-audit-handoff.html`
>   - 2차 HTML (재호출 시): `docs/설명/2차/next-session-2026-05-24-ultra-audit-handoff.html`
>   - 3차 (사장이 더 디테일 요청 시): `docs/설명/3차/next-session-2026-05-24-ultra-audit-handoff.html`
> - **N차 폴더 자동 탐지 + 증분 로직** (Stage 8-pre):
>   ```bash
>   # 기존 N차 폴더 스캔
>   max_n=0
>   for dir in "<원본_디렉토리>/설명/"*차/; do
>     n=$(basename "$dir" | sed 's/차//')
>     [[ "$n" =~ ^[0-9]+$ ]] && (( n > max_n )) && max_n=$n
>   done
>   next_n=$((max_n + 1))
>   mkdir -p "<원본_디렉토리>/설명/${next_n}차/"
>   ```
> - **루트 직접 생성 폴백**: 원본 파일이 프로젝트 루트인 경우 → `설명/N차/<파일명>.html`
> - **분량**: ~50KB / 1,300+ 줄 (디테일 강화 시 ~80KB / 2,000+ 줄)

---

## ⚠️ Uncompromising Rigor (글로벌 룰 강제 적용)

이 스킬은 `~/.claude/rules/uncompromising-rigor.md` 4개 정책을 **무조건 준수**:

1. **Browser Tool Priority** — `mcp__claude-in-chrome__*` 우선 (라이브 렌더 검증 시)
2. **Self-Justification Red Flags** — "이 정도면 충분" / "사용자가 신경 안 씀" 등장 시 즉시 자기 차단
3. **All Findings Are Defects** — 설명 누락 / 비유 부족 / 시각 자료 빈약은 결함
4. **Per-Round Deep Analysis** — 매 HTML 생성 라운드 5단계 심층 분석 (이전 한계 재조회 → 본 라운드 강화 → 시각 검증 → 자기 정당화 자가 검증 → 신규 디테일 등재)

---

## 핵심 원칙 (8 원칙)

### 1. 식당/일상 비유 의무
- 모든 기술 용어 → 식당/일상 비유 (예: API 키 = 전기·가스 계량기, 보안 = 도어락, LAUNCH = 식당 오픈일)
- 비유 사전: `references/analogy-bank.md` 참조
- 카드별로 최소 1개 비유 + 전체 헤더에 통합 비유 1개

### 2. 3단 설명 구조 (의무)
모든 의제는 3개 컬럼으로 분리:
- 🤔 **무엇?** (What) — 정의 + 현재 상태
- ⚙️ **어떻게 작동?** (How) — 메커니즘 + 비유
- 🚨 **왜 필요?** (Why) — 위험 시나리오 + 결과

### 3. 책임 분리 매트릭스
각 의제마다 명시:
- 👤 **사장님** — 본인이 할 일 (자세히)
- 🤖 **Claude** — 할 수 있는 일 (자세히, 시간 포함)

### 4. 시각 자료 풍부화
- ASCII 다이어그램 (비교 / 흐름 / 매트릭스)
- 카드 레이아웃 (색상 코딩)
- 타임라인 (D-Day 기준)
- 결정 트리 (Q&A 형식)
- 진행률 바 (% 진행 상태)

### 5. 결정 트리 의무
사장님이 "지금 무엇 해야 하나?" 답변 가능한 5단계 Q&A:
```
Q1. 지금 당장 가장 급한 것? → [Yes/No]
Q2. 오픈 전 필수? → [Yes/No]
...
```

### 6. 오늘 할 수 있는 것 (시간 기준)
시간순 정렬 액션 매트릭스:
- 5분 / 10분 / 30분 / 1시간 / 2시간 / 4시간
- 각 액션마다 "어떤 명령어" + "어떤 의존" 명시

### 7. FAQ 섹션 (사장 자주 묻는 질문)
- "이거 안 하면 어떻게 되나?"
- "비용은 얼마?"
- "Claude가 다 못 해주나?"
- "내가 직접 해야 하는 이유?"
- "다른 회사는 어떻게 하나?"

### 8. 용어집 (Glossary)
모르는 전문 용어 즉시 확인:
- 우측 상단 floating 또는 footer 직전 섹션
- 예: API = "전기 계량기 같은 것" / DB = "주방 냉장고" / commit = "저장 + 도장 찍기"

---

## 강화 디테일 체크리스트 (이전 HTML 한계 극복)

이전 `잔존-의제-비전공자-설명.html` 의 한계를 본 스킬에서 강화:

| 한계 | 강화 |
|---|---|
| 비유 1개 (헤더만) | 카드별 1개 + 헤더 통합 1개 (총 N+1개) |
| 결정 트리 단순 | 분기별 결과 박스 + 예상 시나리오 시각화 |
| 인터랙티브 요소 0 | `<details>` 토글 + 클릭 가능 카드 + 부드러운 스크롤 |
| FAQ 없음 | 5+ FAQ 신설 |
| 용어집 없음 | 10+ 용어 정의 신설 |
| 위험 시나리오 없음 | "안 하면 어떻게?" 시뮬레이션 박스 |
| 비용 계산 없음 | 시간/금액 명시 (예: "30분 + 0원") |
| 진행률 시각화 없음 | 진행률 바 추가 |
| 모바일 반응형 부분 | 모든 카드 반응형 강화 |

---

## 9-Stage 파이프라인 (디렉토리 정책 자동화 포함)

```
[Stage 0 Pre-Flight + Rigor 활성]
        ↓
[Stage 1 입력 분석 — 원본 파일 경로 + 사장 컨텍스트 파악]
        ↓
[Stage 2 비유 선택 — analogy-bank 매핑 + 통합 비유 결정]
        ↓
[Stage 3 카드 구조 설계 — N개 우선순위 카드 + 3단 설명]
        ↓
[Stage 4 시각 자료 설계 — ASCII 다이어그램 + 타임라인 + 진행률]
        ↓
[Stage 5 결정 트리 + 오늘 액션 매트릭스 작성]
        ↓
[Stage 6 FAQ + 용어집 작성]
        ↓
[Stage 7 HTML 통합 + CSS 디자인 + 인터랙티브 요소]
        ↓
[Stage 8-pre ★자동 디렉토리 증분★]
        bash ~/.claude/skills/owner-friendly-explainer/scripts/setup-output-dir.sh <원본_파일>
        → stdout = 다음 N차 HTML 절대 경로 (스킬이 그대로 사용)
        → 자동으로 `<원본_dir>/설명/N차/` 신설 (1차 → 2차 → 3차 ... 증분)
        ↓
[Stage 8 HTML Write — Stage 8-pre 가 반환한 경로에 저장]
        ↓
[Stage 9 라이브 렌더 검증 (Chrome MCP) + 출력 품질 자체 점검]
```

### ★ Stage 8-pre 자동 디렉토리 정책 (사장 명시 2026-05-24)

**모든 HTML 생성은 반드시 setup-output-dir.sh 를 거쳐야 한다**. 스킬이 자동으로:

1. 원본 파일 디렉토리 추출 (예: `docs/`)
2. 그 안에 `설명/` 디렉토리 검사 (없으면 신설)
3. 기존 `N차/` 폴더 스캔 (예: `1차/`, `2차/` 발견 → max_n=2)
4. 다음 `(N+1)차/` 폴더 신설 (예: `3차/`)
5. 그 안에 HTML 저장 (`{원본_파일명}.html`)

**예시 흐름**:
- 원본: `docs/next-session-2026-05-24-ultra-audit-handoff.md`
- 1차 호출: → `docs/설명/1차/next-session-2026-05-24-ultra-audit-handoff.html`
- 2차 호출 (더 디테일 원할 때): → `docs/설명/2차/next-session-2026-05-24-ultra-audit-handoff.html`
- 3차, 4차 ... 무한 증분

**금지 사항**:
- 스킬이 원본 디렉토리 바로 밑에 HTML 생성 금지 (예: `docs/next-session-...html` X)
- 동일 N차 폴더에 HTML 2개 이상 저장 금지 (폴더당 1 HTML 원칙)
- Stage 8-pre 우회 금지 (수동 mkdir + Write 금지)

---

## 호출 방법

### A. 직접 호출
```
/explain-owner 잔존-의제
/explain-owner 보안-블로커-4건
/explain-owner Toss-5/26-상담
```

### B. 자연어 트리거
```
사장님께 잔존 의제 설명하는 HTML 만들어줘
비전공자가 이해할 수 있는 HTML로 만들어
owner-friendly-explainer 스킬 호출
```

### C. 옵션 플래그
- `--analogy=restaurant|hospital|construction|school` (비유 도메인 선택, 기본 restaurant)
- `--depth=brief|standard|detail|ultra` (기본 standard)
- `--interactive` (collapse/toggle 등 인터랙티브 강화)
- `--save=root|archive|docs` (저장 위치, 기본 root)

---

## 출력 매트릭스 (의무 섹션)

매 HTML 생성 시 아래 14 섹션 의무:

| § | 섹션 | 설명 |
|:-:|---|---|
| §0 | **헤로** | 헤더 + 한 줄 요약 + 통계 4건 |
| §1 | **목차 (TOC)** | 클릭 가능 섹션 점프 |
| §2 | **핵심 비유** | 통합 비유 + 비유 매핑 표 (기술 ↔ 비유) |
| §3 | **N개 우선순위 카드** | 3단 설명 + 비유 + ASCII 일러스트 + 책임 매트릭스 + 한 줄 요약 |
| §4 | **위험 시나리오** | "안 하면 어떻게?" 시뮬레이션 (NEW) |
| §5 | **결정 트리** | 5+ Q&A 분기별 결과 박스 (강화) |
| §6 | **오늘 할 수 있는 것** | 시간순 액션 매트릭스 (5분~4시간) |
| §7 | **FAQ** | 사장 자주 묻는 5+ 질문 (NEW) |
| §8 | **용어집** | 10+ 전문 용어 정의 (NEW) |
| §9 | **진행률 매트릭스** | 카테고리별 % 진행 (NEW) |
| §10 | **인터랙티브 요소** | `<details>` 토글 / 클릭 가능 카드 (NEW) |
| §11 | **푸터** | 작성자 + 일자 + 상세 SSoT 링크 |

---

## 파일 참조

| 파일 | 내용 |
|---|---|
| `templates/base.html` | HTML 골격 + CSS (~300 줄) |
| `templates/priority-card.html` | 우선순위 카드 패턴 |
| `templates/analogy-box.html` | 비유 박스 패턴 |
| `templates/decision-tree.html` | 결정 트리 패턴 |
| `templates/faq-section.html` | FAQ 섹션 패턴 |
| `templates/glossary.html` | 용어집 패턴 (NEW) |
| `templates/interactive.html` | 인터랙티브 요소 패턴 (NEW) |
| `references/analogy-bank.md` | 비유 사전 (기술 → 일상) |
| `references/visual-patterns.md` | 시각 자료 패턴 가이드 |
| `references/enhancement-checklist.md` | 이전 한계 극복 체크리스트 |
| `references/output-quality-criteria.md` | 출력 품질 평가 기준 |
| `examples/잔존-의제-비전공자-설명.html` | 이전 v1.0 예시 (강화 baseline) |

---

## 환각 방지

- 가짜 통계 / 가짜 결정 의제 / 가짜 commit 해시 생성 금지
- 본 프로젝트 실제 SSoT (session-handoff.md, CLAUDE.md, *insights.md) 참조 의무
- 사장 lock (L1~L41) 가짜 인용 금지
- 비유는 일상 도메인 (식당/공사장/병원/학교)만 사용 — 모호한 추상 비유 금지

---

## 출력 품질 기준 (자체 점검 12항목)

매 HTML 생성 후 아래 자체 점검:

```
[ ] 1. 통합 비유 1개 + 카드별 비유 N개 (총 N+1개)
[ ] 2. 3단 설명 (무엇/어떻게/왜) 모든 카드 적용
[ ] 3. 책임 매트릭스 (사장/Claude) 모든 카드 명시
[ ] 4. ASCII 다이어그램 / 타임라인 / 매트릭스 충분히 사용
[ ] 5. 결정 트리 5+ Q&A
[ ] 6. 오늘 할 수 있는 것 시간순 매트릭스
[ ] 7. FAQ 5+ 질문 (강화 신규)
[ ] 8. 용어집 10+ 용어 (강화 신규)
[ ] 9. 위험 시나리오 박스 (강화 신규)
[ ] 10. 인터랙티브 요소 (toggle/collapse) (강화 신규)
[ ] 11. 진행률 바 / 통계 (강화 신규)
[ ] 12. 모바일 반응형 + 라이브 렌더 검증 (Chrome MCP)
```

12개 모두 통과 후만 사장님께 보고.

---

## Notion 자동 동기화 (글로벌 룰 정합)

`~/.claude/rules/skill-notion-sync.md` 정합:
- 본 스킬은 카테고리 **"4. QA/테스트 + 코드품질 + 문서 + 배포 + 인프라"** 의 "문서" 영역에 등재
- 신규 등록 시 Notion 카탈로그 자동 갱신 의무
