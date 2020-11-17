import Foundation

let portFormatter: NumberFormatter = {
	let formatter = NumberFormatter()
	formatter.maximumFractionDigits = 0
	formatter.usesGroupingSeparator = false
	return formatter
}()
