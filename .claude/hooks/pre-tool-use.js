#!/usr/bin/env node

/**
 * Claude Code PreToolUse Hook
 *
 * Runs before tool execution. Uses hookSpecificOutput with
 * permissionDecision to control tool approval:
 *   "ask"  — force manual per-command approval prompt
 *   "deny" — block with reason shown to Claude
 *   "allow" — bypass permission check
 *
 * Fail-safe: any error → deny (not allow).
 *
 * ── Adding new restrictions ──────────────────────────────────
 * To require explicit approval before a command runs ("ask"):
 *   Add a pattern to the "Ask" section in processToolRequest().
 *   Message format: '[What the command does]. Confirm before approving.'
 *
 * To block a command outright ("deny"):
 *   Add a pattern to the "Hard deny" section in processToolRequest().
 *   Message format: '[What is blocked]. Run manually if intended.'
 *
 * Discuss with user before adding or removing entries.
 * ─────────────────────────────────────────────────────────────
 *
 * ── History ──────────────────────────────────────────────────
 * Deny rules were originally split into a separate PermissionRequest
 * hook (permission-request.js). That hook event is not documented by
 * Claude Code — valid events are PreToolUse, PostToolUse, Stop,
 * SessionStart, Notification, PreCompact, UserPromptSubmit. The split
 * also caused a bug: PreToolUse returned "ask" for commands that
 * PermissionRequest would deny, so the tool call appeared before
 * being blocked. Merged all deny rules here 2026-03-11.
 *
 * Past format pitfalls (avoid repeating):
 * - PermissionRequest used { decision.behavior: "deny" } not
 *   { permissionDecision: "deny" } — different from PreToolUse.
 * - PermissionRequest received { tool_name, tool_input }, not
 *   { tool, input } — an earlier version destructured wrong fields
 *   so every condition was silently false (no-op).
 * ─────────────────────────────────────────────────────────────
 */

const fs = require('fs');
const path = require('path');

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
    // Fail-safe: deny on any error (not fail-open)
    console.log(JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        permissionDecision: 'deny',
        permissionDecisionReason: 'PreToolUse hook error — blocking as safety precaution.'
      }
    }));
    process.exit(0);
  }
});

function ask(reason) {
  return {
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      permissionDecision: 'ask',
      permissionDecisionReason: reason
    }
  };
}

function deny(reason) {
  return {
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      permissionDecision: 'deny',
      permissionDecisionReason: reason
    }
  };
}

function extractWriteContent(input, toolName) {
  if (toolName === 'Write') return input?.content || '';
  if (toolName === 'Edit') return input?.new_string || '';
  if (toolName === 'NotebookEdit') return input?.new_source || '';
  if (toolName === 'MultiEdit') {
    return (input?.edits || []).map(e => e.new_string || '').join('\n');
  }
  return '';
}

function isPlaceholderCode(text) {
  return [
    // Action TODOs — organizational TODOs ("TODO: move to utils") won't match
    /\/\/\s*TODO:?\s*(implement|add|fix|complete|finish|write|handle)/i,
    /#\s*TODO:?\s*(implement|add|fix|complete|finish|write|handle)/i,
    // Explicit stub/placeholder markers
    /\/\/\s*(placeholder|stub implementation|fallback impl)/i,
    /#\s*(placeholder|stub implementation|fallback impl)/i,
    // "Not implemented" throws
    /throw\s+new\s+Error\s*\(\s*['"`][^'"]*not\s+implement/i,
    /raise\s+NotImplementedError\s*(\(|$)/,
    // Language-specific not-implemented idioms
    /\bunimplemented!\s*\(\)/,                            // Rust
    /\btodo!\s*\(\)/,                                     // Rust
    /fatalError\s*\(\s*['"].*not\s+implement/i,           // Swift
    // Hardcoded fake data markers (requires context word to avoid false positives)
    /\/\/\s*(fake|mock|dummy)\s+(data|response|result|implementation)/i,
    /#\s*(fake|mock|dummy)\s+(data|response|result|implementation)/i,
  ].some(p => p.test(text));
}

// Strip global flags that can be inserted between command and subcommand to bypass patterns.
// e.g. `git -C /path commit` → `git commit`, `chmod -R 777` → `chmod 777`
function normalizeCmd(cmd) {
  let n = cmd;
  // Git: strip global flags before subcommand (flags that go between `git` and the subcommand)
  n = n.replace(
    /\bgit\b((?:\s+(?:-C\s+\S+|-c\s+\S+|--git-dir[= ]\S+|--work-tree[= ]\S+|--namespace[= ]\S+|--config-env[= ]\S+|--exec-path[= ]\S*|--no-pager|--bare|--no-replace-objects|--literal-pathspecs|--glob-pathspecs|--noglob-pathspecs|--icase-pathspecs|--no-optional-locks|-[pP]))+)/g,
    'git'
  );
  // chmod: strip flags before mode so `chmod -R 777` → `chmod 777`
  n = n.replace(/\bchmod\b((?:\s+(?:-[a-zA-Z]+|--[a-z-]+))*)/g, 'chmod');
  return n;
}

function processToolRequest(data) {
  const { tool_name, tool_input } = data;

  if (tool_name === 'Bash') {
    const cmd = tool_input?.command || '';
    const n = normalizeCmd(cmd);

    // ── Hard deny (run these yourself) ──────────────────────────
    if (/\bmkfs\b/.test(cmd)) {
      return deny('mkfs formats filesystems. Run manually if intended.');
    }
    if (/\bdd\b/.test(cmd) && (/if=\/dev\//.test(cmd) || /of=\/dev\//.test(cmd))) {
      return deny('dd targeting device files. Run manually if intended.');
    }
    if (/(?:^|[;&|]\s*|&&\s*|\|\|\s*|\$\()sudo\s/.test(cmd)) {
      return deny('sudo commands require manual execution.');
    }
    if (/\bchmod\s+777\b/.test(n)) {
      return deny('chmod 777 is insecure. Use more restrictive permissions.');
    }
    if (/git\s+filter-(?:branch|repo)\b/.test(n)) {
      return deny('git filter-branch/filter-repo irreversibly rewrites history. Run manually if intended.');
    }
    if (/\bfind\b.*-delete\b/.test(cmd)) {
      return deny('find -delete silently removes all matched files. Run manually if intended.');
    }
    if (/\bdiskutil\s+(?:erase|secureErase|zeroDisk)\b/.test(cmd)) {
      return deny('diskutil erase destroys filesystem data. Run manually if intended.');
    }
    if (/\bdscl\b.*\bdelete\b/.test(cmd)) {
      return deny('dscl delete modifies system directory records. Run manually if intended.');
    }
    // Recursive rm on absolute/home/wildcard paths
    if (/\brm\b/.test(cmd) && (/\s-[a-zA-Z]*r/.test(cmd) || /--recursive/.test(cmd))
        && (/\s[\/~]/.test(cmd) || /\s\*/.test(cmd))) {
      return deny('Recursive delete on absolute/home/wildcard path blocked.');
    }

    // ── Ask (prompt every time) ─────────────────────────────────

    // Any rm command — stronger warning for recursive
    if (/\brm\b/.test(cmd)) {
      const isRecursive = /\s-[a-zA-Z]*r/.test(cmd) || /--recursive/.test(cmd);
      return ask(isRecursive
        ? 'DESTRUCTIVE: Recursive delete. Confirm exact path before approving.'
        : 'File deletion. Confirm target before approving.');
    }

    // In-place file editing — bypasses Edit tool diff review
    if (/\b(?:sed|perl)\s.*-i\b/.test(cmd)) {
      return ask('In-place file edit bypasses diff review. Confirm before approving.');
    }

    // File truncation — silent data loss
    // Match: `> file`, `echo > file`, but NOT `2>/dev/null`, `>/dev/null`, `>>file`
    if (/\btruncate\b/.test(cmd) || /(?:^|[;&|])\s*>\s*(?!\/dev\/null)\S+/.test(cmd)) {
      return ask('File truncation/overwrite. Confirm target before approving.');
    }

    // dd (non-device targets) — still dangerous
    if (/\bdd\b/.test(cmd)) {
      return ask('dd is a raw data tool. Confirm parameters before approving.');
    }

    // Destructive git — reset, clean, stash drop, branch -D, push --delete
    if (/git\s+reset\s+--hard/.test(n)) {
      return deny('Hard reset blocked. This discards uncommitted changes.');
    }
    if (/git\s+clean\s+-[a-zA-Z]*f[a-zA-Z]*/.test(n)) {
      return ask('Cleaning untracked files discards uncommitted changes. Confirm before approving.');
    }
    if (/git\s+stash\s+drop/.test(n)) {
      return ask('Dropping a stash permanently deletes it. Confirm before approving.');
    }
    if (/git\s+branch\s+-[a-zA-Z]*D/.test(n)) {
      return ask('Force deleting a branch removes it even if unmerged. Confirm before approving.');
    }
    if (/git\s+push\s+\S+\s+--delete/.test(n) || /git\s+push\s+\S+\s+:/.test(n)) {
      return ask('Deleting a remote branch. Confirm before approving.');
    }
    if (/git\s+checkout\s+--\s/.test(n)) {
      return ask('Checking out a file from git discards uncommitted changes. Confirm before approving.');
    }
    // Catches: git checkout . / git checkout file.ext / git checkout src/file.c (no -- separator)
    if (/git\s+checkout\s+(?:\.|[^-]\S*\.\w+)/.test(n)) {
      return ask('Checking out a file path from git discards uncommitted changes. Confirm before approving.');
    }
    if (/git\s+rebase\b(?!\s*(?:--abort|--continue|--skip))/.test(n)) {
      return ask('Rebasing rewrites commit history. Confirm before approving.');
    }
    if (/git\s+restore\b/.test(n)) {
      return ask('Restoring a file from git discards uncommitted changes. Confirm before approving.');
    }
    if (/git\s+reflog\s+expire/.test(n)) {
      return ask('Expiring reflogs removes the ability to recover lost commits. Confirm before approving.');
    }

    // Git commit/add/push — require explicit user request
    if (/git\s+commit\s+.*--amend/.test(n)) {
      return ask('git commit --amend rewrites the previous commit (destroys its original state). Confirm before approving.');
    }
    if (/git\s+tag\s+(-d|--delete)\b/.test(n)) {
      return ask('Deleting a git tag. Tags may be referenced by releases/CI. Confirm before approving.');
    }
    if (/git\s+commit\b/.test(n)) {
      return ask('Committing changes to git. Confirm before approving.');
    }
    if (/git\s+add\b/.test(n) && !/git\s+add\s+-n\b/.test(n)) {
      return ask('Staging files for git commit. Confirm before approving.');
    }
    if (/git\s+push\s+.*--force-with-lease/.test(n)) {
      return ask('Force push with lease (safe variant). Confirm before approving.');
    }
    if (/git\s+push\s+.*--force/.test(n) || /git\s+push\s+-f\b/.test(n)) {
      return deny('Force push blocked. Use --force-with-lease or ask explicitly.');
    }
    if (/git\s+push\s+.*(--delete|:\S)/.test(n)) {
      return ask('Deleting a remote ref (branch/tag). This removes it for everyone. Confirm before approving.');
    }
    if (/git\s+push\b/.test(n)) {
      return ask('Pushing to remote repository. Confirm before approving.');
    }

    // Secure deletion and system daemon management
    if (/\bshred\b/.test(cmd)) {
      return ask('Shred securely deletes files with no recovery possible. Confirm before approving.');
    }
    if (/\blaunchctl\s+(bootout|remove)\b/.test(cmd)) {
      return ask('Unloading a system daemon can break services. Confirm before approving.');
    }

    // Process killing
    if (/\bkillall\b/.test(cmd) || /\bkill\s+(?:-9|-s\s+(?:9|KILL|SIGKILL)|-KILL|-SIGKILL)\b/.test(cmd) || /\bpkill\b/.test(cmd)) {
      return ask('Process kill command. Confirm target before approving.');
    }
  }

  // ── Plan files — tiered Write protection (Edit always allowed) ──────
  if (tool_name === 'Write') {
    const filePath = tool_input?.file_path || '';
    if (/\.claude\/plans\/.*\.md$/.test(filePath)) {
      const inPlanMode = data.permission_mode === 'plan';

      if (fs.existsSync(filePath)) {
        // Existing file — tiered protection based on content and mode
        const content = fs.readFileSync(filePath, 'utf8');
        const done = (content.match(/^- \[x\] .+$/gm) || []).length;
        const pending = (content.match(/^- \[ \] .+$/gm) || []).length;
        const total = done + pending;

        // Plan mode + no pending items → no friction for new tasks
        if (inPlanMode && pending === 0) return {};

        // Plan mode + pending items → soft ask
        if (inPlanMode && pending > 0) {
          return ask(
            `Plan has ${pending} pending items (${done} done). ` +
            'Building on it, or starting fresh?'
          );
        }

        // Implementation mode → contextual ask (nothing banned, just informed)
        if (pending > 0) {
          return ask(
            `Plan has ${pending} pending and ${done} done items (${total} total). ` +
            'Rewriting will lose this progress. Approve if starting a genuinely new task.'
          );
        }
        if (done > 0 && pending === 0) {
          return ask(
            `Plan is fully complete (${done}/${total} done). Safe to rewrite for new task.`
          );
        }
        return ask('Rewriting plan file with no status markers. Approve if intentional.');

      } else if (!inPlanMode) {
        // New file outside plan mode — unusual, warn
        return ask('Creating new plan file outside plan mode. Approve if intentional.');

      } else {
        // New file in plan mode — check for sibling plans with pending items
        const plansDir = path.dirname(filePath);
        try {
          if (fs.existsSync(plansDir)) {
            const siblings = fs.readdirSync(plansDir).filter(f => f.endsWith('.md') && !f.includes('-agent-'));
            for (const sib of siblings) {
              const sibContent = fs.readFileSync(path.join(plansDir, sib), 'utf8');
              const pending = (sibContent.match(/^- \[ \] .+$/gm) || []).length;
              if (pending > 0) {
                return ask(
                  `Creating new plan while ${sib} has ${pending} pending items. ` +
                  'Approve if this is a different task.'
                );
              }
            }
          }
        } catch { /* fail open */ }
      }
    }
  }

  // ── Write/Edit tools — block placeholder/stub/fallback code ──────────
  if (['Write', 'Edit', 'MultiEdit', 'NotebookEdit'].includes(tool_name)) {
    const content = extractWriteContent(tool_input, tool_name);
    if (content && isPlaceholderCode(content)) {
      return deny(
        'Placeholder, stub, or fallback code detected. Implement completely, ' +
        'or stop and explain what is blocking you.'
      );
    }
  }

  return {};
}
