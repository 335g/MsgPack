
import Foundation

protocol HaveByte {
    var byte: UInt8 { get }
}

protocol Have: HaveByte {
    associatedtype Target
    
    var target: Target { get }
}

struct Integer: Have {
    enum IntegerType {
        case a
        case b
        case c
    }
    
    let type: IntegerType
    var value: Int
    
    typealias Target = Int
    var byte: UInt8 {
        switch type {
        case .a:
            return 0xc0
        case .b:
            return 0xc1
        case .c:
            return 0xc2
        }
    }
    
    var target: Int {
        return value
    }
    
    
}

struct HaveObject<H: Have> {
    var type: H
}



var a = HaveObject<Integer>(type: Integer(type: .a, value: 10))
