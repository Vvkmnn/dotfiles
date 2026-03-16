import Darwin
import Foundation

// Persistent daemon: reads network byte counters via getifaddrs (kernel, no subprocess)
// Replaces: network_stats.sh which spawned ifconfig(×2) + netstat + awk(×6) every second
// ~600 subprocess spawns/min → 0

var prevDown: UInt32 = 0
var prevUp: UInt32 = 0
var hasPrev = false

// MARK: - Read byte counters from kernel via getifaddrs

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
            totalDown = totalDown &+ UInt32(bitPattern: Int32(data.pointee.ifi_ibytes))
            totalUp = totalUp &+ UInt32(bitPattern: Int32(data.pointee.ifi_obytes))
        }
    }
    return (totalDown, totalUp, active)
}

// MARK: - Colors (match existing network_stats.sh thresholds exactly)

func downColor(_ kb: Int) -> String {
    kb < 50 ? "0xff8A869E" : kb < 500 ? "0xffFFFFFF" : kb < 5000 ? "0xffFFA500" : "0xffE74C3C"
}

func upColor(_ kb: Int) -> String {
    kb < 20 ? "0xff8A869E" : kb < 200 ? "0xffFFFFFF" : kb < 2000 ? "0xffFFA500" : "0xffE74C3C"
}

func fillColor(_ c: String) -> String {
    // 0xffXXXXXX → 0x33XXXXXX
    "0x33" + c.dropFirst(4)
}

// MARK: - Update sketchybar

func sketchybar(_ args: [String]) {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/sketchybar")
    proc.arguments = args
    try? proc.run()
    proc.waitUntilExit()
}

func update() {
    let (curDown, curUp, active) = readNetBytes()

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
        // Wrapping-safe subtraction (UInt32 handles overflow naturally)
        let diffDown = Int(curDown &- prevDown)
        let diffUp = Int(curUp &- prevUp)
        let downKB = max(0, diffDown) / 1024
        let upKB = max(0, diffUp) / 1024

        // Format: max 2 digits + unit (e.g. 99K, 1M)
        let downStr = downKB < 100 ? "\(downKB)K" : "\((downKB + 1023) / 1024)M"
        let upStr = upKB < 100 ? "\(upKB)K" : "\((upKB + 1023) / 1024)M"

        // Graph: log scale — 1K=0, 10K=0.33, 100K=0.67, 1000K=1.0
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
        // First tick — show zeros
        sketchybar([
            "--set", "network_down", "label=0K", "label.color=0xff8A869E", "icon.color=0xff8A869E",
                "icon.drawing=on", "label.drawing=on",
            "--set", "network_up", "label=0K", "label.color=0xff8A869E", "icon.color=0xff8A869E",
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

// MARK: - Main: 1-second timer

let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
timer.schedule(deadline: .now() + 0.5, repeating: 1.0)  // 0.5s delay for items to exist
timer.setEventHandler { update() }
timer.resume()

dispatchMain()
