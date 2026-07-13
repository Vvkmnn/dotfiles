#!/usr/bin/env node

/**
 * Enhanced Claude Code Notification Hook
 * 
 * Triggered when Claude Code sends notifications:
 * 1. Claude needs permission to use a tool
 * 2. Prompt input has been idle for 60+ seconds
 * 
 * Features:
 * - Rich contextual information (git repo, branch, project type)
 * - Custom development tool icons
 * - Enhanced location details
 * - No sound disturbance
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

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

async function processHook(hookInput) {
  console.log('🔍 Enhanced Claude notification triggered');
  
  const context = await gatherContext();
  const icon = await selectIcon();
  
  const message = formatMessage(context);
  const subtitle = formatSubtitle(context);
  
  // Enhanced terminal-notifier command (no sound)
  const title = "🤖 Claude Code";
  const notifyCmd = `terminal-notifier -title "${title}" -subtitle "${subtitle}" -message "${message}" -sender "${icon}" -timeout 37`;
  
  exec(notifyCmd, (error) => {
    if (error) {
      console.error('❌ Enhanced notification failed:', error);
      // Fallback to basic notification
      const fallbackCmd = `terminal-notifier -title "Claude Code" -message "Claude needs attention" -timeout 15`;
      exec(fallbackCmd, () => process.exit(0));
    } else {
      console.log('✅ Enhanced notification sent successfully');
      process.exit(0);
    }
  });
}

async function gatherContext() {
  const context = {
    workingDir: process.cwd(),
    dirName: path.basename(process.cwd()),
    tmuxInfo: await getTmuxInfo(),
    gitInfo: await getGitInfo(),
    projectType: await detectProjectType(),
    timestamp: new Date().toLocaleTimeString()
  };
  
  return context;
}

function getTmuxInfo() {
  return new Promise((resolve) => {
    exec('tmux display-message -p "#S:#W"', (error, stdout) => {
      if (error) {
        const fallback = `${process.env.TMUX_SESSION || 'unknown'}:${process.env.TMUX_WINDOW || process.env.TMUX_PANE || 'unknown'}`;
        resolve(fallback);
      } else {
        resolve(stdout.trim());
      }
    });
  });
}

function getGitInfo() {
  return new Promise((resolve) => {
    exec('git rev-parse --show-toplevel 2>/dev/null', (error, repoPath) => {
      if (error) {
        resolve({ isGitRepo: false });
        return;
      }
      
      const repoName = path.basename(repoPath.trim());
      
      exec('git branch --show-current 2>/dev/null', (branchError, branch) => {
        const currentBranch = branchError ? 'unknown' : branch.trim();
        
        exec('git status --porcelain 2>/dev/null', (statusError, status) => {
          const hasChanges = !statusError && status.trim().length > 0;
          
          resolve({
            isGitRepo: true,
            repoName,
            branch: currentBranch,
            hasChanges
          });
        });
      });
    });
  });
}

function detectProjectType() {
  return new Promise((resolve) => {
    const projectFiles = [
      { file: 'package.json', type: 'Node.js' },
      { file: 'requirements.txt', type: 'Python' },
      { file: 'Cargo.toml', type: 'Rust' },
      { file: 'go.mod', type: 'Go' },
      { file: 'pom.xml', type: 'Java' },
      { file: 'Gemfile', type: 'Ruby' },
      { file: 'composer.json', type: 'PHP' },
      { file: '.sln', type: '.NET' }
    ];
    
    for (const { file, type } of projectFiles) {
      if (fs.existsSync(path.join(process.cwd(), file))) {
        resolve(type);
        return;
      }
    }
    
    resolve('Unknown');
  });
}

async function selectIcon() {
  const iconOptions = [
    'com.anthropic.claude',      // Claude (if available)
    'com.microsoft.VSCode',      // VS Code
    'com.apple.dt.Xcode',        // Xcode  
    'com.apple.Terminal'         // Terminal fallback
  ];
  
  // Test which icons are available
  for (const bundleId of iconOptions) {
    try {
      await testBundleId(bundleId);
      return bundleId;
    } catch (error) {
      continue;
    }
  }
  
  return 'com.apple.Terminal'; // Ultimate fallback
}

function testBundleId(bundleId) {
  return new Promise((resolve, reject) => {
    exec(`osascript -e 'tell application "System Events" to get name of application processes whose bundle identifier is "${bundleId}"'`, (error, stdout) => {
      if (error || !stdout.trim()) {
        reject(error);
      } else {
        resolve(bundleId);
      }
    });
  });
}

function formatMessage(context) {
  const [session, window] = context.tmuxInfo.split(':');
  return `In window "${context.tmuxInfo}" of session "${session}"`;
}

function formatSubtitle(context) {
  if (context.gitInfo.isGitRepo) {
    const status = context.gitInfo.hasChanges ? ' *' : '';
    return `Human needed for ${context.gitInfo.repoName} (${context.gitInfo.branch}${status})`;
  } else {
    return `Human needed for ${context.dirName}`;
  }
}