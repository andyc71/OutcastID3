//
//  MP3File+FrameHelpers.swift
//  
//
//  Created by Andy on 12/11/2023.
//

import Foundation

extension OutcastID3.ID3Tag {
    
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

    // Re-purposing .band frame as Album Artist as advised in
    // https://stackoverflow.com/questions/5922622/whats-this-album-artist-tag-itunes-uses-any-way-to-set-it-using-java
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
    
    // TODO: Support values > UInt32.max (i.e. 4 bytes)
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
    
    // TODO: Support languages
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

    // TODO: Support different languages.
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

    public var trackNumber: OutcastID3.ID3Track? {
        get {
            guard let string = getStringFrame(.track)?.str else {
                return nil
            }
            return OutcastID3.ID3Track(id3String: string)
        }
        set {
            setStringFrame(.track, newValue?.id3String ?? nil)
        }
    }

    /// Recording year. This is superceded by recordingTime
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

    /// Original release year. This is superceded by originalReleaseTime
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
    
    public var genre: String? {
        get {
            guard let genreString = getStringFrame(.contentType)?.str else {
                return nil
            }
            return genreString
            
        }
        set {
            setStringFrame(.contentType, newValue)
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
            // TODO: Review MIME type
            // “image/” will be implied. The “image/png” [PNG] or “image/jpeg” [JFIF] picture
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
        self.pictureFrames.map { $0.picture }
    }
    
    var defaultEncoding: String.Encoding {
        String.Encoding.utf8
    }
    
    var defaultLanguage: String {
        "ENG"
    }
}
