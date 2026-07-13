#!/usr/bin/env python3
"""Alignment linter for text diagrams — the grid never lies.

Checks every fenced code block in a markdown file (or a raw diagram on stdin)
for the failures that make ASCII/Unicode diagrams look broken:

  1. WIDE      a double-width glyph (emoji / CJK) inside the grid — the #1 killer
  2. TRAILING  trailing whitespace (invisible misalignment, dirty diffs)
  3. FRAME     a boxed row whose right border doesn't line up (ragged rectangle)

Ambiguous-width glyphs (▶ ● → …) are treated as width 1 — correct for a Western
monospace terminal, which is the target. Exit code is non-zero if any issue found.

Usage:
    python3 lint.py SKILL.md references/gallery.md   # lint markdown files
    pbpaste | python3 lint.py -                       # lint a raw diagram on stdin
"""
from __future__ import annotations

import sys
import unicodedata

# Corner glyphs that open / close a rectangular frame at a fixed column.
OPEN_CORNERS = "╭┌╔┏"
CLOSE_CORNERS = "╰└╚┗"
TOP_RIGHT = "╮┐╗┓"
BOT_RIGHT = "╯┘╝┛"
VERTICALS = "│║┃"


def char_width(ch: str) -> int:
    """Display columns a character occupies in a monospace terminal."""
    if unicodedata.combining(ch):
        return 0
    # East Asian Wide / Fullwidth are the genuine double-width offenders —
    # this already catches emoji like ✅ (W) while leaving ambiguous marks
    # such as ✓ ✗ ★ ● ▶ (width A) as single-width, which is how they render
    # in a Western monospace terminal.
    if unicodedata.east_asian_width(ch) in ("W", "F"):
        return 2
    # Pictographic emoji planes render double-width regardless.
    if ord(ch) >= 0x1F000:
        return 2
    return 1


def display_width(s: str) -> int:
    return sum(char_width(ch) for ch in s)


def wide_chars(line: str) -> list[str]:
    return [ch for ch in line if char_width(ch) == 2]


def indent_of(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def check_block(lines: list[str], origin: str) -> list[str]:
    """Return a list of human-readable issues for one diagram block."""
    issues: list[str] = []

    for i, line in enumerate(lines, 1):
        if line != line.rstrip():
            issues.append(f"{origin}:{i}  TRAILING whitespace")
        wide = wide_chars(line)
        if wide:
            issues.append(
                f"{origin}:{i}  WIDE double-width glyph(s) in grid: {' '.join(wide)}"
            )

    # Frame check: pair each opening corner with the next closing corner at the
    # same column, and require every row between them to share the frame's width.
    open_stack: list[tuple[int, int]] = []  # (line_index, indent_column)
    for i, line in enumerate(lines):
        stripped = line.lstrip(" ")
        if not stripped:
            continue
        col = indent_of(line)
        first = stripped[0]
        if first in OPEN_CORNERS:
            open_stack.append((i, col))
        elif first in CLOSE_CORNERS and open_stack:
            # Match the most recent open at the same indent column.
            for k in range(len(open_stack) - 1, -1, -1):
                oi, ocol = open_stack[k]
                if ocol != col:
                    continue
                top = lines[oi].rstrip()
                # A frame only if the top row is a clean box top ending in a
                # top-right corner. The box's right border must then sit at that
                # same column R on every row — content *after* R (side
                # annotations, as in mind-maps/flows) is allowed and ignored.
                if top and top[-1] in TOP_RIGHT:
                    R = len(top) - 1  # all grid glyphs are width-1 here
                    borders = VERTICALS + TOP_RIGHT + BOT_RIGHT
                    for j in range(oi, i + 1):
                        row = lines[j]
                        rls = row.lstrip(" ")
                        if not (rls and rls[0] in OPEN_CORNERS + CLOSE_CORNERS + VERTICALS):
                            continue
                        if len(row) <= R or row[R] not in borders:
                            issues.append(
                                f"{origin}:{j + 1}  FRAME right border missing at "
                                f"column {R} — box edge is ragged"
                            )
                del open_stack[k]
                break
    return issues


def blocks_from_markdown(text: str, path: str):
    """Yield (origin_label, lines) for each ``` fenced block."""
    lines = text.split("\n")
    in_block = False
    start = 0
    buf: list[str] = []
    for idx, line in enumerate(lines):
        if line.lstrip().startswith("```"):
            if in_block:
                yield (f"{path} block@L{start + 1}", buf)
                buf, in_block = [], False
            else:
                in_block, start = True, idx
            continue
        if in_block:
            buf.append(line)


def main(argv: list[str]) -> int:
    args = argv[1:]
    if not args:
        print(__doc__)
        return 2

    all_issues: list[str] = []
    if args == ["-"]:
        text = sys.stdin.read()
        all_issues += check_block(text.rstrip("\n").split("\n"), "stdin")
    else:
        for path in args:
            with open(path, encoding="utf-8") as f:
                text = f.read()
            for origin, block in blocks_from_markdown(text, path):
                all_issues += check_block(block, origin)

    if all_issues:
        print(f"✗ {len(all_issues)} issue(s):")
        for issue in all_issues:
            print(f"  {issue}")
        return 1
    print("✓ all diagrams grid-aligned")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
