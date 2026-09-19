//
//  String.swift
//  
//
//  Created by MainasuK on 2022/11/18.
//

import Foundation
import CryptoKit


extension String {
    /*
     * Convert to String from Tuple
     */
    public static func fromTuple<T>(tuple: T) -> String? {
        let reflection = Mirror(reflecting: tuple)
        var arr: [Int8] = []
        for child in reflection.children {
            if let value = child.value as? Int8 {
                arr.append(value)
            }
        }
        // `String(cString:)` requires the buffer to stay alive for the call. Wrapping it
        // in `withUnsafeBufferPointer` keeps the array's storage valid until the closure
        // returns; `UnsafePointer(arr)` on its own is a dangling pointer.
        return arr.withUnsafeBufferPointer { buffer in
            guard let base = buffer.baseAddress else { return "" }
            return String(cString: base)
        }
    }
    /*
     * Convert String to Tupple Fixed size
     */
    public func toTuple<T>(tuple: inout T, size: Int) -> () {
        let name: [UInt8] = [UInt8](self.utf8)
        withUnsafeMutablePointer(to: &tuple, { (ptr) -> () in
            memset(ptr, 0, size)
            memcpy(ptr, name, min(name.count, size))
            assert(name.count < size)
            return
        })
    }
}

// let machine = withUnsafeBytes(of: &utsInfo.machine) { (rawPtr) -> String in
//     let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
//     return String(cString: ptr)
// }
// print(machine) // → x86_64

private func hexString(_ iterator: Array<UInt8>.Iterator) -> String {
    return iterator.map { String(format: "%02x", $0) }.joined()
}

extension Data {

    public var sha256: String {
        return hexString(SHA256.hash(data: self).makeIterator())
    }

}
