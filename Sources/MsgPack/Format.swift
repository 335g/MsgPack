
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
        
        enum EncodeError: Error {
            case overflow
        }
        
        let data: Data
        let type: BinaryType
        
        init(data: Data) throws {
            let count = data.count
            guard count < 0xffff_ffff else {
                throw EncodeError.overflow
            }
            
            self.data = data
            if count < 0xff {
                self.type = .bin8
            } else if count < 0xffff {
                self.type = .bin16
            } else {
                self.type = .bin32
            }
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
        
        enum EncodeError: Error {
            case overflow
        }
        
        let elements: [MsgPackFormat]
        let type: ArrayType
        
        init(elements: [MsgPackFormat]) throws {
            let count = elements.count
            guard count < 0xffff_ffff else {
                throw EncodeError.overflow
            }
            
            self.elements = elements
            if count < 16 {
                self.type = .fix
            } else if count < 0xffff {
                self.type = .array16
            } else {
                self.type = .array32
            }
        }
    }
    
    struct String {
        enum StringType {
            case fix
            case str8
            case str16
            case str32
        }
        
        enum EncodeError: Error {
            case overflow
        }
        
        let value: Swift.String
        let type: StringType
        
        init(string: Swift.String) throws {
            let count = string.utf8.count
            guard count < 0xffff_ffff else {
                throw EncodeError.overflow
            }
            
            self.value = string
            if count < 32 {
                self.type = .fix
            } else if count < 0xff {
                self.type = .str8
            } else if count < 0xffff {
                self.type = .str16
            } else {
                self.type = .str32
            }
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
        
        enum EncodeError: Error {
            case overflow
        }
        
        let dict: [MsgPackFormat : MsgPackFormat]
        let type: MapType
        
        init(dict: [MsgPackFormat : MsgPackFormat]) throws {
            let count = dict.count
            guard count < 0xffff_ffff else {
                throw EncodeError.overflow
            }
            
            self.dict = dict
            if count < 16 {
                self.type = .fix
            } else if count < 0xffff {
                self.type = .map16
            } else {
                self.type = .map32
            }
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
        
        enum EncodeError: Error {
            case overflow
        }
        
        let type: Int8
        let extType: ExtType
        let data: Data
        
        init(type: Int8, data: Data) throws {
            let byte = data.count
            guard byte < 0xffff_ffff else {
                throw EncodeError.overflow
            }
            
            self.type = type
            self.data = data
            if byte == 1 {
                self.extType = .fix1
            } else if byte == 2 {
                self.extType = .fix2
            } else if byte == 4 {
                self.extType = .fix4
            } else if byte == 8 {
                self.extType = .fix8
            } else if byte < 0xff {
                self.extType = .ext8
            } else if byte < 0xffff {
                self.extType = .ext16
            } else {
                self.extType = .ext32
            }
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
        /// nil:
        /// +--------+
        /// |  0xc0  |
        /// +--------+
        return 0xc0
    }
}

extension MsgPackFormat.Bool: HasPrefix {
    var prefix: UInt8 {
        switch self {
        case .true:
            ///
            /// true:
            /// +--------+
            /// |  0xc3  |
            /// +--------+
            return 0xc3
            
        case .false:
            ///
            /// false:
            /// +--------+
            /// |  0xc2  |
            /// +--------+
            return 0xc2
        }
    }
}

extension MsgPackFormat.Binary: HasPrefix {
    var prefix: UInt8 {
        switch self.type {
        case .bin8:
            ///
            /// bin 8 stores a byte array whose length is upto (2^8)-1 bytes:
            /// +--------+--------+========+
            /// |  0xc4  |XXXXXXXX|  data  |
            /// +--------+--------+========+
            return 0xc4
            
        case .bin16:
            ///
            /// bin 16 stores a byte array whose length is upto (2^16)-1 bytes:
            /// +--------+--------+--------+========+
            /// |  0xc5  |YYYYYYYY|YYYYYYYY|  data  |
            /// +--------+--------+--------+========+
            return 0xc5
            
        case .bin32:
            ///
            /// bin 32 stores a byte array whose length is upto (2^32)-1 bytes:
            /// +--------+--------+--------+--------+--------+========+
            /// |  0xc6  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|  data  |
            /// +--------+--------+--------+--------+--------+========+
            return 0xc6
        }
    }
}

extension MsgPackFormat.Float: HasPrefix {
    var prefix: UInt8 {
        switch self {
        case .float32:
            ///
            /// float 32 stores a floating point number in IEEE 754 single precision floating point number format:
            /// +--------+--------+--------+--------+--------+
            /// |  0xca  |XXXXXXXX|XXXXXXXX|XXXXXXXX|XXXXXXXX|
            /// +--------+--------+--------+--------+--------+
            return 0xca
            
        case .float64:
            ///
            /// float 64 stores a floating point number in IEEE 754 double precision floating point number format:
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
            /// |  0xcb  |YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
            return 0xcb
        }
    }
}

extension MsgPackFormat.Array: HasPrefix {
    var prefix: UInt8 {
        switch self.type {
        case .fix:
            ///
            /// fixarray stores an array whose length is upto 15 elements:
            /// +--------+~~~~~~~~~~~~~~~~~+
            /// |1001XXXX|    N objects    |
            /// +--------+~~~~~~~~~~~~~~~~~+
            return 0b10010000 | UInt8(truncatingIfNeeded: self.elements.count)
            
        case .array16:
            ///
            /// array 16 stores an array whose length is upto (2^16)-1 elements:
            /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
            /// |  0xdc  |YYYYYYYY|YYYYYYYY|    N objects    |
            /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
            return 0xdc
            
        case .array32:
            ///
            /// array 32 stores an array whose length is upto (2^32)-1 elements:
            /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
            /// |  0xdd  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|    N objects    |
            /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
            return 0xdd
        }
    }
}

extension MsgPackFormat.String: HasPrefix {
    var prefix: UInt8 {
        switch self.type {
        case .fix:
            ///
            /// fixstr stores a byte array whose length is upto 31 bytes:
            /// +--------+========+
            /// |101XXXXX|  data  |
            /// +--------+========+
            return 0b10100000 | UInt8(self.value.utf8.count)
            
        case .str8:
            ///
            /// str 8 stores a byte array whose length is upto (2^8)-1 bytes:
            /// +--------+--------+========+
            /// |  0xd9  |YYYYYYYY|  data  |
            /// +--------+--------+========+
            return 0xd9
            
        case .str16:
            ///
            /// str 16 stores a byte array whose length is upto (2^16)-1 bytes:
            /// +--------+--------+--------+========+
            /// |  0xda  |ZZZZZZZZ|ZZZZZZZZ|  data  |
            /// +--------+--------+--------+========+
            return 0xda
            
        case .str32:
            ///
            /// str 32 stores a byte array whose length is upto (2^32)-1 bytes:
            /// +--------+--------+--------+--------+--------+========+
            /// |  0xdb  |AAAAAAAA|AAAAAAAA|AAAAAAAA|AAAAAAAA|  data  |
            /// +--------+--------+--------+--------+--------+========+
            return 0xdb
        }
    }
}

extension MsgPackFormat.UInt: HasPrefix {
    var prefix: UInt8 {
        switch self {
        case .positiveFix(let x):
            ///
            /// positive fixnum stores 7-bit positive integer
            /// +--------+
            /// |0XXXXXXX|
            /// +--------+
            return x
            
        case .uint8:
            ///
            /// uint 8 stores a 8-bit unsigned integer
            /// +--------+--------+
            /// |  0xcc  |ZZZZZZZZ|
            /// +--------+--------+
            return 0xcc
            
        case .uint16:
            ///
            /// uint 16 stores a 16-bit big-endian unsigned integer
            /// +--------+--------+--------+
            /// |  0xcd  |ZZZZZZZZ|ZZZZZZZZ|
            /// +--------+--------+--------+
            return 0xcd
            
        case .uint32:
            ///
            /// uint 32 stores a 32-bit big-endian unsigned integer
            /// +--------+--------+--------+--------+--------+
            /// |  0xce  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
            /// +--------+--------+--------+--------+--------+
            return 0xce
            
        case .uint64:
            ///
            /// uint 64 stores a 64-bit big-endian unsigned integer
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
            /// |  0xcf  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
            return 0xcf
        }
    }
}

extension MsgPackFormat.Int: HasPrefix {
    var prefix: UInt8 {
        switch self {
        case .negativeFix(let x):
            ///
            /// negative fixnum stores 5-bit negative integer
            /// +--------+
            /// |111YYYYY|
            /// +--------+
            return UInt8(truncatingIfNeeded: x)
            
        case .int8:
            ///
            /// int 8 stores a 8-bit signed integer
            /// +--------+--------+
            /// |  0xd0  |ZZZZZZZZ|
            /// +--------+--------+
            return 0xd0
            
        case .int16:
            ///
            /// int 16 stores a 16-bit big-endian signed integer
            /// +--------+--------+--------+
            /// |  0xd1  |ZZZZZZZZ|ZZZZZZZZ|
            /// +--------+--------+--------+
            return 0xd1
            
        case .int32:
            ///
            /// int 32 stores a 32-bit big-endian signed integer
            /// +--------+--------+--------+--------+--------+
            /// |  0xd2  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
            /// +--------+--------+--------+--------+--------+
            return 0xd2
            
        case .int64:
            ///
            /// int 64 stores a 64-bit big-endian signed integer
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
            /// |  0xd3  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
            return 0xd3
        }
    }
}

extension MsgPackFormat.Map: HasPrefix {
    var prefix: UInt8 {
        switch self.type {
        case .fix:
            ///
            // fixmap stores a map whose length is upto 15 elements
            /// +--------+~~~~~~~~~~~~~~~~~+
            /// |1000XXXX|   N*2 objects   |
            /// +--------+~~~~~~~~~~~~~~~~~+
            return 0b10000000 | UInt8(truncatingIfNeeded: self.dict.count)
            
        case .map16:
            ///
            /// map 16 stores a map whose length is upto (2^16)-1 elements
            /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
            /// |  0xde  |YYYYYYYY|YYYYYYYY|   N*2 objects   |
            /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
            return 0xde
            
        case .map32:
            ///
            /// map 32 stores a map whose length is upto (2^32)-1 elements
            /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
            /// |  0xdf  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|   N*2 objects   |
            /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
            return 0xdf
        }
    }
}

extension MsgPackFormat.Ext: HasPrefix {
    var prefix: UInt8 {
        switch self.extType {
        case .fix1:
            /// fixext 1 stores an integer and a byte array whose length is 1 byte
            /// +--------+--------+--------+
            /// |  0xd4  |  type  |  data  |
            /// +--------+--------+--------+
            return 0xd4
            
        case .fix2:
            /// fixext 2 stores an integer and a byte array whose length is 2 bytes
            /// +--------+--------+--------+--------+
            /// |  0xd5  |  type  |       data      |
            /// +--------+--------+--------+--------+
            return 0xd5
            
        case .fix4:
            /// fixext 4 stores an integer and a byte array whose length is 4 bytes
            /// +--------+--------+--------+--------+--------+--------+
            /// |  0xd6  |  type  |                data               |
            /// +--------+--------+--------+--------+--------+--------+
            return 0xd6
            
        case .fix8:
            /// fixext 8 stores an integer and a byte array whose length is 8 bytes
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
            /// |  0xd7  |  type  |                                  data                                 |
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
            return 0xd7
            
        case .fix16:
            /// fixext 16 stores an integer and a byte array whose length is 16 bytes
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
            /// |  0xd8  |  type  |                                  data
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
            /// +--------+--------+--------+--------+--------+--------+--------+--------+
            ///                               data (cont.)                              |
            /// +--------+--------+--------+--------+--------+--------+--------+--------+
            return 0xd8
            
        case .ext8:
            /// ext 8 stores an integer and a byte array whose length is upto (2^8)-1 bytes:
            /// +--------+--------+--------+========+
            /// |  0xc7  |XXXXXXXX|  type  |  data  |
            /// +--------+--------+--------+========+
            return 0xc7
            
        case .ext16:
            /// ext 16 stores an integer and a byte array whose length is upto (2^16)-1 bytes:
            /// +--------+--------+--------+--------+========+
            /// |  0xc8  |YYYYYYYY|YYYYYYYY|  type  |  data  |
            /// +--------+--------+--------+--------+========+
            return 0xc8
            
        case .ext32:
            /// ext 32 stores an integer and a byte array whose length is upto (2^32)-1 bytes:
            /// +--------+--------+--------+--------+--------+--------+========+
            /// |  0xc9  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|  type  |  data  |
            /// +--------+--------+--------+--------+--------+--------+========+
            return 0xc9
        }
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

extension MsgPackFormat.Float: ExpressibleByFloatLiteral {
    init(floatLiteral value: Double) {
        self = .float64(value)
    }
}

// MARK: - Constructor

extension MsgPackFormat {
    static func from<U: UnsignedInteger>(positiveInteger value: U) -> MsgPackFormat {
        if value < 0b10000000 {
            return .uint(MsgPackFormat.UInt.positiveFix(UInt8(truncatingIfNeeded: value)))
        } else if value <= UInt8.max {
            return .uint(MsgPackFormat.UInt.uint8(UInt8(truncatingIfNeeded: value)))
        } else if value <= UInt16.max {
            return .uint(MsgPackFormat.UInt.uint16(UInt16(truncatingIfNeeded: value)))
        } else if value <= UInt32.max {
            return .uint(MsgPackFormat.UInt.uint32(UInt32(truncatingIfNeeded: value)))
        } else {
            return .uint(MsgPackFormat.UInt.uint64(UInt64(value)))
        }
    }
    
    static func from<S: SignedInteger>(negativeInteger value: S) throws -> MsgPackFormat {
        if value >= 0 {
            return .from(positiveInteger: UInt8(clamping: value))
        } else if value >= Int8(truncatingIfNeeded: 0b11100000) {
            return .int(MsgPackFormat.Int.negativeFix(Int8(truncatingIfNeeded: value)))
        } else if value >= Int8.min {
            return .int(MsgPackFormat.Int.int8(Int8(truncatingIfNeeded: value)))
        } else if value >= Int16.min {
            return .int(MsgPackFormat.Int.int16(Int16(truncatingIfNeeded: value)))
        } else if value >= Int32.min {
            return .int(MsgPackFormat.Int.int32(Int32(truncatingIfNeeded: value)))
        } else {
            return .int(MsgPackFormat.Int.int64(Int64(value)))
        }
    }
}

// MARK: - Packageable

protocol Packageable {
    var packedData: Data { get }
}

private func pack(_ value: UInt64, divided number: Int) -> [UInt8] {
    precondition(number > 0)
    
    return stride(from: 8 * (number - 1), through: 0, by: -8).map {
        UInt8(truncatingIfNeeded: value >> UInt64($0))
    }
}

extension MsgPackFormat.Nil: Packageable {
    var packedData: Data {
        ///
        /// `nil`
        ///
        /// +--------+
        /// |  0xc0  |
        /// +--------+
        return Data([prefix])
    }
}

extension MsgPackFormat.Bool: Packageable {
    var packedData: Data {
        ///
        /// `bool`
        ///
        /// false:
        /// +--------+
        /// |  0xc2  |
        /// +--------+
        ///
        /// true:
        /// +--------+
        /// |  0xc3  |
        /// +--------+
        return Data([prefix])
    }
}

extension MsgPackFormat.Binary: Packageable {
    var packedData: Data {
        switch type {
        case .bin8:
            ///
            /// `bin8`
            ///
            /// bin 8 stores a byte array whose length is upto (2^8)-1 bytes:
            /// +--------+--------+========+
            /// |  0xc4  |XXXXXXXX|  data  |
            /// +--------+--------+========+
            ///
            /// XXXXXXXX is a 8-bit unsigned integer which represents a length of data
            return Data([prefix, UInt8(data.count)]) + data
            
        case .bin16:
            ///
            /// `bin16`
            ///
            /// bin 16 stores a byte array whose length is upto (2^16)-1 bytes:
            /// +--------+--------+--------+========+
            /// |  0xc5  |YYYYYYYY|YYYYYYYY|  data  |
            /// +--------+--------+--------+========+
            ///
            /// YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents a length of data
            return Data([prefix] + pack(UInt64(data.count), divided: 2)) + data
            
        case .bin32:
            /// `bin32`
            ///
            /// bin 32 stores a byte array whose length is upto (2^32)-1 bytes:
            /// +--------+--------+--------+--------+--------+========+
            /// |  0xc6  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|  data  |
            /// +--------+--------+--------+--------+--------+========+
            ///
            /// ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a 32-bit big-endian unsigned integer which represents
            /// `the length of data`
            return Data([prefix] + pack(UInt64(data.count), divided: 4)) + data
        }
    }
}

extension MsgPackFormat.Float: Packageable {
    var packedData: Data {
        switch self {
        case .float32(let x):
            /// `float32`
            ///
            /// float 32 stores a floating point number in IEEE 754 single precision floating point number format:
            /// +--------+--------+--------+--------+--------+
            /// |  0xca  |XXXXXXXX|XXXXXXXX|XXXXXXXX|XXXXXXXX|
            /// +--------+--------+--------+--------+--------+
            ///
            /// XXXXXXXX_XXXXXXXX_XXXXXXXX_XXXXXXXX is a big-endian IEEE 754 single precision floating point number.
            /// Extension of precision from single-precision to double-precision does not lose precision.
            return Data([prefix] + pack(UInt64(x.bitPattern), divided: 4))

        case .float64(let x):
            /// `float64`
            ///
            /// float 64 stores a floating point number in IEEE 754 double precision floating point number format:
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
            /// |  0xcb  |YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
            ///
            /// YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY is a big-endian
            /// IEEE 754 double precision floating point number
            return Data([prefix] + pack(x.bitPattern, divided: 8))
        }
    }
}

extension MsgPackFormat.Array: Packageable {
    var packedData: Data {
        switch self.type {
        case .fix:
            ///
            /// `fixarray`
            ///
            /// fixarray stores an array whose length is upto 15 elements:
            /// +--------+~~~~~~~~~~~~~~~~~+
            /// |1001XXXX|    N objects    |
            /// +--------+~~~~~~~~~~~~~~~~~+
            ///
            /// XXXX is a 4-bit unsigned integer which represents a size of array
            return Data([prefix]) + elements.flatMap{ $0.packedData }

        case .array16:
            ///
            /// `array16`
            ///
            /// array 16 stores an array whose length is upto (2^16)-1 elements:
            /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
            /// |  0xdc  |YYYYYYYY|YYYYYYYY|    N objects    |
            /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
            ///
            /// YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents a size of array
            return Data([prefix] + pack(UInt64(elements.count), divided: 2)) + elements.flatMap{ $0.packedData }

        case .array32:
            /// `array32`
            ///
            /// array 32 stores an array whose length is upto (2^32)-1 elements:
            /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
            /// |  0xdd  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|    N objects    |
            /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
            ///
            /// ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a 32-bit big-endian unsigned integer which represents a size of array
            return Data([prefix] + pack(UInt64(elements.count), divided: 4)) + elements.flatMap{ $0.packedData }
        }
    }
}

extension MsgPackFormat.String: Packageable {
    var packedData: Data {
        switch type {
        case .fix:
            ///
            /// `fixstr`
            ///
            /// fixstr stores a byte array whose length is upto 31 bytes:
            /// +--------+========+
            /// |101XXXXX|  data  |
            /// +--------+========+
            ///
            /// XXXXX is a 5-bit unsigned integer which represents a length of data
            return Data([prefix] + value.utf8)

        case .str8:
            /// `str8`
            ///
            /// str 8 stores a byte array whose length is upto (2^8)-1 bytes:
            /// +--------+--------+========+
            /// |  0xd9  |YYYYYYYY|  data  |
            /// +--------+--------+========+
            ///
            /// YYYYYYYY is a 8-bit unsigned integer which represents a length of data
            return Data([prefix, UInt8(value.utf8.count)] + value.utf8)

        case .str16:
            /// `str16`
            ///
            /// str 16 stores a byte array whose length is upto (2^16)-1 bytes:
            /// +--------+--------+--------+========+
            /// |  0xda  |ZZZZZZZZ|ZZZZZZZZ|  data  |
            /// +--------+--------+--------+========+
            ///
            /// ZZZZZZZZ_ZZZZZZZZ is a 16-bit big-endian unsigned integer which represents a length of data
            return Data([prefix] + pack(UInt64(value.utf8.count), divided: 2) + value.utf8)

        case .str32:
            /// `str32`
            ///
            /// str 32 stores a byte array whose length is upto (2^32)-1 bytes:
            /// +--------+--------+--------+--------+--------+========+
            /// |  0xdb  |AAAAAAAA|AAAAAAAA|AAAAAAAA|AAAAAAAA|  data  |
            /// +--------+--------+--------+--------+--------+========+
            ///
            /// AAAAAAAA_AAAAAAAA_AAAAAAAA_AAAAAAAA is a 32-bit big-endian unsigned integer which represents
            /// a length of data
            return Data([prefix] + pack(UInt64(value.utf8.count), divided: 4) + value.utf8)

        }
    }
}

extension MsgPackFormat.UInt: Packageable {
    var packedData: Data {
        switch self {
        case .positiveFix:
            /// `positive fixint`
            ///
            /// positive fixnum stores 7-bit positive integer
            /// +--------+
            /// |0XXXXXXX|
            /// +--------+
            ///
            /// 0XXXXXXX is 8-bit unsigned integer
            return Data([prefix])
            
        case .uint8(let x):
            /// `uint8`
            ///
            /// uint 8 stores a 8-bit unsigned integer
            /// +--------+--------+
            /// |  0xcc  |ZZZZZZZZ|
            /// +--------+--------+
            return Data([prefix, x])
            
        case .uint16(let x):
            /// `uint16`
            ///
            /// uint 16 stores a 16-bit big-endian unsigned integer
            /// +--------+--------+--------+
            /// |  0xcd  |ZZZZZZZZ|ZZZZZZZZ|
            /// +--------+--------+--------+
            return Data([prefix] + pack(UInt64(x), divided: 2))
            
        case .uint32(let x):
            /// uint32
            ///
            /// uint 32 stores a 32-bit big-endian unsigned integer
            /// +--------+--------+--------+--------+--------+
            /// |  0xce  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
            /// +--------+--------+--------+--------+--------+
            return Data([prefix] + pack(UInt64(x), divided: 4))

        case .uint64(let x):
            /// `uint64`
            ///
            /// uint 64 stores a 64-bit big-endian unsigned integer
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
            /// |  0xcf  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
            return Data([prefix] + pack(x, divided: 8))
        }
    }
}

extension MsgPackFormat.Int: Packageable {
    var packedData: Data {
        switch self {
        case .negativeFix:
            /// `negative fixint`
            ///
            /// negative fixnum stores 5-bit negative integer
            /// +--------+
            /// |111YYYYY|
            /// +--------+
            ///
            /// 111YYYYY is 8-bit signed integer
            return Data([prefix])
        
        case .int8(let x):
            /// `int8`
            ///
            /// int 8 stores a 8-bit signed integer
            /// +--------+--------+
            /// |  0xd0  |ZZZZZZZZ|
            /// +--------+--------+
            return Data([prefix, UInt8(bitPattern: x)])
            
        case .int16(let x):
            /// `int16`
            ///
            /// int 16 stores a 16-bit big-endian signed integer
            /// +--------+--------+--------+
            /// |  0xd1  |ZZZZZZZZ|ZZZZZZZZ|
            /// +--------+--------+--------+
            let target = UInt16(bitPattern: x)
            return Data([prefix] + pack(UInt64(target), divided: 2))

        case .int32(let x):
            /// `int32`
            ///
            /// int 32 stores a 32-bit big-endian signed integer
            /// +--------+--------+--------+--------+--------+
            /// |  0xd2  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
            /// +--------+--------+--------+--------+--------+
            let target = UInt32(bitPattern: x)
            return Data([prefix] + pack(UInt64(target), divided: 4))
        
        case .int64(let x):
            /// `int64`
            ///
            /// int 64 stores a 64-bit big-endian signed integer
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
            /// |  0xd3  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
            return Data([prefix] + pack(UInt64(bitPattern: x), divided: 8))
        }
    }
}

extension MsgPackFormat.Map: Packageable {
    var packedData: Data {
        
        let pre: Data
        switch self.type {
        case .fix:
            /// `fixmap`
            ///
            /// fixmap stores a map whose length is upto 15 elements
            /// +--------+~~~~~~~~~~~~~~~~~+
            /// |1000XXXX|   N*2 objects   |
            /// +--------+~~~~~~~~~~~~~~~~~+
            ///
            /// XXXX is a 4-bit unsigned integer which represents a size of map
            pre = Data([prefix])

        case .map16:
            /// `map16`
            ///
            /// map 16 stores a map whose length is upto (2^16)-1 elements
            /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
            /// |  0xde  |YYYYYYYY|YYYYYYYY|   N*2 objects   |
            /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
            ///
            /// YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents a size of map
            pre = Data([prefix] + pack(UInt64(dict.count), divided: 2))

        case .map32:
            /// `map32`
            ///
            /// map 32 stores a map whose length is upto (2^32)-1 elements
            /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
            /// |  0xdf  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|   N*2 objects   |
            /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
            ///
            /// ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a 32-bit big-endian unsigned integer which represents
            /// a size of map
            pre = Data([prefix] + pack(UInt64(dict.count), divided: 4))
        }
        
        return pre + dict.reduce(Data([])){ $0 + $1.0.packedData + $1.1.packedData }
    }
}

extension MsgPackFormat.Ext: Packageable {
    var packedData: Data {
        switch self.extType {
        case .fix1, .fix2, .fix4, .fix8, .fix16:
            /// `fixext1`
            ///
            /// fixext 1 stores an integer and a byte array whose length is 1 byte
            /// +--------+--------+--------+
            /// |  0xd4  |  type  |  data  |
            /// +--------+--------+--------+
            ///
            ///
            /// `fixext2`
            ///
            /// fixext 2 stores an integer and a byte array whose length is 2 bytes
            /// +--------+--------+--------+--------+
            /// |  0xd5  |  type  |       data      |
            /// +--------+--------+--------+--------+
            ///
            ///
            /// `fixext4`
            ///
            /// fixext 4 stores an integer and a byte array whose length is 4 bytes
            /// +--------+--------+--------+--------+--------+--------+
            /// |  0xd6  |  type  |                data               |
            /// +--------+--------+--------+--------+--------+--------+
            ///
            ///
            /// `fixext8`
            ///
            /// fixext 8 stores an integer and a byte array whose length is 8 bytes
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
            /// |  0xd7  |  type  |                                  data                                 |
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
            ///
            ///
            /// `fixext16`
            ///
            /// fixext 16 stores an integer and a byte array whose length is 16 bytes
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
            /// |  0xd8  |  type  |                                  data
            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
            /// +--------+--------+--------+--------+--------+--------+--------+--------+
            ///                               data (cont.)                              |
            /// +--------+--------+--------+--------+--------+--------+--------+--------+
            ///
            /// type is a signed 8-bit signed integer
            
            return Data([prefix, UInt8(bitPattern: type)]) + data
        
        case .ext8:
            /// `ext8`
            ///
            /// ext 8 stores an integer and a byte array whose length is upto (2^8)-1 bytes:
            /// +--------+--------+--------+========+
            /// |  0xc7  |XXXXXXXX|  type  |  data  |
            /// +--------+--------+--------+========+
            ///
            /// type is a signed 8-bit signed integer
            /// XXXXXXXX is a 8-bit unsigned integer which represents a length of data
            return Data([prefix, UInt8(truncatingIfNeeded: data.count), UInt8(bitPattern: type)]) + data

        case .ext16:
            /// `ext16`
            ///
            /// ext 16 stores an integer and a byte array whose length is upto (2^16)-1 bytes:
            /// +--------+--------+--------+--------+========+
            /// |  0xc8  |YYYYYYYY|YYYYYYYY|  type  |  data  |
            /// +--------+--------+--------+--------+========+
            ///
            /// type is a signed 8-bit signed integer
            /// YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents a length of data
            var elements: [UInt8] = pack(UInt64(truncatingIfNeeded: data.count), divided: 2)
            elements.insert(prefix, at: 0)
            elements.append(UInt8(bitPattern: type))
            return Data(elements) + data

        case .ext32:
            /// `ext32`
            ///
            /// ext 32 stores an integer and a byte array whose length is upto (2^32)-1 bytes:
            /// +--------+--------+--------+--------+--------+--------+========+
            /// |  0xc9  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|  type  |  data  |
            /// +--------+--------+--------+--------+--------+--------+========+
            ///
            /// type is a signed 8-bit signed integer
            /// ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a big-endian 32-bit unsigned integer which represents a length of data
            var elements: [UInt8] = pack(UInt64(truncatingIfNeeded: data.count), divided: 4)
            elements.insert(prefix, at: 0)
            elements.append(UInt8(bitPattern: type))
            return Data(elements) + data
        }
    }
}

extension MsgPackFormat: Packageable {
    var packedData: Data {
        switch self {
        case .nil(let x):       return x.packedData
        case .bool(let x):      return x.packedData
        case .binary(let x):    return x.packedData
        case .float(let x):     return x.packedData
        case .array(let x):     return x.packedData
        case .string(let x):    return x.packedData
        case .uint(let x):      return x.packedData
        case .int(let x):       return x.packedData
        case .map(let x):       return x.packedData
        case .ext(let x):       return x.packedData
        }
    }
}
