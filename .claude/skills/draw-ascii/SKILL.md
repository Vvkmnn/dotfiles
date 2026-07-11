---
name: draw-ascii
description: Use when the user asks to visualize, diagram, draw, sketch, chart, map,
  or "show me" a concept, flow, pipeline, architecture, hierarchy, tree, sequence,
  timeline, state machine, or relationship — or when an explanation would land
  better as a picture than prose. Covers flowcharts, dependency graphs, directory
  trees, box-and-arrow architecture, sequence/interaction diagrams, tables, bar/meter
  charts, sparklines, timelines, state machines, dashboards, and mind-maps, rendered
  as clean grid-aligned Unicode (or ASCII-fallback) text art. Also triggers on
  "ascii diagram", "box drawing", "explain this visually". Not for image/SVG
  generation or real charting libraries.
author: Vvkmnn
version: 1.0.0
user-invocable: true
argument-hint: "[concept or diagram-type to visualize]"
---

Draws crisp, consistent, grid-aligned text diagrams — rounded boxes, clean lines, one coherent system per picture. Best-in-class ASCII/Unicode, every time.

## When to Use

- **Explicit ask** — "visualize", "draw", "diagram", "sketch", "chart", "show me", "map out", "explain this visually".
- **Proactive (offer, don't force)** — when explaining a flow, architecture, hierarchy, sequence, state machine, or set of relationships where a picture beats a paragraph. One good diagram, then prose around it.
- **Skip it** — trivial one-line answers, single facts, or where a sentence is already clearer. Don't decorate.

Audience is usually **Claude → human** (explaining to you) or **docs**. These render in the terminal and in markdown, so Unicode is safe. Always put a diagram in a fenced code block so markdown won't reflow it.

## The One Rule

**A diagram is a grid of equal-width cells.** ~90% of "beautiful" is alignment; 10% is glyph choice. Every glyph must sit in the cell the reader's eye expects. Break the grid — one double-width emoji, one stray space, one mismatched corner — and the whole thing reads as broken.

## Core Principles

- **Weight carries meaning — hold it consistently.** Don't mix line weights at random (`┌───┒` is the ugliest, commonest failure). Mix them only *by rule* — see the house hierarchy below.
- **Rounded + light is the signature look** (`╭╮╰╯ ─ │`) for cards, single nodes, and soft flows. Square `┌┐└┘` for junction-heavy grids and tables (rounded corners can't form `├ ┼ ┤`).
- **Never put emoji / CJK / combining chars inside the grid.** They're double-width and shift every following cell, destroying the right border. Use single-width status marks — `● ○ ◐ ◆ ◇ ✓ ✗ ★` — inside diagrams; leave emoji in prose.
- **One space of interior padding:** `│ Label │`, never `│Label│`. Keep it symmetric when centering (bias the extra space right).
- **Equal-width siblings, shared baselines.** Size every box in a row to the longest label + 2; align their tops and bottoms.
- **Real junction glyphs at every crossing** — `┼ ├ ┤ ┬ ┴` (or `╬ ╠ ╣ ╦ ╩` for double). Never butt-join a line into another (`──│`).
- **One arrow family per diagram.** Default to the triangle family `▶ ◀ ▲ ▼` with `──▶` connectors (matches the terminal look); or the light family `→ ← ↑ ↓` / `─►`. Pick one, don't blend.
- **Width budget ≤ 80 columns** (hard stop 100). Too wide → stack vertically or split into two diagrams.
- **No trailing whitespace.** It's invisible misalignment and dirty diffs. Strip it.
- **ASCII fallback** (`+ - |`, `-->`) only when the target is ASCII-only. Then commit fully — never leave one lone Unicode corner in an ASCII drawing.

## The House Weight Hierarchy

Encode nesting depth with weight — this is the signature system, not random mixing:

| Weight | Glyphs | Use for |
|--------|--------|---------|
| **Double** | `╔═╗ ║ ╚╝` | Outermost container · trust/framework boundary · top-level layer |
| **Square (light)** | `┌─┐ │ └┘` | Components · panels · table grids · anything with internal junctions |
| **Rounded (light)** | `╭─╮ │ ╰╯` | Soft sub-components · cards · single highlighted nodes · titled panels |

Separators inside a frame: `═══` between framework-level layers, `───` between inner partitions. Titles ride the top border: `╭─ Title · subtitle ──────╮`, breadcrumbs use `›` or `·` (`USE CASE › THREATS › RISKS`).

## Quick Glyph Reference

| Role | Glyphs |
|------|--------|
| Light lines / corners | `─ │` · `┌ ┐ └ ┘` · rounded `╭ ╮ ╰ ╯` |
| Light junctions | `├ ┤ ┬ ┴ ┼` |
| Double (containers) | `═ ║` · `╔ ╗ ╚ ╝` · `╠ ╣ ╦ ╩ ╬` · single↔double `╤ ╧ ╪ ╫` |
| Heavy (emphasis path) | `━ ┃` · `┏ ┓ ┗ ┛` · `┣ ┫ ┳ ┻ ╋` |
| Arrows (triangle) | `▶ ◀ ▲ ▼` · connector `──▶` |
| Arrows (light) | `→ ← ↑ ↓ ↔` · `─►` |
| Status / nodes | `● ○ ◐ ◆ ◇ ■ □ ✓ ✗ ★ ·` |
| Bars / fill (eighths) | `█ ▉ ▊ ▋ ▌ ▍ ▎ ▏` · shades `▓ ▒ ░` |
| Sparkline (eighths) | `▁ ▂ ▃ ▄ ▅ ▆ ▇ █` |
| Dashed | `╌ ╎` · `┄ ┆` · `┈ ┊` |

Full tables (heavy/double transitions, all blocks, accents) live in the gallery.

## Canonical Examples

**Flow / pipeline** — rounded+light, one arrow family, a branch that drops orthogonally:
```
╭─────────╮      ╭──────────╮      ╭──────────╮
│ Request │ ───▶ │   Auth   │ ───▶ │ Database │
╰─────────╯      ╰────┬─────╯      ╰──────────╯
                      │ 401 if invalid
                      ▼
                 ╭─────────╮
                 │ Reject  │
                 ╰─────────╯
```

**Directory tree** — `├──` for every child, `└──` for the last; `│` continues only while siblings remain below:
```
draw-ascii/
├── SKILL.md
├── references/
│   └── gallery.md
└── scripts/
    └── lint.py
```

**Layered architecture** — the house weight hierarchy: double outer container, square components, rounded cache card:
```
╔════════════════════════════════════════╗
║  Gateway                               ║
║                                        ║
║   ┌──────────┐        ┌──────────┐     ║
║   │   API    │ ─────▶ │ Service  │     ║
║   └──────────┘        └────┬─────┘     ║
║                            │           ║
║                            ▼           ║
║                       ╭──────────╮     ║
║                       │  Cache   │     ║
║                       ╰──────────╯     ║
╚════════════════════════════════════════╝
```

**Status dashboard** — titled rounded card, aligned columns, single-width status glyphs, block meters:
```
╭─ fleet · 3 machines ────────────────────────╮
│ ● mini  AC     82%  ██████████░░   cool     │
│ ● air   batt   64%  ███████░░░░░   cool     │
│ ○ neo   asleep      ░░░░░░░░░░░░   —        │
╰─────────────────────────────────────────────╯
```

## Pre-Emit Self-Check

Before showing any diagram, verify:

1. One weight system, applied by rule (not mixed at random)?
2. Zero emoji / CJK / combining chars inside the grid?
3. All sibling boxes equal width; tops and bottoms aligned?
4. One space of interior padding everywhere?
5. Real junction glyphs at every crossing?
6. One arrow family throughout?
7. ≤ 80 columns wide?
8. No trailing whitespace?
9. Wrapped in a fenced code block?
10. Would it survive a paste into a git commit or a narrow tmux pane?

For a hard check, run the bundled linter — it flags double-width glyphs, trailing whitespace, and ragged frames:
```
pbpaste | python3 scripts/lint.py -      # check a diagram you're about to send
python3 scripts/lint.py SKILL.md         # check diagrams in a markdown file
```

## Common Mistakes → Fixes

| Mistake | Why it's ugly | Fix |
|---------|---------------|-----|
| Emoji inside a box (`│ ✅ ok │`) | Double-width shifts the right border | Single-width `✓ ● ○`; emoji in prose |
| Weights mixed at random (`┌───┒`) | Corners don't connect | One system; nest by the house hierarchy |
| Butt-joined lines (`──│`) | Gaps/overlaps at crossings | `┼ ├ ┤ ┬ ┴` at every crossing |
| Ragged box widths in a row | No shared baseline | Size all siblings to longest label + 2 |
| No interior padding (`│Label│`) | Text kisses the border | `│ Label │` |
| Fake dashes (`─ ─ ─`) | Ragged, uneven gaps | Real dashed glyph `╌ ┄`, or a solid rule |
| Mixed arrows (`→` + `▶` + `-->`) | Reads as three diagrams | One arrow family |
| Double-encoding (`● healthy [UP]`) | Redundant, crowded | One signal — the glyph *or* the label |
| Too wide (> 100 cols) | Wraps to confetti in narrow panes | Cap ~80; stack or split |
| Diagonal arrows on a grid (`↗↘`) | Can't land on cell centers | Route orthogonally: `│ ─` + a corner |

---

See [references/gallery.md](references/gallery.md) for the full glyph tables and a gallery of nine polished diagram types (sequence, table, bar chart, timeline, state machine, mind-map, multi-panel dashboard, and more).
