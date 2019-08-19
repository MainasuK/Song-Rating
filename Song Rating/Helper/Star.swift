//
//  Star.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-1.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

struct Star {
    
    let size: NSSize
    let fill: Bool
    
    init(size: NSSize, fill: Bool) {
        self.size = size
        self.fill = fill
    }
    
    var image: NSImage {
        return Star.image(in: size, fill: fill)
    }
    
    static func image(in size: NSSize, fill: Bool) -> NSImage {
        return NSImage(size: size, flipped: false, drawingHandler: { rect -> Bool in
            let radius = min(rect.height, rect.width) * 0.5
            let center = CGPoint(x: rect.midX, y: rect.midY - 0.5 * 0.191 * radius)
            
//            NSColor.black.setFill()
//            NSColor.black.setStroke()
            
            if !fill {
                let path = NSBezierPath()
                let width = radius * 0.5
                let size = CGSize(width: width, height: width)
                let origin = CGPoint(x: center.x - 0.5 * size.width, y: center.y - 0.5 * size.height)
                path.appendOval(in: NSRect(origin: origin, size: size))
                path.stroke()
                path.fill()
                return true
            }
            
            let points = Star.starPoints(at: center, with: radius)
            let path = NSBezierPath()
            path.move(to: points[0])
            
            for point in points[1...] {
                path.line(to: point)
            }
            path.close()
            
            path.stroke()
            path.fill()
            
            return true
        })
    }
    
}

extension Star {
    
    static func starPoints(at center: CGPoint, with radius: CGFloat) -> [CGPoint] {
        let R = radius  // outer radius
        let r = R * sin(Angle(18).radius) / sin(Angle(126).radius)  // inner radius
        
        return [
            CGPoint(x: R * cos(Angle(162).radius), y: R * sin(Angle(162).radius)),
            CGPoint(x: r * cos(Angle(126).radius), y: r * sin(Angle(126).radius)),
            CGPoint(x: R * cos(Angle(90).radius),  y: R * sin(Angle(90).radius)),
            CGPoint(x: r * cos(Angle(54).radius),  y: r * sin(Angle(54).radius)),
            CGPoint(x: R * cos(Angle(18).radius),  y: R * sin(Angle(18).radius)),
            CGPoint(x: r * cos(Angle(342).radius), y: r * sin(Angle(342).radius)),
            CGPoint(x: R * cos(Angle(306).radius), y: R * sin(Angle(306).radius)),
            CGPoint(x: r * cos(Angle(270).radius), y: r * sin(Angle(270).radius)),
            CGPoint(x: R * cos(Angle(234).radius), y: R * sin(Angle(234).radius)),
            CGPoint(x: r * cos(Angle(198).radius), y: r * sin(Angle(198).radius)),
            ].map {
                CGPoint(x: center.x + $0.x, y: center.y + $0.y)
        }
    }
    
    struct Angle {
        let degree: CGFloat
        var radius: CGFloat {
            return degree * .pi / 180.0
        }
        
        init(_ degree: CGFloat) {
            self.degree = degree
        }
    }
    
}
