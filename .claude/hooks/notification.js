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
 * - Duration tracking (time since prompt submitted)
 * - Click-to-navigate (Ghostty + tmux integration)
 * - Custom development tool icons (Ghostty priority)
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
  console.log('🔍 Claude notification triggered');

  const context = await gatherContext();
  const eventType = hookInput.hook_event_name || 'Notification';
  const notifType = hookInput.notification_type || '';

  // Build informative subtitle: [type] repo (branch) @ tmux
  const subtitle = formatSubtitle(context, eventType, notifType);

  // Use Claude's message, with fallback
  const message = hookInput.message || 'Claude needs your attention';

  // Simple notification (click action broken on modern macOS)
  const title = "🤖 Claude Code";
  // Icon options - Ghostty has known icon caching issues on macOS
  // const sender = '-sender "com.anthropic.claudefordesktop"';  // Claude app
  // const sender = '-sender "com.mitchellh.ghostty"';  // Ghostty (unreliable)
  const sender = '-sender "com.apple.Terminal"';  // Terminal (reliable)
  const notifyCmd = `terminal-notifier -title "${title}" -subtitle "${subtitle}" -message "${message}" ${sender} -sound default -timeout 30`;

  exec(notifyCmd, (error) => {
    if (error) {
      console.error('❌ Notification failed:', error);
      // Fallback to osascript
      const fallback = `osascript -e 'display notification "${message}" with title "${title}" subtitle "${subtitle}" sound name "default"'`;
      exec(fallback, () => process.exit(0));
    } else {
      console.log('✅ Notification sent');
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
    timestamp: new Date().toLocaleTimeString(),
    duration: getDuration()
  };

  return context;
}

// Duration tracking - reads state from prompt-submit.js hook
function getDuration() {
  const stateFile = path.join(process.env.HOME, '.claude', 'hooks', '.task-state.json');
  try {
    const state = JSON.parse(fs.readFileSync(stateFile, 'utf8'));
    const elapsed = Date.now() - state.startTime;
    const mins = Math.floor(elapsed / 60000);
    const secs = Math.floor((elapsed % 60000) / 1000);
    if (mins > 0) {
      return `${mins}m ${secs}s`;
    }
    return `${secs}s`;
  } catch (e) {
    return null;
  }
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

function selectIcon() {
  // Use Terminal - has notification permissions by default
  // To use Ghostty: enable in System Settings > Notifications
  return 'com.apple.Terminal';
}

function formatMessage(context) {
  const [session, window] = context.tmuxInfo.split(':');
  return `In window "${context.tmuxInfo}" of session "${session}"`;
}

function formatSubtitle(context, eventType, notifType) {
  // Event type prefix
  let prefix = '';
  if (eventType === 'Stop') {
    prefix = '✓ Done';
  } else if (notifType === 'permission_prompt') {
    prefix = '⚠️ Permission';
  } else if (notifType === 'idle_prompt') {
    prefix = '⏸️ Waiting';
  } else if (notifType === 'elicitation_dialog') {
    prefix = '❓ Input needed';
  } else {
    prefix = '📢 Attention';
  }

  // Project info
  let project;
  if (context.gitInfo.isGitRepo) {
    const status = context.gitInfo.hasChanges ? '*' : '';
    project = `${context.gitInfo.repoName}:${context.gitInfo.branch}${status}`;
  } else {
    project = context.dirName;
  }

  // tmux location
  const location = context.tmuxInfo || '';

  return `${prefix} | ${project} @ ${location}`;
}