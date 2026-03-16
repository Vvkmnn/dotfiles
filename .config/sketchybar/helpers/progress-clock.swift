import Foundation

// Persistent daemon: day progress + clock, updated every 60s aligned to minute boundaries
// Replaces: progress_unified.sh which spawned 7 date commands every second
// ~420 subprocess spawns/min → 0

// MARK: - Sunrise/sunset lookup (same table as shell version)

func sunriseSunset(tz: String, month: Int) -> (sunrise: Int, sunset: Int) {
    switch tz {
    case "Australia/Sydney", "Australia/Melbourne":
        switch month {
        case 12, 1, 2: return (6, 20)
        case 3, 4, 5: return (7, 18)
        case 6, 7, 8: return (7, 17)
        default: return (6, 19)
        }
    case "America/New_York", "America/Toronto":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (6, 20)
        default: return (7, 18)
        }
    case "America/Vancouver", "America/Los_Angeles":
        switch month {
        case 12, 1, 2: return (8, 16)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (5, 21)
        default: return (7, 18)
        }
    case "America/Edmonton", "America/Calgary":
        switch month {
        case 12, 1, 2: return (8, 16)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (5, 21)
        default: return (7, 18)
        }
    case "America/Mexico_City":
        switch month {
        case 12, 1, 2: return (7, 18)
        case 3, 4, 5: return (7, 19)
        case 6, 7, 8: return (7, 20)
        default: return (7, 19)
        }
    case "Europe/London":
        switch month {
        case 12, 1, 2: return (8, 16)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (5, 21)
        default: return (7, 17)
        }
    case "Europe/Paris", "Europe/Berlin", "Europe/Bucharest":
        switch month {
        case 12, 1, 2: return (8, 16)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (5, 21)
        default: return (7, 17)
        }
    case "Asia/Tokyo", "Asia/Seoul", "Asia/Shanghai", "Asia/Hong_Kong":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 3, 4, 5: return (6, 18)
        case 6, 7, 8: return (5, 19)
        default: return (6, 17)
        }
    case "Asia/Kolkata", "Asia/Calcutta":
        switch month {
        case 12, 1, 2: return (7, 18)
        case 3, 4, 5: return (6, 18)
        case 6, 7, 8: return (6, 19)
        default: return (6, 18)
        }
    case "Asia/Singapore", "Asia/Kuala_Lumpur":
        return (7, 19)
    case "Africa/Accra":
        return (6, 18)
    default:
        return (6, 18)
    }
}

// MARK: - Update

func update() {
    let cal = Calendar.current
    let now = Date()
    let hour = cal.component(.hour, from: now)
    let minute = cal.component(.minute, from: now)
    let month = cal.component(.month, from: now)
    let year = cal.component(.year, from: now)
    let dayOfYear = cal.ordinality(of: .day, in: .year, for: now)!

    // Leap year check
    let isLeap = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0)
    let daysInYear = isLeap ? 366 : 365
    let nextDay = dayOfYear == daysInYear ? 1 : dayOfYear + 1

    // Progress through day (0-100)
    let minutesIntoDay = hour * 60 + minute
    let progress = minutesIntoDay * 100 / 1440

    // Segment highlight (first 10% of each segment)
    let segments = 7
    let segmentMinutes = 1440 / segments
    let segmentOffset = minutesIntoDay % segmentMinutes
    let highlightMinutes = segmentMinutes / 10
    let trackColor = segmentOffset < highlightMinutes ? "0xffFFFFFF" : "0xffA0A0A0"

    // Dot position (0-6)
    let dotPos = min(6, progress * 7 / 100)

    // Sunrise/sunset slots
    let tz = TimeZone.current.identifier
    let (sunriseHour, sunsetHour) = sunriseSunset(tz: tz, month: month)
    let sunriseSlot = sunriseHour * 60 * 7 / 1440
    let sunsetSlot = sunsetHour * 60 * 7 / 1440

    // Build track: ━━━●┈┈┈ with ◐/◑ for sunrise/sunset
    var track = ""
    for i in 0..<7 {
        if i == dotPos {
            if i == sunriseSlot { track += "◐" }
            else if i == sunsetSlot { track += "◑" }
            else { track += "●" }
        } else if i < dotPos {
            track += "━"
        } else {
            track += "┈"
        }
    }

    // Time string
    let time = String(format: "%02d:%02d", hour, minute)

    // Single sketchybar call
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/sketchybar")
    proc.arguments = [
        "--set", "progress", "label=\(dayOfYear)\(track)\(nextDay)", "label.color=\(trackColor)",
        "--set", "clock_time", "label=\(time)"
    ]
    try? proc.run()
    proc.waitUntilExit()
}

// MARK: - Main: fire immediately, then align to minute boundaries

update()  // instant first update

let cal = Calendar.current
let secs = cal.component(.second, from: Date())
let delay = Double(60 - secs)  // seconds until next minute

let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
timer.schedule(deadline: .now() + delay, repeating: 60.0)
timer.setEventHandler { update() }
timer.resume()

dispatchMain()
