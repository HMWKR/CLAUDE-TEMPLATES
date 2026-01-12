# CLAUDE-TEMPLATES

Claude Code CLI 협업을 위한 마스터 템플릿 저장소

## 이 저장소는?

새 프로젝트에 Claude Code 협업 환경을 빠르게 구축하기 위한 템플릿 모음입니다.

## 포함 파일

| 파일 | 용도 |
|------|------|
| `CLAUDE_TEMPLATE.md` | CLAUDE.md 전체 템플릿 (19개 섹션) |
| `CLAUDE_UNIVERSAL_RULES.md` | 공통 규칙 (섹션 9-19) |
| `PROJECT_SETUP_CHECKLIST.md` | 새 프로젝트 설정 체크리스트 |
| `CONVERSATION_PROMPTS.md` | Claude 대화 프롬프트 패턴 모음 |
| `커밋메시지-16섹션-설정가이드.md` | 16개 섹션 커밋 검증 시스템 가이드 |

## 핵심 기능

1. **16개 섹션 커밋 메시지 검증** - Husky + Commitlint 자동화
2. **환각 방지 프로토콜** - Read Before Write
3. **Ultrathink 8단계 워크플로우** - 체계적 문제 해결
4. **5계층 48점 프롬프트 품질 평가** - 객관적 품질 측정

## 사용법

```bash
# 1. 템플릿 복사
cp CLAUDE_TEMPLATE.md /path/to/new-project/CLAUDE.md

# 2. 커밋 검증 시스템 설치 (선택)
npm install -D husky @commitlint/cli @commitlint/config-conventional
npx husky init
```

상세 가이드: `PROJECT_SETUP_CHECKLIST.md` 참고

## 라이선스

MIT
