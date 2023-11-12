//
//  PopularimeterFrame.swift
//  Chapters
//
//  Created by Andy Clynes on 06/11/23.
//  Copyright © Andy Clynes. All rights reserved.
//

import Foundation

extension OutcastID3.Frame {
    public struct PopularimeterFrame: OutcastID3TagFrame {
        
        static let frameIdentifier = "POPM"
        public var frameType: OutcastID3TagFrameType = .popularimeter

        public var email: String
        public var rating: Int
        public var playCount: Int
        
        public init(email: String, rating: Int, playCount: Int) {
            self.email = email
            self.rating = rating
            self.playCount = playCount
        }
        public var debugDescription: String {
            return "email=\(email) rating=\(rating) playCount=\(playCount)"
        }
    }
}

extension OutcastID3.Frame.PopularimeterFrame {
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: OutcastID3.Frame.PopularimeterFrame.frameIdentifier)
        try fb.addString(str: email, encoding: .isoLatin1, includeEncodingByte: false, terminator: version.stringTerminator(encoding: .isoLatin1))
        
        //Append the rating.
        fb.append(byte: UInt8(rating))
        
        //Append the play counter.
        fb.append(data: UInt32(playCount).bigEndian.toData)
        
        return try fb.data()
    }
}

extension OutcastID3.Frame.PopularimeterFrame {
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        
        var frameContentRangeStart = version.frameHeaderSizeInBytes
        
        let email = data.readString(offset: &frameContentRangeStart, encoding: .isoLatin1, terminator: version.stringTerminator(encoding: .isoLatin1))

        let rating = data[frameContentRangeStart]
        //let rating = data.subdata(in: frameContentRangeStart ..< frameContentRangeStart + playCountLength)
        frameContentRangeStart += 1

        //Remainder of the frame is the playcount.
        //TODO: DOn't just grab the last 4 bytes, take them all.
        var counter: UInt32 = 0
        let counterLength = 4
        let nsData = data.subdata(in: frameContentRangeStart..<frameContentRangeStart+counterLength) as NSData
        nsData.getBytes(&counter, length: counterLength)
        counter = counter.bigEndian

        return OutcastID3.Frame.PopularimeterFrame(
            email: email ?? "",
            rating: Int(rating),
            playCount: Int(counter)
        )
    }

}
