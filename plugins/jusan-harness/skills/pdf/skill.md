---
name: pdf
description: Comprehensive PDF manipulation toolkit for extracting text and tables, creating new PDFs, merging/splitting documents, and handling forms. Use when filling in PDF forms or programmatically processing, generating, or analyzing PDF documents at scale.
license: Proprietary. LICENSE.txt has complete terms
---

# PDF Processing Guide

## Overview

This guide covers essential PDF processing operations using Python libraries and command-line tools. For advanced features, JavaScript libraries, and detailed examples, see reference.md. If you need to fill out a PDF form, read forms.md and follow its instructions.

## Quick Start

```python
from pypdf import PdfReader, PdfWriter

# Read a PDF
reader = PdfReader("document.pdf")
print(f"Pages: {len(reader.pages)}")

# Extract text
text = ""
for page in reader.pages:
    text += page.extract_text()
```

## Python Libraries

### pypdf - Basic Operations

#### Merge PDFs
```python
from pypdf import PdfWriter, PdfReader

writer = PdfWriter()
for pdf_file in ["doc1.pdf", "doc2.pdf", "doc3.pdf"]:
    reader = PdfReader(pdf_file)
    for page in reader.pages:
        writer.add_page(page)

with open("merged.pdf", "wb") as output:
    writer.write(output)
```

#### Split PDF
```python
reader = PdfReader("input.pdf")
for i, page in enumerate(reader.pages):
    writer = PdfWriter()
    writer.add_page(page)
    with open(f"page_{i+1}.pdf", "wb") as output:
        writer.write(output)
```

#### Extract Metadata
```python
reader = PdfReader("document.pdf")
meta = reader.metadata
print(f"Title: {meta.title}")
print(f"Author: {meta.author}")
print(f"Subject: {meta.subject}")
print(f"Creator: {meta.creator}")
```

#### Rotate Pages
```python
reader = PdfReader("input.pdf")
writer = PdfWriter()

page = reader.pages[0]
page.rotate(90)  # Rotate 90 degrees clockwise
writer.add_page(page)

with open("rotated.pdf", "wb") as output:
    writer.write(output)
```

### pdfplumber - Text and Table Extraction

#### Extract Text with Layout
```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        print(text)
```

#### Extract Tables
```python
with pdfplumber.open("document.pdf") as pdf:
    for i, page in enumerate(pdf.pages):
        tables = page.extract_tables()
        for j, table in enumerate(tables):
            print(f"Table {j+1} on page {i+1}:")
            for row in table:
                print(row)
```

#### Advanced Table Extraction
```python
import pandas as pd

with pdfplumber.open("document.pdf") as pdf:
    all_tables = []
    for page in pdf.pages:
        tables = page.extract_tables()
        for table in tables:
            if table:  # Check if table is not empty
                df = pd.DataFrame(table[1:], columns=table[0])
                all_tables.append(df)

# Combine all tables
if all_tables:
    combined_df = pd.concat(all_tables, ignore_index=True)
    combined_df.to_excel("extracted_tables.xlsx", index=False)
```

### reportlab - Create PDFs

#### Basic PDF Creation
```python
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

c = canvas.Canvas("hello.pdf", pagesize=letter)
width, height = letter

# Add text
c.drawString(100, height - 100, "Hello World!")
c.drawString(100, height - 120, "This is a PDF created with reportlab")

# Add a line
c.line(100, height - 140, 400, height - 140)

# Save
c.save()
```

#### Create PDF with Multiple Pages
```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.styles import getSampleStyleSheet

doc = SimpleDocTemplate("report.pdf", pagesize=letter)
styles = getSampleStyleSheet()
story = []

# Add content
title = Paragraph("Report Title", styles['Title'])
story.append(title)
story.append(Spacer(1, 12))

body = Paragraph("This is the body of the report. " * 20, styles['Normal'])
story.append(body)
story.append(PageBreak())

# Page 2
story.append(Paragraph("Page 2", styles['Heading1']))
story.append(Paragraph("Content for page 2", styles['Normal']))

# Build PDF
doc.build(story)
```

## Command-Line Tools

### pdftotext (poppler-utils)
```bash
# Extract text
pdftotext input.pdf output.txt

# Extract text preserving layout
pdftotext -layout input.pdf output.txt

# Extract specific pages
pdftotext -f 1 -l 5 input.pdf output.txt  # Pages 1-5
```

### qpdf
```bash
# Merge PDFs
qpdf --empty --pages file1.pdf file2.pdf -- merged.pdf

# Split pages
qpdf input.pdf --pages . 1-5 -- pages1-5.pdf
qpdf input.pdf --pages . 6-10 -- pages6-10.pdf

# Rotate pages
qpdf input.pdf output.pdf --rotate=+90:1  # Rotate page 1 by 90 degrees

# Remove password
qpdf --password=mypassword --decrypt encrypted.pdf decrypted.pdf
```

### pdftk (if available)
```bash
# Merge
pdftk file1.pdf file2.pdf cat output merged.pdf

# Split
pdftk input.pdf burst

# Rotate
pdftk input.pdf rotate 1east output rotated.pdf
```

## Common Tasks

### Extract Text from Scanned PDFs
```python
# Requires: pip install pytesseract pdf2image
import pytesseract
from pdf2image import convert_from_path

# Convert PDF to images
images = convert_from_path('scanned.pdf')

# OCR each page
text = ""
for i, image in enumerate(images):
    text += f"Page {i+1}:\n"
    text += pytesseract.image_to_string(image)
    text += "\n\n"

print(text)
```

### Add Watermark
```python
from pypdf import PdfReader, PdfWriter

# Create watermark (or load existing)
watermark = PdfReader("watermark.pdf").pages[0]

# Apply to all pages
reader = PdfReader("document.pdf")
writer = PdfWriter()

for page in reader.pages:
    page.merge_page(watermark)
    writer.add_page(page)

with open("watermarked.pdf", "wb") as output:
    writer.write(output)
```

### Extract Images
```bash
# Using pdfimages (poppler-utils)
pdfimages -j input.pdf output_prefix

# This extracts all images as output_prefix-000.jpg, output_prefix-001.jpg, etc.
```

### Password Protection
```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
writer = PdfWriter()

for page in reader.pages:
    writer.add_page(page)

# Add password
writer.encrypt("userpassword", "ownerpassword")

with open("encrypted.pdf", "wb") as output:
    writer.write(output)
```

## Quick Reference

| Task | Best Tool | Command/Code |
|------|-----------|--------------|
| Merge PDFs | pypdf | `writer.add_page(page)` |
| Split PDFs | pypdf | One page per file |
| Extract text | pdfplumber | `page.extract_text()` |
| Extract tables | pdfplumber | `page.extract_tables()` |
| Create PDFs | reportlab | Canvas or Platypus |
| Command line merge | qpdf | `qpdf --empty --pages ...` |
| OCR scanned PDFs | pytesseract | Convert to image first |
| Fill PDF forms | pdf-lib or pypdf (see forms.md) | See forms.md |

## Next Steps

- For advanced pypdfium2 usage, see reference.md
- For JavaScript libraries (pdf-lib), see reference.md
- If you need to fill out a PDF form, follow the instructions in forms.md
- For troubleshooting guides, see reference.md

## 참조

- 전문가 역할: `${CLAUDE_PLUGIN_ROOT}/skills/_core/roles.md`
- 문제 해결 프로토콜: `${CLAUDE_PLUGIN_ROOT}/skills/_core/protocols.md`


## PDF 도구 선택 가이드

### 의사결정 트리

```
PDF 작업 → 어떤 작업?
├── 텍스트 추출 → 표가 있나?
│   ├── 표 있음 → pdfplumber (표 + 텍스트)
│   └── 표 없음 → pypdf (빠른 텍스트 추출)
│
├── PDF 생성 → 복잡도?
│   ├── 단순 보고서 → reportlab
│   └── 기존 PDF 수정 → pypdf + reportlab
│
├── PDF 병합/분할 → pypdf
│
├── 폼 필드 처리 → pypdf (읽기) + reportlab (작성)
│
└── 이미지 추출 → pypdf 또는 pdfplumber
```

### 라이브러리 비교

| 기능 | pypdf | pdfplumber | reportlab |
|------|:-----:|:---------:|:---------:|
| 텍스트 추출 | O | O (우수) | X |
| 표 추출 | X | O | X |
| PDF 생성 | X | X | O |
| 병합/분할 | O | X | X |
| 폼 처리 | O | X | 부분 |
| 메타데이터 | O | O | O |
| 속도 | 빠름 | 보통 | 빠름 |

## 한국어 PDF 처리

### 한국어 폰트 설정 (reportlab)

```python
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

# 시스템 폰트 등록
pdfmetrics.registerFont(TTFont('MalgunGothic', 'malgun.ttf'))
pdfmetrics.registerFont(TTFont('MalgunGothicBold', 'malgunbd.ttf'))

# 캔버스에서 사용
canvas.setFont('MalgunGothic', 12)
canvas.drawString(100, 700, '한국어 텍스트')
```

### 한국어 텍스트 추출 주의사항

- pypdf: 대부분의 한국어 PDF에서 정상 추출
- pdfplumber: CID 폰트 매핑이 없는 경우 깨짐 가능
- 인코딩 이슈: UTF-8 강제 설정 필요할 수 있음

```python
# 한국어 추출 검증
text = page.extract_text()
if text and any('가' <= c <= '힣' for c in text):
    print("한국어 추출 성공")
else:
    print("한국어 추출 실패 - 대안 시도 필요")
```

## 에러 처리 가이드

### 일반적 에러와 해결

| 에러 | 원인 | 해결 |
|------|------|------|
| PdfReadError | 손상된 PDF | strict=False로 재시도 |
| PasswordError | 암호화된 PDF | decrypt(password) 호출 |
| DependencyError | 누락 라이브러리 | pip install 확인 |
| UnicodeDecodeError | 인코딩 불일치 | 바이너리 모드로 읽기 |

### 방어적 PDF 처리

```python
from pypdf import PdfReader
from pypdf.errors import PdfReadError

def safe_read_pdf(path):
    try:
        reader = PdfReader(path)
    except PdfReadError:
        reader = PdfReader(path, strict=False)

    if reader.is_encrypted:
        try:
            reader.decrypt('')
        except Exception:
            raise ValueError('암호가 필요한 PDF입니다')

    pages_text = []
    for i, page in enumerate(reader.pages):
        try:
            text = page.extract_text() or ''
            pages_text.append(text)
        except Exception as e:
            pages_text.append(f'[페이지 {i+1} 추출 실패: {e}]')

    return pages_text
```

## 고급 패턴

### PDF 워터마크 추가

```python
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas as rl_canvas
from pypdf import PdfReader, PdfWriter
import io

def add_watermark(input_path, output_path, text):
    packet = io.BytesIO()
    c = rl_canvas.Canvas(packet, pagesize=A4)
    c.setFont('Helvetica', 40)
    c.setFillAlpha(0.3)
    c.translate(A4[0]/2, A4[1]/2)
    c.rotate(45)
    c.drawCentredString(0, 0, text)
    c.save()
    packet.seek(0)

    watermark = PdfReader(packet)
    reader = PdfReader(input_path)
    writer = PdfWriter()

    for page in reader.pages:
        page.merge_page(watermark.pages[0])
        writer.add_page(page)

    with open(output_path, 'wb') as f:
        writer.write(f)
```

### 대용량 PDF 최적화

- 100페이지 이상: 페이지 범위 지정 처리
- 이미지 많은 PDF: 메모리 모니터링
- 배치 처리: 파일 단위 순차 처리


## 배치 처리 패턴

### 여러 PDF 병합

```python
from pypdf import PdfWriter

writer = PdfWriter()
for pdf_file in sorted(glob.glob('documents/*.pdf')):
    writer.append(pdf_file)
writer.write('merged.pdf')
writer.close()
```

### PDF 분할

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader('large.pdf')
for i, page in enumerate(reader.pages):
    writer = PdfWriter()
    writer.add_page(page)
    writer.write(f'page_{i+1:03d}.pdf')
    writer.close()
```

### 메타데이터 수정

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader('input.pdf')
writer = PdfWriter()
for page in reader.pages:
    writer.add_page(page)

writer.add_metadata({
    '/Title': 'Document Title',
    '/Author': 'Author Name',
    '/Subject': 'Subject',
    '/Creator': 'Python pypdf'
})
writer.write('output.pdf')
```

## 보안 고려사항

- 사용자 업로드 PDF는 항상 검증 후 처리
- 악성 JavaScript가 포함된 PDF 주의
- 대용량 PDF는 메모리 제한 설정
- 암호화된 PDF 처리 시 비밀번호 안전 관리


## 배치 처리 가이드

### PDF 병합

```python
from PyPDF2 import PdfMerger

merger = PdfMerger()
for pdf_path in ['file1.pdf', 'file2.pdf', 'file3.pdf']:
    merger.append(pdf_path)
merger.write('merged.pdf')
merger.close()
```

### PDF 분할

```python
from PyPDF2 import PdfReader, PdfWriter

reader = PdfReader('large.pdf')
for i, page in enumerate(reader.pages):
    writer = PdfWriter()
    writer.add_page(page)
    writer.write(f'page_{i+1}.pdf')
```

### 메타데이터 수정

```python
from PyPDF2 import PdfReader, PdfWriter

reader = PdfReader('input.pdf')
writer = PdfWriter()
for page in reader.pages:
    writer.add_page(page)

writer.add_metadata({
    '/Title': 'Document Title',
    '/Author': 'Author Name',
    '/Subject': 'Subject',
})
writer.write('output.pdf')
```

## 보안 고려사항

### 비밀번호 보호

```python
from PyPDF2 import PdfWriter

writer = PdfWriter()
# 페이지 추가 후
writer.encrypt(user_password='read_pass', owner_password='admin_pass')
writer.write('protected.pdf')
```

### 민감정보 처리 주의사항

- PDF 텍스트 추출 시 개인정보(주민번호, 계좌번호) 자동 마스킹 고려
- OCR 결과물에서 민감 데이터 필터링
- 임시 파일 처리 후 안전한 삭제 (os.remove)
- 메모리에 로드된 민감 데이터는 사용 후 즉시 해제
