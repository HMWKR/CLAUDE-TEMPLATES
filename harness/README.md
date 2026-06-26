# 하네스 재현 키트 (Harness Reproduction Kit)

> 이 디렉토리만으로 **현재 Claude Code 하네스 전체**(글로벌 지침 · 규칙 · 에이전트 · 스킬 · 플러그인 · MCP)를 새 머신(Mac/Windows/Linux)에 동일하게 재구성한다.
> 스냅샷: **2026-06-26** · Claude Code 2.1.185 기준.

---

## 무엇이 들어있나

| 경로 | 내용 | 재현 방식 |
|---|---|---|
| `dot-claude/CLAUDE.md` | 글로벌 지침 (81줄: CE·착수계약·FABLIZE 라우터·bkit 하이브리드) | 파일 복사 |
| `dot-claude/rules/` | always-on 규칙 9종 | 파일 복사 |
| `dot-claude/agents/` | 글로벌 서브에이전트 6종 | 파일 복사 |
| `dot-claude/skills/` | 글로벌 스킬 50종 (4.6M) | 파일 복사 |
| `dot-claude/settings.reference.json` | settings 참조본 (env 플래그·enabledPlugins 맵) | **수동 병합** (머신 특화 경로 포함) |
| `PLUGINS.md` + `setup-plugins.*` | 마켓플레이스 13 + 플러그인 26 | `claude plugin` 명령 |
| `MCP.md` + `setup-mcp.*` | MCP 서버 22 (standalone 6 자동) | `claude mcp add` 명령 |

> ⚠️ **플러그인·MCP 서버 본체는 번들하지 않는다** — 3rd-party 코드라 설치 명령으로 재현한다(라이선스·용량·자동업데이트 고려). 위 스크립트가 공식 마켓플레이스에서 받아 설치한다.

---

## 설치 범위 — 글로벌 vs 프로젝트

`install.sh`/`install.ps1`은 실행 시작에 **설치 범위를 묻는다**(`--scope`/`-Scope`로 비대화형 지정 가능).

| 범위 | 대상 | 적용 | 플러그인·MCP 스코프 |
|---|---|---|---|
| **글로벌** (기본) | `~/.claude/` (`CLAUDE.md`는 `~/.claude/CLAUDE.md`) | 이 머신의 **모든 프로젝트** | `-s user` |
| **프로젝트** | `<프로젝트>/.claude/` (`CLAUDE.md`는 `<프로젝트>/CLAUDE.md`) | **해당 프로젝트만** | `-s project` |

- 글로벌: 머신 전체 하네스를 깐다(지금까지의 기본 동작).
- 프로젝트: 특정 프로젝트에만 하네스를 격리 적용. `rules/`는 글로벌처럼 자동주입되지 않고 보존 목적으로 복사되며, `CLAUDE.md`·`skills/`·`agents/`는 그 프로젝트에서 로드된다.

---

## 사전 요구사항 (공통)

- **Claude Code CLI** 설치 + 로그인 (`claude` 명령 사용 가능)
- **Node.js / npx** (다수 플러그인·MCP가 의존)
- **git**, **curl**
- 선택: **Python 3** (insane-search·일부 스킬), **uv** (serena MCP)

---

## 설치 — macOS / Linux

```bash
git clone https://github.com/HMWKR/CLAUDE-TEMPLATES.git
cd CLAUDE-TEMPLATES

# 1) 하네스 파일 설치 — 실행하면 범위(글로벌/프로젝트)를 물어본다 (기존본 자동 백업)
bash harness/install.sh
#    비대화형 지정:  bash harness/install.sh --scope global
#                    bash harness/install.sh --scope project --project /path/to/proj

# 2) 플러그인 (글로벌=user / 프로젝트=project)
bash harness/setup-plugins.sh user           # 프로젝트면 해당 폴더에서:  bash <repo>/harness/setup-plugins.sh project

# 3) MCP (standalone 6) — 파일 상단 경로 변수 확인 후
bash harness/setup-mcp.sh user

# 한 번에:  bash harness/install.sh --scope global --with-plugins --with-mcp
```

## 설치 — Windows (PowerShell)

```powershell
git clone https://github.com/HMWKR/CLAUDE-TEMPLATES.git
cd CLAUDE-TEMPLATES

# 1) 하네스 파일 설치 — 실행하면 범위(글로벌/프로젝트)를 물어본다
pwsh harness/install.ps1        # 또는 Windows PowerShell:  powershell -File harness/install.ps1
#    비대화형 지정:  pwsh harness/install.ps1 -Scope global
#                    pwsh harness/install.ps1 -Scope project -Project C:\path\to\proj

# 2) 플러그인 (글로벌=user / 프로젝트=project)
pwsh harness/setup-plugins.ps1 user          # 프로젝트면 해당 폴더에서:  pwsh <repo>\harness\setup-plugins.ps1 project

# 3) MCP (standalone 6)
pwsh harness/setup-mcp.ps1 user

# 한 번에:  pwsh harness/install.ps1 -Scope global -WithPlugins -WithMcp
```

> Windows에서 `harness/install.sh`(bash)를 쓰려면 **Git Bash** 또는 **WSL**이 필요하다. PowerShell만 있으면 `.ps1`을 쓴다.

---

## 설치 후 (양 OS 공통)

1. **settings 병합**: `harness/dot-claude/settings.reference.json`을 보고 `~/.claude/settings.json`에 필요한 키(`env`, `enabledPlugins`, `permissions` 등)를 **수동 병합**한다. `additionalDirectories`·`hooks`의 절대경로는 본인 환경 경로로 교체.
2. **MCP 경로 치환**: `setup-mcp.*` 상단 변수(`SERENA_BIN`·`VAULT_PATH` 등)와 `MCP.md`의 플레이스홀더를 본인 경로로. 토큰은 `-e KEY=값` 또는 `/mcp` OAuth로 — **레포에 커밋 금지**.
3. **insane-search Python dep** (선택): `python3 -m pip install curl_cffi beautifulsoup4 pyyaml`
4. **Claude Code 재시작** → 전 기능 적용.

---

## 검증

```bash
claude plugin list        # 플러그인 설치 확인
claude mcp list           # MCP 등록·연결 확인
ls ~/.claude/skills | wc -l   # 50+ 스킬 확인
```

기대치: 마켓플레이스 13, 활성 플러그인 26, MCP standalone 6 + 플러그인 제공 8 + 원격 커넥터(OAuth) 8.

---

## 알려진 OS 차이 / gotcha

| 항목 | macOS/Linux | Windows |
|---|---|---|
| 글로벌 설치 | `install.sh` (bash) | `install.ps1` (PowerShell) |
| serena MCP | `uv tool install serena-agent` → `~/.local/bin/serena` | 동일, `serena.exe` |
| insane-search | `setup.sh` 동작 | bash 미작동 → Python dep 수동 시드 |
| agentmemory | 정상 | Docker fallback + 서버 수동 기동 |
| 절대경로 | `$HOME` 기반 | `$env:USERPROFILE` 기반 (`settings.reference.json`은 `C:\Users\jusan` 하드코딩 — 교체 필요) |

스냅샷이라 마켓플레이스/플러그인은 시간이 지나면 변동할 수 있다. 실시간 상태는 `claude plugin list` / `claude mcp list`로 확인.
