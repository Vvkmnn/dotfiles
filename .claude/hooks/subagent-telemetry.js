#!/usr/bin/env node

/**
 * Claude Code SubagentStart/SubagentStop Hook
 *
 * Minimal agent-usage telemetry to stderr only (no disk artifacts per house rule).
 * Answers "which agents earn their keep" — visible in debug logs, greppable via
 * `claude doctor` output or debug/ session logs when investigating.
 * Added 2026-07-06 (Tier 4, deep-upgrade plan).
 */

let inputData = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (c) => { inputData += c; });

process.stdin.on('end', () => {
  try {
    const evt = JSON.parse(inputData);
    const name = evt.agent_type || evt.subagent_type || evt.agent_name || 'unknown';
    const event = evt.hook_event_name || (evt.duration_ms != null ? 'SubagentStop' : 'SubagentStart');
    const dur = evt.duration_ms != null ? ` ${Math.round(evt.duration_ms / 1000)}s` : '';
    process.stderr.write(`[agent-telemetry] ${event} ${name}${dur}\n`);
  } catch { /* silent */ }
  process.exit(0);
});
