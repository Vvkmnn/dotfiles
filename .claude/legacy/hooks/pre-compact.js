#!/usr/bin/env node

/**
 * Claude Code PreCompact Hook
 * 
 * Triggered: Before Claude Code runs a compact operation
 * Matchers: "manual" (from /compact) or "auto" (due to full context window)
 * 
 * Use cases:
 * - Backup conversations before compaction
 * - Custom compaction logic
 * - User notifications about compaction
 * - Preserve important context
 * - Performance monitoring
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
  const { hook_event_name, matcher, conversation_id } = hookInput;
  
  // matcher will be "manual" or "auto"
  
  // Placeholder: Add your pre-compact logic here
  // Examples:
  // - Backup conversation before compaction
  // - Notify user about impending compaction
  // - Save important context separately
  // - Log compaction events
  // - Custom preservation logic
  
  // Always exit successfully for placeholder
  process.exit(0);
}