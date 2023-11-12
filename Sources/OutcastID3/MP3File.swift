//
//  MP3File.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation
import UIKit

public class OutcastID3 {
    public class MP3File {
        // swiftlint: disable:next nesting
        public struct TagProperties {
            public let tag: OutcastID3.ID3Tag
            
            public let startingByteOffset: UInt64
            public let endingByteOffset: UInt64
        }

        let localUrl: URL

        public init(localUrl: URL) throws {
            self.localUrl = localUrl
        }
    }

    public struct Frame {}
}
