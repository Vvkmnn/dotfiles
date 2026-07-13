#!/usr/bin/env node

/**
 * Claude Code PostToolUse Hook
 * 
 * Triggered: Immediately after a tool completes successfully
 * Use cases:
 * - Log tool usage and performance
 * - Clean up temporary files
 * - Trigger follow-up actions
 * - Update metrics or notifications
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
  const { tool_name, tool_input, hook_event_name } = hookInput;
  
  // Placeholder: Add your post-tool logic here
  // Examples:
  // - Log successful operations
  // - Trigger cleanup
  // - Send notifications
  // - Update statistics
  
  // Always exit successfully for placeholder
  process.exit(0);
}