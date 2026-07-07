export const meta = {
  name: 'fix-skills',
  description: '캐시 스킬 P0+P1 in-place 정합 — 브라우저 Chrome→Playwright(분류식)·죽은참조 수정. 삭제·통폐합 금지. 8클러스터 병렬. 플러그인 업데이트 후 재실행하면 재적용됨.',
  whenToUse: '스킬 분석 리포트(2026-07-07) 반영. 플러그인 캐시 스킬의 파이프라인 정합 수정. 재실행=재적용.',
  phases: [{ title: 'Fix', detail: '8클러스터 병렬 in-place 수정' }],
}

const JH = '~/.claude/plugins/cache/claude-templates/jusan-harness/1.0.0/skills'
const AG = '~/.claude/plugins/cache/claude-templates/jusan-harness/1.0.0/agents'

const FIX = `수정 규칙(각 스킬 SKILL.md를 in-place Edit — 최소·외과수술식, frontmatter·핵심 로직 보존):

1) 브라우저 우선순위(분류식, 맹목 일괄치환 금지):
   - "Chrome MCP 우선"·"Chrome 1순위·Playwright fallback only"·"playwright는 fallback" 류 **정책 재진술** → "브라우저 우선순위는 rules/uncompromising-rigor §1(2026-07-07 Playwright MCP 전역 우선)을 따른다"로 교체.
   - **정당한 Chrome 용법**(로그인/세션 재사용·실제 브라우저 상태·확장/DevTools·열린 탭 확인)은 **보존**하되 "세션 재사용이 필요할 때만 Chrome MCP"로 문구 명확화.
   - 도구명 오류는 실제 MCP 도구명으로.

2) 죽은 참조:
   - \`~/.claude/skills/_core/…\` → \`\${CLAUDE_PLUGIN_ROOT}/../_core/…\`(또는 "플러그인의 형제 _core/") 로. **버전 캐시 절대경로 하드코딩 금지.**
   - 죽은 훅 참조(\`check-chrome-mcp-priority.sh\`·\`detect-self-justification.sh\`·\`block-on-self-justification.sh\`)는 **제거**(문장째).
   - Windows 경로(\`C:\\\\Users\\\\…\`) → 제거 또는 스킬 동봉/인라인 등 플랫폼 독립.
   - Notion "자동 동기화 의무" → "Notion MCP 연결 시에만(옵션)"으로 강등 또는 제거.
   - \`present_files\`(claude.ai 전용) → "워크스페이스에 파일로 산출" 로.
   - \`/think-deep\` 참조 → think-lite/think-full로 정정 또는 제거.
   - gstack/aidlc-baseline 등 하드 전제 경로 → \`\${CLAUDE_PLUGIN_ROOT}\` 상대 또는 "있을 때만" 조건화.

3) 금지: 스킬 **삭제·통폐합·대규모 재작성 금지**(이 단계는 in-place 정합만). agent-teams/think 등 통폐합은 별도 승인 대상이라 손대지 않는다.

4) 편집 후 각 스킬: frontmatter(--- … ---) 온전·마크다운 유효 확인. 안전하게 못 고칠 항목은 **편집하지 말고 flag**에 사유 기재.
5) 파일이 없거나 이슈 없으면 edited=false.`

const SK = { type: 'object', additionalProperties: false, required: ['name', 'edited', 'changes', 'flagged'], properties: {
  name: { type: 'string' }, edited: { type: 'boolean' },
  changes: { type: 'array', items: { type: 'string' } },
  flagged: { type: 'array', items: { type: 'string' } } } }
const CS = { type: 'object', additionalProperties: false, required: ['cluster', 'skills'], properties: {
  cluster: { type: 'string' }, skills: { type: 'array', items: SK } } }

const clusters = [
  { n: 'C1 사고/분석', base: JH, s: ['what', 'what-ce', 'think-full', 'think-lite', 'first-principles', 'ooda', 'cynefin', 'deep-analysis-mode', 'ce-advisor', 'clarity-tracker'] },
  { n: 'C2 오케스트레이션', base: JH, s: ['agent-teams-orchestrator', 'agent-teams-deep-analysis', 'agent-teams-feature-dev', 'agent-teams-reactive-dev', 'harness-loop', 'harness-merge-advisor'] },
  { n: 'C3a Playwright/QA', base: JH, s: ['playwright-design-audit', 'playwright-qa-agent-teams', 'playwright-qa-expert', 'playwright-uiux-audit', 'live-verify-loop', 'webapp-testing'] },
  { n: 'C3b UI/UX/웹', base: JH, s: ['ui-ux-pro-max', 'web-design-guidelines', 'web-audit-pipeline', 'reference-match', 'design-intent-lock', 'lighthouse-ci', 'accesslint'] },
  { n: 'C4 보안/리뷰/인프라', base: JH, s: ['security-audit', 'security-review', 'backend-review', 'frontend-review', 'infra-audit', 'project-ultra-audit'] },
  { n: 'C5 도메인/프로젝트', base: JH, s: ['aidlc-baseline', 'aidlc-realizesoft', 'architect', 'domain-expert-analysis', 'domain-researcher', 'project-bootstrapper', 'office-hours', 'ga4-funnel'] },
  { n: 'C6 산출물/문서', base: JH, s: ['docx', 'pdf', 'xlsx', 'ppt-study', 'pitch-deck', 'owner-friendly-explainer', 'ultradetail-walk', 'knot-connect'] },
  { n: 'C7 에이전트', base: AG, s: ['ce-reviewer', 'codebase-explorer', 'harness-evaluator', 'infra-auditor', 'security-reviewer', 'thoughts-writer'], isAgent: true },
]

const results = await parallel(clusters.map((c) => () =>
  agent(
    `당신은 하네스 스킬 수리공이다. 아래 클러스터의 각 파일을 읽고 수정 규칙대로 **in-place Edit**하라. 서로 다른 클러스터는 다른 파일을 건드리므로 충돌 없음.\n\n대상 경로: ${c.base}/<이름>/SKILL.md ${c.isAgent ? '(에이전트는 ' + c.base + '/<이름>.md)' : ''}\n이름: ${c.s.join(', ')}\n\n${FIX}\n\n각 파일마다 {name, edited, changes[], flagged[]} 반환. 큰 파일은 관련 섹션만 정밀 수정(전체 재작성 금지).`,
    { schema: CS, label: c.n, phase: 'Fix' })
))

return { clusters: results.filter(Boolean) }
