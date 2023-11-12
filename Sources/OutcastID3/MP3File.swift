//
//  MP3File.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation
import UIKit

public class OutcastID3 {
    public struct ID3Tag {
        public let version: TagVersion
        public var frames: [OutcastID3TagFrame]
        private var indexedFrames: [OutcastID3TagFrameType : OutcastID3TagFrame]
        public var pictureFrames: [OutcastID3.Frame.PictureFrame]
        
        public init(version: TagVersion, frames: [OutcastID3TagFrame]) {
            self.version = version
            self.frames = frames
            
            var indexedFrames = [OutcastID3TagFrameType : OutcastID3TagFrame]()
            var pictureFrames = [OutcastID3.Frame.PictureFrame]()
            for frame in frames {
                //Make sure we're not adding duplicates
                assert(indexedFrames[frame.frameType] == nil)
                //Store the frame
                indexedFrames[frame.frameType] = frame
                if let pictureFrame = frame as? OutcastID3.Frame.PictureFrame {
                    pictureFrames.append(pictureFrame)
                }
            }
            self.indexedFrames = indexedFrames
            self.pictureFrames = pictureFrames
        }
        
        public func getFrame(_ frameType: OutcastID3TagFrameType) -> OutcastID3TagFrame? {
            return indexedFrames[frameType]
        }
        
        public func getChapterFrame() -> OutcastID3.Frame.ChapterFrame? {
            return indexedFrames[.chapter] as? OutcastID3.Frame.ChapterFrame
        }

        public func getCommentFrame() -> OutcastID3.Frame.CommentFrame? {
            return indexedFrames[.comment] as? OutcastID3.Frame.CommentFrame
        }

        public func getPictureFrame(_ pictureType: OutcastID3.Frame.PictureFrame.PictureType) -> OutcastID3.Frame.PictureFrame? {
            return indexedFrames[.picture(pictureType)] as? OutcastID3.Frame.PictureFrame
        }

        public func getStringFrame(_ stringType: OutcastID3.Frame.StringFrame.StringType) -> OutcastID3.Frame.StringFrame? {
            return indexedFrames[.string(stringType)] as? OutcastID3.Frame.StringFrame
        }

        public mutating func setStringFrame(_ stringType: OutcastID3.Frame.StringFrame.StringType, _ newValue: String?) {
            let frameType = OutcastID3TagFrameType.string(stringType)
            if let newValue {
                let frame = OutcastID3.Frame.StringFrame(type: stringType, encoding: .utf8, str: newValue)
                storeFrame(frameType, newFrame: frame)
            }
            else {
                storeFrame(frameType, newFrame: nil)
            }
        }
        
        public func getUIntFrame(_ uIntType: OutcastID3.Frame.UIntFrame.UIntType) -> OutcastID3.Frame.UIntFrame? {
            return indexedFrames[.uInt(uIntType)] as? OutcastID3.Frame.UIntFrame
        }

        public mutating func setUIntFrame(_ uIntType: OutcastID3.Frame.UIntFrame.UIntType, _ newValue: UInt?) {
            let frameType = OutcastID3TagFrameType.uInt(uIntType)
            if let newValue {
                let frame = OutcastID3.Frame.UIntFrame(type: uIntType, value: newValue)
                storeFrame(frameType, newFrame: frame)
            }
            else {
                storeFrame(frameType, newFrame: nil)
            }
        }
        
        public func getPopularimeterFrame() -> OutcastID3.Frame.PopularimeterFrame? {
            return indexedFrames[.popularimeter] as? OutcastID3.Frame.PopularimeterFrame
        }
        
        public mutating func storeFrame(_ frameType: OutcastID3TagFrameType, newFrame: OutcastID3TagFrame?) {
            if let newFrame {
                if let index = self.frames.firstIndex(where: {$0.frameType == frameType}) {
                    self.frames[index] = newFrame
                }
                else {
                    self.frames.append(newFrame)
                }
                self.indexedFrames[frameType] = newFrame
            }
            else {
                if let index = self.frames.firstIndex(where: {$0.frameType == frameType}) {
                    self.frames.remove(at: index)
                }
                self.indexedFrames.removeValue(forKey: frameType)

            }
        }

        public func getTableOfContentsFrame() -> OutcastID3.Frame.TableOfContentsFrame? {
            return indexedFrames[.tableOfContents] as? OutcastID3.Frame.TableOfContentsFrame
        }

        public func getTranscriptionFrame() -> OutcastID3.Frame.TranscriptionFrame? {
            return indexedFrames[.transcription] as? OutcastID3.Frame.TranscriptionFrame
        }
        
        public func getUrlFrame(_ urlType: OutcastID3.Frame.UrlFrame.UrlType) -> OutcastID3.Frame.UrlFrame? {
            return indexedFrames[.url(urlType)] as? OutcastID3.Frame.UrlFrame
        }
        
        public func getUserUrlFrame() -> OutcastID3.Frame.UserUrlFrame? {
            return indexedFrames[.userUrl] as? OutcastID3.Frame.UserUrlFrame
        }
        
        //MARK: Helpers
        
        public var title: String? {
            get {
                guard let frame = getStringFrame(.title) else {
                    return nil
                }
                return frame.str
            }
            set {
                setStringFrame(.title, newValue)
            }
        }

        public var subtitle: String? {
            get {
                return getStringFrame(.description)?.str
            }
            set {
                setStringFrame(.description, newValue)
            }
        }
        
        public var leadArtist: String? {
            get {
                return getStringFrame(.leadArtist)?.str
            }
            set {
                setStringFrame(.leadArtist, newValue)
            }
        }
        
        public var albumTitle: String? {
            get {
                return getStringFrame(.albumTitle)?.str
            }
            set {
                setStringFrame(.albumTitle, newValue)
            }
        }

        //Re-purposing .band frame as Album Artist as advised in
        //https://stackoverflow.com/questions/5922622/whats-this-album-artist-tag-itunes-uses-any-way-to-set-it-using-java
        public var albumArtist: String? {
            get {
                return getStringFrame(.band)?.str
            }
            set {
                setStringFrame(.band, newValue)
            }
        }
        
        public var beatsPerMinute: Int? {
            get {
                guard let bpmString = getStringFrame(.beatsPerMinute)?.str else {
                    return nil
                }
                return Int(bpmString)
            }
            set {
                if let newValue {
                    setStringFrame(.beatsPerMinute, String(newValue))
                }
                else {
                    setStringFrame(.beatsPerMinute, nil)
                }
            }
        }
        
        public var initialKey: String? {
            get {
                return getStringFrame(.initialKey)?.str
            }
            set {
                setStringFrame(.initialKey, newValue)
            }
        }
        
        public var rating: PopularimeterRating? {
            get {
                guard let rating = getPopularimeterFrame()?.rating else {
                    return nil
                }
                return PopularimeterRating(rating)
            }
            set {
                if let rating = newValue {
                    if var popularimeterFrame = getPopularimeterFrame() {
                        popularimeterFrame.rating = rating.value
                        storeFrame(.popularimeter, newFrame: popularimeterFrame)
                    }
                    else {
                        let popularimeterFrame = OutcastID3.Frame.PopularimeterFrame(email: "OutcastID3", rating: rating.value, playCount: 0)
                        storeFrame(.popularimeter, newFrame: popularimeterFrame)
                    }
                }
                else {
                    storeFrame(.popularimeter, newFrame: nil)
                }
            }
        }
        
        //TODO: Support values > UInt32.max (i.e. 4 bytes)
        public var playCount: UInt? {
            get {
                guard let frame = getUIntFrame(.playCounter) else {
                    return nil                }
                return frame.value
            }
            set {
                setUIntFrame(.playCounter, newValue)
            }
        }
        
        let defaultEncoding = String.Encoding.utf8
        let defaultLanguage = "ENG"

        //TODO: Support languages
        public var comments: String? {
            get {
                return getCommentFrame()?.comment
            }
            set {
                if let newValue {
                    let newFrame = OutcastID3.Frame.CommentFrame(encoding: .utf8, language: defaultLanguage, commentDescription: "", comment: newValue)
                    storeFrame(.comment, newFrame: newFrame)
                }
                else {
                    storeFrame(.comment, newFrame: nil)
                }
                
            }
        }

        //TODO: Support different languages.
        public var unsychronisedLyrics: String? {
            get {
                guard let frame = getTranscriptionFrame() else {
                    return nil
                }
                return frame.lyrics
            }
            set {
                if let newValue {
                    let newFrame = OutcastID3.Frame.TranscriptionFrame(encoding: defaultEncoding, language: defaultLanguage, lyricsDescription: "", lyrics: newValue)
                    storeFrame(.transcription, newFrame: newFrame)
                }
                else {
                    storeFrame(.transcription, newFrame: nil)
                }
            }
        }

        public var trackNumber: ID3Track? {
            get {
                guard let string = getStringFrame(.track)?.str else {
                    return nil
                }
                return ID3Track(id3String: string)
            }
            set {
                setStringFrame(.track, newValue?.id3String ?? nil)
            }
        }

        ///Recording year. This is superceded by recordingTime
        public var recordingYear: Int? {
            get {
                guard let yearString = getStringFrame(.year)?.str else {
                    return nil
                }
                return Int(yearString)
            }
            set {
                if let newValue {
                    setStringFrame(.year, String(newValue))
                }
                else {
                    setStringFrame(.year, nil)
                }
            }
        }

        ///Original release year. This is superceded by originalReleaseTime
        public var originalReleaseYear: Int? {
            get {
                guard let yearString = getStringFrame(.originalReleaseYear)?.str else {
                    return nil
                }
                return Int(yearString)
            }
            set {
                if let newValue {
                    setStringFrame(.originalReleaseYear, String(newValue))
                }
                else {
                    setStringFrame(.originalReleaseYear, nil)
                }
            }
        }

        public var releaseTime: Date? {
            get {
                guard let releaseTimeString = getStringFrame(.releaseTime)?.str else {
                    return nil
                }
                return Date(id3String: releaseTimeString)
            }
            set {
                setStringFrame(.releaseTime, newValue?.id3String ?? nil)
            }
        }

        public var originalReleaseTime: Date? {
            get {
                guard let releaseTimeString = getStringFrame(.originalReleaseTime)?.str else {
                    return nil
                }
                return Date(id3String: releaseTimeString)
            }
            set {
                setStringFrame(.originalReleaseTime, newValue?.id3String ?? nil)
            }
        }
        
        public var recordingTime: Date? {
            get {
                guard let recordingTimeString = getStringFrame(.recordingTime)?.str else {
                    return nil
                }
                return Date(id3String: recordingTimeString)
            }
            set {
                setStringFrame(.recordingTime, newValue?.id3String ?? nil)
            }
        }
        
        public var genres: [String]? {
            get {
                guard let genreString = getStringFrame(.contentType)?.str else {
                    return nil
                }
                
                //TODO: parse the string properly
                return [genreString]
                
                
            }
            set {
                //TODO: support multiple
                setStringFrame(.contentType, newValue?.first)
            }
        }
        
        public func picture(_ pictureType: OutcastID3.Frame.PictureFrame.PictureType) -> OutcastID3.Frame.PictureFrame.Picture? {
            guard let picture = getPictureFrame(pictureType)?.picture else {
                return nil
            }
            
            return picture
        }
        
        public mutating func setPicture(_ pictureType: OutcastID3.Frame.PictureFrame.PictureType, _ pictureImage: OutcastID3.Frame.PictureFrame.Picture.PictureImage?, description: String?) {
            let frameType = OutcastID3TagFrameType.picture(pictureType)
            if let pictureImage {
                let picture = OutcastID3.Frame.PictureFrame.Picture(image: pictureImage)
                //TODO: Review MIME type
                //“image/” will be implied. The “image/png” [PNG] or “image/jpeg” [JFIF] picture
                let pictureFrame = OutcastID3.Frame.PictureFrame(encoding: .isoLatin1, mimeType: "image/jpeg", pictureType: pictureType, pictureDescription: description ?? "", picture: picture)
                
                if let index = pictureFrames.firstIndex(where: { $0.pictureType == pictureType }) {
                    self.pictureFrames[index] = pictureFrame
                }
                else {
                    self.pictureFrames.append(pictureFrame)
                }
                storeFrame(frameType, newFrame: pictureFrame)
            }
            else {
                if let index = self.pictureFrames.firstIndex(where: { $0.pictureType == pictureType }) {
                    self.pictureFrames.remove(at: index)
                }
                storeFrame(frameType, newFrame: nil)
            }
            
        }
        
        public var pictures: [OutcastID3.Frame.PictureFrame.Picture] {
            get {
                self.pictureFrames.map { $0.picture }
            }
            
        }
        
    }
    
    public class MP3File {
        public struct TagProperties {
            public let tag: ID3Tag
            
            public let startingByteOffset: UInt64
            public let endingByteOffset: UInt64
        }

        let localUrl: URL

        public init(localUrl: URL) throws {
            self.localUrl = localUrl
        }
    }

    public struct Frame {}
}


extension Date {
    init?(id3String dateString: String) {
        let dateStringFormatter = DateFormatter()
        if dateString.count == 4 {
            dateStringFormatter.dateFormat = "yyyy"
        }
        else if dateString.count == 10 {
            dateStringFormatter.dateFormat = "yyyy-MM-dd"
        }
        else if dateString.count == 13 {
            dateStringFormatter.dateFormat = "yyyy-MM-dd HH"
        }
        else if dateString.count == 16 {
            dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        else if dateString.count == 19 {
            dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }
        else {
            return nil
        }
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        if let date = dateStringFormatter.date(from: dateString.replacingOccurrences(of: "T", with: " ")) {
            self.init(timeInterval:0, since:date)
        }
        else {
            return nil
        }
    }
    
    var id3String: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let str = dateFormatter.string(from: self)
        return str.replacingOccurrences(of: " ", with: "T")
    }
}

public struct ID3Track {
    public var position: Int
    public var total: Int?
    
    public init(position: Int, total: Int? = nil) {
        self.position = position
        self.total = total
    }
    
    public init?(id3String: String) {
        let elements = id3String.split(separator: "/")
        if elements.count > 0 {
            self.position = Int(elements[0]) ?? 0
            if elements.count > 1 {
                self.total = Int(elements[1])
            }
        }
        else {
            self.position = 0
        }
    }
    
    var id3String: String {
        if let total {
            return "\(position)/\(total)"
        }
        else {
            return String(position)
        }
    }
    
}
