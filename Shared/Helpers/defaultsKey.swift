import Foundation

func defaultsKey(_ key: String, default defaultValue: Any) -> String {
	UserDefaults.standard.register(defaults: [key: defaultValue])
	return key
}
