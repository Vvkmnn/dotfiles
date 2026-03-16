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

  // ========================================
  // File creation → remind about pending tasks
  // ========================================
  if (tool_name === 'Write' && !error) {
    const filePath = tool_input?.file_path || '';
    // Skip plan/hook/rule files — only trigger for implementation files
    if (!/plans\/.*\.md$|\.claude\/hooks\/|\.claude\/rules\//.test(filePath)) {
      const planDir = path.join(os.homedir(), '.claude', 'plans');
      try {
        const plans = fs.readdirSync(planDir).filter(f => f.endsWith('.md'));
        if (plans.length > 0) {
          const content = fs.readFileSync(path.join(planDir, plans[0]), 'utf8');
          const pending = (content.match(/^- \[ \] .+$/gm) || []).length;
          if (pending > 0) {
            return context(`<system-reminder>You just created a new file. ${pending} plan items are still pending — if this work completes one, call TaskUpdate → completed before moving on.</system-reminder>`);
          }
        }
      } catch (e) { /* no plans, skip */ }
    }
  }

  // ========================================
  // Subagent completion → remind TaskUpdate
  // ========================================
  if (tool_name === 'Agent' && !error) {
    const planDir = path.join(os.homedir(), '.claude', 'plans');
    try {
      const plans = fs.readdirSync(planDir).filter(f => f.endsWith('.md'));
      if (plans.length > 0) {
        return context('<system-reminder>A subagent just completed. If it finished a plan item, call TaskUpdate → completed for that task NOW — subagents cannot update the parent task list, only you can.</system-reminder>');
      }
    } catch (e) { /* no plans dir, skip */ }
  }

  // No additional context needed
  return {};
}
