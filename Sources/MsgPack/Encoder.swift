
import Foundation

public struct MsgPackEncoder {
    private final class _Encoder: Encoder {
        let userInfo: [CodingUserInfoKey : Any]
        var codingPath: [CodingKey]
        var storage: MsgPackEncodingStorage
        
        init(userInfo: [CodingUserInfoKey : Any], codingPath: [CodingKey] = []) {
            self.userInfo = userInfo
            self.codingPath = codingPath
            self.storage = MsgPackEncodingStorage()
        }
        
        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            fatalError()
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            fatalError()
        }
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            fatalError()
        }
    }
    
    public enum EncodeError: Error {
        case noValue
    }
    
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    public init() {}
    
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = _Encoder(userInfo: userInfo)
        try value.encode(to: encoder)
        
        guard let topValue = encoder.storage.container else {
            throw EncodeError.noValue
        }
        
        return topValue.packedData
    }
}

fileprivate struct MsgPackEncodingStorage {
    private(set) fileprivate var container: MsgPackFormat?
    
    fileprivate mutating func pushKeyedContainer() {
        
    }
}

