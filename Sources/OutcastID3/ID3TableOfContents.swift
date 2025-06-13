//
//  ID3TableOfContents.swift
//  OutcastID3
//
//  Created by Andy on 12/06/2025.
//
import Foundation

public struct ID3TableOfContents {
    public let elementId: String
    public let isOrdered: Bool
    public let isTopLevel: Bool
    public let childTOCs: [ID3TableOfContents]
    public var chapters: [ID3Chapter]

    public init(elementId: String, isTopLevel: Bool, isOrdered: Bool, childTOCs: [ID3TableOfContents], chapters: [ID3Chapter]) {
        self.elementId = elementId
        self.isTopLevel = isTopLevel
        self.isOrdered = isOrdered
        self.childTOCs = childTOCs
        self.chapters = chapters
    }
}
