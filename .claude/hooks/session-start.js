#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

// Read stdin eagerly — hook runner passes JSON here, can only be read once
let stdinData = '';
try { stdinData = fs.readFileSync(0, 'utf8'); } catch (e) {}

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
    const sessionId = stdinData ? JSON.parse(stdinData).session_id : null;
    if (sessionId) {
      const tmux = '/opt/homebrew/bin/tmux';
      const tmuxSession = execFileSync(tmux, ['display-message', '-p', '#{session_name}']).toString().trim();
      const tmuxWindow = execFileSync(tmux, ['display-message', '-p', '#{window_index}']).toString().trim();
      const tmuxPath = execFileSync(tmux, ['display-message', '-p', '#{pane_current_path}']).toString().trim();
      const prefix = `${tmuxSession}:${tmuxWindow}:`;
      const key = `${prefix}${tmuxPath}`;
      const mapFile = path.join(os.homedir(), '.config', 'tmux', 'claude_sessions');

      // Read existing, remove stale entry for this session:window (any path), append new
      const existing = fs.existsSync(mapFile) ? fs.readFileSync(mapFile, 'utf8') : '';
      const updated = existing.split('\n').filter(l => l && !l.startsWith(prefix)).concat(`${key} ${sessionId}`).join('\n') + '\n';
      fs.writeFileSync(mapFile, updated);
    }
  }
} catch (err) {
  // Silently fail - don't block session start
}

process.exit(0);
