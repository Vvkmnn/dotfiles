#!/usr/bin/env node

/**
 * Claude Code PostToolUse Hook
 *
 * Runs after tool execution completes. Can:
 * - Inject additional context based on results
 * - Log tool usage for debugging
 * - Trigger notifications for long operations
 *
 * Output options:
 * - { "hookSpecificOutput": { "hookEventName": "PostToolUse", "additionalContext": "text" } }
 * - {} or nothing - No action
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

let inputData = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => { inputData += chunk; });

process.stdin.on('end', () => {
  try {
    const result = JSON.parse(inputData);
    const response = processToolResult(result);
    if (response && Object.keys(response).length > 0) {
      console.log(JSON.stringify(response));
    }
    process.exit(0);
  } catch (err) {
    // Fail silently
    process.exit(0);
  }
});

function context(text) {
  return {
    hookSpecificOutput: {
      hookEventName: 'PostToolUse',
      additionalContext: text
    }
  };
}

// Find the most recent plan with pending items (prefers pending over mtime-only).
// Same logic as pre-compact.js findMostRecentPlan.
function findActivePlan() {
  const planDir = path.join(os.homedir(), '.claude', 'plans');
  try {
    const plans = fs.readdirSync(planDir)
      .filter(f => f.endsWith('.md') && !f.includes('-agent-'))
      .map(f => {
        const fp = path.join(planDir, f);
        const c = fs.readFileSync(fp, 'utf8');
        return { path: fp, mtime: fs.statSync(fp).mtimeMs, hasPending: /^- \[ \] /m.test(c) };
      })
      .sort((a, b) => b.mtime - a.mtime);
    return plans.find(p => p.hasPending) || plans[0] || null;
  } catch { return null; }
}

function processToolResult(result) {
  const { tool_name, tool_input, output, duration_ms, error } = result;

  // ========================================
  // Log slow operations (>10s) for debugging
  // ========================================
  if (duration_ms && duration_ms > 10000) {
    const logFile = path.join(os.tmpdir(), 'claude-slow-tools.log');
    const entry = `${new Date().toISOString()} | ${tool_name} | ${duration_ms}ms | ${JSON.stringify(tool_input).slice(0, 100)}\n`;
    try {
      fs.appendFileSync(logFile, entry);
    } catch (e) {
      // Ignore logging errors
    }
  }

  // ========================================
  // Error research reminders
  // ========================================
  if (tool_name === 'Bash' && error) {
    const command = tool_input?.command || '';
    const errorStr = typeof error === 'string' ? error : JSON.stringify(error);

    // Skip noise (grep/find/test exit 1, empty errors)
    if (/\b(grep|rg|find|test)\b.*exit code 1/i.test(`${errorStr} ${command}`) ||
        /No files? matched/i.test(errorStr) || !errorStr.trim()) {
      return {};
    }

    // All errors: remind to research before retrying
    return context('<system-reminder>Command failed. Read the full error. If this is a repeat failure or unfamiliar error, follow the research protocol in orchestrate.md before retrying. Never attempt the same approach twice without new information.</system-reminder>');
  }

  // ========================================
  // Plan checkbox flip → remind TaskUpdate
  // ========================================
  if (tool_name === 'Edit' && !error) {
    const filePath = tool_input?.file_path || '';
    const oldStr = tool_input?.old_string || '';
    const newStr = tool_input?.new_string || '';
    if (/plans\/.*\.md$/.test(filePath) && /\[ \]/.test(oldStr) && /\[x\]/.test(newStr)) {
      const flipped = (newStr.match(/\[x\]/g) || []).length - (oldStr.match(/\[x\]/g) || []).length;
      if (flipped > 0) {
        return context(`<system-reminder>You just marked ${flipped} plan item(s) [x]. Did you also call TaskUpdate → completed for each? The Flowing display only updates via TaskUpdate.</system-reminder>`);
      }
    }
  }

  // MultiEdit: same checkbox flip detection across multiple edits
  if (tool_name === 'MultiEdit' && !error) {
    const filePath = tool_input?.file_path || '';
    if (/plans\/.*\.md$/.test(filePath)) {
      let flipped = 0;
      for (const e of (tool_input?.edits || [])) {
        const oldStr = e.old_string || '';
        const newStr = e.new_string || '';
        if (/\[ \]/.test(oldStr) && /\[x\]/.test(newStr)) {
          flipped += (newStr.match(/\[x\]/g) || []).length - (oldStr.match(/\[x\]/g) || []).length;
        }
      }
      if (flipped > 0) {
        return context(`<system-reminder>You just marked ${flipped} plan item(s) [x]. Did you also call TaskUpdate → completed for each? The Flowing display only updates via TaskUpdate.</system-reminder>`);
      }
    }
  }

  // ========================================
  // Subagent completion → remind TaskUpdate (only if plan has pending items)
  // ========================================
  if (tool_name === 'Agent' && !error) {
    const active = findActivePlan();
    if (active && active.hasPending) {
      return context('<system-reminder>A subagent just completed. If it finished a plan item, call TaskUpdate -> completed for that task NOW — subagents cannot update the parent task list, only you can.</system-reminder>');
    }
  }

  // ========================================
  // Track last-edited file in tmux pane option (for prefix+V)
  // ========================================
  if (['Edit', 'Write', 'MultiEdit'].includes(tool_name) && !error) {
    try {
      const tmuxPane = process.env.TMUX_PANE;
      const filePath = tool_input?.file_path || '';
      if (tmuxPane && filePath) {
        const absPath = path.isAbsolute(filePath) ? filePath : path.resolve(filePath);
        const { execFileSync } = require('child_process');
        const tmux = '/opt/homebrew/bin/tmux';
        execFileSync(tmux, ['set-option', '-pq', '-t', tmuxPane, '@claude_last_edit', absPath], { timeout: 1000 });

        // Find line number of the edit
        let line = '1';
        const newStr = tool_input?.new_string || tool_input?.content || '';
        if (newStr) {
          const firstLine = newStr.split('\n')[0];
          if (firstLine.trim()) {
            try {
              line = execFileSync('grep', ['-n', '-m1', '-F', firstLine, absPath], { timeout: 1000 }).toString().split(':')[0] || '1';
            } catch {}
          }
        }
        execFileSync(tmux, ['set-option', '-pq', '-t', tmuxPane, '@claude_last_edit_line', line], { timeout: 1000 });
      }
    } catch {}
  }

  // ========================================
  // ExitPlanMode → remind to create tasks immediately
  // ========================================
  if (tool_name === 'ExitPlanMode' && !error) {
    // Extract the exact plan file from output (not findActivePlan, which may find a different plan)
    const planPathMatch = (output || '').match(/saved to: (.+\.md)/);
    if (planPathMatch) {
      try {
        const content = fs.readFileSync(planPathMatch[1], 'utf8');
        const pendingCount = (content.match(/^- \[ \] /gm) || []).length;
        if (pendingCount > 0) {
          return context(`<system-reminder>Plan approved with ${pendingCount} pending items. Create tasks (TaskCreate) for all pending items NOW as your first action — before invoking skills, reading files, or any other work. The Flowing task list is empty until you call TaskCreate.</system-reminder>`);
        }
      } catch { /* plan file not readable, skip */ }
    }
  }

  // No additional context needed
  return {};
}
