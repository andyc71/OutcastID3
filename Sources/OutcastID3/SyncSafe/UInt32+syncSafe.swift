//
//  UInt32+syncSafe.swift
//
//
//  Created by Andy on 26/12/2023.
//

import Foundation

extension UInt32 {
    
    var syncSafe: UInt32 {
        var encodedInteger: UInt32 = 0
        var mask: UInt32 = 0x7F
        var partiallyEncodedInteger = self
        while mask != 0x7FFFFFFF {
            encodedInteger = partiallyEncodedInteger & ~mask
            encodedInteger = encodedInteger << 1
            encodedInteger = encodedInteger | partiallyEncodedInteger & mask
            mask = ((mask + 1) << 8) - 1
            partiallyEncodedInteger = encodedInteger
        }
        return encodedInteger.bigEndian
    }
    
    var toNonSyncSafe: UInt32 {
        
        let syncSafeValue = self.byteSwapped
        
        var decodedInteger: UInt32 = 0
        var mask: UInt32 = 0x7F000000

        while mask != 0 {
            decodedInteger = decodedInteger >> 1
            decodedInteger = decodedInteger | syncSafeValue & mask
            mask >>= 8
        }
        return decodedInteger
    }
    
}
 
