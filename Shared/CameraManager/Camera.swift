import Foundation

struct Camera: Codable, Hashable, Identifiable {
	private(set) var id = UUID()
	var name: String = ""
	var address: String
	var port: UInt16
	
	init(id: UUID = UUID(), name: String = "", address: String, port: UInt16 = 5678) {
		self.id = id
		self.name = name
		self.address = address
		self.port = port
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		id = try container.decode(UUID.self, forKey: .id)
		name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
		address = try container.decode(String.self, forKey: .address)
		port = try container.decode(UInt16.self, forKey: .port)
	}
}
