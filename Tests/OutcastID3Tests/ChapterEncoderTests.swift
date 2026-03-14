//
//  ChapterEncoderTests.swift
//  OutcastID3
//
//  Created by Andy on 12/06/2025.
//


import XCTest
import UIKit
@testable import OutcastID3

// Tests the encoding of Chapters (public interface)
// to Chapter Frames (part of internal persistence layer).
// Also tests saving chapters to an MP3 file.
final class ChapterEncoderTests: XCTestCase {

    func testEncoding_SingleTOCWithOneChapter() throws {
        let imageUrl = try testDataURL(for: "FrontCover.jpg")
        let imageData = try Data(contentsOf: imageUrl)
        let image = try XCTUnwrap(UIImage(data: imageData))
        let picture = ID3Picture(image: image, imageType: .coverFront, description: "Front")
        let rating = ID3Rating(email: "a@test.com", rating: 200, playCount: 20)
        let chapter = ID3Chapter(
            id: "ch1",
            title: "Intro",
            artist: "John Doe",
            composer: "Jane Doe",
            description: "Opening section",
            comments: "This is the intro",
            rating: rating,
            explicitSetting: "1",
            beatsPerMinute: 121,
            initialKey: "1A",
            genre: "House / Dance",
            energyLevel: 6,
            pictures: [picture],
            startTime: 0.5,
            endTime: 10.75
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
        XCTAssertEqual(frame.startTime, 0.5)
        XCTAssertEqual(frame.endTime, 10.75)
        XCTAssertNil(frame.startByteOffset)
        XCTAssertNil(frame.endByteOffset)
        XCTAssertEqual(frame.subFrames.count, 12)

        XCTAssertEqual(try XCTUnwrap(stringFrame(.title, in: frame.subFrames)).str, "Intro")
        XCTAssertEqual(try XCTUnwrap(stringFrame(.leadArtist, in: frame.subFrames)).str, "John Doe")
        XCTAssertEqual(try XCTUnwrap(stringFrame(.composer, in: frame.subFrames)).str, "Jane Doe")
        XCTAssertEqual(try XCTUnwrap(stringFrame(.description, in: frame.subFrames)).str, "Opening section")
        XCTAssertEqual(try XCTUnwrap(stringFrame(.beatsPerMinute, in: frame.subFrames)).str, "121")
        XCTAssertEqual(try XCTUnwrap(stringFrame(.initialKey, in: frame.subFrames)).str, "1A")
        XCTAssertEqual(try XCTUnwrap(stringFrame(.contentType, in: frame.subFrames)).str, "House / Dance")

        let commentFrame = try XCTUnwrap(frame.subFrames.compactMap { $0 as? OutcastID3.Frame.CommentFrame }.first)
        XCTAssertEqual(commentFrame.language, "EN")
        XCTAssertEqual(commentFrame.commentDescription, "")
        XCTAssertEqual(commentFrame.comment, "This is the intro")

        let ratingFrame = try XCTUnwrap(frame.subFrames.compactMap { $0 as? OutcastID3.Frame.PopularimeterFrame }.first)
        XCTAssertEqual(ratingFrame.email, rating.email)
        XCTAssertEqual(ratingFrame.rating, rating.rating)
        XCTAssertEqual(ratingFrame.playCount, rating.playCount)

        let advisoryFrame = try XCTUnwrap(userDefinedTextFrame(description: "ITUNESADVISORY", in: frame.subFrames))
        XCTAssertEqual(advisoryFrame.encoding, .utf8)
        XCTAssertEqual(userDefinedTextFrameType(advisoryFrame), .raw(description: "ITUNESADVISORY", text: "1"))

        let energyFrame = try XCTUnwrap(energyLevelFrame(in: frame.subFrames))
        XCTAssertEqual(energyFrame.encoding, .utf8)
        XCTAssertEqual(userDefinedTextFrameType(energyFrame), .energyLevel(level: 6))

        let pictureFrame = try XCTUnwrap(frame.subFrames.compactMap { $0 as? OutcastID3.Frame.PictureFrame }.first)
        XCTAssertEqual(pictureFrame.pictureType, .coverFront)
        XCTAssertEqual(pictureFrame.pictureDescription, "Front")
        assertImagesMatch(pictureFrame.picture.image, image)
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
        let toc = try XCTUnwrap(tag.chapters)
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

    func testEncoding_SaveChapterMetadataToFile() throws {
        let mp3File = try loadMP3File(from: TestFileNames.unTaggedFile)
        var tag = try mp3File.readID3Tag().tag

        let imageUrl = try testDataURL(for: "FrontCover.jpg")
        let imageData = try Data(contentsOf: imageUrl)
        let image = try XCTUnwrap(UIImage(data: imageData))
        let picture = ID3Picture(image: image, imageType: .coverFront, description: "Front")

        let chapter = ID3Chapter(
            id: "ch1",
            title: "Chapter Title",
            artist: "Chapter Artist",
            composer: "Chapter Composer",
            description: "Chapter Description",
            comments: nil,
            rating: ID3Rating(email: "test@example.com", rating: 200, playCount: 12),
            explicitSetting: "1",
            beatsPerMinute: 121,
            initialKey: "1A",
            genre: "House / Dance",
            energyLevel: 6,
            pictures: [picture],
            startTime: 1.25,
            endTime: 10.5
        )

        tag.setChapters([chapter])

        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag
        let toc = try XCTUnwrap(tagNew.chapters)
        let savedChapter = try XCTUnwrap(toc.chapters.first)

        XCTAssertEqual(savedChapter.id, "ch1")
        XCTAssertEqual(savedChapter.title, "Chapter Title")
        XCTAssertEqual(savedChapter.artist, "Chapter Artist")
        XCTAssertEqual(savedChapter.composer, "Chapter Composer")
        XCTAssertEqual(savedChapter.description, "Chapter Description")
        XCTAssertEqual(savedChapter.rating, ID3Rating(email: "test@example.com", rating: 200, playCount: 12))
        XCTAssertEqual(savedChapter.explicitSetting, "1")
        XCTAssertEqual(savedChapter.beatsPerMinute, 121)
        XCTAssertEqual(savedChapter.initialKey, "1A")
        XCTAssertEqual(savedChapter.genre, "House / Dance")
        XCTAssertEqual(savedChapter.energyLevel, 6)
        XCTAssertEqual(savedChapter.startTime, 1.25)
        XCTAssertEqual(savedChapter.endTime, 10.5)

        let savedPicture = try XCTUnwrap(savedChapter.pictures.first)
        XCTAssertEqual(savedPicture.imageType, .coverFront)
        XCTAssertEqual(savedPicture.description, "Front")
        assertImagesMatch(savedPicture.image, image)
    }

    func testEncoding_IncludesPictureFrames() throws {
        let imageUrl = try testDataURL(for: "FrontCover.jpg")
        let imageData = try Data(contentsOf: imageUrl)
        let image = try XCTUnwrap(UIImage(data: imageData))

        let picture = ID3Picture(image: image, imageType: .coverFront, description: "Front")
        let chapter = ID3Chapter(
            id: "ch1",
            title: "Intro",
            artist: nil,
            comments: nil,
            rating: nil,
            pictures: [picture],
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

        let (_, chapterFrames) = ChapterEncoder.encode(toc: toc)
        let chapterFrame = try XCTUnwrap(chapterFrames.first)
        let pictureFrame = chapterFrame.subFrames.compactMap { $0 as? OutcastID3.Frame.PictureFrame }.first

        XCTAssertEqual(pictureFrame?.pictureType, .coverFront)
        XCTAssertEqual(pictureFrame?.pictureDescription, "Front")
    }

    private func stringFrame(
        _ type: OutcastID3.Frame.StringFrame.StringType,
        in subFrames: [OutcastID3TagFrame]
    ) -> OutcastID3.Frame.StringFrame? {
        subFrames
            .compactMap { $0 as? OutcastID3.Frame.StringFrame }
            .first(where: { $0.type == type })
    }

    private func userDefinedTextFrame(
        description: String,
        in subFrames: [OutcastID3TagFrame]
    ) -> OutcastID3.Frame.UserDefinedTextFrame? {
        subFrames
            .compactMap { $0 as? OutcastID3.Frame.UserDefinedTextFrame }
            .first {
                guard case let .raw(frameDescription, _) = userDefinedTextFrameType($0) else {
                    return false
                }
                return frameDescription == description
            }
    }

    private func energyLevelFrame(
        in subFrames: [OutcastID3TagFrame]
    ) -> OutcastID3.Frame.UserDefinedTextFrame? {
        subFrames
            .compactMap { $0 as? OutcastID3.Frame.UserDefinedTextFrame }
            .first {
                if case .energyLevel = userDefinedTextFrameType($0) {
                    return true
                }
                return false
            }
    }

    private func userDefinedTextFrameType(
        _ frame: OutcastID3.Frame.UserDefinedTextFrame
    ) -> OutcastID3.Frame.UserDefinedTextFrame.UserDefinedType {
        guard case let .userDefinedText(type) = frame.frameType else {
            XCTFail("Expected user-defined text frame")
            return .raw(description: "", text: "")
        }
        return type
    }
}
