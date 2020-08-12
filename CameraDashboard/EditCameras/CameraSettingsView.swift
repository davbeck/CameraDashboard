//
//  CameraSettingsView.swift
//  CameraDashboard
//
//  Created by David Beck on 8/11/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI
import Network

struct CameraSettingsView: View {
	var isLoading: Bool
	
	var save: (Camera) -> Void
	var cancel: () -> Void
	
	@State var name: String = ""
	@State var address: String = ""
	@State var port: UInt16? = nil
	
	var isValid: Bool {
		!self.address.isEmpty
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
						TextField("\(NWEndpoint.Port.visca.rawValue)", value: $port, formatter: portFormatter)
							.frame(width: 80)
					}
				}
			}
			
			HStack(spacing: 16) {
				Spacer()
				
				Button(action: self.cancel, label: {
					Text("Cancel")
						.padding(.horizontal, 10)
						.column("Buttons", alignment: .center)
				})
				// .keyboardShortcut(.cancelAction)
				
				Button(action: {
					self.save(Camera(
						name: name,
						address: address,
						port: port
					))
				}, label: {
					Text("Save")
						.padding(.horizontal, 10)
						.column("Buttons", alignment: .center)
				})
					.disabled(!isValid)
				// .keyboardShortcut(.defaultAction)
			}
		}
		.disabled(isLoading)
		.columnGuide()
		.padding()
	}
}

struct AddCameraView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			CameraSettingsView(isLoading: false, save: { _ in }, cancel: {})
			CameraSettingsView(isLoading: true, save: { _ in }, cancel: {})
		}
	}
}
