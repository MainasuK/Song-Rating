//
//  MenuBarIcon.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-20.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

struct MenuBarIcon {
    
    let image: NSImage
    
    let size: NSSize
    
    init(size: NSSize) {
        self.size = size
        self.image = NSImage(size: size, flipped: false, drawingHandler: { rect -> Bool in
            let radius = min(rect.height, rect.width) * 0.5
            let center = CGPoint(x: rect.midX, y: rect.midY - 0.5 * 0.191 * radius)
            
            let centerDotPath: NSBezierPath = {
                let path = NSBezierPath()
                let width = radius * 0.5
                let size = CGSize(width: width, height: width)
                let origin = CGPoint(x: center.x - 0.5 * size.width, y: center.y - 0.5 * size.height)
                path.appendOval(in: NSRect(origin: origin, size: size))
                return path
            }()
            NSColor.black.setFill()
            NSColor.black.setStroke()
            centerDotPath.stroke()
            centerDotPath.fill()
            
            return true
        })
        
        self.image.isTemplate = true
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(macOS 10.15.0, *)
struct MenuBarIcon_Preview: PreviewProvider {
    
    static var previews: some View {
        NSViewPreview {
            let menuBarIcon = MenuBarIcon(size: NSSize(width: 22, height: 22))
            return NSImageView(image: menuBarIcon.image)
        }
    }
    
}

#endif
