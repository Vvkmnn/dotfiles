#!/usr/bin/env node

/**
 * Claude Code Notification hook — one local emitter for "Claude is waiting on you".
 *
 * On permission_prompt / idle_prompt / agent_needs_input / elicitation_*:
 *   1. set the tmux pane + window option @claude_waiting=1 — read by statusline.sh (ॐ turns red)
 *      and by tmux.conf formats (red marker on the window/pane); cleared by user-prompt-submit.js
 *   2. ring the bell on the pane tty (tmux bell-action any highlights the window)
 *   3. send one macOS banner via terminal-notifier only when the window is NOT the one you are
 *      looking at (no duplicate while you watch the pane). agent_completed → "Done".
 * No emoji anywhere (house rule). Fails open: any error exits 0 and never blocks Claude.
 */

const { execFile } = require('child_process');
const { basename } = require('path');
const { execFileSync } = require('child_process');
const { raise } = require('./lib/waiting-flag');

const TMUX = '/opt/homebrew/bin/tmux';
// Every way Claude can be paused on the owner raises the flag (owner rule: "if Claude is paused
// in any way I need to know visually from tmux, and notifications"). Stop = the turn finished
// and Claude waits for the next instruction; quota_* = waiting on a usage-limit reset.
const LABELS = {
  permission_prompt: 'Permission',
  idle_prompt: 'Waiting',
  agent_needs_input: 'Agent input',
  elicitation_dialog: 'Input',
  elicitation_url_dialog: 'Input',
  agent_completed: 'Agent done',
  quota_auto_resume_fired: 'Usage limit',
  quota_auto_resume_stale: 'Usage limit',
  quota_auto_resume_disabled: 'Usage limit',
  Stop: 'Done',
};
const WAITING = new Set(Object.keys(LABELS));

let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (c) => { raw += c; });
process.stdin.on('end', () => {
  try { run(JSON.parse(raw)); } catch { process.exit(0); }
});

function tmux(args) {
  try { return execFileSync(TMUX, args, { encoding: 'utf8', timeout: 500, stdio: ['ignore', 'pipe', 'ignore'] }).trim(); }
  catch { return ''; }
}

function run(hook) {
  const type = hook.notification_type || hook.hook_event_name || '';
  const label = LABELS[type] || 'Attention';
  const inTmux = Boolean(process.env.TMUX);

  if (inTmux && WAITING.has(type)) {
    raise(type);   // pane + window option, explicit -t, status refresh, flag.log line (lib/waiting-flag.js)
    const tty = tmux(['display-message', '-p', '-t', process.env.TMUX_PANE || '', '#{pane_tty}']);
    if (tty) execFile('sh', ['-c', `printf '\\a' > ${tty}`], () => {});
  }

  // Banner only when the owner is not looking at this window.
  const active = inTmux ? tmux(['display-message', '-p', '#{window_active}#{session_attached}']) : '';
  const looking = active === '11';
  if (looking) return process.exit(0);

  const where = inTmux ? tmux(['display-message', '-p', '#S|#I']) : '';
  const branch = git(['branch', '--show-current']);
  const dirty = git(['status', '--porcelain']) ? '*' : '';
  const place = [where, basename(process.cwd()) + (branch ? `:${branch}${dirty}` : '')].filter(Boolean).join('|');
  const message = hook.message || 'Claude needs your attention';

  // terminal-notifier ≥ 3 (UserNotifications API): -contentImage attaches the clawd image;
  // -sender/-appIcon are gone. The app needs a one-time Allow in System Settings → Notifications,
  // granted from a GUI shell (a Background launchd session cannot request it).
  execFile('terminal-notifier', [
    '-title', 'Claude Code', '-subtitle', `${label} · ${place}`, '-message', message,
    '-contentImage', `${process.env.HOME}/.claude/clawd.png`,
  ], (err) => {
    if (err) execFile('osascript', ['-e', `display notification "${message.replace(/"/g, '\\"')}" with title "Claude Code" subtitle "${label}"`], () => process.exit(0));
    else process.exit(0);
  });
}

function git(args) {
  try { return execFileSync('git', args, { encoding: 'utf8', timeout: 500, stdio: ['ignore', 'pipe', 'ignore'] }).trim(); }
  catch { return ''; }
}
