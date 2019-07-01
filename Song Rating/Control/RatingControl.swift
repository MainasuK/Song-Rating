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
//    {
//        didSet {
//            os_log("%{public}s[%{public}ld], %{public}s: rating updated to %ld", ((#file as NSString).lastPathComponent), #line, #function, rating)
//        }
//    }
    let size: NSSize
    let spacing: CGFloat
    
    /// Set host view for display latest rating when rating change
    weak var hostView: NSView?
    
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
        self.size = size
        self.spacing = spacing
        self.image = NSImage(size: NSSize(width: CGFloat(5) * size.width + CGFloat(6) * spacing, height: size.height))
        
        image.isTemplate = true
        drawStars()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RatingControl.iTunesCurrentPlayInfoChanged(_:)), name: .iTunesCurrentPlayInfoChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RatingControl.iTunesRadioSetupRating(_:)), name: .iTunesRadioSetupRating, object: nil)
    }
    
}

extension RatingControl {

    @objc func iTunesCurrentPlayInfoChanged(_ notification: Notification) {
        guard let playInfo = notification.object as? PlayInfo, self.rating != playInfo.rating else {
            return
        }
        
        update(rating: playInfo.rating ?? 0)
    }
    
    @objc func iTunesRadioSetupRating(_ notification: Notification) {
        guard let rating = notification.object as? Int else {
            return
        }
        
        // let userInfo = notification.userInfo
        
        update(rating: rating)
    }

    private func update(rating: Int) {
        let newRating = min(100, max(0, rating))
        guard newRating != self.rating else { return }
        
        self.rating = newRating
        drawStars()
        if let button = hostView {
            button.setNeedsDisplay(button.bounds)
        }
        os_log("%{public}s[%{public}ld], %{public}s: update display only rating %ld", ((#file as NSString).lastPathComponent), #line, #function, rating)
    }
    
    fileprivate func drawStars() {
        let rect = NSRect(origin: .zero, size: image.size)
        image.lockFocus()
        if let context = NSGraphicsContext.current?.cgContext {
            context.clear(rect)
        }
        stars.image.draw(in: rect)
        image.unlockFocus()
    }
    
}

// handle click & drag mouse event on menu bar
extension RatingControl {
    
    func action(from sender: NSButton, with event: NSEvent) {
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
            update(rating: newRating)
            iTunesRadioStation.shared.setRating(newRating)

        default:
            break
        }
    }
    
}
