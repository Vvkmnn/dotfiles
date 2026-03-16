import Foundation

// Persistent daemon: spawns macmon, reads JSON, updates sketchybar
// Replaces: macmon shell pipe loop + cpu.sh + gpu.sh + temp.sh + memory.sh + power.sh
// State kept in-memory (no disk I/O for smoothing)

let cacheFile = "/tmp/sketchybar_cache"
let windowSize = 3

// MARK: - In-memory smoothing (no state file needed — daemon is persistent)

var smoothState: [String: [Int]] = [:]

func smooth(key: String, value: Int) -> Int {
    var vals = smoothState[key] ?? []
    vals.append(value)
    if vals.count > windowSize { vals = Array(vals.suffix(windowSize)) }
    smoothState[key] = vals
    return Int((Double(vals.reduce(0, +)) / Double(vals.count)) + 0.5)
}

// MARK: - Color thresholds (match existing plugin colors exactly)

func cpuGpuColor(_ pct: Int) -> String {
    pct < 10 ? "0xff606060" : pct < 25 ? "0xffFFFFFF" : pct < 40 ? "0xffFFA500" : "0xffE74C3C"
}

func tempColor(_ t: Int) -> String {
    t <= 0 ? "0xff606060" : t < 60 ? "0xffFFFFFF" : t < 80 ? "0xffFFA500" : "0xffE74C3C"
}

func memColor(_ pct: Int) -> String {
    pct < 50 ? "0xff606060" : pct < 70 ? "0xffFFFFFF" : pct < 80 ? "0xffFFA500" : "0xffE74C3C"
}

func powerColor(_ w: Double) -> String {
    w < 8 ? "0xffFFFFFF" : w < 15 ? "0xffFFA500" : w < 25 ? "0xffFF6F61" : "0xffE74C3C"
}

// MARK: - Process one macmon JSON line

func processLine(_ line: String) {
    guard let data = line.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

    // Write cache atomically for other consumers (e.g. future scripts)
    let tmp = cacheFile + ".tmp"
    try? line.write(toFile: tmp, atomically: false, encoding: .utf8)
    rename(tmp, cacheFile)

    // Parse usage arrays: [count, ratio]
    func ratio(_ key: String) -> Double {
        guard let arr = json[key] as? [Any], arr.count >= 2 else { return 0 }
        return (arr[1] as? NSNumber)?.doubleValue ?? 0
    }

    // CPU: average of efficiency + performance core usage
    let cpuPct = min(100, max(0, Int((ratio("ecpu_usage") + ratio("pcpu_usage")) / 2.0 * 100)))

    // GPU
    let gpuPct = min(100, max(0, Int(ratio("gpu_usage") * 100 + 0.5)))

    // Temp (nested: {"temp": {"cpu_temp_avg": F, "gpu_temp_avg": F}})
    guard let tempObj = json["temp"] as? [String: Any],
          let rawTemp = (tempObj["cpu_temp_avg"] as? NSNumber)?.doubleValue else { return }
    let rawTempInt = Int(rawTemp + 0.5)

    // Memory (nested: {"memory": {"ram_total": N, "ram_usage": N, ...}})
    guard let memObj = json["memory"] as? [String: Any],
          let ramUsage = (memObj["ram_usage"] as? NSNumber)?.int64Value,
          let ramTotal = (memObj["ram_total"] as? NSNumber)?.int64Value,
          ramTotal > 0 else { return }
    let rawMemPct = Int(Double(ramUsage) / Double(ramTotal) * 100 + 0.5)

    // Power (top-level: "sys_power": F)
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

    // Colors
    let cpuC = cpuGpuColor(cpuPct)
    let gpuC = cpuGpuColor(gpuPct)
    let tempC = tempColor(temp)
    let memC = memColor(memPct)
    let pwrC = powerColor(totalPower)
    let pwrLabel = String(format: "%.0f", totalPower)

    // Single sketchybar IPC call for all 5 metrics
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/sketchybar")
    proc.arguments = [
        "--set", "cpu", "label=\(cpuPct)%", "label.color=\(cpuC)", "icon.color=\(cpuC)",
        "--set", "gpu", "label=\(gpuPct)%", "label.color=\(gpuC)", "icon.color=\(gpuC)",
        "--set", "temp", "label=\(temp)°", "label.color=\(tempC)", "icon.color=\(tempC)",
        "--set", "memory", "label=\(memPct)%", "label.color=\(memC)", "icon.color=\(memC)",
        "--set", "power", "label=\(pwrLabel)W", "label.color=\(pwrC)", "icon.color=\(pwrC)"
    ]
    try? proc.run()
    proc.waitUntilExit()
}

// MARK: - Startup: pre-load existing cache so items aren't empty during macmon's first sample

if let existing = try? String(contentsOfFile: cacheFile, encoding: .utf8), !existing.isEmpty {
    processLine(existing)
}

// MARK: - Main: spawn macmon and read its stdout

let macmon = Process()
macmon.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/macmon")
macmon.arguments = ["pipe", "--interval", "10000"]

let pipe = Pipe()
macmon.standardOutput = pipe
macmon.standardError = FileHandle.nullDevice

do {
    try macmon.run()
} catch {
    fputs("metrics-daemon: failed to start macmon\n", stderr)
    exit(1)
}

// Line-buffered reading (macmon outputs one JSON object per line)
let handle = pipe.fileHandleForReading
var buffer = ""

while true {
    let data = handle.availableData
    if data.isEmpty { break }  // EOF — macmon exited
    guard let chunk = String(data: data, encoding: .utf8) else { continue }
    buffer += chunk
    while let range = buffer.range(of: "\n") {
        let line = String(buffer[buffer.startIndex..<range.lowerBound])
        buffer = String(buffer[range.upperBound...])
        if !line.isEmpty { processLine(line) }
    }
}
