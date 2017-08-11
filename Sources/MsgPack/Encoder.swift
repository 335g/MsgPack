
///
/// The following description quotes [official documentation](https://github.com/msgpack/msgpack/blob/master/spec.md).
///
///
/// ## Notation in diagrams
///
/// one byte:
/// +--------+
/// |        |
/// +--------+
///
/// a variable number of bytes:
/// +========+
/// |        |
/// +========+
///
/// variable number of objects stored in MessagePack format:
/// +~~~~~~~~~~~~~~~~~+
/// |                 |
/// +~~~~~~~~~~~~~~~~~+
///

import Foundation

public struct MsgPackEncoder {
    public struct Options {
        let userInfo: [CodingUserInfoKey : Any]
        
        init(_ userInfo: [CodingUserInfoKey : Any] = [:]) {
            self.userInfo = userInfo
        }
    }
    
    fileprivate struct Worker {
        let options: Options
        var codingPath: [CodingKey]
        var data: Data
        
        init(options: Options, codingPath: [CodingKey] = []) {
            self.options = options
            self.codingPath = codingPath
            self.data = Data([])
        }
    }
    
    public enum Error: Swift.Error {
        case overflow
        case notUTF8String
    }
    
    var options: Options = Options()
    
    public init() {}
    
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = Worker(options: options)
        try value.encode(to: encoder)
        
        return encoder.data
    }
}

extension MsgPackEncoder.Worker: Swift.Encoder {
    var userInfo: [CodingUserInfoKey : Any] {
        return options.userInfo
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        fatalError()
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

extension MsgPackEncoder.Worker: SingleValueEncodingContainer {
    mutating func encodeNil() throws {
        fatalError()
    }
    
    mutating func encode(_ value: Bool) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int8) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int16) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int32) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int64) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt8) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt16) throws {
        fatalError()
        
    }
    
    mutating func encode(_ value: UInt32) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt64) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Float) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Double) throws {
        fatalError()
    }
    
    mutating func encode(_ value: String) throws {
        fatalError()
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        fatalError()
    }
}

//private struct MsgPackSingleEncodingContainer: SingleValueEncodingContainer {
//    var codingPath: [CodingKey]
//    var format: MsgPackFormat?
//
//    init(with format: MsgPackFormat? = nil, codingPath: [CodingKey] = []){
//        self.codingPath = codingPath
//        self.format = format
//    }
//
//    mutating func encodeNil() throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: Bool) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: Int) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: Int8) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: Int16) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: Int32) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: Int64) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: UInt) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: UInt8) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: UInt16) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: UInt32) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: UInt64) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: Float) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: Double) throws {
//        fatalError()
//    }
//
//    mutating func encode(_ value: String) throws {
//        fatalError()
//    }
//
//    mutating func encode<T>(_ value: T) throws where T : Encodable {
//        fatalError()
//    }
//}

private struct MsgPackUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    var count: Int
    
    var codingPath: [CodingKey]
    
    mutating func encodeNil() throws {
        fatalError()
    }
    
    mutating func encode(_ value: Bool) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int8) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int16) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int32) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int64) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt8) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt16) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt32) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt64) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Float) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Double) throws {
        fatalError()
    }
    
    mutating func encode(_ value: String) throws {
        fatalError()
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        fatalError()
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        fatalError()
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    mutating func superEncoder() -> Encoder {
        fatalError()
    }
}

private struct MsgPackKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K
    
    var codingPath: [CodingKey]
    
    mutating func encodeNil(forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Bool, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int8, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int16, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int32, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int64, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt8, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt16, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt32, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt64, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Float, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Double, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode(_ value: String, forKey key: K) throws {
        fatalError()
    }
    
    mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        fatalError()
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }
    
    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    mutating func superEncoder() -> Encoder {
        fatalError()
    }
    
    mutating func superEncoder(forKey key: K) -> Encoder {
        fatalError()
    }
}

//extension MsgPackObject.Nil {
//    fileprivate func encode() throws -> Data {
//        ///
//        /// `nil`
//        ///
//        /// +--------+
//        /// |  0xc0  |
//        /// +--------+
//        return Data([0xc0])
//    }
//}
//
//extension Bool {
//    fileprivate func encode() throws -> Data {
//        ///
//        /// `bool`
//        ///
//        /// false:
//        /// +--------+
//        /// |  0xc2  |
//        /// +--------+
//        ///
//        /// true:
//        /// +--------+
//        /// |  0xc3  |
//        /// +--------+
//        return Data([self ? 0xc3 : 0xc2])
//    }
//}
//
//extension UInt64 {
//    fileprivate func encode() throws -> Data {
//        if self < 0b10000000 {
//            ///
//            /// `positive fixint`
//            ///
//            /// positive fixnum stores 7-bit positive integer
//            /// +--------+
//            /// |0XXXXXXX|
//            /// +--------+
//            ///
//            /// 0XXXXXXX is 8-bit unsigned integer
//            //return Data([UInt8(extendingOrTruncating: self)])
//            return Data([UInt8(truncatingIfNeeded: self)])
//
//        } else if self <= 0xff {
//            ///
//            /// `uint8`
//            ///
//            /// uint 8 stores a 8-bit unsigned integer
//            /// +--------+--------+
//            /// |  0xcc  |ZZZZZZZZ|
//            /// +--------+--------+
//            return Data([0xcc, UInt8(truncatingIfNeeded: self)])
//
//        } else if self <= 0xffff {
//            ///
//            /// `uint16`
//            ///
//            /// uint 16 stores a 16-bit big-endian unsigned integer
//            /// +--------+--------+--------+
//            /// |  0xcd  |ZZZZZZZZ|ZZZZZZZZ|
//            /// +--------+--------+--------+
//            return Data([0xcd] + MsgPackEncoder.pack(self, divided: 2))
//
//        } else if self <= 0xffff_ffff {
//            ///
//            /// uint32
//            ///
//            /// uint 32 stores a 32-bit big-endian unsigned integer
//            /// +--------+--------+--------+--------+--------+
//            /// |  0xce  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
//            /// +--------+--------+--------+--------+--------+
//            return Data([0xce] + MsgPackEncoder.pack(self, divided: 4))
//
//        } else {
//            ///
//            /// `uint64`
//            ///
//            /// uint 64 stores a 64-bit big-endian unsigned integer
//            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
//            /// |  0xcf  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
//            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
//            return Data([0xcf] + MsgPackEncoder.pack(self, divided: 8))
//        }
//    }
//}
//
//extension Int64 {
//    fileprivate func encode() throws -> Data {
//        if self >= 0 {
//            return try UInt64(self).encode()
//        } else if self >= -0x20 {
//            ///
//            /// `negative fixint`
//            ///
//            /// negative fixnum stores 5-bit negative integer
//            /// +--------+
//            /// |111YYYYY|
//            /// +--------+
//            ///
//            /// 111YYYYY is 8-bit signed integer
//            return Data([0xe0 + 0x1f & UInt8(truncatingIfNeeded: self)])
//
//        } else if self >= -0x7f {
//            ///
//            /// `int8`
//            ///
//            /// int 8 stores a 8-bit signed integer
//            /// +--------+--------+
//            /// |  0xd0  |ZZZZZZZZ|
//            /// +--------+--------+
//            return Data([0xd0, UInt8(bitPattern: Int8(self))])
//
//        } else if self >= -0x7ffff {
//            ///
//            /// `int16`
//            ///
//            /// int 16 stores a 16-bit big-endian signed integer
//            /// +--------+--------+--------+
//            /// |  0xd1  |ZZZZZZZZ|ZZZZZZZZ|
//            /// +--------+--------+--------+
//            let truncated = UInt16(bitPattern: Int16(self))
//            return Data([0xd1] + MsgPackEncoder.pack(UInt64(truncated), divided: 2))
//
//        } else if self >= -0x7ffff_ffff {
//            ///
//            /// `int32`
//            ///
//            /// int 32 stores a 32-bit big-endian signed integer
//            /// +--------+--------+--------+--------+--------+
//            /// |  0xd2  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
//            /// +--------+--------+--------+--------+--------+
//            let truncated = UInt32(bitPattern: Int32(self))
//            return Data([0xd2] + MsgPackEncoder.pack(UInt64(truncated), divided: 4))
//
//        } else {
//            ///
//            /// `int64`
//            ///
//            /// int 64 stores a 64-bit big-endian signed integer
//            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
//            /// |  0xd3  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
//            /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
//            let truncated = UInt64(bitPattern: Int64(self))
//            return Data([0xd3] + MsgPackEncoder.pack(truncated, divided: 8))
//        }
//    }
//}
//
//extension Float {
//    fileprivate func encode() throws -> Data {
//        ///
//        /// `float32`
//        ///
//        /// float 32 stores a floating point number in IEEE 754 single precision floating point number format:
//        /// +--------+--------+--------+--------+--------+
//        /// |  0xca  |XXXXXXXX|XXXXXXXX|XXXXXXXX|XXXXXXXX|
//        /// +--------+--------+--------+--------+--------+
//        ///
//        /// XXXXXXXX_XXXXXXXX_XXXXXXXX_XXXXXXXX is a big-endian IEEE 754 single precision floating point number.
//        /// Extension of precision from single-precision to double-precision does not lose precision.
//        return Data([0xca] + MsgPackEncoder.pack(UInt64(self.bitPattern), divided: 4))
//    }
//}
//
//extension Double {
//    fileprivate func encode() throws -> Data {
//        ///
//        /// `float64`
//        ///
//        /// float 64 stores a floating point number in IEEE 754 double precision floating point number format:
//        /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
//        /// |  0xcb  |YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|
//        /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
//        ///
//        /// YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY is a big-endian
//        /// IEEE 754 double precision floating point number
//        return Data([0xcb] + MsgPackEncoder.pack(self.bitPattern, divided: 8))
//    }
//}
//
//// TODO: Conditional Conformance
//extension Array where Element == MsgPackObject {
//    fileprivate func encode() throws -> Data {
//        let count = self.count
//
//        guard count < 0xffff_ffff else {
//            throw MsgPackEncodeError.overflow
//        }
//
//        let rest = try self.flatMap{ try $0.encode() }
//        if count <= 15 {
//            ///
//            /// `fixarray`
//            ///
//            /// fixarray stores an array whose length is upto 15 elements:
//            /// +--------+~~~~~~~~~~~~~~~~~+
//            /// |1001XXXX|    N objects    |
//            /// +--------+~~~~~~~~~~~~~~~~~+
//            ///
//            /// XXXX is a 4-bit unsigned integer which represents a size of array
//            return Data([0x90 | UInt8(count)] + rest)
//
//        } else if count < 0xffff {
//            ///
//            /// `array16`
//            ///
//            /// array 16 stores an array whose length is upto (2^16)-1 elements:
//            /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
//            /// |  0xdc  |YYYYYYYY|YYYYYYYY|    N objects    |
//            /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
//            ///
//            /// YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents a size of array
//            return Data([0xdc] + MsgPackEncoder.pack(UInt64(count), divided: 2) + rest)
//
//        } else {
//            ///
//            /// `array32`
//            ///
//            /// array 32 stores an array whose length is upto (2^32)-1 elements:
//            /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
//            /// |  0xdd  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|    N objects    |
//            /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
//            ///
//            /// ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a 32-bit big-endian unsigned integer which represents a size of array
//            return Data([0xdd] + MsgPackEncoder.pack(UInt64(count), divided: 4) + rest)
//        }
//    }
//}
//
//extension String {
//    fileprivate func encode() throws -> Data {
//        let utf8 = self.utf8
//        let count = UInt64(utf8.count)
//
//        guard count < 0xffff_ffff else {
//            throw MsgPackEncodeError.overflow
//        }
//
//        if count < 0x20 {
//            ///
//            /// `fixstr`
//            ///
//            /// fixstr stores a byte array whose length is upto 31 bytes:
//            /// +--------+========+
//            /// |101XXXXX|  data  |
//            /// +--------+========+
//            ///
//            /// XXXXX is a 5-bit unsigned integer which represents a length of data
//            return Data([0xa0 | UInt8(count)] + utf8)
//
//        } else if count < 0xff {
//            ///
//            /// `str8`
//            ///
//            /// str 8 stores a byte array whose length is upto (2^8)-1 bytes:
//            /// +--------+--------+========+
//            /// |  0xd9  |YYYYYYYY|  data  |
//            /// +--------+--------+========+
//            ///
//            /// YYYYYYYY is a 8-bit unsigned integer which represents a length of data
//            return Data([0xd9, UInt8(count)] + utf8)
//
//        } else if count < 0xffff {
//            ///
//            /// `str16`
//            ///
//            /// str 16 stores a byte array whose length is upto (2^16)-1 bytes:
//            /// +--------+--------+--------+========+
//            /// |  0xda  |ZZZZZZZZ|ZZZZZZZZ|  data  |
//            /// +--------+--------+--------+========+
//            ///
//            /// ZZZZZZZZ_ZZZZZZZZ is a 16-bit big-endian unsigned integer which represents a length of data
//            return Data([0xda] + MsgPackEncoder.pack(count, divided: 2) + utf8)
//
//        } else {
//            ///
//            /// `str32`
//            ///
//            /// str 32 stores a byte array whose length is upto (2^32)-1 bytes:
//            /// +--------+--------+--------+--------+--------+========+
//            /// |  0xdb  |AAAAAAAA|AAAAAAAA|AAAAAAAA|AAAAAAAA|  data  |
//            /// +--------+--------+--------+--------+--------+========+
//            ///
//            /// AAAAAAAA_AAAAAAAA_AAAAAAAA_AAAAAAAA is a 32-bit big-endian unsigned integer which represents
//            /// a length of data
//            return Data([0xdb] + MsgPackEncoder.pack(count, divided: 4) + utf8)
//        }
//    }
//}
//
//extension Data {
//    fileprivate func encode() throws -> Data {
//        let count = UInt64(self.count)
//
//        guard count < 0xffff_ffff else {
//            throw MsgPackEncodeError.overflow
//        }
//
//        if count < 0xff {
//            ///
//            /// `bin8`
//            ///
//            /// bin 8 stores a byte array whose length is upto (2^8)-1 bytes:
//            /// +--------+--------+========+
//            /// |  0xc4  |XXXXXXXX|  data  |
//            /// +--------+--------+========+
//            ///
//            /// XXXXXXXX is a 8-bit unsigned integer which represents a length of data
//            return Data([0xc4, UInt8(count)]) + self
//
//        } else if count < 0xffff {
//            ///
//            /// `bin16`
//            ///
//            /// bin 16 stores a byte array whose length is upto (2^16)-1 bytes:
//            /// +--------+--------+--------+========+
//            /// |  0xc5  |YYYYYYYY|YYYYYYYY|  data  |
//            /// +--------+--------+--------+========+
//            ///
//            /// YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents a length of data
//            return Data([0xc5] + MsgPackEncoder.pack(count, divided: 2)) + self
//
//        } else {
//            ///
//            /// `bin32`
//            ///
//            /// bin 32 stores a byte array whose length is upto (2^32)-1 bytes:
//            /// +--------+--------+--------+--------+--------+========+
//            /// |  0xc6  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|  data  |
//            /// +--------+--------+--------+--------+--------+========+
//            ///
//            /// ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a 32-bit big-endian unsigned integer which represents
//            /// `the length of data`
//            return Data([0xc6] + MsgPackEncoder.pack(count, divided: 4)) + self
//        }
//    }
//}
//
//extension Dictionary where Key == MsgPackObject, Value == MsgPackObject {
//    public func encode() throws -> Data {
//        let count = UInt64(self.count)
//
//        guard count < 0xffff_ffff else {
//            throw MsgPackEncodeError.overflow
//        }
//
//        let prefix: Data
//        if count <= 15 {
//            ///
//            /// `fixmap`
//            ///
//            /// fixmap stores a map whose length is upto 15 elements
//            /// +--------+~~~~~~~~~~~~~~~~~+
//            /// |1000XXXX|   N*2 objects   |
//            /// +--------+~~~~~~~~~~~~~~~~~+
//            ///
//            /// XXXX is a 4-bit unsigned integer which represents a size of map
//            prefix = Data([0x80 | UInt8(count)])
//
//        } else if count < 0xffff {
//            ///
//            /// `map16`
//            ///
//            /// map 16 stores a map whose length is upto (2^16)-1 elements
//            /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
//            /// |  0xde  |YYYYYYYY|YYYYYYYY|   N*2 objects   |
//            /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
//            ///
//            /// YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents a size of map
//            prefix = Data([0xde] + MsgPackEncoder.pack(count, divided: 2))
//
//        } else {
//            ///
//            /// `map32`
//            ///
//            /// map 32 stores a map whose length is upto (2^32)-1 elements
//            /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
//            /// |  0xdf  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|   N*2 objects   |
//            /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
//            ///
//            /// ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a 32-bit big-endian unsigned integer which represents
//            /// a size of map
//            prefix = Data([0xdf] + MsgPackEncoder.pack(count, divided: 4))
//        }
//
//        let flatten: [MsgPackObject] = self.reduce([]){ (list, x) in
//            let (k, v) = x
//            return list + [k, v]
//        }
//
//        return prefix + (try flatten.flatMap{ try $0.encode() })
//    }
//}
//
//extension MsgPackObject {
//    public func encode() throws -> Data {
//        switch self {
//        case .nil(let x):       return try x.encode()
//        case .bool(let x):      return try x.encode()
//        case .int(let x):       return try x.encode()
//        case .uint(let x):      return try x.encode()
//        case .float(let x):     return try x.encode()
//        case .double(let x):    return try x.encode()
//        case .array(let x):     return try x.encode()
//        case .map(let x):       return try x.encode()
//        case .string(let x):    return try x.encode()
//        case .binary(let x):    return try x.encode()
//
//        case .ext(let type, let data):
//            let count = UInt64(data.count)
//
//            guard count < 0xffff_ffff else {
//                throw MsgPackEncodeError.overflow
//            }
//
//            let type = UInt8(bitPattern: type)
//            if count == 1 {
//                ///
//                /// `fixext1`
//                ///
//                /// fixext 1 stores an integer and a byte array whose length is 1 byte
//                /// +--------+--------+--------+
//                /// |  0xd4  |  type  |  data  |
//                /// +--------+--------+--------+
//                ///
//                /// type is a signed 8-bit signed integer
//                return Data([0xd4, type]) + data
//
//            } else if count == 2 {
//                ///
//                /// `fixext2`
//                ///
//                /// fixext 2 stores an integer and a byte array whose length is 2 bytes
//                /// +--------+--------+--------+--------+
//                /// |  0xd5  |  type  |       data      |
//                /// +--------+--------+--------+--------+
//                ///
//                /// type is a signed 8-bit signed integer
//                return Data([0xd5, type]) + data
//
//            } else if count == 4 {
//                ///
//                /// `fixext4`
//                ///
//                /// fixext 4 stores an integer and a byte array whose length is 4 bytes
//                /// +--------+--------+--------+--------+--------+--------+
//                /// |  0xd6  |  type  |                data               |
//                /// +--------+--------+--------+--------+--------+--------+
//                ///
//                /// type is a signed 8-bit signed integer
//                return Data([0xd6, type]) + data
//
//            } else if count == 8 {
//                ///
//                /// `fixext8`
//                ///
//                /// fixext 8 stores an integer and a byte array whose length is 8 bytes
//                /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
//                /// |  0xd7  |  type  |                                  data                                 |
//                /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
//                ///
//                /// type is a signed 8-bit signed integer
//                return Data([0xd7, type]) + data
//
//            } else if count == 16 {
//                ///
//                /// `fixext16`
//                ///
//                /// fixext 16 stores an integer and a byte array whose length is 16 bytes
//                /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
//                /// |  0xd8  |  type  |                                  data
//                /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
//                /// +--------+--------+--------+--------+--------+--------+--------+--------+
//                ///                               data (cont.)                              |
//                /// +--------+--------+--------+--------+--------+--------+--------+--------+
//                ///
//                /// type is a signed 8-bit signed integer
//                return Data([0xd8, type]) + data
//
//            } else if count < 0xff {
//                ///
//                /// `ext8`
//                ///
//                /// ext 8 stores an integer and a byte array whose length is upto (2^8)-1 bytes:
//                /// +--------+--------+--------+========+
//                /// |  0xc7  |XXXXXXXX|  type  |  data  |
//                /// +--------+--------+--------+========+
//                ///
//                /// type is a signed 8-bit signed integer
//                /// XXXXXXXX is a 8-bit unsigned integer which represents a length of data
//                return Data([0xc7, UInt8(count), type]) + data
//
//            } else if count < 0xffff {
//                ///
//                /// `ext16`
//                ///
//                /// ext 16 stores an integer and a byte array whose length is upto (2^16)-1 bytes:
//                /// +--------+--------+--------+--------+========+
//                /// |  0xc8  |YYYYYYYY|YYYYYYYY|  type  |  data  |
//                /// +--------+--------+--------+--------+========+
//                ///
//                /// type is a signed 8-bit signed integer
//                /// YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents a length of data
//                return Data([0xc8] + MsgPackEncoder.pack(count, divided: 2) + [type]) + data
//
//            } else {
//                ///
//                /// `ext32`
//                ///
//                /// ext 32 stores an integer and a byte array whose length is upto (2^32)-1 bytes:
//                /// +--------+--------+--------+--------+--------+--------+========+
//                /// |  0xc9  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|  type  |  data  |
//                /// +--------+--------+--------+--------+--------+--------+========+
//                ///
//                /// type is a signed 8-bit signed integer
//                /// ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a big-endian 32-bit unsigned integer which represents a length of data
//                return Data([0xc9] + MsgPackEncoder.pack(count, divided: 4) + [type]) + data
//            }
//        }
//    }
//}
//
//// MARK: MsgPackEncoder
//
//public struct MsgPackEncoder {}
//
//extension MsgPackEncoder {
//    static func pack(_ value: UInt64, divided number: Int) -> [UInt8] {
//        precondition(number > 0)
//
//        return stride(from: 8 * (number - 1), through: 0, by: -8).map{
//            UInt8(truncatingIfNeeded: value >> UInt64($0))
//        }
//    }
//
//    public func encode(_ value: MsgPackObject) throws -> Data {
//        return try value.encode()
//    }
//}


