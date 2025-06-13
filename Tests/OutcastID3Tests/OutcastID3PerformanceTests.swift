
#if canImport(XCTest)
import XCTest
import SnapshotTesting
@testable import OutcastID3

final class OutcastID3PerformanceTests: XCTestCase {
    
    ///Make sure we can read a file, and when we save it nothing is lost.
    func testReadFileNoChanges() throws {
        
        let mp3File = try loadMP3File(from: TestFileNames.taggedFile)
        let tag = try mp3File.readID3Tag().tag
        
//        //Save the file as a new one.
//        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
//        let tagNew = try mp3FileNew.readID3Tag().tag
                
    }
    
}

#endif
