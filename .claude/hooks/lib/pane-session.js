'use strict';
/**
 * Records which Claude session this tmux pane runs, as the pane option `@claude_session`, so the
 * launcher (`c` in ~/.functions) resumes exactly that id instead of `claude --continue`'s "most recent
 * conversation", which on 2026-11-04 pointed at a parked background job and stranded the owner.
 *
 * Written on SessionStart and again on every prompt (a `/clear` or a resume changes the id). The pane
 * is addressed explicitly by TMUX_PANE, as lib/waiting-flag.js does: hooks run with stdin closed.
 * Fails open: without tmux, or on any error, it does nothing and never throws.
 */
const { execFileSync } = require('child_process');

const TMUX = process.env.CLAUDE_TMUX_BIN || '/opt/homebrew/bin/tmux';
const OPTION = '@claude_session';

function pane() {
  return process.env.TMUX && process.env.TMUX_PANE ? process.env.TMUX_PANE : '';
}

/** Sets this pane's `@claude_session` to `sessionId`; returns true when a pane was addressed. */
function record(sessionId) {
  const p = pane();
  if (!p || !sessionId || !/^[0-9a-f-]{36}$/.test(sessionId)) return false;
  try { execFileSync(TMUX, ['set-option', '-p', '-t', p, OPTION, sessionId], { timeout: 300, stdio: 'ignore' }); } catch { return false; }
  return true;
}

module.exports = { record, OPTION };
