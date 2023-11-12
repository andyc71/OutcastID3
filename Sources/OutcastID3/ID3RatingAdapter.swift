//
//  ID3RatingAdapter.swift
//
//  Created by Andy Clynes on 12/10/2023.
//  2023 Andy Clynes.
//

import Foundation

/// Converts between ID3Ratings with different rating scales
///
public class ID3RatingAdapter {
    
    public init() { }

    public func adapt(_ popRating: PopularimeterRating) -> FiveStarRating {
        convertPopularimeterToFiveStar(popRating)
    }
    
    public func adapt(_ fiveStarRating: FiveStarRating) -> PopularimeterRating {
        return convertFiveStarToPopularimeter(fiveStarRating)
    }
    
    /// The rating converted to a defacto standard 5 star range as used
    /// by popular apps such as Windows Media Player
    /// 0: unrated = 0
    /// 1 (worst rating) = ID3 value of 1
    /// 2 = 64
    /// 3 = 128
    /// 4 = 196
    /// 5 (best rating) = ID3 value of 255
    private var fiveStarToPopmRatings : [Double : Int] = [
        0:0, 1:1, 2:64, 3:128, 4:196, 5:255
    ]
    
    func convertPopularimeterToFiveStar(_ popularimeterRating: PopularimeterRating) -> FiveStarRating {
        for fiveStarToPopmRating in fiveStarToPopmRatings {
            if fiveStarToPopmRating.value == popularimeterRating.value {
                return FiveStarRating(fiveStarToPopmRating.key)
            }
        }
        return FiveStarRating(0)
    }
    
    func convertFiveStarToPopularimeter(_ fiveStarRating: FiveStarRating) -> PopularimeterRating {
        if let popularimeterRating = fiveStarToPopmRatings[fiveStarRating.value] {
            return PopularimeterRating(popularimeterRating)
        }
        else {
            return PopularimeterRating(0)
        }
    }

}

/**
 A struct to represent a user's song rating within a Popularimeter. A type identifier
 indicates which kind of rating scale is in use, and this will always be converted
 to RatingType.popularimeter when stored within a Popularimeter frame.
 */
public struct PopularimeterRating: Equatable {
    public let value: Int
    
    public init(_ value: Int) {
        self.value = value
    }
    
    public init(_ value: UInt8) {
        self.value = Int(value)
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
