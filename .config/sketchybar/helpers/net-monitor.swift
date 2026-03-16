import Network
import Foundation

let monitor = NWPathMonitor()
monitor.pathUpdateHandler = { path in
  let data = "changed\n".data(using: .utf8)!
  FileHandle.standardOutput.write(data)
  fflush(stdout)
}

monitor.start(queue: DispatchQueue(label: "net-monitor"))
dispatchMain()
