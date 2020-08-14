//
//  PresetView.swift
//  CameraDashboard
//
//  Created by David Beck on 8/12/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct PresetStateOverlay: View {
	var isActive: Bool
	var isSwitching: Bool
	@State private var animatedOff: Bool = false
	
	var body: some View {
		if isSwitching {
			RoundedRectangle(cornerRadius: 15)
				.stroke(Color.blue, lineWidth: 4)
				.opacity(animatedOff ? 0 : 1)
				.onAppear {
					withAnimation(Animation.linear(duration: 0.2)
						.delay(0.2)
						.repeatForever(autoreverses: true)) {
						self.animatedOff = true
					}
				}
		} else if isActive {
			RoundedRectangle(cornerRadius: 15)
				.stroke(Color.blue, lineWidth: 4)
		}
	}
}

struct PresetView: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	var presetConfig: PresetConfig
	var isActive: Bool
	var isSwitching: Bool
	
	@State var isShowingEdit: Bool = false
	
	var body: some View {
		HStack {
			VStack(spacing: 0) {
				VStack(alignment: .leading) {
					HStack {
						Text(presetConfig.name)
							.lineLimit(2)
							.font(.headline)
						Spacer()
					}
					Spacer(minLength: 0)
					HStack(alignment: .bottom) {
						Text("Preset \(presetConfig.preset.rawValue)")
							.font(.subheadline)
						Spacer()
							
						Button(action: {
							self.isShowingEdit = true
						}, label: {
							Image("ellipsis.circle.fill")
						}).buttonStyle(PlainButtonStyle())
							.contentShape(Rectangle())
					}
				}
			}
		}
		.padding(12)
		.foregroundColor(.white)
		.frame(width: 140, height: 100)
		.background(LinearGradient(gradient: Gradient(colors: [
			Color(white: 0, opacity: 0),
			Color(white: 0, opacity: 0.1),
		]), startPoint: .top, endPoint: .bottom))
		.background(Color.gray)
		.cornerRadius(15)
		.overlay(
			PresetStateOverlay(
				isActive: isActive,
				isSwitching: isSwitching
			)
		)
		.sheet(isPresented: $isShowingEdit, content: {
			PresetEditView(
				presetConfig: presetConfig,
				isOpen: $isShowingEdit
			)
			.environmentObject(cameraManager)
		})
	}
}

struct PresetView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			PresetView(
				presetConfig: PresetConfig(cameraID: UUID(), preset: VISCAPreset(rawValue: 1)!),
				isActive: false,
				isSwitching: false
			)
			.padding()
			
			PresetView(
				presetConfig: PresetConfig(cameraID: UUID(), preset: VISCAPreset(rawValue: 2)!),
				isActive: false,
				isSwitching: true
			)
			.padding()
			
			PresetView(
				presetConfig: PresetConfig(cameraID: UUID(), preset: VISCAPreset(rawValue: 3)!),
				isActive: true,
				isSwitching: false
			)
			.padding()
		}
	}
}
