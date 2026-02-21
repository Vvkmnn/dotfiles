---
name: apple-tools
description: Create beautiful reminders, notes, calendar events, and mail with rich metadata using AppleScript
---

## Quick Reference

Use the AppleScript MCP (`applescript.applescript_applescript_execute`) for all Apple app automation.

### Reminders Metadata
- **Priority**: 1=urgent/high, 5=normal/medium, 9=low/someday
- **Due date format**: `date "2026-01-15 3:00 PM"`
- **Lists**: TODO, Study, Supplies, Default

### Notes Format
- **HTML body**: `<h1>Title</h1><p>Content</p>`
- **Folders**: Dev, House, Quick, Recipes, Thoughts, Todo, etc.

---

## Templates

### Create Reminder with Full Metadata

```applescript
tell application "Reminders"
  tell list "TODO"
    make new reminder with properties {¬
      name:"Update site background", ¬
      body:"Context: Design refresh\nLinks: [Related URLs]\nSee: site note in Apple Notes", ¬
      priority:5, ¬
      due date:date "2026-01-20 5:00 PM"}
  end tell
end tell
```

**Priority guide:**
- 1 = Urgent (red flag)
- 5 = Normal (default)
- 9 = Low priority

---

### Search Notes by Title

```applescript
tell application "Notes"
  set matchingNotes to notes whose name contains "site"
  set output to ""
  repeat with n in matchingNotes
    set output to output & "Found: " & name of n & linefeed
  end repeat
  return output
end tell
```

---

### Create Note in Folder

```applescript
tell application "Notes"
  tell folder "Dev"
    make new note with properties {¬
      name:"claude-sage Project", ¬
      body:"<h1>claude-sage MCP</h1>
<p><strong>Goal:</strong> Search and discover Claude Code skills, plugins, and MCP servers.</p>

<h2>Scope</h2>
<ul>
  <li>Semantic search integration</li>
  <li>Browse by category/popularity</li>
  <li>Show data sources and status</li>
</ul>

<h2>Next Actions</h2>
<ul>
  <li>Review existing MCP search implementations</li>
  <li>Design search interface</li>
  <li>Build semantic search layer</li>
</ul>"}
  end tell
end tell
```

---

### Create Calendar Event

```applescript
tell application "Calendar"
  tell calendar "Work"
    make new event with properties {¬
      summary:"Site background design review", ¬
      start date:date "2026-01-15 2:00 PM", ¬
      end date:date "2026-01-15 3:00 PM", ¬
      description:"Review background options for site redesign", ¬
      location:"Zoom"}
  end tell
end tell
```

---

### List Reminder Lists

```applescript
tell application "Reminders"
  return name of every list
end tell
```

---

### List Note Folders

```applescript
tell application "Notes"
  return name of every folder
end tell
```

---

### Count Reminders in List

```applescript
tell application "Reminders"
  set todoList to list "TODO"
  set reminderCount to count of reminders of todoList
  return "TODO has " & reminderCount & " reminders"
end tell
```

---

## Workflow: Link Reminder to Note

1. **Create note** with project details
2. **Create reminder** referencing the note title in the body
3. Both sync across all Apple devices

Example:
```applescript
-- Step 1: Create note
tell application "Notes"
  tell folder "Dev"
    make new note with properties {name:"My Project", body:"<p>Details here</p>"}
  end tell
end tell

-- Step 2: Create reminder linking to note
tell application "Reminders"
  tell list "TODO"
    make new reminder with properties {¬
      name:"Work on My Project", ¬
      body:"See: 'My Project' note in Dev folder", ¬
      priority:5}
  end tell
end tell
```

---

## Tips

**Avoid timeouts:**
- Use simple queries (count, specific lookups) instead of listing all items
- Increase timeout for complex operations: `timeout: 60`

**Date formats:**
- AppleScript: `date "2026-01-15 3:00 PM"`
- Can also use: `date "January 15, 2026 at 3:00 PM"`

**HTML in Notes:**
- `<h1>`, `<h2>` for headers
- `<p>` for paragraphs
- `<strong>`, `<em>` for emphasis
- `<ul>`, `<li>` for lists
- `<a href="url">link</a>` for links
