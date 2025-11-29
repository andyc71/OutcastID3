//
//  ReadStringTests.swift
//  OutcastID3
//
//  Created by Andy on 29/11/2025.
//


import XCTest
@testable import OutcastID3

final class ReadStringTests: XCTestCase {

    // MARK: - UTF-16 (double-terminated) tests

    func testUTF16_StandardKorean() {
        let s = "목소리 (Original Mix)"
        let data = utf16LEData(s) + Data([0x00,0x00])               // terminator
        var o = 0
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .utf16,
                                       terminator: .double), s)
        XCTAssertEqual(o, data.count)
    }

    func testUTF16_WithBOM_RemovesIt() {
        let s = "테스트 한글"
        let data = Data([0xFF,0xFE]) + utf16LEData(s) + Data([0x00,0x00])
        var o = 0
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .utf16,
                                       terminator: .double), s)
    }

    func testUTF16_NoTerminatorStillParses() {
        let s = "한국어 테스트"
        let data = utf16LEData(s)                                // no null pair
        var o = 0
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .utf16,
                                       terminator: .double), s)
        XCTAssertEqual(o, data.count)
    }

    func testUTF16_StopsAtDoubleZero() {
        // UTF16 bytes → "ABC" + terminator + junk
        let data = Data([0x41,0x00, 0x42,0x00, 0x43,0x00, 0x00,0x00, 0x44,0x00])
        var o = 0
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .utf16LittleEndian,
                                       terminator: .double), "ABC")
        XCTAssertEqual(o, 8)   // exactly up to null pair
    }

    func testUTF16_BigEndian() {
        let s = "Hello 👍🏼"
        let data = utf16BEData(s) + Data([0x00,0x00])
        var o = 0
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .utf16BigEndian,
                                       terminator: .double), s)
    }

    // MARK: - Single-byte terminator

    func testLatin_SingleTerminated() {
        let data = Data([0x48,0x65,0x6C,0x6C,0x6F,0x00])          // "Hello\0"
        var o = 0
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .isoLatin1,
                                       terminator: .single), "Hello")
        XCTAssertEqual(o, 6)
    }

    func testLatin_NoTerminator() {
        let data = Data("Test123".utf8)
        var o = 0
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .utf8,
                                       terminator: .single), "Test123")
        XCTAssertEqual(o, data.count)
    }

    func testLatinStopsAtNull() {
        let data = Data([0x41,0x42,0x43,0x00,0x44,0x45])          // "ABC\0DE"
        var o = 0
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .utf8,
                                       terminator: .single), "ABC")
        XCTAssertEqual(o, 4)
    }

    // MARK: - Edge Cases

    func testUTF16_WithEmoji() {
        let s = "Mix 🎧 Test"
        let data = utf16LEData(s) + Data([0x00,0x00])
        var o = 0
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .utf16,
                                       terminator: .double), s)
    }

    func testUTF16_EmptyStringWithBOMOnly() {
        let data = Data([0xFF,0xFE, 0x00,0x00])                   // UTF16LE empty
        var o = 0
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .utf16,
                                       terminator: .double), "")
    }

    func testUTF16_MalformedOddLength() {
        let data = Data([0xFF,0xFE, 0x41,0x00, 0x42])             // odd-length
        var o = 0
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .utf16,
                                       terminator: .double), "A")
        XCTAssertTrue(o <= data.count)
    }

    func testOffsetAcrossTwoSequentialReads() {
        let p1 = utf16LEData("Hello") + Data([0x00,0x00])
        let p2 = Data("World".utf8) + Data([0x00])
        let data = p1 + p2

        var o = 0
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .utf16,
                                       terminator: .double), "Hello")
        XCTAssertEqual(data.readString(offset: &o,
                                       encoding: .utf8,
                                       terminator: .single), "World")
        XCTAssertEqual(o, data.count)
    }
}

private func utf16LEBytes(_ s: String) -> [UInt8] {
    Array(s.data(using: .utf16LittleEndian)!)
}

private func utf16LEData(_ s: String) -> Data {
    Data([0xFF,0xFE]) + Data(s.data(using: .utf16LittleEndian)!)
}

private func utf16BEData(_ s: String) -> Data {
    Data([0xFE,0xFF]) + Data(s.data(using: .utf16BigEndian)!)
}
