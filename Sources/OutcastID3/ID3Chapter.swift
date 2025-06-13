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
    public var startTime: TimeInterval
    public var endTime: TimeInterval
    
    public init(id: String, title: String? = nil, artist: String? = nil, comments: String? = nil, rating: ID3Rating? = nil, startTime: TimeInterval, endTime: TimeInterval) {
        self.id = id
        self.title = title
        self.artist = artist
        self.comments = comments
        self.rating = rating
        self.startTime = startTime
        self.endTime = endTime
    }
}
