//
//  SyncSafeTests.swift
//
//
//  Created by Andy on 26/12/2023.
//

import XCTest
import SnapshotTesting
@testable import OutcastID3


// Unit tests
class SyncSafeConversionTests2: XCTestCase {
    func testConversion() {
        // Test case: Convert various values to and from sync-safe format
        
        let testValues: [UInt32] = [
            0x00000000,
            0xF,        //15
            0xFF,       //255
            0xFFFF,     //65535
            0xFFFFFF,   //16777215
            0xFFFFFFFF, //4294967295
            0x1,        //1
            0x10,       //16
            0x11,       //17
            0x111,      //273
            0x1111,     //4369
            0x11111,    //69905
            0x111111,   //1118481
            0x1111111,  //17895697
            0x11111111, //286331153
            0x01020304, //16909060
            0x12345678, //305419896
            0xABCD5678, //0xABCD5678
        ]
        
        
        for originalValue in testValues {
            if originalValue > SyncSafeUInt32.max {
                XCTAssertNil(SyncSafeUInt32(nonSyncSafeValue: originalValue))
            }
            else {
                let syncSafeValue = SyncSafeUInt32(nonSyncSafeValue: originalValue)!
                
                // Convert sync-safe value back to non-sync safe
                let convertedValue = syncSafeValue.toNonSyncSafe()
                
                // Print bit patterns
                let originalValueHexString = String(format:"%02X", originalValue)
                print()
                print("Original Value: Hex: 0x\(originalValueHexString) Decimal: \(originalValue)")
                print("Original Value Bit Pattern: \(originalValue.bitPatternString())")
                print("Sync-Safe Value Bit Pattern: \(syncSafeValue.bitPatternString())")
                print("Converted Value Bit Pattern: \(convertedValue.bitPatternString())")
                
                // Check if the conversion is correct
                XCTAssertEqual(originalValue, convertedValue, "Conversion to and from sync-safe format failed")
                
                // Test init(data:) and toData()
                            do {
                                let dataRepresentation = syncSafeValue.toData()
                                let reconstructedValue = try SyncSafeUInt32(data: dataRepresentation)
                                print("Reconstructed Value Bit Pattern: \(reconstructedValue.bitPatternString())")
                                
                                XCTAssertEqual(syncSafeValue.value, reconstructedValue.value, "init(data:) and toData() failed")
                            } catch {
                                XCTFail("Error: \(error)")
                            }
            }
        }
    }
        
        func testInvalidData() {
            // Test case: Try to initialize SyncSafeUInt32 with invalid data
            let invalidData = Data([0x80, 0x80, 0x80]) // Invalid sync-safe data
            
            XCTAssertThrowsError(try SyncSafeUInt32(data: invalidData)) { error in
                XCTAssertEqual(error as? SyncSafeConversionError, SyncSafeConversionError.invalidData)
            }
        }
    
    func testBinaryStringFormatting() {
            // Test case: Binary string formatting for various values
            
            // Test value: 0x00000000
            XCTAssertEqual(String(0x00000000, radix: 2).spacedAndPadded(by: 8), "00000000 00000000 00000000 00000000")
            
            // Test value: 0xFFFFFFFF
            XCTAssertEqual(String(0xFFFFFFFF, radix: 2).spacedAndPadded(by: 8), "11111111 11111111 11111111 11111111")
            
            // Test value: 0x12345678
            XCTAssertEqual(String(0x12345678, radix: 2).spacedAndPadded(by: 8), "00010010 00110100 01010110 01111000")
            
            // Test value: 0xABCD5678
            XCTAssertEqual(String(0xABCD5678, radix: 2).spacedAndPadded(by: 8), "10101011 11001101 01010110 01111000")
            
            // Test value: 0x01020304
            XCTAssertEqual(String(0x01020304, radix: 2).spacedAndPadded(by: 8), "00000001 00000010 00000011 00000100")
        }
}
    
// Extension on UInt32 to print bit pattern with spaces (little-endian)
extension UInt32 {
    func bitPatternString() -> String {
        return String(self, radix: 2).spacedAndPadded(by: 8)
    }
}

// Extension on SyncSafeUInt32 to print bit pattern with spaces (big-endian)
extension SyncSafeUInt32 {
    func bitPatternString() -> String {
        return value.bitPatternString()
        //return value.byteSwapped.bitPatternString()
    }
}

// Helper extension to add spaces between each byte in a binary string and pad to 8-bit boundary with zero padding
extension String {
    func spacedAndPadded(by distance: Int) -> String {
        let bitCount = 32 // Assuming UInt32 has 32 bits
        var paddedString = self

        // Add zero padding
        while paddedString.count % bitCount != 0 {
            paddedString = "0" + paddedString
        }

        let spacedString = paddedString.enumerated().map { index, char in
            let shouldAddSpace = index > 0 && (index % 8 == 0)
            return (shouldAddSpace ? " " : "") + String(char)
        }.joined()

        return spacedString
    }
}
