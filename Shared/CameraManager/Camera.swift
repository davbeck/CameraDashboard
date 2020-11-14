//
//  Camera.swift
//  CameraDashboard
//
//  Created by David Beck on 8/13/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

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
		
		self.id = try container.decode(UUID.self, forKey: .id)
		self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
		self.address = try container.decode(String.self, forKey: .address)
		self.port = try container.decodeIfPresent(UInt16.self, forKey: .port)
	}
}
