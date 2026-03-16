# EventKit Reference: Swift Templates for Reminders & Calendar

Use `swift -e` for features AppleScript can't access: recurrence, location reminders, advanced alarms, calendar events with URLs/attendees.

Both `EKReminder` and `EKEvent` inherit from `EKCalendarItem` (shared: title, notes, url, alarms, recurrenceRules).

## Permissions

EventKit requires access grants (auto-prompted on first run, persists after):
- `requestFullAccessToReminders` — for EKReminder
- `requestFullAccessToEvents` — for EKEvent (calendar)

## Boilerplate

All EventKit scripts follow this pattern:

```swift
import EventKit
import Foundation

let store = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)
store.requestFullAccessToReminders { granted, error in
    guard granted else { print("ACCESS_DENIED"); semaphore.signal(); return }

    // ... operations here ...

    semaphore.signal()
}
semaphore.wait()
```

For calendar events, use `requestFullAccessToEvents` instead.

## Recurring Reminder

```swift
// Inside requestFullAccessToReminders callback:
let calendars = store.calendars(for: .reminder)
guard let list = calendars.first(where: { $0.title == "LIST_NAME" }) else {
    print("ERROR: list not found"); semaphore.signal(); return
}

let reminder = EKReminder(eventStore: store)
reminder.title = "TITLE"
reminder.calendar = list
reminder.priority = 1  // 1=high, 5=medium, 9=low

var due = DateComponents()
due.year = 2026; due.month = 3; due.day = 1
due.hour = 14; due.minute = 0
reminder.dueDateComponents = due

// Recurrence: .daily, .weekly, .monthly, .yearly
// interval: every N (e.g., 2 = every other)
var endComps = DateComponents()
endComps.year = 2026; endComps.month = 6; endComps.day = 30
let endDate = Calendar.current.date(from: endComps)!
let rule = EKRecurrenceRule(
    recurrenceWith: .daily, interval: 1,
    end: EKRecurrenceEnd(end: endDate)
)
reminder.addRecurrenceRule(rule)

let alarm = EKAlarm(absoluteDate: Calendar.current.date(from: due)!)
reminder.addAlarm(alarm)

do {
    try store.save(reminder, commit: true)
    print("SUCCESS: \(reminder.title ?? "")")
} catch { print("ERROR: \(error.localizedDescription)") }
```

## Calendar Event

```swift
// Inside requestFullAccessToEvents callback:
let calendars = store.calendars(for: .event)
guard let cal = calendars.first(where: { $0.title == "CALENDAR_NAME" }) else {
    print("ERROR: calendar not found"); semaphore.signal(); return
}

let event = EKEvent(eventStore: store)
event.title = "TITLE"
event.calendar = cal
event.notes = "Description or linked note reference"
event.location = "Zoom / Room 301 / etc."
event.url = URL(string: "https://example.com")  // optional

// Dates
let formatter = ISO8601DateFormatter()
event.startDate = formatter.date(from: "2026-03-15T14:00:00Z")!
event.endDate = formatter.date(from: "2026-03-15T15:00:00Z")!

// Alarm (offset in seconds, negative = before event)
event.addAlarm(EKAlarm(relativeOffset: -600))  // 10 min before

// Recurrence (optional)
let rule = EKRecurrenceRule(
    recurrenceWith: .weekly, interval: 1,
    end: EKRecurrenceEnd(occurrenceCount: 10)  // or end date
)
event.addRecurrenceRule(rule)

do {
    try store.save(event, span: .thisEvent, commit: true)
    // span: .thisEvent = only this occurrence, .futureEvents = this + all future
    print("SUCCESS: \(event.title ?? "") id=\(event.eventIdentifier ?? "")")
} catch { print("ERROR: \(error.localizedDescription)") }
```

## Query Reminders

```swift
// Inside requestFullAccessToReminders callback:
let calendars = store.calendars(for: .reminder)
guard let list = calendars.first(where: { $0.title == "LIST_NAME" }) else {
    semaphore.signal(); return
}

let predicate = store.predicateForReminders(in: [list])
store.fetchReminders(matching: predicate) { reminders in
    for r in (reminders ?? []) {
        if !r.isCompleted {
            print("\(r.title ?? "") | due: \(r.dueDateComponents?.description ?? "none") | priority: \(r.priority)")
        }
    }
    semaphore.signal()
}
// Note: fetchReminders is async — put semaphore.signal() inside the callback
```

## Query Calendar Events

```swift
// Inside requestFullAccessToEvents callback:
let calendars = store.calendars(for: .event)
let cal = Calendar.current

// Date range: next 7 days
let start = Date()
let end = cal.date(byAdding: .day, value: 7, to: start)!

let predicate = store.predicateForEvents(withStart: start, end: end, calendars: calendars)
let events = store.events(matching: predicate)

for e in events {
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM-dd HH:mm"
    print("\(fmt.string(from: e.startDate)) | \(e.title ?? "") | \(e.location ?? "")")
}
```

## Recurrence Frequencies

| Frequency | Code | Example |
|-----------|------|---------|
| Daily | `.daily, interval: 1` | Every day |
| Every other day | `.daily, interval: 2` | Mon, Wed, Fri... |
| Weekly | `.weekly, interval: 1` | Every week |
| Biweekly | `.weekly, interval: 2` | Every 2 weeks |
| Monthly | `.monthly, interval: 1` | Every month |
| Yearly | `.yearly, interval: 1` | Every year |

End conditions:
- `EKRecurrenceEnd(end: Date)` — stop after date
- `EKRecurrenceEnd(occurrenceCount: Int)` — stop after N occurrences
- `nil` — repeat forever

## EKCalendarItem Properties (shared by EKReminder and EKEvent)

| Property | Type | Notes |
|----------|------|-------|
| `title` | String | Name |
| `notes` | String? | Body text, can store references |
| `url` | URL? | Stored URL (EKEvent only in practice) |
| `alarms` | [EKAlarm]? | Notification triggers |
| `recurrenceRules` | [EKRecurrenceRule]? | Repeat patterns |
| `calendar` | EKCalendar | Which list/calendar |
| `calendarItemIdentifier` | String | Unique ID |

### EKReminder-specific

| Property | Type | Notes |
|----------|------|-------|
| `dueDateComponents` | DateComponents? | When due |
| `startDateComponents` | DateComponents? | When to start showing |
| `isCompleted` | Bool | Done status |
| `completionDate` | Date? | When completed |
| `priority` | Int | 1=high, 5=medium, 9=low, 0=none |

### EKEvent-specific

| Property | Type | Notes |
|----------|------|-------|
| `startDate` | Date | Event start |
| `endDate` | Date | Event end |
| `location` | String? | Where |
| `isAllDay` | Bool | All-day event |
| `availability` | EKEventAvailability | .busy, .free, .tentative |
| `eventIdentifier` | String | Unique ID |
