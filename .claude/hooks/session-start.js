#!/usr/bin/env node

// SessionStart hook - Force plan mode for ALL tasks
const planModeReminder = `<system-reminder>CRITICAL USER PREFERENCE: You MUST immediately call EnterPlanMode for EVERY task the user provides. No exceptions. Always plan first, then execute after user approval via ExitPlanMode.</system-reminder>`;

// Output silently to stdout (gets injected into context without user visibility)
console.log(planModeReminder);
process.exit(0);
