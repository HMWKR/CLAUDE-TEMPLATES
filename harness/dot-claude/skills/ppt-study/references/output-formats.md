# 출력 형식 템플릿

> skill.md의 Phase 3~6에서 참조하는 PDF/Notion 출력 형식 정의.

---

## 1. 학습 정리 PDF

### 색상 체계

```python
DARK_BLUE  = HexColor('#1a365d')   # 제목, 강조
MID_BLUE   = HexColor('#2b6cb0')   # 섹션 헤더, 테이블 헤더
LIGHT_BLUE = HexColor('#ebf8ff')   # 배경, 표지 박스
ACCENT_BLUE = HexColor('#3182ce')  # 링크, 하이라이트
BG_GRAY    = HexColor('#f7fafc')   # 교차 행 배경
BORDER_GRAY = HexColor('#e2e8f0')  # 테이블 테두리
DARK_GRAY  = HexColor('#2d3748')   # 본문 텍스트
```

### 폰트

```python
pdfmetrics.registerFont(TTFont('Malgun', 'C:/Windows/Fonts/malgun.ttf'))
pdfmetrics.registerFont(TTFont('MalgunBd', 'C:/Windows/Fonts/malgunbd.ttf'))
```

### 스타일 정의

| 용도 | 폰트 | 크기 | 색상 | 정렬 |
|------|------|------|------|------|
| 표지 제목 | MalgunBd | 28pt | DARK_BLUE | CENTER |
| 챕터 제목 | MalgunBd | 18pt | DARK_BLUE | LEFT |
| 섹션 제목 | MalgunBd | 15pt | MID_BLUE | LEFT |
| 소섹션 제목 | MalgunBd | 12pt | DARK_BLUE | LEFT |
| 본문 | Malgun | 10pt | DARK_GRAY | LEFT |
| 불릿 | Malgun | 10pt | DARK_GRAY | LEFT (leftIndent=20) |
| 테이블 헤더 | MalgunBd | 9.5pt | white | CENTER |
| 테이블 셀 | Malgun | 9pt | DARK_GRAY | LEFT |

### 헬퍼 함수 패턴

```python
def colored_box(text, bg_color=LIGHT_BLUE, text_color=DARK_BLUE):
    """색상 배경 강조 박스. 핵심 개념 강조에 사용."""

def tip_box(title, content):
    """팁/참고 박스. LIGHT_BLUE 배경 + MID_BLUE 좌측 테두리."""

def sqld_box(title, content):
    """자격증 관련 포인트 박스. 연한 주황 배경."""

def make_table(headers, rows, col_widths=None):
    """MID_BLUE 헤더 + white/BG_GRAY 교차 행 + BORDER_GRAY 그리드 테이블."""

def hr():
    """BORDER_GRAY 수평 구분선."""

def bullet(text, indent=0):
    """bullet_char(•) + leftIndent=20+indent 불릿 항목."""

def sub_bullet(text):
    """bullet(text, indent=15) 서브 불릿."""
```

### PDF 구조

```
1. 표지
   - Spacer(2*inch)
   - cover_data Table: LIGHT_BLUE 배경, MID_BLUE 테두리
   - 과목명 + 챕터명 서브제목

2. 목차
   - 섹션별 제목 + 페이지 번호 (dotted leader)

3. 섹션별 상세
   - 챕터 제목 (s_chapter)
   - 섹션 제목 (s_section) + hr()
   - 소섹션 제목 (s_subsection)
   - 본문: bullet(), sub_bullet(), make_table(), tip_box(), sqld_box() 조합
   - 핵심 개념: colored_box()로 강조

4. 핵심 요약 페이지
   - 챕터 전체 요약 (불릿 리스트)
   - 시험 출제 포인트 (sqld_box)

5. 페이지 번호
   - 하단 중앙: "- N -"
   - 하단 우측: 과목명
```

---

## 2. 시험문제 PDF

### 색상 체계

```python
NAVY       = HexColor('#1B2A4A')   # 문제 번호, 제목
BLUE       = HexColor('#2E5BA6')   # 섹션 헤더
LIGHT_BLUE = HexColor('#E8F0FE')   # 배경
ACCENT     = HexColor('#D4380D')   # 강조, 주의
GREEN      = HexColor('#389E0D')   # 정답 표시
DARK_GRAY  = HexColor('#4A4A4A')   # 본문
LIGHT_GREEN  = HexColor('#F6FFED') # PART B 정답표 배경
LIGHT_ORANGE = HexColor('#FFF7E6') # PART C 정답표 배경
```

### 폰트

```python
pdfmetrics.registerFont(TTFont('MalgunGothic', 'C:/Windows/Fonts/malgun.ttf'))
pdfmetrics.registerFont(TTFont('MalgunGothicBold', 'C:/Windows/Fonts/malgunbd.ttf'))
```

### 스타일 정의

| 용도 | 폰트 | 크기 | 색상 | 정렬 |
|------|------|------|------|------|
| 표지 제목 | MalgunGothicBold | 22pt | NAVY | CENTER |
| PART 제목 | MalgunGothicBold | 16pt | NAVY | LEFT |
| 소섹션 | MalgunGothicBold | 13pt | BLUE | LEFT |
| 문제 텍스트 | MalgunGothicBold | 11pt | NAVY | LEFT |
| 보기/본문 | MalgunGothic | 10pt | DARK_GRAY | LEFT |
| 정답 표시 | MalgunGothicBold | 10pt | GREEN | LEFT |
| 해설 | MalgunGothic | 9.5pt | DARK_GRAY | LEFT |

### 문제 데이터 구조

```python
# PART B, C의 문제 데이터 구조
question = {
    "q": "문제 텍스트",
    "opts": ["① 보기1", "② 보기2", "③ 보기3", "④ 보기4"],
    "ans": "③",
    "exp": "해설 텍스트"
}
```

### PART 구성

```
PART A: PPT 내 Quiz (교수님 출제 원본)
  - 15~20문항
  - 개별 Paragraph로 작성 (원본 형식 보존)
  - 문제 → 보기 → 정답 + 해설 순서

PART B: PPT 내용 기반 종합 연습문제
  - 20문항
  - question 데이터 구조 사용
  - PPT에서 다룬 개념 기반 4지선다

PART C: 자격증 실전 예상문제
  - 20문항
  - question 데이터 구조 사용
  - 과목 컨텍스트 반영 (예: SQLD 기출 유형)
```

### PDF 구조

```
1. 표지
   - 제목: "{과목명} - {챕터명} 시험문제"
   - 정보표: 총 문항수, PART별 구성, 난이도 분포

2. PART A: PPT Quiz
   - PART 제목 (section_style)
   - 문제별: 번호 + 문제(q_style) → 보기(body_style) → 정답(answer_style) + 해설(explain_style)

3. PART B: 종합 연습문제
   - 동일 형식, question 딕셔너리 루프로 생성

4. PART C: 실전 예상문제
   - 동일 형식

5. 정답 요약표 (3개 Table)
   - PART A: NAVY 헤더 + LIGHT_BLUE 배경
   - PART B: NAVY 헤더 + LIGHT_GREEN 배경
   - PART C: NAVY 헤더 + LIGHT_ORANGE 배경
   - 각 표: 문제번호 | 정답 | 키워드 요약
```

---

## 3. Notion 학습 정리 페이지

### 사전 참조

Notion 페이지 생성 전 반드시 `notion://docs/enhanced-markdown-spec` 리소스를 읽어 enhanced markdown 스펙을 확인한다.

### 페이지 구조

```markdown
# {과목명} - {챕터명} 학습 정리

> 📘 **범위**: {챕터 범위 설명}
> 🎯 **학습 목표**: {핵심 학습 목표 나열}

---

## 1. {섹션1 제목}

### 1.1 {소섹션 제목}

{핵심 개념 설명}

| 구분 | 설명 | 비고 |
|------|------|------|
| ... | ... | ... |

- **핵심 포인트**: ...
  - 세부 설명 1
  - 세부 설명 2

### 1.2 {소섹션 제목}
...

---

## 2. {섹션2 제목}
...

---

## 핵심 요약 체크리스트

- [ ] {핵심 개념 1 이해 여부}
- [ ] {핵심 개념 2 이해 여부}
- [ ] {핵심 개념 3 이해 여부}
...
```

### 스타일 규칙

- **callout** (`>` 블록): 메타 정보, 학습 목표, 중요 포인트에 사용
- **표**: 비교, 분류, 속성 정리에 적극 활용
- **불릿 리스트**: 나열형 정보, 순서 없는 항목
- **번호 리스트**: 순서가 중요한 프로세스, 단계
- **Bold**: 핵심 용어, 정의 강조
- **구분선** (`---`): 섹션 간 시각적 분리
- **체크리스트** (`- [ ]`): 핵심 요약에서 자기 점검용

---

## 4. Notion 시험문제 페이지

### 페이지 구조

```markdown
# {과목명} - {챕터명} 시험문제 리스트 ({총문항수}문항)

> 📝 **구성**: PART A ({n}문항) + PART B ({n}문항) + PART C ({n}문항)
> 📊 **난이도**: 기본 40% / 중급 40% / 심화 20%

---

## PART A: PPT Quiz (교수님 출제)

### Q1. {문제 텍스트}

① {보기1}
② {보기2}
③ {보기3}
④ {보기4}

<details>
<summary>정답 및 해설 보기</summary>

**정답: {정답}**

{해설 텍스트}

</details>

### Q2. {문제 텍스트}
...

---

## PART B: 종합 연습문제

### Q{n}. {문제 텍스트}
...

---

## PART C: {과목/자격증} 실전 예상문제

### Q{n}. {문제 텍스트}
...

---

## 정답 요약

### PART A 정답

| 번호 | 정답 | 키워드 |
|------|------|--------|
| Q1 | ③ | {키워드} |
| Q2 | ② | {키워드} |
...

### PART B 정답

| 번호 | 정답 | 키워드 |
|------|------|--------|
...

### PART C 정답

| 번호 | 정답 | 키워드 |
|------|------|--------|
...
```

### 스타일 규칙

- **`<details><summary>`**: 각 문제의 정답+해설을 접기 처리 (학습 시 자기 테스트 용이)
- **Bold**: 정답 표시, 핵심 키워드 강조
- **표**: 정답 요약표에 사용
- **번호 헤더** (`### Q1.`): 문제 번호 식별
- **구분선** (`---`): PART 간 분리
