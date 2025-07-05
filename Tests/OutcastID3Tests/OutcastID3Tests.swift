
#if canImport(XCTest)
import XCTest
@testable import OutcastID3

final class OutcastID3Tests: XCTestCase {
    
    ///Make sure we can read a file, and when we save it nothing is lost.
    func testReadWriteFileNoChanges() throws {
        
        let mp3File = try loadMP3File(from: TestFileNames.taggedFile)
        let tag = try mp3File.readID3Tag().tag
        try checkKnownValues(tag)
        
        //Save the file as a new one.
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag

        try checkKnownValues(tagNew)
        
        compareFrames(tag, tagNew)
        
    }
    
    ///Read the file, and make one change (to the title).
    ///Verify that the change is persisted, and nothing else changes.
    func testReadWriteFileWithTitleChange() throws {
        
        let mp3File = try loadMP3File(from: TestFileNames.taggedFile)
        var tag = try mp3File.readID3Tag().tag
        try checkKnownValues(tag)
        
        //Change the title
        tag.title = "New Title"

        //Save the file as a new one.
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag

        XCTAssertEqual(tagNew.title, "New Title")
        
        //Check the remaining tags
        try checkKnownValues(tagNew, includngTitle: false)
        
    }
    
    ///Read the file, and make many changed (to the title).
    ///Verify that the changes are persisted.
    func testReadWriteFileWithManyChanges() throws {
        
        let mp3File = try loadMP3File(from: TestFileNames.taggedFile)
        var tag = try mp3File.readID3Tag().tag
        try checkKnownValues(tag)
        
        //Change all of the fields by adding one to them all.
        appendOneToTagContents(&tag)

        //Save the file as a new one.
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag

        //Check the new values against the known values with one added.
        try checkKnownValues(tagNew, addOne: true)
        
    }

    ///Add a frame that doesn't already exist.
    func testAddNewFrame() throws {
        
        let mp3File = try loadMP3File(from: TestFileNames.taggedFile)
        var tag = try mp3File.readID3Tag().tag
        try checkKnownValues(tag)

        //Make sure we don't have a playcount tag, and then add it.
        XCTAssertNil(tag.playCount)
        tag.playCount = UInt(UInt32.max)
        
        //Save the file as a new one.
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag

        //Check the new values against the known values with one added.
        try checkKnownValues(tagNew)

        XCTAssertEqual(tag.playCount, tagNew.playCount)
        
    }
    
    ///Changes the cover photo to something diffferent, makes sure the
    ///change sticks, and then reverts it back and ensures that still matches the original.
    func testCoverPhotoReplacement() throws {
        let mp3File = try loadMP3File(from: TestFileNames.taggedFile)
        var tag = try mp3File.readID3Tag().tag
        try checkKnownValues(tag)

        //Make sure we already have a front cover picture
        let frontCoverOriginal = tag.getPictureFrame(.coverFront)
        XCTAssertNotNil(frontCoverOriginal)

        //Replace the front cover with a different picure
        guard let backCoverPicture = try loadImage(from: "BackCover.jpg") else { return }
        tag.setPicture(.coverFront, backCoverPicture, description: "")

        //Save the file as a new one.
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        var tagNew = try mp3FileNew.readID3Tag().tag

        //Make sure the cover photo matches
        let frontCoverNew = tag.getPictureFrame(.coverFront)
        assertImagesMatch(backCoverPicture, frontCoverNew?.picture.image)
        
        //Make sure the other photos are still intact.
        try checkKnownPhotos(tag, except: .coverFront)
        
        //Set the front cover back to the original image.
        tagNew.setPicture(.coverFront, frontCoverOriginal?.picture.image, description: "")
        
        let mp3FileNew2 = try saveAsTempMP3(originalFile: mp3FileNew, tag: tagNew)
        let tagNew2 = try mp3FileNew2.readID3Tag().tag
        //Check all the photos now match.
        try checkKnownPhotos(tagNew2)
    }
    
    ///Start with an MP3 with no tags and create some photos..
    func testPhotoCreation() throws {
        let mp3File = try loadMP3File(from: TestFileNames.unTaggedFile)
        var tag = try mp3File.readID3Tag().tag
        XCTAssertEqual(tag.frames.count, 1) //It just has the encoding settings.

        //Replace the front cover with a different picure
        guard let frontCoverPicture = try loadImage(from: "FrontCover.jpg") else { return }
        tag.setPicture(.coverFront, frontCoverPicture, description: "Front cover")

        guard let backCoverPicture = try loadImage(from: "BackCover.jpg") else { return }
        tag.setPicture(.coverBack, backCoverPicture, description: "Back cover")

        guard let artistPicture = try loadImage(from: "Artist.jpg") else { return }
        tag.setPicture(.artist, artistPicture, description: "Artist")

        //Save the file as a new one.
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag

        //Make sure the cover photo matches
        let frontCoverNew = tag.getPictureFrame(.coverFront)
        assertImagesMatch(frontCoverPicture, frontCoverNew?.picture.image)
        
        let backCoverNew = tag.getPictureFrame(.coverBack)
        assertImagesMatch(backCoverPicture, backCoverNew?.picture.image)
        
        let artistNew = tag.getPictureFrame(.artist)
        assertImagesMatch(artistPicture, artistNew?.picture.image)
        
        XCTAssertEqual(tagNew.frames.count, 4)

    }
    
    func testReleaseDate() throws {
        let mp3File = try loadMP3File(from: TestFileNames.dateTestMusicTagEditor)
        let tag = try mp3File.readID3Tag().tag
        //XCTAssertEqual(tag.frames.count, 1) //It just has the encoding settings.
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let date = formatter.date(from: "2020/01/31")
        XCTAssertNotNil(date)
        
        XCTAssertEqual(tag.releaseTime, date)
        XCTAssertEqual(tag.originalReleaseTime, nil)
        
        

    }

    func testOriginalReleaseDate() throws {
        let mp3File = try loadMP3File(from: TestFileNames.dateTestEverTag)
        let tag = try mp3File.readID3Tag().tag
        //XCTAssertEqual(tag.frames.count, 1) //It just has the encoding settings.
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let date = formatter.date(from: "2000/01/31")
        XCTAssertNotNil(date)
        
        XCTAssertEqual(tag.releaseTime, nil)
        XCTAssertEqual(tag.originalReleaseTime, date)

    }
    
    func testGenreConversion() throws {
        
        let mp3File = try loadMP3File(from: TestFileNames.genreTestEverTag)
        let tag = try mp3File.readID3Tag().tag
        XCTAssertEqual(tag.genre, "Funk")
        
        let mp3File2 = try loadMP3File(from: TestFileNames.genreStringTag)
        let tag2 = try mp3File2.readID3Tag().tag
        XCTAssertEqual(tag2.genre, "Dance")

    }
    
    ///Tests a file with a version 4.2 tag, which is supposed to have only SyncSafe frame sizes, but in this case
    ///actually contains an APIC frame with a non-SyncSafe frame size.
    func testVersion2_4_with_Mixed_SyncSafe() throws {
        let mp3File = try loadMP3File(from: TestFileNames.tagVersion4_2_With_Mixed_SyncSafe)
        let tag = try mp3File.readID3Tag().tag
        let picture1 = tag.getPictureFrame(.other)
        
        //Make sure we can read the picture (i.e. the frame with the non-standard size header).
        XCTAssertNotNil(picture1?.picture.image)
        if let picture1 = picture1 {
            XCTAssertGreaterThan(picture1.picture.image.size.width, 50)
            XCTAssertGreaterThan(picture1.picture.image.size.height, 50)
        }
        
        //Save the file as a new one. It will result in the frame being updated with a
        //sync safe frame size, so let's check nothing else changes.
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag
        
        let picture2 = tagNew.getPictureFrame(.other)
        assertImagesMatch(picture1?.picture.image, picture2?.picture.image)
        
        //Compare all the other frames.
        compareFrames(tag, tagNew)
    }
    
    ///Tests a file with a blank album frame (TALB) formatted in such a way that the frame is present, has an encoding, but no data for the
    ///album text. Arguably this is corrupt, but we handle it gracefully by returning an album frame with an empty string.
    func testEmptyAlbumFrame() throws {
        let mp3File = try loadMP3File(from: TestFileNames.emptyAlbumFrame)
        let tag = try mp3File.readID3Tag().tag
        XCTAssertEqual(tag.albumTitle, "")
        
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag
        XCTAssertEqual(tagNew.albumTitle, "")
        
        //Compare all the other frames.
        compareFrames(tag, tagNew)
    }
    
    ///Tests a file an Energy Level within a custom tag.
    func testCustomFrameWithEnergyLevel() throws {
        let mp3File = try loadMP3File(from: TestFileNames.tagWithEnergyLevel)
        let tag = try mp3File.readID3Tag().tag
        XCTAssertEqual(tag.energyLevel, 7)
        
        let mp3FileNew = try saveAsTempMP3(originalFile: mp3File, tag: tag)
        let tagNew = try mp3FileNew.readID3Tag().tag
        XCTAssertEqual(tagNew.energyLevel, 7)
        
        //Compare all the other frames.
        compareFrames(tag, tagNew)
    }

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
    
    ///Appends one to each known frame's value within the tag.
    func appendOneToTagContents(_ tag: inout OutcastID3.ID3Tag) {
        tag.title = TestDataValues.trackTitle.addOne()
        tag.subtitle = TestDataValues.subtitle.addOne()
        tag.leadArtist = TestDataValues.leadArtist.addOne()

        tag.albumTitle = TestDataValues.albumTitle.addOne()
        tag.albumArtist = TestDataValues.albumArtist.addOne()
        tag.trackNumber?.position = TestDataValues.trackNumber.addOne()
        tag.trackNumber?.total = TestDataValues.trackTotal.addOne()

        tag.beatsPerMinute = TestDataValues.bpm.addOne()
        tag.comments = TestDataValues.comment.addOne()
        tag.genre = TestDataValues.genre.addOne()
        tag.initialKey = TestDataValues.initialKey.addOne()
        tag.unsychronisedLyrics = TestDataValues.lyrics.addOne()
        tag.originalReleaseTime = TestDataValues.originalReleaseDate.addOne()
        tag.recordingTime = TestDataValues.recordingTime.addOne()
        tag.playCount = TestDataValues.playCount.addOne()
        
        tag.rating = FiveStarRating(TestDataValues.rating.addOne()).toPopularimeterRating()
    }
    
    
    func compareFramesOld(_ tag: OutcastID3.ID3Tag, _ tagNew: OutcastID3.ID3Tag) throws {
        
        //checkTagContents only verifies the tags that we directly support
        //through the helper classes. The code below goes through everything else.
        XCTAssertEqual(tag.frames.count, tagNew.frames.count)
        for i in 0..<tag.frames.count {
            let oldFrame = tag.frames[i]
            let newFrame = tag.frames[i]
            print("Frame: \(oldFrame.debugDescription)")
            XCTAssertEqual(oldFrame.frameType, newFrame.frameType)
            
            let oldFrameData = try oldFrame.frameData(version: .v2_4)
            let newFrameData = try newFrame.frameData(version: .v2_4)
            XCTAssertEqual(oldFrameData, newFrameData)
            
            if let oldFrameString = oldFrame as? OutcastID3.Frame.StringFrame {
                guard let newFrameString = newFrame as? OutcastID3.Frame.StringFrame else {
                    XCTFail("Could not convert new frame to string")
                    return
                }
                XCTAssertEqual(oldFrameString.str, newFrameString.str)
            }
        }
    }
    
    func addOne<T: Numeric>(to value: T, _ shouldAddOne: Bool = true) -> T {
        if shouldAddOne {
            return value + 1
        }
        else {
            return value
        }
    }
    
    func addOne(to string: String, _ shouldAddOne: Bool = true) -> String {
        if shouldAddOne {
            return string + "1"
        }
        else {
            return string
        }
    }
    
    func addOne1(to date: Date, _ shouldAddOne: Bool = true) -> Date {
        if shouldAddOne {
            return Calendar.current.date(byAdding: .year, value: 1, to: date)!
        }
        else {
            return date
        }
    }

//    static var allTests = [
//        ("testExample", testExample),
//    ]
}

extension Date {
    func component(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
            return calendar.component(component, from: self)
    }
    func addOne(_ shouldAddOne: Bool = true) -> Date {
        if shouldAddOne {
            return Calendar.current.date(byAdding: .year, value: 1, to: self)!
        }
        else {
            return self
        }
    }
}

extension Int {
    func addOne(_ shouldAddOne: Bool = true) -> Int {
        if shouldAddOne {
            return self + 1
        }
        else {
            return self
        }
    }
}

extension UInt {
    func addOne(_ shouldAddOne: Bool = true) -> UInt {
        if shouldAddOne {
            return self + 1
        }
        else {
            return self
        }
    }
}

extension Double {
    func addOne(_ shouldAddOne: Bool = true) -> Double {
        if shouldAddOne {
            return self + 1.0
        }
        else {
            return self
        }
    }
}
/*
extension Double {
    func addOne(_ shouldAddOne: Bool = true) -> Double {
        if shouldAddOne {
            return self + 1.0
        }
        else {
            return self
        }
    }
}
*/
extension String {
    func addOne(_ shouldAddOne: Bool = true) -> String {
        if shouldAddOne {
            return self + "1"
        }
        else {
            return self
        }
    }
}

struct ID3TestError : Error {
    let message: String
}




#endif

