import Foundation
import Mixpanel

enum Tracker {
	static func track(numberOfCameras count: Int) {
		Mixpanel.mainInstance().people.set(properties: ["Number of Cameras": count])
	}
	
	static func trackCameraAdd(version: VISCAVersion, port: UInt16) {
		Mixpanel.mainInstance().track(event: "Camera Added", properties: [
			"Vendor": Int(version.venderID),
			"Model": Int(version.modelID),
			"ARM Version": Int(version.armVersion),
			"Reserve": Int(version.reserve),
			
			"Port": Int(port),
		])
	}
	
	static func trackCameraAddFailed(_ error: Swift.Error) {
		let nsError = error as NSError
		
		Mixpanel.mainInstance().track(event: "Failed to Add Camera", properties: [
			"Description": nsError.localizedDescription,
			"User Info": nsError.userInfo,
			"Domain": nsError.domain,
			"Code": nsError.code,
		])
	}
}
