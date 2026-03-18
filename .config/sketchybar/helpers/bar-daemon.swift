import CoreWLAN
import Darwin
import Foundation
import IOKit
import Network
import SystemConfiguration

// Unified bar daemon: single process for all 15 sketchybar items
// Replaces: metrics-daemon + net-stats + net-monitor + progress-clock + wifi-signal
//           + battery.sh + disk.sh + connection.sh + location.sh
//
// Event sources:
//   1. Main 1s timer         → network (every tick), battery + disk (change detection)
//   2. NWPathMonitor (push)  → connection, location, network_change trigger
//   3. Minute-aligned timer  → progress track + clock
//   4. Power source notify   → battery (instant plug/unplug reaction)
//   5. macmon readability    → cpu, gpu, temp, memory, power (callback-based)
//   6. 30s tick (via main)   → connection latency measurement

// MARK: - Shared sketchybar helper (fire-and-forget)

// Smooth startup: first ~3s of updates animate with tanh 30 so values fade in
var startupSmooth = true

func sketchybar(_ args: [String]) {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/sketchybar")
    proc.arguments = startupSmooth ? ["--animate", "tanh", "30"] + args : args
    try? proc.run()
}


// MARK: - Global state

var networkActive = false
var internetReachable = true
var tick = 0

// ═══════════════════════════════════════════════════════════════════
// MARK: - Network Stats (1-second getifaddrs)
// ═══════════════════════════════════════════════════════════════════

var prevDown: UInt32 = 0
var prevUp: UInt32 = 0
var hasPrev = false

func readNetBytes() -> (down: UInt32, up: UInt32, active: Bool) {
    var totalDown: UInt32 = 0
    var totalUp: UInt32 = 0
    var active = false

    var ifaddrsPtr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddrsPtr) == 0, let first = ifaddrsPtr else {
        return (0, 0, false)
    }
    defer { freeifaddrs(first) }

    var current: UnsafeMutablePointer<ifaddrs>? = first
    while let ifa = current {
        defer { current = ifa.pointee.ifa_next }
        let name = String(cString: ifa.pointee.ifa_name)
        guard (name == "en0" || name == "en1"),
              ifa.pointee.ifa_addr.pointee.sa_family == UInt8(AF_LINK),
              (ifa.pointee.ifa_flags & UInt32(IFF_RUNNING)) != 0 else { continue }

        active = true
        if let data = ifa.pointee.ifa_data?.assumingMemoryBound(to: if_data.self) {
            // ifi_ibytes/ifi_obytes are UInt32 — no Int32 cast (would crash >2GB)
            totalDown = totalDown &+ data.pointee.ifi_ibytes
            totalUp = totalUp &+ data.pointee.ifi_obytes
        }
    }
    return (totalDown, totalUp, active)
}

func downColor(_ kb: Int) -> String {
    kb < 50 ? "0xff8A869E" : kb < 500 ? "0xffFFFFFF" : kb < 5000 ? "0xffFFA500" : "0xffE74C3C"
}

func upColor(_ kb: Int) -> String {
    kb < 20 ? "0xff8A869E" : kb < 200 ? "0xffFFFFFF" : kb < 2000 ? "0xffFFA500" : "0xffE74C3C"
}

func fillColor(_ c: String) -> String {
    "0x33" + c.dropFirst(4)
}

func updateNetwork() {
    let (curDown, curUp, active) = readNetBytes()
    networkActive = active

    // Don't update network items while internet is down (animation script controls them)
    if !internetReachable { return }

    if !active {
        sketchybar([
            "--set", "network_down", "icon.drawing=off", "label.drawing=off", "padding_right=0",
            "--set", "network_up", "icon.drawing=off", "label.drawing=off", "padding_right=0",
            "--set", "graph_down", "drawing=off",
            "--set", "graph_up", "drawing=off"
        ])
        hasPrev = false
        return
    }

    if hasPrev {
        let diffDown = Int(curDown &- prevDown)
        let diffUp = Int(curUp &- prevUp)
        let downKB = max(0, diffDown) / 1024
        let upKB = max(0, diffUp) / 1024

        // Units: ᴷ (U+1D37) = KB/s, ᴹ (U+1D39) = MB/s — superscript modifier letters
        // Alternative: plain "K"/"M" if superscript is hard to read at small font sizes
        let downStr = downKB < 100 ? "\(downKB)\u{1D37}" : "\((downKB + 1023) / 1024)\u{1D39}"
        let upStr = upKB < 100 ? "\(upKB)\u{1D37}" : "\((upKB + 1023) / 1024)\u{1D39}"

        let gDown = downKB > 0 ? min(1.0, max(0.0, log(Double(downKB)) / log(1000))) : 0.0
        let gUp = upKB > 0 ? min(1.0, max(0.0, log(Double(upKB)) / log(1000))) : 0.0

        let dC = downColor(downKB)
        let uC = upColor(upKB)

        sketchybar([
            "--set", "network_down", "label=\(downStr)", "label.color=\(dC)", "icon.color=\(dC)",
                "icon.drawing=on", "label.drawing=on",
            "--set", "network_up", "label=\(upStr)", "label.color=\(uC)", "icon.color=\(uC)",
                "icon.drawing=on", "label.drawing=on",
            "--set", "graph_down", "graph.color=\(dC)", "graph.fill_color=\(fillColor(dC))", "drawing=on",
            "--set", "graph_up", "graph.color=\(uC)", "graph.fill_color=\(fillColor(uC))", "drawing=on",
            "--push", "graph_down", String(format: "%.3f", gDown),
            "--push", "graph_up", String(format: "%.3f", gUp)
        ])
    } else {
        sketchybar([
            "--set", "network_down", "label=0\u{1D37}", "label.color=0xff8A869E", "icon.color=0xff8A869E",
                "icon.drawing=on", "label.drawing=on",
            "--set", "network_up", "label=0\u{1D37}", "label.color=0xff8A869E", "icon.color=0xff8A869E",
                "icon.drawing=on", "label.drawing=on",
            "--set", "graph_down", "drawing=on",
            "--set", "graph_up", "drawing=on",
            "--push", "graph_down", "0.0",
            "--push", "graph_up", "0.0"
        ])
    }

    prevDown = curDown
    prevUp = curUp
    hasPrev = true
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - NWPathMonitor (push-based network change detection)
// ═══════════════════════════════════════════════════════════════════

var pathMonitor: NWPathMonitor?  // global to prevent ARC deallocation
var lastNetworkTrigger = Date.distantPast
var pendingTrigger: DispatchWorkItem?

func setupPathMonitor() {
    let monitor = NWPathMonitor()
    pathMonitor = monitor
    monitor.pathUpdateHandler = { _ in
        let now = Date()
        guard now.timeIntervalSince(lastNetworkTrigger) >= 3 else { return }
        pendingTrigger?.cancel()
        let work = DispatchWorkItem {
            lastNetworkTrigger = Date()
            sketchybar(["--trigger", "network_change"])
            updateConnection()
            updateLocation(force: true)  // VPN changes don't alter SCDynamicStore fingerprint
        }
        pendingTrigger = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: work)
    }
    // Run on main queue — handler accesses shared globals (lastNetworkTrigger, pendingTrigger)
    monitor.start(queue: DispatchQueue.main)
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Progress + Clock (60-second, minute-aligned)
// ═══════════════════════════════════════════════════════════════════

// Coordinate lookup from timezone identifier — (latitude, longitude) of reference city.
// Used for solar sunrise/sunset. No network call needed — derived from machine timezone.
func timezoneCoordinates(_ tz: String) -> (lat: Double, lon: Double) {
    switch tz {
    // North America
    case "America/Anchorage":                                           return (61.2, -150.0)
    case "America/Edmonton", "America/Calgary", "America/Winnipeg":     return (53.5, -113.5)
    case "America/Halifax", "America/St_Johns":                         return (44.6, -63.6)
    case "America/Vancouver", "America/Los_Angeles", "America/Tijuana": return (49.3, -123.1)
    case "America/Denver", "America/Boise":                             return (39.7, -105.0)
    case "America/Chicago", "America/Indiana/Indianapolis":             return (41.9, -87.6)
    case "America/New_York", "America/Toronto", "America/Detroit",
         "America/Montreal":                                            return (43.7, -79.4)
    case "America/Phoenix":                                             return (33.4, -112.1)
    case "Pacific/Honolulu":                                            return (21.3, -157.8)
    case "America/Mexico_City":                                         return (19.4, -99.1)
    // South America
    case "America/Sao_Paulo":                                           return (-23.5, -46.6)
    case "America/Argentina/Buenos_Aires":                              return (-34.6, -58.4)
    case "America/Santiago":                                            return (-33.4, -70.7)
    case "America/Lima":                                                return (-12.0, -77.0)
    case "America/Bogota":                                              return (4.7, -74.1)
    // Europe
    case "Europe/London", "Europe/Dublin":                              return (51.5, -0.1)
    case "Europe/Lisbon":                                               return (38.7, -9.1)
    case "Europe/Paris", "Europe/Brussels":                             return (48.9, 2.3)
    case "Europe/Madrid":                                               return (40.4, -3.7)
    case "Europe/Berlin", "Europe/Amsterdam", "Europe/Zurich",
         "Europe/Vienna", "Europe/Warsaw":                              return (52.5, 13.4)
    case "Europe/Rome":                                                 return (41.9, 12.5)
    case "Europe/Stockholm", "Europe/Oslo", "Europe/Copenhagen":        return (59.3, 18.1)
    case "Europe/Helsinki", "Europe/Tallinn", "Europe/Vilnius",
         "Europe/Riga":                                                 return (60.2, 24.9)
    case "Europe/Bucharest", "Europe/Athens", "Europe/Sofia":           return (44.4, 26.1)
    case "Europe/Istanbul":                                             return (41.0, 29.0)
    case "Europe/Moscow", "Europe/Minsk":                               return (55.8, 37.6)
    // Middle East
    case "Asia/Dubai", "Asia/Muscat":                                   return (25.3, 55.3)
    case "Asia/Riyadh", "Asia/Qatar":                                   return (24.7, 46.7)
    case "Asia/Tehran":                                                 return (35.7, 51.4)
    case "Asia/Jerusalem", "Asia/Tel_Aviv":                             return (31.8, 35.2)
    // East & Southeast Asia
    case "Asia/Tokyo":                                                  return (35.7, 139.7)
    case "Asia/Seoul":                                                  return (37.6, 127.0)
    case "Asia/Shanghai", "Asia/Hong_Kong", "Asia/Taipei":              return (31.2, 121.5)
    case "Asia/Bangkok", "Asia/Ho_Chi_Minh":                            return (13.8, 100.5)
    case "Asia/Jakarta":                                                return (-6.2, 106.8)
    case "Asia/Manila":                                                 return (14.6, 121.0)
    case "Asia/Singapore", "Asia/Kuala_Lumpur":                         return (1.4, 103.8)
    // South Asia
    case "Asia/Kolkata", "Asia/Calcutta":                               return (28.6, 77.2)
    case "Asia/Karachi":                                                return (24.9, 67.0)
    case "Asia/Dhaka":                                                  return (23.8, 90.4)
    // Africa
    case "Africa/Cairo":                                                return (30.0, 31.2)
    case "Africa/Johannesburg":                                         return (-26.2, 28.0)
    case "Africa/Lagos", "Africa/Accra":                                return (6.5, 3.4)
    case "Africa/Nairobi", "Africa/Dar_es_Salaam":                      return (-1.3, 36.8)
    // Australia & Pacific
    case "Australia/Sydney", "Australia/Melbourne":                     return (-33.9, 151.2)
    case "Australia/Perth":                                             return (-31.9, 115.9)
    case "Australia/Brisbane":                                          return (-27.5, 153.0)
    case "Pacific/Auckland":                                            return (-36.8, 174.8)
    case "Pacific/Fiji":                                                return (-18.1, 178.4)
    default:
        // Unknown timezone: estimate longitude from UTC offset, assume mid-latitude 35°
        // in the appropriate hemisphere based on timezone region prefix
        let utcHours = Double(TimeZone.current.secondsFromGMT()) / 3600.0
        let estLon = utcHours * 15.0
        let estLat: Double
        if tz.hasPrefix("Australia") || tz.hasPrefix("Pacific/A") {
            estLat = -33.0  // southern hemisphere, Oceania
        } else if tz.hasPrefix("America") && tz.contains("Buenos") || tz.contains("Santiago") {
            estLat = -33.0  // southern hemisphere, South America
        } else if tz.hasPrefix("Africa/Jo") || tz.hasPrefix("Africa/Ca") {
            estLat = -30.0  // southern Africa
        } else {
            estLat = 35.0   // northern hemisphere default (covers most populated areas)
        }
        return (estLat, estLon)
    }
}

// Solar sunrise/sunset from coordinates and day of year.
// Uses the sunrise equation with longitude correction for solar noon offset.
// Pure math, ~1μs, accurate to ±15 minutes.
func solarSunriseSunset(lat: Double, lon: Double, utcOffsetSec: Int, dayOfYear: Int) -> (sunrise: Int, sunset: Int) {
    let latRad = lat * .pi / 180.0

    // Solar declination (Spencer formula, radians)
    let dayAngle = 2.0 * .pi / 365.0 * Double(dayOfYear - 1)
    let decl = 0.006918
        - 0.399912 * cos(dayAngle)
        + 0.070257 * sin(dayAngle)
        - 0.006758 * cos(2.0 * dayAngle)
        + 0.000907 * sin(2.0 * dayAngle)

    // Hour angle at sunrise/sunset
    let cosH = -tan(latRad) * tan(decl)
    if cosH < -1.0 { return (3, 23) }   // midnight sun
    if cosH > 1.0  { return (9, 15) }    // polar night

    let halfDay = acos(cosH) * 180.0 / .pi / 15.0  // hours of daylight / 2

    // Solar noon in local clock time: corrects for longitude offset within timezone
    // Without this, sunrise/sunset can be off by 1-2 hours
    let utcOffsetHrs = Double(utcOffsetSec) / 3600.0
    let solarNoon = 12.0 + (utcOffsetHrs * 15.0 - lon) / 15.0

    let sunriseHour = Int(solarNoon - halfDay + 0.5)
    let sunsetHour = Int(solarNoon + halfDay + 0.5)

    return (max(0, min(23, sunriseHour)), max(0, min(23, sunsetHour)))
}

// Convenience: get sunrise/sunset for current machine timezone and day
func sunriseSunset(dayOfYear: Int) -> (sunrise: Int, sunset: Int) {
    let tz = TimeZone.current
    let coords = timezoneCoordinates(tz.identifier)
    return solarSunriseSunset(lat: coords.lat, lon: coords.lon,
                              utcOffsetSec: tz.secondsFromGMT(), dayOfYear: dayOfYear)
}

// Previous approach: hardcoded timezone→month→hours lookup table (kept for reference)
/*
func sunriseSunsetLegacy(tz: String, month: Int) -> (sunrise: Int, sunset: Int) {
    switch tz {

    // --- North America ---
    case "America/New_York", "America/Toronto", "America/Detroit", "America/Montreal":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (6, 20)
        default: return (7, 18)
        }
    case "America/Chicago", "America/Winnipeg", "America/Indiana/Indianapolis":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (6, 20)
        default: return (7, 18)
        }
    case "America/Denver", "America/Boise":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (6, 21)
        default: return (7, 18)
        }
    case "America/Vancouver", "America/Los_Angeles", "America/Tijuana":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (6, 20)
        default: return (7, 18)
        }
    case "America/Edmonton", "America/Calgary":
        switch month {
        case 12, 1, 2: return (8, 16)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (5, 21)
        default: return (7, 18)
        }
    case "America/Phoenix":
        // No DST, near-equatorial variation
        switch month {
        case 12, 1, 2: return (7, 17)
        case 6, 7, 8: return (5, 19)
        default: return (6, 18)
        }
    case "America/Halifax", "America/St_Johns":
        switch month {
        case 12, 1, 2: return (8, 16)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (6, 21)
        default: return (7, 17)
        }
    case "America/Anchorage":
        switch month {
        case 12, 1, 2: return (10, 15)
        case 3, 4, 5: return (7, 20)
        case 6, 7, 8: return (4, 23)
        default: return (8, 18)
        }
    case "Pacific/Honolulu":
        switch month {
        case 12, 1, 2: return (7, 18)
        case 6, 7, 8: return (6, 19)
        default: return (6, 18)
        }
    case "America/Mexico_City":
        switch month {
        case 12, 1, 2: return (7, 18)
        case 3, 4, 5: return (7, 19)
        case 6, 7, 8: return (7, 20)
        default: return (7, 19)
        }

    // --- South America (inverted seasons) ---
    case "America/Sao_Paulo", "America/Argentina/Buenos_Aires":
        switch month {
        case 12, 1, 2: return (5, 20)   // summer
        case 3, 4, 5: return (6, 18)
        case 6, 7, 8: return (7, 17)     // winter
        default: return (6, 19)
        }
    case "America/Santiago":
        switch month {
        case 12, 1, 2: return (6, 21)
        case 3, 4, 5: return (7, 18)
        case 6, 7, 8: return (8, 17)
        default: return (6, 19)
        }
    case "America/Lima", "America/Bogota":
        return (6, 18)  // near equator, minimal variation

    // --- Europe ---
    case "Europe/London", "Europe/Dublin":
        switch month {
        case 12, 1, 2: return (8, 16)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (5, 21)
        default: return (7, 17)
        }
    case "Europe/Paris", "Europe/Berlin", "Europe/Amsterdam", "Europe/Brussels",
         "Europe/Madrid", "Europe/Rome", "Europe/Zurich", "Europe/Vienna":
        switch month {
        case 12, 1, 2: return (8, 17)
        case 3, 4, 5: return (6, 20)
        case 6, 7, 8: return (6, 21)
        default: return (7, 18)
        }
    case "Europe/Bucharest", "Europe/Athens", "Europe/Sofia", "Europe/Helsinki",
         "Europe/Tallinn", "Europe/Vilnius", "Europe/Riga":
        switch month {
        case 12, 1, 2: return (8, 16)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (5, 21)
        default: return (7, 17)
        }
    case "Europe/Stockholm", "Europe/Oslo", "Europe/Copenhagen", "Europe/Warsaw":
        switch month {
        case 12, 1, 2: return (9, 15)
        case 3, 4, 5: return (6, 20)
        case 6, 7, 8: return (4, 22)
        default: return (7, 17)
        }
    case "Europe/Moscow", "Europe/Minsk":
        switch month {
        case 12, 1, 2: return (9, 16)
        case 3, 4, 5: return (6, 20)
        case 6, 7, 8: return (4, 22)
        default: return (7, 17)
        }
    case "Europe/Istanbul":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 3, 4, 5: return (6, 19)
        case 6, 7, 8: return (5, 20)
        default: return (7, 18)
        }
    case "Europe/Lisbon":
        switch month {
        case 12, 1, 2: return (8, 17)
        case 3, 4, 5: return (6, 20)
        case 6, 7, 8: return (6, 21)
        default: return (7, 18)
        }

    // --- Middle East ---
    case "Asia/Dubai", "Asia/Muscat":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 6, 7, 8: return (6, 19)
        default: return (6, 18)
        }
    case "Asia/Riyadh", "Asia/Qatar":
        switch month {
        case 12, 1, 2: return (6, 17)
        case 6, 7, 8: return (5, 19)
        default: return (6, 18)
        }
    case "Asia/Tehran":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 6, 7, 8: return (6, 20)
        default: return (6, 18)
        }
    case "Asia/Jerusalem", "Asia/Tel_Aviv":
        switch month {
        case 12, 1, 2: return (6, 17)
        case 6, 7, 8: return (5, 20)
        default: return (6, 18)
        }

    // --- East & Southeast Asia ---
    case "Asia/Tokyo", "Asia/Seoul":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 3, 4, 5: return (5, 18)
        case 6, 7, 8: return (5, 19)
        default: return (6, 17)
        }
    case "Asia/Shanghai", "Asia/Hong_Kong", "Asia/Taipei":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 3, 4, 5: return (6, 18)
        case 6, 7, 8: return (6, 19)
        default: return (6, 18)
        }
    case "Asia/Bangkok", "Asia/Ho_Chi_Minh", "Asia/Jakarta":
        switch month {
        case 12, 1, 2: return (6, 18)
        case 6, 7, 8: return (6, 18)
        default: return (6, 18)
        }
    case "Asia/Manila":
        switch month {
        case 12, 1, 2: return (6, 17)
        case 6, 7, 8: return (5, 18)
        default: return (6, 18)
        }
    case "Asia/Singapore", "Asia/Kuala_Lumpur":
        return (7, 19)

    // --- South Asia ---
    case "Asia/Kolkata", "Asia/Calcutta":
        switch month {
        case 12, 1, 2: return (7, 18)
        case 3, 4, 5: return (6, 18)
        case 6, 7, 8: return (6, 19)
        default: return (6, 18)
        }
    case "Asia/Karachi":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 6, 7, 8: return (5, 19)
        default: return (6, 18)
        }
    case "Asia/Dhaka":
        switch month {
        case 12, 1, 2: return (6, 17)
        case 6, 7, 8: return (5, 19)
        default: return (6, 18)
        }

    // --- Africa ---
    case "Africa/Cairo":
        switch month {
        case 12, 1, 2: return (7, 17)
        case 6, 7, 8: return (5, 19)
        default: return (6, 18)
        }
    case "Africa/Johannesburg":
        switch month {
        case 12, 1, 2: return (5, 19)   // southern summer
        case 6, 7, 8: return (7, 17)     // southern winter
        default: return (6, 18)
        }
    case "Africa/Lagos", "Africa/Accra":
        return (6, 18)  // near equator
    case "Africa/Nairobi", "Africa/Dar_es_Salaam":
        return (6, 18)  // equatorial

    // --- Australia & Pacific (inverted seasons) ---
    case "Australia/Sydney", "Australia/Melbourne":
        switch month {
        case 12, 1, 2: return (6, 20)
        case 3, 4, 5: return (7, 18)
        case 6, 7, 8: return (7, 17)
        default: return (6, 19)
        }
    case "Australia/Perth":
        switch month {
        case 12, 1, 2: return (5, 19)
        case 6, 7, 8: return (7, 17)
        default: return (6, 18)
        }
    case "Australia/Brisbane":
        switch month {
        case 12, 1, 2: return (5, 19)
        case 6, 7, 8: return (6, 17)
        default: return (6, 18)
        }
    case "Pacific/Auckland":
        switch month {
        case 12, 1, 2: return (6, 21)
        case 3, 4, 5: return (7, 18)
        case 6, 7, 8: return (8, 17)
        default: return (6, 19)
        }
    case "Pacific/Fiji":
        switch month {
        case 12, 1, 2: return (6, 19)
        case 6, 7, 8: return (6, 18)
        default: return (6, 18)
        }

    default:
        return (6, 18)
    }
}
*/

// Nerd Font clock face icons: nf-md-clock_time_one (U+F143F) through twelve (U+F144A)
// Maps 24h hour to the correct 12h clock face glyph
func clockIcon(hour: Int) -> String {
    // 12h mapping: 0/12→12, 1/13→1, ..., 11/23→11
    let h12 = hour % 12  // 0-11
    // Outline codepoints: 1=F144B, 2=F144C, ..., 12=F1456
    let codepoint = h12 == 0 ? 0xF1456 : (0xF144B + h12 - 1)
    return String(UnicodeScalar(codepoint)!)
}

func updateProgress() {
    let cal = Calendar.current
    let now = Date()
    let hour = cal.component(.hour, from: now)
    let minute = cal.component(.minute, from: now)
    let year = cal.component(.year, from: now)
    let dayOfYear = cal.ordinality(of: .day, in: .year, for: now) ?? 1

    let isLeap = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0)
    let daysInYear = isLeap ? 366 : 365
    let nextDay = dayOfYear == daysInYear ? 1 : dayOfYear + 1

    let minutesIntoDay = hour * 60 + minute
    let progress = minutesIntoDay * 100 / 1440

    let (sunriseHour, sunsetHour) = sunriseSunset(dayOfYear: dayOfYear)

    // Determine icon and color state:
    // - Sunrise hour, first 30 min: gold ◐
    // - Sunset hour, first 30 min: blue ◑
    // - Minute 0 (top of hour, not during sunrise/sunset): white flash
    // - Otherwise: gray clock face
    let gold = "0xffE8A838"
    let blue = "0xff4A90D9"
    let red = "0xffE74C3C"
    let white = "0xffFFFFFF"
    let gray = "0xffA0A0A0"

    let icon: String
    let highlightColor: String  // clock icon + slider bar
    let dayColor: String        // both day numbers (must match)
    let displayHour = minute >= 30 ? hour + 1 : hour

    if hour == sunriseHour && minute < 30 {
        icon = "◐"
        highlightColor = gold
        dayColor = gold
    } else if hour == sunsetHour && minute < 30 {
        icon = "◑"
        highlightColor = blue
        dayColor = blue
    } else if minute == 0 {
        icon = clockIcon(hour: displayHour)
        highlightColor = red
        dayColor = red
    } else {
        icon = clockIcon(hour: displayHour)
        highlightColor = white
        dayColor = gray
    }

    let time = String(format: "%02d:%02d", hour, minute)

    // Slider properties set without animation (startupFade interferes with slider state)
    let sb = "/opt/homebrew/bin/sketchybar"
    let sliderProc = Process()
    sliderProc.executableURL = URL(fileURLWithPath: sb)
    sliderProc.arguments = ["--set", "progress", "slider.percentage=\(progress)",
                            "slider.highlight_color=\(highlightColor)",
                            "slider.background.color=0xff8A869E"]
    try? sliderProc.run()

    sketchybar([
        "--set", "progress_icon", "icon=\(icon)", "icon.color=\(highlightColor)",
        "--set", "progress", "icon=\(dayOfYear)", "icon.color=\(dayColor)",
        "label=\(nextDay)", "label.color=\(dayColor)",
        "--set", "clock_time", "label=\(time)"
    ])
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Battery (IOKit, 1s read with change detection)
// ═══════════════════════════════════════════════════════════════════

var lastBattPct = -1
var lastBattPlugged: Bool? = nil
var lastBattCycles = -1

func updateBattery() {
    let matching = IOServiceMatching("AppleSmartBattery")
    let service = IOServiceGetMatchingService(kIOMainPortDefault, matching)
    guard service != IO_OBJECT_NULL else { return }
    defer { IOObjectRelease(service) }

    var propsRef: Unmanaged<CFMutableDictionary>?
    guard IORegistryEntryCreateCFProperties(service, &propsRef, kCFAllocatorDefault, 0) == KERN_SUCCESS,
          let props = propsRef?.takeRetainedValue() as? [String: Any] else { return }

    let currentCap = props["CurrentCapacity"] as? Int ?? 0
    let maxCap = props["MaxCapacity"] as? Int ?? 1
    let percentage = maxCap > 0 ? (currentCap * 100) / maxCap : 0
    let externalConnected = props["ExternalConnected"] as? Bool ?? false
    let cycleCount = props["CycleCount"] as? Int ?? 0

    // Change detection — skip sketchybar call if nothing changed
    guard percentage != lastBattPct || externalConnected != lastBattPlugged || cycleCount != lastBattCycles else { return }
    lastBattPct = percentage
    lastBattPlugged = externalConnected
    lastBattCycles = cycleCount

    let icon: String
    if externalConnected {
        icon = "\u{F06A5}"  // nf-md-battery_charging_40
    } else if percentage > 80 {
        icon = "\u{F0079}"  // nf-md-battery
    } else if percentage > 60 {
        icon = "\u{F0081}"  // nf-md-battery_80
    } else if percentage > 40 {
        icon = "\u{F007F}"  // nf-md-battery_60
    } else if percentage > 20 {
        icon = "\u{F007D}"  // nf-md-battery_40
    } else if percentage > 10 {
        icon = "\u{F007B}"  // nf-md-battery_20
    } else {
        icon = "\u{F0083}"  // nf-md-battery_alert
    }

    // Plugged in + >=80% → show cycle count (dimmed)
    let display: String
    let color: String
    if externalConnected && percentage >= 80 {
        display = "\(cycleCount)"
        color = "0xff8A869E"
    } else {
        display = "\(percentage)%"
        if percentage > 30 {
            color = "0xffFFFFFF"
        } else if percentage > 10 {
            color = "0xffFFA500"
        } else {
            color = "0xffE74C3C"
        }
    }

    sketchybar(["--set", "battery", "icon=\(icon)", "icon.color=\(color)",
                "label=\(display)", "label.color=\(color)"])
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Disk (statvfs, 1s read with change detection)
// ═══════════════════════════════════════════════════════════════════

var lastDiskPct = -1

func diskColor(_ pct: Int) -> String {
    pct < 30 ? "0xff8A869E" : pct < 60 ? "0xffFFFFFF" : pct < 80 ? "0xffFFA500" : "0xffE74C3C"
}

func updateDisk() {
    var stat = statvfs()
    guard statvfs("/System/Volumes/Data", &stat) == 0, stat.f_blocks > 0 else { return }

    // APFS-correct formula: matches df output (excludes snapshots/purgeable from "used")
    let used = stat.f_blocks - stat.f_bfree
    let usedPct = Int(Double(used) / Double(used + stat.f_bavail) * 100 + 0.5)

    guard usedPct != lastDiskPct else { return }
    lastDiskPct = usedPct

    let color = diskColor(usedPct)
    sketchybar(["--set", "disk", "label=\(usedPct)%", "label.color=\(color)", "icon.color=\(color)"])
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Macmon Metrics (readabilityHandler — cpu/gpu/temp/mem/power)
// ═══════════════════════════════════════════════════════════════════

let cacheFile = "/tmp/sketchybar_cache"
let windowSize = 3
var smoothState: [String: [Int]] = [:]
var macmonBuffer = ""
var macmonHasRestarted = false

func smooth(key: String, value: Int) -> Int {
    var vals = smoothState[key] ?? []
    vals.append(value)
    if vals.count > windowSize { vals = Array(vals.suffix(windowSize)) }
    smoothState[key] = vals
    return Int((Double(vals.reduce(0, +)) / Double(vals.count)) + 0.5)
}

func cpuGpuColor(_ pct: Int) -> String {
    pct < 10 ? "0xff8A869E" : pct < 25 ? "0xffFFFFFF" : pct < 40 ? "0xffFFA500" : "0xffE74C3C"
}

func tempColor(_ t: Int) -> String {
    t <= 0 ? "0xff8A869E" : t < 60 ? "0xffFFFFFF" : t < 80 ? "0xffFFA500" : "0xffE74C3C"
}

func memColor(_ pct: Int) -> String {
    pct < 50 ? "0xff8A869E" : pct < 70 ? "0xffFFFFFF" : pct < 80 ? "0xffFFA500" : "0xffE74C3C"
}

func powerColor(_ w: Double) -> String {
    w < 8 ? "0xffFFFFFF" : w < 15 ? "0xffFFA500" : w < 25 ? "0xffFF6F61" : "0xffE74C3C"
}

func processLine(_ line: String) {
    guard let data = line.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

    // Write cache atomically for other consumers
    let tmp = cacheFile + ".tmp"
    try? line.write(toFile: tmp, atomically: false, encoding: .utf8)
    rename(tmp, cacheFile)

    func ratio(_ key: String) -> Double {
        guard let arr = json[key] as? [Any], arr.count >= 2 else { return 0 }
        return (arr[1] as? NSNumber)?.doubleValue ?? 0
    }

    let cpuPct = min(100, max(0, Int((ratio("ecpu_usage") + ratio("pcpu_usage")) / 2.0 * 100)))
    let gpuPct = min(100, max(0, Int(ratio("gpu_usage") * 100 + 0.5)))

    guard let tempObj = json["temp"] as? [String: Any],
          let rawTemp = (tempObj["cpu_temp_avg"] as? NSNumber)?.doubleValue else { return }
    let rawTempInt = Int(rawTemp + 0.5)

    guard let memObj = json["memory"] as? [String: Any],
          let ramUsage = (memObj["ram_usage"] as? NSNumber)?.int64Value,
          let ramTotal = (memObj["ram_total"] as? NSNumber)?.int64Value,
          ramTotal > 0 else { return }
    let rawMemPct = Int(Double(ramUsage) / Double(ramTotal) * 100 + 0.5)

    guard let rawPower = (json["sys_power"] as? NSNumber)?.doubleValue else { return }
    let rawPowerTenths = Int(rawPower * 10 + 0.5)

    // Apply smoothing
    var temp: Int
    if rawTempInt >= 10, rawTempInt <= 110 {
        temp = smooth(key: "temp", value: rawTempInt)
    } else if let vals = smoothState["temp"], let last = vals.last {
        temp = last
    } else {
        return
    }

    let memPct = smooth(key: "memory", value: rawMemPct)
    let pwrTenths = smooth(key: "power_w10", value: rawPowerTenths)
    let totalPower = Double(pwrTenths) / 10.0

    let cpuC = cpuGpuColor(cpuPct)
    let gpuC = cpuGpuColor(gpuPct)
    let tempC = tempColor(temp)
    let memC = memColor(memPct)
    let pwrC = powerColor(totalPower)
    let pwrLabel = String(format: "%.0f", totalPower)

    sketchybar([
        "--set", "cpu", "label=\(cpuPct)%", "label.color=\(cpuC)", "icon.color=\(cpuC)",
        "--set", "gpu", "label=\(gpuPct)%", "label.color=\(gpuC)", "icon.color=\(gpuC)",
        "--set", "temp", "label=\(temp)\u{00B0}", "label.color=\(tempC)", "icon.color=\(tempC)",
        "--set", "memory", "label=\(memPct)%", "label.color=\(memC)", "icon.color=\(memC)",
        "--set", "power", "label=\(pwrLabel)W", "label.color=\(pwrC)", "icon.color=\(pwrC)"
    ])
}

func setupMacmon() {
    let macmon = Process()
    macmon.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/macmon")
    macmon.arguments = ["pipe", "--interval", "10000"]

    let pipe = Pipe()
    macmon.standardOutput = pipe
    macmon.standardError = FileHandle.nullDevice

    do {
        try macmon.run()
    } catch {
        return  // macmon not installed or failed — other items still work
    }

    let handle = pipe.fileHandleForReading
    handle.readabilityHandler = { fh in
        let data = fh.availableData
        if data.isEmpty {
            // EOF — macmon exited
            fh.readabilityHandler = nil
            if !macmonHasRestarted {
                macmonHasRestarted = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { setupMacmon() }
            }
            return
        }
        guard let chunk = String(data: data, encoding: .utf8) else { return }
        DispatchQueue.main.async {
            macmonBuffer += chunk
            while let range = macmonBuffer.range(of: "\n") {
                let line = String(macmonBuffer[macmonBuffer.startIndex..<range.lowerBound])
                macmonBuffer = String(macmonBuffer[range.upperBound...])
                if !line.isEmpty { processLine(line) }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Connection Quality (SCDynamicStore + CoreWLAN + NWConnection)
// ═══════════════════════════════════════════════════════════════════

var connectionCheckInFlight = false
var pingEMA: Int? = nil

func getGatewayInfo() -> (gateway: String, iface: String)? {
    guard let store = SCDynamicStoreCreate(nil, "bar-daemon" as CFString, nil, nil),
          let dict = SCDynamicStoreCopyValue(store, "State:/Network/Global/IPv4" as CFString) as? [String: Any],
          let router = dict["Router"] as? String,
          let iface = dict["PrimaryInterface"] as? String else { return nil }
    return (router, iface)
}

func getWiFiRSSI() -> Int? {
    guard let iface = CWWiFiClient.shared().interface() else { return nil }
    let rssi = iface.rssiValue()
    return rssi != 0 ? rssi : nil
}

func measureLatency(host: String, port: UInt16, timeout: TimeInterval, completion: @escaping (Double?) -> Void) {
    guard let nwPort = NWEndpoint.Port(rawValue: port) else { completion(nil); return }
    let connection = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: .tcp)
    let start = Date()
    var fired = false

    connection.stateUpdateHandler = { state in
        guard !fired else { return }
        switch state {
        case .ready:
            fired = true
            let ms = Date().timeIntervalSince(start) * 1000
            connection.cancel()
            completion(ms)
        case .failed:
            fired = true
            connection.cancel()
            completion(nil)
        default:
            break
        }
    }

    connection.start(queue: DispatchQueue.main)

    DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
        guard !fired else { return }
        fired = true
        connection.cancel()
        completion(nil)
    }
}

func wifiIcon(rssi: Int?) -> String {
    guard let rssi = rssi else { return "\u{F0928}" }  // 󰤨 strong (fallback)
    if rssi > -50 { return "\u{F0928}" }       // 󰤨 strong
    else if rssi > -60 { return "\u{F0925}" }  // 󰤥 good
    else if rssi > -70 { return "\u{F0922}" }  // 󰤢 fair
    else { return "\u{F091F}" }                // 󰤟 weak
}

func updateConnection() {
    guard networkActive else {
        sketchybar(["--set", "connection", "icon.drawing=off", "label.drawing=off"])
        pingEMA = nil
        return
    }
    guard !connectionCheckInFlight else { return }
    connectionCheckInFlight = true

    guard let gwInfo = getGatewayInfo() else {
        connectionCheckInFlight = false
        sketchybar(["--set", "connection", "icon.drawing=off", "label.drawing=off"])
        return
    }

    // WiFi icon based on RSSI, or ethernet icon
    let icon: String
    if gwInfo.iface.hasPrefix("en0") {
        icon = wifiIcon(rssi: getWiFiRSSI())
    } else {
        icon = "\u{F0200}"  // 󰈀 ethernet
    }

    // Measure gateway + internet latency in parallel
    var gwLatency: Double? = nil
    var inetLatency: Double? = nil
    var gwDone = false
    var inetDone = false

    func finalize() {
        guard gwDone && inetDone else { return }
        connectionCheckInFlight = false

        if let inet = inetLatency {
            // Internet is up — trigger reconnect animation if was down
            if !internetReachable {
                internetReachable = true
                sketchybar(["--trigger", "internet_reconnect"])
                updateLocation(force: true)
            }

            let current = Int(inet + 0.5)
            if let prev = pingEMA {
                pingEMA = (30 * current + 70 * prev) / 100
            } else {
                pingEMA = current
            }
            let label = "\(pingEMA!)\u{2098}\u{209B}"
            let gwInt = gwLatency.map { Int($0 + 0.5) }
            let color: String
            if let gw = gwInt, gw > 50 {
                color = "0xffE74C3C"  // red — local network bad
            } else if pingEMA! < 50 {
                color = "0xff8A869E"  // dim — smooth, don't care
            } else if pingEMA! < 150 {
                color = "0xffFFFFFF"  // white — noticeable but fine
            } else if pingEMA! < 300 {
                color = "0xffFFA500"  // orange — slow
            } else {
                color = "0xffE74C3C"  // red — bad
            }
            sketchybar(["--set", "connection", "icon=\(icon)", "icon.drawing=on", "icon.color=\(color)",
                        "label=\(label)", "label.drawing=on", "label.color=\(color)"])
        } else {
            // Internet is down — trigger disconnect animation if was up
            if internetReachable {
                internetReachable = false
                sketchybar(["--trigger", "internet_disconnect"])
            }
            pingEMA = nil
        }
    }

    // Gateway ping — try port 80 (web UI), then 443, then skip
    // Many consumer routers have no open TCP ports, so gateway latency is best-effort
    let gwPorts: [UInt16] = [80, 443]
    var gwPortIdx = 0

    func tryGateway() {
        guard gwPortIdx < gwPorts.count else {
            // No gateway ports open — skip gateway measurement
            gwDone = true
            finalize()
            return
        }
        let port = gwPorts[gwPortIdx]
        gwPortIdx += 1
        measureLatency(host: gwInfo.gateway, port: port, timeout: 1) { ms in
            if let ms = ms {
                gwLatency = ms
                gwDone = true
                finalize()
            } else {
                tryGateway()  // try next port
            }
        }
    }
    tryGateway()

    // Internet ping — port 443 (HTTPS, never filtered), try all 3 in parallel, take first success
    let targets = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]
    var inetFinished = false
    var inetRemaining = targets.count

    for host in targets {
        measureLatency(host: host, port: 443, timeout: 3) { ms in
            inetRemaining -= 1
            if let ms = ms, !inetFinished {
                inetFinished = true
                inetLatency = ms
                inetDone = true
                finalize()
            } else if inetRemaining == 0 && !inetFinished {
                inetFinished = true
                inetDone = true
                finalize()
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Location (URLSession, NWPathMonitor-triggered only)
// ═══════════════════════════════════════════════════════════════════

var cachedFingerprint = ""
var cachedCountry = ""

func countryToFlag(_ cc: String) -> String {
    String(cc.uppercased().unicodeScalars.compactMap {
        UnicodeScalar(0x1F1E6 + $0.value - 0x41)
    }.map { Character($0) })
}

func updateLocation(force: Bool = false) {
    // Don't update while disconnected (animation script controls location item)
    guard internetReachable else { return }
    guard networkActive else {
        sketchybar(["--set", "location", "icon=\u{F0AC8}", "icon.drawing=on", "label=", "label.drawing=off"])
        return
    }

    // Network fingerprint = interface + gateway (detects physical network switches)
    // Note: VPN changes don't alter SCDynamicStore — force=true bypasses cache for those
    guard let gwInfo = getGatewayInfo() else {
        sketchybar(["--set", "location", "icon=\u{F059F}", "icon.drawing=on", "label=", "label.drawing=off"])
        return
    }
    let fingerprint = "\(gwInfo.iface)|\(gwInfo.gateway)"

    // Skip if network hasn't changed (unless forced by path monitor — VPN changes)
    if !force && fingerprint == cachedFingerprint && !cachedCountry.isEmpty {
        let flag = countryToFlag(cachedCountry)
        sketchybar(["--set", "location", "icon=\(flag)", "icon.drawing=on",
                    "label=\(cachedCountry)", "label.drawing=on"])
        return
    }
    cachedFingerprint = fingerprint

    // Async geo lookup
    guard let url = URL(string: "https://ipinfo.io/country") else { return }
    var request = URLRequest(url: url, timeoutInterval: 3)
    request.cachePolicy = .reloadIgnoringLocalCacheData
    URLSession.shared.dataTask(with: request) { data, _, _ in
        DispatchQueue.main.async {
            guard let data = data,
                  let country = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                  country.count == 2 else {
                // Lookup failed — show globe
                sketchybar(["--set", "location", "icon=\u{F059F}", "icon.drawing=on", "label=", "label.drawing=off"])
                return
            }
            cachedCountry = country
            let flag = countryToFlag(country)
            sketchybar(["--set", "location", "icon=\(flag)", "icon.drawing=on",
                        "label=\(country)", "label.drawing=on"])
        }
    }.resume()
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Main: start all event sources
// ═══════════════════════════════════════════════════════════════════

// Pre-load macmon cache so metrics items aren't empty during first 10s
if let existing = try? String(contentsOfFile: cacheFile, encoding: .utf8), !existing.isEmpty {
    processLine(existing)
}

// 1. NWPathMonitor (push-based network change → connection + location + trigger)
setupPathMonitor()

// 2. Macmon pipe reader (callback-based, ~10s intervals from macmon)
setupMacmon()

// 2b. Initialize networkActive + baseline bytes (so first updateNetwork shows real delta)
let (initDown, initUp, initialActive) = readNetBytes()
networkActive = initialActive
prevDown = initDown
prevUp = initUp
hasPrev = true

// 3. First updates: all sides simultaneously at +1s (startupSmooth=true animates them in)
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    // Right side
    updateProgress()
    updateBattery()
    updateDisk()
    // Left side
    updateNetwork()
    updateConnection()
    updateLocation()
}

// End smooth startup after 4s — subsequent updates are instant
DispatchQueue.main.asyncAfter(deadline: .now() + 4) { startupSmooth = false }

// 4. Main 1s timer: starts after first updates settle
let mainTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
mainTimer.schedule(deadline: .now() + 2.0, repeating: 1.0)
mainTimer.setEventHandler {
    tick += 1
    updateNetwork()
    updateBattery()
    updateDisk()
    if tick % 30 == 0 { updateConnection() }
}
mainTimer.resume()

// 5. Progress + clock timer (60s, minute-aligned)
let cal = Calendar.current
let secs = cal.component(.second, from: Date())
let progressDelay = Double(60 - secs)

let progressTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
progressTimer.schedule(deadline: .now() + progressDelay, repeating: 60.0)
progressTimer.setEventHandler { updateProgress() }
progressTimer.resume()

// 7. SIGUSR1 handler: re-enable smooth animation (used by wake/unlock fade-in)
let sigSource = DispatchSource.makeSignalSource(signal: SIGUSR1, queue: DispatchQueue.main)
signal(SIGUSR1, SIG_IGN)  // ignore default handler, let GCD handle it
sigSource.setEventHandler {
    startupSmooth = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { startupSmooth = false }
}
sigSource.resume()

dispatchMain()
