#!/usr/bin/env bash
# infra-audit.sh — Claude Code 인프라 자동화 구조 검사
# Phase 1 자동 검사 항목을 JSON 형식으로 출력
# 사용법: bash ~/.claude/skills/infra-audit/scripts/infra-audit.sh [--quick|--focus=AREA]

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
RESULTS=()
PASS=0
WARN=0
FAIL=0

# --- 유틸리티 함수 ---

add_result() {
  local area="$1" id="$2" name="$3" status="$4" detail="$5" harness="$6"
  RESULTS+=("{\"area\":\"$area\",\"id\":\"$id\",\"name\":\"$name\",\"status\":\"$status\",\"detail\":\"$detail\",\"harness\":\"$harness\"}")
  case "$status" in
    PASS) ((PASS++)) ;;
    WARN) ((WARN++)) ;;
    FAIL) ((FAIL++)) ;;
  esac
}

file_lines() {
  if [ -f "$1" ]; then
    wc -l < "$1" | tr -d ' '
  else
    echo "0"
  fi
}

# --- 검사 모드 파싱 ---

MODE="full"
FOCUS_AREA=""
for arg in "$@"; do
  case "$arg" in
    --quick) MODE="quick" ;;
    --focus=*) MODE="focus"; FOCUS_AREA="${arg#--focus=}" ;;
  esac
done

# --- 1. CLAUDE.md 검사 ---

check_claudemd() {
  # 1-1: 글로벌 CLAUDE.md 존재
  if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    add_result "CLAUDE.md" "1-1" "글로벌 CLAUDE.md 존재" "PASS" "파일 존재 확인" "CE"
  else
    add_result "CLAUDE.md" "1-1" "글로벌 CLAUDE.md 존재" "FAIL" "~/.claude/CLAUDE.md 없음" "CE"
  fi

  # 1-2: 줄 수 적정성
  if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    lines=$(file_lines "$CLAUDE_DIR/CLAUDE.md")
    if [ "$lines" -ge 50 ] && [ "$lines" -le 120 ]; then
      add_result "CLAUDE.md" "1-2" "줄 수 적정성" "PASS" "${lines}줄 (50-120 권장)" "CE"
    elif [ "$lines" -ge 30 ] && [ "$lines" -le 150 ]; then
      add_result "CLAUDE.md" "1-2" "줄 수 적정성" "WARN" "${lines}줄 (30-150 범위)" "CE"
    else
      add_result "CLAUDE.md" "1-2" "줄 수 적정성" "FAIL" "${lines}줄 (범위 초과)" "CE"
    fi
  fi

  # 1-3: 필수 섹션 존재
  if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    missing=""
    for keyword in "언어" "사고" "코드" "커밋"; do
      if ! grep -q "$keyword" "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
        missing="$missing $keyword"
      fi
    done
    if [ -z "$missing" ]; then
      add_result "CLAUDE.md" "1-3" "필수 섹션 존재" "PASS" "4개 필수 섹션 확인" "CE"
    else
      add_result "CLAUDE.md" "1-3" "필수 섹션 존재" "WARN" "누락:$missing" "CE"
    fi
  fi

  # 1-5: _core 참조 존재
  if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    if grep -q "_core" "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
      add_result "CLAUDE.md" "1-5" "_core 참조 존재" "PASS" "_core 참조 확인" "CE"
    else
      add_result "CLAUDE.md" "1-5" "_core 참조 존재" "WARN" "_core 참조 없음" "CE"
    fi
  fi

  # 1-8: CE 원칙 반영
  if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    ce_count=0
    for kw in "토큰" "신호" "CE" "컨텍스트" "고도"; do
      if grep -q "$kw" "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
        ((ce_count++))
      fi
    done
    if [ "$ce_count" -ge 3 ]; then
      add_result "CLAUDE.md" "1-8" "CE 원칙 반영" "PASS" "CE 키워드 ${ce_count}개 확인" "CE"
    elif [ "$ce_count" -ge 1 ]; then
      add_result "CLAUDE.md" "1-8" "CE 원칙 반영" "WARN" "CE 키워드 ${ce_count}개 (3개+ 권장)" "CE"
    else
      add_result "CLAUDE.md" "1-8" "CE 원칙 반영" "FAIL" "CE 키워드 없음" "CE"
    fi
  fi
}

# --- 2. Hooks 검사 ---

check_hooks() {
  local settings="$CLAUDE_DIR/settings.local.json"

  # 2-1: JSON 유효성
  if [ -f "$settings" ]; then
    if python3 -m json.tool "$settings" > /dev/null 2>&1; then
      add_result "Hooks" "2-1" "JSON 유효성" "PASS" "settings.local.json 유효" "SI"
    else
      add_result "Hooks" "2-1" "JSON 유효성" "FAIL" "JSON 파싱 실패" "SI"
      return
    fi
  else
    add_result "Hooks" "2-1" "JSON 유효성" "FAIL" "settings.local.json 없음" "SI"
    return
  fi

  # 2-2: 필수 이벤트 커버리지
  missing_events=""
  for event in "SessionStart" "PreToolUse" "PostToolUse" "Stop"; do
    if ! grep -q "\"$event\"" "$settings" 2>/dev/null; then
      missing_events="$missing_events $event"
    fi
  done
  if [ -z "$missing_events" ]; then
    add_result "Hooks" "2-2" "필수 이벤트 커버리지" "PASS" "4개 필수 이벤트 존재" "AC,SI"
  else
    add_result "Hooks" "2-2" "필수 이벤트 커버리지" "WARN" "누락:$missing_events" "AC,SI"
  fi

  # 2-4: 안전 훅 존재
  if grep -q "rm.*-rf\|reset.*--hard\|DROP.*TABLE" "$settings" 2>/dev/null; then
    add_result "Hooks" "2-4" "안전 훅 존재" "PASS" "파괴적 명령 감지 패턴 존재" "AC,SI"
  else
    add_result "Hooks" "2-4" "안전 훅 존재" "WARN" "파괴적 명령 감지 훅 없음" "AC,SI"
  fi

  # 2-5: prompt 훅 존재
  prompt_count=$(grep -c '"type": *"prompt"' "$settings" 2>/dev/null || echo "0")
  if [ "$prompt_count" -ge 1 ]; then
    add_result "Hooks" "2-5" "prompt 훅 존재" "PASS" "prompt 훅 ${prompt_count}개" "AC,GC"
  else
    add_result "Hooks" "2-5" "prompt 훅 존재" "WARN" "prompt 훅 없음" "AC,GC"
  fi

  # 2-7: 루프 방지 훅
  if grep -q "anti-loop\|loop.*guard\|loop.*prevent" "$settings" 2>/dev/null; then
    add_result "Hooks" "2-7" "루프 방지 훅" "PASS" "루프 방지 훅 존재" "AC,EL"
  else
    add_result "Hooks" "2-7" "루프 방지 훅" "WARN" "루프 방지 훅 없음" "AC,EL"
  fi

  # 2-8: 훅 수 적정성
  hook_count=$(grep -c '"type"' "$settings" 2>/dev/null || echo "0")
  if [ "$hook_count" -ge 5 ] && [ "$hook_count" -le 15 ]; then
    add_result "Hooks" "2-8" "훅 수 적정성" "PASS" "훅 ${hook_count}개 (5-15 권장)" "SI"
  elif [ "$hook_count" -ge 3 ] && [ "$hook_count" -le 20 ]; then
    add_result "Hooks" "2-8" "훅 수 적정성" "WARN" "훅 ${hook_count}개 (3-20 범위)" "SI"
  else
    add_result "Hooks" "2-8" "훅 수 적정성" "FAIL" "훅 ${hook_count}개 (범위 초과)" "SI"
  fi
}

# --- 3. Skills 검사 ---

check_skills() {
  local skills_dir="$CLAUDE_DIR/skills"

  # 3-1: SKILL.md 존재
  if [ -d "$skills_dir" ]; then
    total_dirs=$(find "$skills_dir" -mindepth 1 -maxdepth 1 -type d ! -name "_core" | wc -l | tr -d ' ')
    skill_md_count=$(find "$skills_dir" -name "SKILL.md" | wc -l | tr -d ' ')
    if [ "$skill_md_count" -ge "$total_dirs" ] && [ "$total_dirs" -gt 0 ]; then
      add_result "Skills" "3-1" "SKILL.md 존재" "PASS" "${skill_md_count}개 SKILL.md (${total_dirs}개 디렉토리)" "GC"
    elif [ "$skill_md_count" -gt 0 ]; then
      add_result "Skills" "3-1" "SKILL.md 존재" "WARN" "${skill_md_count}/${total_dirs} SKILL.md 존재" "GC"
    else
      add_result "Skills" "3-1" "SKILL.md 존재" "FAIL" "SKILL.md 없음" "GC"
    fi
  else
    add_result "Skills" "3-1" "SKILL.md 존재" "FAIL" "skills/ 디렉토리 없음" "GC"
  fi

  # 3-2: YAML frontmatter 필수 필드
  if [ -d "$skills_dir" ]; then
    fm_ok=0
    fm_total=0
    for f in $(find "$skills_dir" -name "SKILL.md" 2>/dev/null); do
      ((fm_total++))
      if grep -q "^name:" "$f" && grep -q "^description:" "$f"; then
        ((fm_ok++))
      fi
    done
    if [ "$fm_total" -gt 0 ] && [ "$fm_ok" -eq "$fm_total" ]; then
      add_result "Skills" "3-2" "YAML frontmatter" "PASS" "${fm_ok}/${fm_total} frontmatter 유효" "GC"
    elif [ "$fm_ok" -gt 0 ]; then
      add_result "Skills" "3-2" "YAML frontmatter" "WARN" "${fm_ok}/${fm_total} frontmatter 유효" "GC"
    else
      add_result "Skills" "3-2" "YAML frontmatter" "FAIL" "유효한 frontmatter 없음" "GC"
    fi
  fi

  # 3-3: description 품질 (트리거 문구)
  if [ -d "$skills_dir" ]; then
    trigger_ok=0
    trigger_total=0
    for f in $(find "$skills_dir" -name "SKILL.md" 2>/dev/null); do
      ((trigger_total++))
      if grep -qi "should be used when\|trigger\|asked to" "$f" 2>/dev/null; then
        ((trigger_ok++))
      fi
    done
    if [ "$trigger_total" -gt 0 ] && [ "$trigger_ok" -ge $((trigger_total * 7 / 10)) ]; then
      add_result "Skills" "3-3" "description 품질" "PASS" "${trigger_ok}/${trigger_total} 트리거 문구 포함" "GC,CE"
    else
      add_result "Skills" "3-3" "description 품질" "WARN" "${trigger_ok}/${trigger_total} 트리거 문구 포함" "GC,CE"
    fi
  fi

  # 3-8: _core SSoT 구조
  if [ -d "$skills_dir/_core" ]; then
    core_ok=true
    for f in roles.md protocols.md; do
      if [ ! -f "$skills_dir/_core/$f" ]; then
        core_ok=false
      fi
    done
    if $core_ok; then
      add_result "Skills" "3-8" "_core SSoT 구조" "PASS" "roles.md + protocols.md 존재" "CE,GC"
    else
      add_result "Skills" "3-8" "_core SSoT 구조" "WARN" "_core 파일 일부 누락" "CE,GC"
    fi
  else
    add_result "Skills" "3-8" "_core SSoT 구조" "FAIL" "_core/ 디렉토리 없음" "CE,GC"
  fi
}

# --- 4. Rules 검사 ---

check_rules() {
  local rules_dir="$CLAUDE_DIR/rules"

  # 4-1: 글로벌 rules 존재
  if [ -d "$rules_dir" ]; then
    rule_count=$(find "$rules_dir" -name "*.md" | wc -l | tr -d ' ')
    if [ "$rule_count" -ge 1 ]; then
      add_result "Rules" "4-1" "글로벌 rules 존재" "PASS" "${rule_count}개 규칙 파일" "GC"
    else
      add_result "Rules" "4-1" "글로벌 rules 존재" "FAIL" "규칙 파일 없음" "GC"
    fi
  else
    add_result "Rules" "4-1" "글로벌 rules 존재" "FAIL" "rules/ 디렉토리 없음" "GC"
  fi

  # 4-2: 핵심 규칙 커버리지
  if [ -d "$rules_dir" ]; then
    core_rules=0
    for kw in "환각\|hallucin\|anti-halluc" "안전\|safety\|safe" "루프\|loop"; do
      if grep -rql "$kw" "$rules_dir" 2>/dev/null; then
        ((core_rules++))
      fi
    done
    if [ "$core_rules" -ge 3 ]; then
      add_result "Rules" "4-2" "핵심 규칙 커버리지" "PASS" "환각방지+안전+루프방지 존재" "GC,EL"
    elif [ "$core_rules" -ge 2 ]; then
      add_result "Rules" "4-2" "핵심 규칙 커버리지" "WARN" "${core_rules}/3 핵심 규칙" "GC,EL"
    else
      add_result "Rules" "4-2" "핵심 규칙 커버리지" "FAIL" "${core_rules}/3 핵심 규칙" "GC,EL"
    fi
  fi

  # 4-4: 파일 크기 적정성
  if [ -d "$rules_dir" ]; then
    size_ok=0
    size_total=0
    for f in "$rules_dir"/*.md; do
      [ -f "$f" ] || continue
      ((size_total++))
      lines=$(wc -l < "$f" | tr -d ' ')
      if [ "$lines" -ge 5 ] && [ "$lines" -le 30 ]; then
        ((size_ok++))
      fi
    done
    if [ "$size_total" -gt 0 ] && [ "$size_ok" -eq "$size_total" ]; then
      add_result "Rules" "4-4" "파일 크기 적정성" "PASS" "${size_ok}/${size_total} 적정 범위" "GC"
    else
      add_result "Rules" "4-4" "파일 크기 적정성" "WARN" "${size_ok}/${size_total} 적정 범위" "GC"
    fi
  fi
}

# --- 5. Scripts 검사 ---

check_scripts() {
  local scripts_dir="$CLAUDE_DIR/scripts"

  # 5-1: 스크립트 존재
  if [ -d "$scripts_dir" ]; then
    script_count=$(find "$scripts_dir" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) | wc -l | tr -d ' ')
    if [ "$script_count" -ge 1 ]; then
      add_result "Scripts" "5-1" "스크립트 존재" "PASS" "${script_count}개 스크립트" "AC"
    else
      add_result "Scripts" "5-1" "스크립트 존재" "FAIL" "스크립트 없음" "AC"
    fi
  else
    add_result "Scripts" "5-1" "스크립트 존재" "FAIL" "scripts/ 디렉토리 없음" "AC"
  fi

  # 5-2: 문법 유효성 (Python, JS, Bash)
  if [ -d "$scripts_dir" ]; then
    syntax_ok=0
    syntax_total=0
    for f in "$scripts_dir"/*.py; do
      [ -f "$f" ] || continue
      ((syntax_total++))
      if python3 -c "import py_compile; py_compile.compile('$f', doraise=True)" 2>/dev/null; then
        ((syntax_ok++))
      fi
    done
    for f in "$scripts_dir"/*.js; do
      [ -f "$f" ] || continue
      ((syntax_total++))
      if node --check "$f" 2>/dev/null; then
        ((syntax_ok++))
      fi
    done
    for f in "$scripts_dir"/*.sh; do
      [ -f "$f" ] || continue
      ((syntax_total++))
      if bash -n "$f" 2>/dev/null; then
        ((syntax_ok++))
      fi
    done
    if [ "$syntax_total" -gt 0 ] && [ "$syntax_ok" -eq "$syntax_total" ]; then
      add_result "Scripts" "5-2" "문법 유효성" "PASS" "${syntax_ok}/${syntax_total} 문법 통과" "AC,EL"
    elif [ "$syntax_ok" -gt 0 ]; then
      add_result "Scripts" "5-2" "문법 유효성" "WARN" "${syntax_ok}/${syntax_total} 문법 통과" "AC,EL"
    else
      add_result "Scripts" "5-2" "문법 유효성" "FAIL" "문법 통과 0건" "AC,EL"
    fi
  fi

  # 5-6: GC/평가 스크립트 존재
  if [ -d "$scripts_dir" ]; then
    maint_count=0
    for kw in "gc" "eval" "clean" "audit"; do
      if find "$scripts_dir" -name "*${kw}*" -type f 2>/dev/null | grep -q .; then
        ((maint_count++))
      fi
    done
    if [ "$maint_count" -ge 2 ]; then
      add_result "Scripts" "5-6" "GC/평가 스크립트" "PASS" "유지보수 스크립트 ${maint_count}종" "EL"
    elif [ "$maint_count" -ge 1 ]; then
      add_result "Scripts" "5-6" "GC/평가 스크립트" "WARN" "유지보수 스크립트 ${maint_count}종" "EL"
    else
      add_result "Scripts" "5-6" "GC/평가 스크립트" "FAIL" "유지보수 스크립트 없음" "EL"
    fi
  fi
}

# --- 6. Agents 검사 ---

check_agents() {
  local agents_dir="$CLAUDE_DIR/agents"

  # 6-1: 에이전트 정의 존재
  if [ -d "$agents_dir" ]; then
    agent_count=$(find "$agents_dir" -name "*.md" | wc -l | tr -d ' ')
    if [ "$agent_count" -ge 1 ]; then
      add_result "Agents" "6-1" "에이전트 정의 존재" "PASS" "${agent_count}개 에이전트" "AC"
    else
      add_result "Agents" "6-1" "에이전트 정의 존재" "FAIL" "에이전트 없음" "AC"
    fi
  else
    add_result "Agents" "6-1" "에이전트 정의 존재" "FAIL" "agents/ 디렉토리 없음" "AC"
  fi

  # 6-2: YAML frontmatter 필수 필드
  if [ -d "$agents_dir" ]; then
    fm_ok=0
    fm_total=0
    for f in "$agents_dir"/*.md; do
      [ -f "$f" ] || continue
      ((fm_total++))
      if grep -q "^name:" "$f" && grep -q "^description:" "$f" && grep -q "tools:" "$f"; then
        ((fm_ok++))
      fi
    done
    if [ "$fm_total" -gt 0 ] && [ "$fm_ok" -eq "$fm_total" ]; then
      add_result "Agents" "6-2" "YAML frontmatter" "PASS" "${fm_ok}/${fm_total} 필수 필드 확인" "AC,SI"
    else
      add_result "Agents" "6-2" "YAML frontmatter" "WARN" "${fm_ok}/${fm_total} 필수 필드 확인" "AC,SI"
    fi
  fi

  # 6-3: description 품질
  if [ -d "$agents_dir" ]; then
    desc_ok=0
    desc_total=0
    for f in "$agents_dir"/*.md; do
      [ -f "$f" ] || continue
      ((desc_total++))
      if grep -qi "use when\|asked to\|trigger" "$f" 2>/dev/null; then
        ((desc_ok++))
      fi
    done
    if [ "$desc_total" -gt 0 ] && [ "$desc_ok" -ge $((desc_total * 7 / 10)) ]; then
      add_result "Agents" "6-3" "description 품질" "PASS" "${desc_ok}/${desc_total} 트리거 문구 포함" "AC,GC"
    else
      add_result "Agents" "6-3" "description 품질" "WARN" "${desc_ok}/${desc_total} 트리거 문구 포함" "AC,GC"
    fi
  fi
}

# --- 7. MCP 검사 ---

check_mcp() {
  # 7-1: MCP 설정 존재
  local mcp_found=false
  for mcp_file in "$CLAUDE_DIR/.mcp.json" "$HOME/.mcp.json"; do
    if [ -f "$mcp_file" ]; then
      mcp_found=true
      # 7-2: JSON 유효성
      if python3 -m json.tool "$mcp_file" > /dev/null 2>&1; then
        add_result "MCP" "7-1" "MCP 설정 존재" "PASS" "$(basename "$mcp_file") 존재" "SI"
        add_result "MCP" "7-2" "JSON 유효성" "PASS" "MCP 설정 파싱 가능" "SI"
      else
        add_result "MCP" "7-1" "MCP 설정 존재" "PASS" "$(basename "$mcp_file") 존재" "SI"
        add_result "MCP" "7-2" "JSON 유효성" "FAIL" "MCP JSON 파싱 실패" "SI"
      fi
      break
    fi
  done
  if ! $mcp_found; then
    add_result "MCP" "7-1" "MCP 설정 존재" "WARN" "MCP 설정 파일 없음 (선택 사항)" "SI"
    add_result "MCP" "7-2" "JSON 유효성" "WARN" "MCP 없어 검사 생략" "SI"
  fi
}

# --- 실행 ---

case "$MODE" in
  quick)
    check_claudemd
    check_hooks
    check_skills
    ;;
  focus)
    case "$FOCUS_AREA" in
      claudemd|claude) check_claudemd ;;
      hooks) check_hooks ;;
      skills) check_skills ;;
      rules) check_rules ;;
      scripts) check_scripts ;;
      agents) check_agents ;;
      mcp) check_mcp ;;
      *) echo "알 수 없는 영역: $FOCUS_AREA"; exit 1 ;;
    esac
    ;;
  full)
    check_claudemd
    check_hooks
    check_skills
    check_rules
    check_scripts
    check_agents
    check_mcp
    ;;
esac

# --- JSON 출력 ---

TOTAL=$((PASS + WARN + FAIL))

echo "{"
echo "  \"mode\": \"$MODE\","
echo "  \"total\": $TOTAL,"
echo "  \"pass\": $PASS,"
echo "  \"warn\": $WARN,"
echo "  \"fail\": $FAIL,"
echo "  \"results\": ["

for i in "${!RESULTS[@]}"; do
  if [ "$i" -lt $((${#RESULTS[@]} - 1)) ]; then
    echo "    ${RESULTS[$i]},"
  else
    echo "    ${RESULTS[$i]}"
  fi
done

echo "  ]"
echo "}"
