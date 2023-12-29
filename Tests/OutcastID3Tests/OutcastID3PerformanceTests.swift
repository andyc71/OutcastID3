
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
    
    func loadMP3File(from fileName: String) throws -> OutcastID3.MP3File {
        let mp3FileURL = try testDataURL(for: fileName)
        let mp3File = try OutcastID3.MP3File(localUrl: mp3FileURL)
        return mp3File
    }
    
    ///Create a URL for a file residing in the test bundle's TestData folder.
    func testDataURL(for fileName: String) throws -> URL {
        guard let mp3FileURL = Bundle.module.resourceURL?.appendingPathComponent("TestData").appendingPathComponent(fileName) else {
            throw ID3TestError(message: "Cannot get bundle resource URL for file \(fileName)")
        }
        return mp3FileURL
    }


}

#endif
