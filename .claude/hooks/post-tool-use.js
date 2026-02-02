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
 * - { "additionalContext": "text" } - Add context to conversation
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
  // Context injection based on tool results
  // ========================================

  // If a test command failed, suggest debugging
  if (tool_name === 'Bash' && error) {
    const command = tool_input?.command || '';
    if (/npm\s+test|pytest|cargo\s+test|go\s+test/.test(command)) {
      return {
        additionalContext: '<system-reminder>Tests failed. Consider using the debugging-toolkit:debugger agent or superpowers:systematic-debugging skill to investigate.</system-reminder>'
      };
    }
  }

  // If build failed, suggest checking errors
  if (tool_name === 'Bash' && error) {
    const command = tool_input?.command || '';
    if (/npm\s+run\s+build|cargo\s+build|go\s+build|make/.test(command)) {
      return {
        additionalContext: '<system-reminder>Build failed. Check the error output above and fix the issues before proceeding.</system-reminder>'
      };
    }
  }

  // If git push failed, check for common issues
  if (tool_name === 'Bash' && error) {
    const command = tool_input?.command || '';
    if (/git\s+push/.test(command)) {
      return {
        additionalContext: '<system-reminder>Git push failed. Common causes: remote has new commits (pull first), branch protection rules, or authentication issues.</system-reminder>'
      };
    }
  }

  // No additional context needed
  return {};
}
