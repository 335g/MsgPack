//
//  NilTests.swift
//  MsgPackTests
//
//  Created by Yoshiki Kudo on 2017/09/20.
//

import XCTest
@testable import MsgPack

class NilTests: XCTestCase {
    let obj = MsgPackObject.nil
    let data = Data([0xc0])
    
    func testNilEncode() {
        do {
            let encoded = try obj.encode()
            XCTAssert(encoded == data)
        } catch {
            XCTFail("Fails encode MsgPackObject.nil")
        }
    }
    
    func testNilDecode() {
        do {
            let decoded = try MsgPackObject(data: data)
            XCTAssert(decoded == obj)
        } catch {
            XCTFail("Fails decode data to MsgPackObject.nil")
        }
    }
    
    func testConstructor() {
        XCTAssert(obj == nil)
    }
    
    static var allTests = [
        ("testNilEncode", testNilEncode),
        ("testNilDecode", testNilDecode),
        ("testConstructor", testConstructor),
    ]
}
