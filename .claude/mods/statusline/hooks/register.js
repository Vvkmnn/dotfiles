// statusline mod: one row. Claude Code always draws its prompt footer (`⏸ manual mode on · …`), and a
// status-line script can only sit above it. This mod draws the status line INTO that footer row, after
// the mode words, so there is one row. The line itself is still rendered by ~/.claude/statusline.sh:
// this mod builds the stdin payload the script expects from the mods API, runs it with the room the
// footer has left, and turns its colour codes into Text elements.
//
// Learned from midudev/better-claude (MIT), sub-meter and token-meter at commit 249f0f6 (2026-11-02):
// the PromptHint and SessionMode render sites, the footer's width accounting (padding, the mode
// label's width, the separator), session.measure as the push signal, and the test harness shape.
// Pull their updates by diffing plugins/sub-meter/hooks/register.tsx against that commit.
//
// Effort and thinking are not in the mods API, so effort comes from settings (modelSettings, then
// effortLevel) and thinking is on for the models that always think. Everything else the script shows
// comes from $.session.usage(), $.session.model(), $.session.cwd(), the pane's tmux env and git.

const FOOTER_PADDING = 4   // two columns at each end of the footer row
const MODE_LABEL = 20      // `⏵⏵ accept edits on` is the widest mode label
const SEPARATOR = 3        // the ` · ` the engine draws between the label and the hint
const REFRESH_MS = 5000
const ALWAYS_THINKING = /fable|opus-5|sonnet-5|haiku-5|opus-4-[78]/

// The script's truecolor codes, passed through as the same hex so the row keeps the Kanagawa palette
// (Text.color is a string; a theme name would recolour the glyphs to the theme's idea of a warning).
const COLORS = {
  '38;2;230;195;132': '#e6c384',  // gold: the glyphs
  '38;2;232;36;36': '#e82424',    // red: needs you
  '38;2;255;160;102': '#ffa066',  // orange: caution
  '38;2;126;156;216': '#7e9cd8',  // blue: VISUAL, an approved PR
  '38;2;114;113;105': 'dim',      // grey: draft PR
}

let runs = []          // the line as [{ text, color?, dim? }]
let lastLine = ''
let busy = false
let timer

/** Splits the script's ANSI output into styled runs; adjacent runs with one style merge. */
export function runsOf(ansi) {
  const out = []
  const re = /\x1b\[([0-9;]*)m/g
  let color, dim = false, buf = '', last = 0, m
  const flush = () => {
    if (!buf) return
    const prev = out[out.length - 1]
    if (prev && prev.color === color && prev.dim === dim) prev.text += buf
    else out.push({ text: buf, color, dim })
    buf = ''
  }
  while ((m = re.exec(ansi))) {
    buf += ansi.slice(last, m.index)
    flush()
    last = re.lastIndex
    const code = m[1]
    if (code === '0' || code === '') { color = undefined; dim = false }
    else if (code === '2') dim = true
    else if (code in COLORS) { if (COLORS[code] === 'dim') { dim = true; color = undefined } else color = COLORS[code] }
  }
  buf += ansi.slice(last)
  flush()
  return out
}

/** The stdin payload the script reads, from what the mods API knows. */
export async function payloadOf($) {
  const [usage, model, cwd, settings] = await Promise.all([
    $.session.usage(), $.session.model(), $.session.cwd(), $.settings.read().catch(() => ({})),
  ])
  const perModel = settings && settings.modelSettings && settings.modelSettings[model]
  const effort = (perModel && (perModel.effort || perModel.effortLevel)) || (settings && settings.effortLevel) || ''
  const limits = {}
  for (const l of usage.rateLimits || []) {
    if (l.kind !== 'five_hour' && l.kind !== 'seven_day') continue
    limits[l.kind] = { used_percentage: l.percentUsed, resets_at: l.resetsAt ? Math.floor(Date.parse(l.resetsAt) / 1000) : null }
  }
  return {
    model: { id: model },
    effort: { level: effort },
    thinking: { enabled: ALWAYS_THINKING.test(model) },
    cwd, workspace: { current_dir: cwd },
    cost: { total_cost_usd: (usage.cost && usage.cost.usd) || 0 },
    context_window: { used_percentage: usage.context && usage.context.percent != null ? usage.context.percent : null, context_window_size: usage.context && usage.context.window },
    rate_limits: limits,
  }
}

// What the footer last told us; the script is rerun when any of it moves.
let columns
let hint = ''        // Claude's own hint text (`-- INSERT -- (shift+tab to cycle)`, `esc to interrupt`, its pills)
let state = 'idle'   // 'draft' while you type, 'working' while Claude runs: the pane's waiting flag lies in both
let pending = false

/** Runs the script for the room the footer leaves, keeps the runs, redraws when the line changed. */
async function refresh($) {
  if (busy) { pending = true; return }   // a change during a run is not lost: one more run follows
  busy = true
  try {
    const payload = JSON.stringify(await payloadOf($))
    // Claude's hint comes first and whole; our line takes what is left after it and its separator.
    const room = Math.max(36, (columns || 120) - FOOTER_PADDING - MODE_LABEL - SEPARATOR - hint.length - (hint ? SEPARATOR : 0))
    // The script reads this pane's waiting flag through TMUX_PANE; the child must see the same pane.
    const [home, tmux, pane] = await Promise.all([$.env.get('HOME'), $.env.get('TMUX'), $.env.get('TMUX_PANE')])
    const env = { COLUMNS: String(room + 2), CLAUDE_STATUSLINE_STATE: state }
    if (tmux) env.TMUX = tmux
    if (pane) env.TMUX_PANE = pane
    const r = await $.process.run(['bash', home + '/.claude/statusline.sh'], { stdin: payload, env, timeoutMs: 3000 })
    const line = (r.stdout || '').replace(/\n$/, '')
    if (r.exitCode === 0 && line && line !== lastLine) {
      lastLine = line
      runs = runsOf(line)
      $.ui.invalidate('ui.render')
    }
  } catch { /* the previous line stays on screen */ } finally { busy = false }
  if (pending) { pending = false; await refresh($) }
}

/** Debug: with CLAUDE_STATUSLINE_DEBUG=<file> in the session's env, every render writes the hint site's props there. */
async function dump($, e) {
  const to = await $.env.get('CLAUDE_STATUSLINE_DEBUG')
  if (!to) return
  const body = JSON.stringify({ at: new Date().toISOString(), columns, state, props: e.props, line: lastLine }, null, 1)
  void $.process.run(['sh', '-c', 'cat > "$1"', 'x', to], { stdin: body }).catch(() => {})
}

export function register(on) {
  on('session.start', async ($, e, next) => {
    if (timer) timer.cancel()
    timer = $.clock.every(REFRESH_MS, () => { void refresh($) })
    void refresh($)
    return next(e)
  })
  on('session.end', ($, e, next) => {
    if (e.reason !== 'clear' && timer) { timer.cancel(); timer = undefined }
    return next(e)
  })
  // Claude pushes this the moment context or a limit moves: no waiting for the timer.
  on('session.measure', ($, e, next) => { void refresh($); return next(e) })

  // The footer's hint site. The engine's own node (`await next(e)`) is opaque and always takes a
  // whole row, so it cannot share one with us (probed 2026-11-04: our line wrapped under it at every
  // width). Instead Claude's words are drawn by us, first and dim, from the `hint` string the engine
  // hands over, which reads the drawn line in full (`-- INSERT --`, the shortcuts hint, `esc to
  // interrupt`, its pills); then ` · ` and our line.
  on('ui.render', { component: 'PromptHint' }, async ($, e, next) => {
    if (e.surface === 'vscode') return next(e)
    // A hot reload (the engine reloads a mod when its file is saved) cancels the old timer and does
    // not replay session.start, so the first render after a reload restarts it.
    if (!timer) timer = $.clock.every(REFRESH_MS, () => { void refresh($) })
    // Two parts of Claude's hint the owner does not want on the row: the vim-mode word
    // (`-- INSERT --`) and the shortcuts reminder (`(shift+tab to cycle)`). Everything else stays.
    const nextHint = ((e.props && e.props.hint) || '')
      .replace(/^-- [A-Z]+ --\s*(· )?/, '')
      .replace(/\(shift\+tab to cycle\)\s*(· )?/, '')
      .replace(/\s*·\s*$/, '')
    const nextState = e.props && e.props.isDraft ? 'draft' : e.props && e.props.isWorking ? 'working' : 'idle'
    const moved = (e.viewport && e.viewport.columns !== columns) || nextHint !== hint || nextState !== state
    if (e.viewport) columns = e.viewport.columns
    hint = nextHint
    state = nextState
    if (moved) void refresh($)
    void dump($, e)
    if (runs.length === 0) return next(e)
    const { Box, Text } = $.ui.resolve(e)
    const claude = hint ? [Text({ dimColor: true, children: [hint] }), Text({ dimColor: true, children: [' · '] })] : []
    const ours = runs.map(r => Text({ color: r.color, dimColor: r.dim || undefined, children: [r.text] }))
    return Box({ flexDirection: 'row', children: [...claude, ...ours] })
  })
  // The mode labels at the right (`focus`, `memory paused`) stay as they are.
}
