//
//  Decode.swift
//  MsgPack
//
//  Created by Yoshiki Kudo on 2017/09/17.
//

import Foundation

extension MsgPackObject {
    public init(data: Data) throws {
        var index = data.startIndex
        self = try data.object(from: &index)
        
        /// must be `index == data.endIndex`
        if index < data.endIndex {
            throw MsgPackDecodeError.extraData
        }
    }
}

extension Data {
    private func element(at index: inout Index) throws -> Data.Element {
        guard startIndex <= index && index < endIndex else {
            throw MsgPackDecodeError.outOfRange
        }
        
        defer { index = self.index(after: index) }
        return self[index]
    }
    
    private func integer(from: inout Index, number: IndexDistance) throws -> UInt64 {
        precondition(number > 0)
        
        guard let to = index(from, offsetBy: number, limitedBy: endIndex) else {
            throw MsgPackDecodeError.insufficient
        }
        
        defer { from = to }
        return self[from..<to].reduce(0){ all, value in
            all << 8 | UInt64(value)
        }
    }
    
    private func string(from: inout Index, number: IndexDistance) throws -> String {
        precondition(number > 0)
        
        guard let to = index(from, offsetBy: number, limitedBy: endIndex) else {
            throw MsgPackDecodeError.insufficient
        }
        guard let str = String(data: self[from..<to], encoding: .utf8) else {
            throw MsgPackDecodeError.invalid
        }
        
        defer { from = to }
        return str
    }
    
    private func data(from: inout Index, number: IndexDistance) throws -> Data {
        precondition(number > 0)
        
        guard let to = index(from, offsetBy: number, limitedBy: endIndex) else {
            throw MsgPackDecodeError.insufficient
        }
        
        defer { from = to }
        return subdata(in: from..<to)
    }
    
    private func array(from: inout Index, number: IndexDistance) throws -> [MsgPackObject] {
        precondition(number > 0)
        
        guard number < 0xffff_ffff else {
            throw MsgPackDecodeError.overflow
        }
        
        return try (0..<number).map{ _ in try object(from: &from) }
    }
    
    private func dict(from: inout Index, number: IndexDistance) throws -> [MsgPackObject: MsgPackObject] {
        precondition(number > 0)
        
        guard number < 0xffff_ffff else {
            throw MsgPackDecodeError.overflow
        }
        
        return try (0..<number).reduce(into: [:]){ dict, _ in
            let key = try object(from: &from)
            let value = try object(from: &from)
            dict[key] = value
        }
    }
    
    fileprivate func object(from index: inout Index) throws -> MsgPackObject {
        let prefix = try element(at: &index)
        
        switch prefix {
        case 0x00...0x7f:
            /// positive fixint
            return .uint(UInt64(prefix))
            
        case 0x80...0x8f:
            /// fixmap
            let dict = try self.dict(from: &index, number: Int(prefix - 0x80))
            return .map(dict)
            
        case 0x90...0x9f:
            /// fixarray
            let array = try self.array(from: &index, number: Int(prefix - 0x90))
            return .array(array)
            
        case 0xa0...0xbf:
            /// fixstr
            let string = try self.string(from: &index, number: Int(prefix - 0xa0))
            return .string(string)
            
        case 0xc0:
            /// nil
            return .nil
            
        case 0xc1:
            /// ** NOT USED **
            throw MsgPackDecodeError.insufficient
            
        case 0xc2:
            /// false
            return .bool(false)
            
        case 0xc3:
            /// true
            return .bool(true)
            
        case 0xc4...0xc6:
            /// binary
            let offset = Int(try integer(from: &index, number: 1 << Int(prefix - 0xc4)))
            let data = try self.data(from: &index, number: offset)
            return .binary(data)
            
        case 0xc7...0xc9:
            /// ext
            let offset = 1 << Int(prefix - 0xc7)
            let count = Int(try integer(from: &index, number: offset))
            let prefix = try element(at: &index)
            let type = Int8(bitPattern: prefix)
            let data = try self.data(from: &index, number: count)
            
            return .ext(type, data)
        
        case 0xca:
            /// float32
            let value = try integer(from: &index, number: 4)
            return .float(Float(bitPattern: UInt32(truncatingIfNeeded: value)))
            
        case 0xcb:
            /// float64
            let value = try integer(from: &index, number: 8)
            return .double(Double(bitPattern: value))
            
        case 0xcc...0xcf:
            /// uint8, uint16, uint32, uint64
            let value = try integer(from: &index, number: 1 << (Int(prefix) - 0xcc))
            return .uint(value)
            
        case 0xd0:
            /// int8
            let bit = Int8(bitPattern: try element(at: &index))
            return .int(Int64(bit))
            
        case 0xd1:
            /// int16
            let byte = try integer(from: &index, number: 2)
            let bit = Int16(bitPattern: UInt16(truncatingIfNeeded: byte))
            return .int(Int64(bit))
            
        case 0xd2:
            /// int32
            let byte = try integer(from: &index, number: 4)
            let bit = Int32(bitPattern: UInt32(truncatingIfNeeded: byte))
            return .int(Int64(bit))
            
        case 0xd3:
            /// int64
            let byte = try integer(from: &index, number: 8)
            let bit = Int64(bitPattern: byte)
            return .int(bit)
            
        case 0xd4...0xd8:
            /// fixext1, fixext2, fixext4, fixext8, fixext16
            let type = Int8(bitPattern: try element(at: &index))
            let data = try self.data(from: &index, number: 1 << Int(prefix - 0xd4))
            return .ext(type, data)
            
        case 0xd9...0xdb:
            /// str8, str16, str32
            let count = try integer(from: &index, number: 1 << Int(prefix - 0xd9))
            let str = try string(from: &index, number: Int(count))
            return .string(str)
            
        case 0xdc...0xdd:
            /// array16, array32
            let count = try integer(from: &index, number: 1 << Int(prefix - 0xdc))
            let arr = try array(from: &index, number: Int(count))
            return .array(arr)
            
        case 0xde...0xdf:
            /// map16, map32
            let count = try integer(from: &index, number: 1 << Int(prefix - 0xde))
            let map = try dict(from: &index, number: Int(count))
            return .map(map)
            
        case 0xe0...0xff:
            /// negative fixint
            return .int(Int64(prefix) - 0x100)
            
        default:
            /// **  WILL NOT REACH HERE **
            /// ** The compiler is in a good mood **
            throw MsgPackDecodeError.insufficient
        }
    }
}
