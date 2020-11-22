import XCTest
@testable import CameraDashboard

class DataLoadingTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testLoadBitPadded() {
		let packet = Data([0x90, 0x50, 0x04, 0x00, 0x00, 0x00, 0xFF])
		let number = packet.dropFirst(2).loadBitPadded(as: UInt16.self)
		
		XCTAssertEqual(number, 16384)
	}
	
	func testBitPadded() {
		let packet = UInt16(16384).bitPadded
		
		XCTAssertEqual(packet, Data([0x04, 0x00, 0x00, 0x00]))
	}
}
