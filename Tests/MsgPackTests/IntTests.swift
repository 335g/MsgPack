//
//  IntTests.swift
//  MsgPackTests
//
//  Created by Yoshiki Kudo on 2017/09/20.
//

import XCTest
@testable import MsgPack

class IntTests: XCTestCase {
    
    func testConstructor() {
        /// negative value is `MsgPackObject.int`
        XCTAssert(MsgPackObject.int(-1) == -1)
        XCTAssert(MsgPackObject.int(-100) == -100)
        
        /// positive value (or 0) is `MsgPackObject.uint`
        XCTAssert(MsgPackObject.uint(10) == 10)
        XCTAssert(MsgPackObject.uint(0) == 0)
        XCTAssert(MsgPackObject.int(0) != 0)
    }
    
    /// positive fixint (0x00 - 0x7f)
    ///
    /// positive fixnum stores 7-bit positive integer
    /// +--------+
    /// |0XXXXXXX|
    /// +--------+
    ///
    /// * 0XXXXXXX is 8-bit unsigned integer
    func testEncodePositiveFixInt() {
        do {
            var encoded: Data
            
            encoded = try MsgPackObject.uint(0).encode()
            XCTAssert(encoded == Data([0]))
            
            encoded = try MsgPackObject.uint(10).encode()
            XCTAssert(encoded == Data([10]))
            
            encoded = try MsgPackObject.uint(127).encode()   /// 0x7f
            XCTAssert(encoded == Data([127]))
            
        } catch {
            XCTFail("Fails encode MsgPackObject.uint(`positive fixint`)")
        }
    }
    
    /// uint8
    ///
    /// uint 8 stores a 8-bit unsigned integer
    /// +--------+--------+
    /// |  0xcc  |ZZZZZZZZ|
    /// +--------+--------+
    ///
    ///
    func testEncodeUInt8() {
        do {
            var encoded: Data
            
            encoded = try MsgPackObject.uint(128).encode()
            XCTAssert(encoded == Data([0xcc, 128]))
            
            encoded = try MsgPackObject.uint(255).encode()
            XCTAssert(encoded == Data([0xcc, 255]))
            
        } catch {
            XCTFail("Fails encode MsgPackObject.uint('uint8')")
        }
    }
    
    
}
