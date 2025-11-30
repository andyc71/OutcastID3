//
//  BugFixTests.swift
//  OutcastID3
//
//  Created by Andy on 30/11/2025.
//
import XCTest
@testable import OutcastID3

final class BugFixTests: XCTestCase {
    
    /// Make sure we can read a file with a Picture frame containing a description in
    /// UTF16 format..
    func test_picture_With_UTF16_Description() throws {
        
        let mp3File = try loadMP3File(from: TestFileNames.picture_With_UTF16_Description)
        let tag = try mp3File.readID3Tag().tag
        //try checkKnownValues(tag)
        
        let pictures = tag.pictures
        XCTAssertEqual(pictures.count, 1)
        
        let picture = pictures[0]
        XCTAssertEqual(picture.image.size, CGSize(width: 512, height: 512))
        XCTAssertEqual(picture.description, "목소리 (Original Mix)")
        XCTAssertEqual(picture.imageType, .coverFront)
    }
    
}
