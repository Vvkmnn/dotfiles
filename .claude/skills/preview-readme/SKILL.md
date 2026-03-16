---
name: preview-readme
description: Preview a GitHub README or markdown file locally using go-grip with GitHub-flavored rendering
---

# Preview Markdown Locally

Use this skill when the user asks to preview a README, markdown file, or wants to see how a `.md` file looks before pushing to GitHub.

## How to Run

1. **Find the file** - Default to `README.md` in the current directory. If the user specifies a file, use that path.
2. **Start go-grip** - Use the Bash tool with `run_in_background: true` so Claude tracks the process and the user sees it in their task list. Do NOT use `&` or `disown`.
3. **Report the URL** - go-grip outputs the URL (default `http://localhost:6419/<file>`). Tell the user.
4. **Leave it running** - go-grip watches for file changes and auto-reloads the browser. The user can keep editing.

## Start Command

Use `run_in_background: true` on the Bash tool call:

```
command: "go-grip README.md"
run_in_background: true
```

For a specific file:
```
command: "go-grip path/to/file.md"
run_in_background: true
```

If port 6419 is already in use:
```
command: "go-grip -p 6420 README.md"
run_in_background: true
```

## Important

- Always use `run_in_background: true` - never `&` or `disown`. This keeps the process tracked by Claude so the user gets notified when it stops and it won't be orphaned.
- go-grip renders using GitHub CSS so the preview matches what GitHub shows
- Auto-reload is enabled by default - file saves trigger browser refresh
- If port is already in use, the server is probably already running from a previous call

## Cleanup

When the user says they're done previewing:

```bash
pkill go-grip
```
