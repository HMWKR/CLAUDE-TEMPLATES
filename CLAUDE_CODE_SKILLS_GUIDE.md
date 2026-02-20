# Claude Code 스킬 완전 가이드 (내 설치 스킬 기준)

> 작성일: 2026-02-20
> 버전: 3.0 (CE v2.0 반영)
> 설치 위치: `~/.claude/skills/`

---

# 현재 설치된 스킬 목록

```
~/.claude/skills/
├── ce-advisor/                     # CE + PE 하이브리드 프롬프트 최적화 ⭐ NEW
├── docx/                           # Word 문서 처리
├── js-refactor-cleanup-skill/      # JS/TS 리팩토링
├── pdf/                            # PDF 처리
├── superpowers/                    # 20+ 개발 워크플로우 스킬
├── unused-code-refactor-suggester/ # 미사용 코드 탐지
├── vercel-deploy/                  # Vercel 배포
├── vercel-react-best-practices/    # React 성능 최적화
├── web-design-guidelines/          # UI/UX 가이드라인
└── xlsx/                           # Excel 처리
```

---

# 0. ce-advisor (Context Engineering Advisor) ⭐ NEW

> CE + PE 하이브리드 프롬프트 최적화 스킬

## 사용법

```
/ce-advisor
```

## 기능

| 기능 | 설명 |
|:----:|------|
| 3+1 제안 | High-Signal / Context-Rich / Multi-Turn / 함께 구체화 |
| 토큰 예산 표시 | 각 제안의 예상 토큰 비용 |
| CE 실패 모드 경고 | Poisoning/Distraction/Confusion/Clash 자동 진단 |
| 위치 최적화 | Primacy/Middle/Recency 배치 가이드 |
| 컨텍스트 스냅샷 | 현재 사용량 기반 권장 전략 |
| 패턴 학습 | auto memory 연동, 이전 선택 참조 |

## 적용 원칙

- **Right Altitude**: 3개 제안이 간결↔상세 스펙트럼 커버
- **Primacy/Recency**: 위치 최적화 시각화
- **4대 실패 모드**: 매 분석마다 자동 진단

---

# 1. superpowers (핵심 스킬 모음) ⭐

> obra/superpowers - 20+ 개의 검증된 개발 스킬 라이브러리

## 1.1 test-driven-development

### 사용 상황
- **새 기능 구현 시** - 모든 새 코드 작성 전
- **버그 수정 시** - 수정 전 실패 테스트 작성
- **리팩토링 시** - 기존 동작 보장

### 핵심 원칙
```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

### 워크플로우
| 단계 | 행동 | 검증 |
|:----:|------|------|
| **RED** | 실패하는 테스트 작성 | 테스트가 올바른 이유로 실패하는지 확인 |
| **GREEN** | 테스트 통과할 최소 코드 작성 | 모든 테스트 통과 확인 |
| **REFACTOR** | 코드 정리 | 테스트 여전히 통과 확인 |

### 금지 사항
- 테스트 없이 코드 작성 ❌
- 테스트 후 코드 유지 ("참고용") ❌
- "이번만 TDD 건너뛰기" ❌

---

## 1.2 systematic-debugging

### 사용 상황
- **테스트 실패 시**
- **프로덕션 버그 발생 시**
- **예상치 못한 동작 발생 시**
- **성능 문제 발생 시**
- **빌드 실패 시**

### 핵심 원칙
```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

### 4단계 디버깅 프로세스

| 단계 | 이름 | 행동 |
|:----:|------|------|
| 1 | **Root Cause** | 에러 메시지 완전히 읽기, 재현, 최근 변경 확인, 증거 수집 |
| 2 | **Pattern** | 작동하는 유사 코드 찾기, 차이점 비교 |
| 3 | **Hypothesis** | 단일 가설 수립, 최소 변경으로 테스트 |
| 4 | **Implementation** | 실패 테스트 케이스 생성 → 단일 수정 → 검증 |

### 3회 이상 수정 실패 시
- **멈추고 아키텍처 재검토**
- 패턴 자체가 문제일 수 있음
- 증상 수정 대신 근본 재설계 고려

---

## 1.3 verification-before-completion

### 사용 상황
- **작업 완료 선언 전**
- **커밋/푸시/PR 생성 전**
- **다음 작업으로 이동 전**
- **에이전트에게 위임 전**

### 핵심 원칙
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

### 검증 게이트
```
1. IDENTIFY: 이 주장을 증명할 명령어는?
2. RUN: 명령어 실행 (신선하게, 완전히)
3. READ: 전체 출력, 종료 코드, 실패 수 확인
4. VERIFY: 출력이 주장을 확인하는가?
5. ONLY THEN: 주장하기
```

### 금지 표현
- "아마 될 거예요" ❌
- "확신해요" (증거 없이) ❌
- "완료!" (검증 없이) ❌

---

## 1.4 subagent-driven-development

### 사용 상황
- **구현 계획이 있고 태스크가 독립적일 때**
- **같은 세션에서 병렬 실행 필요 시**
- **품질 게이트가 필요한 복잡한 구현 시**

### 워크플로우
```
1. 계획 읽기 → 모든 태스크 추출
2. 태스크마다:
   a. 구현 서브에이전트 디스패치
   b. 스펙 준수 리뷰어 디스패치
   c. 코드 품질 리뷰어 디스패치
3. 모든 태스크 완료 후 최종 코드 리뷰
```

### 2단계 리뷰 시스템
| 순서 | 리뷰어 | 검증 내용 |
|:----:|--------|----------|
| 1 | **Spec Reviewer** | 스펙 준수 여부, 누락/추가 기능 |
| 2 | **Code Quality** | 코드 품질, 매직 넘버, 명명 규칙 |

---

## 1.5 defense-in-depth

### 사용 상황
- **버그 수정 후 재발 방지 시**
- **데이터 유효성 검증 필요 시**
- **여러 레이어를 거치는 데이터 흐름 시**

### 4개 레이어 검증

| 레이어 | 목적 | 예시 |
|:------:|------|------|
| **Entry Point** | API 경계에서 명백히 잘못된 입력 거부 | 빈 문자열, 존재하지 않는 경로 |
| **Business Logic** | 이 작업에 데이터가 적합한지 확인 | 필수 파라미터 검증 |
| **Environment Guards** | 특정 컨텍스트에서 위험한 작업 방지 | 테스트 중 tmpdir 외부 git init 거부 |
| **Debug Instrumentation** | 포렌식을 위한 컨텍스트 캡처 | 스택 트레이스 로깅 |

---

# 2. 문서 처리 스킬

## 2.1 docx (Word 문서)

### 사용 상황
| 작업 | 트리거 |
|------|--------|
| **새 문서 생성** | "Word 문서 만들어줘", "보고서 작성해줘" |
| **문서 편집** | "이 문서 수정해줘", "내용 추가해줘" |
| **변경 추적** | "redline으로 수정해줘", "tracked changes" |
| **텍스트 추출** | "문서 내용 읽어줘", "텍스트 추출해줘" |

### 워크플로우 결정 트리
```
읽기/분석 → pandoc으로 마크다운 변환
새 문서 생성 → docx-js (JavaScript)
기존 문서 편집 → Document library (Python)
법률/비즈니스 문서 → Redlining workflow 필수
```

### 핵심 명령어
```bash
# 텍스트 추출 (변경 추적 포함)
pandoc --track-changes=all document.docx -o output.md

# 문서 언팩
python ooxml/scripts/unpack.py document.docx output_dir

# 문서 팩
python ooxml/scripts/pack.py input_dir document.docx
```

---

## 2.2 pdf (PDF 처리)

### 사용 상황
| 작업 | 트리거 |
|------|--------|
| **텍스트 추출** | "PDF 내용 읽어줘", "텍스트 추출해줘" |
| **테이블 추출** | "표 데이터 추출해줘", "엑셀로 변환해줘" |
| **PDF 병합** | "PDF 합쳐줘", "문서 합치기" |
| **PDF 분할** | "페이지별로 나눠줘", "특정 페이지 추출" |
| **폼 채우기** | "PDF 폼 작성해줘", "양식 채워줘" |

### Python 라이브러리 선택
| 작업 | 라이브러리 |
|------|-----------|
| 기본 작업 (병합/분할/회전) | `pypdf` |
| 텍스트/테이블 추출 | `pdfplumber` |
| 새 PDF 생성 | `reportlab` |
| OCR (스캔 PDF) | `pytesseract` + `pdf2image` |

### 핵심 코드
```python
# 테이블 추출
import pdfplumber
with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        tables = page.extract_tables()

# PDF 병합
from pypdf import PdfWriter, PdfReader
writer = PdfWriter()
for pdf_file in ["doc1.pdf", "doc2.pdf"]:
    reader = PdfReader(pdf_file)
    for page in reader.pages:
        writer.add_page(page)
```

---

## 2.3 xlsx (Excel 스프레드시트)

### 사용 상황
| 작업 | 트리거 |
|------|--------|
| **데이터 분석** | "엑셀 분석해줘", "통계 내줘" |
| **새 스프레드시트 생성** | "엑셀 만들어줘", "수식 포함해서" |
| **기존 파일 편집** | "엑셀 수정해줘", "셀 업데이트" |
| **수식 재계산** | "수식 업데이트해줘", "계산 다시 해줘" |

### 핵심 원칙
```
항상 Excel 수식 사용, Python 계산값 하드코딩 금지!
```

### 올바른 예시
```python
# ✅ 좋음 - Excel이 계산
sheet['B10'] = '=SUM(B2:B9)'
sheet['C5'] = '=(C4-C2)/C2'

# ❌ 나쁨 - Python이 계산 후 하드코딩
total = df['Sales'].sum()
sheet['B10'] = total  # 5000 하드코딩
```

### 라이브러리 선택
| 작업 | 라이브러리 |
|------|-----------|
| 데이터 분석 | `pandas` |
| 수식/서식 | `openpyxl` |
| 수식 재계산 | `recalc.py` (LibreOffice 필요) |

---

# 3. 개발 도구 스킬

## 3.1 vercel-react-best-practices

### 사용 상황
| 작업 | 트리거 |
|------|--------|
| **새 React 컴포넌트 작성** | "컴포넌트 만들어줘" |
| **Next.js 페이지 구현** | "페이지 만들어줘" |
| **데이터 페칭 구현** | "API 호출 추가해줘" |
| **코드 리뷰** | "성능 검토해줘", "최적화해줘" |
| **번들 최적화** | "번들 크기 줄여줘" |

### 우선순위별 규칙 (45개)

| 우선순위 | 카테고리 | 영향도 | 핵심 규칙 |
|:--------:|----------|:------:|----------|
| 1 | **Waterfall 제거** | CRITICAL | `Promise.all()`, Suspense 사용 |
| 2 | **번들 최적화** | CRITICAL | 직접 import, dynamic import |
| 3 | **서버 성능** | HIGH | `React.cache()`, LRU 캐시 |
| 4 | **클라이언트 페칭** | MEDIUM-HIGH | SWR 중복 제거 |
| 5 | **리렌더 최적화** | MEDIUM | `useMemo`, `useCallback` |
| 6 | **렌더링 성능** | MEDIUM | `content-visibility` |
| 7 | **JS 성능** | LOW-MEDIUM | Set/Map O(1) 조회 |
| 8 | **고급 패턴** | LOW | 이벤트 핸들러 refs |

### CRITICAL 규칙 예시
```typescript
// ❌ 워터폴 (순차 실행)
const user = await getUser();
const posts = await getPosts();

// ✅ 병렬 실행
const [user, posts] = await Promise.all([
  getUser(),
  getPosts()
]);
```

---

## 3.2 web-design-guidelines

### 사용 상황
| 작업 | 트리거 |
|------|--------|
| **UI 코드 리뷰** | "UI 검토해줘", "review my UI" |
| **접근성 검사** | "접근성 확인해줘", "check accessibility" |
| **디자인 감사** | "디자인 감사해줘", "audit design" |
| **UX 검토** | "UX 검토해줘", "review UX" |

### 워크플로우
```bash
1. WebFetch로 최신 가이드라인 가져오기
2. 지정된 파일 읽기
3. 모든 규칙 적용
4. file:line 형식으로 결과 출력
```

---

## 3.3 vercel-deploy

### 사용 상황
| 작업 | 트리거 |
|------|--------|
| **앱 배포** | "배포해줘", "Deploy my app" |
| **프리뷰 배포** | "프리뷰 URL 줘", "Create a preview" |
| **프로덕션 배포** | "라이브로 푸시해줘", "Push this live" |

### 핵심 특징
- **인증 불필요** - 바로 배포 가능
- **프레임워크 자동 감지** - Next.js, Vite, Remix 등
- **두 가지 URL 반환**:
  - Preview URL: 라이브 사이트
  - Claim URL: Vercel 계정으로 이전

### 사용법
```bash
# 현재 디렉토리 배포
bash /mnt/skills/user/vercel-deploy/scripts/deploy.sh

# 특정 프로젝트 배포
bash /mnt/skills/user/vercel-deploy/scripts/deploy.sh /path/to/project
```

---

## 3.4 js-refactor-cleanup-skill

### 사용 상황
| 작업 | 트리거 |
|------|--------|
| **코드 정리** | "코드 정리해줘", "clean up" |
| **이름 변경** | "변수명 개선해줘", "rename" |
| **리팩토링** | "리팩토링해줘", "refactor" |
| **async/await 변환** | "콜백을 async로 변환해줘" |

### 지원 패턴
| 패턴 | 예시 파일 |
|------|----------|
| 기본 이름 변경 & 헬퍼 추출 | `simple-refactor.js` |
| 콜백 → async/await | `async-refactor.js` |
| 모듈 export 정리 | `module-refactor.js` |

### 규칙
- 동작 변경 없이 구조만 개선
- 공개 API 변경 시 확인 필수
- 최소한의 안전한 변경만 수행

---

## 3.5 unused-code-refactor-suggester

### 사용 상황
| 작업 | 트리거 |
|------|--------|
| **미사용 코드 탐지** | "dead code 찾아줘", "find unused" |
| **리팩토링 제안** | "리팩토링 리포트 생성해줘" |
| **코드 정리** | "정리할 코드 식별해줘" |

### 지원 언어
`.py`, `.js`, `.ts`, `.jsx`, `.tsx`, `.java`, `.go`, `.rb`

### 출력 형식 (refactoring_report.md)
```markdown
- File: src/utils/helpers.py:42 — function compute_format
  - Recommendation: Delete
  - Reason: No references in this file; appears to be dead helper logic.
  - Risk: May be used by other modules via dynamic import.
```

### 추천 규칙
- **Delete**: 참조 없음 + 내보내기 없음 + 엔트리포인트 아님
- **Keep**: 내보내기됨 또는 공개 어노테이션 또는 불확실

---

# 4. 스킬 사용 시나리오

## 시나리오 1: 새 React 기능 구현

```
1. vercel-react-best-practices 참조 (성능 패턴)
2. test-driven-development 적용 (RED → GREEN → REFACTOR)
3. verification-before-completion (테스트 통과 확인)
4. vercel-deploy (프리뷰 배포)
```

## 시나리오 2: 버그 수정

```
1. systematic-debugging (4단계 근본 원인 분석)
2. test-driven-development (실패 테스트 작성)
3. defense-in-depth (다층 검증 추가)
4. verification-before-completion (수정 확인)
```

## 시나리오 3: 코드 정리/리팩토링

```
1. unused-code-refactor-suggester (미사용 코드 탐지)
2. js-refactor-cleanup-skill (JS/TS 리팩토링)
3. test-driven-development (동작 보장)
4. verification-before-completion (테스트 통과 확인)
```

## 시나리오 4: 문서 작업

```
- Word 문서: docx 스킬
- PDF 처리: pdf 스킬
- Excel 분석: xlsx 스킬
```

## 시나리오 5: 대규모 구현

```
1. 계획 수립 (superpowers:write-plan)
2. subagent-driven-development (태스크별 서브에이전트)
3. 2단계 리뷰 (스펙 + 품질)
4. verification-before-completion (최종 검증)
```

---

# 5. 스킬 관리

## 설치 위치
| 위치 | 범위 |
|------|------|
| `~/.claude/skills/` | 개인 (모든 프로젝트) |
| `.claude/skills/` | 프로젝트별 |

## 설치된 스킬 확인
```bash
ls ~/.claude/skills/
```

## 새 스킬 추가 방법
```bash
# 공식 스킬
npx add-skill anthropics/skills --skill <name>

# GitHub 스킬
git clone <url> ~/.claude/skills/<name>

# SkillsCokac
npx skillscokac -i <name>
```

---

## Sources

- [anthropics/skills](https://github.com/anthropics/skills)
- [obra/superpowers](https://github.com/obra/superpowers)
- [SkillsCokac](https://skills.cokac.com/)

---

<!--
작성일: 2026-01-19
작성자: Claude Opus 4.5
저장소: claude-templates
버전: 2.0 (설치된 스킬 기준 상세 가이드)
-->
