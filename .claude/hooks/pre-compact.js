#!/usr/bin/env node

/**
 * PreCompact Hook — Plan Checkpoint
 *
 * Appends a visible reminder to the active plan file before compaction,
 * so Claude sees it when re-reading the plan post-compaction.
 *
 * Fires on: PreCompact (manual and auto)
 * Fails open — compaction must never be blocked.
 */

const fs = require('fs');
const path = require('path');

let inputData = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => { inputData += chunk; });

process.stdin.on('end', () => {
  try {
    const hookInput = JSON.parse(inputData);
    const cwd = hookInput.cwd || process.cwd();

    const planFile = findMostRecentPlan(path.join(cwd, '.claude', 'plans'))
                  || findMostRecentPlan(path.join(process.env.HOME, '.claude', 'plans'));
    if (!planFile) process.exit(0);

    const planContent = fs.readFileSync(planFile, 'utf8');
    const lineCount = planContent.split('\n').length;
    if (lineCount < 10) process.exit(0);

    // Extract plan title for relevance context
    const titleMatch = planContent.match(/^# (.+)$/m);
    const planTitle = titleMatch ? titleMatch[1].trim() : path.basename(planFile, '.md');

    // Deduplicate: skip if checkpoint added in last 5 minutes
    const checkpointRegex = /\n\n<!-- compaction-checkpoint:\d+ -->\n> \*\*Compaction checkpoint\*\*[^\n]*\n/g;
    const checkpointTimestamps = planContent.match(/<!-- compaction-checkpoint:(\d+) -->/g);
    if (checkpointTimestamps) {
      const lastTs = parseInt(checkpointTimestamps[checkpointTimestamps.length - 1].match(/(\d+)/)[1]);
      if (Date.now() - lastTs < 5 * 60 * 1000) process.exit(0);
    }

    // Remove all previous checkpoint markers before adding new one (keep only latest)
    const cleaned = planContent.replace(checkpointRegex, '');

    // Parse checkboxes for status snapshot
    const doneItems = (cleaned.match(/^- \[x\] .+$/gm) || []);
    const pendingItems = (cleaned.match(/^- \[ \] .+$/gm) || []);
    const doneCount = doneItems.length;
    const pendingCount = pendingItems.length;
    const totalCount = doneCount + pendingCount;

    // Extract next 3 pending item names (strip checkbox prefix, truncate)
    const nextPending = pendingItems.slice(0, 3).map(item =>
      item.replace(/^- \[ \] /, '').replace(/ — .+$/, '').substring(0, 60)
    );

    // Auto-sync progress line at top of plan file
    if (totalCount > 0) {
      const progressRegex = /^\*\*Progress: \d+\/\d+ done\*\*.*$/m;
      const activeItem = nextPending.length > 0
        ? nextPending[0].replace(/^\*\*/, '').replace(/\*\*$/, '')
        : 'All complete';
      const newProgress = `**Progress: ${doneCount}/${totalCount} done** | Active: ${activeItem}`;
      if (progressRegex.test(cleaned)) {
        cleaned = cleaned.replace(progressRegex, newProgress);
      }
    }

    const ts = new Date().toISOString().replace('T', ' ').slice(0, 19);
    const statusLine = totalCount > 0
      ? `Status: ${doneCount}/${totalCount} done.` +
        (nextPending.length > 0 ? ` Next: ${nextPending.join(', ')}.` : ' All items complete.')
      : `Plan has ${lineCount} lines.`;

    // Task audit nudge: if plan has [x] items, remind about TaskUpdate
    const taskAudit = doneCount > 0
      ? `> **Task audit**: ${doneCount} plan items are [x]. Verify each has a matching TaskUpdate → completed — the Flowing display only updates via TaskUpdate.\n`
      : '';

    const newCheckpoint =
      `\n\n<!-- compaction-checkpoint:${Date.now()} -->\n` +
      `> **Compaction checkpoint** (${ts}): Plan: **${planTitle}** | ${statusLine}\n` +
      `> **Relevance check**: Does "${planTitle}" match the user's current ask? If not, suggest starting fresh — don't blindly continue.\n` +
      taskAudit +
      `> BEFORE continuing: if you completed plan items, update them to [x] using Edit.\n` +
      `> Call TaskUpdate → completed for each finished item — the Flowing display ONLY updates via TaskUpdate.\n` +
      `> Then create Tasks from remaining [ ] items. Do NOT re-investigate [x] items.\n`;

    fs.writeFileSync(planFile, cleaned + newCheckpoint);
    process.exit(0);
  } catch {
    process.exit(0); // Fail open
  }
});

function findMostRecentPlan(dir) {
  try {
    return fs.readdirSync(dir)
      .filter(f => f.endsWith('.md'))
      .map(f => ({ path: path.join(dir, f), mtime: fs.statSync(path.join(dir, f)).mtimeMs }))
      .sort((a, b) => b.mtime - a.mtime)[0]?.path || null;
  } catch { return null; }
}
