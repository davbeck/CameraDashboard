//
//  Camera.swift
//  VISCASimulator
//
//  Created by David Beck on 11/15/20.
//

import Foundation

final class Camera: ObservableObject {
    @Published var zoom: UInt16 = 0
}
