
import XCTest
@testable import MsgPack

class NilTests: XCTestCase {
    func testEncode(){
        let nilObject: MsgPackObject = nil
        XCTAssertEqual(try nilObject.encode(), Data([0xc0]))
    }
    
    func testDecode() {
        var nilData = Data([0xc0]).msgpack
        XCTAssertEqual(try nilData.object(), nil)
        XCTAssertEqual(nilData.base, Data([]))
    }
    
    static var allTests = [
        ("testEncode", testEncode),
        ("testDecode", testDecode)
    ]
}
