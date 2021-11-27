import SwiftUI
import Network
import Dispatch
import CoreData

struct CameraConnectionSettingsView: View {
	@Environment(\.managedObjectContext) var context
	@EnvironmentObject var cameraManager: CameraManager
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var camera: Camera
	// using separate state in order to manually parse
	@State var port: String
	
	@State private var isLoading: Bool = false
	@State private var error: Swift.Error?
	
	var isValid: Bool {
		!camera.address.isEmpty
	}
	
	init(camera: Camera) {
		self.camera = camera
		_port = State(wrappedValue: camera.port.map { String($0) } ?? "")
	}
	
	var body: some View {
		_CameraConnectionSettingsView(
			title: "Camera Settings",
			name: $camera.name,
			address: $camera.address,
			port: $port
		) {
			isLoading = true
			
			do {
				if !self.port.isEmpty {
					camera.port = portFormatter.number(from: self.port)?.uint16Value
				} else {
					camera.port = nil
				}
				
				try context.save()
				try context.parent?.saveOrRollback()
				
				presentationMode.wrappedValue.dismiss()
			} catch {
				self.error = error
			}
		} cancel: {
			presentationMode.wrappedValue.dismiss()
		} removeCamera: {
			do {
				context.delete(camera)
				try context.save()
				try context.parent?.saveOrRollback()
			} catch {
				self.error = error
			}
		}
		.disabled(isLoading)
		.alert($error)
		.id(camera.id)
	}
}

struct AddCameraConnectionView: View {
	@Environment(\.managedObjectContext) var context
	@EnvironmentObject var cameraManager: CameraManager
	@Environment(\.presentationMode) var presentationMode
	
	@State var name: String = ""
	@State var address: String = ""
	@State var port: String = ""
	
	@State var isLoading: Bool = false
	@State var error: Swift.Error?
	
	var isValid: Bool {
		!address.isEmpty
	}
	
	var body: some View {
		_CameraConnectionSettingsView(
			title: "Add Camera",
			name: $name,
			address: $address,
			port: $port
		) {
			DispatchQueue.main.async {
				do {
					let port: UInt16?
					if !self.port.isEmpty {
						port = portFormatter.number(from: self.port)?.uint16Value
					} else {
						port = nil
					}
					_ = Camera.create(
						in: context,
						name: name,
						address: address,
						port: port
					)
					
					try context.saveOrRollback()
					
					presentationMode.wrappedValue.dismiss()
				} catch {
					self.error = error
				}
			}
		} cancel: {
			presentationMode.wrappedValue.dismiss()
		}
		.disabled(isLoading)
		.alert($error)
	}
}

struct _CameraConnectionSettingsView: View {
	var title: LocalizedStringKey
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
		#if os(macOS)
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
								.disableAutocorrection(true)
						}
						
						HStack(spacing: 5) {
							Text("Port:")
							TextField("auto", text: $port)
								.disableAutocorrection(true)
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
		#else
			NavigationView {
				Form {
					HStack {
						Text("Name:")
						TextField("(Optional)", text: $name)
							.autocapitalization(.words)
					}
					
					HStack(spacing: 5) {
						Text("Address:")
						TextField("0.0.0.0", text: $address)
							.autocapitalization(.none)
							.keyboardType(.URL)
							.disableAutocorrection(true)
					}
					
					HStack(spacing: 5) {
						Text("Port:")
						TextField("auto", text: $port)
							.autocapitalization(.none)
							.keyboardType(.numberPad)
							.disableAutocorrection(true)
					}
				}
				.navigationTitle(title)
				.navigationBarItems(
					leading: Button(action: {
						self.cancel()
					}, label: {
						Text("Cancel")
					}),
					trailing: Button(action: {
						self.save()
					}, label: {
						Text("Save")
					})
				)
			}
		#endif
	}
}

// struct AddCameraView_Previews: PreviewProvider {
//	static var previews: some View {
//		Group {
//			AddCameraConnectionView(isOpen: .constant(true))
//			CameraConnectionSettingsView(camera: Camera(name: "Stage right", address: "192.168.0.102", port: 1234), isOpen: .constant(true))
//		}
//	}
// }
