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

    /// Canonical values written for each star level
    private let fiveStarToPopmRatings: [Double: Int] = [
        0: 0,
        1: 1,
        2: 64,
        3: 128,
        4: 196,
        5: 255
    ]
    
    /// Fuzzy reverse mapping using inclusive POPM rating ranges
    /// These are loosely based on how Windows Media Player and Mp3tag interpret the values
    private let popmRatingToFiveStarRanges: [(range: ClosedRange<Int>, stars: Double)] = [
        (0...0, 0),
        (1...32, 1),
        (33...95, 2),
        (96...159, 3),  // includes 128 and 153
        (160...223, 4),
        (224...255, 5)
    ]
    
    /// Converts POPM rating to a 0–5 star rating, using fuzzy matching
    func convertPopularimeterToFiveStar(_ popularimeterRating: PopularimeterRating) -> FiveStarRating {
        for (range, stars) in popmRatingToFiveStarRanges {
            if range.contains(popularimeterRating.rating) {
                return FiveStarRating(stars)
            }
        }
        return FiveStarRating(0)
    }
    
    /// Converts a 0–5 star rating to a canonical POPM value
    func convertFiveStarToPopularimeter(_ fiveStarRating: FiveStarRating) -> PopularimeterRating {
        let popmValue = fiveStarToPopmRatings[fiveStarRating.value] ?? 0
        return PopularimeterRating(rating: popmValue)
    }
}
