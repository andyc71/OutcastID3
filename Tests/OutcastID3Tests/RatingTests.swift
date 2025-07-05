
#if canImport(XCTest)
import XCTest
@testable import OutcastID3

final class RatingTests: XCTestCase {
    
    ///Make sure we can read a file, and when we save it nothing is lost.
    func testFileRating_1Star() throws {
        try testRating(1)
    }
    
    func testFileRating_2Star() throws {
        try testRating(2)
    }
    
    func testFileRating_3Star() throws {
        try testRating(3)
    }
    
    func testFileRating_4Star() throws {
        try testRating(4)
    }
    
    func testFileRating_5Star() throws {
        try testRating(5)
    }
    
    ///Make sure we can read a file, and when we save it nothing is lost.
    func testRating(_ fiveStarRatingValue: Double) throws {
        
        let mp3File = try loadMP3File(from: TestFileNames.taggedFile)
        var tag = try mp3File.readID3Tag().tag
        try checkKnownValues(tag)
        
        tag.rating = FiveStarRating(fiveStarRatingValue).toPopularimeterRating()
        
        //Save the file as a new one.
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag

        let rating = tagNew.rating
        let fiveStarRating = rating?.toFiveStarRating()

        XCTAssertEqual(fiveStarRatingValue, fiveStarRating?.value)
        
    }
    
}

#endif

