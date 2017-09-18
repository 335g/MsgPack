//
//  Encode.swift
//  MsgPack
//
//  Created by Yoshiki Kudo on 2017/09/17.
//

import Foundation

extension MsgPackObject {
    public func encode() throws -> Data {
        switch self {
        case .nil:
            ///
            /// `nil`
            ///
            /// +--------+
            /// |  0xc0  |
            /// +--------+
            return Data([0xc0])
            
        case .bool(let x):
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
            return Data([x ? 0xc3 : 0xc2])
            
        case .uint(let x):
            return MsgPack.encode(positive: x)
            
        case .int(let x):
            return x >= 0
                ? MsgPack.encode(positive: UInt64(x))
                : MsgPack.encode(negative: x)
            
        case .float(let x):
            return MsgPack.encode(float: x)
        case .double(let x):
            return MsgPack.encode(double: x)
        case .string(let x):
            return try MsgPack.encode(string: x)
        case .binary(let x):
            return try MsgPack.encode(binary: x)
        case .array(let x):
            return try MsgPack.encode(array: x)
        case .map(let x):
            return try MsgPack.encode(map: x)
        case .ext(let type, let data):
            return try MsgPack.encode(type: type, data: data)
        }
    }
}

private func encode(positive value: UInt64) -> Data {
    if value < 0b10000000 {
        ///
        /// `positive fixint`
        ///
        /// positive fixnum stores 7-bit positive integer
        /// +--------+
        /// |0XXXXXXX|
        /// +--------+
        ///
        /// 0XXXXXXX is 8-bit unsigned integer
        //return Data([UInt8(extendingOrTruncating: self)])
        return Data([UInt8(truncatingIfNeeded: value)])
        
    } else if value <= 0xff {
        ///
        /// `uint8`
        ///
        /// uint 8 stores a 8-bit unsigned integer
        /// +--------+--------+
        /// |  0xcc  |ZZZZZZZZ|
        /// +--------+--------+
        return Data([0xcc, UInt8(truncatingIfNeeded: value)])
        
    } else if value <= 0xffff {
        ///
        /// `uint16`
        ///
        /// uint 16 stores a 16-bit big-endian unsigned integer
        /// +--------+--------+--------+
        /// |  0xcd  |ZZZZZZZZ|ZZZZZZZZ|
        /// +--------+--------+--------+
        return Data([0xcd] + pack(value, divided: 2))
        
    } else if value <= 0xffff_ffff {
        ///
        /// uint32
        ///
        /// uint 32 stores a 32-bit big-endian unsigned integer
        /// +--------+--------+--------+--------+--------+
        /// |  0xce  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
        /// +--------+--------+--------+--------+--------+
        return Data([0xce] + pack(value, divided: 4))
        
    } else {
        ///
        /// `uint64`
        ///
        /// uint 64 stores a 64-bit big-endian unsigned integer
        /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
        /// |  0xcf  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
        /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
        return Data([0xcf] + pack(value, divided: 8))
    }
}

private func encode(negative value: Int64) -> Data {
    precondition(value < 0)
    
    if value >= -0x20 {
        ///
        /// `negative fixint`
        ///
        /// negative fixnum stores 5-bit negative integer
        /// +--------+
        /// |111YYYYY|
        /// +--------+
        ///
        /// 111YYYYY is 8-bit signed integer
        return Data([0xe0 + 0x1f & UInt8(truncatingIfNeeded: value)])
        
    } else if value >= -0x7f {
        ///
        /// `int8`
        ///
        /// int 8 stores a 8-bit signed integer
        /// +--------+--------+
        /// |  0xd0  |ZZZZZZZZ|
        /// +--------+--------+
        return Data([0xd0, UInt8(bitPattern: Int8(value))])
        
    } else if value >= -0x7ffff {
        ///
        /// `int16`
        ///
        /// int 16 stores a 16-bit big-endian signed integer
        /// +--------+--------+--------+
        /// |  0xd1  |ZZZZZZZZ|ZZZZZZZZ|
        /// +--------+--------+--------+
        let truncated = UInt16(bitPattern: Int16(value))
        return Data([0xd1] + pack(UInt64(truncated), divided: 2))
        
    } else if value >= -0x7ffff_ffff {
        ///
        /// `int32`
        ///
        /// int 32 stores a 32-bit big-endian signed integer
        /// +--------+--------+--------+--------+--------+
        /// |  0xd2  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
        /// +--------+--------+--------+--------+--------+
        let truncated = UInt32(bitPattern: Int32(value))
        return Data([0xd2] + pack(UInt64(truncated), divided: 4))
        
    } else {
        ///
        /// `int64`
        ///
        /// int 64 stores a 64-bit big-endian signed integer
        /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
        /// |  0xd3  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|
        /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
        let truncated = UInt64(bitPattern: Int64(value))
        return Data([0xd3] + pack(truncated, divided: 8))
    }
}

private func encode(float value: Float) -> Data {
    ///
    /// `float32`
    ///
    /// float 32 stores a floating point number in IEEE 754 single precision floating point number format:
    /// +--------+--------+--------+--------+--------+
    /// |  0xca  |XXXXXXXX|XXXXXXXX|XXXXXXXX|XXXXXXXX|
    /// +--------+--------+--------+--------+--------+
    ///
    /// XXXXXXXX_XXXXXXXX_XXXXXXXX_XXXXXXXX is a big-endian IEEE 754 single precision floating point number.
    /// Extension of precision from single-precision to double-precision does not lose precision.
    return Data([0xca] + pack(UInt64(value.bitPattern), divided: 4))
}

private func encode(double value: Double) -> Data {
    ///
    /// `float64`
    ///
    /// float 64 stores a floating point number in IEEE 754 double precision floating point number format:
    /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
    /// |  0xcb  |YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|YYYYYYYY|
    /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+
    ///
    /// YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY_YYYYYYYY is a big-endian
    /// IEEE 754 double precision floating point number
    return Data([0xcb] + pack(value.bitPattern, divided: 8))
}

private func encode(string value: String) throws -> Data {
    let utf8 = value.utf8
    let count = UInt64(utf8.count)
    
    guard count < 0xffff_ffff else {
        throw MsgPackEncodeError.overflow
    }
    
    if count < 0x20 {
        ///
        /// `fixstr`
        ///
        /// fixstr stores a byte array whose length is upto 31 bytes:
        /// +--------+========+
        /// |101XXXXX|  data  |
        /// +--------+========+
        ///
        /// XXXXX is a 5-bit unsigned integer which represents a length of data
        return Data([0xa0 | UInt8(count)] + utf8)
        
    } else if count < 0xff {
        ///
        /// `str8`
        ///
        /// str 8 stores a byte array whose length is upto (2^8)-1 bytes:
        /// +--------+--------+========+
        /// |  0xd9  |YYYYYYYY|  data  |
        /// +--------+--------+========+
        ///
        /// YYYYYYYY is a 8-bit unsigned integer which represents a length of data
        return Data([0xd9, UInt8(count)] + utf8)
        
    } else if count < 0xffff {
        ///
        /// `str16`
        ///
        /// str 16 stores a byte array whose length is upto (2^16)-1 bytes:
        /// +--------+--------+--------+========+
        /// |  0xda  |ZZZZZZZZ|ZZZZZZZZ|  data  |
        /// +--------+--------+--------+========+
        ///
        /// ZZZZZZZZ_ZZZZZZZZ is a 16-bit big-endian unsigned integer which represents a length of data
        return Data([0xda] + pack(count, divided: 2) + utf8)
        
    } else {
        ///
        /// `str32`
        ///
        /// str 32 stores a byte array whose length is upto (2^32)-1 bytes:
        /// +--------+--------+--------+--------+--------+========+
        /// |  0xdb  |AAAAAAAA|AAAAAAAA|AAAAAAAA|AAAAAAAA|  data  |
        /// +--------+--------+--------+--------+--------+========+
        ///
        /// AAAAAAAA_AAAAAAAA_AAAAAAAA_AAAAAAAA is a 32-bit big-endian unsigned integer which represents
        /// a length of data
        return Data([0xdb] + pack(count, divided: 4) + utf8)
    }
}

private func encode(binary value: Data) throws -> Data {
    let count = UInt64(value.count)
    
    guard count < 0xffff_ffff else {
        throw MsgPackEncodeError.overflow
    }
    
    if count < 0xff {
        ///
        /// `bin8`
        ///
        /// bin 8 stores a byte array whose length is upto (2^8)-1 bytes:
        /// +--------+--------+========+
        /// |  0xc4  |XXXXXXXX|  data  |
        /// +--------+--------+========+
        ///
        /// XXXXXXXX is a 8-bit unsigned integer which represents a length of data
        return Data([0xc4, UInt8(count)]) + value
        
    } else if count < 0xffff {
        ///
        /// `bin16`
        ///
        /// bin 16 stores a byte array whose length is upto (2^16)-1 bytes:
        /// +--------+--------+--------+========+
        /// |  0xc5  |YYYYYYYY|YYYYYYYY|  data  |
        /// +--------+--------+--------+========+
        ///
        /// YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents a length of data
        return Data([0xc5] + pack(count, divided: 2)) + value
        
    } else {
        ///
        /// `bin32`
        ///
        /// bin 32 stores a byte array whose length is upto (2^32)-1 bytes:
        /// +--------+--------+--------+--------+--------+========+
        /// |  0xc6  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|  data  |
        /// +--------+--------+--------+--------+--------+========+
        ///
        /// ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a 32-bit big-endian unsigned integer which represents
        /// `the length of data`
        return Data([0xc6] + pack(count, divided: 4)) + value
    }
}

private func encode(array value: [MsgPackObject]) throws -> Data {
    fatalError()
}

private func encode(map dict: [MsgPackObject: MsgPackObject]) throws -> Data {
    let count = UInt64(dict.count)
    
    guard count < 0xffff_ffff else {
        throw MsgPackEncodeError.overflow
    }
    
    let prefix: Data
    if count <= 15 {
        ///
        /// `fixmap`
        ///
        /// fixmap stores a map whose length is upto 15 elements
        /// +--------+~~~~~~~~~~~~~~~~~+
        /// |1000XXXX|   N*2 objects   |
        /// +--------+~~~~~~~~~~~~~~~~~+
        ///
        /// XXXX is a 4-bit unsigned integer which represents a size of map
        prefix = Data([0x80 | UInt8(count)])
        
    } else if count < 0xffff {
        ///
        /// `map16`
        ///
        /// map 16 stores a map whose length is upto (2^16)-1 elements
        /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
        /// |  0xde  |YYYYYYYY|YYYYYYYY|   N*2 objects   |
        /// +--------+--------+--------+~~~~~~~~~~~~~~~~~+
        ///
        /// YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents a size of map
        prefix = Data([0xde] + pack(count, divided: 2))
        
    } else {
        ///
        /// `map32`
        ///
        /// map 32 stores a map whose length is upto (2^32)-1 elements
        /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
        /// |  0xdf  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|   N*2 objects   |
        /// +--------+--------+--------+--------+--------+~~~~~~~~~~~~~~~~~+
        ///
        /// ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a 32-bit big-endian unsigned integer which represents
        /// a size of map
        prefix = Data([0xdf] + pack(count, divided: 4))
    }
    
    let postfix = try dict.reduce(Data()){ (list, elem) in
        list + (try elem.key.encode()) + (try elem.value.encode())
    }
    
    return prefix + postfix
}

private func encode(type: Int8, data: Data) throws -> Data {
    let count = UInt64(data.count)
    
    guard count < 0xffff_ffff else {
        throw MsgPackEncodeError.overflow
    }
    
    let type = UInt8(bitPattern: type)
    if count == 1 {
        ///
        /// `fixext1`
        ///
        /// fixext 1 stores an integer and a byte array whose length is 1 byte
        /// +--------+--------+--------+
        /// |  0xd4  |  type  |  data  |
        /// +--------+--------+--------+
        ///
        /// type is a signed 8-bit signed integer
        return Data([0xd4, type]) + data
        
    } else if count == 2 {
        ///
        /// `fixext2`
        ///
        /// fixext 2 stores an integer and a byte array whose length is 2 bytes
        /// +--------+--------+--------+--------+
        /// |  0xd5  |  type  |       data      |
        /// +--------+--------+--------+--------+
        ///
        /// type is a signed 8-bit signed integer
        return Data([0xd5, type]) + data
        
    } else if count == 4 {
        ///
        /// `fixext4`
        ///
        /// fixext 4 stores an integer and a byte array whose length is 4 bytes
        /// +--------+--------+--------+--------+--------+--------+
        /// |  0xd6  |  type  |                data               |
        /// +--------+--------+--------+--------+--------+--------+
        ///
        /// type is a signed 8-bit signed integer
        return Data([0xd6, type]) + data
        
    } else if count == 8 {
        ///
        /// `fixext8`
        ///
        /// fixext 8 stores an integer and a byte array whose length is 8 bytes
        /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
        /// |  0xd7  |  type  |                                  data                                 |
        /// +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
        ///
        /// type is a signed 8-bit signed integer
        return Data([0xd7, type]) + data
        
    } else if count == 16 {
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
        return Data([0xd8, type]) + data
        
    } else if count < 0xff {
        ///
        /// `ext8`
        ///
        /// ext 8 stores an integer and a byte array whose length is upto (2^8)-1 bytes:
        /// +--------+--------+--------+========+
        /// |  0xc7  |XXXXXXXX|  type  |  data  |
        /// +--------+--------+--------+========+
        ///
        /// type is a signed 8-bit signed integer
        /// XXXXXXXX is a 8-bit unsigned integer which represents a length of data
        return Data([0xc7, UInt8(count), type]) + data
        
    } else if count < 0xffff {
        ///
        /// `ext16`
        ///
        /// ext 16 stores an integer and a byte array whose length is upto (2^16)-1 bytes:
        /// +--------+--------+--------+--------+========+
        /// |  0xc8  |YYYYYYYY|YYYYYYYY|  type  |  data  |
        /// +--------+--------+--------+--------+========+
        ///
        /// type is a signed 8-bit signed integer
        /// YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents a length of data
        return Data([0xc8] + pack(count, divided: 2) + [type]) + data
        
    } else {
        ///
        /// `ext32`
        ///
        /// ext 32 stores an integer and a byte array whose length is upto (2^32)-1 bytes:
        /// +--------+--------+--------+--------+--------+--------+========+
        /// |  0xc9  |ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|ZZZZZZZZ|  type  |  data  |
        /// +--------+--------+--------+--------+--------+--------+========+
        ///
        /// type is a signed 8-bit signed integer
        /// ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a big-endian 32-bit unsigned integer which represents a length of data
        return Data([0xc9] + pack(count, divided: 4) + [type]) + data
    }
}

private func pack(_ value: UInt64, divided number: Int) -> [UInt8] {
    precondition(number > 0)
    
    return stride(from: 8 * (number - 1), through: 0, by: -8).map{
        UInt8(truncatingIfNeeded: value >> UInt64($0))
    }
}

