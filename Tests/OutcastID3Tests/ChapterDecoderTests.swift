//
//  ChapterDecoderTests.swift
//  OutcastID3
//
//  Created by Andy on 12/06/2025.
//


import XCTest
@testable import OutcastID3

// Tests the decoding of Chapter Frames (part of internal persistence layer)
// to Chapters (public interface).
// Also tests loading chapters from an MP3 file.
final class ChapterDecoderTests: XCTestCase {
    
    func testChapterDecoder_withMatchingChapters_returnsChapters() throws {
        let chapterFrame = OutcastID3.Frame.ChapterFrame(
            elementId: "ch1",
            startTime: 10.0,
            endTime: 20.0,
            startByteOffset: nil,
            endByteOffset: nil,
            subFrames: [titleFrame("Chapter 1"), artistFrame("Test Artist"), commentFrame("Interesting part"), ratingFrame(250)]
        )
        
        let tocFrame = OutcastID3.Frame.TableOfContentsFrame(
            elementId: "toc1",
            isTopLevel: true,
            isOrdered: true,
            childElementIds: ["ch1"],
            subFrames: []
        )
        
        let toc = try XCTUnwrap(ChapterDecoder.decode(tocFrames: [tocFrame],
                                         chapterFrames: [chapterFrame]))
        let chapters = toc.chapters
        
        XCTAssertEqual(chapters.count, 1)
        let chapter = chapters[0]
        XCTAssertEqual(chapter.title, "Chapter 1")
        XCTAssertEqual(chapter.artist, "Test Artist")
        XCTAssertEqual(chapter.comments, "Interesting part")
        XCTAssertEqual(chapter.rating, ID3Rating(email: "", rating: 250, playCount: 0))
        XCTAssertEqual(chapter.startTime, 10.0)
        XCTAssertEqual(chapter.endTime, 20.0)
    }
    
    func testChapterDecoder_missingChapterFrame_returnsEmpty() throws {
        let tocFrame = OutcastID3.Frame.TableOfContentsFrame(
            elementId: "toc1",
            isTopLevel: true,
            isOrdered: true,
            childElementIds: ["chX"],
            subFrames: []
        )
        
        let toc = try XCTUnwrap(ChapterDecoder.decode(tocFrames: [tocFrame],
                                         chapterFrames: []))
        let chapters = toc.chapters
        
        XCTAssertEqual(chapters.count, 0)
    }
    
    func testChapterDecoder_withNoSubFrames_returnsChapterWithNilFields() throws {
        let chapterFrame = OutcastID3.Frame.ChapterFrame(
            elementId: "ch1",
            startTime: 0,
            endTime: 100,
            startByteOffset: nil,
            endByteOffset: nil,
            subFrames: [] // no metadata
        )
        
        let tocFrame = OutcastID3.Frame.TableOfContentsFrame(
            elementId: "toc",
            isTopLevel: true,
            isOrdered: true,
            childElementIds: ["ch1"],
            subFrames: []
        )
        
        let toc = try XCTUnwrap(ChapterDecoder.decode(tocFrames: [tocFrame],
                                         chapterFrames: [chapterFrame]))

        let chapters = toc.chapters
        
        XCTAssertEqual(chapters.count, 1)
        let chapter = chapters[0]
        XCTAssertNil(chapter.title)
        XCTAssertNil(chapter.artist)
        XCTAssertNil(chapter.comments)
        XCTAssertNil(chapter.rating)
    }
    
    func testChapterDecoder_LoadChaptersFromFile() throws {
        let mp3File = try loadMP3File(from: TestFileNames.fileWithChapters)
        let tag = try mp3File.readID3Tag().tag
        
        let toc = try XCTUnwrap(tag.chapters)
        
        checkKnownChapters(toc)
    }
    
    
    func testChapterDecoder_MultipleTOCs() throws {
        let childTOC = ID3TableOfContents(
            elementId: "toc2",
            isTopLevel: false,
            isOrdered: false,
            childTOCs: [],
            chapters: [
                ID3Chapter(
                    id: "toc2:ch1",
                    title: "Chapter 2A",
                    artist: "Artist B",
                    comments: nil,
                    rating: ID3Rating(rating: 4),
                    startTime: 0,
                    endTime: 15
                )
            ]
        )
        
        let topLevelTOC = ID3TableOfContents(
            elementId: "toc1",
            isTopLevel: true,
            isOrdered: true,
            childTOCs: [childTOC],
            chapters: [
                ID3Chapter(
                    id: "toc1:ch1",
                    title: "Chapter 1A",
                    artist: "Artist A",
                    comments: nil,
                    rating: ID3Rating(rating: 200),
                    startTime: 0,
                    endTime: 10
                ),
                ID3Chapter(
                    id: "toc1:ch2",
                    title: "Chapter 1B",
                    artist: nil,
                    comments: "Intro comment",
                    rating: nil,
                    startTime: 10,
                    endTime: 20
                )
            ]
        )
        
        // Encode to ID3 frames
        let (tocFrames, chapterFrames) = ChapterEncoder.encode(toc: topLevelTOC)
        XCTAssertEqual(tocFrames.count, 2)
        XCTAssertEqual(chapterFrames.count, 3)
        
        // Decode back
        let decodedTOC = try XCTUnwrap(ChapterDecoder.decode(tocFrames: tocFrames, chapterFrames: chapterFrames))
        
        XCTAssertEqual(decodedTOC.chapters.count, 2)
        XCTAssertEqual(decodedTOC.chapters[0].title, "Chapter 1A")
        
        let secondTOC = try XCTUnwrap(decodedTOC.childTOCs.first)
        XCTAssertNotNil(secondTOC)
        XCTAssertEqual(secondTOC.chapters.count, 1)
        XCTAssertEqual(secondTOC.chapters[0].title, "Chapter 2A")
    }

    // MARK: - Helpers

    func titleFrame(_ title: String) -> OutcastID3TagFrame {
        return OutcastID3.Frame.StringFrame(type: .title, encoding: .utf8, str: title)
    }

    func artistFrame(_ artist: String) -> OutcastID3TagFrame {
        return OutcastID3.Frame.StringFrame(type: .leadArtist, encoding: .utf8, str: artist)
    }

    func commentFrame(_ comment: String) -> OutcastID3TagFrame {
        return OutcastID3.Frame.CommentFrame(encoding: .utf8, language: "EN", commentDescription: "", comment: comment)
    }

    func ratingFrame(_ rawRating: UInt8) -> OutcastID3TagFrame {
        return OutcastID3.Frame.PopularimeterFrame(email: "", rating: Int(rawRating), playCount: 0)
    }
}

