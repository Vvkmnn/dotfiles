#!/usr/bin/env node

/**
 * Claude Code PermissionRequest Hook
 *
 * Auto-approves safe operations, auto-denies dangerous ones.
 * Falls back to asking user for everything else.
 *
 * Decision outputs:
 * - { "decision": "approve" } - Allow without prompt
 * - { "decision": "deny", "message": "reason" } - Block with message
 * - { "decision": "ask" } - Show normal permission prompt
 */

let inputData = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => { inputData += chunk; });

process.stdin.on('end', () => {
  try {
    const request = JSON.parse(inputData);
    const decision = evaluatePermission(request);
    console.log(JSON.stringify(decision));
    process.exit(0);
  } catch (err) {
    // Fail open - ask user
    console.log(JSON.stringify({ decision: 'ask' }));
    process.exit(0);
  }
});

function evaluatePermission(request) {
  const { tool, input } = request;
  const command = input?.command || '';

  // ========================================
  // AUTO-APPROVE: Safe read-only operations
  // ========================================

  // Read tools are always safe
  if (['Read', 'Glob', 'Grep', 'LS'].includes(tool)) {
    return { decision: 'approve' };
  }

  // WebSearch and WebFetch (already in settings, but belt + suspenders)
  if (['WebSearch', 'WebFetch'].includes(tool)) {
    return { decision: 'approve' };
  }

  // Task tool (subagents)
  if (tool === 'Task') {
    return { decision: 'approve' };
  }

  // TodoWrite (internal tracking)
  if (tool === 'TodoWrite') {
    return { decision: 'approve' };
  }

  // ========================================
  // AUTO-DENY: Dangerous operations
  // ========================================

  if (tool === 'Bash') {
    // Force push - never
    if (/git\s+push\s+.*--force/.test(command) || /git\s+push\s+-f/.test(command)) {
      return { decision: 'deny', message: 'Force push blocked. Use regular push or ask explicitly.' };
    }

    // Hard reset - never
    if (/git\s+reset\s+--hard/.test(command)) {
      return { decision: 'deny', message: 'Hard reset blocked. This discards uncommitted changes.' };
    }

    // rm -rf with dangerous paths
    if (/rm\s+-rf?\s+[\/~]/.test(command) || /rm\s+-rf?\s+\*/.test(command)) {
      return { decision: 'deny', message: 'Recursive delete on root/home/wildcard blocked.' };
    }

    // sudo commands
    if (/^sudo\s/.test(command) || /\|\s*sudo/.test(command)) {
      return { decision: 'deny', message: 'sudo commands require manual execution.' };
    }

    // chmod 777
    if (/chmod\s+777/.test(command)) {
      return { decision: 'deny', message: 'chmod 777 is insecure. Use more restrictive permissions.' };
    }
  }

  // ========================================
  // ASK: Everything else
  // ========================================

  return { decision: 'ask' };
}
