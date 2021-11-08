import Foundation
import PersistentCacheKit
import os.log
import SwiftUI
import Combine
import MessagePack

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
	
	private let endcoder = MessagePackEncoder()
	private let decoder = MessagePackDecoder()
	private let legacyDecoder = JSONDecoder()
	
	private let valueWillChange = PassthroughSubject<(rawKey: String, value: Any), Never>()
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
					
					let value: Key.Value
					if let data = data {
						do {
							value = try self.legacyDecoder.decode(Key.Value.self, from: data)
						} catch {
							value = try self.decoder.decode(Key.Value.self, from: data)
						}
					} else {
						value = Key.defaultValue
					}
					
					values[key.rawValue] = value
					return value
				} catch {
					log.error("error retrieving data from SQLite: \(String(describing: error))")
					values[key.rawValue] = Key.defaultValue
					return Key.defaultValue
				}
			}
		}
		set {
			valueWillChange.send((key.rawValue, newValue))
			
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
	
	class ConfigObserver<Key: ConfigKey>: ObservableObject {
		let key: Key
		private weak var manager: ConfigManager?
		private var observer: AnyCancellable?
		
		init(key: Key, manager: ConfigManager) {
			self.key = key
			self.manager = manager
			
			observer = manager.valueWillChange
				.filter { $0.rawKey == key.rawValue }
				.compactMap { $0.value as? Key.Value }
				.sink(receiveValue: { [weak self] _ in
					self?.objectWillChange.send()
				})
		}
		
		var value: Key.Value {
			get {
				manager?[key] ?? Key.defaultValue
			}
			set {
				manager?[key] = newValue
			}
		}
	}

	private var configObservers: [String: AnyObject] = [:]
	public func observer<Key: ConfigKey>(for key: Key) -> ConfigObserver<Key> {
		if let observer = configObservers[key.rawValue] as? ConfigObserver<Key> {
			return observer
		}
		
		let observer = ConfigObserver(key: key, manager: self)
		configObservers[key.rawValue] = observer
		return observer
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
	let key: Key
	let store: ConfigManager
	
	@StateObject var observer: ConfigManager.ConfigObserver<Key>
	
	init(key: Key, store: ConfigManager = .shared) {
		self.key = key
		self.store = store
		
		_observer = StateObject(wrappedValue: store.observer(for: key))
	}
	
	var wrappedValue: Key.Value {
		get {
			observer.value
		}
		nonmutating set {
			observer.value = newValue
		}
	}
	
	var projectedValue: Binding<Key.Value> {
		$observer.value
	}
}
