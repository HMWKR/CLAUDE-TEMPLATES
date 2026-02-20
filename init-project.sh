#!/bin/bash
#
# init-project.sh - 새 프로젝트 Claude 협업 환경 자동 설정 (CE v2.0)
#
# 사용법:
#   curl -sL https://raw.githubusercontent.com/HMWKR/CLAUDE-TEMPLATES/main/init-project.sh | bash
#
# 자동 수행:
#   1. CLAUDE.md 템플릿 다운로드
#   2. commitlint.config.cjs 다운로드 (4섹션 검증)
#   3. .gitmessage 다운로드
#   4. npm 패키지 설치 (husky, commitlint)
#   5. Husky 초기화 및 commit-msg 훅 설정
#   6. .thoughts/ 폴더 생성
#   7. create-thinking-log.js 다운로드
#   8. extract-local-prompts.js v4.0 다운로드
#   9. validate-journals.js v2.0 다운로드
#   10. Git 커밋 템플릿 등록

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_PATH="${1:-.}"
TEMPLATES_URL="https://raw.githubusercontent.com/HMWKR/CLAUDE-TEMPLATES/main"

print_step() { echo -e "${BLUE}[$1]${NC} $2"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

echo ""
echo "================================================"
echo "  Claude Code CE v2.0 프로젝트 설정"
echo "================================================"
echo ""

cd "$PROJECT_PATH"

# 1. CLAUDE.md 템플릿
print_step "1/10" "CLAUDE.md 템플릿 다운로드"
if [ -f "CLAUDE.md" ]; then
    print_warning "CLAUDE.md 이미 존재 — 건너뜀"
else
    curl -sL "$TEMPLATES_URL/CLAUDE_TEMPLATE.md" -o CLAUDE.md
    print_success "CLAUDE.md 생성됨 (섹션 1-8 TODO 작성 필요)"
fi

# 2. commitlint.config.cjs (4섹션 검증)
print_step "2/10" "commitlint.config.cjs 다운로드 (4섹션 검증)"
curl -sL "$TEMPLATES_URL/commitlint.config.cjs" -o commitlint.config.cjs
print_success "commitlint.config.cjs 설치됨"

# 3. .gitmessage
print_step "3/10" ".gitmessage 다운로드"
curl -sL "$TEMPLATES_URL/.gitmessage" -o .gitmessage
print_success ".gitmessage 설치됨"

# 4. npm 패키지 설치
print_step "4/10" "npm 패키지 설치"
if [ ! -f "package.json" ]; then
    npm init -y > /dev/null 2>&1
fi
npm install -D husky @commitlint/cli @commitlint/config-conventional > /dev/null 2>&1
print_success "husky + commitlint 설치됨"

# 5. Husky 초기화
print_step "5/10" "Husky 초기화"
npx husky init > /dev/null 2>&1 || true
echo 'npx --no -- commitlint --edit "$1"' > .husky/commit-msg
echo '#!/bin/sh
echo "커밋 완료. .thoughts/ 에 사고 여정을 기록하세요."' > .husky/post-commit
print_success "Git 훅 설정됨 (commit-msg + post-commit)"

# 6. .thoughts/ 폴더
print_step "6/10" ".thoughts/ 폴더 생성"
mkdir -p .thoughts
touch .thoughts/.gitkeep
print_success ".thoughts/ 생성됨 (CE 사고 여정 저장)"

# 7. create-thinking-log.js
print_step "7/10" "CE 사고 여정 스크립트 다운로드"
mkdir -p scripts
curl -sL "$TEMPLATES_URL/scripts/create-thinking-log.js" -o scripts/create-thinking-log.js
print_success "scripts/create-thinking-log.js 설치됨"

# 8. extract-local-prompts.js v4.0
print_step "8/10" "프롬프트 추출 스크립트 v4.0 다운로드"
curl -sL "$TEMPLATES_URL/scripts/extract-local-prompts.js" -o scripts/extract-local-prompts.js
print_success "scripts/extract-local-prompts.js v4.0 설치됨"

# 9. validate-journals.js v2.0
print_step "9/10" "저널 검증 스크립트 v2.0 다운로드"
curl -sL "$TEMPLATES_URL/scripts/validate-journals.js" -o scripts/validate-journals.js
print_success "scripts/validate-journals.js v2.0 설치됨"

# 10. Git 커밋 템플릿 등록
print_step "10/10" "Git 커밋 템플릿 등록"
git config commit.template .gitmessage
print_success "커밋 템플릿 등록됨"

echo ""
echo "================================================"
echo "  설정 완료!"
echo "================================================"
echo ""
echo "  다음 단계:"
echo "  1. CLAUDE.md 섹션 1-8을 프로젝트에 맞게 작성"
echo "  2. git commit 으로 4섹션 커밋 테스트"
echo "  3. 작업 후 .thoughts/에 CE 사고 여정 기록"
echo ""
