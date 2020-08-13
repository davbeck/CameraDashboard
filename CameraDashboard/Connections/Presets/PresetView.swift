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
	var preset: VISCAPreset
	var isActive: Bool
	var isSwitching: Bool
	
	var body: some View {
		HStack {
			VStack(spacing: 0) {
				Spacer(minLength: 0)
				VStack(alignment: .leading) {
					Text("Scripture lorem ipsum")
						.lineLimit(2)
						.font(.headline)
					Text("Preset \(preset.rawValue)")
						.font(.subheadline)
				}
			}
			Spacer()
		}
		.padding()
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
	}
}

struct PresetView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			PresetView(
				preset: VISCAPreset(rawValue: 1)!,
				isActive: false,
				isSwitching: false
			)
			.padding()
			
			PresetView(
				preset: VISCAPreset(rawValue: 2)!,
				isActive: false,
				isSwitching: true
			)
			.padding()
			
			PresetView(
				preset: VISCAPreset(rawValue: 3)!,
				isActive: true,
				isSwitching: false
			)
			.padding()
		}
	}
}
