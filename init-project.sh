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
print_step "1/5" "템플릿 다운로드 중..."

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
print_step "2/5" "package.json 확인 중..."

if [[ ! -f "package.json" ]]; then
    echo '{"name": "my-project", "version": "1.0.0", "type": "module"}' > package.json
    print_success "package.json 생성 완료"
else
    print_success "package.json 존재 확인"
fi

# Step 3: npm 패키지 설치
print_step "3/5" "npm 패키지 설치 중..."

npm install -D husky @commitlint/cli @commitlint/config-conventional --silent
print_success "husky, commitlint 설치 완료"

# Step 4: Husky 초기화
print_step "4/5" "Husky 설정 중..."

npx husky init 2>/dev/null || true

# commit-msg 훅 생성
mkdir -p .husky
echo 'npx --no -- commitlint --edit "$1"' > .husky/commit-msg
chmod +x .husky/commit-msg 2>/dev/null || true
print_success "Husky commit-msg 훅 설정 완료"

# Step 5: Git 템플릿 등록
print_step "5/5" "Git 템플릿 등록 중..."

git config commit.template .gitmessage
print_success "Git 커밋 템플릿 등록 완료"

# 완료 메시지
echo ""
echo "=================================================="
echo -e "  ${GREEN}✓ Claude 협업 환경 설정 완료!${NC}"
echo "=================================================="
echo ""
echo "  생성된 파일:"
echo "  • CLAUDE.md          - Claude 작업 지침"
echo "  • commitlint.config.cjs - 16개 섹션 검증 규칙"
echo "  • .gitmessage        - 커밋 메시지 템플릿"
echo "  • .husky/commit-msg  - 커밋 검증 훅"
echo ""
echo "  다음 단계:"
echo "  1. CLAUDE.md의 [TODO] 부분을 프로젝트에 맞게 수정"
echo "  2. git commit 실행 → 16개 섹션 템플릿 자동 표시"
echo ""
echo "  prompt-library 연동 (선택):"
echo "  cd /path/to/prompt-library"
echo "  ./scripts/setup-project.sh <project-name>"
echo ""
echo "  대시보드: https://hmwkr.github.io/prompt-dashboard/"
echo ""
