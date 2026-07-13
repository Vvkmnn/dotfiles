#!/usr/bin/env node

/**
 * Claude Code PreToolUse Hook
 * 
 * Handles three main scenarios:
 * 1. File Operations (Edit/MultiEdit/Write) - Shows current content before modification
 * 2. Destructive Commands (rm) - Requires confirmation before execution
 * 3. Git Operations - Requires confirmation before any git command
 */

const fs = require('fs');
const readline = require('readline');
const { exec } = require('child_process');

// Read JSON input from stdin
let inputData = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => {
  inputData += chunk;
});

process.stdin.on('end', async () => {
  try {
    const hookInput = JSON.parse(inputData);
    await processHook(hookInput);
  } catch (error) {
    console.error('❌ Hook Error:', error.message);
    process.exit(1);
  }
});

async function processHook(hookInput) {
  const { tool_name, tool_input } = hookInput;

  switch (tool_name) {
    case 'Edit':
    case 'MultiEdit':
    case 'Write':
      await handleFileOperation(tool_name, tool_input);
      break;
    
    case 'Bash':
      await handleBashCommand(tool_input);
      break;
    
    default:
      // Allow other tools to proceed
      process.exit(0);
  }
}

async function handleFileOperation(toolName, toolInput) {
  const filePath = toolInput.file_path;
  
  if (!filePath) {
    process.exit(0);
  }

  // Check if file exists and automatically provide content to Claude
  if (fs.existsSync(filePath)) {
    try {
      const content = fs.readFileSync(filePath, 'utf8');
      
      // Send file content to Claude via stderr (gets fed back automatically)
      console.error(`📄 Auto-reading file: ${filePath}`);
      console.error('─'.repeat(50));
      
      if (content.length > 2000) {
        console.error(content.substring(0, 2000) + '\n...[Content truncated - showing first 2000 chars]');
      } else {
        console.error(content);
      }
      console.error('─'.repeat(50));
      console.error(`✅ File content provided to Claude. Please retry your ${toolName} operation.`);
      
      // Block this operation so Claude processes the content, then user can retry
      process.exit(2);
      
    } catch (error) {
      console.error(`⚠️ Could not auto-read file: ${error.message}`);
    }
  }
  
  // Allow operations on new files to proceed
  process.exit(0);
}

async function handleBashCommand(toolInput) {
  const command = toolInput.command;
  
  if (!command) {
    process.exit(0);
  }

  // Check for git operations
  if (/\bgit\s+/.test(command)) {
    console.log('🔒 Git operation detected:');
    console.log(`Command: ${command}`);
    const confirmed = await askConfirmation('Do you want to proceed with this git operation?');
    process.exit(confirmed ? 0 : 1);
  }

  // Check for rm operations - ALWAYS BLOCK
  if (/\brm\s+/.test(command)) {
    console.error('🚫 rm operation BLOCKED - destructive commands not allowed');
    console.error(`Blocked command: ${command}`);
    process.exit(2);
  }

  // Allow other bash commands to proceed
  process.exit(0);
}

function askConfirmation(question) {
  return new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    rl.question(`${question} (y/N): `, (answer) => {
      rl.close();
      resolve(answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes');
    });
  });
}