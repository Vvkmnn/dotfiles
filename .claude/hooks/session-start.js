#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

// ============================================================================
// OLD: Plan mode forcing (now replaced by native permissions.defaultMode)
// ============================================================================
// const planModeReminder = `<system-reminder>CRITICAL USER PREFERENCE: You MUST immediately call EnterPlanMode for EVERY task the user provides. No exceptions. Always plan first, then execute after user approval via ExitPlanMode.</system-reminder>`;
// console.log(planModeReminder);

// ============================================================================
// NEW: Update-claude reminder (if >7 days since last check)
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

process.exit(0);
