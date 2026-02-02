#!/usr/bin/env node

/**
 * Claude Code PreToolUse Hook
 *
 * Runs before tool execution. Can:
 * - Block dangerous operations (exit code 2)
 * - Inject context before tool runs
 * - Log tool usage
 *
 * Note: Continuous learning observation is handled by
 * ~/.claude/skills/continuous-learning/hooks/observe.sh
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

let inputData = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => { inputData += chunk; });

process.stdin.on('end', () => {
  try {
    const data = JSON.parse(inputData);
    const response = processToolRequest(data);
    if (response && Object.keys(response).length > 0) {
      console.log(JSON.stringify(response));
    }
    process.exit(0);
  } catch (err) {
    process.exit(0);
  }
});

function processToolRequest(data) {
  const { tool_name, tool_input } = data;

  // Add custom pre-tool checks here
  // Example: block certain operations, inject context, etc.

  return {};
}
