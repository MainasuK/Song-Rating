//
//  NSImage.swift
//  
//
//  Created by MainasuK on 2022/11/18.
//

import Cocoa

extension NSImage {
    public func imagePNGRepresentation() -> Data? {
        guard let tiffRepresentation = self.tiffRepresentation,
              let imageRep = NSBitmapImageRep(data: tiffRepresentation),
              let pngData = imageRep.representation(using: .png, properties: [:])
        else { return nil }
        return pngData
    }
    
    public func imageJPEGRepresentation() -> Data? {
        guard let tiffRepresentation = self.tiffRepresentation,
              let imageRep = NSBitmapImageRep(data: tiffRepresentation),
              let pngData = imageRep.representation(using: .jpeg, properties: [:])
        else { return nil }
        return pngData
    }
}
