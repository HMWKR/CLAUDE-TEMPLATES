export const meta = {
  name: 'p2-consolidate',
  description: 'P2 통폐합(codex-safe·additive·고유가치 보존): agent-teams 4종 거버넌스 정합(완료권위→conductor) + uiux-audit→design-audit alias + think 라우팅. 6 병렬. 재실행=재적용.',
  phases: [{ title: 'Consolidate', detail: '6 병렬 편집' }],
}

const JH = '~/.claude/plugins/cache/claude-templates/jusan-harness/1.0.0/skills'

const RES = { type: 'object', additionalProperties: false, required: ['target', 'edited', 'changes', 'flagged'], properties: {
  target: { type: 'string' }, edited: { type: 'boolean' },
  changes: { type: 'array', items: { type: 'string' } }, flagged: { type: 'array', items: { type: 'string' } } } }

// ---- P2.1: agent-teams 거버넌스 정합 (additive, 고유가치 보존) ----
const ALIGN = (kind, unique) => `당신은 하네스 정합 편집자다. 파일: ${JH}/${kind}/SKILL.md 를 읽고 **거버넌스 정합만 additive로** 편집하라(대규모 재작성·삭제 금지).

작업:
1. frontmatter 직후(첫 인트로 근처)에 아래 취지의 절을 **추가**한다(문구는 스킬 톤에 맞게):
   "## conductor-verify 정합\n이 스킬은 conductor-verify 파이프라인 하위의 <${kind}> 전문 진입점이다. **완료권위·최종검증은 conductor-verify(계획→검수→실행→종합→독립검증→승인)·codex 교차벤더 게이트·verify-lock을 따른다** — 자체 스코어링/완료보고는 그 단계에 종속(경쟁 권위 아님). 이 스킬의 고유 기여(${unique})는 유지한다."
2. 본문에 "완료 선언"·"자체 완료권위"·"자체 최종 게이트" 성격의 문장이 있으면 **"→ conductor-verify 승인 단계에 위임"** 취지로 1~2곳만 부드럽게 정합(문장 대량 수정 금지).
3. **금지**: 고유 로직(역할구성·병렬분업·spawn 프롬프트·Observer-Worker 루프 등) 삭제·gutting·통폐합. frontmatter 보존. AGENT_TEAMS 연산 이름 추측 변경 금지.
4. 편집 후 frontmatter(--- … ---) 온전 확인. 위험하면 flag.

반환: {target:"${kind}", edited, changes[], flagged[]}.`

const at = [
  ['agent-teams-orchestrator', '100점 패턴 스코어링·5패턴 자동선택·4-Block spawn 템플릿'],
  ['agent-teams-deep-analysis', '읽기전용 심층분석 Lead+3TM 병렬 분업·데이터 디렉토리 계약'],
  ['agent-teams-feature-dev', '인터페이스-먼저 계약·FE/BE 병렬 구현 파이프라인'],
  ['agent-teams-reactive-dev', 'Observer-Worker 폐쇄 검증 루프(고유 신규 패턴)'],
]

const tasks = []
for (const [k, u] of at) tasks.push(() => agent(ALIGN(k, u), { schema: RES, label: `align:${k}`, phase: 'Consolidate' }))

// ---- P2.2: uiux-audit → design-audit alias (superset 확인됨) ----
tasks.push(() => agent(
  `파일: ${JH}/playwright-uiux-audit/SKILL.md 을 편집하라. playwright-design-audit(450항목/24카테고리)이 이 스킬(360항목)을 명시적으로 통합 커버함이 확인됨. **frontmatter는 유지**(트리거 보존)하되, 본문 상단에 아래 안내를 추가하고 이후 본문은 "상세는 design-audit 참조"로 정리:\n"## ⚠️ 통합됨 → playwright-design-audit\n이 스킬은 playwright-design-audit(24카테고리 A–V, ~450항목 superset)으로 **통합**되었다. UI/UX 감사는 design-audit을 사용하라. 이 문서는 호환 진입점으로 유지되며, 실제 감사 로직·체크리스트는 design-audit이 정본이다."\n본문의 방대한 중복 체크리스트를 대량 삭제하진 말고(안전), 상단 안내 + 각 주요 섹션에 "→ design-audit 정본" 한 줄 정도만. frontmatter 보존. 반환: {target:"playwright-uiux-audit", edited, changes[], flagged[]}.`,
  { schema: RES, label: 'alias:uiux-audit', phase: 'Consolidate' }))

// ---- P2.3: think 라우팅 (think-lite 앵커, 삭제 없음) ----
tasks.push(() => agent(
  `파일: ${JH}/think-lite/SKILL.md 을 편집하라. think 계열 라우팅을 명확화하는 절을 **추가**(삭제 금지):\n"## think 계열 라우팅\n- **think-lite(이 스킬) = 적응형 기본** — Cynefin 1단계 분류로 깊이 자동 조절.\n- **think-full · cynefin · deep-analysis-mode · first-principles · ooda = 고비용 명시호출 전용** — 사용자가 그 스킬을 직접 부를 때만. 자동 추천 금지(네이티브 적응형 사고·plan-first와 중복 방지)."\nfrontmatter·기존 내용 보존. 반환: {target:"think-lite", edited, changes[], flagged[]}.`,
  { schema: RES, label: 'route:think', phase: 'Consolidate' }))

const results = await parallel(tasks)
return { results: results.filter(Boolean) }
