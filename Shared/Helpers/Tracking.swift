import Foundation
#if canImport(Mixpanel)
	import Mixpanel
#endif

enum Tracker {
	static func track(numberOfCameras count: Int) {
		#if canImport(Mixpanel)
			Mixpanel.mainInstance().people.set(properties: ["Number of Cameras": count])
		#endif
	}
	
	static func trackCameraAdd(version: VISCAVersion, port: UInt16) {
		#if canImport(Mixpanel)
			Mixpanel.mainInstance().track(event: "Camera Added", properties: [
				"Vendor": Int(version.venderID),
				"Model": Int(version.modelID),
				"ARM Version": Int(version.armVersion),
				"Reserve": Int(version.reserve),
				
				"Port": Int(port),
			])
		#endif
	}
	
	static func trackCameraAddFailed(_ error: Swift.Error) {
		#if canImport(Mixpanel)
			let nsError = error as NSError
			
			Mixpanel.mainInstance().track(event: "Failed to Add Camera", properties: [
				"Description": nsError.localizedDescription,
				"User Info": nsError.userInfo,
				"Domain": nsError.domain,
				"Code": nsError.code,
			])
		#endif
	}
	
	static func track(error: Swift.Error, operation: String, payload: Data) {
		#if canImport(Mixpanel)
			let nsError = error as NSError
			
			Mixpanel.mainInstance().track(event: "Message Error", properties: [
				"Description": nsError.localizedDescription,
				"User Info": nsError.userInfo,
				"Domain": nsError.domain,
				"Code": nsError.code,
				"Operation": operation,
				"Payload": payload.hexDescription,
			])
		#endif
	}
}
