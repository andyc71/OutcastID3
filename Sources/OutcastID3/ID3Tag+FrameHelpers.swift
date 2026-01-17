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
    
    public var composer: String? {
        get {
            return getStringFrame(.composer)?.str
        }
        set {
            setStringFrame(.composer, newValue)
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
            return PopularimeterRating(rating: rating)
        }
        set {
            if let rating = newValue {
                if var popularimeterFrame = getPopularimeterFrame() {
                    popularimeterFrame.rating = rating.rating
                    storeFrame(.popularimeter, newFrame: popularimeterFrame)
                }
                else {
                    let popularimeterFrame = OutcastID3.Frame.PopularimeterFrame(email: rating.email, rating: rating.rating, playCount: rating.playCount)
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
            if let intGenre = Int(genreString) {
                if let genre = ID3Genre(rawValue: intGenre) {
                    return genre.displayName
                }
            }

            return genreString
            
        }
        set {
            setStringFrame(.contentType, newValue)
        }
    }
    
    public var energyLevel: UInt8? {
        get {
            for frame in self.frames {
                if case .userDefinedText(type: .energyLevel(let level)) = frame.frameType {
                    return level
                }
            }
            return nil
        }
        set {
            setUserDefinedTextFrame(.energyLevel(level: newValue))
        }
    }

    public var itunesAdvisory: String? {
        get {
            userDefinedTextValue(description: "ITUNESADVISORY")
        }
        set {
            removeUserDefinedTextFrames(description: "ITUNESADVISORY")
            guard let newValue else {
                return
            }
            let frame = OutcastID3.Frame.UserDefinedTextFrame(description: "ITUNESADVISORY", text: newValue, encoding: .utf8)
            storeFrame(frame.frameType, newFrame: frame)
        }
    }

    
    public func picture(_ pictureType: OutcastID3.Frame.PictureFrame.PictureType) -> ID3Picture? {
        guard let picture = getPictureFrame(pictureType) else {
            return nil
        }
        
        return ID3Picture(image: picture.picture.image, imageType: picture.pictureType, description: picture.pictureDescription)
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
    
    
    public var pictures: [ID3Picture] {
        self.pictureFrames.map { ID3Picture(image: $0.picture.image, imageType: $0.pictureType, description: $0.pictureDescription) }
    }
    
    public var chapters: ID3TableOfContents? {
        ChapterDecoder.decode(tocFrames: chapterTOCFrames, chapterFrames: chapterFrames)
    }

    public mutating func setChapters(_ chapters: [ID3Chapter]) {
        if let tocFrame = chapterTOCFrames.first(where: {$0.isTopLevel}) {
            let toc = ID3TableOfContents(elementId: tocFrame.elementId, isTopLevel: true, isOrdered: tocFrame.isOrdered, childTOCs: [], chapters: chapters)
            setTableOfContents(toc)
        }
        else {
            let toc = ID3TableOfContents(elementId: UUID().uuidString, isTopLevel: true, isOrdered: true, childTOCs: [], chapters: chapters )
            setTableOfContents(toc)
        }
                                            
    }
    
    public mutating func setTableOfContents(_ newTOC: ID3TableOfContents) {
        // Encode all TOCs and chapters in the hierarchy
        let (newTOCFrames, newChapterFrames) = ChapterEncoder.encode(toc: newTOC)

        // Create sets of elementIds for TOCs and CHAPs in the new hierarchy
        let newTOCIds = Set(newTOCFrames.map { $0.elementId })
        let newChapterIds = Set(newChapterFrames.map { $0.elementId })

        // Remove obsolete TOC frames
        let oldTOCIds = Set(chapterTOCFrames.map { $0.elementId })
        let toRemoveTOCs = oldTOCIds.subtracting(newTOCIds)
        for id in toRemoveTOCs {
            if let index = chapterTOCFrames.firstIndex(where: { $0.elementId == id }) {
                let removed = chapterTOCFrames.remove(at: index)
                storeFrame(removed.frameType, newFrame: nil)
            }
        }

        // Remove obsolete CHAP frames
        let oldChapterIds = Set(chapterFrames.map { $0.elementId })
        let toRemoveChapters = oldChapterIds.subtracting(newChapterIds)
        removeChapters(elementIds: Array(toRemoveChapters))

        // Add or update all TOC frames
        for tocFrame in newTOCFrames {
            if let index = chapterTOCFrames.firstIndex(where: { $0.elementId == tocFrame.elementId }) {
                chapterTOCFrames[index] = tocFrame
            } else {
                chapterTOCFrames.append(tocFrame)
            }
            storeFrame(tocFrame.frameType, newFrame: tocFrame)
        }

        // Add or update all CHAP frames
        for chapterFrame in newChapterFrames {
            setChapter(chapterFrame)
        }
    }
    
    private mutating func setChapter(_ chapterFrame: OutcastID3.Frame.ChapterFrame) {
        if let index = chapterFrames.firstIndex(where: { $0.elementId == chapterFrame.elementId }) {
            self.chapterFrames[index] = chapterFrame
        }
        else {
            self.chapterFrames.append(chapterFrame)
        }
        storeFrame(chapterFrame.frameType, newFrame: chapterFrame)
    }
    
    private mutating func removeChapters(elementIds: [String]) {
        for elementId in elementIds {
            if let index = chapterFrames.firstIndex(where: { $0.elementId == elementId }) {
                let chapterFrame = chapterFrames[index]
                storeFrame(chapterFrame.frameType, newFrame: nil)
                self.chapterFrames.remove(at: index)
            }
        }
    }
    
    
    var defaultEncoding: String.Encoding {
        String.Encoding.utf8
    }
    
    var defaultLanguage: String {
        "ENG"
    }

    private func userDefinedTextValue(description: String) -> String? {
        for frame in frames {
            guard let userDefined = frame as? OutcastID3.Frame.UserDefinedTextFrame else {
                continue
            }
            if case let .userDefinedText(type) = userDefined.frameType {
                switch type {
                case .raw(let desc, let text):
                    if desc == description {
                        return text.isEmpty ? nil : text
                    }
                case .energyLevel:
                    continue
                }
            }
        }
        return nil
    }

    private mutating func removeUserDefinedTextFrames(description: String) {
        let framesToRemove = frames.compactMap { frame -> OutcastID3TagFrameType? in
            guard let userDefined = frame as? OutcastID3.Frame.UserDefinedTextFrame else {
                return nil
            }
            if case let .userDefinedText(type) = userDefined.frameType {
                switch type {
                case .raw(let desc, _):
                    return desc == description ? userDefined.frameType : nil
                case .energyLevel:
                    return nil
                }
            }
            return nil
        }

        for frameType in framesToRemove {
            storeFrame(frameType, newFrame: nil)
        }
    }
}
