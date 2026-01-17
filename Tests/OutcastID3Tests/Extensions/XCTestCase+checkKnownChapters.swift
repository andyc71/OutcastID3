//
//  XCTestCase+checkKnownChapters.swift
//  OutcastID3
//
//  Created by Andy on 12/06/2025.
//
import XCTest
import OutcastID3

extension XCTestCase {
    
    func checkKnownChapters(_ toc: ID3TableOfContents) {
        
        XCTAssertEqual(toc.childTOCs.count, 0)
        
        let chapters = toc.chapters
        
        XCTAssertEqual(chapters.count, 12)
        
        let chapter1 = chapters[0]
        XCTAssertEqual(chapter1.title, "Chapter 1")
        XCTAssertEqual(chapter1.startTime, TimeInterval(0))
        XCTAssertEqual(chapter1.endTime, TimeInterval(60))
        
        let chapter12 = chapters[11]
        XCTAssertEqual(chapter12.title, "Chapter 12")
        XCTAssertEqual(chapter12.startTime, TimeInterval(13 * 60 + 42))
        XCTAssertEqual(chapter12.endTime.rounded(), TimeInterval(15 * 60))
    }
}

