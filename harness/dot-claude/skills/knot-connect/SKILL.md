---
name: knot-connect
description: 현재 작업 중인 프로젝트를 knot 지식 vault(Obsidian)에 연결한다 — wiki/projects/<name>/ 네임스페이스를 스캐폴드하고 초기 지식을 ingest한다. Use when "옵시디언 연결", "obsidian 연결", "knot 연결", "knot에 등록", "이 프로젝트 knot에", "지식 vault에 추가", "이 프로젝트 옵시디언에", "connect to obsidian", "connect to knot", or "/knot-connect". NOT for - knot 일반 ingest/query/lint(use the knot skill instead), 새 vault 생성(use configure-multiagent).
---

# knot-connect — 프로젝트를 knot vault에 연결

현재 작업 중인 프로젝트를 개인 knot 지식 vault에 등록하고 초기 지식을 ingest한다.
Obsidian으로는 vault 하나(`$KNOT_VAULT`)를 열어 모든 프로젝트를 본다 — 이 스킬은 그 vault 안에 현재 프로젝트의 격리된 네임스페이스를 만든다(프로젝트 코드 폴더 자체를 Obsidian으로 여는 게 아니다).

## 0. 게이트 (먼저)

```bash
KNOT_VAULT="${KNOT_VAULT:-$(cat ~/.config/knot/vault 2>/dev/null)}"
[ -n "$KNOT_VAULT" ] && [ -d "$KNOT_VAULT" ] && echo "OK $KNOT_VAULT" || echo NO_VAULT
```
`NO_VAULT`면 중단하고 안내한다 — vault가 없으면 `configure-multiagent`(또는 knot setup)로 먼저 만든다. 경로 추측 금지.

## 1. 프로젝트명 결정

현재 작업 디렉토리 basename을 kebab-case 슬러그로 변환한다. 사용자에게 **1회 확인**한다(다른 이름을 원하면 받는다). 슬러그 규칙: 영소문자·숫자·하이픈.

## 2. 등록 여부 확인

`$KNOT_VAULT/wiki/projects/<slug>/`가 이미 있으면 "이미 등록됨"을 보고하고, **갱신 ingest를 할지** 묻는다(기존 stub/페이지를 최신 사실로 채움). 없으면 3으로.

## 3. 스캐폴드

`cd "$KNOT_VAULT"` 후 working tree가 더러우면(미커밋) 중단·보고. 깨끗하면:
```bash
python3 "$KNOT_VAULT/scripts/new_project.py" <slug>
```
→ 24 CORE stub 생성 + 루트 `index.md ## projects`에 진입점 등록.

## 4. 초기 ingest (사용자 확인 후)

현재 저장소의 핵심 메타(`CLAUDE.md`/`README`/`package.json`/주요 디렉토리)를 읽어, 최소 `overview`·`product-overview`·`architecture`·`tech-stack`·`file-map`을 **검증된 사실로** 채운다. 규약은 `$KNOT_VAULT/schema.md`와 `prompts/ingest.md`를 정독해 따른다:
- frontmatter `scope: project` · `project: <slug>` · `sources:` 근거.
- 프로젝트 내부 링크는 경로 한정 `[[projects/<slug>/<page>|표시]]`. **다른 프로젝트로 링크 금지**(격리). 공통은 `[[_common/...]]`.
- 저장소에 **실제로 없는 것**(DB·인증·결제 등)은 "해당 없음"으로 정직하게. 발명 금지.
규모가 크면 카테고리별로 나눠 채우고, 채울 근거가 없는 페이지는 stub으로 둔다.

## 5. lint + 커밋 + 보고

```bash
cd "$KNOT_VAULT" && python3 scripts/lint.py     # 0 error 확인 (격리·등재·frontmatter)
git add -A && git commit -m "scaffold: <slug> 연결 (+초기 ingest)"   # 모델 트레일러 포함
```
완료 후: Obsidian으로 `$KNOT_VAULT`를 열면 `<slug>` 클러스터가 graph에 보인다고 안내.

## Do NOT

- `$KNOT_VAULT` 미설정 시 경로 추측·임의 폴더 사용 금지.
- `schema.md`·`prompts/`·`scripts/`를 임의 수정하지 말 것(제안만).
- 프로젝트 네임스페이스 간 직접 링크 금지(격리 불변식).
- 코드/git에 이미 있는 정보를 그대로 복제하지 말 것 — 지속가치 있는 요약·결정·구조만 ingest.
