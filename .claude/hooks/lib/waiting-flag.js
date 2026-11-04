'use strict';
/**
 * The "Claude is waiting on you" flag, in one place.
 *
 * raise(event) sets @claude_waiting=1 on THIS pane and its window; clear(event) unsets both.
 * The pane is always addressed explicitly by TMUX_PANE (claude-tmux-hop's pattern): hooks run with
 * stdin closed, and an explicit -t leaves nothing to tmux's default-target resolution. After every
 * change the status line is refreshed (tmux only repaints on its own interval otherwise).
 *
 * Every call appends one line to the flag log so a stale flag can be traced to the hook that left
 * it: `<iso-time>\t<event>\t<pane>\t<raise|clear>`. The log lives under ~/.local/state/claude
 * (regenerable, never required at boot; listed in CONFIG.md per-machine state).
 *
 * Fails open: without tmux, or on any error, it does nothing and never throws.
 * Overrides for tests: CLAUDE_TMUX_BIN (stub binary), CLAUDE_FLAG_LOG (log path).
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execFileSync } = require('child_process');

const OPTION = '@claude_waiting';
const TMUX = process.env.CLAUDE_TMUX_BIN || '/opt/homebrew/bin/tmux';
const LOG = process.env.CLAUDE_FLAG_LOG || path.join(os.homedir(), '.local', 'state', 'claude', 'flag.log');

function tmux(args) {
  try { execFileSync(TMUX, args, { timeout: 300, stdio: 'ignore' }); } catch { /* no tmux, or pane gone */ }
}

function log(event, pane, action) {
  try {
    fs.mkdirSync(path.dirname(LOG), { recursive: true });
    fs.appendFileSync(LOG, `${new Date().toISOString()}\t${event}\t${pane}\t${action}\n`);
  } catch { /* logging never blocks a hook */ }
}

function pane() {
  return process.env.TMUX && process.env.TMUX_PANE ? process.env.TMUX_PANE : '';
}

function raise(event) {
  const p = pane();
  if (!p) return false;
  tmux(['set-option', '-p', '-t', p, OPTION, '1']);
  tmux(['set-option', '-w', '-t', p, OPTION, '1']);
  tmux(['refresh-client', '-S']);
  log(event, p, 'raise');
  return true;
}

function clear(event) {
  const p = pane();
  if (!p) return false;
  tmux(['set-option', '-pu', '-t', p, OPTION]);
  tmux(['set-option', '-wu', '-t', p, OPTION]);
  tmux(['refresh-client', '-S']);
  log(event, p, 'clear');
  return true;
}

module.exports = { raise, clear, OPTION };
