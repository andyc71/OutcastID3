//
//  ID3Chapter.swift
//  OutcastID3
//
//  Created by Andy on 11/06/2025.
//
import Foundation

public struct ID3Chapter: Equatable {
    public let id: String
    public var title: String?
    public var artist: String?
    public var comments: String?
    public var rating: ID3Rating?
    public var pictures: [ID3Picture]
    public var startTime: TimeInterval
    public var endTime: TimeInterval
    
    public init(id: String, title: String? = nil, artist: String? = nil, comments: String? = nil, rating: ID3Rating? = nil, pictures: [ID3Picture] = [], startTime: TimeInterval, endTime: TimeInterval) {
        self.id = id
        self.title = title
        self.artist = artist
        self.comments = comments
        self.rating = rating
        self.pictures = pictures
        self.startTime = startTime
        self.endTime = endTime
    }

    public func picture(_ pictureType: OutcastID3.Frame.PictureFrame.PictureType) -> ID3Picture? {
        pictures.first(where: { $0.imageType == pictureType })
    }

    public mutating func setPicture(_ pictureType: OutcastID3.Frame.PictureFrame.PictureType, _ pictureImage: OutcastID3.Frame.PictureFrame.Picture.PictureImage?, description: String?) {
        if let pictureImage {
            let picture = ID3Picture(image: pictureImage, imageType: pictureType, description: description)
            if let index = pictures.firstIndex(where: { $0.imageType == pictureType }) {
                pictures[index] = picture
            } else {
                pictures.append(picture)
            }
        } else {
            pictures.removeAll(where: { $0.imageType == pictureType })
        }
    }

    public static func == (lhs: ID3Chapter, rhs: ID3Chapter) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.artist == rhs.artist &&
        lhs.comments == rhs.comments &&
        lhs.rating == rhs.rating &&
        lhs.startTime == rhs.startTime &&
        lhs.endTime == rhs.endTime &&
        pictureSignatureMatches(lhs.pictureSignature, rhs.pictureSignature)
    }

    private var pictureSignature: [(UInt8, String?)] {
        pictures
            .map { ($0.imageType.rawValue, $0.description) }
            .sorted { lhs, rhs in
                if lhs.0 != rhs.0 {
                    return lhs.0 < rhs.0
                }
                return (lhs.1 ?? "") < (rhs.1 ?? "")
            }
    }

    private static func pictureSignatureMatches(_ lhs: [(UInt8, String?)], _ rhs: [(UInt8, String?)]) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        for (left, right) in zip(lhs, rhs) {
            if left.0 != right.0 || left.1 != right.1 {
                return false
            }
        }
        return true
    }
}
