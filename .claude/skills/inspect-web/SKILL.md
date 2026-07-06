---
name: inspect-web
author: Vvkmnn
description: Use when debugging web performance, measuring page metrics, "inspect this page", "check Core Web Vitals", "audit performance", or automated browser work. Routes across claude-in-chrome (interactive), agent-browser CLI (headless), npx lighthouse (audits), and the parked chrome-devtools MCP (deep CDP tracing — un-park when needed). Includes Core Web Vitals reference and CDP workflow runbook.
version: 0.3.0
---

# Web Inspection & Testing

## Tool Routing (chrome-devtools MCP parked in fleet decision — docs/CONFIG.md MCP section)

| Task | Use | Why |
|------|-----|-----|
| Browse a page, fill forms, take screenshots | `claude-in-chrome` | NLP element finding, GIF recording, your real browser + auth |
| Headless/scripted automation from Bash | `agent-browser` CLI | `open <url>` → `snapshot` (@refs) → `click @e1` → `close`; 200-400 tok/page |
| Core Web Vitals / performance audit (one-shot) | `npx lighthouse <url> --output json` | No standing server needed |
| Deep CDP work: perf traces, HAR, a11y tree, emulation | `chrome-devtools` MCP — **parked** | Un-park per docs/CONFIG.md restore procedure (move entry back + claude mcp add + kickstart); workflows below are its runbook |
| Read page content, extract text | `claude-in-chrome` or `agent-browser snapshot` | get_page_text / compact refs |

> The CDP workflow sections below are kept verbatim as the runbook for un-parked chrome-devtools sessions — the Core Web Vitals reference tables apply regardless of tool. `browse-claude` skill handles Chrome session bootstrap.

## Core Web Vitals Quick Reference

All measured at **75th percentile** of page loads.

| Metric | Good | Needs Work | Poor | Measures |
|--------|------|-----------|------|----------|
| **INP** (Interaction to Next Paint) | ≤ 200ms | 200-500ms | > 500ms | Input delay + processing + presentation |
| **LCP** (Largest Contentful Paint) | ≤ 2.5s | 2.5-4s | > 4s | Main content load time |
| **CLS** (Cumulative Layout Shift) | ≤ 0.1 | 0.1-0.25 | > 0.25 | Unexpected layout shifts |
| **TBT** (Total Blocking Time) | < 200ms | — | — | Lab proxy for INP (NOT a CWV) |

- INP replaced FID on March 12, 2024
- INP requires real user interactions (field data only)
- TBT is lab-only — useful during development but not a substitute for INP
- Field data (CrUX) affects search rankings; lab data does not

## Key Workflows

### 1. Performance Trace

```
performance_start_trace → reload: true, autoStop: false
wait_for → page stabilization
performance_stop_trace → returns Core Web Vitals
performance_analyze_insight → "LCPBreakdown", "DocumentLatency", "TBT"
```

Best practices: reload for baselines, run 3-5x and use median, clear cache between runs.

### 2. Network Capture

```
navigate_page → clears previous requests
list_network_requests → resourceTypes: ["xhr", "fetch", "document"]
get_network_request → reqid for full headers/body/timing
```

Timing breakdown per request: DNS, connect, SSL, send, wait (TTFB), receive.
Filter by: resourceTypes, pageSize/pageIdx, includePreservedRequests (last 3 navigations).

### 3. Accessibility Snapshot

```
take_snapshot → verbose: false (UIDs + roles)
take_snapshot → verbose: true (full ARIA properties, states, relationships)
```

UIDs from snapshot used for interaction: `click uid="2"`, `fill uid="3" value="test"`.
Check: heading hierarchy, label associations, focusable elements, landmark roles.

### 4. Device Emulation

```
resize_page → width/height
emulate_network → "Slow 3G" | "Fast 3G" | "Slow 4G" | "Fast 4G" | "Offline"
emulate_cpu → throttlingRate: 4 (mid-range mobile)
```

Typical mobile simulation: Fast 4G + 4x CPU + mobile viewport.

### 5. Complete Mobile Audit

```
1. resize_page width: 393, height: 852 (iPhone 14 Pro)
2. emulate_network "Fast 4G"
3. emulate_cpu throttlingRate: 4
4. performance_start_trace reload: true
5. performance_stop_trace
6. take_snapshot (verify mobile accessibility)
7. take_screenshot fullPage: true
```

## Device Dimensions

**Phones (portrait):** iPhone 14 Pro 393x852, iPhone SE 375x667, Pixel 7 412x915, Galaxy S22 360x800
**Tablets:** iPad Pro 12.9" 1024x1366, iPad Air 820x1180, Surface Pro 912x1368
**Desktop:** MacBook Air 1280x832, 1080p 1920x1080, 4K 3840x2160

## Network Throttling Profiles

| Profile | Down | Up | Latency | Use for |
|---------|------|-----|---------|---------|
| Slow 3G | ~400 Kbps | ~400 Kbps | ~2000ms | Extreme mobile |
| Fast 3G | ~1.6 Mbps | ~750 Kbps | ~562ms | Typical 3G |
| Slow 4G | ~4 Mbps | ~3 Mbps | ~150ms | Poor LTE |
| Fast 4G | ~10 Mbps | ~5 Mbps | ~40ms | Good LTE |

## 27 Tools by Category

**Input (8):** click, drag, fill, fill_form, handle_dialog, hover, press_key, upload_file
**Navigation (7):** close_page, list_pages, navigate_page, navigate_page_history, new_page, select_page, wait_for
**Emulation (3):** emulate_cpu, emulate_network, resize_page
**Performance (3):** performance_analyze_insight, performance_start_trace, performance_stop_trace
**Network (2):** get_network_request, list_network_requests
**Debug (4):** evaluate_script, get_console_message, list_console_messages, take_screenshot, take_snapshot

## CLS Common Causes

- Images without explicit width/height dimensions
- Dynamically injected content (ads, embeds)
- Web fonts causing FOIT/FOUT
- Third-party widgets resizing after load

## Resources

- Chrome DevTools MCP: https://github.com/nicholasgriffintn/chrome-devtools-mcp
- Core Web Vitals: https://web.dev/articles/vitals
- PageSpeed Insights: https://pagespeed.web.dev
- CrUX Dashboard: https://developer.chrome.com/docs/crux
