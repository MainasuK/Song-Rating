//
//  Stars.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-1.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

struct Stars {
    
    let stars: [Star]
    let spacing: CGFloat
    
    init(stars: [Star], spacing: CGFloat) {
        self.stars = stars
        self.spacing = spacing
    }
    
    var image: NSImage {
        return Stars.image(stars: stars, spacing: spacing)
    }
    
    static func image(stars: [Star], spacing: CGFloat) -> NSImage {
        let width = stars.map { $0.size.width }.reduce(into: 0.0, { $0 += $1 }) + CGFloat(stars.count + 1) * spacing
        let height = stars.map { $0.size.height }.max() ?? 0.0
        
        let canvasImage = NSImage(size: NSSize(width: width, height: height))
        canvasImage.lockFocus()
        for (i, star) in stars.enumerated() {
            let origin = CGPoint(x: spacing * CGFloat(1 + i) + star.size.width * CGFloat(i), y: 0.5 * (height - star.size.height))
            star.image.draw(in: NSRect(origin: origin, size: star.size))
        }
        canvasImage.unlockFocus()
        
        return canvasImage
    }
    
}
