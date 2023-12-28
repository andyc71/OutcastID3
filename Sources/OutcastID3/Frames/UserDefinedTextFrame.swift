//
//  UserDefinedTextFrame.swift
//  OutcastID3
//
//  Created by Andy Clynes on 25/12/23.
//

import Foundation

extension OutcastID3.Frame {
    public struct UserDefinedTextFrame: OutcastID3TagFrame {
        static let frameIdentifier = "TXXX"
        public var frameType: OutcastID3TagFrameType = .userDefinedText
        
        public let encoding: String.Encoding
        public let description: String
        public let text: String
        
        public init(encoding: String.Encoding, description: String, text: String) {
            self.encoding = encoding
            self.description = description
            self.text = text
        }
        public var debugDescription: String {
            return "encoding=\(encoding) description=\(description) length=\(text.count) text=\(text)"
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
        
        try builder.addString(
            str: self.description,
            encoding: self.encoding,
            includeEncodingByte: false,
            terminator: version.stringTerminator(encoding: self.encoding)
        )
        
        try builder.addString(str: self.text, encoding: self.encoding, includeEncodingByte: false, terminator: nil)
        
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
            encoding: encoding,
            description: description ?? "",
            text: text ?? ""
        )
    }

}
