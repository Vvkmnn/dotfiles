#!/usr/bin/env node

/**
 * Claude Code SubagentStop Hook
 * 
 * Triggered: When a Claude Code subagent (Task tool call) has finished responding
 * 
 * Use cases:
 * - Track subagent performance
 * - Aggregate subagent results
 * - Clean up subagent resources
 * - Log complex task completion
 * - Trigger follow-up actions
 */

const fs = require('fs');

// Read JSON input from stdin
let inputData = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => {
  inputData += chunk;
});

process.stdin.on('end', () => {
  try {
    const hookInput = JSON.parse(inputData);
    processHook(hookInput);
  } catch (error) {
    // Silently fail - don't block workflow
    process.exit(0);
  }
});

function processHook(hookInput) {
  const { hook_event_name, subagent_id, parent_tool_use_id } = hookInput;
  
  // Placeholder: Add your subagent stop logic here
  // Examples:
  // - Log subagent completion
  // - Aggregate subagent metrics
  // - Clean up subagent resources
  // - Track complex task progress
  // - Trigger parent task updates
  
  // Always exit successfully for placeholder
  process.exit(0);
}