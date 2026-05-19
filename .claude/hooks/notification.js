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
  console.error('Claude notification triggered');

  const context = await gatherContext();
  const eventType = hookInput.hook_event_name || 'Notification';
  const notifType = hookInput.notification_type || '';

  const subtitle = formatSubtitle(context, eventType, notifType);

  // const dir = context.workingDir.replace(process.env.HOME, '~');
  const message = hookInput.message || 'Claude needs your attention';

  // Simple notification (click action broken on modern macOS)
  // const title = "🤖 Claude Code";
  const title = "Claude Code";
  // Icon options - Ghostty has known icon caching issues on macOS
  // -appIcon relies on private API, broken since Big Sur (terminal-notifier#283)
  // -sender only works for system apps on macOS 26+, not custom bundles
  // -contentImage shows inline image reliably — using clawd pixel-art mascot
  const sender = '-sender "com.apple.Terminal"';
  const icon = '-contentImage "$HOME/.claude/clawd.png"';
  const notifyCmd = `terminal-notifier -title "${title}" -subtitle "${subtitle}" -message "${message}" ${sender} ${icon} -timeout 30`;

  // Ring terminal bell for tmux window highlighting
  // Get current pane's tty and write bell directly to it
  exec(`/opt/homebrew/bin/tmux display-message -p '#{pane_tty}'`, (ttyError, ttyPath) => {
    if (!ttyError && ttyPath) {
      const tty = ttyPath.trim();
      exec(`printf "\\a" > ${tty}`, (bellError) => {
        if (bellError) {
          console.error('❌ Bell to tty failed:', bellError);
        }
      });
    }
  });

  exec(notifyCmd, (error) => {
    if (error) {
      console.error('❌ terminal-notifier failed, trying osascript:', error);
      // Fallback to osascript (no sound)
      const fallback = `osascript -e 'display notification "${message}" with title "${title}" subtitle "${subtitle}"'`;
      exec(fallback, () => process.exit(0));
    } else {
      console.error('Notifications sent (bell + macOS)');
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
    exec('/opt/homebrew/bin/tmux display-message -p "v#S|#I|#W"', (error, stdout) => {
      if (error) {
        const fallback = `${process.env.TMUX_SESSION || 'unknown'}:${process.env.TMUX_WINDOW || process.env.TMUX_PANE || 'unknown'}`;
        resolve(fallback);
      } else {
        // Strip automatic-rename path suffix: "claude (~/.claude/hooks)" → "claude"
        resolve(stdout.trim().replace(/\s*\(.*\)$/, ''));
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

function formatSubtitle(context, eventType, notifType) {
  let prefix = '';
  if (eventType === 'Stop') {
    prefix = '✅ Complete';
  } else if (notifType === 'permission_prompt') {
    prefix = '⚠️ Permission';
  } else if (notifType === 'idle_prompt') {
    prefix = '⏸️ Waiting';
  } else if (notifType === 'elicitation_dialog') {
    prefix = '💬 Input';
  } else {
    prefix = '🔔 Attention';
  }

  // Format: v7|8|hooks:main* (tmux session|index|folder:branch)
  const tmux = context.tmuxInfo || '';
  // Use session|index from tmux, folder name from cwd (not tmux window name which includes path)
  const sessionIndex = tmux.replace(/\|[^|]*$/, '');
  let location = `${sessionIndex}|${context.dirName}`;
  if (context.gitInfo.isGitRepo) {
    const status = context.gitInfo.hasChanges ? '*' : '';
    location = `${sessionIndex}|${context.dirName}:${context.gitInfo.branch}${status}`;
  }

  return `${prefix} · ${location}`;
}