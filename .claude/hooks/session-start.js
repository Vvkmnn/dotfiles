#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

// Read stdin eagerly — hook runner passes JSON here, can only be read once
let stdinData = '';
try { stdinData = fs.readFileSync(0, 'utf8'); } catch (e) {}
const hookData = stdinData ? (() => { try { return JSON.parse(stdinData); } catch { return {}; } })() : {};

// ============================================================================
// OLD: Plan mode forcing (now replaced by native permissions.defaultMode)
// ============================================================================
// const planModeReminder = `<system-reminder>CRITICAL USER PREFERENCE: You MUST immediately call EnterPlanMode for EVERY task the user provides. No exceptions. Always plan first, then execute after user approval via ExitPlanMode.</system-reminder>`;
// console.log(planModeReminder);

// ============================================================================
// Update-claude reminder (if >7 days since last check)
// ============================================================================
const lastCheckFile = path.join(os.homedir(), '.claude', '.last-update-check');

try {
  const lastCheck = fs.existsSync(lastCheckFile)
    ? new Date(fs.readFileSync(lastCheckFile, 'utf8').trim())
    : new Date(0); // Never checked

  const daysSinceCheck = (Date.now() - lastCheck.getTime()) / (1000 * 60 * 60 * 24);

  if (daysSinceCheck > 7) {
    const reminder = `<system-reminder>It has been ${Math.floor(daysSinceCheck)} days since last Claude Code setup review. Consider running the upgrade-claude skill to check for new features, best practices, and optimizations.</system-reminder>`;
    console.log(reminder);
  }
} catch (err) {
  // Silently fail if check fails - don't block session start
}

// ============================================================================
// tmux session mapping: save pane -> claude session ID for exact resume
// Used by ~/.config/tmux/claude-session-restore.sh after reboot/crash
// ============================================================================
try {
  if (process.env.TMUX) {
    const { execFileSync } = require('child_process');
    const sessionId = hookData ? hookData.session_id : null;
    if (sessionId) {
      const tmux = '/opt/homebrew/bin/tmux';
      const tmuxSession = execFileSync(tmux, ['display-message', '-p', '#{session_name}']).toString().trim();
      const tmuxWindow = execFileSync(tmux, ['display-message', '-p', '#{window_index}']).toString().trim();
      const tmuxPath = execFileSync(tmux, ['display-message', '-p', '#{pane_current_path}']).toString().trim();
      const key = `${tmuxSession}:${tmuxWindow}:${tmuxPath}`;
      const mapFile = path.join(os.homedir(), '.config', 'tmux', 'claude_sessions');

      // Append-only: atomic for short writes (<PIPE_BUF), no race between concurrent sessions
      // Pruning happens in claude-session-restore.sh on reboot
      fs.appendFileSync(mapFile, `${key} ${sessionId}\n`);
    }
  }
} catch (err) {
  // Silently fail - don't block session start
}

// ============================================================================
// Post-compaction plan injection: surface active plan state in new context
// Without this, Claude must proactively re-read the plan file after compaction
// ============================================================================
try {
  const planDir = path.join(os.homedir(), '.claude', 'plans');
  if (fs.existsSync(planDir)) {
    // Find most recent plan with pending items (same logic as pre-compact.js)
    const plans = fs.readdirSync(planDir)
      .filter(f => f.endsWith('.md') && !f.includes('-agent-'))
      .map(f => {
        const fp = path.join(planDir, f);
        const c = fs.readFileSync(fp, 'utf8');
        return { path: fp, mtime: fs.statSync(fp).mtimeMs, content: c, hasPending: /^- \[ \] /m.test(c) };
      })
      .sort((a, b) => b.mtime - a.mtime);
    const active = plans.find(p => p.hasPending);

    if (active) {
      const title = (active.content.match(/^# (.+)$/m) || [])[1] || path.basename(active.path, '.md');
      const basename = path.basename(active.path);
      const done = (active.content.match(/^- \[x\] /gm) || []).length;
      const pending = (active.content.match(/^- \[ \] /gm) || []).length;
      const pendingItems = (active.content.match(/^- \[ \] .+$/gm) || [])
        .slice(0, 3)
        .map(item => item.replace(/^- \[ \] /, '').replace(/ — .+$/, '').substring(0, 60));

      const injection = [
        `<system-reminder>`,
        `**Active plan**: "${title}" (\`plans/${basename}\`).`,
        `Status: ${done}/${done + pending} done.`,
        pendingItems.length > 0 ? `Next: ${pendingItems.join(', ')}.` : '',
        `Read the plan file for full context. Follow plan.md rules.`,
        `</system-reminder>`
      ].filter(Boolean).join(' ');

      console.log(JSON.stringify({
        hookSpecificOutput: {
          hookEventName: 'SessionStart',
          additionalContext: injection
        }
      }));
    }
  }
} catch {
  // Fail open - don't block session start
}

process.exit(0);
