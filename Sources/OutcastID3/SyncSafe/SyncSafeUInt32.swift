//
//  SyncSafeUInt32.swift
//  
//
//  Created by Andy on 27/12/2023.
//

import Foundation

// Define a custom error for invalid data
enum SyncSafeConversionError: Error {
    case invalidData
}

// Wrapper struct around UInt32 with Big Endian and sync-safe properties
struct SyncSafeUInt32 {
    var value: UInt32 = 0
    
    static var max: UInt32 = 0x0FFFFFFF // 268435455
    
    // Initializer to convert a non-sync safe UInt32 to sync-safe format
    init?(nonSyncSafeValue: UInt32) {
        guard let value = toSyncSafe(nonSyncSafeValue) else {
            return nil
        }
        self.value = value
    }
    
    func toSyncSafe(_ nonSyncSafeValue: UInt32) -> UInt32? {
        
        // Ensure the value is within the valid range
        guard nonSyncSafeValue <= SyncSafeUInt32.max else {
            // Handle this case differently based on requirements (e.g., throw an error)
            return nil
        }
        var encodedInteger: UInt32 = 0
        var mask: UInt32 = 0x7F
        var partiallyEncodedInteger = nonSyncSafeValue
        while mask != 0x7FFFFFFF {
            encodedInteger = partiallyEncodedInteger & ~mask
            encodedInteger = encodedInteger << 1
            encodedInteger = encodedInteger | partiallyEncodedInteger & mask
            mask = ((mask + 1) << 8) - 1
            partiallyEncodedInteger = encodedInteger
        }
        return encodedInteger.bigEndian
    }
    
    // Initializer to convert from Data containing sync-safe UInt32 with big endian encoding
    init(data: Data) throws {
        guard data.count == 4 else {
            throw SyncSafeConversionError.invalidData
        }

        var bigEndianValue: UInt32 = 0
        _ = withUnsafeMutableBytes(of: &bigEndianValue) { data.copyBytes(to: $0) }
                
        self.value = bigEndianValue
    }
    
    /// Convert SyncSafeUInt32 to non-sync safe UInt32
    func toNonSyncSafe() -> UInt32 {
        let value = value.byteSwapped

        var decodedInteger: UInt32 = 0
        var mask: UInt32 = 0x7F000000

        while mask != 0 {
            decodedInteger = decodedInteger >> 1
            decodedInteger = decodedInteger | value & mask
            mask >>= 8
        }

        return decodedInteger
    }

    /// Convert SyncSafeUInt32 to Data using Big Endian sync safe encoding
    func toData() -> Data {
        var currentUInt32 = self
        let bytes = withUnsafePointer(to: &currentUInt32) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt32>.size) {
                Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<UInt32>.size))
            }
        }
        return Data(bytes: bytes, count: bytes.count)
    }
}
