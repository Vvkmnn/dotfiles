---
description: Query and manage Apple Reminders efficiently via osascript
allowed-tools: Bash(osascript:*)
argument-hint: "[list|add|complete|delete] [list-name] [reminder-text]"
---

# /apple-reminders - Apple Reminders Integration

Interact with Apple Reminders using osascript directly. Avoids the slow MCP AppleScript server.

## Why osascript?
- MCP AppleScript server (`@peakmojo/applescript-mcp`) times out on Reminders queries
- Reminders is a Catalyst app with inherently slow AppleScript performance
- Direct osascript via Bash is 10x+ faster and more reliable

## Arguments
- `$ARGUMENTS` - Action and parameters:
  - `list [ListName]` - Show reminders from a list (default: Inbox)
  - `add "ListName" "Reminder text"` - Create a new reminder
  - `complete "ListName" "Reminder name"` - Mark reminder as done
  - `lists` - Show all reminder lists
  - (no args) - Show incomplete reminders from Inbox

## Efficient Query Patterns

### ALWAYS use one-liners, NEVER use loops
```applescript
# GOOD - Single Apple Event, returns list directly
tell application "Reminders" to get name of reminders in list "Inbox" whose completed is false

# BAD - Multiple Apple Events, 10x slower
tell application "Reminders"
  repeat with r in reminders of list "Inbox"
    set output to output & name of r  -- SLOW: fetches each individually
  end repeat
end tell
```

### Why one-liners are faster
- Each AppleScript command = 1 Apple Event (IPC overhead)
- Loops generate N events for N items
- One-liners batch into single event
- Reminders' Catalyst bridge makes this worse

## Common Operations

### List incomplete reminders
```bash
osascript -e 'tell application "Reminders" to get name of reminders in list "Inbox" whose completed is false'
```

### List all reminder lists
```bash
osascript -e 'tell application "Reminders" to get name of every list'
```

### Add a reminder
```bash
osascript -e 'tell application "Reminders" to make new reminder in list "Inbox" with properties {name:"Task name"}'
```

### Add reminder with due date
```bash
osascript -e 'tell application "Reminders" to make new reminder in list "Inbox" with properties {name:"Task name", due date:date "2024-01-15 09:00"}'
```

### Complete a reminder
```bash
osascript -e 'tell application "Reminders" to set completed of (first reminder in list "Inbox" whose name is "Task name") to true'
```

### Delete a reminder
```bash
osascript -e 'tell application "Reminders" to delete (first reminder in list "Inbox" whose name is "Task name")'
```

### Get reminder details (name + notes)
```bash
osascript -e 'tell application "Reminders" to get {name, body} of reminders in list "Inbox" whose completed is false'
```

## Performance Tips
1. **Delete completed items** - Large lists with completed items slow queries significantly
2. **Use specific lists** - Querying all lists is slower than one specific list
3. **Filter in AppleScript** - `whose completed is false` is faster than post-filtering
4. **Avoid body property** - Fetching notes adds latency; skip if not needed

## Reminder Properties
- `name` (text) - Title
- `body` (text) - Notes/description
- `completed` (boolean) - Done status
- `due date` (date) - When due
- `remind me date` (date) - Alert time
- `priority` (integer) - 0=none, 1=high, 5=medium, 9=low
- `flagged` (boolean) - Has flag

## Pairing with Notes

Use Reminders for actionable tracking, Notes for detailed reference:

```
Reminders (Tools list)          Notes (Tools note)
-------------------------       -------------------------
[ ] Backdrop (Cindori)    <-->  Full details, links, pricing
[ ] Alcove                <-->  Features, why to buy
```

Pattern:
1. Create Reminder with short actionable name
2. Create matching Note with full details (HTML formatted)
3. Check off Reminder when done
4. Keep Note for future reference

See also: `/apple-notes` for creating beautifully formatted notes.

## Limitations
- No access to Reminder Groups (AppleScript doesn't support them)
- No subtasks access
- No tags access
- Location-based reminders can't be created via AppleScript

## Workflow
1. Parse `$ARGUMENTS` to determine action
2. Run appropriate osascript command
3. Format output for readability
4. For modifications, confirm success by re-querying
