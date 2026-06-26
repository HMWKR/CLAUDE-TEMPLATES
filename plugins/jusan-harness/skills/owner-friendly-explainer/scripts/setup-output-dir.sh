#!/usr/bin/env bash
# owner-friendly-explainer 스킬 출력 디렉토리 자동 증분 헬퍼.
#
# 사용:
#   bash setup-output-dir.sh <원본_파일_절대경로>
#
# 출력 (stdout):
#   다음 N차 HTML 절대 경로 (스킬이 그대로 사용)
#
# 동작:
#   1. 원본 파일 디렉토리 추출
#   2. 그 안에 `설명/` 디렉토리 검사 (없으면 신설)
#   3. 기존 `N차/` 폴더 스캔 → 최대 N 찾기
#   4. 다음 N+1차 폴더 신설
#   5. 출력 HTML 절대 경로 echo
#
# 정책 (사장 명시 2026-05-24):
#   - 원본 파일 디렉토리 바로 밑이 아니라 `<원본>/설명/N차/` 구조
#   - N차 = 1부터 자동 증분 (재호출 시 +1)
#   - 폴더당 HTML 1개 원칙
#   - 루트 파일이면 `설명/N차/` (프로젝트 루트 기준)

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "ERROR: 원본 파일 경로 필요" >&2
    echo "사용: $0 <원본_파일_절대경로>" >&2
    exit 1
fi

SOURCE_FILE="$1"
SOURCE_DIR=$(dirname "$SOURCE_FILE")
SOURCE_BASENAME=$(basename "$SOURCE_FILE")
SOURCE_NAME_NO_EXT="${SOURCE_BASENAME%.*}"

# 원본 파일 존재 검증
if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "ERROR: 원본 파일 없음: $SOURCE_FILE" >&2
    exit 2
fi

# `설명/` 디렉토리 신설 (없으면)
EXPLAIN_DIR="${SOURCE_DIR}/설명"
mkdir -p "$EXPLAIN_DIR"

# 기존 N차 폴더 스캔 → 최대 N 찾기 (빈 폴더는 skip)
max_n=0
shopt -s nullglob
for dir in "${EXPLAIN_DIR}"/*차/; do
    [[ -d "$dir" ]] || continue
    # 빈 폴더 skip (HTML 없는 빈 N차 폴더는 재사용 가능)
    if [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
        rmdir "$dir" 2>/dev/null || true
        continue
    fi
    base=$(basename "$dir")
    n="${base%차}"
    if [[ "$n" =~ ^[0-9]+$ ]] && (( n > max_n )); then
        max_n=$n
    fi
done
shopt -u nullglob

# 다음 N+1차 폴더
next_n=$((max_n + 1))
NEXT_DIR="${EXPLAIN_DIR}/${next_n}차"
mkdir -p "$NEXT_DIR"

# 출력 HTML 절대 경로
OUTPUT_HTML="${NEXT_DIR}/${SOURCE_NAME_NO_EXT}.html"

# stdout = 출력 절대 경로 (스킬이 그대로 사용)
echo "$OUTPUT_HTML"

# stderr = 진행 로그 (디버깅용, 스크립트 출력 흐름 영향 없음)
echo "✅ owner-friendly-explainer 출력 디렉토리 준비:" >&2
echo "   원본:      $SOURCE_FILE" >&2
echo "   설명 dir:  $EXPLAIN_DIR" >&2
echo "   증분:      ${max_n}차 → ${next_n}차 (신규)" >&2
echo "   출력 HTML: $OUTPUT_HTML" >&2
