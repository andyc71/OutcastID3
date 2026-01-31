//
//  ID3ExplicitSetting.swift
//  OutcastID3
//
//  Created by Codex on 2025-06-12.
//

import Foundation

public enum ID3ExplicitSetting: Equatable {
    case unrated
    case explicit
    case clean

    public init?(itunesAdvisoryValue: String) {
        let normalized = itunesAdvisoryValue.trimmingCharacters(in: CharacterSet(charactersIn: "\0")).trimmingCharacters(in: .whitespacesAndNewlines)
        switch normalized {
        case "", "0":
            self = .unrated
        case "1":
            self = .explicit
        case "2":
            self = .clean
        default:
            return nil
        }
    }

    public var itunesAdvisoryValue: String {
        switch self {
        case .unrated:
            return "0"
        case .explicit:
            return "1"
        case .clean:
            return "2"
        }
    }
}
