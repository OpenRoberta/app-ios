//  Copyright © 2018 Fraunhofer Gesellschaft. All rights reserved.

import Foundation

class WeDoDevice : NSObject {
    let nativeSDKDevice: LEDevice
    var services: [String: LEService] = [:]
    
    init(device: LEDevice) {
        nativeSDKDevice = device
    }
    
    deinit {
        nativeSDKDevice.remove(self)
    }
    
    private func upd2webkit(state: Any, properties dict: [String: Any]) {
        var clone = dict
        clone["target"] = "wedo"
        clone["type"] = "update"
        clone["brickid"] = nativeSDKDevice.deviceId
        clone["state"] = "\(state)" // a kind of toString
        
        let json = DeviceManager.dict2jsonstring(dict: clone)
        let cmd = "webviewController.appToJsInterface('" + json! + "')"
        print("send: \(cmd)")
        DeviceManager.sharedManager.webView.evaluateJavaScript(cmd, completionHandler: nil)
    }
    
    // MARK: - Bluetooth
    
    func connect() -> Bool {
        guard let deviceManager = LEDeviceManager.shared() else {
            print("no native device - connect request ignored")
            return false
        }
        nativeSDKDevice.add(self)
		services = [:]
        deviceManager.connect(to: nativeSDKDevice)
        return true
    }

    func disconnect() {
        guard let deviceManager = LEDeviceManager.shared() else {
            print("no native device - disconnect request ignored")
            return
        }
        nativeSDKDevice.remove(self)
        deviceManager.cancelDeviceConnection(nativeSDKDevice)
    }
	
	func process(_ request: [String: Any]) {
        guard let deviceId = nativeSDKDevice.deviceId else {
            print("no native device - javascript request ignored")
            return
        }
		if let requestDevice = request["device"] as? String {
			if (requestDevice != deviceId) {
                print("device ids do not match: \(requestDevice) != \(deviceId)")
			}
		} else {
			print("device ids do not match: device in javascript request is nil")
		}
        switch (request["actuator"] as? String) {
            case "motor":
                if let m = services[deviceId + "--motor"] as? LEMotor,
                   let action = request["action"] as? String {
                    if (action == "on") {
                        let direction = js2int(request["direction"])
                        let leDirection: LEMotorDirection
                        if (direction == 0) {
                            leDirection = .left
                        } else if (direction == 1) {
                            leDirection = .right
                        } else {
                            leDirection = .drifting
                        }
                        m.run(in: leDirection, power: js2int(request["power"]));
                    } else if (action == "stop") {
                        m.brake();
                    }
                } else {
                    print("request ignored - motor service not found")
                }
            case "piezo":
                if let p = services[deviceId + "--piezo"] as? LEPiezoTonePlayer {
                    p.playFrequency(js2int(request["frequency"]), forMilliseconds: js2int(request["duration"]))
                } else {
                    print("request ignored - piezo service not found")
                }
            case "light":
                if let rgb = services[deviceId + "--light"] as? LERGBLight {
                    rgb.colorIndex = js2int(request["color"])
                } else {
                    print("request ignored - light service not found")
                }
            default:
                print("request ignored - invalid actuator: \(request)")
        }
	}
    
    private func js2int(_ any: Any?) -> UInt {
        if let str = any as? String {
            let uint = UInt(str)
            return uint ?? 0
        } else if let int = any as? Int {
            let uint = UInt(int)
            return uint
        } else {
            print("invalid uint from json, returning 0: \(String(describing: any))")
            return 0;
        }
    }
}   

// MARK: - LEDeviceDelegate

extension WeDoDevice: LEDeviceDelegate {
    
    func device(_ device: LEDevice?, didUpdate deviceInfo: LEDeviceInfo, error err: Error) {
        guard let deviceId = nativeSDKDevice.deviceId else {
            print("no native device - request ignored")
            return
        }
        print("LEDeviceDelegate deviceInfo for \(deviceId)")
        let inform = ["target":"wedo", "type":"connect", "state":"connected", "brickid":deviceId, "brickname":nativeSDKDevice.name]
        DeviceManager.dict2webkit(dict: inform as [String : Any])
    }
    
    func device(_ device: LEDevice!, didAdd service: LEService!) {
        guard let deviceId = nativeSDKDevice.deviceId else {
            print("no native device - request ignored")
            return
        }
        print("LEDeviceDelegate add service: \(String(describing: service.serviceName))")
        
        var key = ""
        var type = ""
        switch service {
        case let voltageSensor as LEVoltageSensor:
            type = "sensor"
            voltageSensor.add(self)
            voltageSensor.sendReadValueRequest()
            print("event listener (voltage) added")
        case let tiltSensor as LETiltSensor:
            type = "sensor"
            tiltSensor.tiltSensorMode = .tilt   // important: if you don't set this value explict the sensor will not work
            tiltSensor.add(self)
            tiltSensor.sendReadValueRequest()
            print("event listener (tilt sensor) added. Mode \(tiltSensor.tiltSensorMode)")
        case let motionSensor as LEMotionSensor:
            type = "sensor"
            motionSensor.motionSensorMode = .detect   // important: if you don't set this value explict the sensor will not work
            motionSensor.add(self)
            motionSensor.sendReadValueRequest()
            print("event listener (motion sensor) added. Mode \(motionSensor.motionSensorMode)")
        case let motor as LEMotor:
            type = "actuator"
            key = deviceId + "--motor"
            services[key] = motor
            print("motor added: \(String(describing: service.serviceName))")
        case let piezo as LEPiezoTonePlayer:
            type = "actuator"
            key = deviceId + "--piezo"
            services[key] = piezo
            print("piezo added: \(String(describing: service.serviceName))")
		case let light as LERGBLight:
            type = "actuator"
            key = deviceId + "--light"
            services[key] = light
            print("light added: \(String(describing: service.serviceName))")
		default:
			print("LEDeviceDelegate [ignored] add service: \(String(describing: service.serviceName))")
			return
        }
        let connectId = "\(service.connectInfo.connectID)"
        let inform = ["target":"wedo", "type":"didAddService", "state":"connected", "brickid":nativeSDKDevice.deviceId, type: service.serviceName, "id":connectId]
        DeviceManager.dict2webkit(dict: inform as [String : Any])
    }
    
    func device(_ device: LEDevice!, didRemove service: LEService!) {
        guard let deviceId = nativeSDKDevice.deviceId else {
            print("no native device - request ignored")
            return
        }
        print("LEDeviceDelegate remove service: \(String(describing: service.serviceName))")
        var key = ""
        switch service {
        case let voltageSensor as LEVoltageSensor:
            voltageSensor.remove(self)
            print("event listener (voltage) removed")
        case let tiltSensor as LETiltSensor:
            tiltSensor.remove(self)
            print("event listener (tilt sensor) removed")
        case let motionSensor as LEMotionSensor:
            motionSensor.remove(self)
            print("event listener (motion sensor) removed")
		case let motor as LEMotor:
            key = deviceId + "--motor"
            services[key] = nil
            print("motor removed: \(String(describing: motor.serviceName))")
        case let piezo as LEPiezoTonePlayer:
            key = deviceId + "--piezo"
            services[key] = nil
            print("piezo removed: \(String(describing: piezo.serviceName))")
        case let light as LERGBLight:
            key = deviceId + "--light"
            services[key] = nil
            print("light removed: \(String(describing: light.serviceName))")
		default:
			print("LEDeviceDelegate [ignored] remove service: \(String(describing: service.serviceName))")
			return
		}
        if (key != "") {
            let inform = ["target":"wedo", "type":"didRemoveService", "state":"disconnected", "brickid":nativeSDKDevice.deviceId, "id":key]
            DeviceManager.dict2webkit(dict: inform as [String : Any])
        }
    }
    
    func device(_ device: LEDevice!, didChangeNameFrom oldName: String!, to newName: String!) {
        print("LEDeviceDelegate [ignored] change name from \(String(describing: oldName)) to \(String(describing: newName))")
    }
    
    func device(_ device: LEDevice!, didUpdateBatteryLevel newLevel: NSNumber!) {
	    let scaledLevel = newLevel.doubleValue / 100.0
        print("LEDeviceDelegate [ignored] update battery level to \(scaledLevel)");
    }
    
    func device(_ device: LEDevice!, didUpdateLowVoltageState lowVoltage: Bool) {
        print("LEDeviceDelegate [ignored] update low voltage state to \(lowVoltage)")
    }
    
    func device(_ device: LEDevice!, didChangeButtonState pressed: Bool) {
		print("LEDeviceDelegate change button state to \(pressed)")
		let inform = ["sensor":"button"]
        upd2webkit(state: pressed, properties: inform)
    }
}

// MARK: - LEServiceDelegate

extension WeDoDevice : LEServiceDelegate {
    @objc func service(_ service: LEService!, didUpdateValueDataFrom oldValue: Data!, to newValue: Data!) {
        print("LEServiceDelegate [ignored] update data from \(String(describing: oldValue)) to \(String(describing: newValue))");
    }
    
    @objc func service(_ service: LEService!, didUpdateInputFormatFrom oldFormat: LEInputFormat!, to newFormat: LEInputFormat!) {
        print("LEServiceDelegate [ignored] update input format from \(String(describing: oldFormat)) to \(String(describing: newFormat))");
    }
}

// MARK: - LEVoltageSensorDelegate

extension WeDoDevice: LEVoltageSensorDelegate {
    func voltageSensor(_ sensor: LEVoltageSensor!, didUpdateMilliVolts milliVolts: CGFloat) {
        print("LEVoltageSensorDelegate [ignored] update milli volts to \(milliVolts)");
    }
}

// MARK: - LETiltSensorDelegate

extension WeDoDevice : LETiltSensorDelegate {
    func tiltSensor(_ sensor: LETiltSensor!, didUpdateAngleFrom oldAngle: LETiltSensorAngle, to newAngle: LETiltSensorAngle) {
        let crashDescription = "x=\(newAngle.x) y=\(newAngle.y)"
        print("LETiltSensorDelegate [ignored] update angle to \(crashDescription)");
    }
    
    func tiltSensor(_ sensor: LETiltSensor!, didUpdateDirectionFrom oldDirection: LETiltSensorDirection, to newDirection: LETiltSensorDirection) {
		print("LETiltSensorDelegate update direction to \(newDirection)");
		
		let inform = ["sensor":sensor.serviceName, "id":sensor.defaultInputFormat.connectID] as [String : Any]
        upd2webkit(state: newDirection.rawValue, properties: inform)
    }
    
    func tiltSensor(_ sensor: LETiltSensor!, didUpdateCrashFrom oldCrashValue: LETiltSensorCrash, to newCrashValue: LETiltSensorCrash) {
        let crashDescription = "x=\(newCrashValue.x) y=\(newCrashValue.y) z=\(newCrashValue.z)"
        print("LETiltSensorDelegate [ignored] update crash to \(crashDescription)");
    }
}

// MARK: - LEMotionSensorDelegate

extension WeDoDevice : LEMotionSensorDelegate {
    func motionSensor(_ sensor: LEMotionSensor!, didUpdateDistanceFrom oldDistance: CGFloat, to newDistance: CGFloat) {
		let newDistanceDouble = Double(newDistance)
        print("LEMotionSensorDelegate update distance to \(newDistanceDouble)");
        let inform = ["sensor":sensor.serviceName, "id": String(sensor.defaultInputFormat.connectID)]
        upd2webkit(state: newDistanceDouble, properties: inform as [String : Any])
    }
    
    func motionSensor(_ sensor: LEMotionSensor!, didUpdateCountTo count: UInt) {
		let newCountDouble = Double(count)
        print("LEMotionSensorDelegate [ignored] update crash to \(newCountDouble)");
    }
}
