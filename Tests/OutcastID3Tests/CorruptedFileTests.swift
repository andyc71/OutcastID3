
#if canImport(XCTest)
import XCTest
import SnapshotTesting
@testable import OutcastID3

final class CorruptedFileTests: XCTestCase {
    
    ///Make sure we can read a file, and when we save it nothing is lost.
    func testReadWriteCorruptedFile() throws {
        
        let mp3File = try loadMP3File(from: TestFileNames.corruptedFile)
        let tag = try mp3File.readID3Tag().tag
        try checkKnownValues(tag)
        
        //Save the file as a new one.
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag
        
        try checkKnownValues(tagNew)
        
        compareFrames(tag, tagNew)
        
    }
    
    ///Make sure we can read a file, and when we save it nothing is lost.
    func testReadWriteCorruptedFile_PictureFrame() throws {
        
        let mp3File = try loadMP3File(from: TestFileNames.corruptedFile_PictureFrame)
        let tag = try mp3File.readID3Tag().tag
        //try checkKnownValues(tag)

        let pictures = tag.pictures
        XCTAssertEqual(pictures.count, 1)
        
        let picture = pictures[0]
        XCTAssertEqual(picture.image.size, CGSize(width: 600, height: 600))
        XCTAssertEqual(picture.description, "목소리 (Original Mix)")
        XCTAssertEqual(picture.imageType, .other)
    }
    
    ///Checks the frames withtin the tag against a  known set of values.
    func checkKnownValues(_ tag: OutcastID3.ID3Tag) throws {
        XCTAssertEqual("Bloom (Original Mix)", tag.title)
        XCTAssertEqual("Cheat Codes, Train", tag.leadArtist)
        XCTAssertEqual(2024, tag.recordingTime?.component(.year))
        
    }
}


#endif

