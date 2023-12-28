//
//  Frame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 27/11/18.
//
//  Frame type resources:
//  https://mutagen-specs.readthedocs.io/en/latest/id3/id3v2.2.html
//  https://mutagen-specs.readthedocs.io/en/latest/id3/id3v2.3.0.html

import Foundation

public protocol OutcastID3TagFrame: CustomDebugStringConvertible {
    static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame?
    
    /// Used to build raw data that can be written to an MP3 file
    func frameData(version: OutcastID3.TagVersion) throws -> Data
    
    var frameType: OutcastID3TagFrameType { get }
}

public enum OutcastID3TagFrameType: Hashable, CustomDebugStringConvertible {
    
    case chapter
    case comment
    case picture(_ pictureType: OutcastID3.Frame.PictureFrame.PictureType)
    case popularimeter
    case raw(frameIdentifier: String?, uniqueID: UUID)
    case string(_ stringType: OutcastID3.Frame.StringFrame.StringType)
    case tableOfContents
    case transcription
    case uInt(_ uintType: OutcastID3.Frame.UIntFrame.UIntType)
    case url(_ urlType: OutcastID3.Frame.UrlFrame.UrlType)
    case userUrl
    case userDefinedText
    
    public var debugDescription: String {
        switch self {
        case .chapter:
            return "chapter"
        case .comment:
            return "comment"
        case .picture(let type):
            return "picture: type: \(type)"
        case .popularimeter:
            return "popularimeter"
        case .raw(let frameIdentifier, let uniqueID):
            return "raw: frameID \(frameIdentifier), id: \(uniqueID)"
        case .string(let type):
            return "string: type: \(type)"
        case .tableOfContents:
            return "table of contents"
        case .transcription:
            return "transcription"
        case .uInt(let type):
            return "uInt: type \(type)"
        case .url(let type):
            return "URL: type \(type)"
        case .userUrl:
            return "User URL"
        case .userDefinedText:
            return "user defined text"
        }
    }
    
}
