//
//  ChapterEncoderTests.swift
//  OutcastID3
//
//  Created by Andy on 12/06/2025.
//


import XCTest
@testable import OutcastID3

// Tests the encoding of Chapters (public interface)
// to Chapter Frames (part of internal persistence layer).
// Also tests saving chapters to an MP3 file.
final class ChapterEncoderTests: XCTestCase {

    func testEncoding_SingleTOCWithOneChapter() {
        let chapter = ID3Chapter(
            id: "ch1",
            title: "Intro",
            artist: "John Doe",
            comments: "This is the intro",
            rating: ID3Rating(email: "a@test.com", rating: 200, playCount: 20),
            startTime: 0,
            endTime: 10
        )

        let toc = ID3TableOfContents(
            elementId: "toc1",
            isTopLevel: true,
            isOrdered: true,
            childTOCs: [],
            chapters: [chapter]
        )

        let (tocFrames, chapterFrames) = ChapterEncoder.encode(toc: toc)

        XCTAssertEqual(tocFrames.count, 1)
        XCTAssertEqual(tocFrames.first?.elementId, "toc1")
        XCTAssertEqual(tocFrames.first?.childElementIds, ["ch1"])

        XCTAssertEqual(chapterFrames.count, 1)
        let frame = chapterFrames.first!

        XCTAssertEqual(frame.elementId, "ch1")
        XCTAssertEqual(frame.startTime, 0)
        XCTAssertEqual(frame.endTime, 10)

        let subFrameTypes = frame.subFrames.map { $0.frameType }
        XCTAssertTrue(subFrameTypes.contains(.string(.title)))
        XCTAssertTrue(subFrameTypes.contains(.string(.leadArtist)))
        XCTAssertTrue(subFrameTypes.contains(.comment))
        XCTAssertTrue(subFrameTypes.contains(.popularimeter))
    }
    
    func testEncoding_EmptyTOCProducesOnlyTOCFrame() {
        let toc = ID3TableOfContents(
            elementId: "toc1",
            isTopLevel: true,
            isOrdered: false,
            childTOCs: [],
            chapters: []
        )

        let (tocFrames, chapterFrames) = ChapterEncoder.encode(toc: toc)
        XCTAssertEqual(tocFrames.count, 1)
        XCTAssertEqual(chapterFrames.count, 0)
    }
    
    func testChapterEncoder_handlesNilMetadata() {
        let chapter = ID3Chapter(
            id: "ch1",
            title: nil,
            artist: nil,
            comments: nil,
            rating: nil,
            startTime: 0,
            endTime: 1
        )

        let toc = ID3TableOfContents(
            elementId: "toc1",
            isTopLevel: true,
            isOrdered: false,
            childTOCs: [],
            chapters: [chapter]
        )

        let (_, chapterFrames) = ChapterEncoder.encode(toc: toc)
        XCTAssertEqual(chapterFrames.count, 1)
        XCTAssertEqual(chapterFrames[0].subFrames.count, 0, "Subframes should be empty when metadata is nil")
    }
    
    func testEncoding_SaveChaptersToFile() throws {
        let mp3File = try loadMP3File(from: TestFileNames.fileWithChapters)
        var tag = try mp3File.readID3Tag().tag
        
        //Load the original file and check the chapters
        var toc = try XCTUnwrap(tag.chapters)
        checkKnownChapters(toc)
        
        //Add a new chapter.
        var chapters = try XCTUnwrap(toc.chapters)
        var lastChapter = try XCTUnwrap(chapters.first)
        
        let endOfFile = lastChapter.endTime
        lastChapter.endTime = 13 * 60
        
        let newChapter = ID3Chapter(id: UUID().uuidString, title: "Chapter 13", artist: "Artist 13", comments: "No comment", rating: ID3Rating(email: "", rating: 50, playCount: 20), startTime: lastChapter.endTime, endTime: endOfFile)
        
        chapters.removeLast()
        chapters.append(lastChapter)
        chapters.append(newChapter)
        
        //toc.chapters = chapters
        tag.setChapters(chapters)
        
        //Save the file as a new one.
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag
        
        let newTOC = try XCTUnwrap(tagNew.chapters)
        XCTAssertEqual(newTOC.childTOCs.count, toc.childTOCs.count)
        
        let newChapters = try XCTUnwrap(newTOC.chapters)
        XCTAssertEqual(newChapters.count, chapters.count)
        
        
        let newLastChapter = try XCTUnwrap(newChapters.first)

        XCTAssertEqual(newLastChapter, lastChapter)
        
    }
}

