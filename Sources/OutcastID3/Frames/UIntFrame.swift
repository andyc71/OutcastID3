//
//  UIntFrame.swift
//  Chapters
//
//  Created by Andy Clynes on 11/11/23.
//  Copyright © Andy Clynes. All rights reserved.
//

import Foundation

extension OutcastID3.Frame {
    public struct UIntFrame: OutcastID3TagFrame, Equatable {
        public enum UIntType: String, Codable {
            case playCounter                        = "PCNT"
            
            public var description: String {
                switch self {
                    
                case .playCounter:
                    return "Play Counter"
                }
            }
        }
        public var frameType: OutcastID3TagFrameType
        
        public let type: UIntType
        public let value: UInt
        
        public init(type: UIntType, value: UInt) {
            self.type = type
            self.value = value
            self.frameType = .uInt(type)
        }
        
        public var debugDescription: String {
            return "intType=\(type) int=\(value)"
        }
    }
}

extension OutcastID3.Frame.UIntFrame {
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let builder = FrameBuilder(version: version, frameIdentifier: self.type.rawValue)

        builder.append(data: UInt32(value).bigEndian.toData)

        return try builder.data()
    }
}

extension OutcastID3.Frame.UIntFrame {
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        
        guard let frameIdentifier = data.frameIdentifier(version: version) else {
            return nil
        }
        
        guard let uIntType = UIntType(rawValue: frameIdentifier) else {
            return nil
        }
        
        let frameContentRangeStart = version.frameHeaderSizeInBytes
        
        guard frameContentRangeStart < data.count else {
            return nil
        }
        
        // let frameContent = data.subdata(in: frameContentRangeStart ..< data.count)
        
        // TODO: Look at the frame size to decice how wide the int is (i.e. don't
        // limit ourselves to UInt
        var int: UInt32 = 0
        let intLength = 4
        let nsData = data.subdata(in: frameContentRangeStart..<frameContentRangeStart+intLength) as NSData
        nsData.getBytes(&int, length: intLength)
        int = int.bigEndian
        
        return OutcastID3.Frame.UIntFrame(type: uIntType, value: UInt(int))
    }
}
