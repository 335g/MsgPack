//
//  Error.swift
//  MsgPack
//
//  Created by Yoshiki Kudo on 2017/09/16.
//

import Foundation

public enum MsgPackEncodeError: Error {
    case overflow
}

public enum MsgPackDecodeError: Error {
    case outOfRange
    case insufficient
    case extraData
    case invalid
    case overflow
}
