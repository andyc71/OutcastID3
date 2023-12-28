//
//  File.swift
//  
//
//  Created by Andy on 26/12/2023.
//

import Foundation

extension Data {
    
    var bits: [Bit] {
        var returnBits = [Bit]()
        for index in 0..<self.count {
            let byte = self[index]
            let bits = getBits(fromBytes: byte)
            returnBits.append(contentsOf: bits)
        }
        return returnBits
    }
    
    func getBits<T: FixedWidthInteger>(fromBytes bytes: T) -> [Bit] {
        // Make variable
        var bytes = bytes
        // Fill an array of bits with zeros to the fixed width integer length
        var bits = [Bit](repeating: .zero, count: T.bitWidth)
        // Run through each bit (LSB first)
        for counter in 0..<T.bitWidth {
            let currentBit = bytes & 0x01
            if currentBit != 0 {
                bits[counter] = .one
            }
            
            bytes >>= 1
        }
        
        return bits
    }
    
}

enum Bit: UInt8, CustomStringConvertible {
case zero, one
    
    var description: String {
        switch self {
        case .one:
            return "1"
        case .zero:
            return "0"
        }
    }
}


extension FixedWidthInteger {
    var bits: [Bit] {
        // Make variable
        var bytes = self
        // Fill an array of bits with zeros to the fixed width integer length
        var bits = [Bit](repeating: .zero, count: self.bitWidth)
        // Run through each bit (LSB first)
        for counter in 0..<self.bitWidth {
            let currentBit = bytes & 0x01
            if currentBit != 0 {
                bits[counter] = .one
            }
            
            bytes >>= 1
        }
        
        return bits
    }
}

extension Array where Element == Bit {
    var asString: String {
        var str = ""
        for index in 0..<self.count {
            let byte = self[index]
            if index % 8 == 0 {
                str += " "
            }
            str += byte.description
        }
        return str
    }
}
