#!/usr/bin/env bash
# Chạy sau mỗi lần Claude Code sửa/tạo file .dart.
# Exit 2 = chặn và đẩy stderr ngược lại cho Claude tự sửa — đây là vòng kiểm chứng.
set -uo pipefail

file=$(cat | jq -r '.tool_input.file_path // empty')
[[ "$file" == *.dart ]] || exit 0
[[ -f "$file" ]] || exit 0

dart format "$file" >/dev/null 2>&1

# Chặn màu và font viết cứng trong tầng màn hình.
if [[ "$file" == *"/lib/features/"* ]]; then
  if violations=$(grep -nE "Color\(0x|fontFamily: '" "$file"); then
    echo "Vi phạm quy tắc token trong $file:" >&2
    echo "$violations" >&2
    echo "Dùng AppColors / AppText thay vì viết cứng. Xem CLAUDE.md quy tắc 1 và 6." >&2
    exit 2
  fi
fi

if ! out=$(flutter analyze "$file" 2>&1); then
  echo "$out" >&2
  exit 2
fi
