//
//  TestDataValues.swift
//
//
//  Created by Andy on 09/11/2023.
//

import Foundation
import OutcastID3

struct TestFileNames {
    //let mp3FileName = "3s-EverTag.mp3"
    //let mp3FileName = "3s-EverTag-1Photo.mp3"
    static let taggedFile = "3s-MusicTagEditor-3Photos.mp3"
    static let unTaggedFile = "3s-No-Tags.mp3"

}

class TestDataValues {
    
    static let trackTitle = "My Track Title"
    static let leadArtist = "My Artist"
    static let subtitle = "My Subtitle"

    static let albumTitle = "My Album"
    static let albumArtist = "My Album Artist"
    
    static let artists = "My Artist 1, My Artist 2"
    static let bpm = 120
    static let comment = "Comment Line 1\nComment Line 2\nComment Line 3"
    static let composer = "My Composer"
    static let conductor = "My Conductor"
    static let copyright = "(c) My Copyright"
    static let discNumber = 1
    static let discTotal = 2
    static let encoderSettings = "Lavf57.83.100"
    static let genre = "My Genre"
    static let initialKey = "1A"
    static let lyrics = "Lyrics Line 1\nLyrics Line 2\nLyrics Line 3"
    //static var involvedPeople = ""
    static let mixDJ = "My Mix DJ"
    static let mixer = "My Mixer"
    static var originalReleaseDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.date(from: "2020/01/30")!
    }
    static let recordingYear = 2023
    static var recordingTime: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.date(from: "2023/01/01")!
    }
    static let producer = "My Producer"
    static let recordLabal = "My Record Label"
    static let releaseCountry = "My Release Country"
    static let remixer = "My Remixer"
    static let trackNumber = 1
    static let trackTotal = 10
    
    static let rating: Double = 4.0
    static let playCount: UInt = 0
    
    static let photos = TestDataPhotos()

}

struct TestDataPhoto {
    var photoType: OutcastID3.Frame.PictureFrame.PictureType
    var resourceFileName: String
}

struct TestDataPhotos {
    var photos: [TestDataPhoto] = []
    
    init() {
        photos.append(TestDataPhoto(photoType: .coverFront, resourceFileName: "FrontCover.jpg"))
        photos.append(TestDataPhoto(photoType: .coverBack, resourceFileName: "BackCover.jpg"))
        photos.append(TestDataPhoto(photoType: .artist, resourceFileName: "Artist.jpg"))
    }
    
}
