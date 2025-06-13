//
//  XCTestCase+loadTag.swift
//  OutcastID3
//
//  Created by Andy on 12/06/2025.
//

import XCTest
import OutcastID3

extension XCTestCase {
    ///Loads a tag from an mp3 file within the TestData folder in the resource bundle.
    func loadTag(from fileName: String) throws -> OutcastID3.ID3Tag {
        let mp3File = try loadMP3File(from: fileName)
        let tag = try mp3File.readID3Tag().tag
        return tag
    }
    
    func loadMP3File(from fileName: String) throws -> OutcastID3.MP3File {
        let mp3FileURL = try testDataURL(for: fileName)
        let mp3File = try OutcastID3.MP3File(localUrl: mp3FileURL)
        return mp3File
    }
    
    ///Saves an MP3 file to a temp file,, using the supplied tags, and returns the temp file.
    func saveAsTempMP3(originalFile: OutcastID3.MP3File, tag: OutcastID3.ID3Tag) throws -> OutcastID3.MP3File {
        let mp3FileNewURL = try makeTempFileURL()
        try originalFile.writeID3Tag(tag: tag, outputUrl: mp3FileNewURL)
        
        print("New file: \(mp3FileNewURL.path)")
        
        //Re-load the file we just saved, and then compare the frames
        //to the original.
        let mp3FileNew = try OutcastID3.MP3File(localUrl: mp3FileNewURL)
        
        return mp3FileNew
    }
    
    func makeTempFileURL(fileExtension ext: String = ".mp3") throws -> URL {
        let fileName = UUID().uuidString.appending("\(ext)")
        let url = try tempURL(for: fileName)
        return url
    }
    
    ///Create a URL for a file residing in the temp folder.
    func tempURL(for fileName: String) throws -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }

}
