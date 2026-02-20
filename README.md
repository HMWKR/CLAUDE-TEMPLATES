# CLAUDE-TEMPLATES

Claude Code CLI 협업을 위한 마스터 템플릿 저장소 (CE v2.0)

## 이 저장소는?

새 프로젝트에 Claude Code 협업 환경을 빠르게 구축하기 위한 템플릿 모음입니다.
**Context Engineering(CE) v2.0** 원칙에 기반하여 최소 토큰으로 최대 효과를 달성합니다.

## 원클릭 설정

```bash
curl -sL https://raw.githubusercontent.com/HMWKR/CLAUDE-TEMPLATES/main/init-project.sh | bash
```

**자동으로 수행되는 작업:**
- CLAUDE.md 템플릿 다운로드 (프로젝트 고유 섹션 1-8 + 글로벌 참조)
- 4섹션 커밋 검증 시스템 설치 (commitlint + husky)
- CE 사고 여정 폴더 생성 (`.thoughts/`)
- 프롬프트 추출 스크립트 다운로드 (`extract-local-prompts.js` v4.0)
- GitHub Actions 워크플로우 생성 (`sync-prompts.yml`)

## 포함 파일

| 파일 | 용도 |
|------|------|
| `init-project.sh` | 원클릭 자동 설정 스크립트 |
| `CLAUDE_TEMPLATE.md` | CLAUDE.md 템플릿 (섹션 1-8 TODO + 글로벌 참조) |
| `commitlint.config.cjs` | 4개 필수 섹션 검증 규칙 |
| `.gitmessage` | 커밋 메시지 템플릿 (What/Why/Impact) |
| `scripts/extract-local-prompts.js` | 프롬프트 + CE 사고여정 추출 v4.0 |
| `scripts/create-thinking-log.js` | CE 사고 여정 템플릿 생성 |
| `scripts/validate-journals.js` | 저널 + 사고여정 검증 v2.0 |
| `.thoughts/` | CE 사고 여정 저장 폴더 |
| `.github/workflows/sync-prompts.yml` | 푸시 시 자동 추출 및 gh-pages 배포 |

## 핵심 기능

### 1. 4섹션 커밋 메시지 검증

```
[type]: [한 줄 요약]

## What        ← 변경 사항
## Why         ← 변경 이유
## Impact      ← 영향 범위 + 위험도

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 2. CE 사고 여정 (.thoughts/)

Claude가 작업 완료 시 `.thoughts/YYYY-MM-DD-{subject}.md`에 기록:
- 컨텍스트 수집/선택/폐기 과정
- 4대 실패 모드 감지 (Poisoning/Distraction/Confusion/Clash)
- 적용된 CE 전략 (Write/Select/Compress/Isolate)
- 대안 비교 및 결정 근거

### 3. 글로벌 + 프로젝트 분리 구조

```
~/.claude/CLAUDE.md          ← 공통 규칙 (72줄, ~700 토큰)
프로젝트/CLAUDE.md           ← 프로젝트 고유 정보 (섹션 1-8)
                               + "글로벌 참조" 1줄
```

> CE 원칙: 중복 제거 → 세션당 ~12,000 토큰 절감

## CE v2.0 원칙

| 원칙 | 이 저장소에서의 적용 |
|:----:|---------------------|
| **Right Altitude** | CLAUDE.md가 과도하지도 모호하지도 않은 적정 수준 |
| **Compress** | 글로벌 72줄로 핵심만 유지 |
| **Select** | 프로젝트 CLAUDE.md에서 글로벌 중복 100% 제거 |
| **Isolate** | .thoughts/를 커밋과 분리하여 독립 컨텍스트 |

## 라이선스

MIT
