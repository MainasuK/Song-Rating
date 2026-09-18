//
//  RatingControl.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-1.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import os

protocol RatingControlDelegate: class {
    func ratingControl(_ ratingControl: RatingControl, shouldUpdateRating rating: Int) -> Bool
    func ratingControl(_ ratingControl: RatingControl, userDidUpdateRating rating: Int)
}

class RatingControl {
    
    weak var delegate: RatingControlDelegate?
    
    let starsImage: NSImage
    
    let starSize: NSSize
    let spacing: CGFloat
    /// 0 ~ 100
    private(set) var rating: Int
    
    var stars: Stars {
        let fullStarCount = rating / 20
        let halfStarCount: Int = {
            let remainRating = rating - 20 * fullStarCount
            return remainRating / 10
        }()
        let dotCount = 5 - fullStarCount - halfStarCount
        
        var stars: [Star] = []
        if fullStarCount > 0 {
            stars.append(contentsOf: Array(repeating: Star(size: starSize, style: .full), count: fullStarCount))
        }
        if halfStarCount > 0 {
            stars.append(contentsOf: Array(repeating: Star(size: starSize, style: .half), count: halfStarCount))
        }
        if dotCount > 0 {
            stars.append(contentsOf: Array(repeating: Star(size: starSize, style: .dot), count: dotCount))
        }
        
        return Stars(stars: stars, spacing: spacing)
    }
    
    /// Stars rating control constructor
    ///
    /// - Parameters:
    ///   - rating: 0~100
    ///   - size: size for one star
    ///   - spacing: spacing between two stars
    init(rating: Int, starSize: NSSize = NSSize(width: 16, height: 16), spacing: CGFloat = 4) {
        self.rating = rating
        self.starSize = starSize
        self.spacing = spacing
        
        self.starsImage = NSImage(size: NSSize(width: CGFloat(5) * starSize.width + CGFloat(6) * spacing, height: starSize.height))
        
        starsImage.isTemplate = true
        starsImage.cacheMode = .never
        drawStars()
    }
    
}

extension RatingControl {
    
    /// Update control rating
    ///
    /// - Parameter rating: 0 ~ 100
    func update(rating: Int) {
        let newRating = min(100, max(0, rating))
        self.rating = newRating
        
        drawStars()
        os_log("%{public}s[%{public}ld], %{public}s: draw rating control %{public}ld", ((#file as NSString).lastPathComponent), #line, #function, newRating)
    }
    
    /// Stars draw only method
    private func drawStars() {
        let rect = NSRect(origin: .zero, size: starsImage.size)
        starsImage.lockFocus()
        if let context = NSGraphicsContext.current?.cgContext {
            context.clear(rect)
        }
        stars.image.draw(in: rect)
        starsImage.unlockFocus()
    }
    
}

extension RatingControl {
    
    /// Horizontal geometry of the five stars inside `starsImage`.
    ///
    /// Star `i` occupies `starsMinX[i] ..< starsMaxX[i]` in image coordinates.
    private var starsMinX: [CGFloat] {
        (0..<5).map { i in spacing * CGFloat(1 + i) + starSize.width * CGFloat(i) }
    }
    
    private var starsMaxX: [CGFloat] {
        starsMinX.map { $0 + starSize.width }
    }
    
    /// Legacy Big Sur status item container width applied on macOS 11 … 26.
    ///
    /// The two input paths historically compensated with different constants (`10` for
    /// gesture recognizers, `20` for mouse events). That difference is preserved verbatim
    /// so behaviour on macOS 26 and earlier is unchanged.
    private enum LegacyContainerInset {
        static let gesture: CGFloat = 10
        static let event: CGFloat = 20
    }
    
    /// Cursor position in the host button's coordinate space.
    ///
    /// On macOS 27 the status item window is wider than the button and its coordinate
    /// conversion no longer matches the screen, so `NSEvent.locationInWindow` (and the
    /// gesture recognizer's `location(in:)`, which is derived from it) report a point
    /// offset by roughly 40pt — a click on the 5th star was reported as the 3rd star,
    /// and every click on the button resolved to nearly the same rating. That is why it
    /// was impossible to assign more than three stars.
    ///
    /// Convert the true cursor position from screen space instead. This is only needed
    /// on macOS 27+; earlier releases are left on the original path so their behaviour
    /// is unchanged.
    private func currentLocation(in sender: NSButton) -> CGPoint? {
        guard #available(macOS 27.0, *), let window = sender.window else {
            return nil
        }
        let inWindow = window.convertPoint(fromScreen: NSEvent.mouseLocation)
        return sender.convert(inWindow, from: nil)
    }
    
    /// Resolve a point in the host button's coordinate space into a star rating.
    ///
    /// - Parameters:
    ///   - point: location in the host button's coordinate space.
    ///   - legacyInset: Big Sur container width compensated on macOS 11 … 26.
    /// - Returns: rating in `0...10` (units of a half star), or `nil` when the point
    ///   does not resolve to a star.
    ///
    /// - Note: macOS 27 changed the status item window geometry. See
    ///   `currentLocation(in:)` for the coordinate-space problem that made every click
    ///   resolve to the same star and prevented rating above three stars.
    private func starRating(at point: CGPoint, in sender: NSButton, behavior: Behavior, legacyInset: CGFloat) -> Int? {
        let width = sender.bounds.size.width
        let imageWidth = starsImage.size.width
        guard width > 0, imageWidth > 0 else { return nil }
        
        // trailing margin | image | leading margin
        let systemLeftMargin: CGFloat = {
            if #available(macOS 27.0, *) {
                // The image is centered inside the button, so its origin follows the
                // measured button width. Deriving it keeps the hit area aligned with the
                // drawn stars instead of assuming a fixed container inset.
                return 0.5 * (width - imageWidth)
            } else if #available(macOS 11.0, *) {
                return legacyInset + 0.5 * (width - imageWidth)         //  Big Sur magic container width + leading margin
            } else {
                return 0.5 * (width - imageWidth)                       //  leading margin (default 4)
            }
        }()
        let positionX = point.x - systemLeftMargin                      // x in range: -leading margin ~ image.size.with
        
        let minX = starsMinX
        let maxX = starsMaxX
        
        if positionX < minX[0] {
            return 0
        }
        if positionX > maxX[4] {
            return 10
        }
        
        // Inclusive upper bound so a point landing exactly on a star edge still resolves
        // instead of leaving `rating` nil.
        for i in 0..<5 where positionX >= minX[i] && positionX <= maxX[i] {
            switch behavior {
            case .full:
                return 2 * (i + 1)
            case .half:
                return 2 * (i + 1) - 1
            case .both:
                let centerX = 0.5 * (minX[i] + maxX[i])
                return positionX > centerX ? (2 * (i + 1)) : (2 * (i + 1) - 1)
            }
        }
        
        return nil
    }
    
    func action(from sender: NSButton, by gestureRecognizer: NSGestureRecognizer, behavior: Behavior) {
        // Prefer the true cursor position; the recognizer's own location is unreliable
        // on macOS 27. See `currentLocation(in:)`.
        let position = currentLocation(in: sender) ?? gestureRecognizer.location(in: sender)
        guard let starRating = starRating(at: position,
                                          in: sender,
                                          behavior: behavior,
                                          legacyInset: LegacyContainerInset.gesture) else {
            return
        }
        
        // starRating: 0 ~ 10
        guard delegate?.ratingControl(self, shouldUpdateRating: starRating * 10) ?? false else {
            return
        }
        
        let newRating = starRating * 10
        update(rating: newRating)
        delegate?.ratingControl(self, userDidUpdateRating: newRating)
    }
    
    enum Behavior {
        case full
        case half
        case both
    }
    
    
    // handle .leftMouseUp, .leftMouseDragged event on host button
    func action(from sender: NSButton, with event: NSEvent) {
        // `event.locationInWindow` shares the unreliable conversion described in
        // `currentLocation(in:)`, so prefer the true cursor position on macOS 27+.
        let position = currentLocation(in: sender) ?? sender.convert(event.locationInWindow, from: nil)
        
        // starRating: 0 ~ 10
        guard let starRating = starRating(at: position,
                                          in: sender,
                                          behavior: .full,
                                          legacyInset: LegacyContainerInset.event) else {
            return
        }
        
        guard delegate?.ratingControl(self, shouldUpdateRating: starRating * 10) ?? false else {
            return
        }
        
        switch event.type {
        case .leftMouseUp, .leftMouseDragged:
            let newRating = starRating * 10
            update(rating: newRating)
            delegate?.ratingControl(self, userDidUpdateRating: newRating)

        default:
            break
        }
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(macOS 10.15.0, *)
struct RatingControl_Preview: PreviewProvider {
    
    static let ratings: [Int] = Array(stride(from: 0, through: 100, by: 10))
    
    static var previews: some View {
        ForEach(ratings, id: \.self) { rating in
            NSViewPreview {
                let ratingControl = RatingControl(rating: rating)
                return NSImageView(image: ratingControl.starsImage)
            }
        }
    }
    
}

#endif
