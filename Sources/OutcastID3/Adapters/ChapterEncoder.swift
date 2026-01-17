//
//  ChapterEncoder.swift
//  OutcastID3
//
//  Created by Andy on 12/06/2025.
//
import Foundation

// ID3 chapter specification:
// https://id3.org/id3v2-chapters-1.0

/// Encodes Chapters (public interface)
/// to Chapter Frames (part of internal persistence layer).

struct ChapterEncoder {

    static func encode(toc: ID3TableOfContents) -> (tocFrames: [OutcastID3.Frame.TableOfContentsFrame], chapterFrames: [OutcastID3.Frame.ChapterFrame]) {
        var tocFrames: [OutcastID3.Frame.TableOfContentsFrame] = []
        var chapterFrames: [OutcastID3.Frame.ChapterFrame] = []

        encodeTOC(toc, isTopLevel: true, tocFrames: &tocFrames, chapterFrames: &chapterFrames)

        return (tocFrames, chapterFrames)
    }

    static func encodeTOC(
        _ toc: ID3TableOfContents,
        isTopLevel: Bool = false,
        tocFrames: inout [OutcastID3.Frame.TableOfContentsFrame],
        chapterFrames: inout [OutcastID3.Frame.ChapterFrame]
    ) {
        var childElementIds: [String] = []

        // First encode all chapters
        for chapter in toc.chapters {
            let chapterFrame = encodeChapter(chapter)
            chapterFrames.append(chapterFrame)
            childElementIds.append(chapter.id)
        }

        // Then encode child TOCs
        for childTOC in toc.childTOCs {
            encodeTOC(childTOC, isTopLevel: false, tocFrames: &tocFrames, chapterFrames: &chapterFrames)
            childElementIds.append(childTOC.elementId)
        }

        // Encode the TOC frame
        let tocFrame = OutcastID3.Frame.TableOfContentsFrame(
            elementId: toc.elementId,
            isTopLevel: toc.isTopLevel,
            isOrdered: toc.isOrdered,
            childElementIds: childElementIds,
            subFrames: [] // optionally include title frame, etc.
        )

        tocFrames.append(tocFrame)
    }

    private static func encodeChapter(_ chapter: ID3Chapter) -> OutcastID3.Frame.ChapterFrame {
        var subFrames: [OutcastID3TagFrame] = []

        if let title = chapter.title {
            subFrames.append(OutcastID3.Frame.StringFrame(type: .title, encoding: .utf8, str: title))
        }

        if let artist = chapter.artist {
            subFrames.append(OutcastID3.Frame.StringFrame(type: .leadArtist, encoding: .utf8, str: artist))
        }

        if let composer = chapter.composer {
            subFrames.append(OutcastID3.Frame.StringFrame(type: .composer, encoding: .utf8, str: composer))
        }

        if let description = chapter.description {
            subFrames.append(OutcastID3.Frame.StringFrame(type: .description, encoding: .utf8, str: description))
        }

        if let comments = chapter.comments {
            subFrames.append(OutcastID3.Frame.CommentFrame(encoding: .utf8, language: "EN", commentDescription: "", comment: comments))
        }

        if let rating = chapter.rating {
            subFrames.append(OutcastID3.Frame.PopularimeterFrame(email: rating.email, rating: rating.rating, playCount: rating.playCount))
        }

        if let explicitSetting = chapter.explicitSetting {
            let frame = OutcastID3.Frame.UserDefinedTextFrame(description: "ITUNESADVISORY", text: explicitSetting, encoding: .utf8)
            subFrames.append(frame)
        }

        if let bpm = chapter.beatsPerMinute {
            subFrames.append(OutcastID3.Frame.StringFrame(type: .beatsPerMinute, encoding: .utf8, str: String(bpm)))
        }

        if let initialKey = chapter.initialKey {
            subFrames.append(OutcastID3.Frame.StringFrame(type: .initialKey, encoding: .utf8, str: initialKey))
        }

        for picture in chapter.pictures {
            let pictureFrame = OutcastID3.Frame.PictureFrame(
                encoding: .isoLatin1,
                mimeType: "image/jpeg",
                pictureType: picture.imageType,
                pictureDescription: picture.description ?? "",
                picture: OutcastID3.Frame.PictureFrame.Picture(image: picture.image)
            )
            subFrames.append(pictureFrame)
        }

        let chapterFrame = OutcastID3.Frame.ChapterFrame(
            elementId: chapter.id,
            startTime: chapter.startTime,
            endTime: chapter.endTime,
            startByteOffset: nil,
            endByteOffset: nil,
            subFrames: subFrames
        )

        return chapterFrame
    }
}
