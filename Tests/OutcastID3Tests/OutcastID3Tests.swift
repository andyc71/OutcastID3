
#if canImport(XCTest)
import XCTest
import SnapshotTesting
@testable import OutcastID3

final class OutcastID3Tests: XCTestCase {
    
    ///Make sure we can read a file, and when we save it nothing is lost.
    func testReadWriteFileNoChanges() throws {
        
        let mp3File = try loadMP3File(from: TestFileNames.taggedFile)
        let tag = try mp3File.readID3Tag().tag
        try checkKnownValues(tag)
        
        //Save the file as a new one.
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

    

    ///Create a URL for a file residing in the test bundle's TestData folder.
    func testDataURL(for fileName: String) throws -> URL {
        guard let mp3FileURL = Bundle.module.resourceURL?.appendingPathComponent("TestData").appendingPathComponent(fileName) else {
            throw ID3TestError(message: "Cannot get bundle resource URL for file \(fileName)")
        }
        return mp3FileURL
    }
    
    ///Create a URL for a file residing in the temp folder.
    func tempURL(for fileName: String) throws -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }
    
    func makeTempFileURL(fileExtension ext: String = "mp3") throws -> URL {
        let fileName = UUID().uuidString.appending("\(ext)")
        let url = try tempURL(for: fileName)
        return url
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
    
    func loadMP3File(from fileName: String) throws -> OutcastID3.MP3File {
        let mp3FileURL = try testDataURL(for: fileName)
        let mp3File = try OutcastID3.MP3File(localUrl: mp3FileURL)
        return mp3File
    }
    
    ///Loads a tag from an mp3 file within the TestData folder in the resource bundle.
    func loadTag(from fileName: String) throws -> OutcastID3.ID3Tag {
        let mp3File = try loadMP3File(from: fileName)
        let tag = try mp3File.readID3Tag().tag
        return tag
    }
    
    func loadImage(from fileName: String) throws -> UIImage? {
        let imageURL = try testDataURL(for: fileName)
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            XCTFail("Could not load resource image \(fileName) at \(imageURL.path)")
            return nil
        }
        return image
    }
    
    ///Saves an MP3 file to a temp file,, using the supplied tags, and returns the temp file.
    func saveAsTempMP3(originalFile: OutcastID3.MP3File, tag: OutcastID3.ID3Tag) throws -> OutcastID3.MP3File {
        let mp3FileNewURL = try makeTempFileURL()
        try originalFile.writeID3Tag(tag: tag, outputUrl: mp3FileNewURL)
        
        //Re-load the file we just saved, and then compare the frames
        //to the original.
        let mp3FileNew = try OutcastID3.MP3File(localUrl: mp3FileNewURL)
        
        return mp3FileNew
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
        
        tag.rating = FiveStarRating(TestDataValues.rating.addOne()).toPopularimeterRating()
    }
    
    func compareFrames(_ tag1: OutcastID3.ID3Tag, _ tag2: OutcastID3.ID3Tag) {
        let frameCount1 = tag1.frames.count
        let frameCount2 = tag2.frames.count
        XCTAssertEqual(frameCount1, frameCount2)
        if frameCount1 != frameCount2 {
            return
        }
        
        for i in 0..<frameCount1 {
            
            let frame1 = tag1.frames[i]
            let frame2 = tag2.frames[i]
            
            switch frame1 {
                
            case let s1 as OutcastID3.Frame.StringFrame:
                guard let s2 = frame2 as? OutcastID3.Frame.StringFrame else {
                    XCTFail("Expected frame type of \(frame1.frameType) but got \(frame2.frameType)")
                    return
                }
                XCTAssertEqual(s1.frameType, s2.frameType)
                XCTAssertEqual(s1.type, s2.type)
                XCTAssertEqual(s1.str, s2.str)
                XCTAssertEqual(s1.encoding, s2.encoding)
                
            case let u1 as OutcastID3.Frame.UIntFrame:
                guard let u2 = frame2 as? OutcastID3.Frame.UIntFrame else {
                    XCTFail("Expected frame type of \(frame1.frameType) but got \(frame2.frameType)")
                    return
                }
                XCTAssertEqual(u1.frameType, u2.frameType)
                XCTAssertEqual(u1.type, u2.type)
                XCTAssertEqual(u1.value, u2.value)
                
            case let u1 as OutcastID3.Frame.UrlFrame:
                //print("\(u.type.description): \(u)")
                
                guard let u2 = frame2 as? OutcastID3.Frame.UrlFrame else {
                    XCTFail("Expected frame type of \(frame1.frameType) but got \(frame2.frameType)")
                    return
                }
                XCTAssertEqual(u1.frameType, u2.frameType)
                XCTAssertEqual(u1.type, u2.type)
                XCTAssertEqual(u1.url, u2.url)
                XCTAssertEqual(u1.urlString, u2.urlString)

                
            case let c1 as OutcastID3.Frame.CommentFrame:
                //print("Comment: \(comment)")
                guard let c2 = frame2 as? OutcastID3.Frame.CommentFrame else {
                    XCTFail("Expected frame type of \(frame1.frameType) but got \(frame2.frameType)")
                    return
                }
                XCTAssertEqual(c1.frameType, c2.frameType)
                XCTAssertEqual(c1.commentDescription, c2.commentDescription)
                XCTAssertEqual(c1.comment, c2.comment)
                XCTAssertEqual(c1.encoding, c2.encoding)
                XCTAssertEqual(c1.language, c2.language)
                
            case let t1 as OutcastID3.Frame.TranscriptionFrame:
                //print("Transcription: \(transcription)")
                guard let t2 = frame2 as? OutcastID3.Frame.TranscriptionFrame else {
                    XCTFail("Expected frame type of \(frame1.frameType) but got \(frame2.frameType)")
                    return
                }
                XCTAssertEqual(t1.frameType, t2.frameType)
                XCTAssertEqual(t1.lyricsDescription, t2.lyricsDescription)
                XCTAssertEqual(t1.lyrics, t2.lyrics)
                XCTAssertEqual(t1.encoding, t2.encoding)
                XCTAssertEqual(t1.language, t2.language)

                
            case let p1 as OutcastID3.Frame.PictureFrame:
                //print("Picture: \(picture)")
                guard let p2 = frame2 as? OutcastID3.Frame.PictureFrame else {
                    XCTFail("Expected frame type of \(frame1.frameType) but got \(frame2.frameType)")
                    return
                }
                XCTAssertEqual(p1.frameType, p2.frameType)
                XCTAssertEqual(p1.pictureType, p2.pictureType)
                XCTAssertEqual(p1.pictureDescription, p2.pictureDescription)
                XCTAssertEqual(p1.encoding, p2.encoding)
                XCTAssertEqual(p1.mimeType, p2.mimeType)
                assertImagesMatch(p1.picture.image, p2.picture.image)
                
            case let p1 as OutcastID3.Frame.PopularimeterFrame:
                //print("Picture: \(picture)")
                guard let p2 = frame2 as? OutcastID3.Frame.PopularimeterFrame else {
                    XCTFail("Expected frame type of \(frame1.frameType) but got \(frame2.frameType)")
                    return
                }
                XCTAssertEqual(p1.frameType, p2.frameType)
                XCTAssertEqual(p1.email, p2.email)
                XCTAssertEqual(p1.rating, p2.rating)
                XCTAssertEqual(p1.playCount, p2.playCount)
                
            case let f as OutcastID3.Frame.ChapterFrame:
                print("Chapter: \(f)")
                //TODO:
                /*
                guard let p2 = frame2 as? OutcastID3.Frame.PictureFrame else {
                    XCTFail("Expected frame type of \(frame1.frameType) but got \(frame2.frameType)")
                    return
                }
                XCTAssertEqual(p1.frameType, p2.frameType)
                XCTAssertEqual(p1.pictureType, p2.pictureType)
                XCTAssertEqual(p1.pictureDescription, p2.pictureDescription)
                XCTAssertEqual(p1.encoding, p2.encoding)
                XCTAssertEqual(p1.mimeType, p2.mimeType)
                XCTAssertEqual(p1.picture, p2.picture)
                */
                
            case let toc as OutcastID3.Frame.TableOfContentsFrame:
                print("TOC: \(toc)")
                //TODO:
                /*
                guard let p2 = frame2 as? OutcastID3.Frame.PictureFrame else {
                    XCTFail("Expected frame type of \(frame1.frameType) but got \(frame2.frameType)")
                    return
                }
                XCTAssertEqual(p1.frameType, p2.frameType)
                XCTAssertEqual(p1.pictureType, p2.pictureType)
                XCTAssertEqual(p1.pictureDescription, p2.pictureDescription)
                XCTAssertEqual(p1.encoding, p2.encoding)
                XCTAssertEqual(p1.mimeType, p2.mimeType)
                XCTAssertEqual(p1.picture, p2.picture)
                */
            case let rawFrame as OutcastID3.Frame.RawFrame:
                print("Unrecognised frame: \(String(describing: rawFrame.frameIdentifier))")
                //TODO:
                /*
                guard let p2 = frame2 as? OutcastID3.Frame.PictureFrame else {
                    XCTFail("Expected frame type of \(frame1.frameType) but got \(frame2.frameType)")
                    return
                }
                XCTAssertEqual(p1.frameType, p2.frameType)
                XCTAssertEqual(p1.pictureType, p2.pictureType)
                XCTAssertEqual(p1.pictureDescription, p2.pictureDescription)
                XCTAssertEqual(p1.encoding, p2.encoding)
                XCTAssertEqual(p1.mimeType, p2.mimeType)
                XCTAssertEqual(p1.picture, p2.picture)
                */
            default:
                break
            }
        }
    }
    
    func assertImagesMatch(_ image1: UIImage?, _ image2: UIImage?) {
        
        if image1 == nil && image2 == nil {
            return
        }
        
        if image1 != nil && image2 == nil {
            XCTFail("image2 is nil but image1 is not nil")
            return
        }
        
        if image2 != nil && image1 == nil {
            XCTFail("image1 is nil but image2 is not nil")
            return
        }
        
        guard let image1, let image2 else { return }

        if let (failureMessage, attachments) = imageDiffer.diff(image1, image2) {
            //assertSnapshots(of: <#T##Value#>, as: <#T##[String : Snapshotting<Value, Format>]#>)
            
            //add(<#T##attachment: XCTAttachment##XCTAttachment#>)
            
            var issue = XCTIssue(type: .assertionFailure, compactDescription: failureMessage)
                     //issue.add(headers)
            for attachment in attachments {
                issue.add(attachment)
            }
            self.record(issue)
            
//            XCTContext.runActivity(named: "Attached Failure Diff") { activity in
//              attachments.forEach {
//                activity.add($0)
//              }
//            }
            
            //XCTFail("Images do not match \(failure)")
            return
        }
    }
    
    var imageDiffer: Diffing<UIImage> {
        Diffing.image(precision: 0.95, perceptualPrecision: 0.95)
    }
    
    func assertImagesDoNotMatch(_ image1: UIImage?, _ image2: UIImage?) {
        
        if image1 == nil && image2 == nil {
            XCTFail("Images match (both nil)")
        }
        
        if image1 != nil && image2 == nil {
            return
        }
        
        if image2 != nil && image1 == nil {
            return
        }
        
        guard let image1, let image2 else { return }

        if let (_, _/*attachments*/) = imageDiffer.diff(image1, image2) {
            return
        }
        
        XCTFail("Images match")

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

