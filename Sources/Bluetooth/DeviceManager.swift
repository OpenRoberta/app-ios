//  Copyright © 2018 Fraunhofer Gesellschaft. All rights reserved.

import Foundation
import WebKit

class DeviceManager: NSObject, LEDeviceManagerDelegate {
    static let sharedManager = DeviceManager()
	
	static func json2dict(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("convert to utf8 failed for: \(text)")
        }
        return nil
    }

	static func dict2jsonstring(dict: [String: Any], prettyPrinted:Bool = false) -> String? {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: options)
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
				if (string.contains("'")) {
					print("error caused by single quotes: \(string)")
					return nil
				} else {
				    return string as String
				}
            } else {
                print("utf-encoding failed for: \(data)")
                return nil
            }
        } catch {
            print("error when: stringifying \(dict) got: \(error.localizedDescription)")
            return nil
        }
    }
	
	static func dict2webkit(dict: [String: Any]) {
		let json = dict2jsonstring(dict: dict)
        let cmd = "webviewController.appToJsInterface('" + json! + "')"
        print("send: \(cmd)")
        DeviceManager.sharedManager.webView.evaluateJavaScript(cmd, completionHandler: nil)
	}

    private (set) var webView: WKWebView!
    private(set) var devices: [String: LEDevice] = [:]
    private(set) var selectedDevice: WeDoDevice?
    
    override init() {
        super.init()
        LEDeviceManager.shared().add(self) // set the delegate
    }
    
    func setWebView(webView: WKWebView!) {
        self.webView = webView
    }
    
    // MARK: -
    
    /**
     Start scanning for bluetooth devices
     */
    func startScan() {
        LEDeviceManager.shared()?.scan()
    }
    
    /**
     Stop scanning for bluetooth devices
     */
    func stopScan() {
        LEDeviceManager.shared()?.stopScanning()
    }
    
    /**
     Make a connection to the bluetooth device and store a reference to the device
     */
    func connectToDevice(_ name: String) {
		let device = devices[name]
        let wedoDevice = WeDoDevice(device: device!)
        selectedDevice = wedoDevice.connect() ? wedoDevice : nil
    }
    
    /**
     Cancel the connection between device and app
    */
    func disconnectFromDevice() {
        selectedDevice?.disconnect()
        selectedDevice = nil
    }

// MARK: - LEDeviceManagerDelegate

	func deviceManager(_ manager: LEDeviceManager!, deviceDidAppear device: LEDevice!) {
        if (devices[device.deviceId] != nil) {
			print("device already there: \(device.name!)")
		} else {
			devices[device.deviceId] = device
			print("device added: \(device.name!)")
		}
        let inform = ["target":"wedo", "type":"scan", "state":"appeared", "brickid":device.deviceId, "brickname":device.name]
        DeviceManager.dict2webkit(dict: inform as [String : Any])
    }
    
    func deviceManager(_ manager: LEDeviceManager!, deviceDidDisappear device: LEDevice!) {
        devices[device.deviceId] = nil
        print("device removed: \(device.name!)")
    }
    
    func deviceManager(_ manager: LEDeviceManager!, willStartConnectingTo device: LEDevice!) {
        print("start connecting to device: \(String(describing: device.name))")
    }
    
    func deviceManager(_ manager: LEDeviceManager!, didStartInterrogatingDevice device: LEDevice!) {
        print("start interrogating device: \(String(describing: device.name))")
    }
    
    func deviceManager(_ manager: LEDeviceManager!, didFinishInterrogatingDevice device: LEDevice!) {
        print("finished interrogating device: \(String(describing: device.name))")
    }
    
    func deviceManager(_ manager: LEDeviceManager!, didDisconnectFrom device: LEDevice!, willAttemptAutoReconnect autoReconnect: Bool, error: Error!) {
        let inform = ["target":"wedo", "type":"connect", "state":"disconnected", "brickid":device.deviceId]
        DeviceManager.dict2webkit(dict: inform as [String : Any])
        print("disconnected from device: \(String(describing: device.name))")
    }
    
    func deviceManager(_ manager: LEDeviceManager!, didFailToConnectTo device: LEDevice!, willAttemptAutoReconnect autoReconnect: Bool, error: Error!) {
        let inform = ["target":"wedo", "type":"connect", "state":"failed", "brickid":device.deviceId]
        DeviceManager.dict2webkit(dict: inform as [String : Any])
        print("connect to device fails: \(String(describing: device.name))")
    }
}
