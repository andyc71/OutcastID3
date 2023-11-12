//
//  ID3Track.swift
//  
//
//  Created by Andy on 12/11/2023.
//

import Foundation

extension OutcastID3 {
    public struct ID3Track {
        public var position: Int
        public var total: Int?
        
        public init(position: Int, total: Int? = nil) {
            self.position = position
            self.total = total
        }
        
        public init?(id3String: String) {
            let elements = id3String.split(separator: "/")
            if elements.count > 0 {
                self.position = Int(elements[0]) ?? 0
                if elements.count > 1 {
                    self.total = Int(elements[1])
                }
            }
            else {
                self.position = 0
            }
        }
        
        var id3String: String {
            if let total {
                return "\(position)/\(total)"
            }
            else {
                return String(position)
            }
        }
        
    }
}
