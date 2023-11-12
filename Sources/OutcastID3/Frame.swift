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

public enum OutcastID3TagFrameType : Hashable {
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
}


