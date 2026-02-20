/**
 * Commitlint 설정 - 4개 필수 섹션 검증 (CE v2.0)
 *
 * 기존 16개 섹션에서 핵심 4개로 간소화.
 * AI 사고 여정은 .thoughts/ 파일로 분리.
 */
module.exports = {
  extends: ['@commitlint/config-conventional'],

  parserPreset: {
    parserOpts: {
      headerPattern: /^(\w+)(?:\((.+)\))?:\s(.+)$/,
      headerCorrespondence: ['type', 'scope', 'subject'],
    },
  },

  plugins: [
    {
      rules: {
        /**
         * 4개 필수 섹션 검증
         *
         * 1. ## What — 변경 사항
         * 2. ## Why — 변경 이유
         * 3. ## Impact — 영향 범위
         * 4. Co-Authored-By: — AI 협업 표시
         */
        'require-4-sections': ({ raw }) => {
          const requiredSections = [
            { pattern: /^## What/m, name: 'What (변경 사항)' },
            { pattern: /^## Why/m, name: 'Why (변경 이유)' },
            { pattern: /^## Impact/m, name: 'Impact (영향 범위)' },
            { pattern: /Co-Authored-By:/m, name: 'Co-Authored-By' },
          ];

          const missingSections = requiredSections
            .filter(({ pattern }) => !pattern.test(raw))
            .map(({ name }) => name);

          if (missingSections.length > 0) {
            return [
              false,
              `\n\n필수 섹션 누락 (${missingSections.length}개):\n` +
              missingSections.map(s => `   - ${s}`).join('\n') +
              '\n\n.gitmessage 템플릿을 사용하세요: git commit\n'
            ];
          }

          return [true, ''];
        },
      },
    },
  ],

  rules: {
    'type-enum': [
      2, 'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'chore', 'ci', 'revert', 'build'],
    ],
    'type-case': [2, 'always', 'lower-case'],
    'type-empty': [2, 'never'],
    'subject-empty': [2, 'never'],
    'subject-case': [0],
    'body-max-line-length': [0, 'always', Infinity],
    'footer-max-line-length': [0, 'always', Infinity],
    'require-4-sections': [2, 'always'],
  },
};
