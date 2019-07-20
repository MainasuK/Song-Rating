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
    func ratingControl(_ ratingControl: RatingControl, didUpdateRating rating: Int)
}

class RatingControl {
    
    weak var delegate: RatingControlDelegate?
    
    let starsImage: NSImage
    
    private let starSize: NSSize
    private let spacing: CGFloat
    /// 0 ~ 100
    private(set) var rating: Int
    
    var stars: Stars {
        let fillCount = rating / 20
        let notFillCount = 5 - fillCount
        
        var stars: [Star] = []
        if fillCount > 0 {
            stars.append(contentsOf: Array(repeating: Star(size: starSize, fill: true), count: fillCount))
        }
        if notFillCount > 0 {
            stars.append(contentsOf: Array(repeating: Star(size: starSize, fill: false), count: notFillCount))
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
        
//        statusItem?.length = (isPlaying ? fiveStarsSize : oneStarSize).width
        drawStars()

        delegate?.ratingControl(self, didUpdateRating: newRating)
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
    
    // handle .leftMouseUp, .leftMouseDragged event on host button
    func action(from sender: NSButton, with event: NSEvent) {
        let width = sender.bounds.size.width
        let imageWidth = starsImage.size.width
        guard width > 0, imageWidth > 0 else { return }
        
        // assert image center aligment without resize and leading & tariling margin added
        let position = sender.convert(event.locationInWindow, to: nil)  //  leading margin | image | trailing margin
        let systemLeftMargin = 0.5 * (width - imageWidth)               //  leading margin (default 4 on menu bar)
        let positionX = position.x - systemLeftMargin                   // -leading margin ~ image.size.with
        
        var rating: Int?
        let array = Array(0..<5)
        let starsMinX = array.map { i -> CGFloat in
            return spacing * CGFloat(1 + i) + starSize.width * CGFloat(i)
        }
        let starsMaxX = starsMinX.map { $0 + starSize.width }
        
        if positionX < starsMinX[0] {
            rating = 0
        } else if positionX > starsMaxX[4] {
            rating = 5
        } else {
            for i in array where positionX > starsMinX[i] && positionX < starsMaxX[i] {
                rating = i + 1
            }
        }
        
        // starRating: 0 ~ 5
        guard let starRating = rating,
        delegate?.ratingControl(self, shouldUpdateRating: starRating * 20) ?? false else {
            return
        }
        
        switch event.type {
        case .leftMouseUp, .leftMouseDragged:
            let newRating = starRating * 20
            update(rating: newRating)

        default:
            break
        }
    }
    
}
