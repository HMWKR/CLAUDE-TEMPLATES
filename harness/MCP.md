# MCP 서버 재현 매니페스트

> 현재 하네스에 등록된 MCP 서버 22종. 스냅샷: 2026-06-26 (`claude mcp list` 실측).
> **자동 설치(standalone분)**: `bash harness/setup-mcp.sh` 또는 `pwsh harness/setup-mcp.ps1`.

CLI 문법 [검증됨]: `claude mcp add [-s user] [-t http] [-e KEY=val] <name> <commandOrUrl> [args...]`

> ⚠️ **경로/시크릿 주의**: 아래 standalone 서버 명령에는 머신 특화 절대경로가 들어간다. `<...>` 플레이스홀더를 본인 환경에 맞게 치환할 것. 토큰이 필요한 서버는 `-e KEY=값` 또는 OAuth(`/mcp`)로 주입하고 **레포에 토큰을 커밋하지 말 것**.

---

## 1. Standalone 서버 (명시적 `claude mcp add` 필요) — 6종

| 서버 | 용도 | add 명령 (경로는 플레이스홀더) |
|---|---|---|
| **codex** | Codex 워커/코드 | `claude mcp add -s user codex -- codex mcp-server` |
| **playwright** | 브라우저 자동화 | `claude mcp add -s user playwright -- npx -y @playwright/mcp@latest` |
| **serena** | 시맨틱 코드 도구 | `claude mcp add -s user serena -- <SERENA_BIN> start-mcp-server --context claude-code --project-from-cwd` |
| **obsidian** | knot 지식 vault | `claude mcp add -s user obsidian -- npx -y obsidian-mcp <VAULT_PATH>` |
| **capcut** | 영상 편집(VectCutAPI) | `claude mcp add -s user capcut -- <PYTHON_VENV> <VECTCUTAPI>/mcp_server.py` |
| **cantos** | ADR/DDR 캡처 | `claude mcp add -s user cantos -- node <CANTOS>/server.js` |

플레이스홀더 참조값 (현재 머신, Windows):
- `<SERENA_BIN>` = `C:/Users/jusan/.local/bin/serena.exe` — 설치: `uv tool install serena-agent` (Mac/Linux는 `~/.local/bin/serena`)
- `<VAULT_PATH>` = `C:/Users/jusan/knot-vault` (`$KNOT_VAULT`)
- `<PYTHON_VENV>` = `C:/Users/jusan/tools/VectCutAPI/venv-capcut/Scripts/python.exe`, `<VECTCUTAPI>` = `C:/Users/jusan/tools/VectCutAPI`
- `<CANTOS>` = `C:/Users/jusan/.claude/mcp/cantos`

---

## 2. 플러그인 제공 MCP (플러그인 설치 시 자동 등록) — 8종

별도 `claude mcp add` 불필요. 해당 플러그인([PLUGINS.md](./PLUGINS.md))을 설치하면 따라온다.

| MCP | 제공 플러그인 |
|---|---|
| `plugin:supabase:supabase` | supabase |
| `plugin:context7:context7` | context7 |
| `plugin:vercel:vercel` | vercel |
| `plugin:accesslint:accesslint` | accesslint |
| `plugin:agentmemory:agentmemory` | agentmemory |
| `plugin:oh-my-claudecode:t` | oh-my-claudecode |
| `plugin:bkit:bkit-pdca` | bkit |
| `plugin:bkit:bkit-analysis` | bkit |

---

## 3. claude.ai 원격 커넥터 (OAuth — `/mcp`로 인증) — 8종

스크립트로 등록 불가. Claude Code에서 `/mcp` → 서버 선택 → 브라우저 로그인. 또는 claude.ai 커넥터 설정.

| 커넥터 | 상태(스냅샷) |
|---|---|
| Notion | ✔ Connected |
| Wix | ✔ Connected |
| Webflow / Canva / Google Drive / Figma / Google Calendar / Gmail | 인증 필요 |

---

## 4. 검증

```bash
claude mcp list      # 전체 등록·연결 상태
claude mcp get <name>  # 개별 서버 상세
```

스냅샷 시점 연결: Connected 15 / 인증 필요 7 (claude.ai 원격 6 + plugin:vercel).
