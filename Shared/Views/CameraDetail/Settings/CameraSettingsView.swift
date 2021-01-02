import SwiftUI
import Network
import Dispatch

struct CameraConnectionSettingsView: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	@State var camera: Camera
	@State var port: String
	@Binding var isOpen: Bool
	
	@State var isLoading: Bool = false
	@State var error: Swift.Error?
	
	var isValid: Bool {
		!camera.address.isEmpty
	}
	
	init(camera: Camera, isOpen: Binding<Bool>) {
		_camera = State(wrappedValue: camera)
		_port = State(wrappedValue: String(camera.port))
		_isOpen = isOpen
	}
	
	var body: some View {
		_CameraConnectionSettingsView(name: $camera.name, address: $camera.address, port: $port) {
			isLoading = true
			
			DispatchQueue.main.async {
				let port: UInt16?
				if !self.port.isEmpty {
					port = portFormatter.number(from: self.port)?.uint16Value
				} else {
					port = nil
				}
				
				cameraManager.save(camera: camera, port: port) { result in
					isLoading = false
					
					switch result {
					case .success:
						self.isOpen = false
					case let .failure(error):
						self.error = error
					}
				}
			}
		} cancel: {
			self.isOpen = false
		} removeCamera: {
			cameraManager.remove(camera: camera)
		}
		.disabled(isLoading)
		.alert($error)
		.id(camera.id)
	}
}

struct AddCameraConnectionView: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	@State var name: String = ""
	@State var address: String = ""
	@State var port: String = ""
	@Binding var isOpen: Bool
	
	@State var isLoading: Bool = false
	@State var error: Swift.Error?
	
	var isValid: Bool {
		!address.isEmpty
	}
	
	var body: some View {
		_CameraConnectionSettingsView(name: $name, address: $address, port: $port) {
			isLoading = true
			
			DispatchQueue.main.async {
				let port: UInt16?
				if !self.port.isEmpty {
					port = portFormatter.number(from: self.port)?.uint16Value
				} else {
					port = nil
				}
				
				cameraManager.createCamera(name: name, address: address, port: port) { result in
					isLoading = false
					
					switch result {
					case .success:
						self.isOpen = false
					case let .failure(error):
						self.error = error
					}
				}
			}
		} cancel: {
			self.isOpen = false
		}
		.disabled(isLoading)
		.alert($error)
	}
}

struct _CameraConnectionSettingsView: View {
	@Binding var name: String
	@Binding var address: String
	@Binding var port: String
	var save: () -> Void
	var cancel: () -> Void
	var removeCamera: (() -> Void)?
	
	var isValid: Bool {
		!address.isEmpty
	}
	
	var body: some View {
		VStack(spacing: 20) {
			Text("Connect to a PTZ camera that supports VISCA over IP")
			VStack {
				HStack(spacing: 5) {
					Text("Name:")
						.column(0, alignment: .trailing)
					TextField("(Optional)", text: $name)
				}
				HStack(spacing: 16) {
					HStack(spacing: 5) {
						Text("Address:")
							.column(0, alignment: .trailing)
						TextField("0.0.0.0", text: $address)
					}
					
					HStack(spacing: 5) {
						Text("Port:")
						TextField("auto", text: $port)
							.frame(width: 80)
					}
				}
			}
			
			HStack(spacing: 16) {
				if let removeCamera = removeCamera {
					RemoveCameraButton(removeCamera: removeCamera)
				}
				
				Spacer(minLength: 100)
				
				Button(action: {
					self.cancel()
				}, label: {
					Text("Cancel")
						.padding(.horizontal, 10)
						.column("Buttons", alignment: .center)
				})
					.keyboardShortcut(.cancelAction)
				
				Button(action: {
					self.save()
				}, label: {
					Text("Save")
						.padding(.horizontal, 10)
						.column("Buttons", alignment: .center)
				})
					.keyboardShortcut(.defaultAction)
			}
			.columnGuide()
		}
		.columnGuide()
		.padding()
	}
}

struct AddCameraView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			AddCameraConnectionView(isOpen: .constant(true))
			CameraConnectionSettingsView(camera: Camera(name: "Stage right", address: "192.168.0.102", port: 1234), isOpen: .constant(true))
		}
	}
}
