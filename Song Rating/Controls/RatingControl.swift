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
    
    /// Legacy Big Sur status item container width applied on macOS 11 … 26.
    ///
    /// The two input paths historically compensated with different constants (`10` for
    /// gesture recognizers, `20` for mouse events). That difference is preserved verbatim
    /// so behaviour on macOS 26 and earlier is unchanged.
    private enum LegacyContainerInset {
        static let gesture: CGFloat = 10
        static let event: CGFloat = 20
    }
    
    /// How the host OS lays out a status item button.
    ///
    /// This is the single place where OS-dependent geometry lives. It is an injectable
    /// value rather than an inline `#available` check so every variant stays testable on
    /// any machine: the macOS 11…26 layouts cannot otherwise be exercised on a 27 host.
    enum Layout {
        /// macOS 10.14 … 10.15: the image sits in the button with only its own margin.
        case preBigSur
        /// macOS 11 … 26: Big Sur added a container inset ahead of the image.
        case bigSur(inset: CGFloat)
        /// macOS 27+: the inset is gone and the image is centred in the button.
        case modern
        
        /// The layout of the OS the app is currently running on.
        static var current: Layout {
            if #available(macOS 27.0, *) {
                return .modern
            } else if #available(macOS 11.0, *) {
                // `gesture` and `event` differ; the caller passes the one it wants.
                return .bigSur(inset: LegacyContainerInset.gesture)
            } else {
                return .preBigSur
            }
        }
        
        /// Offset from the button's leading edge to the image's leading edge.
        ///
        /// - Parameter legacyInset: Big Sur container width for the path being used
        ///   (`LegacyContainerInset.gesture` or `.event`); ignored by other layouts.
        func imageOriginX(buttonWidth: CGFloat, imageWidth: CGFloat, legacyInset: CGFloat = 0) -> CGFloat {
            let centred = 0.5 * (buttonWidth - imageWidth)
            switch self {
            case .preBigSur:
                return centred                                        //  leading margin (default 4)
            case .bigSur:
                return legacyInset + centred                          //  Big Sur container + leading margin
            case .modern:
                return centred
            }
        }
    }
    
    /// Cursor position in the host button's coordinate space.
    ///
    /// macOS 27 changed how a status item routes events: the button's subview
    /// hit-testing and the event coordinates no longer reflect where the user actually
    /// clicked. A click anywhere resolved to the same point (roughly the button centre),
    /// so every click produced nearly the same rating and the 4th/5th stars could never
    /// be reached. This is an AppKit behaviour change on 27, not a layout regression;
    /// the geometry itself is still correct.
    ///
    /// The reliable workaround (per the Stats #3456 report and the WWDC26 AppKit
    /// guidance) is to stop trusting the event's own coordinates and instead read the
    /// cursor from screen space, mapping the button's on-screen rect onto its bounds.
    /// This also absorbs any difference between the status item window width and the
    /// button width.
    ///
    /// Only needed on macOS 27+; earlier releases keep the original path so their
    /// behaviour is unchanged.
    private func currentLocation(in sender: NSButton) -> CGPoint? {
        guard #available(macOS 27.0, *), let window = sender.window else {
            return nil
        }
        
        let screenRect = window.convertToScreen(sender.convert(sender.bounds, to: nil))
        guard screenRect.width > 0, screenRect.height > 0 else { return nil }
        
        let mouse = NSEvent.mouseLocation
        guard mouse.x.isFinite, mouse.y.isFinite else { return nil }
        
        // Map the cursor's screen position back into the button's bounds.
        let scaleX = sender.bounds.width / screenRect.width
        let scaleY = sender.bounds.height / screenRect.height
        return CGPoint(x: (mouse.x - screenRect.minX) * scaleX,
                       y: (mouse.y - screenRect.minY) * scaleY)
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
        Self.starRating(at: point,
                        buttonWidth: sender.bounds.size.width,
                        imageWidth: starsImage.size.width,
                        starSize: starSize,
                        spacing: spacing,
                        behavior: behavior,
                        layout: .current,
                        legacyInset: legacyInset)
    }
    
    /// Pure geometry: resolve a point in a button's coordinate space into a star rating.
    ///
    /// Kept free of AppKit state and of `#available` so every layout variant can be
    /// asserted from tests on any host OS.
    ///
    /// - Parameters:
    ///   - point: location in the button's coordinate space.
    ///   - buttonWidth: width of the host button.
    ///   - imageWidth: width of the drawn stars image.
    ///   - starSize: size of a single star.
    ///   - spacing: gap between two stars.
    ///   - behavior: how a position within a star maps to full/half stars.
    ///   - layout: OS layout to interpret the coordinates with.
    ///   - legacyInset: Big Sur container width, used by `.bigSur` only.
    /// - Returns: rating in `0...10` (half-star units), or `nil` if unresolved.
    static func starRating(at point: CGPoint,
                           buttonWidth: CGFloat,
                           imageWidth: CGFloat,
                           starSize: NSSize,
                           spacing: CGFloat,
                           behavior: Behavior,
                           layout: Layout,
                           legacyInset: CGFloat = 0) -> Int? {
        guard buttonWidth > 0, imageWidth > 0 else { return nil }
        
        let systemLeftMargin = layout.imageOriginX(buttonWidth: buttonWidth,
                                                   imageWidth: imageWidth,
                                                   legacyInset: legacyInset)
        let positionX = point.x - systemLeftMargin                      // x in range: -leading margin ~ image.size.with
        
        let minX = (0..<5).map { i in spacing * CGFloat(1 + i) + starSize.width * CGFloat(i) }
        let maxX = minX.map { $0 + starSize.width }
        
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
        action(from: sender, at: position, behavior: behavior, legacyInset: LegacyContainerInset.gesture)
    }
    
    /// Apply the rating for wherever the cursor currently is.
    ///
    /// Used while dragging: macOS 27 does not deliver drag events to the status item
    /// button, so the position is sampled from the cursor instead.
    func action(from sender: NSButton, atCursorWith behavior: Behavior) {
        guard let position = currentLocation(in: sender) else { return }
        action(from: sender, at: position, behavior: behavior, legacyInset: LegacyContainerInset.gesture)
    }
    
    /// Apply a point in the host button's coordinate space as a new rating.
    ///
    /// - Parameters:
    ///   - point: location in the host button's coordinate space.
    ///   - behavior: how a position within a star maps to full/half stars.
    ///   - legacyInset: Big Sur container width compensated on macOS 11 … 26.
    private func action(from sender: NSButton, at point: CGPoint, behavior: Behavior, legacyInset: CGFloat) {
        guard let starRating = starRating(at: point,
                                          in: sender,
                                          behavior: behavior,
                                          legacyInset: legacyInset) else {
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
        
        switch event.type {
        case .leftMouseUp, .leftMouseDragged:
            action(from: sender, at: position, behavior: .full, legacyInset: LegacyContainerInset.event)

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
