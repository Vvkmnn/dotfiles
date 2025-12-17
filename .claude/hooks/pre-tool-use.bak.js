#!/usr/bin/env node

/**
 * Claude Code PreToolUse Hook - Token-Saving Protection
 *
 * Blocks reading from token-wasting directories:
 * - node_modules/, dist/, build/, logs/, etc.
 * - Silently blocks first attempt (Claude moves on)
 * - Shows bypass instructions on repeated attempts (Claude needs it)
 *
 * Emergency bypass: export CLAUDE_BYPASS_HOOKS=1
 */

// NOTE: Seems to fuck up the searching? CHeck later
// const fs = require('fs');
// const path = require('path');
//
// // Comprehensive blocklist
// const FORBIDDEN_PATTERNS = [
//   // Dependency directories
//   /node_modules\//,
//   /frontend\/node_modules\//,
//   /backend\/node_modules\//,
//   /venv\//,
//   /\.venv\//,
//   /env\//,
//   /__pycache__\//,
//   /vendor\//,
//   /packages\//,
//   /bower_components\//,
//
//   // Build artifacts
//   /dist\//,
//   /build\//,
//   /out\//,
//   /target\//,
//   /\.next\//,
//   /\.nuxt\//,
//   /frontend\/dist\//,
//   /backend\/dist\//,
//
//   // Infrastructure as Code
//   /\.terraform\//,
//   /\.terraform\.lock\.hcl$/,
//   /\.serverless\//,
//   /cdk\.out\//,
//
//   // IDE and tooling
//   /\.idea\//,
//   /\.vscode\//,
//   /\.vs\//,
//   /\.fleet\//,
//
//   // Git internals
//   /\.git\/objects\//,
//   /\.git\/index$/,
//
//   // Logs and data
//   /logs\//,
//   /\.log$/,
//   /\.csv$/,
//   /\.parquet$/,
//   /data\//,
//   /datasets\//,
//
//   // Compiled and cache
//   /\.pyc$/,
//   /\.pyo$/,
//   /\.pyd$/,
//   /\.pytest_cache\//,
//   /\.class$/,
//   /\.jar$/,
//   /\.war$/,
//   /\.o$/,
//   /\.so$/,
//   /\.dylib$/,
//   /\.dll$/,
//
//   // Package locks
//   /package-lock\.json$/,
//   /yarn\.lock$/,
//   /pnpm-lock\.yaml$/,
//   /poetry\.lock$/,
//   /Pipfile\.lock$/,
//   /Gemfile\.lock$/,
//
//   // Sensitive files
//   /\.env$/,
//   /\.env\.local$/,
//   /\.env\.production$/,
//   /service-account-key\.json$/,
//   /credentials\.json$/,
//   /\.pem$/,
//   /\.key$/,
//   /\.crt$/,
//
//   // Documentation builds
//   /\.docusaurus\//,
//   /site\//,
//   /_site\//,
//
//   // Coverage
//   /coverage\//,
//   /\.nyc_output\//,
//   /htmlcov\//,
//
//   // Database files
//   /\.db$/,
//   /\.sqlite$/,
//   /\.sqlite3$/,
// ];
//
// // Track last blocked path
// const LAST_BLOCK_FILE = '/tmp/claude-hook-last-block';
//
// // Read JSON input from stdin
// let inputData = '';
// process.stdin.setEncoding('utf8');
// process.stdin.on('data', (chunk) => {
//   inputData += chunk;
// });
//
// process.stdin.on('end', () => {
//   try {
//     const hookInput = JSON.parse(inputData);
//     processHook(hookInput);
//   } catch (error) {
//     // Fail gracefully
//     process.exit(0);
//   }
// });
//
// function processHook(hookInput) {
//   const { tool_name, tool_input } = hookInput;
//
//   // Check bypass
//   if (process.env.CLAUDE_BYPASS_HOOKS === '1') {
//     console.error('⚠️  Hook bypass active - allowing operation (may consume many tokens)');
//     process.exit(0);
//   }
//
//   // Extract path based on tool
//   let targetPath = null;
//
//   if (tool_name === 'Read') {
//     targetPath = tool_input.file_path;
//   } else if (tool_name === 'Grep') {
//     targetPath = tool_input.path || '.';
//   } else if (tool_name === 'Glob') {
//     targetPath = tool_input.path || '.';
//   } else if (tool_name === 'Bash') {
//     targetPath = extractPathFromBashCommand(tool_input.command);
//   }
//
//   if (!targetPath) {
//     process.exit(0);
//   }
//
//   // Check if path matches forbidden patterns
//   const matchedPattern = FORBIDDEN_PATTERNS.find(pattern => pattern.test(targetPath));
//
//   if (matchedPattern) {
//     // Check if this is a repeated block
//     const lastBlockedPath = readLastBlockedPath();
//     const isRepeated = lastBlockedPath === targetPath;
//
//     // Save this blocked path
//     saveBlockedPath(targetPath);
//
//     if (isRepeated) {
//       // Show bypass instructions on repeated attempts
//       console.error('⚠️  BLOCKED: Reading from this path would waste significant tokens\n');
//       console.error(`Path: ${targetPath}`);
//       console.error(`\nYou've attempted this path multiple times. To bypass if truly needed:\n`);
//       console.error(`   export CLAUDE_BYPASS_HOOKS=1`);
//       console.error(`   claude  # Restart in same terminal`);
//       console.error(`   unset CLAUDE_BYPASS_HOOKS  # Remember to disable after!\n`);
//     }
//
//     // Block silently (exit code 2)
//     process.exit(2);
//   }
//
//   // Allow operation
//   process.exit(0);
// }
//
// function extractPathFromBashCommand(command) {
//   if (!command) return null;
//
//   // Extract paths from common commands
//   const catMatch = command.match(/\bcat\s+([^\s;|&]+)/);
//   const grepMatch = command.match(/\bgrep\s+.*?\s+([^\s;|&]+)/);
//   const lsMatch = command.match(/\bls\s+([^\s;|&]+)/);
//   const headMatch = command.match(/\bhead\s+([^\s;|&]+)/);
//   const tailMatch = command.match(/\btail\s+([^\s;|&]+)/);
//
//   if (catMatch) return catMatch[1];
//   if (grepMatch) return grepMatch[1];
//   if (lsMatch) return lsMatch[1];
//   if (headMatch) return headMatch[1];
//   if (tailMatch) return tailMatch[1];
//
//   return null;
// }
//
// function readLastBlockedPath() {
//   try {
//     if (fs.existsSync(LAST_BLOCK_FILE)) {
//       return fs.readFileSync(LAST_BLOCK_FILE, 'utf8').trim();
//     }
//   } catch (error) {
//     // Ignore errors
//   }
//   return null;
// }
//
// function saveBlockedPath(path) {
//   try {
//     fs.writeFileSync(LAST_BLOCK_FILE, path, 'utf8');
//   } catch (error) {
//     // Ignore errors - not critical
//   }
// }
