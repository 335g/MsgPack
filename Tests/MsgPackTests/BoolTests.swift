//
//  BoolTests.swift
//  MsgPackTests
//
//  Created by Yoshiki Kudo on 2017/09/20.
//

import XCTest
@testable import MsgPack

class BoolTests: XCTestCase {
    let trueObj = MsgPackObject.bool(true)
    let falseObj = MsgPackObject.bool(false)
    let trueData = Data([0xc3])
    let falseData = Data([0xc2])
    
    func testEncodeTrue() {
        do {
            let encoded = try trueObj.encode()
            XCTAssert(encoded == trueData)
        } catch {
            XCTFail("Fails encode MsgPackObject.bool(true)")
        }
    }
    
    func testEncodeFalse() {
        do {
            let encoded = try falseObj.encode()
            XCTAssert(encoded == falseData)
        } catch {
            XCTFail("Fails encode MsgPackObject.bool(false)")
        }
    }
    
    func testDecodeTrue() {
        do {
            let decoded = try MsgPackObject(data: trueData)
            XCTAssert(decoded == trueObj)
        } catch {
            XCTFail("Fails decode data to MsgPackObject.bool(true)")
        }
    }
    
    func testDecodeFalse() {
        do {
            let decoded = try MsgPackObject(data: falseData)
            XCTAssert(decoded == falseObj)
        } catch {
            XCTFail("Fails decode data to MsgPackObject.bool(false)")
        }
    }
    
    func testConstructorTrue() {
        XCTAssert(trueObj == true)
    }
    
    func testConstructorFalse() {
        XCTAssert(falseObj == false)
    }
    
    static var allTests = [
        ("testEncodeTrue", testEncodeTrue),
        ("testEncodeFalse", testEncodeFalse),
        ("testDecodeTrue", testDecodeTrue),
        ("testDecodeFalse", testDecodeFalse),
        ("testConstructorTrue", testConstructorTrue),
        ("testConstructorFalse", testConstructorFalse),
    ]
}
