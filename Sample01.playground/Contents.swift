
import MsgPack

let a = Int(1)
let b1 = UInt64(truncatingIfNeeded: a)
UInt64.max
//0b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111110
let b2 = UInt32(truncatingIfNeeded: a)

let b3 = UInt64(a)
