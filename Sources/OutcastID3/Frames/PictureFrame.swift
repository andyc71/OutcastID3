//
//  PictureFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

extension OutcastID3.Frame {
    public struct PictureFrame: OutcastID3TagFrame {
        static let frameIdentifier = "APIC"
        public var frameType: OutcastID3TagFrameType
        
        public struct Picture: Codable {
            #if canImport(UIKit)
            public typealias PictureImage = UIImage
            #else
            public typealias PictureImage = NSImage
            #endif
            
            public let image: PictureImage
            private var jpegData: Data?
            private var pngData: Data?

            public init(image: PictureImage) {
                self.image = image
                self.jpegData = nil
                self.pngData = nil
            }
            
            init?(data: Data, mimeType: String?) {
                guard let image = PictureImage(data: data) else {
                    return nil
                }
                
                self.image = image
                if let mimeType, mimeType.uppercased().contains("JPEG") {
                    self.jpegData = data
                }
                if let mimeType, mimeType.uppercased().contains("PNG") {
                    self.pngData = data
                }
            }

            var toPngData: Data? {
                if let data = self.pngData {
                    return data
                }
                else {
                    return self.image.pngRepresentation
                }
            }

            var toJpegData: Data? {
                if let data = self.jpegData {
                    return data
                }
                else {
                    return self.image.jpegData(compressionQuality: 0.9)
                }
            }
        }
        
        enum Error: Swift.Error {
            case encodingError
            case decodingError
        }

        public enum PictureType: UInt8, Codable {
            case other              = 0x00
            case fileIcon32x32Png   = 0x01
            case fileIconOther      = 0x02
            case coverFront         = 0x03
            case coverBack          = 0x04
            case leafletPage        = 0x05
            case mediaLabel         = 0x06
            case leadArtist         = 0x07
            case artist             = 0x08
            case conductor          = 0x09
            case bandOrchestra      = 0x0a
            case composer           = 0x0b
            case textWriter         = 0x0c
            case recordingLocation  = 0x0d
            case duringRecording    = 0x0e
            case duringPerformance  = 0x0f
            case movieScreenCapture = 0x10
            case brightColoredFish  = 0x11
            case illustration       = 0x12
            case bandLogotype       = 0x13
            case publisherLogotype  = 0x14
            
            public var description: String {
                switch self {
                    
                case .other:
                    return "Other"
                case .fileIcon32x32Png:
                    return "File Icon 32x32 PNG"
                case .fileIconOther:
                    return "File Icon Other"
                case .coverFront:
                    return "Front Cover"
                case .coverBack:
                    return "Back Cover"
                case .leafletPage:
                    return "Leaflet Page"
                case .mediaLabel:
                    return "Media Label"
                case .leadArtist:
                    return "Lead Artist"
                case .artist:
                    return "Artist"
                case .conductor:
                    return "Conductor"
                case .bandOrchestra:
                    return "Band/Orchestra"
                case .composer:
                    return "Composer"
                case .textWriter:
                    return "Lyricist/Text Writer"
                case .recordingLocation:
                    return "Recording Location"
                case .duringRecording:
                    return "During Recording"
                case .duringPerformance:
                    return "During Performance"
                case .movieScreenCapture:
                    return "Movie Screen Capture"
                case .brightColoredFish:
                    return "Bright Colored Fish"
                case .illustration:
                    return "Illustration"
                case .bandLogotype:
                    return "Band Logotype"
                case .publisherLogotype:
                    return "Publisher Logotype"
                }
            }
        }

        public let encoding: String.Encoding
        public let mimeType: String
        public let pictureType: PictureType
        public let pictureDescription: String
        
        public let picture: Picture
        
        public init(encoding: String.Encoding, mimeType: String, pictureType: PictureType, pictureDescription: String, picture: Picture) {
            self.encoding = encoding
            self.mimeType = mimeType
            self.pictureType = pictureType
            self.pictureDescription = pictureDescription
            self.picture = picture
            self.frameType = .picture(pictureType)
        }
        
        public var debugDescription: String {
            return "mimeType=\(self.mimeType) pictureType=\(self.pictureType.description) pictureDescription=\(String(describing: self.pictureDescription)) picture=\(self.picture)"
        }
    }
}

extension OutcastID3.Frame.PictureFrame {
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }

        // TODO: This should use the correct image type according to the mimetype.
        // AC: Extended to support JPEG.
        let imageData: Data?
        if self.mimeType.uppercased() == "IMAGE/JPEG" {
            imageData = self.picture.toJpegData
        }
        else {
            imageData = self.picture.toPngData
        }
        guard let imageData else {
            throw OutcastID3.MP3File.WriteError.encodingError
        }

        let builder = FrameBuilder(version: version, frameIdentifier: OutcastID3.Frame.PictureFrame.frameIdentifier)
        builder.addStringEncodingByte(encoding: self.encoding)
        
        try builder.addString(
            str: self.mimeType,
            encoding: .isoLatin1,
            includeEncodingByte: false,
            terminator: version.stringTerminator(encoding: .isoLatin1)
        )
        
        builder.append(byte: self.pictureType.rawValue)

        // BUG:
        // If we write a picture description using UTF8, the picture is
        // no longer parsable. isoLatin1 seems to work OK.
        try builder.addString(
            str: self.pictureDescription,
            encoding: self.encoding,
            includeEncodingByte: false,
            terminator: version.stringTerminator(encoding: self.encoding)
        )

        builder.append(data: imageData)
        
        return try builder.data()
    }
}

extension OutcastID3.Frame.PictureFrame {
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        
        var frameContentRangeStart = version.frameHeaderSizeInBytes
        
        let encoding = String.Encoding.fromEncodingByte(byte: data[frameContentRangeStart], version: version)
        frameContentRangeStart += 1
        
        let mimeType = data.readString(offset: &frameContentRangeStart, encoding: .isoLatin1, terminator: version.stringTerminator(encoding: .isoLatin1))
        
        let pictureTypeByte = data[frameContentRangeStart]
        frameContentRangeStart += 1
        
        let pictureType = PictureType(rawValue: pictureTypeByte) ?? .other
        
        let pictureDescription = data.readString(offset: &frameContentRangeStart, encoding: encoding, terminator: version.stringTerminator(encoding: encoding))
        
        let pictureBytes = data.subdata(in: frameContentRangeStart ..< data.count)
        
        guard let picture = Picture(data: pictureBytes, mimeType: mimeType) else {
            return nil
        }
        
        return OutcastID3.Frame.PictureFrame(
            encoding: encoding,
            mimeType: mimeType ?? "",
            pictureType: pictureType,
            pictureDescription: pictureDescription ?? "",
            picture: picture
        )
    }
}

extension OutcastID3.Frame.PictureFrame.Picture {
    enum CodingKeys: String, CodingKey {
        case image
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let data = try container.decode(Data.self, forKey: CodingKeys.image)

        #if canImport(UIKit)
        if #available(iOS 11, tvOS 11, macOS 10.15, *) {
            guard let image = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: data) else {
                throw OutcastID3.Frame.PictureFrame.Error.decodingError
            }

            self.image = image
        }
        else {
            guard let image = NSKeyedUnarchiver.unarchiveObject(with: data) as? PictureImage else {
                throw OutcastID3.Frame.PictureFrame.Error.decodingError
            }

            self.image = image
        }
        #else
        guard let image = NSKeyedUnarchiver.unarchiveObject(with: data) as? PictureImage else {
            throw OutcastID3.Frame.PictureFrame.Error.decodingError
        }

        self.image = image
        #endif
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if #available(iOS 11, tvOS 11, macOS 10.15, *) {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self.image, requiringSecureCoding: false)
            try container.encode(data, forKey: .image)
        }
        else {
            let data = NSKeyedArchiver.archivedData(withRootObject: self.image)
            try container.encode(data, forKey: .image)
        }
    }
}

#if canImport(UIKit)
extension UIImage {
    var pngRepresentation: Data? {
        return self.pngData()
    }
}
#else
extension NSBitmapImageRep {
    var pngRepresentation: Data? {
        return representation(using: .png, properties: [:])
    }
}

extension Data {
    var bitmap: NSBitmapImageRep? {
        return NSBitmapImageRep(data: self)
    }
}

extension NSImage {
    var pngRepresentation: Data? {
        return self.tiffRepresentation?.bitmap?.pngRepresentation
    }
}
#endif
