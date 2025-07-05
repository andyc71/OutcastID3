//
//  PopularimeterRating.swift
//  OutcastID3
//
//  Created by Andy on 05/07/2025.
//
import XCTest
@testable import OutcastID3

final class RatingAdapterTests: XCTestCase {

    let adapter = ID3RatingAdapter()

    func testFiveStarToPopmWriting() {
        XCTAssertEqual(adapter.adapt(FiveStarRating(0)), PopularimeterRating(rating: 0))
        XCTAssertEqual(adapter.adapt(FiveStarRating(1)), PopularimeterRating(rating: 1))
        XCTAssertEqual(adapter.adapt(FiveStarRating(2)), PopularimeterRating(rating: 64))
        XCTAssertEqual(adapter.adapt(FiveStarRating(3)), PopularimeterRating(rating: 128)) // default
        XCTAssertEqual(adapter.adapt(FiveStarRating(4)), PopularimeterRating(rating: 196))
        XCTAssertEqual(adapter.adapt(FiveStarRating(5)), PopularimeterRating(rating: 255))
    }

    func testPopmToFiveStarReading_exactMatches() {
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 0)), FiveStarRating(0))
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 1)), FiveStarRating(1))
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 64)), FiveStarRating(2))
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 128)), FiveStarRating(3))
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 153)), FiveStarRating(3)) // Mp3tag
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 196)), FiveStarRating(4))
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 255)), FiveStarRating(5))
    }

    func testPopmToFiveStarReading_rangeMatches() {
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 10)), FiveStarRating(1))
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 90)), FiveStarRating(2))
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 158)), FiveStarRating(3))
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 160)), FiveStarRating(4))
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 254)), FiveStarRating(5))
    }

    func testOutOfBoundsInputDefaultsToZero() {
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: 999)), FiveStarRating(0))
        XCTAssertEqual(adapter.adapt(PopularimeterRating(rating: -1)), FiveStarRating(0))
    }
}
