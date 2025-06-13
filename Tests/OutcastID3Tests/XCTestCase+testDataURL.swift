//
//  XCTestCase+testDataURL.swift
//  OutcastID3
//
//  Created by Andy on 12/06/2025.
//
import XCTest

extension XCTestCase {
    ///Create a URL for a file residing in the test bundle's TestData folder.
    func testDataURL(for fileName: String) throws -> URL {
        guard let mp3FileURL = Bundle.module.resourceURL?.appendingPathComponent("TestData").appendingPathComponent(fileName) else {
            throw ID3TestError(message: "Cannot get bundle resource URL for file \(fileName)")
        }
        return mp3FileURL
    }
}
