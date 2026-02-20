# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 1. 프로젝트 개요

[TODO: 프로젝트 설명을 작성하세요]

**[프로젝트명]**은 [핵심 기능/목적]을 제공하는 [기술 스택] 애플리케이션입니다.

### 핵심 기능

1. **[기능 1]** - [설명]
2. **[기능 2]** - [설명]
3. **[기능 3]** - [설명]

### 기술 스택

- [프레임워크] ([버전])
- [언어] ([버전])
- [DB] ([버전])

---

## 2. Quick Start

### 설치 및 실행

```bash
# [TODO: 설치 명령어]
npm install
npm run dev
```

### 주요 명령어

| 명령어 | 설명 |
|--------|------|
| `npm run dev` | 개발 서버 실행 |
| `npm run build` | 프로덕션 빌드 |
| `npm test` | 테스트 실행 |

### 환경 변수

| 변수 | 필수 | 설명 |
|------|:----:|------|
| `[TODO]` | O | [설명] |

---

## 3. 아키텍처

### 폴더 구조

```
[TODO: 프로젝트 구조]
src/
├── components/
├── pages/
├── lib/
└── types/
```

### 데이터 흐름

```
[TODO: 데이터 흐름 다이어그램]
사용자 → API → DB → 응답
```

---

## 4. 핵심 모듈

### [모듈 1]

**위치**: `src/[경로]`
**역할**: [설명]

### [모듈 2]

**위치**: `src/[경로]`
**역할**: [설명]

---

## 5. 타입 시스템

[TODO: 핵심 타입/인터페이스 정의]

---

## 6. 테스트

```bash
npm test              # 전체 테스트
npm run test:watch    # 워치 모드
```

---

## 7. 환경 설정

[TODO: 개발 환경, 의존성, 설정 파일 목록]

---

## 8. 알려진 이슈 & TODO

- [ ] [TODO: 현재 이슈]
- [ ] [TODO: 향후 계획]

---

# 작업 지침

> 공통 규칙(언어, 환각 방지, 코드 작성, 보안 등)은 **글로벌 `~/.claude/CLAUDE.md`** 참조.
> 아래는 이 프로젝트에만 해당하는 보충 지침.

## 커밋 메시지 (4개 필수 섹션)

| # | 섹션 | 용도 |
|:-:|------|------|
| 1 | `[type]:` 헤더 | Conventional Commits |
| 2 | `## What` | 변경된 파일/기능 |
| 3 | `## Why` | 변경 이유 |
| 4 | `## Impact` | 영향 범위, 위험도, Breaking |
| - | `Co-Authored-By:` | AI 협업 표시 |

> Husky + Commitlint가 4개 섹션을 자동 검증합니다.

## CE 사고 여정 (.thoughts/)

커밋 후 `.thoughts/YYYY-MM-DD-{subject}.md`에 CE 관점 사고 과정을 기록합니다.

---

# End of CLAUDE.md
