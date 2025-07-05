//
//  XCTestCase+compareImages.swift
//  OutcastID3
//
//  Created by Andy on 05/07/2025.
//
import Foundation
import XCTest
import SnapshotTesting

extension XCTestCase {
    
    func assertImagesMatch(_ image1: UIImage?, _ image2: UIImage?) {
        
        if image1 == nil && image2 == nil {
            return
        }
        
        if image1 != nil && image2 == nil {
            XCTFail("image2 is nil but image1 is not nil")
            return
        }
        
        if image2 != nil && image1 == nil {
            XCTFail("image1 is nil but image2 is not nil")
            return
        }
        
        guard let image1, let image2 else { return }
        
        if let (failureMessage, attachments) = imageDiffer.diff(image1, image2) {
            //assertSnapshots(of: <#T##Value#>, as: <#T##[String : Snapshotting<Value, Format>]#>)
            
            //add(<#T##attachment: XCTAttachment##XCTAttachment#>)
            
            var issue = XCTIssue(type: .assertionFailure, compactDescription: failureMessage)
            //issue.add(headers)
            for attachment in attachments {
                issue.add(attachment)
            }
            self.record(issue)
            
            //            XCTContext.runActivity(named: "Attached Failure Diff") { activity in
            //              attachments.forEach {
            //                activity.add($0)
            //              }
            //            }
            
            //XCTFail("Images do not match \(failure)")
            return
        }
    }
    
    var imageDiffer: Diffing<UIImage> {
        Diffing.image(precision: 0.95, perceptualPrecision: 0.95)
    }
    
    func assertImagesDoNotMatch(_ image1: UIImage?, _ image2: UIImage?) {
        
        if image1 == nil && image2 == nil {
            XCTFail("Images match (both nil)")
        }
        
        if image1 != nil && image2 == nil {
            return
        }
        
        if image2 != nil && image1 == nil {
            return
        }
        
        guard let image1, let image2 else { return }
        
        if let (_, _/*attachments*/) = imageDiffer.diff(image1, image2) {
            return
        }
        
        XCTFail("Images match")
        
    }
    
}
