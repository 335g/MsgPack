//
//  Object.swift
//  MsgPack
//
//  Created by Yoshiki Kudo on 2017/09/16.
//

import Foundation

public enum MsgPackObject {
    case int(Int64)
    case uint(UInt64)
    case `nil`
    case bool(Bool)
    case float(Float)
    case double(Double)
    case string(String)
    case binary(Data)
    case array([MsgPackObject])
    case map([MsgPackObject: MsgPackObject])
    case ext(Int8, Data)
}

extension MsgPackObject: Equatable {
    public static func == (lhs: MsgPackObject, rhs: MsgPackObject) -> Bool {
        switch (lhs, rhs) {
        case (.bool(let l), .bool(let r)):      return l == r
        case (.float(let l), .float(let r)):    return l == r
        case (.double(let l), .double(let r)):  return l == r
        case (.string(let l), .string(let r)):  return l == r
        case (.binary(let l), .binary(let r)):  return l == r
        case (.array(let l), .array(let r)):    return l == r
        case (.map(let l), .map(let r)):        return l == r
            
        case (.nil, .nil):
            return true
            
        case (.int(let l), _):
            switch rhs {
            case .int(let r):
                return l == r
            case .uint(let r) where l > 0:
                return UInt64(l) == r
            default:
                return false
            }
        case (.uint(let l), _):
            switch rhs {
            case .int(let r) where r > 0:
                return l == UInt64(r)
            case .uint(let r):
                return l == r
            default:
                return false
            }
        case (.ext(let lType, let lData), .ext(let rType, let rData)):
            return lType == rType && lData == rData
            
        default:
            // TODO: impl
            return false
        }
    }
}

extension MsgPackObject: Hashable {
    public var hashValue: Int {
        switch self {
        case .nil:              return 0
        case .bool(let x):      return x.hashValue
        case .int(let x):       return x.hashValue
        case .uint(let x):      return x.hashValue
        case .float(let x):     return x.hashValue
        case .double(let x):    return x.hashValue
        case .string(let x):    return x.hashValue
        case .binary(let x):    return x.count
        case .array(let x):     return x.count
        case .map(let x):       return x.count
            
        case .ext(let t, let d):
            return 31 &* t.hashValue &+ d.count
        }
    }
}

extension MsgPackObject: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .nil
    }
}

extension MsgPackObject: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension MsgPackObject: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension MsgPackObject: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension MsgPackObject: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int64) {
        self = .int(value)
    }
}

extension MsgPackObject: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: MsgPackObject...) {
        self = .array(elements)
    }
}

extension MsgPackObject: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (MsgPackObject, MsgPackObject)...) {
        self = .map(elements.reduce(into: [:]){ $0[$1.0] = $1.1 })
    }
}
