# draw-ascii · gallery

Full glyph reference and a gallery of grid-aligned diagram patterns. Every block is
single-width, so the columns line up character-for-character — check by eye. Companion to
[SKILL.md](../SKILL.md) — read that first for the core principles (the one rule, the weight
hierarchy, the self-check).

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

## Fit — the right shape carries the idea

The gallery above is *how to draw cleanly*. This is *what to draw*. Same concept, right form
vs wrong — the test isn't "is it aligned," it's "does the form do the explaining."

**A protocol is about *ordering* → a sequence, not a box.** A static box shows the two actors
but hides who waits when; the sequence puts time down the page and the *why* on the wire:
```
 A            B
 │  lock?     │
 ├───────────▶│  ● B holds it
 │ (blocked)  │  "not my turn yet"
 │◀───────────┤  ○ B releases
 │  acquired  │
 ▼            ▼
```

**Backoff is about *growing gaps* → a timeline, not a table.** A `{attempt, delay}` table has
every number and hides the point; on a timeline the spacing itself doubles, so the eye sees it:
```
try ●   ●    ●       ●           ●
    1s  2s   4s      8s          16s
    └───┴────┴───────┴───────────┘  gaps double
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

## Recurring shapes — templates for the moments you hit most

Grounded in how this setup is actually used across sessions — **research**, **debugging**, and
**mapping a repo** are the top task types. Adapt the content; keep the shape, so the same kind of
answer always reads the same way. (Examples below are filled from real past sessions.)

**Research → verdict** — fan out across sources, reconvene, recommend:
```
research · how often to autosave tmux (resurrect) without thrash

  local    past sessions · current tmux.conf          ┐
  docs     tmux-resurrect + continuum README          ├  parallel · fresh context
  online   HN · GitHub issues · dotfile repos         ┘
              │ synthesize
              ▼
  ▶ A  continuum @ 15 min   ★ pick — resurrect default, no disk churn
    B  save on exit only    loses state on a crash
    C  every 1 min          SSD thrash, marginal gain
```

**Debug → root cause** — symptom · what changed · suspects ruled out · fix + verify:
```
debug · sketchybar hangs after the cascade animation finishes

  symptom   ● items stop updating; bar frozen after cascade
  changed   last: added cascade animation to sketchybarrc
  suspects  ┌ event provider     ✗ still emitting
            ├ animation queue     ● never drains — root cause
            └ shell plugin        ✗ returns fine
  fix       cap animation duration  →  verify: bar resumes ✓
```

**Map a system** — the modules and how they connect (for "read repo X and map it"):
```
map · a CLI's data flow

╭─ modules · what calls what ────────────────╮
│ entry      ─▶   core        ─▶   output    │
│ cli.ts          engine.ts        render.ts │
│                   │ uses                   │
│                   ▼                        │
│ deps ·  parser  ·  cache  ·  logger        │
╰────────────────────────────────────────────╯
```

---

## Most-loved data visualizations — what to steal

The greatest visualizations ever made are not charts — they're *arguments made in ink*. Each one
carries a lesson a text diagram can use.

Minard's own argument — Napoleon's army melting from 422k to 10k — survives translation to text as
a funnel, because the shrinking *is* the point (width ∝ survivors, eighth-blocks for the tail):
```
Napoleon's 1812 army, melting east then back — after Minard

Niemen  ·start  ██████████████████████████████  422k
Smolensk        ██████████▎                     145k  -9°C
Moscow  ·turn   ███████▏                        100k
Smolensk ·ret   ██▋                              37k  -21°C
Berezina        ██                               28k  -30°C
Vilnius         ▉                                12k
Niemen  ·end    ▊                                10k  -25°C
```

Each classic teaches a lesson a text diagram can use:

- **Playfair's charts (1786) and Priestley's timeline (1765)** — the founders: Playfair invented the line, bar, and pie; Priestley first put lives on a time axis. *Most forms you reach for were someone's invention.*
- **Minard's *Napoleon's March* (1869)** — six variables in one flow (army size, position, direction, temperature). *Layout can hold several dimensions at once* — and when text can't do the flow map, a funnel like the one above carries the same gut-punch.
- **John Snow's cholera map (1854)** — plotted deaths on a street map and found the pump. *Position is an axis; put data where it happened.*
- **Nightingale's coxcomb (1858)** and **Du Bois' data portraits (1900)** — persuasion by design; the shape itself argues. *Form can carry the point, not just the number.*
- **Beck's London Tube map (1933)** — threw away geography for topology. *Draw the mental model, not the literal thing* — the reason sequence and state diagrams work.
- **Rosling's Gapminder bubbles** and **Hawkins' warming stripes (2018)** — one moving idea, near-zero chartjunk. *Strip to the single trend.*
- **The periodic table (1869)** — arguably the greatest ever: a grid whose *gaps predicted undiscovered elements*. *A good grid reveals what's missing.*

What the r/dataisbeautiful crowd rewards (top-of-all-time, pulled live): **personal-data stories**
(one person's travels, not a dataset), **change animated over time** (bar-chart races), and **one
surprising comparison** (light speed is *slow*; wildfire smoke drawn over a familiar map). Text can't
animate — so lean on the **sparkline**, the **small multiple**, and a single punchy contrast to get
the same effect statically.

The full study list — marvels, books, blogs, and chart-choosers to look them up in — lives in
[dataviz-canon.md](dataviz-canon.md).

---

*Every block is single-width and grid-aligned — verify by eye: each border column lines up top to bottom.*
