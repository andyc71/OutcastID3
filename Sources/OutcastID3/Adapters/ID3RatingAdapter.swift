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
            if fiveStarToPopmRating.value == popularimeterRating.rating {
                return FiveStarRating(fiveStarToPopmRating.key)
            }
        }
        return FiveStarRating(0)
    }
    
    func convertFiveStarToPopularimeter(_ fiveStarRating: FiveStarRating) -> PopularimeterRating {
        if let popularimeterRating = fiveStarToPopmRatings[fiveStarRating.value] {
            return PopularimeterRating(rating: popularimeterRating)
        }
        else {
            return PopularimeterRating(rating: 0)
        }
    }

}

