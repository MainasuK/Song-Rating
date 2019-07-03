//
//  RatingControl.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-1.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import os

class RatingControl {
    
    let image: NSImage
    
    /// 0 ~ 100
    private(set) var rating: Int
    private(set) var isPlaying: Bool

    let size: NSSize
    let spacing: CGFloat
    
    /// Set host view for display latest rating when rating change
    weak var hostView: NSView?
    var shouldHiddenIfNotPlaying = false {
        didSet {
            if !isPlaying { drawStars() }
        }
    }
    
    var stars: Stars {
        let fillCount = rating / 20
        let notFillCount = 5 - fillCount
        
        var stars: [Star] = []
        if fillCount > 0 {
            stars.append(contentsOf: Array(repeating: Star(size: size, fill: true), count: fillCount))
        }
        if notFillCount > 0 {
            stars.append(contentsOf: Array(repeating: Star(size: size, fill: false), count: notFillCount))
        }
        
        return Stars(stars: stars, spacing: spacing)
    }
    
    init(rating: Int, size: NSSize = NSSize(width: 16, height: 16), spacing: CGFloat = 4) {
        self.rating = rating
        self.isPlaying = false
        self.size = size
        self.spacing = spacing
        self.image = NSImage(size: NSSize(width: CGFloat(5) * size.width + CGFloat(6) * spacing, height: size.height))
        
        image.isTemplate = true
        image.cacheMode = .never
        drawStars()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RatingControl.iTunesCurrentPlayInfoChanged(_:)), name: .iTunesCurrentPlayInfoChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RatingControl.iTunesRadioSetupRating(_:)), name: .iTunesRadioDidSetupRating, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RatingControl.iTunesRadioRequestTrackRatingUp(_:)), name: .iTunesRadioRequestTrackRatingUp, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RatingControl.iTunesRadioRequestTrackRatingDown(_:)), name: .iTunesRadioRequestTrackRatingDown, object: nil)
    }
    
}

extension RatingControl {

    @objc func iTunesCurrentPlayInfoChanged(_ notification: Notification) {
        guard let playInfo = notification.object as? PlayInfo,
        let playerState = playInfo.playerState else {
            return
        }
        
        // just update control state and delegate UI draw
        update(rating: playInfo.notComputedRating ?? 0, isPlaying: playerState == .playing)
    }
    
    @objc func iTunesRadioSetupRating(_ notification: Notification) {
        guard let (rating, isPlaying) = extractMetaFromNotification(notification) else {
            return
        }
    
        // just update control state and delegate UI draw
        update(rating: rating, isPlaying: isPlaying)
    }
    
    @objc func iTunesRadioRequestTrackRatingUp(_ notification: Notification) {
        guard let (_, isPlaying) = extractMetaFromNotification(notification), isPlaying else {
            return
        }
        
        // Do not response rating request when not playing
        // Use self rating to update
        update(rating: self.rating + 20, isPlaying: isPlaying)
        // Use self rating to set rating (already +20)
        iTunesRadioStation.shared.setRating(self.rating)
    }
    
    @objc func iTunesRadioRequestTrackRatingDown(_ notification: Notification) {
        guard let (_, isPlaying) = extractMetaFromNotification(notification), isPlaying else {
            return
        }
        
        // do not response rating request when not playing
        update(rating: self.rating - 20, isPlaying: isPlaying)
        // Use self rating to set rating (already -20)
        iTunesRadioStation.shared.setRating(self.rating)
    }
    
    // Note: Should construct model if needs more info
    private func extractMetaFromNotification(_ notification: Notification) -> (rating: Int, isPlaying: Bool)? {
        guard let userInfo = notification.userInfo,
        let rating = userInfo["rating"] as? Int,
        let playerState = userInfo["playerState"] as? iTunesEPlS else {
            return nil
        }
        
        return (rating, playerState == .playing)
    }

    
    /// Update control rating
    ///
    /// - Parameter rating: 0 ~ 100
    private func update(rating: Int, isPlaying: Bool) {
        let newRating = min(100, max(0, rating))
        self.isPlaying = isPlaying
        self.rating = newRating
        
        // Not check duplicate drawing. Just always redraw to make sure UI update
        drawStars()
        if let button = hostView {
            button.setNeedsDisplay(button.bounds)
        }
        os_log("%{public}s[%{public}ld], %{public}s: update rating control %{public}ld - state (%{public}s)", ((#file as NSString).lastPathComponent), #line, #function, newRating, isPlaying ? "Playing" : "Stop")
    }
    
    /// Star draw only method
    fileprivate func drawStars() {
        let rect = NSRect(origin: .zero, size: image.size)
        image.lockFocus()
        if let context = NSGraphicsContext.current?.cgContext {
            context.clear(rect)
        }
        stars.image.draw(in: rect)
        image.unlockFocus()
        
        // Hidden host view when not playing state
        hostView?.isHidden = !shouldHiddenIfNotPlaying ? false : !isPlaying
    }
    
}

// handle click & drag mouse event on menu bar
extension RatingControl {
    
    func action(from sender: NSButton, with event: NSEvent) {
        // only do action when isPlaying
        guard isPlaying else { return }
        
        let width = sender.bounds.size.width
        let imageWidth = image.size.width
        guard width > 0, imageWidth > 0 else { return }
        
        let position = sender.convert(event.locationInWindow, to: nil)  // 4 | image | 4
        let systemLeftMargin = 0.5 * (width - imageWidth)               // 4
        let positionX = position.x - systemLeftMargin                   // -4 ~ image.size.with
        
        var rating: Int?
        let array = Array(0..<5)
        let starsMinX = array.map { i -> CGFloat in
            return spacing * CGFloat(1 + i) + size.width * CGFloat(i)
        }
        let starsMaxX = starsMinX.map { $0 + size.width }
        
        if positionX < starsMinX[0] {
            rating = 0
        } else if positionX > starsMaxX[4] {
            rating = 5
        } else {
            for i in array where positionX > starsMinX[i] && positionX < starsMaxX[i] {
                rating = i + 1
            }
        }
        
        guard let starRating = rating else { return }
        
        switch event.type {
        case .leftMouseUp, .leftMouseDragged:
            let newRating = starRating * 20
            update(rating: newRating, isPlaying: self.isPlaying)
            // Update iTunes current track rating
            iTunesRadioStation.shared.setRating(newRating)

        default:
            break
        }
    }
    
}
