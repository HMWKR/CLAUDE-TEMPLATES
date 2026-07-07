---
name: ppt-study
description: |
  PPT 학습자료 자동 생성 스킬. PPT 파일을 분석하여 PDF 학습 정리 + PDF 시험문제 + Notion 페이지 2종을 자동 생성.
  Use when "/ppt-study", "PPT 정리", "PPT 분석해서 정리", "시험자료 만들어줘",
  "수업자료 정리", or user provides a .pptx file for study material generation.
  NOT for: simple PPT file reading, PPT template creation, or slide design tasks.
user_invocable: true
version: 1.0.0
---

# PPT 학습자료 자동 생성 파이프라인

## Core Principle

대학 수업 PPT 파일을 입력받아, **학습 정리 PDF + 시험문제 PDF + Notion 학습 정리 + Notion 시험문제** 4종 산출물을 자동 생성한다.

## Announce Pattern

스킬 시작 시 반드시 다음을 출력한다:

> "PPT 학습자료 자동 생성 파이프라인을 시작합니다. PPT 분석 → PDF 학습 정리 → PDF 시험문제 → Notion 학습 정리 → Notion 시험문제 순서로 진행합니다."

---

## Trigger Rules

### 트리거 (작동)

- `/ppt-study` (슬래시 커맨드 직접 호출)
- `/ppt-study <파일경로>` — 파일경로와 함께 호출
- "PPT 정리해줘", "PPT 분석해서 정리", "수업자료 정리해줘"
- "시험자료 만들어줘" + PPT 파일이 컨텍스트에 있을 때
- 사용자가 .pptx 파일을 제공하며 학습/시험 자료 생성을 요청할 때

### 비트리거 (작동 안 함)

- PPT 파일 단순 열기/읽기 요청
- PPT 템플릿 생성, 슬라이드 디자인 요청
- PPT → PDF 단순 변환 (학습 정리 없이)
- "PPT 만들어줘" (생성 요청)

---

## Input Requirements

### 필수
- **PPT 파일 경로**: `.pptx` 파일의 절대 경로 또는 상대 경로

### 선택 (없으면 AskUserQuestion으로 질문)
- **과목/자격증 컨텍스트**: 예) "SQLD", "정보처리기사", "데이터베이스" 등
- **사용자 도메인 지식 수준**: 예) "대학생 2학년", "비전공자", "현업 개발자"

스킬 호출 시 인자가 부족하면:

```
AskUserQuestion:
1. PPT 파일 경로를 입력해주세요
2. 어떤 과목/자격증 시험을 위한 자료인가요?
3. 학습자 수준은? (대학생 / 비전공자 / 현업)
```

---

## Pipeline (6단계)

### Phase 1: PPT 이미지 추출

**목적**: PPT 슬라이드를 이미지로 추출하여 분석 준비

**프로세스**:
1. PPT 파일을 python zipfile로 열어 `ppt/media/` 내 이미지 파일들을 추출
2. 추출 디렉토리: `{PPT파일_디렉토리}/ppt_images/ppt/media/`
3. 추출된 이미지 개수를 카운트하여 보고

**코드 패턴**:
```python
import zipfile, os, sys
sys.stdout.reconfigure(encoding='utf-8')

pptx_path = "INPUT_PATH"
extract_dir = os.path.join(os.path.dirname(pptx_path), "ppt_images")
os.makedirs(extract_dir, exist_ok=True)

with zipfile.ZipFile(pptx_path, 'r') as z:
    media_files = [f for f in z.namelist() if f.startswith('ppt/media/')]
    for f in media_files:
        z.extract(f, extract_dir)

print(f"추출 완료: {len(media_files)}개 이미지")
```

### Phase 2: 이미지 시각 분석

**목적**: 추출된 이미지를 Read 도구로 읽어 내용을 구조화

**프로세스**:
1. 추출된 이미지를 순서대로 Read 도구로 읽기 (멀티모달 분석)
2. 각 이미지에서 다음을 추출:
   - 섹션 구분 (목차, 제목 슬라이드 식별)
   - 핵심 개념, 정의, 분류 체계
   - 표, 다이어그램, 비교표 내용
   - Quiz/문제 슬라이드 식별 및 문제+정답 추출
3. 섹션별로 구조화된 데이터로 정리

**효율화 규칙**:
- 이미지가 30개 미만: 전체 Read
- 이미지가 30~60개: 5개씩 배치로 Read (병렬 가능)
- 이미지가 60개 초과: 10개씩 배치로 Read, 중복/빈 슬라이드 스킵
- 목차 슬라이드를 먼저 찾아 전체 구조를 파악한 후 상세 분석 진행

### Phase 3: PDF 학습 정리 생성

**목적**: 분석된 내용을 체계적인 학습 자료 PDF로 생성

**프로세스**:
1. `generate_study_pdf.py` 스크립트 작성
2. 출력 형식: `references/output-formats.md`의 "학습 정리 PDF" 섹션 참조
3. 스크립트 실행하여 PDF 생성
4. 생성 결과 보고

**핵심 요소**:
- reportlab 라이브러리 사용
- 한글 폰트: 플랫폼별 시스템 한글 폰트를 자동 탐색 (macOS: `AppleGothic`/`Apple SD Gothic Neo`, Linux: `NanumGothic`, Windows: `Malgun Gothic`). 미발견 시 사용자에게 알림
- 색상 체계: Navy(#1B2A4A) 기반 전문적 디자인
- 구조: 표지 → 목차 → 섹션별 상세 → 핵심 요약

### Phase 4: PDF 시험문제 생성

**목적**: PPT 내 문제 + 자체 예상문제를 포함한 시험문제 PDF 생성

**프로세스**:
1. `generate_exam_pdf.py` 스크립트 작성
2. 출력 형식: `references/output-formats.md`의 "시험문제 PDF" 섹션 참조
3. 스크립트 실행하여 PDF 생성
4. 생성 결과 보고

**문제 구성**:
- **PART A**: PPT 내 Quiz/문제 (교수님 출제 원본)
- **PART B**: PPT 내용 기반 종합 연습문제 (20문항)
- **PART C**: 자격증 실전 예상문제 (20문항, 과목 컨텍스트 반영)
- 각 PART에 정답표 포함
- 모든 문제에 상세 해설 포함

### Phase 5: Notion 학습 정리 페이지

**목적**: 온라인에서 접근 가능한 구조화된 학습 정리 페이지

**프로세스**:
1. Notion MCP 도구(`mcp__claude_ai_Notion__notion-create-pages`)로 페이지 생성
2. enhanced markdown 스펙 준수 (먼저 `notion://docs/enhanced-markdown-spec` 참조)
3. 출력 형식: `references/output-formats.md`의 "Notion 학습 정리" 섹션 참조

**Notion 페이지 구조**:
- 제목: `{과목명} - {챕터명} 학습 정리`
- callout으로 메타 정보 (범위, 학습 목표)
- 섹션별 핵심 개념 정리 (표, 리스트 활용)
- 핵심 요약 체크리스트

### Phase 6: Notion 시험문제 페이지

**목적**: 온라인에서 접근 가능한 시험문제 페이지

**프로세스**:
1. Notion MCP 도구로 페이지 생성
2. 출력 형식: `references/output-formats.md`의 "Notion 시험문제" 섹션 참조

**Notion 페이지 구조**:
- 제목: `{과목명} - {챕터명} 시험문제 리스트 ({총문항수}문항)`
- PART별 구분
- 각 문제: 문제 → 보기 → 정답+해설 (`<details><summary>` 접기)
- 정답 요약표 (PART별)

---

## Post-Pipeline

### 완료 보고

모든 Phase 완료 후 다음을 출력한다:

```markdown
## 생성 완료

### 생성된 파일
| # | 산출물 | 경로/링크 |
|---|--------|-----------|
| 1 | 학습 정리 PDF | {파일경로} |
| 2 | 시험문제 PDF | {파일경로} |
| 3 | Notion 학습 정리 | {URL} |
| 4 | Notion 시험문제 | {URL} |

### 추천 학습 순서
1. 학습 정리 PDF/Notion으로 내용 숙지
2. 시험문제 PART A (교수님 Quiz) — 수업 핵심 확인
3. 시험문제 PART B (종합 연습) — 이해도 점검
4. 시험문제 PART C (실전 예상) — 시험 대비
```

### 정리

- 생성된 Python 스크립트는 PPT 파일과 같은 디렉토리에 보관 (재사용 가능)
- `ppt_images/` 디렉토리는 분석 완료 후 유지 (사용자가 삭제 가능)

---

## Error Handling

### PPT 관련
- PPT 파일이 존재하지 않음 → 경로 재확인 요청
- PPT에 이미지가 없음 (텍스트 기반) → python-pptx로 텍스트 직접 추출 시도
- 이미지가 너무 많음 (100+) → 배치 처리 + 진행 상황 보고

### PDF 관련
- reportlab 미설치 → `pip install reportlab` 자동 실행
- 한글 폰트 없음 → 대체 폰트 탐색 또는 사용자에게 알림

### Notion 관련
- Notion MCP 미연결 → PDF만 생성하고 Notion은 스킵, 사용자에게 알림
- 페이지 생성 실패 → 에러 내용 보고 후 재시도 또는 스킵

---

## Red Flags

**Never:**
- PPT 내용을 추측하지 않는다 — 반드시 이미지를 Read로 확인한 후 정리
- 교수님 Quiz를 변형하지 않는다 — 원본 그대로 보존
- 정답이 불확실한 문제를 만들지 않는다 — 명확한 근거가 있는 문제만 출제

**Don't:**
- Phase를 건너뛰지 않는다 (Notion MCP 미연결 시만 예외)
- 섹션 구분을 임의로 하지 않는다 — PPT 목차/구조를 따른다
- 과도한 문제 수를 생성하지 않는다 — PART별 15~20문항이 적정

## PDF 생성 상세 사양

### reportlab 색상 체계

학습 정리 PDF와 시험문제 PDF에서 일관된 색상 체계를 적용한다:

| 요소 | 색상 코드 | 용도 |
|------|-----------|------|
| Navy | `#1B2A4A` | 표지 배경, 섹션 헤더 배경 |
| Dark Blue | `#2C3E6B` | 소제목 텍스트, 테이블 헤더 |
| Accent Gold | `#D4A843` | 강조 텍스트, 구분선, 중요 마커 |
| Light Gray | `#F5F5F5` | 테이블 짝수 행 배경 |
| White | `#FFFFFF` | 본문 배경, 테이블 홀수 행 |
| Black | `#333333` | 본문 텍스트 |
| Red | `#C0392B` | 정답 표시, 오답 해설 강조 |
| Green | `#27AE60` | 정답 해설 강조, 체크 마커 |

### 폰트 사양

| 용도 | 폰트 | 크기 | 스타일 |
|------|------|------|--------|
| 표지 제목 | Malgun Gothic Bold | 28pt | Bold |
| 표지 부제 | Malgun Gothic | 16pt | Normal |
| 섹션 제목 (H1) | Malgun Gothic Bold | 18pt | Bold |
| 소제목 (H2) | Malgun Gothic Bold | 14pt | Bold |
| 본문 | Malgun Gothic | 11pt | Normal |
| 표 내용 | Malgun Gothic | 10pt | Normal |
| 각주/출처 | Malgun Gothic | 8pt | Normal, Gray |

### 페이지 레이아웃

- **용지**: A4 (210mm × 297mm)
- **여백**: 상 25mm, 하 20mm, 좌우 각 20mm
- **머리글**: 과목명 + 챕터명 (8pt, 우측 정렬)
- **바닥글**: 페이지 번호 (10pt, 가운데 정렬)
- **섹션 간 간격**: 15pt
- **단락 간 간격**: 8pt

### 시험문제 PDF 레이아웃 규칙

- 문제 번호: Bold, 11pt, 왼쪽 정렬
- 보기: 들여쓰기 20pt, 번호+본문 구분
- 정답표: 별도 페이지에 5열 테이블로 구성
- 해설: 정답표 뒤에 문제별 상세 해설 포함
- PART 구분: 페이지 나눔 (PageBreak) 적용

---

## Notion 페이지 생성 상세

### Enhanced Markdown 활용 패턴

Notion 페이지 생성 시 다음 enhanced markdown 패턴을 활용한다:

- **Callout 블록**: 메타 정보, 주의사항, 핵심 요약에 사용
  ```
  > [!info] 학습 범위
  > Chapter 3: 데이터 모델링 (슬라이드 1-45)
  ```

- **Toggle 블록**: 상세 해설, 보충 설명에 사용
  ```
  <details>
  <summary>상세 해설 보기</summary>
  해설 내용...
  </details>
  ```

- **표**: 개념 비교, 분류 체계, 정답표에 사용
- **체크리스트**: 핵심 요약, 학습 체크포인트에 사용
- **구분선**: 섹션 간 시각적 분리에 사용

### Notion 페이지 메타 정보

모든 Notion 페이지 상단에 다음 메타 정보를 callout으로 포함한다:

```
> [!info] 학습 정보
> - 과목: {과목명}
> - 범위: {챕터/범위}
> - 생성일: {YYYY-MM-DD}
> - 슬라이드 수: {N}장
> - 학습 목표: {목차 기반 핵심 목표 2-3개}
```

---

## 고급 설정 옵션

### 문제 난이도 조절

사용자가 난이도를 지정하면 PART B, C의 문제 구성을 조절한다:

| 난이도 | 기본 문제 비율 | 심화 문제 비율 | 함정 문제 포함 |
|--------|:-----------:|:-----------:|:----------:|
| 기초 | 70% | 20% | 10% |
| 표준 (기본) | 50% | 35% | 15% |
| 심화 | 30% | 45% | 25% |

### 출력 선택적 스킵

사용자가 특정 산출물만 필요한 경우 Phase를 선택적으로 실행할 수 있다:

- `/ppt-study --pdf-only` : PDF 2종만 생성 (Phase 1-4)
- `/ppt-study --notion-only` : Notion 2종만 생성 (Phase 1-2, 5-6)
- `/ppt-study --exam-only` : 시험문제만 생성 (Phase 1-2, 4, 6)

### 대량 PPT 배치 처리

여러 PPT 파일을 한 번에 처리하는 경우:

1. 파일 목록을 수집하고 순서를 확인
2. 각 PPT를 순차적으로 Phase 1-2 처리
3. 전체 분석 결과를 통합하여 Phase 3-6 실행
4. 통합 목차와 개별 섹션을 모두 포함하는 산출물 생성

---

## 확장 에러 핸들링

### 인코딩 관련

- PPT 내 특수문자(수학 기호, 그리스 문자)가 깨지는 경우 → UTF-8 인코딩 강제 적용
- CJK 문자가 혼재된 PPT → 폰트별 렌더링 확인 후 대체 폰트 자동 매핑

### 구조 분석 실패

- 목차 슬라이드가 없는 PPT → 제목 슬라이드 패턴(큰 텍스트, 단일 텍스트 박스)으로 자동 섹션 구분
- 이미지 기반 슬라이드(스캔본) → OCR 불가 시 사용자에게 텍스트 수동 입력 요청
- 애니메이션/전환 효과로 동일 내용이 중복 추출 → 이미지 유사도 비교로 중복 제거

### 출력 품질 검증

- PDF 생성 후 페이지 수와 예상 페이지 수 비교
- Notion 페이지 생성 후 URL 접근 가능 여부 확인
- 시험문제의 정답 분포 검증 (특정 번호 편중 방지: 각 보기 20-30% 범위)

---

## 참조

- 전문가 역할: `${CLAUDE_PLUGIN_ROOT}/skills/_core/roles.md`
- 문제 해결 프로토콜: `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md`
