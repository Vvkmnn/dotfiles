#!/usr/bin/env node

/**
 * Tests for pre-tool-use.js — focused on the git-gate wrapper/alias hardening.
 *
 * Drives the hook as a subprocess (pipes a tool-call JSON on stdin, reads the decision JSON on
 * stdout) so the hook itself needs no test-only refactor. Decision is derived as:
 *   empty stdout            → 'allow'  (hook returns nothing → Claude Code's normal permission flow)
 *   {permissionDecision: X} → X        ('ask' | 'deny')
 *
 * Run: node ~/.claude/hooks/pre-tool-use.test.js   (exit 0 = all pass, 1 = any fail)
 */

const { spawnSync } = require('child_process');
const path = require('path');

const HOOK = path.join(__dirname, 'pre-tool-use.js');

// Decide what the hook returns for a Bash command string.
function decide(command) {
  const payload = JSON.stringify({ tool_name: 'Bash', tool_input: { command } });
  const res = spawnSync(process.execPath, [HOOK], { input: payload, encoding: 'utf8' });
  if (res.status !== 0) throw new Error(`hook exited ${res.status}: ${res.stderr}`);
  const out = res.stdout.trim();
  if (!out) return 'allow';
  return JSON.parse(out).hookSpecificOutput.permissionDecision;
}

// An inline bare-repo wrapper, as the fleet coordination scripts write it.
const WRAP = 'G(){ /usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"; };';

const cases = [
  // ── Bypass now CLOSED → must ASK ─────────────────────────────────────────
  [`${WRAP} G commit -m x`,                 'ask',  'inline wrapper: commit'],
  [`${WRAP} G push origin v-macos-macbook`, 'ask',  'inline wrapper: push'],
  [`${WRAP} G add -A`,                       'ask',  'inline wrapper: add'],
  ['dotfiles commit -m x',                   'ask',  'dotfiles alias: commit'],
  ['dotfiles push',                          'ask',  'dotfiles alias: push'],
  ['dotfiles add -A',                        'ask',  'dotfiles alias: add'],
  ['d commit -m x',                          'ask',  'd alias (2-hop → dotfiles → git): commit'],
  ['g commit -m x',                          'ask',  'g alias (→ git): commit'],
  ['g push',                                 'ask',  'g alias (→ git): push'],
  ['foo && dotfiles commit -m x',            'ask',  'alias after && separator'],

  // ── Bypass now CLOSED → must DENY ────────────────────────────────────────
  [`${WRAP} G reset --hard HEAD~1`,          'deny', 'inline wrapper: hard reset'],
  ['dotfiles push --force',                  'deny', 'dotfiles alias: force push'],
  ['d reset --hard',                         'deny', 'd alias: hard reset'],
  [',git-undo',                              'deny', ',git-undo (= clean -fd && reset --hard)'],

  // ── Generic catch-all (unregistered names) → must ASK ────────────────────
  ['myg(){ /usr/bin/git --git-dir=$H/.dotfiles --work-tree=$H "$@"; }; myg commit -m x',
                                             'ask',  'inline wrapper, UNREGISTERED name'],
  ['GIT_DIR=$H/.dotfiles GIT_WORK_TREE=$H notgit commit -m x',
                                             'ask',  'backstop: GIT_DIR/GIT_WORK_TREE env + verb'],

  // ── Regression: plain git still gated ────────────────────────────────────
  ['git commit -m x',                        'ask',  'plain git commit'],
  ['git add f',                              'ask',  'plain git add'],
  ['git push',                               'ask',  'plain git push'],
  ['git reset --hard',                       'deny', 'plain git hard reset'],

  // ── No false positives → must ALLOW ──────────────────────────────────────
  ['git status',                             'allow', 'read-only: git status'],
  ['g status',                               'allow', 'read-only: g status'],
  ['dotfiles status',                        'allow', 'read-only: dotfiles status'],
  ['dotfiles diff',                          'allow', 'read-only: dotfiles diff'],
  ['ds',                                     'allow', 'read-only: ds alias (dotfiles status)'],
  ['cd ~/.dotfiles && ls',                   'allow', 'path mention, no verb'],
  ['echo dotfiles',                          'allow', 'dotfiles not in command position'],
  ['cat ~/.dotfiles/hooks/pre-tool-use.js',  'allow', 'reading a file under .dotfiles'],
  ['grep commit ~/.dotfiles/README',         'allow', 'verb word in a read, no bare-repo signature'],
  ['cd dir',                                 'allow', 'cd ends in d — not the d alias'],
];

let pass = 0, fail = 0;
for (const [cmd, want, label] of cases) {
  let got;
  try { got = decide(cmd); } catch (e) { got = `ERROR(${e.message})`; }
  if (got === want) {
    pass++;
    console.log(`  ok    ${want.padEnd(5)} ${label}`);
  } else {
    fail++;
    console.log(`  FAIL  want=${want} got=${got}  ${label}`);
    console.log(`        cmd: ${cmd}`);
  }
}

console.log(`\n${pass} passed, ${fail} failed, ${cases.length} total`);
process.exit(fail === 0 ? 0 : 1);
