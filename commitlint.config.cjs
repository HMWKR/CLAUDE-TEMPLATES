/**
 * Commitlint 설정 - 16개 필수 섹션 검증
 *
 * 5계층 48점 프롬프트 품질 검수 시스템 포함
 */
module.exports = {
  extends: ['@commitlint/config-conventional'],

  parserPreset: {
    parserOpts: {
      headerPattern: /^(\w+)(?:\((.+)\))?:\s(.+)$/,
      headerCorrespondence: ['type', 'scope', 'subject'],
    },
  },

  rules: {
    // 타입 규칙
    'type-enum': [
      2,
      'always',
      [
        'feat',     // 새 기능
        'fix',      // 버그 수정
        'docs',     // 문서 변경
        'style',    // 코드 포맷팅
        'refactor', // 리팩토링
        'perf',     // 성능 개선
        'test',     // 테스트 추가/수정
        'chore',    // 빌드/설정 변경
        'ci',       // CI 설정
        'revert',   // 커밋 되돌리기
        'build',    // 빌드 시스템
      ],
    ],
    'type-case': [2, 'always', 'lower-case'],
    'type-empty': [2, 'never'],

    // 제목 규칙
    'subject-empty': [2, 'never'],
    'subject-max-length': [1, 'always', 100],

    // 본문 규칙
    'body-max-line-length': [0, 'always', Infinity],
    'footer-max-line-length': [0, 'always', Infinity],
  },

  plugins: [
    {
      rules: {
        /**
         * 16개 필수 섹션 검증 규칙
         *
         * 필수 섹션:
         * 1. [type]: 헤더
         * 2. ## 산출물
         * 3. ## 변경 영향도
         * 4. ## 테스트 전략
         * 5. ## 롤백 계획
         * 6. ## 관련 이슈
         * 7. ## Breaking Changes
         * 8. ## 성능 벤치마크
         * 9. ## 아키텍처 다이어그램
         * 10. ## UI/UX 와이어프레임
         * 11. ## 사고 여정
         * 12. ### 원본 프롬프트
         * 13. ### 프롬프트 분석
         * 14. ### 최적화된 프롬프트
         * 15. ## 프롬프트 품질 검수
         * 16. Co-Authored-By:
         */
        'require-16-sections': ({ raw }) => {
          const requiredSections = [
            { pattern: /^## 산출물/m, name: '산출물' },
            { pattern: /^## 변경 영향도/m, name: '변경 영향도' },
            { pattern: /^## 테스트 전략/m, name: '테스트 전략' },
            { pattern: /^## 롤백 계획/m, name: '롤백 계획' },
            { pattern: /^## 관련 이슈/m, name: '관련 이슈' },
            { pattern: /^## Breaking Changes/m, name: 'Breaking Changes' },
            { pattern: /^## 성능 벤치마크/m, name: '성능 벤치마크' },
            { pattern: /^## 아키텍처 다이어그램/m, name: '아키텍처 다이어그램' },
            { pattern: /^## UI\/UX 와이어프레임/m, name: 'UI/UX 와이어프레임' },
            { pattern: /^## 사고 여정/m, name: '사고 여정' },
            { pattern: /^### 원본 프롬프트/m, name: '원본 프롬프트' },
            { pattern: /^### 프롬프트 분석/m, name: '프롬프트 분석' },
            { pattern: /^### 최적화된 프롬프트/m, name: '최적화된 프롬프트' },
            { pattern: /^## 프롬프트 품질 검수/m, name: '프롬프트 품질 검수' },
            { pattern: /Co-Authored-By:/m, name: 'Co-Authored-By' },
          ];

          const missingSections = requiredSections
            .filter(({ pattern }) => !pattern.test(raw))
            .map(({ name }) => name);

          if (missingSections.length > 0) {
            return [
              false,
              `\n\n❌ 필수 섹션 누락 (${missingSections.length}개):\n` +
              missingSections.map(s => `   - ${s}`).join('\n') +
              '\n\n💡 .gitmessage 템플릿을 사용하세요: git commit (템플릿 자동 적용)\n'
            ];
          }

          return [true, ''];
        },

        /**
         * 사고 여정 6단계 검증
         */
        'require-thinking-journey': ({ raw }) => {
          if (!raw.includes('## 사고 여정')) {
            return [true, '']; // 사고 여정 섹션 자체가 없으면 위 규칙에서 처리
          }

          const journeySteps = [
            { pattern: /### 1\. 문제 인식/m, name: '1. 문제 인식' },
            { pattern: /### 2\. 탐색 경로/m, name: '2. 탐색 경로' },
            { pattern: /### 3\. 고려한 대안들/m, name: '3. 고려한 대안들' },
            { pattern: /### 4\. 결정 근거/m, name: '4. 결정 근거' },
            { pattern: /### 5\. 구현 타임라인/m, name: '5. 구현 타임라인' },
            { pattern: /### 6\. 핵심 통찰/m, name: '6. 핵심 통찰' },
          ];

          const missingSteps = journeySteps
            .filter(({ pattern }) => !pattern.test(raw))
            .map(({ name }) => name);

          if (missingSteps.length > 0) {
            return [
              false,
              `\n\n❌ 사고 여정 단계 누락 (${missingSteps.length}개):\n` +
              missingSteps.map(s => `   - ${s}`).join('\n') +
              '\n\n💡 스토리텔링 형식으로 Claude의 사고 과정을 기록하세요.\n'
            ];
          }

          return [true, ''];
        },

        /**
         * 프롬프트 품질 검수 섹션 검증 (5계층 48점)
         */
        'require-prompt-quality': ({ raw }) => {
          if (!raw.includes('## 프롬프트 품질 검수')) {
            return [true, '']; // 섹션 자체가 없으면 위 규칙에서 처리
          }

          const qualityChecks = [
            { pattern: /계층 1.*구조적 완성도/m, name: '계층 1: 구조적 완성도 (18점)' },
            { pattern: /계층 2.*엔지니어링 기법/m, name: '계층 2: 엔지니어링 기법 (8점)' },
            { pattern: /계층 3.*맥락 최적화/m, name: '계층 3: 맥락 최적화 (6점)' },
            { pattern: /계층 4.*효과 검증/m, name: '계층 4: 효과 검증 (4점)' },
            { pattern: /계층 5.*할루시네이션 검증/m, name: '계층 5: 할루시네이션 검증 (12점)' },
            { pattern: /최종 평가|총점.*\/48/m, name: '최종 평가 (총점/48)' },
          ];

          const missingChecks = qualityChecks
            .filter(({ pattern }) => !pattern.test(raw))
            .map(({ name }) => name);

          if (missingChecks.length > 0) {
            return [
              false,
              `\n\n❌ 프롬프트 품질 검수 항목 누락 (${missingChecks.length}개):\n` +
              missingChecks.map(s => `   - ${s}`).join('\n') +
              '\n\n💡 5계층 48점 평가 시스템을 사용하세요.\n'
            ];
          }

          return [true, ''];
        },
      },
    },
  ],

  // 커스텀 규칙 적용
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'chore', 'ci', 'revert', 'build'],
    ],
    'type-case': [2, 'always', 'lower-case'],
    'type-empty': [2, 'never'],
    'subject-empty': [2, 'never'],
    'subject-case': [0], // 한국어 커밋 메시지 허용
    'body-max-line-length': [0, 'always', Infinity],
    'footer-max-line-length': [0, 'always', Infinity],
    'require-16-sections': [2, 'always'],
    'require-thinking-journey': [2, 'always'],
    'require-prompt-quality': [2, 'always'],
  },
};
