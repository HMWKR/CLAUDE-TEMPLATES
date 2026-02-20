# PROJECT_SETUP_CHECKLIST.md

**새 프로젝트에 Claude CE v2.0 협업 환경 설정하기**

---

## 권장: 원클릭 설정

```bash
curl -sL https://raw.githubusercontent.com/HMWKR/CLAUDE-TEMPLATES/main/init-project.sh | bash
```

**자동 생성 파일:**

| 파일 | 용도 |
|------|------|
| `CLAUDE.md` | 프로젝트 지침 (섹션 1-8 TODO) |
| `commitlint.config.cjs` | 4섹션 커밋 검증 |
| `.gitmessage` | 커밋 템플릿 (What/Why/Impact) |
| `.husky/commit-msg` | 커밋 검증 훅 |
| `.husky/post-commit` | 사고 여정 안내 |
| `scripts/extract-local-prompts.js` | 프롬프트 추출 v4.0 |
| `scripts/create-thinking-log.js` | CE 사고 여정 생성 |
| `scripts/validate-journals.js` | 저널 + 사고여정 검증 v2.0 |
| `.thoughts/` | CE 사고 여정 저장 |

원클릭 설정 후 **CLAUDE.md 섹션 1-8만 작성**하면 됩니다.

---

## 수동 설정 (원클릭 안 될 때)

### 1단계: 파일 복사

```bash
# Windows
copy C:\Users\jusan\Desktop\claude-templates\CLAUDE_TEMPLATE.md .\CLAUDE.md
copy C:\Users\jusan\Desktop\claude-templates\commitlint.config.cjs .
copy C:\Users\jusan\Desktop\claude-templates\.gitmessage .

# macOS/Linux
cp ~/Desktop/claude-templates/CLAUDE_TEMPLATE.md ./CLAUDE.md
cp ~/Desktop/claude-templates/commitlint.config.cjs .
cp ~/Desktop/claude-templates/.gitmessage .
```

### 2단계: 패키지 설치

```bash
npm install -D husky @commitlint/cli @commitlint/config-conventional
npx husky init
echo 'npx --no -- commitlint --edit "$1"' > .husky/commit-msg
```

### 3단계: CE 환경 설정

```bash
mkdir -p .thoughts scripts
# scripts/ 에 create-thinking-log.js, extract-local-prompts.js 복사
git config commit.template .gitmessage
```

### 4단계: CLAUDE.md 작성

섹션 1-8을 프로젝트에 맞게 작성:

- [ ] 섹션 1: 프로젝트 개요 (한 문장 정의 + 핵심 기능 + 기술 스택)
- [ ] 섹션 2: Quick Start (설치/실행 명령어 + 환경 변수)
- [ ] 섹션 3: 아키텍처 (폴더 구조 + 데이터 흐름)
- [ ] 섹션 4: 핵심 모듈 (파일 경로 + 역할)
- [ ] 섹션 5: 타입 시스템 (주요 인터페이스)
- [ ] 섹션 6: 테스트 (실행 방법 + 현황)
- [ ] 섹션 7: 환경 설정 (의존성 + 설정 파일)
- [ ] 섹션 8: 알려진 이슈 & TODO

> 공통 규칙(섹션 9+)은 글로벌 `~/.claude/CLAUDE.md`에서 자동 로드됩니다.

---

## 검증

```bash
# 커밋 테스트 (4섹션 누락 시 실패)
git commit -m "test: 검증 테스트"
# → 필수 섹션 누락 오류 표시되면 정상

# 저널 검증
node scripts/validate-journals.js
```

---

## CE v2.0 구조

```
~/.claude/CLAUDE.md              ← 공통 규칙 (72줄)
프로젝트/CLAUDE.md               ← 프로젝트 고유 (섹션 1-8)
프로젝트/.thoughts/              ← CE 사고 여정
프로젝트/commitlint.config.cjs   ← 4섹션 검증
```
