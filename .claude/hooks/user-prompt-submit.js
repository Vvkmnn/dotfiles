#!/usr/bin/env node

/**
 * Claude Code UserPromptSubmit Hook
 *
 * Per-turn context injection (fires on EVERY user message — must stay <1s, no network):
 * - Current git branch + dirty-file count (when cwd is a repo)
 * - Active plan progress line (most recent plan with pending items)
 * - Project type hint (from manifest files in cwd)
 *
 * Why: dynamic context beats CLAUDE.md bloat — branch/plan/type change per turn,
 * SessionStart only fires once. Added 2026-07-06 (Tier 4, deep-upgrade plan).
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execFileSync } = require('child_process');

let inputData = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (c) => { inputData += c; });

process.stdin.on('end', () => {
  try {
    const parts = [];

    // The owner typed: this pane is no longer waiting. Clears the flag set by notification.js
    // (statusline ॐ turns back to the vim color; tmux formats drop the red marker). Shared
    // implementation in lib/waiting-flag.js: explicit pane target, status refresh, flag.log line.
    require('./lib/waiting-flag').clear('UserPromptSubmit');

    // This pane's session id, for the launcher's exact resume (lib/pane-session.js). Rewritten on
    // every prompt because a /clear or a resume changes the id after SessionStart wrote it.
    try { require('./lib/pane-session').record(JSON.parse(inputData).session_id); } catch { /* no id in the payload */ }

    // Git branch + dirty count (fast, local, silent on non-repos)
    try {
      const opts = { timeout: 500, stdio: ['ignore', 'pipe', 'ignore'], encoding: 'utf8' };
      const branch = execFileSync('git', ['branch', '--show-current'], opts).trim();
      if (branch) {
        const dirty = execFileSync('git', ['status', '--porcelain'], opts)
          .split('\n').filter(l => l.trim()).length;
        parts.push(`branch: ${branch}${dirty ? ` (${dirty} dirty)` : ''}`);
      }
    } catch { /* not a repo */ }

    // Active plan progress (first line of newest plan with pending items)
    try {
      const planDir = path.join(os.homedir(), '.claude', 'plans');
      const plans = fs.readdirSync(planDir)
        .filter(f => f.endsWith('.md') && !f.includes('-agent-'))
        .map(f => {
          const fp = path.join(planDir, f);
          return { fp, mtime: fs.statSync(fp).mtimeMs };
        })
        .sort((a, b) => b.mtime - a.mtime)
        .slice(0, 3); // only check the 3 newest — keep it fast
      for (const p of plans) {
        const head = fs.readFileSync(p.fp, 'utf8').slice(0, 600);
        if (/^- \[ \] /m.test(fs.readFileSync(p.fp, 'utf8'))) {
          const prog = head.match(/\*\*Progress: [^*]+\*\*[^\n]*/);
          if (prog) parts.push(`plan: ${prog[0].replace(/\*\*/g, '')}`);
          break;
        }
      }
    } catch { /* no plans dir */ }

    // Project type hint (cheap existence checks only)
    try {
      const markers = {
        'package.json': 'node', 'Cargo.toml': 'rust', 'pyproject.toml': 'python',
        'go.mod': 'go', 'Package.swift': 'swift', 'Gemfile': 'ruby',
      };
      const found = Object.keys(markers).filter(f => fs.existsSync(f)).map(f => markers[f]);
      if (found.length) parts.push(`project: ${found.join('+')}`);
    } catch { /* ignore */ }

    if (parts.length) {
      console.log(JSON.stringify({
        hookSpecificOutput: {
          hookEventName: 'UserPromptSubmit',
          additionalContext: `<session-context>${parts.join(' | ')}</session-context>`,
        },
      }));
    }
    process.exit(0);
  } catch {
    process.exit(0); // fail open — never block a prompt
  }
});
