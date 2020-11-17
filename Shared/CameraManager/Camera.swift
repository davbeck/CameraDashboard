import Foundation

struct Camera: Codable, Hashable, Identifiable {
	private(set) var id = UUID()
	var name: String = ""
	var address: String
	var port: UInt16?
	
	init(name: String = "", address: String, port: UInt16? = nil) {
		self.name = name
		self.address = address
		self.port = port
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		id = try container.decode(UUID.self, forKey: .id)
		name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
		address = try container.decode(String.self, forKey: .address)
		port = try container.decodeIfPresent(UInt16.self, forKey: .port)
	}
}
