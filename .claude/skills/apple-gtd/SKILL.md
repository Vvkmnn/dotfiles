---
name: apple-gtd
author: Vvkmnn
description: Use when managing Reminders, Notes, or Calendar events via osascript/EventKit. Covers GTD inbox processing, cross-app linking (reminder+note pairs), weekly reviews, context tags, and Siri/Shortcuts capture. NOT for Swift/Xcode development.
version: 0.2.1
---

# Apple GTD

## Tool Selection

| Need | Tool |
|------|------|
| Basic Reminders/Notes/Calendar CRUD | `osascript` via Bash |
| Recurrence, alarms, location reminders | `swift -e` + EventKit (see apple-gtd-eventkit.md) |
| Calendar events with URLs/attendees | `swift -e` + EventKit |
| Linked reminder+note pair | `osascript` (convention-based, Claude orchestrates) |
| Quick capture on phone | Claude iOS native Reminders |

## Claude Platform Capabilities

| Feature | iOS App | Desktop App | Code (CLI) |
|---------|---------|-------------|-----------|
| Reminders CRUD | Native | MCP server needed | osascript / EventKit |
| Notes CRUD | No | Connector built-in | osascript |
| Calendar CRUD | Native | MCP server needed | osascript / EventKit |
| Recurrence | Native | MCP dependent | EventKit only |

**Desktop MCP servers** (install one in `claude_desktop_config.json`):
- `FradSer/mcp-server-apple-events` — tags, subtasks, geofence, recurrence
- `supermemoryai/apple-mcp` — Messages, Mail, Contacts, Notes, Reminders
- `member-berries-apple-mcp` — Calendar, Notes, Reminders with memory

## Important: Use osascript, NOT the AppleScript MCP

The `@peakmojo/applescript-mcp` times out on Reminders. Reminders is a Catalyst app with slow AppleScript perf. **Use `osascript` via Bash** — 10x faster.

### Performance Rule: One-liners

Each AppleScript command = 1 Apple Event (IPC overhead). Loops = N events. Batch into single event.

```applescript
# GOOD - single Apple Event
tell application "Reminders" to get name of reminders in list "Inbox" whose completed is false

# BAD - N Apple Events
repeat with r in reminders of list "Inbox" ...
```

---

## Reminders

### Common Operations

```bash
# List all lists
osascript -e 'tell application "Reminders" to get name of every list'

# List incomplete in a list
osascript -e 'tell application "Reminders" to get name of reminders in list "Inbox" whose completed is false'

# Create reminder
osascript -e 'tell application "Reminders" to make new reminder in list "Next Actions" with properties {name:"Task", priority:5}'

# Create with due date
osascript -e 'tell application "Reminders" to make new reminder in list "Next Actions" with properties {name:"Task", due date:date "2026-03-15 2:00 PM"}'

# Complete
osascript -e 'tell application "Reminders" to set completed of (first reminder in list "Next Actions" whose name is "Task") to true'

# Delete
osascript -e 'tell application "Reminders" to delete (first reminder in list "Next Actions" whose name is "Task")'

# Move between lists (delete + recreate — no native move)
```

### Properties (AppleScript)

| Property | Type | Notes |
|----------|------|-------|
| `name` | text | Title |
| `body` | text | Notes field (fetching adds latency — skip if not needed) |
| `completed` | boolean | Done status |
| `due date` | date | When due |
| `remind me date` | date | Alert time |
| `priority` | integer | 1=high, 5=medium, 9=low, 0=none |
| `flagged` | boolean | Has flag |

### Advanced (EventKit)

AppleScript **cannot** set: recurrence rules, location triggers, tags, or advanced alarms. Use `swift -e` + EventKit for these. See apple-gtd-eventkit.md for templates.

### Performance Tips

- Delete completed items — large completed lists slow queries
- Use specific lists, not "all lists"
- Filter in AppleScript (`whose completed is false`) not post-filter
- Skip `body` property if you only need names

---

## Notes

### HTML is Required

Plain text line breaks get stripped. Use HTML for all formatting.

| Element | Example |
|---------|---------|
| `<h1>`, `<h2>` | `<h1>Title</h1>` |
| `<p>` | `<p>Text</p>` |
| `<br>` | `Line one<br>Line two` |
| `<b>`, `<i>` | `<b>Bold</b>` |
| `<ul><li>` | `<ul><li>Item</li></ul>` |
| `<a href="">` | `<a href="url">text</a>` |

### Common Operations

```bash
# List folders
osascript -e 'tell application "Notes" to get name of every folder'

# List notes in folder
osascript -e 'tell application "Notes" to get name of notes in folder "Projects"'

# Create note
osascript <<'EOF'
tell application "Notes"
  tell folder "Projects"
    make new note with properties {name:"Title", body:"<h1>Title</h1><p>Content</p>"}
  end tell
end tell
EOF

# Read note
osascript -e 'tell application "Notes" to get body of first note whose name is "Title"'

# Update note
osascript -e 'tell application "Notes" to set body of (first note whose name is "Title") to "<p>New</p>"'

# Create folder
osascript -e 'tell application "Notes" to make new folder with properties {name:"Projects"}'

# Delete note
osascript -e 'tell application "Notes" to delete (first note whose name is "Title")'
```

### Project Support Note Template

```bash
osascript <<'EOF'
tell application "Notes"
  tell folder "Projects"
    make new note with properties {name:"[NAME] — Support", body:"<h1>NAME</h1>
<p><b>Status:</b> Active<br>
<b>Outcome:</b> What does done look like?<br>
<b>Deadline:</b> YYYY-MM-DD</p>
<h2>Next Steps</h2>
<ul><li>Step 1</li><li>Step 2</li></ul>
<h2>Reference</h2>
<p>Links, docs, context.</p>
<h2>Decisions</h2>
<p>Why this approach?</p>"}
  end tell
end tell
EOF
```

---

## Calendar

### GTD Rule: Hard Landscape Only

Calendar = time-specific appointments and day-specific info ONLY:
- Meetings, calls with specific times
- Deadlines (presentation due Friday)
- Day-specific events (conference, birthday, travel)

Do NOT put Next Actions on the calendar. Those go in Reminders.

### Common Operations

```bash
# List all calendars
osascript -e 'tell application "Calendar" to get name of every calendar'

# Create event
osascript <<'EOF'
tell application "Calendar"
  tell calendar "Work"
    make new event with properties {summary:"Meeting", start date:date "2026-03-15 2:00 PM", end date:date "2026-03-15 3:00 PM", description:"Agenda", location:"Zoom"}
  end tell
end tell
EOF

# List events today
osascript <<'EOF'
tell application "Calendar"
  set today to current date
  set todayStart to today - (time of today)
  set todayEnd to todayStart + (1 * days)
  set todayEvents to {}
  repeat with c in calendars
    set todayEvents to todayEvents & (every event of c whose start date >= todayStart and start date < todayEnd)
  end repeat
  set output to {}
  repeat with e in todayEvents
    set end of output to (summary of e & " @ " & time string of start date of e)
  end repeat
  return output
end tell
EOF

# Delete event
osascript <<'EOF'
tell application "Calendar"
  tell calendar "Work"
    delete (first event whose summary is "Meeting")
  end tell
end tell
EOF

# Update event
osascript <<'EOF'
tell application "Calendar"
  tell calendar "Work"
    set theEvent to first event whose summary is "Meeting"
    set location of theEvent to "Room 301"
    set description of theEvent to "Updated agenda"
  end tell
end tell
EOF
```

### Calendar Properties

| Property | Type | Notes |
|----------|------|-------|
| `summary` | text | Event title |
| `start date` | date | When it starts |
| `end date` | date | When it ends |
| `description` | text | Body/notes |
| `location` | text | Where |
| `allday event` | boolean | All-day flag |
| `recurrence` | text | iCal RRULE string |
| `url` | text | Attached URL |

### Recurring Events

```bash
# Weekly standup via AppleScript recurrence property
osascript <<'EOF'
tell application "Calendar"
  tell calendar "Work"
    set newEvent to make new event with properties {summary:"Standup", start date:date "2026-03-16 9:00 AM", end date:date "2026-03-16 9:15 AM"}
    set recurrence of newEvent to "FREQ=WEEKLY;BYDAY=MO,WE,FR"
  end tell
end tell
EOF
```

For advanced calendar events (attendees, travel time, URL), see apple-gtd-eventkit.md.

---

## Cross-App Linking

Claude orchestrates the lifecycle of linked items across Reminders, Notes, and Calendar. No native cascading exists — Claude manages both sides.

### Convention

Linked items share a name:
- **Reminder**: `"Project Name"` in Projects list, body: `"See note: '[Project Name] — Support' in Projects folder"`
- **Note**: `"[Project Name] — Support"` in Projects folder
- **Calendar event** (optional): `"Project Name — Deadline"` with description referencing the note

### Linked Creation

```bash
# 1. Create support note
osascript <<'EOF'
tell application "Notes"
  tell folder "Projects"
    make new note with properties {name:"[DAW Presentation] — Support", body:"<h1>DAW Presentation</h1><p>LLM Intro & Transformers for Minh</p>"}
  end tell
end tell
EOF

# 2. Create reminder linking to note
osascript -e 'tell application "Reminders" to make new reminder in list "Projects" with properties {name:"DAW Presentation", body:"See note: [DAW Presentation] — Support in Projects folder", priority:1}'

# 3. (Optional) Create calendar deadline
osascript <<'EOF'
tell application "Calendar"
  tell calendar "Work"
    make new event with properties {summary:"DAW Presentation — Deadline", start date:date "2026-03-14 2:00 PM", end date:date "2026-03-14 3:00 PM", description:"See note: [DAW Presentation] — Support"}
  end tell
end tell
EOF
```

### Linked Completion

```bash
# 1. Complete reminder
osascript -e 'tell application "Reminders" to set completed of (first reminder in list "Projects" whose name is "DAW Presentation") to true'

# 2. Move note to Archive (delete + recreate — no native move)
osascript <<'EOF'
tell application "Notes"
  set theNote to first note whose name is "[DAW Presentation] — Support"
  set noteBody to body of theNote
  tell folder "Archive"
    make new note with properties {name:"[DAW Presentation] — Support", body:noteBody}
  end tell
  delete theNote
end tell
EOF
```

### Linked Deletion

```bash
# Delete both sides
osascript -e 'tell application "Reminders" to delete (first reminder in list "Projects" whose name is "DAW Presentation")'
osascript -e 'tell application "Notes" to delete (first note whose name contains "DAW Presentation")'
```

### Finding Pairs

```bash
# Find reminder by name
osascript -e 'tell application "Reminders" to get name of reminders whose name contains "DAW" and completed is false'

# Find linked note
osascript -e 'tell application "Notes" to get name of notes whose name contains "DAW"'

# Find linked calendar event
osascript -e 'tell application "Calendar" to get summary of events of calendar "Work" whose summary contains "DAW"'
```

---

## GTD Setup

### Reminders Lists

```
GTD (Group — create manually in Reminders UI after running script)
  Inbox              # Default list. Siri capture target.
  Next Actions       # Single actionable items, tagged by @context
  Projects           # Multi-step outcomes. Subtasks for steps.
  Waiting For        # Delegated/dependent. Set follow-up due dates.
  Someday/Maybe      # Future ideas. Review weekly.
```

```bash
# Create GTD lists
osascript <<'EOF'
tell application "Reminders"
  if not (exists list "Inbox") then make new list with properties {name:"Inbox"}
  if not (exists list "Next Actions") then make new list with properties {name:"Next Actions"}
  if not (exists list "Projects") then make new list with properties {name:"Projects"}
  if not (exists list "Waiting For") then make new list with properties {name:"Waiting For"}
  if not (exists list "Someday/Maybe") then make new list with properties {name:"Someday/Maybe"}
end tell
EOF
```

After: open Reminders > File > New Group > "GTD" > drag lists into group.
Set default: System Settings > Reminders > Default List > Inbox.

### Notes Folders

```
Projects/           # Active project support (1 note per project)
Reference/          # Non-actionable: templates, processes, decisions
Archive/            # Completed project notes
```

```bash
osascript <<'EOF'
tell application "Notes"
  if not (exists folder "Projects") then make new folder with properties {name:"Projects"}
  if not (exists folder "Reference") then make new folder with properties {name:"Reference"}
  if not (exists folder "Archive") then make new folder with properties {name:"Archive"}
end tell
EOF
```

### Context Tags

Use in Reminders `body` field (AppleScript can't set native tags):

| Tag | Situation |
|-----|-----------|
| `@home` | At home |
| `@work` | Office/workplace |
| `@computer` | Any device, digital |
| `@errands` | Out of house |
| `@calls` | Phone calls |
| `@agenda` | Next meeting with someone |

### Processing Inbox

1. **Actionable?** No → delete or Someday/Maybe
2. **<2 min?** Do it now
3. **Multi-step?** → Projects list + subtasks + linked Note
4. **Single action** → Next Actions + context tag + optional due date
5. **Waiting?** → Waiting For + follow-up due date

### Weekly Review Checklist

1. Empty Inbox (process all items)
2. Review Calendar (past week + next 2 weeks)
3. Review Next Actions (reprioritize, remove stale)
4. Review Projects (add next action for each)
5. Review Waiting For (follow up if overdue)
6. Review Someday/Maybe (activate any?)
7. Mental sweep (anything forgotten? → Inbox)

---

## Siri & Shortcuts

- **Quick capture**: "Remind me to X" → goes to default list (set to Inbox)
- **Specific list**: "Add X to my Next Actions list"
- **Share from Notes**: Right-click text > Share > Reminders → creates deeplinked reminder
- **Tag workflows**: Use `#deferred` and `#review` tags (see petioptrv/reminders-gtd)
- **Daily review shortcut**: Shortcuts app > open Calendar + Reminders + Notes sequentially

---

## Date Formats

- `date "2026-03-15 3:00 PM"`
- `date "March 15, 2026 at 3:00 PM"`
