import SwiftUI

extension Slider {
	init<V>(
		value: Binding<V>,
		in bounds: ClosedRange<V>,
		onEditingChanged: @escaping (Bool) -> Void = { _ in }
	) where V: FixedWidthInteger, ValueLabel == EmptyView, Label == EmptyView {
		self.init(
			value: Binding(get: {
				Double(value.wrappedValue)
			}, set: {
				value.wrappedValue = V($0)
			}),
			in: Double(bounds.lowerBound) ... Double(bounds.upperBound),
			onEditingChanged: onEditingChanged
		)
	}
}
