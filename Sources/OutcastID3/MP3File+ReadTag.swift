//
//  MP3File+ReadTag.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 30/11/18.
//

import Foundation

public extension OutcastID3.MP3File {
    enum ReadError: Swift.Error {
        case tagNotFound
        case tagVersionNotFound
        case tagSizeNotFound
        case unsupportedTagVersion
        case corruptedFile
        case corruptedFrame
        case corruptedHeader
        case nonSyncSafeFrameSize
    }
    
    // TODO: Handle extended header properly
    
    func readID3Tag() throws -> TagProperties {
        let fileHandle = try FileHandle(forReadingFrom: self.localUrl)
        
        defer {
            // Will run after function finishes, even for throws
            fileHandle.closeFile()
        }
        
        return try readID3Tag(fileHandle: fileHandle)
    }
    
    func readID3Tag(fileHandle: FileHandle) throws -> TagProperties {
        // Assumes the ID3 tag is at the start of the file.
        let startingByteOffset: UInt64 = 0
        
        fileHandle.seek(toFileOffset: startingByteOffset)
        
        let id3String = String(bytes: fileHandle.readData(ofLength: 3), encoding: .isoLatin1)
        
        guard id3String == "ID3" else {
            throw ReadError.tagNotFound
        }
        
        guard let versionNumber = fileHandle.readData(ofLength: 1).first else {
            throw ReadError.corruptedHeader
        }
        
        guard let version = OutcastID3.TagVersion(rawValue: versionNumber) else {
            throw ReadError.tagVersionNotFound
        }
        
        fileHandle.seek(toFileOffset: startingByteOffset + 6)
        
        let tagSizeBytes = fileHandle.readData(ofLength: 4)
        
        guard tagSizeBytes.count == 4 else {
            throw ReadError.tagSizeNotFound
        }
        
        // TODO: ID3v2.1 only uses 3 bytes
        
        guard let tagByteCount = tagSizeBytes.syncSafeUInt32 else {
            throw ReadError.tagSizeNotFound
        }
        
        fileHandle.seek(toFileOffset: UInt64(version.tagHeaderSizeInBytes))
        let tagData = fileHandle.readData(ofLength: Int(tagByteCount))
        
        let endingByteOffset = fileHandle.offsetInFile
        
        // Parse the tag data into frames
        let frames: [OutcastID3TagFrame] = try OutcastID3.ID3Tag.framesFromData(version: version, data: tagData, url: localUrl)
        
        let tag = OutcastID3.ID3Tag(
            version: version,
            frames: frames,
            url: localUrl
        )
        
        return TagProperties(
            tag: tag,
            startingByteOffset: startingByteOffset,
            endingByteOffset: endingByteOffset
        )
    }
}

struct FrameSize {
    var size: Int
    var isSyncSafe: Bool
}

extension OutcastID3.ID3Tag {
    
    static func framesFromData(version: OutcastID3.TagVersion, data: Data, url: URL? = nil) throws -> [OutcastID3TagFrame] {
        var ret: [OutcastID3TagFrame] = []
        var position = 0
        let count = data.count

        logDebug("ID3 tag version: \(version) in \(String(describing: url))")

        while position < count {
            // 🛑 Padding check: break if rest is all zero
            let remainingData = data[position...]
            if remainingData.allSatisfy({ $0 == 0 }) {
                logDebug("All remaining data is padding starting at position \(position). Stopping frame parse.")
                break
            }

            // Optional: detect 4 zero bytes (frame header length) as soft padding
            if remainingData.count >= 4 && data[position..<position+4].allSatisfy({ $0 == 0 }) {
                logDebug("Zeroed 4-byte block detected at position \(position). Likely padding. Stopping.")
                break
            }

            let oldPosition = position
            var frame: OutcastID3TagFrame?
            var lastError: Error?

            if version == .v2_4 {
                do {
                    frame = try frameFromData(version: version, data: data, position: &position, useSynchSafeFrameSize: true, throwOnError: true)
                } catch {
                    lastError = error
                }
            }

            if frame == nil {
                do {
                    frame = try frameFromData(version: version, data: data, position: &position, useSynchSafeFrameSize: false, throwOnError: true)
                } catch {
                    lastError = error
                }
            }

            if frame == nil && lastError != nil {
                OutcastID3.Logger.logWarning("Corrupt ID3 frame at position \(position) in \(String(describing: url)).")
                OutcastID3.Logger.logWarning("Error info: \(lastError!)")
            }

            if let frame {
                ret.append(frame)
            } else {
                if position > oldPosition {
                    continue
                } else {
                    // ❗️Fail-safe: no frame and position unchanged — stop to avoid infinite loop
                    break
                }
            }
        }

        return ret
    }
    
    static func frameFromData(version: OutcastID3.TagVersion, data: Data, position: inout Int, useSynchSafeFrameSize: Bool, throwOnError: Bool = false) throws -> OutcastID3TagFrame? {

        logFrameHeader(data: data, position: position)
        
        let frameSize: FrameSize
        do {
            frameSize = try determineFrameSize(data: data, position: position, version: version, syncSafeStrategy: useSynchSafeFrameSize ? .syncSafe : .nonSyncSafe)
        }
        catch {
            if throwOnError {
                throw OutcastID3.MP3File.ReadError.corruptedFrame
            }
            else {
                return nil
            }
        }
        
        let count = data.count
        
        guard position + frameSize.size <= count else {
            let availableLength = count - position
            let maxBytes = min(32, availableLength)
            let previewData = data.subdata(in: position ..< position + maxBytes)
            logWarning("Frame size too big position=\(position) + frameSize=\(frameSize.size) = \(position + frameSize.size), count=\(count), preview=\(previewData.hexEncodedString())")
            
            if throwOnError {
                throw OutcastID3.MP3File.ReadError.corruptedFrame
            } else {
                return nil
            }
        }

        let frameData = data.subdata(in: position ..< position + frameSize.size)

        guard let frame = OutcastID3.Frame.RawFrame.parse(version: version, data: frameData, useSynchSafeFrameSize: useSynchSafeFrameSize) else {
            logWarning("Failed to parse frame body using syncSafe = \(useSynchSafeFrameSize)")
            if throwOnError {
                throw OutcastID3.MP3File.ReadError.corruptedFrame
            } else {
                return nil
            }
        }

        position += frameSize.size

        logFrame(frameData: frameData, frame: frame, frameSize: frameSize)

        return frame
    }
    
    enum SyncSafeStrategy { case syncSafe, nonSyncSafe }
    
    /// Determine the size of the frame that begins at the given position
    /// Includes fix for crash when reading subdata.
    static func determineFrameSize(data: Data, position: Int, version: OutcastID3.TagVersion, syncSafeStrategy: SyncSafeStrategy) throws -> FrameSize {
        let offset = position + version.frameSizeOffsetInBytes
        let end = offset + version.frameSizeByteCount

        guard end <= data.count else {
            let availableLength = data.count - position
            let maxBytes = min(32, availableLength)
            let previewData = data.subdata(in: position ..< position + maxBytes)
            logWarning("Not enough data to determine frame size: position=\(position), offset=\(offset), end=\(end), data.count=\(data.count), preview=\(previewData.hexEncodedString())")
            throw OutcastID3.MP3File.ReadError.corruptedFile
        }

        let sizeBytes = data.subdata(in: offset ..< end)

        switch syncSafeStrategy {
        case .syncSafe:
            guard sizeBytes.isSyncSafeUInt32 else {
                return try determineFrameSizeNonSyncSafe(sizeBytes: sizeBytes, version: version)
            }
            return try determineFrameSizeSyncSafe(sizeBytes: sizeBytes, version: version)

        case .nonSyncSafe:
            return try determineFrameSizeNonSyncSafe(sizeBytes: sizeBytes, version: version)
        }
    }
    
    static func determineFrameSizeSyncSafe(sizeBytes: Data, version: OutcastID3.TagVersion) throws -> FrameSize {
        if let size = sizeBytes.syncSafeUInt32, size > 0, size < Int.max - version.frameHeaderSizeInBytes {
            let size = Int(size) + version.frameHeaderSizeInBytes
            return FrameSize(size: size, isSyncSafe: true)
        } else {
            logWarning("Invalid sync-safe frame size. version=\(version), sizeBytes=\(sizeBytes.hexEncodedString())")
            throw OutcastID3.MP3File.ReadError.corruptedFile
        }
    }
    
    static func determineFrameSizeNonSyncSafe(sizeBytes: Data, version: OutcastID3.TagVersion) throws -> FrameSize {
        if let size = sizeBytes.toUInt32, size > 0, size < Int.max - version.frameHeaderSizeInBytes {
            let size = Int(size) + version.frameHeaderSizeInBytes
            return FrameSize(size: size, isSyncSafe: false)
        } else {
            logWarning("Invalid non-sync-safe frame size. version=\(version), sizeBytes=\(sizeBytes.hexEncodedString())")
            throw OutcastID3.MP3File.ReadError.corruptedFile
        }
    }
    
    static func logDebug(_ message: String) {
        OutcastID3.Logger.logDebug(message)
    }
    
    static func logWarning(_ message: String) {
        OutcastID3.Logger.logWarning(message)
    }
    
    static func logFrameHeader(data: Data, position: Int) {
        guard OutcastID3.Logger.isDetailedLoggingEnabled else { return }

        let availableBytes = min(4, data.count - position)
        guard availableBytes > 0 else {
            OutcastID3.Logger.logDebug("Frame Type: <no data available at position \(position)>")
            return
        }

        let frameHeaderData = data.subdata(in: position ..< position + availableBytes)
        let frameTypeString = String(bytes: frameHeaderData, encoding: .isoLatin1) ?? "<non-decodable>"
        let frameHeaderHex = frameHeaderData.map { String(format: "%02x", $0) }.joined(separator: " ")

        var message = "Frame Type: \(frameTypeString) [hex: \(frameHeaderHex)]"
        if availableBytes < 4 {
            message += " [invalid frame type: too short]"
        }

        OutcastID3.Logger.logDebug(message)
    }
    
    static func logFrame(frameData: Data, frame: OutcastID3TagFrame, frameSize: FrameSize) {
        guard OutcastID3.Logger.isDetailedLoggingEnabled else { return }
        logDebug("Frame: \(frame.frameType)")
        logDebug("Description: \(frame.debugDescription)")

        logDebug("Size: \(frameData.count) (isSyncSafe: \(frameSize.isSyncSafe))")
        let frameDataOnly = frameData.subdata(in: 10..<frameSize.size)

        let frameDataString = frameDataOnly.prefix(500).map { String(format: "%02x", $0) + " " }.joined()
        logDebug("Data: \(frameDataString)")
    }
}

public extension OutcastID3 {
    class Logger {
        public static var isDetailedLoggingEnabled: Bool = false
        
        static func logDebug(_ message: String) {
            if isDetailedLoggingEnabled {
                print("DEBUG: \(message)")
            }
        }
        static func logWarning(_ message: String) {
            print("WARNING: \(message)")
        }
    }
}

extension Data {
    func hexEncodedString() -> String {
        self.map { String(format: "%02x", $0) }.joined(separator: " ")
    }
}
