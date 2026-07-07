#!/usr/bin/env python3
"""settings.reference.json을 대상 settings.json에 딥머지한다 (install.sh/install.ps1 공용 정본).

정책:
  mode=replace : reference 우선(스칼라 충돌 시 reference 채택). 리스트는 union, user-only 키 보존.
  mode=merge   : user 우선(기존 값 절대 안 덮음, 없는 키만 추가). 리스트는 union.
두 모드 모두 리스트는 union(dedupe, 기존 순서 우선 + 신규 뒤에 append)이라 사용자 항목을
잃지 않는다. hooks 같은 객체 배열도 union이므로, 사용자가 다른 훅을 이미 가졌다면 중복
append될 수 있다(동일 항목은 스킵). 완전 동일 스냅샷(재설치)에서는 멱등(no-op).

사용: merge-settings.py <reference.json> <target.json> <mode> [<output.json>]
  output 미지정 시 target에 in-place. target 부재 시 reference를 그대로 복사.
출력 JSON을 재파싱해 유효성을 보장한다(실패 시 비정상 종료 → 호출측 installer가 롤백).
"""
import json
import sys


def deep_merge(ref, cur, mode):
    if isinstance(ref, dict) and isinstance(cur, dict):
        out = dict(cur)
        for k, v in ref.items():
            out[k] = deep_merge(v, out[k], mode) if k in out else v
        return out
    if isinstance(ref, list) and isinstance(cur, list):
        out = list(cur)
        for item in ref:
            if item not in out:
                out.append(item)
        return out
    # 스칼라 또는 타입 불일치: 모드 정책 적용
    return ref if mode == "replace" else cur


def main():
    if len(sys.argv) < 4 or sys.argv[3] not in ("merge", "replace"):
        print("usage: merge-settings.py <reference.json> <target.json> <merge|replace> [<output.json>]", file=sys.stderr)
        return 2
    ref_p, tgt_p, mode = sys.argv[1], sys.argv[2], sys.argv[3]
    out_p = sys.argv[4] if len(sys.argv) > 4 else tgt_p

    with open(ref_p, encoding="utf-8") as f:
        ref = json.load(f)
    try:
        with open(tgt_p, encoding="utf-8") as f:
            cur = json.load(f)
    except FileNotFoundError:
        cur = None

    merged = ref if cur is None else deep_merge(ref, cur, mode)
    text = json.dumps(merged, ensure_ascii=False, indent=2)
    json.loads(text)  # 재파싱 검증 — 깨지면 예외로 비정상 종료
    with open(out_p, "w", encoding="utf-8") as f:
        f.write(text + "\n")
    print(f"settings merged (mode={mode}, base={'new' if cur is None else 'existing'}) -> {out_p}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
