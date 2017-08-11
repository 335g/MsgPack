
import Foundation

enum MsgPackFormat {
    enum Nil: UInt8 {
        case `nil` = 0xc0
    }
    
    enum Bool {
        case `true`
        case `false`
    }
    
    struct Binary {
        enum BinaryType {
            case bin8
            case bin16
            case bin32
        }
        
        let data: Data
        let type: BinaryType
        
        init?(data: Data) {
            fatalError()
        }
    }
    
    enum Float {
        case float32(Swift.Float)
        case float64(Double)
    }
    
    struct Array {
        enum ArrayType {
            case fix
            case array16
            case array32
        }
        
        let elements: [MsgPackFormat]
        let type: ArrayType
        
        init?(elements: [MsgPackFormat]) {
            fatalError()
        }
    }
    
    struct String {
        enum StringType {
            case fix
            case str8
            case str16
            case str32
        }
        
        let value: Swift.String
        let type: StringType
        
        init?(string: Swift.String) {
            fatalError()
        }
    }
    
    enum UInt {
        case positiveFix(UInt8)
        case uint8(UInt8)
        case uint16(UInt16)
        case uint32(UInt32)
        case uint64(UInt64)
    }
    
    enum Int {
        case negativeFix(Int8)
        case int8(Int8)
        case int16(Int16)
        case int32(Int32)
        case int64(Int64)
    }
    
    struct Map {
        enum MapType {
            case fix
            case map16
            case map32
        }
        
        let dict: [MsgPackFormat : MsgPackFormat]
        let type: MapType
        
        init?(dict: [MsgPackFormat : MsgPackFormat]) {
            fatalError()
        }
    }
    
    struct Ext {
        enum ExtType {
            case fix1
            case fix2
            case fix4
            case fix8
            case fix16
            case ext8
            case ext16
            case ext32
        }
        
        let type: Int8
        let extType: ExtType
        let data: Data
        
        init?(data: Data) {
            fatalError()
        }
    }
    
    case `nil`(Nil)
    case bool(Bool)
    case binary(Binary)
    case float(Float)
    case array(Array)
    case string(String)
    case uint(UInt)
    case int(Int)
    case map(Map)
    case ext(Ext)
}

// MARK: - Equatable

extension MsgPackFormat.Nil: Equatable {
    static func == (lhs: MsgPackFormat.Nil, rhs: MsgPackFormat.Nil) -> Bool {
        return true
    }
}

extension MsgPackFormat.Bool: Equatable {
    static func == (lhs: MsgPackFormat.Bool, rhs: MsgPackFormat.Bool) -> Bool {
        switch (lhs, rhs) {
        case (.true, .true), (.false, .false):
            return true
        default:
            return false
        }
    }
}

extension MsgPackFormat.Binary: Equatable {
    static func == (lhs: MsgPackFormat.Binary, rhs: MsgPackFormat.Binary) -> Bool {
        return lhs.type == rhs.type && lhs.data == rhs.data
    }
}

extension MsgPackFormat.Float: Equatable {
    static func == (lhs: MsgPackFormat.Float, rhs: MsgPackFormat.Float) -> Bool {
        switch (lhs, rhs) {
        case (.float32(let l), .float32(let r)):
            return l == r
        case (.float64(let l), .float64(let r)):
            return l == r
        default:
            return false
        }
    }
}

extension MsgPackFormat.Array: Equatable {
    static func == (lhs: MsgPackFormat.Array, rhs: MsgPackFormat.Array) -> Bool {
        return lhs.type == rhs.type && lhs.elements == rhs.elements
    }
}

extension Array where Element == MsgPackFormat {
    static func == (lhs: [MsgPackFormat], rhs: [MsgPackFormat]) -> Bool {
        return lhs.count == rhs.count && zip(lhs, rhs).reduce(true){ $0 && $1.0 == $1.1 }
    }
}

extension MsgPackFormat.String: Equatable {
    static func == (lhs: MsgPackFormat.String, rhs: MsgPackFormat.String) -> Bool {
        return lhs.type == rhs.type && lhs.value == rhs.value
    }
}

extension MsgPackFormat.UInt: Equatable {
    static func == (lhs: MsgPackFormat.UInt, rhs: MsgPackFormat.UInt) -> Bool {
        switch (lhs, rhs) {
        case (.positiveFix(let l), .positiveFix(let r)):
            return l == r
        case (.uint8(let l), .uint8(let r)):
            return l == r
        case (.uint16(let l), .uint16(let r)):
            return l == r
        case (.uint32(let l), .uint32(let r)):
            return l == r
        case (.uint64(let l), .uint64(let r)):
            return l == r
        default:
            return false
        }
    }
}

extension MsgPackFormat.Int: Equatable {
    static func == (lhs: MsgPackFormat.Int, rhs: MsgPackFormat.Int) -> Bool {
        switch (lhs, rhs) {
        case (.negativeFix(let l), .negativeFix(let r)):
            return l == r
        case (.int8(let l), .int8(let r)):
            return l == r
        case (.int16(let l), .int16(let r)):
            return l == r
        case (.int32(let l), .int32(let r)):
            return l == r
        case (.int64(let l), .int64(let r)):
            return l == r
        default:
            return false
        }
    }
}

extension MsgPackFormat.Map: Equatable {
    static func == (lhs: MsgPackFormat.Map, rhs: MsgPackFormat.Map) -> Bool {
        return lhs.type == rhs.type && lhs.dict == rhs.dict
    }
}

extension MsgPackFormat.Ext: Equatable {
    static func == (lhs: MsgPackFormat.Ext, rhs: MsgPackFormat.Ext) -> Bool {
        return lhs.extType == rhs.extType && lhs.type == rhs.type && lhs.data == rhs.data
    }
}

extension MsgPackFormat: Equatable {
    static func == (lhs: MsgPackFormat, rhs: MsgPackFormat) -> Swift.Bool {
        switch (lhs, rhs) {
        case (.nil, .nil):                      return true
        case (.bool(let l), .bool(let r)):      return l == r
        case (.binary(let l), .binary(let r)):  return l == r
        case (.float(let l), .float(let r)):    return l == r
        case (.array(let l), .array(let r)):    return l == r
        case (.string(let l), .string(let r)):  return l == r
        case (.uint(let l), .uint(let r)):      return l == r
        case (.int(let l), .int(let r)):        return l == r
        case (.map(let l), .map(let r)):        return l == r
        case (.ext(let l), .ext(let r)):        return l == r
            
        default:
            return false
        }
    }
}

// MARK: - HasPrefix

protocol HasPrefix {
    var prefix: UInt8 { get }
}

extension MsgPackFormat.Nil: HasPrefix {
    var prefix: UInt8 {
        fatalError()
    }
}

extension MsgPackFormat.Bool: HasPrefix {
    var prefix: UInt8 {
        fatalError()
    }
}

extension MsgPackFormat.Binary: HasPrefix {
    var prefix: UInt8 {
        fatalError()
    }
}

extension MsgPackFormat.Float: HasPrefix {
    var prefix: UInt8 {
        fatalError()
    }
}

extension MsgPackFormat.Array: HasPrefix {
    var prefix: UInt8 {
        fatalError()
    }
}

extension MsgPackFormat.String: HasPrefix {
    var prefix: UInt8 {
        fatalError()
    }
}

extension MsgPackFormat.UInt: HasPrefix {
    var prefix: UInt8 {
        fatalError()
    }
}

extension MsgPackFormat.Int: HasPrefix {
    var prefix: UInt8 {
        fatalError()
    }
}

extension MsgPackFormat.Map: HasPrefix {
    var prefix: UInt8 {
        fatalError()
    }
}

extension MsgPackFormat.Ext: HasPrefix {
    var prefix: UInt8 {
        fatalError()
    }
}

extension MsgPackFormat: HasPrefix {
    var prefix: UInt8 {
        switch self {
        case .nil(let x):       return x.prefix
        case .bool(let x):      return x.prefix
        case .binary(let x):    return x.prefix
        case .float(let x):     return x.prefix
        case .array(let x):     return x.prefix
        case .string(let x):    return x.prefix
        case .uint(let x):      return x.prefix
        case .int(let x):       return x.prefix
        case .map(let x):       return x.prefix
        case .ext(let x):       return x.prefix
        }
    }
}

// MARK: - Hashable

protocol _Hashable: Hashable, HasPrefix {}
extension _Hashable {
    var hashValue: Int {
        return Int(truncatingIfNeeded: prefix)
    }
}

extension MsgPackFormat.Nil: _Hashable {}
extension MsgPackFormat.Bool: _Hashable {}
extension MsgPackFormat.Binary: _Hashable {}
extension MsgPackFormat.Float: _Hashable {}
extension MsgPackFormat.Array: _Hashable {}
extension MsgPackFormat.String: _Hashable {}
extension MsgPackFormat.UInt: _Hashable {}
extension MsgPackFormat.Int: _Hashable {}
extension MsgPackFormat.Map: _Hashable {}
extension MsgPackFormat.Ext: _Hashable {}
extension MsgPackFormat: _Hashable {}

// MARK: - Literal

extension MsgPackFormat: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = .nil(nil)
    }
}

extension MsgPackFormat.Nil: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = .nil
    }
}

extension MsgPackFormat.Bool: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Swift.Bool) {
        self = value ? .true : .false
    }
}

extension MsgPackFormat: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Swift.Bool) {
        self = .bool(value ? true : false)
    }
}

extension MsgPackFormat {
//    static func from(string: Swift.String) throws -> MsgPackFormat {
//        guard let data = string.data(using: .utf8) else {
//            throw MsgPackEncoder.Error.notUTF8String
//        }
//
//        let count = data.count
//        if count < 0x20 {
//            return .fixstr(data)
//        } else if count < 0xff {
//            return .str8(data)
//        } else if count < 0xffff {
//            return .str16(data)
//        } else {
//            return .str32(data)
//        }
//    }
    
//    static func from(uint value: Swift.UInt) -> MsgPackFormat {
//        if value < 0b10000000 {
//            return .uint(MsgPackFormat.UInt.positiveFix(UInt8(truncatingIfNeeded: value)))
//        } else if value <= 0xff {
//            return .uint(MsgPackFormat.UInt.uint8(UInt8(truncatingIfNeeded: value)))
//        } else if value <= 0xffff {
//            return .uint(MsgPackFormat.UInt.uint16(UInt16(truncatingIfNeeded: value)))
//        } else if value <= 0xffff_ffff {
//            return .uint(MsgPackFormat.UInt.uint32(UInt32(truncatingIfNeeded: value)))
//        } else {
//            return .uint(MsgPackFormat.UInt.uint64(UInt64(value)))
//        }
//    }
//
//    static func from(int value: Swift.Int) -> MsgPackFormat {
//        if value >= 0 {
//            return .from(uint: Swift.UInt(bitPattern: value))
//        } else if value >= -0b00100000 {
//            return .int(MsgPackFormat.Int.negativeFix(Int8(truncatingIfNeeded: value)))
//        } else if value >= -0xff {
//            return .int(MsgPackFormat.Int.int8(Int8(truncatingIfNeeded: value)))
//        } else if value >= -0xffff {
//            return .int(MsgPackFormat.Int.int16(Int16(truncatingIfNeeded: value)))
//        } else if value >= -0xffff_ffff {
//            return .int(MsgPackFormat.Int.int32(Int32(truncatingIfNeeded: value)))
//        } else {
//            return .int(MsgPackFormat.Int.int64(Int64(value)))
//        }
//    }
//
//    static func from(keyValues elements: (MsgPackFormat, MsgPackFormat)...) throws -> MsgPackFormat {
//        let count = elements.count
//        guard count < 0xffff_ffff else {
//            throw MsgPackEncoder.Error.overflow
//        }
//
//        let dict: [MsgPackFormat : MsgPackFormat] = elements.reduce(into: [:]){ $0[$1.0] = $1.1 }
//        if count <= 16 {
//            return .fixmap(dict)
//        } else if count < 0xffff {
//            return .map16(dict)
//        } else {
//            return .map32(dict)
//        }
//    }
}