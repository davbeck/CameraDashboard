//
//  PresetEditView.swift
//  CameraDashboard
//
//  Created by David Beck on 8/13/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct PresetEditView: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	@State var presetConfig: PresetConfig
	
	@Binding var isOpen: Bool
	
	@State var isLoading: Bool = false
	@State var error: Swift.Error?
	
	var body: some View {
		_PresetEditView(presetConfig: $presetConfig) {
			cameraManager.save(presetConfig)
			self.isOpen = false
		} cancel: {
			self.isOpen = false
		}
		.disabled(isLoading)
		.alert($error)
	}
}

struct _PresetEditView: View {
	@Binding var presetConfig: PresetConfig
	
	var save: () -> Void
	var cancel: () -> Void
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text("Name:")
					.column("label", alignment: .trailing)
				TextField("(Optional)", text: $presetConfig.name)
			}
			HStack {
				Text("Color:")
					.column("label", alignment: .trailing)
				
				ForEach(PresetColor.allCases, id: \.self) { presetColor in
					PresetColorControl(presetColor: presetColor)
				}
			}
			
			HStack(spacing: 16) {
				Spacer()
				
				Button(action: {
					self.cancel()
				}, label: {
					Text("Cancel")
						.padding(.horizontal, 10)
						.column("Buttons", alignment: .center)
				})
				// .keyboardShortcut(.cancelAction)
				
				Button(action: {
					self.save()
				}, label: {
					Text("Save")
						.padding(.horizontal, 10)
						.column("Buttons", alignment: .center)
				})
				// .keyboardShortcut(.defaultAction)
			}
		}
		.columnGuide()
		.padding()
	}
}

struct PresetEditView_Previews: PreviewProvider {
	struct PresetEditView: View {
		@State var presetConfig: PresetConfig
		
		var body: some View {
			_PresetEditView(presetConfig: $presetConfig, save: {}, cancel: {})
		}
	}
	
	static var previews: some View {
		PresetEditView(presetConfig: PresetConfig(cameraID: UUID(), preset: VISCAPreset.allCases[2]))
	}
}
