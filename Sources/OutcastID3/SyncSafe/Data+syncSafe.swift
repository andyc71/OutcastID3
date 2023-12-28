//
//  Data+syncSafe.swift
//
//
//  Created by Andy on 26/12/2023.
//

import Foundation

extension Data {
    
    var isSyncSafeUInt32: Bool {
        
        /*
         A 4byte synchronization safe integer is stored such that the MSB of each byte, that is the 7th bit (count starts from 0), is always zero. So a synchronization safe integer always have the 7th bit of each byte 0. Note that the relative ordering of the bytes are as big-endian, that is the most significant byte is on higher address. Check This blog post : Little and Big Endian conversion and Wikipedia link for more information on endian.

         So for example a 4 byte integer 0x000000FF whose binary representation is 00000000 00000000 00000000 11111111 will be represented as 00000000 00000000 00000001 01111111 in the synchronization safe format. If any of the MSB of a byte is 1, then it is shifted above on the next significant byte. Check the below examples.

         0x0000FFFF =              : 00000000 00000000 11111111 11111111
         synch-safe representation : 00000000 00000011 01111111 01111111

         0x04ADD3AC =              : 00000100 10101101 11010011 10101100
         synch-safe representation : 00100101 00110111 00100111 00101100
         */
        
        //print("****BITS: \(self.bits.asString)")
        
        return (self[0] & (1 << 0x7)) == 0 &&
                (self[1] & (1 << 0x7)) == 0 &&
                (self[2] & (1 << 0x7)) == 0 &&
                (self[3] & (1 << 0x7)) == 0
    }
    
    /// Reads a big-endian sync safe UInt32 and converts it to a native (litte-endian)
    /// non-sync safe Uint32.
    /// 4 bytes, each of 7 bits
    var syncSafeUInt32: UInt32? {
        guard self.count == 4 else {
            return nil
        }
        
        let byte1 = UInt32(self[0] & 0x7f) << 21
        let byte2 = UInt32(self[1] & 0x7f) << 14
        let byte3 = UInt32(self[2] & 0x7f) << 7
        let byte4 = UInt32(self[3] & 0x7f)
        
        return byte1 + byte2 + byte3 + byte4
    }
    
    /// Reads a big-endian UInt32 and converts it to a native (litte-endian)
    /// Uint32.
    var toUInt32: UInt32? {
        guard self.count == 4 else {
            return nil
        }
        
        var val: UInt32 = 0
        (self as NSData).getBytes(&val, range: NSRange(location: 0, length: self.count))
        
        return val.byteSwapped
    }
}
