
import XCTest
@testable import MsgPack

class EncoderTest: XCTestCase {
    func testPack(){
        var value: UInt64
        
        value = 0
        XCTAssertEqual(MsgPackEncoder.pack(value, divided: 1), [0])
        
        value = 0b0000001_00000000
        XCTAssertEqual(MsgPackEncoder.pack(value, divided: 2), [1, 0])
        
        value = 0b0000011_00000010_00000001_00000000
        XCTAssertEqual(MsgPackEncoder.pack(value, divided: 4), [3, 2, 1, 0])
    }
    
    static var allTests = [
        ("testPack", testPack)
    ]
}
