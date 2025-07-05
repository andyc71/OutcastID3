//
//  XCTestCase+compareFrames.swift
//  OutcastID3
//
//  Created by Andy on 05/07/2025.
//
import Foundation
import XCTest
import OutcastID3

extension XCTestCase {
    
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
                XCTAssertEqual(u1.value, u2.value, "Non-matching value in frame \(u1.frameType)")
                
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
    
}

