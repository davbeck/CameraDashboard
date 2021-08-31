import Foundation
import PersistentCacheKit
import os.log
import SwiftUI
import Combine

private let log = Logger(category: "ConfigManager")

protocol ConfigKey {
	associatedtype Value: Codable
	
	static var defaultValue: Value { get }
	var rawValue: String { get }
}

final class ConfigManager {
	static let shared: ConfigManager = {
		let url = try? FileManager.default
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			.appendingPathComponent(Bundle(for: CameraManager.self).bundleIdentifier ?? "CameraDashboard")
			.appendingPathComponent("Config.sqlite", isDirectory: false)
		
		return ConfigManager(configURL: url)
	}()
	
	private let queue = DispatchQueue(label: "ConfigManager")
	
	private var values: [String: Any] = [:]
	private let db: SQLiteDB?
	
	private let endcoder = JSONEncoder()
	private let decoder = JSONDecoder()
	
	private let valueChanged = PassthroughSubject<(rawKey: String, value: Any), Never>()
	
	init(configURL: URL? = nil) {
		if let configURL = configURL {
			do {
				log.info("creating config db at \(configURL.path)")
				
				let db = try SQLiteDB(url: configURL)
				let statement = try db.preparedStatement(forSQL: """
				CREATE TABLE IF NOT EXISTS config (
					key TEXT PRIMARY KEY NOT NULL,
					data BLOB,
					updatedAt INTEGER
				)
				""", shouldCache: false)
				try statement.step()
				
				self.db = db
			} catch {
				log.error("failed to connect to config db (\(configURL)) \(String(describing: error))")
				self.db = nil
			}
		} else {
			self.db = nil
		}
	}
	
	public func valueChanged<Key: ConfigKey>(for key: Key) -> AnyPublisher<Key.Value, Never> {
		self.valueChanged
			.filter { $0.rawKey == key.rawValue }
			.compactMap { $0.value as? Key.Value }
			.eraseToAnyPublisher()
	}
	
	public subscript<Key: ConfigKey>(key: Key) -> Key.Value {
		get {
			if let value = values[key.rawValue] as? Key.Value {
				return value
			}
			
			guard let db = db else { return Key.defaultValue }
			return self.queue.sync {
				var data: Data?
				
				do {
					let sql = "SELECT data FROM config WHERE key = ?"
					let statement = try db.preparedStatement(forSQL: sql)
					
					try statement.bind(key.rawValue, at: 1)
					
					if try statement.step() {
						data = statement.getData(atColumn: 0)
					}
					
					try statement.reset()
					
					let value = try data.map { try self.decoder.decode(Key.Value.self, from: $0) } ?? Key.defaultValue
					values[key.rawValue] = value
					return value
				} catch {
					log.error("error retrieving data from SQLite: \(String(describing: error))")
					return Key.defaultValue
				}
			}
		}
		set {
			self.values[key.rawValue] = newValue
			
			self.queue.async {
				do {
					guard let db = self.db else { return }
					
					let data = try self.endcoder.encode(newValue)
					
					let sql = "INSERT OR REPLACE INTO config (key, data, updatedAt) VALUES (?, ?, ?)"
					
					let statement = try db.preparedStatement(forSQL: sql)
					
					try statement.bind(key.rawValue, at: 1)
					try statement.bind(data, at: 2)
					try statement.bind(Date(), at: 3)
					
					try statement.step()
					try statement.reset()
				} catch {
					log.error("error saving data to SQLite: \(String(describing: error))")
				}
			}
			
			self.valueChanged.send((key.rawValue, newValue))
		}
	}
}

private struct ConfigManagerKey: EnvironmentKey {
	static let defaultValue = ConfigManager()
}

extension EnvironmentValues {
	var configManager: ConfigManager {
		get { self[ConfigManagerKey.self] }
		set { self[ConfigManagerKey.self] = newValue }
	}
}

@propertyWrapper
struct Config<Key: ConfigKey>: DynamicProperty where Key.Value: Equatable {
	private final class Coordinator: ObservableObject {
		var observer: AnyCancellable?
	}
	
	@Environment(\.configManager) var configManager
	
	@StateObject private var coordinator = Coordinator()
	
	func update() {
		guard coordinator.observer == nil else { return }
		coordinator.observer = configManager.valueChanged(for: key)
			.removeDuplicates()
			.print(key.rawValue)
			.sink { value in
				coordinator.objectWillChange.send()
			}
	}
	
	let key: Key
	
	var wrappedValue: Key.Value {
		get {
			configManager[key]
		}
		nonmutating set {
			configManager[key] = newValue
		}
	}
	
	var projectedValue: Binding<Key.Value> {
		Binding(
			get: { wrappedValue },
			set: { wrappedValue = $0 }
		)
	}
}
