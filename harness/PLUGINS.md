# 플러그인 재현 매니페스트

> 현재 하네스에 설치된 플러그인 마켓플레이스 13종과 플러그인 목록.
> 스냅샷 기준: 2026-06-26 (실제 `~/.claude/plugins/installed_plugins.json` + `settings.json`의 `enabledPlugins` 교차 검증).
> **자동 설치**: `bash harness/setup-plugins.sh` (Mac/Linux/Git-Bash) 또는 `pwsh harness/setup-plugins.ps1` (Windows).

CLI 문법 [검증됨]:
- `claude plugin marketplace add <source>` — source = GitHub `owner/repo` · URL · 로컬 경로
- `claude plugin install <plugin>@<marketplace> -s user`

---

## 1. 마켓플레이스 (13)

| 마켓플레이스 이름 | GitHub 소스 | add 명령 |
|---|---|---|
| claude-plugins-official | `anthropics/claude-plugins-official` | `claude plugin marketplace add anthropics/claude-plugins-official` |
| openai-codex | `openai/codex-plugin-cc` | `claude plugin marketplace add openai/codex-plugin-cc` |
| accesslint | `accesslint/claude-marketplace` | `claude plugin marketplace add accesslint/claude-marketplace` |
| karpathy-skills | `multica-ai/andrej-karpathy-skills` | `claude plugin marketplace add multica-ai/andrej-karpathy-skills` |
| claude-video | `bradautomates/claude-video` | `claude plugin marketplace add bradautomates/claude-video` |
| understand-anything | `Lum1104/Understand-Anything` | `claude plugin marketplace add Lum1104/Understand-Anything` |
| agentmemory | `rohitg00/agentmemory` | `claude plugin marketplace add rohitg00/agentmemory` |
| superpowers-marketplace | `obra/superpowers-marketplace` | `claude plugin marketplace add obra/superpowers-marketplace` |
| omc | `Yeachan-Heo/oh-my-claudecode` | `claude plugin marketplace add Yeachan-Heo/oh-my-claudecode` |
| multi-agent-starter | `netwaif/multi-agent-starter` | `claude plugin marketplace add netwaif/multi-agent-starter` |
| fablize | `fivetaku/fablize` | `claude plugin marketplace add fivetaku/fablize` |
| gptaku-plugins | `fivetaku/gptaku_plugins` | `claude plugin marketplace add fivetaku/gptaku_plugins` |
| bkit-marketplace | `popup-studio-ai/bkit-claude-code` | `claude plugin marketplace add popup-studio-ai/bkit-claude-code` |

---

## 2. 활성 플러그인 (enabled: true) — 현재 하네스 핵심 26종

| 플러그인 | 마켓플레이스 | install 명령 |
|---|---|---|
| commit-commands | claude-plugins-official | `claude plugin install commit-commands@claude-plugins-official -s user` |
| pr-review-toolkit | claude-plugins-official | `claude plugin install pr-review-toolkit@claude-plugins-official -s user` |
| code-review | claude-plugins-official | `claude plugin install code-review@claude-plugins-official -s user` |
| code-simplifier | claude-plugins-official | `claude plugin install code-simplifier@claude-plugins-official -s user` |
| feature-dev | claude-plugins-official | `claude plugin install feature-dev@claude-plugins-official -s user` |
| frontend-design | claude-plugins-official | `claude plugin install frontend-design@claude-plugins-official -s user` |
| security-guidance | claude-plugins-official | `claude plugin install security-guidance@claude-plugins-official -s user` |
| hookify | claude-plugins-official | `claude plugin install hookify@claude-plugins-official -s user` |
| learning-output-style | claude-plugins-official | `claude plugin install learning-output-style@claude-plugins-official -s user` |
| plugin-dev | claude-plugins-official | `claude plugin install plugin-dev@claude-plugins-official -s user` |
| slack | claude-plugins-official | `claude plugin install slack@claude-plugins-official -s user` |
| supabase | claude-plugins-official | `claude plugin install supabase@claude-plugins-official -s user` |
| stripe | claude-plugins-official | `claude plugin install stripe@claude-plugins-official -s user` |
| context7 | claude-plugins-official | `claude plugin install context7@claude-plugins-official -s user` |
| vercel | claude-plugins-official | `claude plugin install vercel@claude-plugins-official -s user` |
| superpowers | claude-plugins-official | `claude plugin install superpowers@claude-plugins-official -s user` |
| codex | openai-codex | `claude plugin install codex@openai-codex -s user` |
| accesslint | accesslint | `claude plugin install accesslint@accesslint -s user` |
| andrej-karpathy-skills | karpathy-skills | `claude plugin install andrej-karpathy-skills@karpathy-skills -s user` |
| watch | claude-video | `claude plugin install watch@claude-video -s user` |
| understand-anything | understand-anything | `claude plugin install understand-anything@understand-anything -s user` |
| agentmemory | agentmemory | `claude plugin install agentmemory@agentmemory -s user` |
| oh-my-claudecode | omc | `claude plugin install oh-my-claudecode@omc -s user` |
| fablize | fablize | `claude plugin install fablize@fablize -s user` |
| insane-search | gptaku-plugins | `claude plugin install insane-search@gptaku-plugins -s user` |
| bkit | bkit-marketplace | `claude plugin install bkit@bkit-marketplace -s user` |

---

## 3. 비활성/선택 플러그인 (enabled: false 또는 미활성)

재현 시 필수 아님. 필요할 때만 설치/활성화한다.

| 플러그인 | 마켓플레이스 | 상태 | 비고 |
|---|---|---|---|
| explanatory-output-style | claude-plugins-official | disabled | 출력 스타일(토큰 비용↑) |
| firebase | claude-plugins-official | disabled | 외부 서비스 |
| playwright | claude-plugins-official | disabled | 별도 standalone playwright MCP 사용 중([MCP.md](./MCP.md)) |
| superpowers | superpowers-marketplace | disabled | claude-plugins-official판이 활성이라 중복본 비활성 |
| multi-agent-starter | multi-agent-starter | local scope | claude-templates 프로젝트 한정 설치 |
| github · gitlab · asana · linear · greptile · laravel-boost · serena | claude-plugins-official | 설치됨/미활성 | 과거 설치분. serena는 standalone MCP로 대체 운용 |

---

## 4. 마켓플레이스 특화 설치 주의 (Windows)

- **insane-search** (gptaku-plugins): Python 의존(`curl_cffi`/`bs4`/`pyyaml`)을 수동 선시드해야 정상 작동. Windows에서 `setup.sh`(bash) 미작동.
  ```bash
  python3 -m pip install curl_cffi beautifulsoup4 pyyaml
  ```
- **bkit** (bkit-marketplace): config가 full-replace 방식이라 글로벌 override 없음. 능동 풀 ON이되 완료선언·검증 권위는 fablize 우선(글로벌 CLAUDE.md `## bkit 하이브리드` 참조).
- **agentmemory**: Windows에서 Docker fallback + 서버 수동 기동 필요(npx classifier 차단 gotcha).

---

## 5. 관리 명령

```bash
claude plugin list                       # 설치 목록
claude plugin marketplace list           # 마켓플레이스 목록
claude plugin enable <plugin>@<market>   # 활성화
claude plugin disable <plugin>@<market>  # 비활성화(코드 유지)
claude plugin update <plugin>            # 업데이트
claude plugin uninstall <plugin>         # 제거
```
