//
//  Column.swift
//  Canera Switcher
//
//  Created by David Beck on 8/6/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct ColumnWidthPreference: Equatable {
	let identifier: AnyHashable
	let width: CGFloat
}

struct ColumnWidthPreferenceKey: PreferenceKey {
	typealias Value = [ColumnWidthPreference]
	
	static var defaultValue: [ColumnWidthPreference] = []
	
	static func reduce(value: inout [ColumnWidthPreference], nextValue: () -> [ColumnWidthPreference]) {
		value.append(contentsOf: nextValue())
	}
}

struct ColumnCell<Content: View, ColumnIdentifier: Hashable>: View {
	var identifier: ColumnIdentifier
	var alignment: Alignment
	var content: Content
	@State var width: CGFloat?
	@Environment(\.maxColumnWidths) var maxWidths: [AnyHashable: CGFloat]
	
	var body: some View {
		ZStack(alignment: alignment) {
			Spacer().frame(width: maxWidths[identifier])
			
			content
				.background(GeometryReader { geometry in
					Rectangle()
						.fill(Color.clear)
						.preference(
							key: ColumnWidthPreferenceKey.self,
							value: [ColumnWidthPreference(identifier: self.identifier, width: geometry.frame(in: CoordinateSpace.global).width)]
						)
				})
		}
		.onPreferenceChange(ColumnWidthPreferenceKey.self) { preferences in
			self.width = preferences
				.filter { $0.identifier == self.identifier as AnyHashable }
				.map { $0.width }.reduce(0, +)
		}
	}
}

struct MaxColumnWidthKey: EnvironmentKey {
	static let defaultValue: [AnyHashable: CGFloat] = [:]
}

extension EnvironmentValues {
	var maxColumnWidths: [AnyHashable: CGFloat] {
		get {
			return self[MaxColumnWidthKey.self]
		}
		set {
			self[MaxColumnWidthKey.self] = newValue
		}
	}
}

struct ColumnContainer<Content: View>: View {
	var content: Content
	@State var maxWidths: [AnyHashable: CGFloat] = [:]
	
	var body: some View {
		content
			.onPreferenceChange(ColumnWidthPreferenceKey.self) { preferences in
				for identifier in Set(preferences.map { $0.identifier }) {
					self.maxWidths[identifier] = preferences
						.filter { $0.identifier == identifier }
						.map { $0.width }.max()
				}
			}
			.environment(\.maxColumnWidths, maxWidths)
	}
}

extension View {
	func columnGuide() -> some View {
		ColumnContainer(content: self)
	}
	
	func column<ColumnIdentifier: Hashable>(_ identifier: ColumnIdentifier, alignment: Alignment = .leading) -> some View {
		ColumnCell(identifier: identifier, alignment: alignment, content: self)
	}
}
