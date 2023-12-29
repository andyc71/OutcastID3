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
        let frames: [OutcastID3TagFrame] = try OutcastID3.ID3Tag.framesFromData(version: version, data: tagData)
        
        let tag = OutcastID3.ID3Tag(
            version: version,
            frames: frames
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
    
    static func framesFromData(version: OutcastID3.TagVersion, data: Data) throws -> [OutcastID3TagFrame] {
        var ret: [OutcastID3TagFrame] = []
        
        var position = 0
        
        let count = data.count
        
        logDebug("ID3 tag version: \(version)")
        
        while position < count {
            var oldPosition = position
            var frame: OutcastID3TagFrame?
            if version == .v2_4 {
                    // According to the spec, we should expect synchsafe ints for
                    // version 2.4, but in reality it works better to check for a
                    // non-synchsafe first and then fall-back to synchsafe after.
                    frame = try frameFromData(version: version, data: data, position: &position, useSynchSafeFrameSize: true, throwOnError: false )
                
            }
            else {
                frame = try frameFromData(version: version, data: data, position: &position, useSynchSafeFrameSize: false, throwOnError: false )
            }
            
            if let frame {
                ret.append(frame)
            }
            else {
                ///We didn't get a frame  back (e.g. could not parse it). If we managed to get a frame size then position will have changed and
                ///we can skip over the frame and move to the next one. If position didn't move then we just stop parsing any more frames.
                if position > oldPosition {
                    continue
                }
                else {
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
                throw error
            }
            else {
                return nil
            }
        }
        
        let count = data.count
        
        guard position + frameSize.size <= count else {
            logWarning("Frame size too big position=\(position) + frameSize=\(frameSize.size) = \(position + frameSize.size), count=\(count)")
            if throwOnError {
                throw OutcastID3.MP3File.ReadError.corruptedFile
            }
            else {
                return nil
            }
        }

        let frameData = data.subdata(in: position ..< position + frameSize.size)
        position += frameSize.size

        guard let frame = OutcastID3.Frame.RawFrame.parse(version: version, data: frameData, useSynchSafeFrameSize: useSynchSafeFrameSize) else {
            return nil
        }
        
        logFrame(frameData: frameData, frame: frame, frameSize: frameSize)

        return frame
    }
    
    enum SyncSafeStrategy { case syncSafe, nonSyncSafe }
    
    /// Determine the size of the frame that begins at the given position
    static func determineFrameSize(data: Data, position: Int, version: OutcastID3.TagVersion, syncSafeStrategy: SyncSafeStrategy) throws -> FrameSize {
        
        let offset = position + version.frameSizeOffsetInBytes
        
        guard offset < data.count else {
            throw OutcastID3.MP3File.ReadError.corruptedFile
        }
        
        let sizeBytes = data.subdata(in: offset ..< offset + version.frameSizeByteCount)
        
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
            return FrameSize(size: size, isSyncSafe: false)
        }
        else {
            throw OutcastID3.MP3File.ReadError.corruptedFile
        }
    }

    static func determineFrameSizeNonSyncSafe(sizeBytes: Data, version: OutcastID3.TagVersion) throws -> FrameSize {
        if let size = sizeBytes.toUInt32, size > 0, size < Int.max - version.frameHeaderSizeInBytes {
            let size = Int(size) + version.frameHeaderSizeInBytes
            return FrameSize(size: size, isSyncSafe: false)
        }
        else {
            throw OutcastID3.MP3File.ReadError.corruptedFile
        }
    }
    
    static func logDebug(_ message: String) {
        // print(message)
    }
    
    static func logWarning(_ message: String) {
        print("Warning: \(message)")
    }
    
    static func logFrameHeader(data: Data, position: Int) {
        guard OutcastID3.Logger.isDetailedLoggingEnabled else { return }
        let frameHeaderData = data.subdata(in: position ..< position+4)
        // let frameHeaderString = frameHeaderData.map { String(format: "%02x", $0) + " " }.joined()
        let frameTypeString = String(bytes: frameHeaderData.subdata(in: 0 ..< 4), encoding: .isoLatin1)
        // logDebug("Frame Header: \(frameHeaderString)")
        OutcastID3.Logger.logDebug("Frame Type: \(frameTypeString)")
    }
    
    static func logFrame(frameData: Data, frame: OutcastID3TagFrame, frameSize: FrameSize) {
        guard OutcastID3.Logger.isDetailedLoggingEnabled else { return }
        logDebug("Frame: \(frame.frameType)")
        logDebug("Description: \(frame.debugDescription)")

        logDebug("Size: \(frameData.count) (isSyncSafe: \(frameSize.isSyncSafe))")
        let frameDataOnly = frameData.subdata(in: 10..<frameSize.size)

        let frameDataString = frameDataOnly.prefix(500).map { String(format: "%02x", $0) + " " }.joined()
        logDebug("Data: \(frameDataString)")
        logDebug("")
    }
}

public extension OutcastID3 {
    public class Logger {
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
