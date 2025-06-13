//
//  PopularimeterRating.swift
//  OutcastID3
//
//  Created by Andy on 11/06/2025.
//

public typealias PopularimeterRating = ID3Rating

/**
 A struct to represent a user's song rating within a Popularimeter. A type identifier
 indicates which kind of rating scale is in use, and this will always be converted
 to RatingType.popularimeter when stored within a Popularimeter frame.
 */
public struct ID3Rating: Equatable {
    public let email: String
    public let rating: Int
    public let playCount: Int
    
    public init(email: String, rating: Int, playCount: Int) {
        self.email = email
        self.rating = rating
        self.playCount = playCount
    }
    
    public init(rating: Int) {
        self.email = ""
        self.rating = rating
        self.playCount = 0
    }
    
    public func toFiveStarRating() -> FiveStarRating {
        return ID3RatingAdapter().convertPopularimeterToFiveStar(self)
    }

}

public struct FiveStarRating: Equatable {
    public let value: Double
    
    public var intValue: Int {
        return Int(value)
    }
    
    public init(_ value: Double) {
        self.value = value
    }

    public init(_ value: Int) {
        self.value = Double(value)
    }
    
    public func toPopularimeterRating() -> PopularimeterRating {
        return ID3RatingAdapter().convertFiveStarToPopularimeter(self)
    }
}

/**
 A struct to represent a Popularimeter frame.
 Used only as return type inside `ID3TagContentReader`.
 */
public struct Popularimeter: Equatable {
    /// The email address associated with rating and playcount.
    public let email: String
    /// The user's rating of the song. See Rating struct for possible values.
    public let rating: PopularimeterRating
    /// The number of times the song has been played.
    public let playCount: Int
}
