#!/usr/bin/env python3
"""Sinh lib/theme/app_colors.dart từ các CSS custom property trong bản phác thảo HTML.

Bản phác thảo trong design/ là nguồn sự thật về màu. Script này đọc khối `:root { … }`,
lấy mọi biến có giá trị là màu, rồi sinh ra một class Dart. Đổi màu = sửa HTML rồi chạy
lại script, không sửa file Dart.

Cách dùng:
    python3 tools/sync_tokens.py design/solodesk-mobile-ui.html lib/theme/app_colors.dart

Mã thoát: 0 = xong, 1 = lỗi (thiếu file đầu vào, không tìm thấy biến màu nào…).
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

# Console Windows mặc định là cp1252, không in được tiếng Việt lẫn mũi tên.
for _stream in (sys.stdout, sys.stderr):
    if hasattr(_stream, "reconfigure"):
        _stream.reconfigure(encoding="utf-8", errors="replace")

# `:root { … }` — lấy tất cả, vì bản phác thảo có thể khai báo nhiều lần.
ROOT_BLOCK = re.compile(r":root\s*\{(.*?)\}", re.DOTALL)
# `--tên: giá trị;` bên trong khối.
DECLARATION = re.compile(r"--([A-Za-z0-9_-]+)\s*:\s*([^;}]+)")
# `var(--tên)` hoặc `var(--tên, fallback)`.
VAR_REF = re.compile(r"var\(\s*--([A-Za-z0-9_-]+)\s*(?:,[^)]*)?\)")

HEX = re.compile(r"^#([0-9a-fA-F]{3,8})$")
RGB_FUNC = re.compile(
    r"^rgba?\(\s*([0-9.]+%?)\s*[,\s]\s*([0-9.]+%?)\s*[,\s]\s*([0-9.]+%?)"
    r"\s*(?:[,/]\s*([0-9.]+%?)\s*)?\)$"
)

MAX_VAR_DEPTH = 10


def die(message: str) -> None:
    print(f"sync_tokens: {message}", file=sys.stderr)
    raise SystemExit(1)


def parse_declarations(html: str) -> dict[str, str]:
    """Trả về {tên-biến: giá-trị-thô} theo thứ tự xuất hiện; khai báo sau đè lên trước."""
    tokens: dict[str, str] = {}
    for block in ROOT_BLOCK.findall(html):
        for name, value in DECLARATION.findall(block):
            tokens[name] = value.strip()
    return tokens


def resolve(value: str, tokens: dict[str, str], depth: int = 0) -> str:
    """Gỡ chuỗi var(--x) lồng nhau. Vượt quá MAX_VAR_DEPTH coi như vòng lặp, trả nguyên trạng."""
    if depth >= MAX_VAR_DEPTH:
        return value
    match = VAR_REF.search(value)
    if not match:
        return value
    target = tokens.get(match.group(1))
    if target is None:
        return value
    return resolve(VAR_REF.sub(target.strip(), value, count=1), tokens, depth + 1)


def _channel(raw: str) -> int | None:
    """'128' hoặc '50%' → 0–255."""
    try:
        number = float(raw[:-1]) * 255 / 100 if raw.endswith("%") else float(raw)
    except ValueError:
        return None
    return max(0, min(255, round(number)))


def _alpha(raw: str | None) -> int | None:
    if raw is None:
        return 255
    try:
        number = float(raw[:-1]) / 100 if raw.endswith("%") else float(raw)
    except ValueError:
        return None
    return max(0, min(255, round(number * 255)))


def to_argb(value: str) -> str | None:
    """Đổi một giá trị màu CSS thành literal 0xAARRGGBB. None nếu không phải màu."""
    value = value.strip()

    hex_match = HEX.match(value)
    if hex_match:
        digits = hex_match.group(1)
        if len(digits) in (3, 4):  # #rgb / #rgba → nhân đôi từng ký tự
            digits = "".join(c * 2 for c in digits)
        if len(digits) == 6:
            return f"0xFF{digits.upper()}"
        if len(digits) == 8:  # CSS là #rrggbbaa, Dart cần 0xAARRGGBB
            return f"0x{digits[6:8].upper()}{digits[0:6].upper()}"
        return None

    rgb_match = RGB_FUNC.match(value)
    if rgb_match:
        red, green, blue = (_channel(rgb_match.group(i)) for i in (1, 2, 3))
        alpha = _alpha(rgb_match.group(4))
        if None in (red, green, blue, alpha):
            return None
        return f"0x{alpha:02X}{red:02X}{green:02X}{blue:02X}"

    return None


def to_dart_name(css_name: str) -> str:
    """`momo-500` → `momo500`, `money_bg` → `moneyBg`. Thêm tiền tố nếu bắt đầu bằng số."""
    parts = [p for p in re.split(r"[-_]+", css_name) if p]
    if not parts:
        return ""
    head, *tail = parts
    name = head[0].lower() + head[1:] + "".join(p[:1].upper() + p[1:] for p in tail)
    return f"c{name[0].upper()}{name[1:]}" if name[0].isdigit() else name


def render(colors: list[tuple[str, str, str]], source: Path) -> str:
    """colors = [(tên Dart, literal ARGB, giá trị CSS gốc)]."""
    lines = [
        "// GENERATED — do not edit.",
        f"// Nguồn: {source.as_posix()}",
        "// Sinh bằng: python3 tools/sync_tokens.py"
        f" {source.as_posix()} lib/theme/app_colors.dart",
        "// Đổi màu bằng cách sửa bản phác thảo rồi chạy lại script.",
        "",
        "import 'package:flutter/material.dart';",
        "",
        "/// Token màu lấy thẳng từ bản phác thảo. Không viết cứng `Color(0x…)` ở nơi khác.",
        "class AppColors {",
        "  AppColors._();",
        "",
    ]
    for dart_name, argb, css_value in colors:
        lines.append(f"  /// `{css_value}`")
        lines.append(f"  static const Color {dart_name} = Color({argb});")
        lines.append("")
    if lines[-1] == "":
        lines.pop()
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        die("cách dùng: sync_tokens.py <design.html> <app_colors.dart>")

    source = Path(argv[1])
    target = Path(argv[2])

    if not source.is_file():
        die(f"không thấy bản phác thảo: {source}")

    html = source.read_text(encoding="utf-8")
    tokens = parse_declarations(html)
    if not tokens:
        die(f"không tìm thấy khối `:root {{ --… }}` nào trong {source}")

    colors: list[tuple[str, str, str]] = []
    skipped: list[str] = []
    seen: dict[str, str] = {}

    for css_name, raw_value in tokens.items():
        argb = to_argb(resolve(raw_value, tokens))
        if argb is None:
            skipped.append(css_name)
            continue
        dart_name = to_dart_name(css_name)
        if not dart_name:
            skipped.append(css_name)
            continue
        if dart_name in seen:
            die(
                f"hai biến CSS cùng sinh ra `{dart_name}`: --{seen[dart_name]} và"
                f" --{css_name}. Đổi tên một trong hai trong bản phác thảo."
            )
        seen[dart_name] = css_name
        colors.append((dart_name, argb, raw_value))

    if not colors:
        die(f"tìm thấy {len(tokens)} biến nhưng không biến nào là màu hợp lệ")

    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(render(colors, source), encoding="utf-8")

    print(f"sync_tokens: {len(colors)} màu → {target}")
    if skipped:
        print(f"sync_tokens: bỏ qua {len(skipped)} biến không phải màu: "
              + ", ".join(f"--{n}" for n in skipped[:10])
              + (" …" if len(skipped) > 10 else ""))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
