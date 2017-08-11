import Foundation

public protocol MsgPackCompatible {
    associatedtype MsgPackCompatibleType
    
    var msgpack: MsgPackCompatibleType { get }
}

public struct MsgPack<Base> {
    var base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
}

public extension MsgPackCompatible {
    public var msgpack: MsgPack<Self> {
        return MsgPack(self)
    }
}

extension Data: MsgPackCompatible {}

