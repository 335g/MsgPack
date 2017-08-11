import Foundation

public enum MsgPackDecodeError: Error {
    case insufficient
    case invalid
}

extension MsgPack where Base == Data {
    private mutating func pullOutFirst() throws -> Data.Element {
        guard let first = base.first else {
            throw MsgPackDecodeError.insufficient
        }
        
        defer { base.removeFirst() }
        return first
    }
    
    private mutating func integer(numberUsed number: Data.IndexDistance) throws -> UInt64 {
        precondition(number > 0)
        
        guard let toIndex = base.index(base.startIndex, offsetBy: number, limitedBy: base.endIndex) else {
            throw MsgPackDecodeError.insufficient
        }
        
        defer { base.removeSubrange(base.startIndex..<toIndex) }
        return self.base[base.startIndex..<toIndex].reduce(0){ all, value in
            all << 8 | UInt64(value)
        }
    }
    
    private mutating func string(numberUsed number: Data.IndexDistance) throws -> String {
        precondition(number >= 0)
        
        guard let toIndex = base.index(base.startIndex, offsetBy: number, limitedBy: base.endIndex) else {
            throw MsgPackDecodeError.insufficient
        }
        
        guard let str = String(data: base[base.startIndex..<toIndex], encoding: .utf8) else {
            throw MsgPackDecodeError.invalid
        }
        
        defer { base.removeSubrange(base.startIndex..<toIndex) }
        return str
    }
    
    private mutating func data(numberUsed number: Data.IndexDistance) throws -> Data {
        precondition(number > 0)
        
        guard let toIndex = base.index(base.startIndex, offsetBy: number, limitedBy: base.endIndex) else {
            throw MsgPackDecodeError.insufficient
        }
        
        defer { base.removeSubrange(base.startIndex..<toIndex) }
        return base.subdata(in: base.startIndex..<toIndex)
    }
    
    private mutating func array(with number: Data.IndexDistance) throws -> [MsgPackObject] {
        return try (0..<number).map{ _ in try self.object() }
    }
    
    private mutating func dict(with number: Data.IndexDistance) throws -> [MsgPackObject : MsgPackObject] {
        let elements = try (0..<number).map{ _ in (try self.object(), try self.object()) }
        return elements.reduce(into: [MsgPackObject : MsgPackObject]()){ $0[$1.0] = $1.1 }
    }
    
    public mutating func object() throws -> MsgPackObject {
        let prefix = try pullOutFirst()
        
        switch prefix {
        case 0x00...0x7f:   // positive fixint
            return .uint(UInt64(prefix))
            
        case 0x80...0x8f:   // fixmap
            let dict = try self.dict(with: Int(prefix - 0x80))
            return .map(dict)
            
        case 0x90...0x9f:   // fixarray
            let array = try self.array(with: Int(prefix - 0x90))
            return .array(array)
            
        case 0xa0...0xbf:   // fixstr
            let string = try self.string(numberUsed: Int(prefix - 0xa0))
            return .string(string)
            
        case 0xc0: // nil
            return .nil(nil)
            
        case 0xc2: // false
            return .bool(false)
            
        case 0xc3: // true
            return .bool(true)
            
        case 0xc4...0xc6: // binary
            let offset = Int(try integer(numberUsed: 1 << Int(prefix - 0xc4)))
            let data = try self.data(numberUsed: offset)
            
            return .binary(data)
            
        case 0xc7...0xc9: // ext
            let offset = 1 << Int(prefix - 0xc7)
            let count = Int(try integer(numberUsed: offset))
            let prefix = try pullOutFirst()
            let type = Int8(bitPattern: prefix)
            let data = try self.data(numberUsed: count)
            
            return .ext(type, data)
            
        case 0xca: // float32
            let value = try integer(numberUsed: 4)
            return .float(Float(bitPattern: UInt32(truncatingIfNeeded: value)))
            
        case 0xcb: // float64
            let value = try integer(numberUsed: 8)
            return .double(Double(bitPattern: value))
            
        case 0xcc...0xcf: // uint8, uint16, uint32, uint64
            let uint = try integer(numberUsed: 1 << (Int(prefix) - 0xcc))
            return .uint(uint)
            
        case 0xd0: // int8
            let byte = Int8(bitPattern: try pullOutFirst())
            return .int(Int64(byte))
            
        case 0xd1: // int16
            let bytes = try integer(numberUsed: 2)
            let bit = Int16(bitPattern: UInt16(truncatingIfNeeded: bytes))
            return .int(Int64(bit))
            
        case 0xd2: //int32
            let bytes = try integer(numberUsed: 4)
            let bit = Int32(bitPattern: UInt32(truncatingIfNeeded: bytes))
            return .int(Int64(bit))
            
        case 0xd3: // int64
            let bytes = try integer(numberUsed: 8)
            let bit = Int64(bitPattern: bytes)
            return .int(bit)
            
        case 0xd4...0xd8: // fixext1, fixext2, fixext4, fixext8, fixext16
            let type = Int8(bitPattern: try pullOutFirst())
            let data = try self.data(numberUsed: 1 << Int(prefix - 0xd4))
            return .ext(type, data)
            
        case 0xd9...0xdb: // str8, str16, str32
            let count = try integer(numberUsed: 1 << Int(prefix - 0xd9))
            let str = try string(numberUsed: Int(count))
            return .string(str)
            
        case 0xdc...0xdd: // array16, array32
            let count = try integer(numberUsed: 1 << Int(prefix - 0xdb))
            let arr = try array(with: Int(count))
            return .array(arr)
            
        case 0xde...0xdf: // map16, map32
            let count = try integer(numberUsed: 1 << Int(prefix - 0xdd))
            let map = try dict(with: Int(count))
            return .map(map)
            
        case 0xe0...0xff: // negative fixint
            return .int(Int64(prefix) - 0x100)
            
        default: // `0xc1` is never used
            throw MsgPackDecodeError.insufficient
        }
    }
}
