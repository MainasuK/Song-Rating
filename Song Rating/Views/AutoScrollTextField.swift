//
//  AutoScrollTextField.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-8-18.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

final class AutoScrollTextField: NSTextField {
    
    var scrollLimit = 3
    var scrollTimes = 0
    
    var leftMargin: CGFloat = 20
    var rightMargin: CGFloat = 20
    
    var step: CGFloat = 0.5
    var interval: TimeInterval = 2
    
    private var offsetX: CGFloat = 0
    
    private var intervalTimer: Timer?
    private var scrollTimer: Timer?
    
    private var appendingAttributedStringValue = NSAttributedString()
    private var appendedAttributedStringValue = NSAttributedString()

    override var stringValue: String {
        didSet {
//            let attributes = [
//                NSAttributedString.Key.foregroundColor : textColor ?? NSColor.labelColor,
//                NSAttributedString.Key.font : font ?? NSFont.systemFont(ofSize: 13.0, weight: .semibold)
//            ]
            let attributes = stringValue.isEmpty ? [:] : attributedStringValue.attributes(at: 0, effectiveRange: nil)
            appendingAttributedStringValue = NSAttributedString(string:  "    " + stringValue, attributes: attributes)
            appendedAttributedStringValue = NSAttributedString(string: stringValue + "    " + stringValue, attributes: attributes)
            
            reset()
        }
    }
    
    func scroll() {
        intervalTimer = Timer(timeInterval: interval, repeats: false, block: { [weak self] timer in
            guard let `self` = self else { return }
            
            self.scrollTimer = Timer(timeInterval: 1.0 / 60, repeats: true, block: { [weak self] timer in
                self?.scrolling()
            })
            self.scrollTimer.flatMap {
                RunLoop.current.add($0, forMode: .default)
            }
        })
        
        intervalTimer.flatMap {
            RunLoop.current.add($0, forMode: .default)
        }
    }
    
    
    func reset(clearCounter: Bool = true) {
        if clearCounter {
            scrollTimes = 0
        }
        offsetX = 0
        intervalTimer?.invalidate()
        intervalTimer = nil
        scrollTimer?.invalidate()
        scrollTimer = nil
        needsDisplay = true
    }

}

extension AutoScrollTextField {
    
    private func scrolling() {
        offsetX += self.step
        needsDisplay = true
        
        if offsetX >= appendingAttributedStringValue.size().width {
            reset(clearCounter: false)
            scrollTimes += 1
            
            if scrollTimes < scrollLimit {
                scroll()
            }
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard attributedStringValue.size().width + leftMargin + rightMargin > bounds.width else {
            var origin = NSPoint.zero
            origin.x = 0.5 * (bounds.width - attributedStringValue.size().width)
            attributedStringValue.draw(at: origin)
            
            // cancel scroll
            reset()
            
            return
        }

        let textStorage = NSTextStorage(attributedString: appendedAttributedStringValue)
        let textContainer = NSTextContainer()
        let layoutManager = BezierLayoutManager()

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textStorage.font = font

        let range = layoutManager.glyphRange(for: textContainer)
        layoutManager.drawGlyphs(forGlyphRange: range, at: .zero)

        guard let path = layoutManager.path else {
            assertionFailure()
            return
        }
        
        var transfrom = AffineTransform()
        transfrom.scale(x: 1.0, y: -1.0)
        transfrom.translate(x: leftMargin-offsetX, y: -bounds.height + abs(font!.descender))
        
        path.transform(using: transfrom)
        
        let textColor = self.textColor ?? NSColor.labelColor
        
        let leftGradientStart = (offsetX-leftMargin) / path.bounds.width
        let leftGradientEnd = offsetX / path.bounds.width
        
        let rightGradientStart = (bounds.width - rightMargin - leftMargin + offsetX) / path.bounds.width
        let rightGradientEnd = (bounds.width - leftMargin + offsetX) / path.bounds.width
        
        let gradient = NSGradient(colorsAndLocations:
            (textColor.withAlphaComponent(0), leftGradientStart),
            (textColor, leftGradientEnd),
            (textColor, rightGradientStart),
            (textColor.withAlphaComponent(0), rightGradientEnd)
        )
        
        textColor.setFill()
        gradient?.draw(in: path, angle: 0)
    }
    
}

final class BezierLayoutManager: NSLayoutManager {
    
    var path: NSBezierPath?
    
    // note: this method may call multiple times to show entity string
    override func showCGGlyphs(_ glyphs: UnsafePointer<CGGlyph>, positions: UnsafePointer<NSPoint>, count glyphCount: Int, font: NSFont, matrix textMatrix: AffineTransform, attributes: [NSAttributedString.Key : Any] = [:], in graphicsContext: NSGraphicsContext) {
        
        if path == nil {
            path = NSBezierPath()
            path?.move(to: .zero)
        }
        
        path?.append(withCGGlyphs: glyphs, count: glyphCount, in: font)
    }
    
}
