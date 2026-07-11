# draw-ascii · gallery

Full glyph reference and a gallery of grid-aligned diagram patterns. Every diagram
here is verified by `scripts/lint.py`. Companion to [SKILL.md](../SKILL.md) — read
that first for the core principles (the one rule, the weight hierarchy, the self-check).

---

## Complete glyph tables

### Light box drawing — the default (~90% of diagrams)
| Role | Glyphs |
|------|--------|
| Lines | `─` `│` |
| Corners (square) | `┌` `┐` `└` `┘` |
| Corners (rounded) | `╭` `╮` `╰` `╯` |
| T-junctions | `├` `┤` `┬` `┴` |
| Cross | `┼` |
| Dashed | `╌` `╎` · `┄` `┆` · `┈` `┊` |

### Heavy — emphasis / a single hot path (never the default)
| Role | Glyphs |
|------|--------|
| Lines | `━` `┃` |
| Corners | `┏` `┓` `┗` `┛` |
| Junctions | `┣` `┫` `┳` `┻` `╋` |
| Light↔heavy transitions | `┝` `┥` `┰` `┸` `╿` `╽` |

### Double — outermost containers / boundaries
| Role | Glyphs |
|------|--------|
| Lines | `═` `║` |
| Corners | `╔` `╗` `╚` `╝` |
| Junctions | `╠` `╣` `╦` `╩` `╬` |
| Single↔double | `╞` `╡` `╤` `╧` `╪` `╫` |

### Arrows & connectors
| Purpose | Glyphs | Note |
|---------|--------|------|
| Triangle family (default in-box) | `▶` `◀` `▲` `▼` · `──▶` | filled; renders width-1 in a Western terminal |
| Light family | `→` `←` `↑` `↓` `↔` · `─►` | the workhorses; `->` is the bulletproof ASCII form |
| Long / drawn | `⟶` `⟵` `⟷` | pair with `──` |
| Curved / return | `↪` `↩` `⤷` `⤶` | |

Avoid diagonal arrows (`↗↘↖↙`) on a grid — they can't land on cell centres. Route orthogonally.

### Blocks, shades, sparklines
| Purpose | Glyphs |
|---------|--------|
| Full / shades | `█` `▓` `▒` `░` |
| Horizontal eighths (bars) | `▏` `▎` `▍` `▌` `▋` `▊` `▉` `█` |
| Vertical eighths (sparklines) | `▁` `▂` `▃` `▄` `▅` `▆` `▇` `█` |
| Half blocks | `▌` `▐` `▀` `▄` |

The eighth-blocks give **sub-cell resolution** — a bar can end at 3/8 of a cell, which is
what makes text meters look smooth instead of chunky.

### Status / nodes / accents
`● ○ ◐ ◆ ◇ ■ □ ▪ ▫` (nodes/status) · `✓ ✗ ★ ☑ ☐` (marks) · `• · ‹ › » «` (bullets/separators)

All of the above are **single-width** — safe inside the grid. Emoji and CJK are **double-width**
and must never go inside a box.

---

## Gallery

**1 · Flow with a decision branch** — rounded+light, one arrow family, branch drops orthogonally:
```
╭─────────╮      ╭──────────╮  yes  ╭──────────╮
│ Request │ ───▶ │  Valid?  │ ────▶ │ Handler  │
╰─────────╯      ╰────┬─────╯       ╰──────────╯
                   no │
                      ▼
                 ╭─────────╮
                 │   400   │
                 ╰─────────╯
```

**2 · Tree / hierarchy** — `├──` per child, `└──` for the last; `│` continues only while siblings remain:
```
~/.claude/
├── CLAUDE.md
├── rules/
│   ├── explore.md
│   ├── verify.md
│   └── code.md
├── skills/
│   └── draw-ascii/
│       ├── SKILL.md
│       └── references/
└── plans/
```

**3 · Layered architecture** — the house weight hierarchy (double container ▸ square components ▸ rounded card):
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

**4 · Sequence / interaction** — fixed lifeline columns, solid call arrows, dashed returns:
```
Client          Server            DB
  │                │                │
  │  POST /order   │                │
  │ ──────────────▶│                │
  │                │  INSERT row    │
  │                │ ──────────────▶│
  │                │  201 created   │
  │                │◀╌╌╌╌╌╌╌╌╌╌╌╌╌╌ │
  │  200 OK        │                │
  │◀╌╌╌╌╌╌╌╌╌╌╌╌╌╌ │                │
  │                │                │
```

**5 · Table / grid** — square corners only; real junctions `┬ ┼ ┴ ├ ┤` at every crossing; columns padded to content:
```
┌───────┬───────┬──────────┐
│ Name  │ Role  │ Status   │
├───────┼───────┼──────────┤
│ alice │ admin │ active   │
│ bob   │ user  │ invited  │
│ carol │ user  │ disabled │
└───────┴───────┴──────────┘
```

**6 · Bar chart / meter** — full blocks fill, light shade track, eighth-block for the sub-cell tail:
```
CPU   █████████████████▉░░░░░░░░░░   64%
Mem   ███████████▌░░░░░░░░░░░░░░░░   41%
Disk  ████████████████████████▉░░░   89%
Net   ███▍░░░░░░░░░░░░░░░░░░░░░░░░   12%
```

**7 · Timeline** — one heavy rail carries the eye; ticks drop to dated events at even spacing:
```
2023        2024        2025        2026
 ┿━━━━━━━━━━━┿━━━━━━━━━━━┿━━━━━━━━━━━┿━━▶
 │           │           │           │
 v1.0        v2.0        v3.0        now
 launch      rewrite     GA          ●
```

**8 · State machine** — rounded nodes read as states; short labels ride above each transition arrow:
```
        start
          │
          ▼
     ╭─────────╮   submit    ╭───────────╮
     │  Draft  │ ──────────▶ │  Review   │
     ╰─────────╯             ╰─────┬─────╯
          ▲                        │ approve
          │ reject                 ▼
          │                  ╭───────────╮
          ╰───────────────── │ Published │
                             ╰───────────╯
```

**9 · Mind-map / relationships** — central node fans to leaves via `├──`/`└──`:
```
                 ┌── light   ─ │ ┌ ┐ └ ┘ ├ ┼
    ╭─────────╮  │
    │   box   │ ─┼── heavy   ━ ┃ ┏ ┓ ┗ ┛ ┣ ╋
    │ drawing │  │
    ╰─────────╯  ├── double  ═ ║ ╔ ╗ ╚ ╝ ╠ ╬
                 │
                 └── rounded ╭ ╮ ╰ ╯
```

**Signature · Multi-panel dashboard** — the house look: titled panels split by `┬ │ ┴`, single-width
status glyphs, block meters, and a sparkline. Seeded from your own fleet/eve dashboards:
```
╭─ fleet · 3 nodes ──┬─ eve · state ──────────╮
│ ● mini  AC   82%   │ queue    0 deep        │
│   ██████████░░     │ latency  480 ms        │
│ ● air   batt 64%   │ model    claude        │
│   ███████░░░░░     │ ✓ langfuse   ✓ signoz  │
│ ○ neo   asleep     │ ✓ uptime     ◇ signal  │
│                    │                        │
│ cost 24h  ▁▂▃▅▆█   │ ⏎ snapshot  ^C release │
╰────────────────────┴────────────────────────╯
```

---

## Prior art — styles worth emulating

The cleanest generators all do the same four things; copy the behaviour, not the tool:

- **Monodraw** (macOS) — the gold standard for hand-crafted output; snaps to a grid, rounded/square styles, block fills.
- **diagon** / **Graph::Easy `boxart`** — text-to-diagram generators with consistent Unicode output; good references for *generated* style.
- **svgbob** — teaches a disciplined ASCII vocabulary (`- | + . '` `/ \`) that maps cleanly to shapes.

**The four behaviours:** (1) commit to one weight system, (2) snap everything to a strict grid,
(3) pad interiors by one space, (4) use real junction glyphs — never overlapping lines.

---

*Generated and verified with `scripts/lint.py`. To regenerate, edit the diagrams and re-run the linter.*
