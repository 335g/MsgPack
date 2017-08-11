
import XCTest
@testable import MsgPack

class StringTests: XCTestCase {
    func testEncode(){
        
        /// `fixstr` stores a byte array whose length is upto 31 bytes
        /// +--------+========+
        /// |101XXXXX|  data  |
        /// +--------+========+
        let empty: MsgPackObject = ""
        XCTAssertEqual(try empty.encode(), Data([0b10100000]))
        
        
        
    }
    
    func testDecode() {
        
    }
    
    static var allTests = [
        ("testEncode", testEncode),
        ("testDecode", testDecode)
    ]
}
