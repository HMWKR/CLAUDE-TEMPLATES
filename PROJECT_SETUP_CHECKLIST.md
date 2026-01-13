# PROJECT_SETUP_CHECKLIST.md

**새 프로젝트에 Claude 협업 환경 설정하기**

이 체크리스트를 따라 새 프로젝트에 Claude Code 협업 환경을 빠르게 구축하세요.

---

## 권장: 원클릭 설정

아래 명령어 하나로 **7단계 설정을 자동 완료**합니다:

```bash
curl -sL https://raw.githubusercontent.com/HMWKR/CLAUDE-TEMPLATES/main/init-project.sh | bash
```

**자동으로 생성되는 파일:**
- `CLAUDE.md` - Claude 작업 지침
- `commitlint.config.cjs` - 16개 섹션 검증 규칙
- `.gitmessage` - 커밋 메시지 템플릿
- `.husky/commit-msg` - 커밋 검증 훅
- `scripts/extract-local-prompts.js` - 프롬프트 추출 스크립트
- `.github/workflows/sync-prompts.yml` - 자동 동기화 워크플로우

원클릭 설정 후 **CLAUDE.md 섹션 1-8만 작성**하면 됩니다.

### init-project.sh 7단계 상세

| 단계 | 동작 | 생성 파일 |
|:----:|------|----------|
| 1/7 | CLAUDE_TEMPLATE.md 다운로드 → CLAUDE.md로 저장 | `CLAUDE.md` |
| 2/7 | package.json 존재 확인, 없으면 생성 | `package.json` |
| 3/7 | husky, commitlint 패키지 설치 | `node_modules/` |
| 4/7 | Husky 초기화 + commit-msg 훅 생성 | `.husky/commit-msg` |
| 5/7 | commitlint.config.cjs 다운로드 | `commitlint.config.cjs` |
| 6/7 | .gitmessage 다운로드 + Git 템플릿 등록 | `.gitmessage` |
| 7/7 | 프롬프트 추출 스크립트 및 워크플로우 생성 | `scripts/`, `.github/workflows/` |

수동 설정이 필요하면 아래 단계를 따르세요.

---

## 1단계: 기본 설정 (필수)

### Git 저장소

- [ ] Git 저장소 초기화
  ```bash
  git init
  ```
- [ ] `.gitignore` 생성 (프로젝트 유형에 맞게)
- [ ] 첫 커밋 생성
  ```bash
  git add .
  git commit -m "chore: 프로젝트 초기화"
  ```

### CLAUDE.md 생성

- [ ] `CLAUDE_TEMPLATE.md`를 프로젝트 루트에 `CLAUDE.md`로 복사
  ```bash
  # Windows
  copy C:\Users\jusan\Desktop\CLAUDE_TEMPLATE.md .\CLAUDE.md

  # macOS/Linux
  cp ~/Desktop/CLAUDE_TEMPLATE.md ./CLAUDE.md
  ```
- [ ] 섹션 1-8 작성 (프로젝트별 정보)
  - [ ] 섹션 1: 프로젝트 개요
  - [ ] 섹션 2: Quick Start
  - [ ] 섹션 3: 아키텍처
  - [ ] 섹션 4: 핵심 모듈
  - [ ] 섹션 5: 타입 시스템 (선택)
  - [ ] 섹션 6: 테스트
  - [ ] 섹션 7: 환경 설정
  - [ ] 섹션 8: 알려진 이슈

---

## 2단계: 커밋 메시지 검증 시스템 (권장)

### 패키지 설치

- [ ] 의존성 설치
  ```bash
  npm install -D husky @commitlint/cli @commitlint/config-conventional
  ```

### Husky 초기화

- [ ] Husky 설정
  ```bash
  npx husky init
  ```

### 설정 파일 생성

- [ ] `.husky/commit-msg` 생성
  ```bash
  npx --no -- commitlint --edit "$1"
  ```

- [ ] `commitlint.config.cjs` 생성
  - 바탕화면의 `커밋메시지-16섹션-설정가이드.md` 참고
  - 또는 기존 프로젝트에서 복사

- [ ] `.gitmessage` 생성 (커밋 템플릿)
  - 바탕화면의 `커밋메시지-16섹션-설정가이드.md` 참고

### Git 설정

- [ ] 커밋 템플릿 등록
  ```bash
  git config commit.template .gitmessage
  ```

### 검증

- [ ] 테스트 커밋으로 검증
  ```bash
  # 실패해야 정상
  git commit -m "test"
  # → 필수 섹션 누락 오류 확인
  ```

---

## 3단계: GitHub 저장소 설정 (선택)

### 원격 저장소 연결

- [ ] GitHub 저장소 생성
- [ ] 원격 저장소 연결
  ```bash
  git remote add origin https://github.com/[username]/[repo].git
  git push -u origin main
  ```

### 저장소 설정 (gh CLI)

- [ ] Squash merge 설정
  ```bash
  gh repo edit --enable-squash-merge --delete-branch-on-merge
  ```

### GitHub Actions (선택)

- [ ] `.github/workflows/commit-lint.yml` 생성
  - 바탕화면의 `커밋메시지-16섹션-설정가이드.md` 참고

### GitHub Pages 설정 (프롬프트 수집용)

프롬프트 자동 수집/대시보드 연동을 위해 Pages를 설정합니다:

- [ ] Repository → Settings → Pages 이동
- [ ] Source: **Deploy from a branch** 선택
- [ ] Branch: **gh-pages** / (root) 선택
- [ ] Save 클릭

> `sync-prompts.yml` 워크플로우가 첫 실행되면 gh-pages 브랜치가 자동 생성됩니다.

### prompt-library 등록 (선택)

프롬프트 대시보드에 프로젝트를 표시하려면:

- [ ] [prompt-library](https://github.com/HMWKR/prompt-library) 저장소 Fork
- [ ] `data/projects.json`에 프로젝트 정보 추가:
  ```json
  {
    "name": "프로젝트명",
    "repo": "owner/repo",
    "owner": "owner",
    "promptsUrl": "https://owner.github.io/repo/prompts.json"
  }
  ```
- [ ] PR 생성: "Add [프로젝트명] to projects"
- [ ] 또는: prompt-library 이슈에 등록 요청

---

## 4단계: 개발 환경 확인

### Claude Code CLI

- [ ] Claude Code 설치 확인
  ```bash
  claude --version
  ```
- [ ] 프로젝트 폴더에서 Claude Code 실행
  ```bash
  claude
  ```
- [ ] CLAUDE.md 인식 확인
  - Claude에게 "이 프로젝트에 대해 알려줘" 질문

### 작업 시작

- [ ] 첫 작업 요청
  ```
  ultrathink 모드로 현재 프로젝트 구조를 분석해줘.
  ```

---

## 빠른 설정 스크립트

### Windows (PowerShell)

```powershell
# 1. CLAUDE.md 복사
Copy-Item "$env:USERPROFILE\Desktop\CLAUDE_TEMPLATE.md" -Destination ".\CLAUDE.md"

# 2. 커밋 메시지 시스템 설치
npm install -D husky @commitlint/cli @commitlint/config-conventional
npx husky init

# 3. Git 템플릿 등록
git config commit.template .gitmessage

Write-Host "설정 완료! CLAUDE.md 섹션 1-8을 작성하세요."
```

### macOS/Linux (Bash)

```bash
#!/bin/bash

# 1. CLAUDE.md 복사
cp ~/Desktop/CLAUDE_TEMPLATE.md ./CLAUDE.md

# 2. 커밋 메시지 시스템 설치
npm install -D husky @commitlint/cli @commitlint/config-conventional
npx husky init

# 3. Git 템플릿 등록
git config commit.template .gitmessage

echo "설정 완료! CLAUDE.md 섹션 1-8을 작성하세요."
```

---

## 참고 파일 위치 (CLAUDE-TEMPLATES 저장소)

| 파일 | 용도 |
|------|------|
| `init-project.sh` | 원클릭 자동 설정 스크립트 |
| `CLAUDE_TEMPLATE.md` | CLAUDE.md 전체 템플릿 |
| `CLAUDE_UNIVERSAL_RULES.md` | 공통 규칙 (섹션 9-19) |
| `CONVERSATION_PROMPTS.md` | Claude 대화 패턴 |
| `커밋메시지-16섹션-설정가이드.md` | 커밋 검증 시스템 상세 가이드 |
| `scripts/extract-local-prompts.js` | 프롬프트 추출 스크립트 |
| `.github/workflows/sync-prompts.yml` | 프롬프트 자동 동기화 워크플로우 |
| `PROJECT_SETUP_CHECKLIST.md` | 이 체크리스트 |

---

## 문제 해결

### Husky 관련

**문제**: `.git can't be found`
**해결**: Git 저장소가 있는 폴더에서 실행하세요.

**문제**: `prepare` 스크립트 오류
**해결**: `package.json`에 `"prepare": "husky"` 스크립트 확인

### Commitlint 관련

**문제**: ES Module 오류
**해결**: `commitlint.config.cjs` (`.cjs` 확장자) 사용

**문제**: 커밋 메시지 검증 통과 안 됨
**해결**: 16개 필수 섹션 모두 포함 확인

### Claude Code 관련

**문제**: CLAUDE.md 인식 안 됨
**해결**: 프로젝트 루트에 `CLAUDE.md` 위치 확인

### GitHub Actions 관련

**문제**: Sync Prompts 워크플로우 실패
**확인 방법**:
1. Actions 탭 → 실패한 워크플로우 클릭
2. 로그에서 `extract-local-prompts.js` 오류 메시지 확인

**일반적 원인**:
- 16개 섹션 미충족 커밋 (최소 10개 섹션 필요)
- `scripts/` 폴더 누락 → `init-project.sh` 재실행
- Node.js 버전 불일치

**문제**: Pages 배포 지연 (1-5분 대기)
**해결**: 커밋 후 Actions 탭에서 `pages build and deployment` 상태 확인

**문제**: prompts.json 비어있음 (`"prompts": []`)
**원인**: 16개 섹션 커밋이 없음
**해결**: `.gitmessage` 템플릿 사용하여 커밋 생성

**문제**: gh-pages 브랜치 없음
**해결**:
1. 16개 섹션 커밋 최소 1개 생성
2. `git push` 실행
3. `Sync Prompts` 워크플로우가 자동으로 gh-pages 생성

---

## 완료 확인

모든 단계를 마쳤으면:

1. **CLAUDE.md 작성 완료** - 섹션 1-8 프로젝트별 정보 입력
2. **커밋 검증 작동** - 템플릿 없이 커밋 시 오류 발생
3. **Claude 인식 확인** - "이 프로젝트 설명해줘" 질문에 CLAUDE.md 기반 응답
4. **프롬프트 수집 확인** (선택)
   - GitHub Actions 탭에서 `Sync Prompts` 워크플로우 성공 확인
   - `https://[username].github.io/[repo]/prompts.json` 접속 가능 확인

---

*체크리스트 작성일: 2026-01-12*
*업데이트: 2026-01-14 (분산 Push 아키텍처 반영)*
