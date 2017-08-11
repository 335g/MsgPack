
import XCTest
@testable import MsgPack

class BoolTests: XCTestCase {
    func testEncode() {
        let trueObject: MsgPackObject = true
        XCTAssertEqual(try trueObject.encode(), Data([0xc3]))
        
        let falseObject: MsgPackObject = false
        XCTAssertEqual(try falseObject.encode(), Data([0xc2]))
    }
    
    func testDecode() {
        var trueData = Data([0xc3]).msgpack
        XCTAssertEqual(try trueData.object(), true)
        XCTAssertEqual(trueData.base, Data([]))
        
        var falseData = Data([0xc2]).msgpack
        XCTAssertEqual(try falseData.object(), false)
        XCTAssertEqual(falseData.base, Data([]))
    }
    
    static var allTests = [
        ("testEncode", testEncode),
        ("testDecode", testDecode)
    ]
}
