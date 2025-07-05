//
//  XCTestCase+checkKnownValues.swift
//  OutcastID3
//
//  Created by Andy on 05/07/2025.
//
import XCTest
@testable import OutcastID3

extension XCTestCase {
    
    ///Checks the frames withtin the tag against a  known set of values.
    ///If includingTitle is false, we don't check the title frame.
    ///If addOne is specified, we append 1 to string values and add 1 to int values
    func checkKnownValues(_ tag: OutcastID3.ID3Tag, includngTitle: Bool = true, addOne shouldAddOne: Bool = false) throws {
        if includngTitle {
            XCTAssertEqual(TestDataValues.trackTitle.addOne(shouldAddOne), tag.title)
        }
        
        XCTAssertEqual(TestDataValues.subtitle.addOne(shouldAddOne), tag.subtitle)
        XCTAssertEqual(TestDataValues.leadArtist.addOne(shouldAddOne), tag.leadArtist)
        
        XCTAssertEqual(TestDataValues.albumTitle.addOne(shouldAddOne), tag.albumTitle)
        XCTAssertEqual(TestDataValues.albumArtist.addOne(shouldAddOne), tag.albumArtist)
        XCTAssertEqual(TestDataValues.trackNumber.addOne(shouldAddOne), tag.trackNumber?.position)
        XCTAssertEqual(TestDataValues.trackTotal.addOne(shouldAddOne), tag.trackNumber?.total)
        
        XCTAssertEqual(TestDataValues.bpm.addOne(shouldAddOne), tag.beatsPerMinute)
        XCTAssertEqual(TestDataValues.comment.addOne(shouldAddOne), tag.comments)
        XCTAssertEqual(TestDataValues.genre.addOne(shouldAddOne), tag.genre)
        XCTAssertEqual(TestDataValues.initialKey.addOne(shouldAddOne), tag.initialKey)
        XCTAssertEqual(TestDataValues.lyrics.addOne(shouldAddOne), tag.unsychronisedLyrics)
        XCTAssertEqual(TestDataValues.originalReleaseDate.addOne(shouldAddOne), tag.originalReleaseTime)
        XCTAssertEqual(TestDataValues.recordingYear.addOne(shouldAddOne), tag.recordingTime?.component(.year))
        
        XCTAssertEqual(TestDataValues.rating.addOne(shouldAddOne), tag.rating?.toFiveStarRating().value)
        
        try checkKnownPhotos(tag)
        
    }
    
    func checkKnownPhotos(_ tag: OutcastID3.ID3Tag, except photoTypeToSkip: OutcastID3.Frame.PictureFrame.PictureType? = nil) throws {
        XCTAssertEqual(TestDataValues.photos.photos.count, tag.pictureFrames.count)
        for i in 0..<TestDataValues.photos.photos.count {
            let testDataPhoto = TestDataValues.photos.photos[i]
            if testDataPhoto.photoType == photoTypeToSkip {
                continue
            }
            guard let tagPhoto = tag.getPictureFrame(testDataPhoto.photoType) else {
                XCTFail("Could not find photo of type \(testDataPhoto.photoType)")
                return
            }
            guard let testDataImage = try loadImage(from: testDataPhoto.resourceFileName) else { return
            }
            assertImagesMatch(testDataImage, tagPhoto.picture.image)
        }
        
    }
    
    func loadImage(from fileName: String) throws -> UIImage? {
        let imageURL = try testDataURL(for: fileName)
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            XCTFail("Could not load resource image \(fileName) at \(imageURL.path)")
            return nil
        }
        return image
    }

    
}

