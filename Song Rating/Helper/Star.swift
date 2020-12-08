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
    let style: Style
    
    init(size: NSSize, style: Style) {
        self.size = size
        self.style = style
    }
    
    var image: NSImage {
        return Star.image(in: size, style: style)
    }
    
}

extension Star {
    enum Style {
        case dot
        case full
        case half
    }
}

extension Star {
    
    static func image(in size: NSSize, style: Style) -> NSImage {
        return NSImage(size: size, flipped: false, drawingHandler: { rect -> Bool in
            let radius = min(rect.height, rect.width) * 0.5
            let center = CGPoint(x: rect.midX, y: rect.midY - 0.5 * 0.191 * radius)
            
            switch style {
            case .dot:
                let path = NSBezierPath()
                let width = radius * 0.5
                let size = CGSize(width: width, height: width)
                let origin = CGPoint(x: center.x - 0.5 * size.width, y: center.y - 0.5 * size.height)
                path.appendOval(in: NSRect(origin: origin, size: size))
                path.stroke()
                path.fill()
                return true
            case .full:
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
            case .half:
                let points = Star.halfStarPoints(at: center, with: radius)
                let path = NSBezierPath()
                path.move(to: points[0])
                
                for point in points[1...] {
                    path.line(to: point)
                }
                path.close()
                
                path.stroke()
                path.fill()
                
                return true
            }
        })
    }
    
}

extension Star {
    
    static func starPoints(at center: CGPoint, with radius: CGFloat) -> [CGPoint] {
        let R = radius  // outer radius
        let r = R * sin(Angle(18).radius) / sin(Angle(126).radius)  // inner radius
        
        return [
            CGPoint(x: R * cos(Angle(162).radius), y: R * sin(Angle(162).radius)),  // point at top-left outer corner -> clockwise
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
    
    static func halfStarPoints(at center: CGPoint, with radius: CGFloat) -> [CGPoint] {
        let points = Star.starPoints(at: center, with: radius)
        return points.prefix(3) + points.suffix(3)
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

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(macOS 10.15.0, *)
struct Star_Preview: PreviewProvider {
    
    static var previews: some View {
        Group {
            NSViewPreview {
                let star = Star(size: NSSize(width: 100.0, height: 100.0), style: .dot)
                return NSImageView(image: star.image)
            }
            NSViewPreview {
                let star = Star(size: NSSize(width: 100.0, height: 100.0), style: .full)
                return NSImageView(image: star.image)
            }
            NSViewPreview {
                let star = Star(size: NSSize(width: 100.0, height: 100.0), style: .half)
                return NSImageView(image: star.image)
            }
        }
    }
    
}

#endif
