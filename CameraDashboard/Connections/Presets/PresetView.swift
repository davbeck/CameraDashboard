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
	
	var preset: VISCAPreset
	@Binding var presetConfig: PresetConfig
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
						Text("Preset \(preset.rawValue)")
							.font(.subheadline)
						Spacer()
							
						Button(action: {
							self.isShowingEdit = true
						}, label: {
							Image("ellipsis.circle.fill")
						})
							.buttonStyle(PlainButtonStyle())
							.contentShape(Rectangle())
							.popover(
								isPresented: $isShowingEdit,
								arrowEdge: .bottom
							) {
								PresetEditView(
									presetConfig: $presetConfig,
									isOpen: $isShowingEdit
								)
								.environmentObject(cameraManager)
							}
					}
				}
			}
		}
		.padding(12)
		.foregroundColor(.white)
		.frame(width: 140, height: 100)
		.background(LinearGradient(gradient: Gradient(colors: [
			Color(white: 1, opacity: 0.1),
			Color(white: 1, opacity: 0),
		]), startPoint: .top, endPoint: .bottom))
		.background(Color(presetConfig.color))
		.cornerRadius(15)
		.overlay(
			PresetStateOverlay(
				isActive: isActive,
				isSwitching: isSwitching
			)
		)
	}
}

struct PresetView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			PresetView(
				preset: VISCAPreset.allCases[1],
				presetConfig: .constant(PresetConfig()),
				isActive: false,
				isSwitching: false
			)
			.padding()
			
			PresetView(
				preset: VISCAPreset.allCases[2],
				presetConfig: .constant(PresetConfig()),
				isActive: false,
				isSwitching: true
			)
			.padding()
			
			PresetView(
				preset: VISCAPreset.allCases[3],
				presetConfig: .constant(PresetConfig()),
				isActive: true,
				isSwitching: false
			)
			.padding()
		}
	}
}
