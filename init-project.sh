#!/bin/bash
#
# init-project.sh - 새 프로젝트 Claude 협업 환경 자동 설정
#
# 사용법:
#   # 현재 폴더에 설정
#   curl -sL https://raw.githubusercontent.com/HMWKR/CLAUDE-TEMPLATES/main/init-project.sh | bash
#
#   # 또는 특정 경로에 설정
#   ./init-project.sh /path/to/your/project
#
# 자동으로 수행되는 작업:
#   1. CLAUDE.md 템플릿 다운로드
#   2. commitlint.config.cjs 다운로드
#   3. .gitmessage 다운로드
#   4. npm 패키지 설치 (husky, commitlint)
#   5. Husky 초기화 및 commit-msg 훅 설정
#   6. Git 커밋 템플릿 등록
#

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 설정
PROJECT_PATH="${1:-.}"
TEMPLATES_URL="https://raw.githubusercontent.com/HMWKR/CLAUDE-TEMPLATES/main"

# 헬퍼 함수
print_step() {
    echo -e "${BLUE}[$1]${NC} $2"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

# 시작
echo ""
echo "=================================================="
echo "  Claude 협업 환경 자동 설정"
echo "  CLAUDE-TEMPLATES by HMWKR"
echo "=================================================="
echo ""
echo "  대상 경로: $PROJECT_PATH"
echo ""

# 경로 확인
if [[ ! -d "$PROJECT_PATH" ]]; then
    print_error "경로가 존재하지 않습니다: $PROJECT_PATH"
fi

cd "$PROJECT_PATH"

# Git 저장소 확인
if [[ ! -d ".git" ]]; then
    print_warning "Git 저장소가 아닙니다. git init을 먼저 실행하세요."
    echo ""
    read -p "git init을 실행할까요? (y/n): " answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        git init
        print_success "Git 저장소 초기화 완료"
    else
        print_error "Git 저장소가 필요합니다."
    fi
fi

# Step 1: 템플릿 다운로드
print_step "1/10" "템플릿 다운로드 중..."

if [[ -f "CLAUDE.md" ]]; then
    print_warning "CLAUDE.md가 이미 존재합니다. 건너뜁니다."
else
    curl -sL "$TEMPLATES_URL/CLAUDE_TEMPLATE.md" -o "CLAUDE.md"
    print_success "CLAUDE.md 다운로드 완료"
fi

if [[ -f "commitlint.config.cjs" ]]; then
    print_warning "commitlint.config.cjs가 이미 존재합니다. 건너뜁니다."
else
    curl -sL "$TEMPLATES_URL/commitlint.config.cjs" -o "commitlint.config.cjs"
    print_success "commitlint.config.cjs 다운로드 완료"
fi

if [[ -f ".gitmessage" ]]; then
    print_warning ".gitmessage가 이미 존재합니다. 건너뜁니다."
else
    curl -sL "$TEMPLATES_URL/.gitmessage" -o ".gitmessage"
    print_success ".gitmessage 다운로드 완료"
fi

# Step 2: package.json 확인
print_step "2/10" "package.json 확인 중..."

if [[ ! -f "package.json" ]]; then
    echo '{"name": "my-project", "version": "1.0.0", "type": "module"}' > package.json
    print_success "package.json 생성 완료"
else
    print_success "package.json 존재 확인"
fi

# Step 3: npm 패키지 설치
print_step "3/10" "npm 패키지 설치 중..."

npm install -D husky @commitlint/cli @commitlint/config-conventional --silent
print_success "husky, commitlint 설치 완료"

# Step 4: Husky 초기화
print_step "4/10" "Husky 설정 중..."

npx husky init 2>/dev/null || true

# commit-msg 훅 생성
mkdir -p .husky
echo 'npx --no -- commitlint --edit "$1"' > .husky/commit-msg
chmod +x .husky/commit-msg 2>/dev/null || true
print_success "Husky commit-msg 훅 설정 완료"

# Step 5: Git 템플릿 등록
print_step "5/10" "Git 템플릿 등록 중..."

git config commit.template .gitmessage
print_success "Git 커밋 템플릿 등록 완료"

# Step 6: 프롬프트 추출 스크립트 생성
print_step "6/10" "프롬프트 추출 스크립트 생성 중..."

mkdir -p scripts
if [[ -f "scripts/extract-local-prompts.js" ]]; then
    print_warning "extract-local-prompts.js가 이미 존재합니다. 건너뜁니다."
else
    curl -sL "$TEMPLATES_URL/scripts/extract-local-prompts.js" -o "scripts/extract-local-prompts.js"
    print_success "extract-local-prompts.js 다운로드 완료"
fi

# Step 7: GitHub Actions 워크플로우 생성
print_step "7/10" "GitHub Actions 워크플로우 생성 중..."

mkdir -p .github/workflows
if [[ -f ".github/workflows/sync-prompts.yml" ]]; then
    print_warning "sync-prompts.yml이 이미 존재합니다. 건너뜁니다."
else
    cat > .github/workflows/sync-prompts.yml << 'EOF'
name: Sync Prompts

on:
  push:
    branches: [main, master]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  extract:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Validate journal files (v3.1)
        if: hashFiles('.prompts/*.md') != ''
        run: |
          if [ -f "scripts/validate-journals.js" ]; then
            node scripts/validate-journals.js
          fi
        continue-on-error: true

      - name: Extract prompts from commits
        run: |
          node scripts/extract-local-prompts.js

      - name: Create prompts directory
        run: mkdir -p prompts-data

      - name: Move prompts.json
        run: |
          if [ -f prompts.json ]; then
            mv prompts.json prompts-data/
          fi

      - name: Deploy to gh-pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./prompts-data
          publish_branch: gh-pages
          keep_files: false
EOF
    print_success "GitHub Actions 워크플로우 생성 완료"
fi

# Step 8: 프롬프트 저널 설정
print_step "8/10" "프롬프트 저널 설정 중..."

mkdir -p .prompts
if [[ -f "PROMPT_JOURNAL_TEMPLATE.md" ]]; then
    print_warning "PROMPT_JOURNAL_TEMPLATE.md가 이미 존재합니다. 건너뜁니다."
else
    curl -sL "$TEMPLATES_URL/PROMPT_JOURNAL_TEMPLATE.md" -o "PROMPT_JOURNAL_TEMPLATE.md"
    print_success "PROMPT_JOURNAL_TEMPLATE.md 다운로드 완료"
fi
print_success ".prompts/ 폴더 생성 완료"

# Step 9: 저널 자동 생성 스크립트 (v3.1)
print_step "9/10" "저널 자동 생성 스크립트 설정 중..."

if [[ -f "scripts/create-journal-from-commit.js" ]]; then
    print_warning "create-journal-from-commit.js가 이미 존재합니다. 건너뜁니다."
else
    curl -sL "$TEMPLATES_URL/scripts/create-journal-from-commit.js" -o "scripts/create-journal-from-commit.js"
    print_success "create-journal-from-commit.js 다운로드 완료"
fi

# post-commit 훅 설정 (저널 자동 생성)
if [[ -f ".husky/post-commit" ]]; then
    print_warning "post-commit 훅이 이미 존재합니다. 건너뜁니다."
else
    cat > .husky/post-commit << 'POSTCOMMIT'
#!/bin/sh
# post-commit hook: 16섹션 커밋 후 프롬프트 저널 자동 생성

if [ -f "scripts/create-journal-from-commit.js" ]; then
  node scripts/create-journal-from-commit.js
fi
POSTCOMMIT
    chmod +x .husky/post-commit 2>/dev/null || true
    print_success "post-commit 훅 설정 완료 (저널 자동 생성)"
fi

# Step 10: 저널 검증 스크립트 (v3.1)
print_step "10/10" "저널 검증 스크립트 설정 중..."

if [[ -f "scripts/validate-journals.js" ]]; then
    print_warning "validate-journals.js가 이미 존재합니다. 건너뜁니다."
else
    curl -sL "$TEMPLATES_URL/scripts/validate-journals.js" -o "scripts/validate-journals.js"
    print_success "validate-journals.js 다운로드 완료"
fi

# 완료 메시지
echo ""
echo "=================================================="
echo -e "  ${GREEN}✓ Claude 협업 환경 설정 완료!${NC}"
echo "=================================================="
echo ""
echo "  생성된 파일:"
echo "  • CLAUDE.md                    - Claude 작업 지침"
echo "  • commitlint.config.cjs        - 16개 섹션 검증 규칙"
echo "  • .gitmessage                  - 커밋 메시지 템플릿"
echo "  • .husky/commit-msg            - 커밋 검증 훅"
echo "  • .husky/post-commit           - 저널 자동 생성 훅 (v3.1)"
echo "  • scripts/extract-local-prompts.js - 프롬프트 추출 스크립트"
echo "  • scripts/create-journal-from-commit.js - 저널 자동 생성 (v3.1)"
echo "  • scripts/validate-journals.js - 저널 검증 (v3.1)"
echo "  • .github/workflows/sync-prompts.yml - 자동 동기화 워크플로우"
echo "  • .prompts/                    - 프롬프트 저널 폴더"
echo "  • PROMPT_JOURNAL_TEMPLATE.md   - 프롬프트 저널 템플릿"
echo ""
echo -e "  ${YELLOW}========================================${NC}"
echo -e "  ${YELLOW}⚠️  중요: 다음 단계 - 섹션 1-8 작성${NC}"
echo -e "  ${YELLOW}========================================${NC}"
echo ""
echo "  CLAUDE.md 섹션 1-8을 상세히 작성해야 Claude 협업 품질이 보장됩니다!"
echo ""
echo -e "  ${GREEN}📋 필독 가이드:${NC}"
echo "     https://github.com/HMWKR/CLAUDE-TEMPLATES/blob/main/SECTION_1_TO_8_WRITING_GUIDE.md"
echo ""
echo -e "  ${GREEN}🎯 좋은 예시 (calclab - 섹션 1-8: ~660줄):${NC}"
echo "     https://github.com/HMWKR/calclab/blob/main/CLAUDE.md"
echo ""
echo "  섹션 1-8 최소 요구사항:"
echo "  • 섹션 1: 프로젝트 한 문장 정의 + 핵심 기능 3개 + 기술 스택(버전)"
echo "  • 섹션 2: 복사-붙여넣기 가능한 명령어 + 명령어 테이블 4개+"
echo "  • 섹션 3: 폴더 구조 트리(역할 주석) + 데이터 흐름 ASCII"
echo "  • 섹션 4: 2개+ 모듈 상세 설명 + 파일 위치 + 주요 함수 목록"
echo "  • 섹션 6-8: 테스트/환경/이슈 현황"
echo ""
echo -e "  ${RED}⚠️  섹션 1-8이 부실하면 Claude가 추정에 의존하여 오류 발생!${NC}"
echo ""
echo "  다음 단계:"
echo "  1. 위 가이드를 읽고 CLAUDE.md 섹션 1-8 상세 작성"
echo "  2. git commit 실행 → 16개 섹션 템플릿 자동 표시"
echo "  3. git push → 프롬프트 자동 수집 및 대시보드 반영"
echo ""
echo "  GitHub Pages 설정:"
echo "  Repository Settings → Pages → Source: Deploy from a branch"
echo "  Branch: gh-pages / (root)"
echo ""
echo "  대시보드: https://hmwkr.github.io/prompt-dashboard/"
echo ""
