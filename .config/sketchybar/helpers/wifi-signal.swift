import CoreWLAN
import Foundation

if let iface = CWWiFiClient.shared().interface() {
    let rssi = iface.rssiValue()
    print(rssi != 0 ? rssi : 0)
} else {
    print("0")
}
