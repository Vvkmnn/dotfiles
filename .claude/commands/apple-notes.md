---
description: Create and manage beautifully formatted Apple Notes via osascript
allowed-tools: Bash(osascript:*)
argument-hint: "[list|create|read|delete] [folder-name] [note-name]"
---

# /apple-notes - Apple Notes Integration

Interact with Apple Notes using osascript directly. Creates properly formatted notes with HTML.

## Why HTML?
- Plain text line breaks get stripped by Notes
- HTML renders headings, lists, links, and formatting correctly
- Use `<br>` for line breaks, `<ul><li>` for bullets, `<h2>` for sections

## Arguments
- `$ARGUMENTS` - Action and parameters:
  - `list [FolderName]` - Show notes in a folder (default: Notes)
  - `create "FolderName" "Note title" "content"` - Create a note
  - `read "Note name"` - Read a note's content
  - `delete "Note name"` - Delete a note
  - `folders` - Show all folders
  - (no args) - Show all notes in default folder

## HTML Formatting Patterns

### Basic Structure (ALWAYS use this)
```applescript
set htmlBody to "<h1>Title</h1>
<p>Introduction paragraph.</p>

<h2>Section</h2>
<p><b>Bold label:</b> Value<br>
<a href=\"https://example.com\">Link text</a></p>

<ul>
<li>Bullet point one</li>
<li>Bullet point two</li>
</ul>

<hr>
<p><i>Footer or note</i></p>"

tell application "Notes"
    make new note at folder "Notes" with properties {name:"Title", body:htmlBody}
end tell
```

### Common HTML Elements
| Element | Purpose | Example |
|---------|---------|---------|
| `<h1>` | Main title | `<h1>Project Name</h1>` |
| `<h2>` | Section header | `<h2>Details</h2>` |
| `<p>` | Paragraph | `<p>Text here</p>` |
| `<br>` | Line break | `Line one<br>Line two` |
| `<b>` | Bold | `<b>Important</b>` |
| `<i>` | Italic | `<i>Note</i>` |
| `<ul><li>` | Bullet list | `<ul><li>Item</li></ul>` |
| `<ol><li>` | Numbered list | `<ol><li>Step 1</li></ol>` |
| `<a href="">` | Link | `<a href="url">text</a>` |
| `<hr>` | Horizontal line | `<hr>` |

## Common Operations

### List all folders
```bash
osascript -e 'tell application "Notes" to get name of every folder'
```

### List notes in a folder
```bash
osascript -e 'tell application "Notes" to get name of notes in folder "Notes"'
```

### Create a simple note
```bash
osascript -e 'tell application "Notes" to make new note at folder "Notes" with properties {name:"Title", body:"<p>Content here</p>"}'
```

### Create a formatted note (heredoc for complex HTML)
```bash
osascript <<'EOF'
tell application "Notes"
    set htmlBody to "<h1>Title</h1>
<p>Content with <b>formatting</b>.</p>
<ul>
<li>Item one</li>
<li>Item two</li>
</ul>"
    make new note at folder "Notes" with properties {name:"Title", body:htmlBody}
end tell
EOF
```

### Read a note
```bash
osascript -e 'tell application "Notes" to get body of first note whose name is "Note Name"'
```

### Update a note
```bash
osascript -e 'tell application "Notes" to set body of (first note whose name is "Note Name") to "<p>New content</p>"'
```

### Delete a note
```bash
osascript -e 'tell application "Notes" to delete (first note whose name is "Note Name")'
```

### Create a new folder
```bash
osascript -e 'tell application "Notes" to make new folder with properties {name:"Folder Name"}'
```

## Note Properties
- `name` (text) - Note title
- `body` (text) - HTML content
- `creation date` (date) - When created
- `modification date` (date) - Last modified
- `id` (text) - Unique identifier
- `container` (folder) - Parent folder

## Beautiful Note Templates

### Tool/App to Buy
```applescript
"<h1>Tool Name</h1>
<p><i>Brief description of what it does.</i></p>

<p><b>Website:</b> <a href=\"URL\">URL</a><br>
<b>Price:</b> $X regular, $Y on sale<br>
<b>Coupon:</b> CODE</p>

<h2>Features</h2>
<ul>
<li>Feature one</li>
<li>Feature two</li>
</ul>

<h2>Why</h2>
<p>Reason to buy this tool.</p>"
```

### Project Reference
```applescript
"<h1>Project Name</h1>
<p><b>Status:</b> Active<br>
<b>Repo:</b> <a href=\"URL\">GitHub</a></p>

<h2>Quick Reference</h2>
<ul>
<li><b>Build:</b> <code>npm run build</code></li>
<li><b>Test:</b> <code>npm test</code></li>
</ul>

<h2>Notes</h2>
<p>Important things to remember.</p>"
```

## Pairing with Reminders

Use Notes for detailed reference, Reminders for actionable tracking:

```
Reminders (Tools list)          Notes (Tools note)
-------------------------       -------------------------
[ ] Backdrop (Cindori)    <-->  Full details, links, pricing
[ ] Alcove                <-->  Features, why to buy
```

Pattern:
1. Create detailed Note with full information
2. Create Reminder with short name pointing to the note
3. Check off Reminder when purchased
4. Keep Note for future reference

See also: `/apple-reminders` for managing the reminder side.

## Limitations
- No direct access to attachments via AppleScript
- Checklists in notes require HTML checkbox elements (not native)
- Shared notes have limited AppleScript access
- No tag support via AppleScript

## Workflow
1. Parse `$ARGUMENTS` to determine action
2. For creation, build HTML body with proper formatting
3. Run osascript command
4. Verify success by re-querying
