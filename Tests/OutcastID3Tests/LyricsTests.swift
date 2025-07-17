
#if canImport(XCTest)
import XCTest
import SnapshotTesting
@testable import OutcastID3

final class LyricsTests: XCTestCase {
    
    ///Make sure we can read a file which has a corrupted lyrics tag, and that we can update
    ///the lyrics successfully. Arguably we should fail the parse, but then we might end up with
    ///two lyrics tags if we subsequently set the lyrics. Should test for this.
    func testReadFileWithCorruptedLyrics() throws {
        
        let mp3File = try loadMP3File(from: TestFileNames.fileWithCorruptedLyics)
        var tag = try mp3File.readID3Tag().tag
        try checkKnownValues(tag)

        tag.unsychronisedLyrics = "New lyrics"
        
        //Save the file as a new one.
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag
        
        try checkKnownValues(tagNew)
        
        XCTAssertEqual(tag.unsychronisedLyrics, tagNew.unsychronisedLyrics)
        
    }
    
    ///Checks the frames withtin the tag against a  known set of values.
    func checkKnownValues(_ tag: OutcastID3.ID3Tag) throws {
        XCTAssertEqual("All We Got (Ofenbach Extended Remix) (Dirty)", tag.title)
        XCTAssertEqual("Robin Schulz ft Kiddo", tag.leadArtist)
    }
}


#endif

