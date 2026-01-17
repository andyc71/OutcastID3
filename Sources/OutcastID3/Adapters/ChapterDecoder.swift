//
//  ChapterBuilder.swift
//  OutcastID3
//
//  Created by Andy on 12/06/2025.
//

import Foundation

// ID3 chapter specification:
// https://id3.org/id3v2-chapters-1.0

/// Decodes Chapter Frames (part of internal persistence layer)
/// to Chapters (public interface).
public struct ChapterDecoder {

    public static func decode(
        tocFrames: [OutcastID3.Frame.TableOfContentsFrame],
        chapterFrames: [OutcastID3.Frame.ChapterFrame]
    ) -> ID3TableOfContents? {
        let tocById = Dictionary(uniqueKeysWithValues: tocFrames.map { ($0.elementId, $0) })
        let chapterById = Dictionary(uniqueKeysWithValues: chapterFrames.map { ($0.elementId, $0) })

        guard let topLevel = tocFrames.first(where: \.isTopLevel) else {
            // Need to support case where there is no TOC, but we still have chapters.
            return nil
        }
        
        return buildTOC(from: topLevel, tocById: tocById, chapterById: chapterById)
    }

    private static func buildTOC(
        from tocFrame: OutcastID3.Frame.TableOfContentsFrame,
        tocById: [String: OutcastID3.Frame.TableOfContentsFrame],
        chapterById: [String: OutcastID3.Frame.ChapterFrame]
    ) -> ID3TableOfContents {
        var childTOCs: [ID3TableOfContents] = []
        var chapters: [ID3Chapter] = []

        for id in tocFrame.childElementIds {
            if let childTOCFrame = tocById[id] {
                childTOCs.append(buildTOC(from: childTOCFrame, tocById: tocById, chapterById: chapterById))
            } else if let chapterFrame = chapterById[id] {
                chapters.append(decodeChapter(from: chapterFrame))
            }
        }

        return ID3TableOfContents(
            elementId: tocFrame.elementId,
            isTopLevel: tocFrame.isTopLevel,
            isOrdered: tocFrame.isOrdered,
            childTOCs: childTOCs,
            chapters: chapters
        )
    }

    private static func decodeChapter(from frame: OutcastID3.Frame.ChapterFrame) -> ID3Chapter {
        return ID3Chapter(
            id: frame.elementId,
            title: extractTextFrame(.title, from: frame.subFrames),
            artist: extractTextFrame(.leadArtist, from: frame.subFrames),
            composer: extractTextFrame(.composer, from: frame.subFrames),
            description: extractTextFrame(.description, from: frame.subFrames),
            comments: extractComment(from: frame.subFrames),
            rating: extractRating(from: frame.subFrames),
            explicitSetting: extractUserDefinedText("ITUNESADVISORY", from: frame.subFrames),
            beatsPerMinute: extractBPM(from: frame.subFrames),
            initialKey: extractTextFrame(.initialKey, from: frame.subFrames),
            pictures: extractPictures(from: frame.subFrames),
            startTime: frame.startTime,
            endTime: frame.endTime,
        )
    }

    private static func extractTextFrame(_ stringType: OutcastID3.Frame.StringFrame.StringType, from subFrames: [OutcastID3TagFrame]) -> String? {
        let frame = subFrames.first { $0.frameType == OutcastID3TagFrameType.string(stringType) } as? OutcastID3.Frame.StringFrame
        return frame?.str
    }

    private static func extractBPM(from subFrames: [OutcastID3TagFrame]) -> Int? {
        guard let bpmString = extractTextFrame(.beatsPerMinute, from: subFrames) else {
            return nil
        }
        return Int(bpmString)
    }
    
    private static func extractComment(from subFrames: [OutcastID3TagFrame]) -> String? {
        for frame in subFrames {
            if let commentFrame = frame as? OutcastID3.Frame.CommentFrame {
                return commentFrame.comment
            }
        }
        return nil
    }

    private static func extractRating(from subFrames: [OutcastID3TagFrame]) -> ID3Rating? {
        for frame in subFrames {
            if let popm = frame as? OutcastID3.Frame.PopularimeterFrame {
                return popm.toID3Rating()
            }
        }
        return nil
    }

    private static func extractUserDefinedText(_ description: String, from subFrames: [OutcastID3TagFrame]) -> String? {
        for frame in subFrames {
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

    private static func extractPictures(from subFrames: [OutcastID3TagFrame]) -> [ID3Picture] {
        subFrames.compactMap { frame in
            guard let pictureFrame = frame as? OutcastID3.Frame.PictureFrame else {
                return nil
            }
            return ID3Picture(
                image: pictureFrame.picture.image,
                imageType: pictureFrame.pictureType,
                description: pictureFrame.pictureDescription
            )
        }
    }
}
