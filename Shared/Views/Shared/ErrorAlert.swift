//
//  ErrorAlert.swift
//  CameraDashboard
//
//  Created by David Beck on 8/13/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

extension View {
	func alert(_ error: Binding<Swift.Error?>) -> some View {
		alert(isPresented: Binding(get: {
			error.wrappedValue != nil
		}, set: { newValue in
			if !newValue {
				error.wrappedValue = nil
			}
		}), content: {
			Alert(
				title: Text("Failed to add camera"),
				message: error.wrappedValue.map { Text($0.localizedDescription) },
				dismissButton: Alert.Button.cancel(Text("OK"))
			)
		})
	}
}
