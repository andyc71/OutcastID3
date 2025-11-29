//
//  Data+String.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 25/11/18.
//

import Foundation

extension Data {
    public enum StringTerminator {
        case single
        case double
        
        var data: Data {
            switch self {
            case .single: return Data([ 0x0 ])
            case .double: return Data([ 0x0, 0x0 ])
            }
        }
    }
    
    func readString(offset: inout Int,
                    encoding: String.Encoding,
                    terminator: StringTerminator) -> String? {
        var bytes: [UInt8] = []
        let count = self.count

        switch terminator {
        case .single:
            while offset < count {
                let b = self[offset]
                if b == 0x00 {
                    offset += 1       // consume terminator
                    break
                }
                bytes.append(b)
                offset += 1
            }

        case .double:
            // UTF-16-style: consume in 2-byte units
            while offset + 1 < count {
                let lo = self[offset]
                let hi = self[offset + 1]

                // terminator 00 00
                if lo == 0x00 && hi == 0x00 {
                    offset += 2      // consume terminator pair
                    break
                }

                bytes.append(lo)
                bytes.append(hi)
                offset += 2
            }
        }

        return decodeID3String(bytes: bytes, defaultEncoding: encoding)
    }

    private func decodeID3String(bytes: [UInt8],
                                 defaultEncoding: String.Encoding) -> String? {
        var bytes = bytes
        var encoding = defaultEncoding

        // --- BOM handling ---
        if bytes.count >= 2 {
            let b0 = bytes[0]
            let b1 = bytes[1]

            // UTF-16LE BOM
            if b0 == 0xFF && b1 == 0xFE {
                encoding = .utf16LittleEndian
                bytes.removeFirst(2)
            }
            // UTF-16BE BOM
            else if b0 == 0xFE && b1 == 0xFF {
                encoding = .utf16BigEndian
                bytes.removeFirst(2)
            }
        }

        guard var string = String(bytes: bytes, encoding: encoding) else {
            return nil
        }

        // Safety net: strip leading U+FEFF if still present
        if let first = string.first, first == "\u{feff}" {
            string.removeFirst()
        }

        return string
    }
}
