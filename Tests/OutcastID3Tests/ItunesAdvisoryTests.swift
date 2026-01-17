//
//  ItunesAdvisoryTests.swift
//  OutcastID3
//
//  Created by Codex on 2025-06-12.
//

import XCTest
@testable import OutcastID3

final class ItunesAdvisoryTests: XCTestCase {

    func testItunesAdvisory_ReadsFromTag() throws {
        let tag = try loadTag(from: TestFileNames.fileWithChapterMetadata)
        XCTAssertEqual(tag.itunesAdvisory, "1")
    }

    func testItunesAdvisory_WritesAndPersists() throws {
        let mp3File = try loadMP3File(from: TestFileNames.unTaggedFile)
        var tag = try mp3File.readID3Tag().tag

        tag.itunesAdvisory = "2"

        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag

        XCTAssertEqual(tagNew.itunesAdvisory, "2")
    }
}
