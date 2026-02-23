//
//  UserDefinedTextFrame.swift
//  OutcastID3
//
//  Created by Andy Clynes on 25/12/23.
//

import Foundation

extension OutcastID3.Frame {
    public struct UserDefinedTextFrame: OutcastID3TagFrame {
        
        public enum UserDefinedType: Hashable, Equatable, Codable {
                        
            case raw(description: String, text: String)
            case energyLevel(level: UInt8?)
            
            public var description: String {
                switch self {
                case .raw(let description, _): description
                case .energyLevel(_): "EnergyLevel"
                }
            }
            
            public var text: String {
                switch self {
                case .raw(_, let text):
                    return text
                case .energyLevel(let level):
                    if let level { return String(level) }
                    else { return "" }
                }
            }
            
            public static func parse(description: String, text: String) -> UserDefinedType {
                if description == "EnergyLevel" {
                    let trimmed = text.trimmingCharacters(in: .nullCharacters)
                    return .energyLevel(level: UInt8(trimmed))
                }
                else {
                    return .raw(description: description, text: text)
                }
            }
        }
        
        static let frameIdentifier = "TXXX"
        
        public var frameType: OutcastID3TagFrameType
        public let encoding: String.Encoding
        
        public init(type: UserDefinedType, encoding: String.Encoding) {
            self.frameType = .userDefinedText(type: type)
            self.encoding = encoding
        }
        
        public init(description: String, text: String, encoding: String.Encoding) {
            let type = UserDefinedType.parse(description: description, text: text)
            self.frameType = .userDefinedText(type: type)
            self.encoding = encoding
        }
        
        public var debugDescription: String {
            return "userDefinedType=\(frameType) encoding=\(encoding)"
        }
    }
}

extension OutcastID3.Frame.UserDefinedTextFrame {
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let builder = FrameBuilder(version: version, frameIdentifier: OutcastID3.Frame.UserDefinedTextFrame.frameIdentifier)
        
        builder.addStringEncodingByte(encoding: self.encoding)
        
        //Should throw if this if case let fails... but it couldn't ever.
        if case let .userDefinedText(type) = frameType {
            try builder.addString(
                str: type.description,
                encoding: self.encoding,
                includeEncodingByte: false,
                terminator: version.stringTerminator(encoding: self.encoding)
            )
            
            try builder.addString(str: type.text, encoding: self.encoding, includeEncodingByte: false, terminator: nil)
        }
        
        return try builder.data()
    }
}

extension OutcastID3.Frame.UserDefinedTextFrame {
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        
        var frameContentRangeStart = version.frameHeaderSizeInBytes
        
        let encoding = String.Encoding.fromEncodingByte(byte: data[frameContentRangeStart], version: version)
        frameContentRangeStart += 1

        let description = data.readString(offset: &frameContentRangeStart, encoding: encoding, terminator: version.stringTerminator(encoding: encoding))

        var text: String?
        
        if frameContentRangeStart < data.count {
            let textData = data.subdata(in: frameContentRangeStart ..< data.count)
            text = String(data: textData, encoding: encoding)
        }
        else {
            text = nil
        }
        
        return OutcastID3.Frame.UserDefinedTextFrame(
            description: description ?? "",
            text: text ?? "",
            encoding: encoding
        )
    }

}
