//
//  File.swift
//  
//
//  Created by Andy on 12/11/2023.
//

import Foundation

extension OutcastID3 {
    
    public struct ID3Tag {
        public let version: TagVersion
        public var frames: [OutcastID3TagFrame]
        private var indexedFrames: [OutcastID3TagFrameType: OutcastID3TagFrame]
        public var pictureFrames: [OutcastID3.Frame.PictureFrame]
        
        public init(version: TagVersion, frames: [OutcastID3TagFrame]) {
            self.version = version
            self.frames = frames
            
            var indexedFrames = [OutcastID3TagFrameType: OutcastID3TagFrame]()
            var pictureFrames = [OutcastID3.Frame.PictureFrame]()
            for frame in frames {
                // Make sure we're not adding duplicates
                assert(indexedFrames[frame.frameType] == nil)
                // Store the frame
                indexedFrames[frame.frameType] = frame
                if let pictureFrame = frame as? OutcastID3.Frame.PictureFrame {
                    pictureFrames.append(pictureFrame)
                }
            }
            self.indexedFrames = indexedFrames
            self.pictureFrames = pictureFrames
        }
        
        public func getFrame(_ frameType: OutcastID3TagFrameType) -> OutcastID3TagFrame? {
            return indexedFrames[frameType]
        }
        
        public func getChapterFrame() -> OutcastID3.Frame.ChapterFrame? {
            return indexedFrames[.chapter] as? OutcastID3.Frame.ChapterFrame
        }

        public func getCommentFrame() -> OutcastID3.Frame.CommentFrame? {
            return indexedFrames[.comment] as? OutcastID3.Frame.CommentFrame
        }

        public func getPictureFrame(_ pictureType: OutcastID3.Frame.PictureFrame.PictureType) -> OutcastID3.Frame.PictureFrame? {
            return indexedFrames[.picture(pictureType)] as? OutcastID3.Frame.PictureFrame
        }

        public func getStringFrame(_ stringType: OutcastID3.Frame.StringFrame.StringType) -> OutcastID3.Frame.StringFrame? {
            return indexedFrames[.string(stringType)] as? OutcastID3.Frame.StringFrame
        }

        public mutating func setStringFrame(_ stringType: OutcastID3.Frame.StringFrame.StringType, _ newValue: String?) {
            let frameType = OutcastID3TagFrameType.string(stringType)
            if let newValue {
                let frame = OutcastID3.Frame.StringFrame(type: stringType, encoding: .utf8, str: newValue)
                storeFrame(frameType, newFrame: frame)
            }
            else {
                storeFrame(frameType, newFrame: nil)
            }
        }
        
        public func getUIntFrame(_ uIntType: OutcastID3.Frame.UIntFrame.UIntType) -> OutcastID3.Frame.UIntFrame? {
            return indexedFrames[.uInt(uIntType)] as? OutcastID3.Frame.UIntFrame
        }

        public mutating func setUIntFrame(_ uIntType: OutcastID3.Frame.UIntFrame.UIntType, _ newValue: UInt?) {
            let frameType = OutcastID3TagFrameType.uInt(uIntType)
            if let newValue {
                let frame = OutcastID3.Frame.UIntFrame(type: uIntType, value: newValue)
                storeFrame(frameType, newFrame: frame)
            }
            else {
                storeFrame(frameType, newFrame: nil)
            }
        }
        
        public func getPopularimeterFrame() -> OutcastID3.Frame.PopularimeterFrame? {
            return indexedFrames[.popularimeter] as? OutcastID3.Frame.PopularimeterFrame
        }
        
        public mutating func storeFrame(_ frameType: OutcastID3TagFrameType, newFrame: OutcastID3TagFrame?) {
            if let newFrame {
                if let index = self.frames.firstIndex(where: {$0.frameType == frameType}) {
                    self.frames[index] = newFrame
                }
                else {
                    self.frames.append(newFrame)
                }
                self.indexedFrames[frameType] = newFrame
            }
            else {
                if let index = self.frames.firstIndex(where: {$0.frameType == frameType}) {
                    self.frames.remove(at: index)
                }
                self.indexedFrames.removeValue(forKey: frameType)

            }
        }

        public func getTableOfContentsFrame() -> OutcastID3.Frame.TableOfContentsFrame? {
            return indexedFrames[.tableOfContents] as? OutcastID3.Frame.TableOfContentsFrame
        }

        public func getTranscriptionFrame() -> OutcastID3.Frame.TranscriptionFrame? {
            return indexedFrames[.transcription] as? OutcastID3.Frame.TranscriptionFrame
        }
        
        public func getUrlFrame(_ urlType: OutcastID3.Frame.UrlFrame.UrlType) -> OutcastID3.Frame.UrlFrame? {
            return indexedFrames[.url(urlType)] as? OutcastID3.Frame.UrlFrame
        }
        
        public func getUserUrlFrame() -> OutcastID3.Frame.UserUrlFrame? {
            return indexedFrames[.userUrl] as? OutcastID3.Frame.UserUrlFrame
        }

    }
}
