import Foundation

extension SwitcherInput {
	var displayName: String {
		if let number = self.switcher.inputs.firstIndex(of: self) {
			return String(localized: "Input \(number)")
		} else {
			return String(localized: "Input")
		}
	}
}
