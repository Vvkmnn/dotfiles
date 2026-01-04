#!/usr/bin/env node

/**
 * Claude Code Stop Hook
 *
 * Triggered when Claude Code session stops (via /exit or Ctrl+D).
 * Automatically updates plugin marketplace metadata in the background
 * to prevent stale cache issues.
 *
 * This hook fires and forgets - doesn't block session exit.
 */

const { spawn } = require('child_process');

// Read JSON input from stdin (required by hook interface)
let inputData = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => {
  inputData += chunk;
});

process.stdin.on('end', () => {
  try {
    // Parse hook input (not used, but required by interface)
    const hookInput = JSON.parse(inputData);
    updatePlugins();
  } catch (error) {
    // Silently fail - don't block workflow
    process.exit(0);
  }
});

function updatePlugins() {
  // Fire and forget - spawn detached process
  const update = spawn('claude', ['plugin', 'marketplace', 'update'], {
    detached: true,
    stdio: 'ignore'
  });

  // Detach from parent process
  update.unref();

  // Exit immediately - update runs in background
  process.exit(0);
}
