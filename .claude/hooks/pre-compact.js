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

    const planDir = findPlanDir(path.join(cwd, '.claude', 'plans'))
                 || findPlanDir(path.join(process.env.HOME, '.claude', 'plans'));
    if (!planDir) process.exit(0);

    const planFile = findMostRecentPlan(planDir);
    if (!planFile) process.exit(0);

    const planContent = fs.readFileSync(planFile, 'utf8');
    const lineCount = planContent.split('\n').length;
    if (lineCount < 10) process.exit(0);

    // Skip completed plans — no reason to add resume instructions
    const hasPending = /^- \[ \] /m.test(planContent);
    if (!hasPending) process.exit(0);

    // Extract plan title for relevance context
    const titleMatch = planContent.match(/^# (.+)$/m);
    const planTitle = titleMatch ? titleMatch[1].trim() : path.basename(planFile, '.md');

    // Deduplicate: skip if checkpoint added in last 5 minutes
    const checkpointRegex = /\n\n<!-- compaction-checkpoint:\d+ -->\n(?:> [^\n]*\n)+/g;
    const checkpointTimestamps = planContent.match(/<!-- compaction-checkpoint:(\d+) -->/g);
    if (checkpointTimestamps) {
      const lastTs = parseInt(checkpointTimestamps[checkpointTimestamps.length - 1].match(/(\d+)/)[1]);
      if (Date.now() - lastTs < 5 * 60 * 1000) process.exit(0);
    }

    // Remove all previous checkpoint markers before adding new one (keep only latest)
    let cleaned = planContent.replace(checkpointRegex, '');
    // Strip orphaned old-format lines only from tail (after last ## heading) to avoid
    // clobbering plan content that happens to contain those phrases in blockquotes
    const lastHeadingIdx = cleaned.lastIndexOf('\n## ');
    if (lastHeadingIdx !== -1) {
      const head = cleaned.slice(0, lastHeadingIdx);
      const tail = cleaned.slice(lastHeadingIdx);
      cleaned = head + tail.replace(/\n(?:> (?:BEFORE continuing|Task audit|Then create Tasks|Call TaskUpdate|Do NOT re-investigate)[^\n]*\n?)+/g, '\n');
    }

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

    const planBasename = path.basename(planFile);
    const planMtime = fs.statSync(planFile).mtimeMs;
    // Check if plan was recently user-edited (not just hook-updated).
    // The hook itself updates mtime on every compaction, so raw mtime is unreliable.
    // If mtime is close to the last checkpoint timestamp, only the hook touched it.
    const lastCheckpointTs = checkpointTimestamps
      ? parseInt(checkpointTimestamps[checkpointTimestamps.length - 1].match(/(\d+)/)[1])
      : 0;
    const recentlyUserEdited = lastCheckpointTs > 0
      ? (planMtime - lastCheckpointTs > 60000) && (Date.now() - planMtime < 3600000)
      : (Date.now() - planMtime < 3600000);

    let newCheckpoint =
      `\n\n<!-- compaction-checkpoint:${Date.now()} -->\n` +
      `> **Compaction checkpoint** (${ts}): Plan: **${planTitle}** (\`plans/${planBasename}\`) | ${statusLine}\n`;
    if (!recentlyUserEdited) {
      newCheckpoint += `> **Relevance check**: Does "${planTitle}" match the user's current ask? If not, suggest starting fresh.\n`;
    }
    // Build plan history — recent non-agent plans with pending items (max 3)
    const history = buildPlanHistory(planDir, planFile);
    if (history) {
      newCheckpoint += `> **Plan history**: ${history}\n`;
    }

    fs.writeFileSync(planFile, cleaned + newCheckpoint);
    process.exit(0);
  } catch {
    process.exit(0); // Fail open
  }
});

function findPlanDir(dir) {
  try {
    const stat = fs.statSync(dir);
    return stat.isDirectory() ? dir : null;
  } catch { return null; }
}

function findMostRecentPlan(dir) {
  try {
    const plans = fs.readdirSync(dir)
      .filter(f => f.endsWith('.md') && !f.includes('-agent-'))
      .map(f => {
        const fp = path.join(dir, f);
        const content = fs.readFileSync(fp, 'utf8');
        return {
          path: fp,
          mtime: fs.statSync(fp).mtimeMs,
          hasPending: /^- \[ \] /m.test(content)
        };
      })
      .sort((a, b) => b.mtime - a.mtime);
    // Prefer most recent plan with pending items; fall back to most recent overall
    return (plans.find(p => p.hasPending) || plans[0])?.path || null;
  } catch { return null; }
}

function buildPlanHistory(dir, activePlan) {
  try {
    const activeBase = path.basename(activePlan);
    let completedCount = 0;
    const active = fs.readdirSync(dir)
      .filter(f => f.endsWith('.md') && !f.includes('-agent-') && f !== activeBase)
      .map(f => {
        const fp = path.join(dir, f);
        const content = fs.readFileSync(fp, 'utf8');
        const titleMatch = content.match(/^# (.+)$/m);
        const done = (content.match(/^- \[x\] /gm) || []).length;
        const pending = (content.match(/^- \[ \] /gm) || []).length;
        if (pending === 0 && done > 0) { completedCount++; return null; }
        if (!titleMatch || pending === 0) return null;
        const nextItem = (content.match(/^- \[ \] \*\*(.+?)\*\*/m) || [])[1] || null;
        return {
          name: f, mtime: fs.statSync(fp).mtimeMs,
          title: titleMatch[1].substring(0, 40),
          done, pending, nextItem
        };
      })
      .filter(Boolean)
      .sort((a, b) => b.mtime - a.mtime);

    // Dedup by title (keep most recent)
    const seen = new Set();
    const deduped = active.filter(p => {
      if (seen.has(p.title)) return false;
      seen.add(p.title);
      return true;
    });

    const entries = deduped.slice(0, 3).map(p => {
      const next = p.nextItem ? `, next: ${p.nextItem.substring(0, 30)}` : '';
      return `\`${p.name}\` (${p.title}, ${p.done}/${p.done + p.pending}${next})`;
    });

    if (entries.length === 0 && completedCount === 0) return null;
    const suffix = completedCount > 0 ? ` | (${completedCount} done)` : '';
    return entries.join(' | ') + suffix;
  } catch { return null; }
}
