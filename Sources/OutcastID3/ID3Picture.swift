//
//  ID3Picture.swift
//  OutcastID3
//
//  Created by Andy on 11/06/2025.
//
import UIKit

public struct ID3Picture {
    public let image: UIImage
    public let imageType: OutcastID3.Frame.PictureFrame.PictureType
    public let description: String?

    public init(image: UIImage, imageType: OutcastID3.Frame.PictureFrame.PictureType, description: String?) {
        self.image = image
        self.imageType = imageType
        self.description = description
    }
}
