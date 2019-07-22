//
//  MenuBarRatingControl.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-20.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import os

final class MenuBarRatingControl {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let ratingControl = RatingControl(rating: 0)
    let menuBarIcon: MenuBarIcon
    
    lazy private(set) var menuBarMenu: NSMenu = {
        let menu = NSMenu()
        let preferences = NSMenuItem(title: "Preferences…", action: #selector(MenuBarRatingControl.preferencesMenuItemPressed(_:)), keyEquivalent: ",")
        preferences.target = self
        menu.addItem(preferences)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Song Rating", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }()
    private(set) var isPlaying = false {
        didSet {
            updateMenuBar()
        }
    }
    
    init() {
        menuBarIcon = MenuBarIcon(size: ratingControl.starSize)

        guard let button = statusItem.button else {
            assertionFailure()
            return
        }
        
        button.image = ratingControl.starsImage
        button.sendAction(on: [.leftMouseUp, .rightMouseUp, .leftMouseDragged])
        button.action = #selector(MenuBarRatingControl.action(_:))
        button.target = self
        button.setButtonType(.momentaryChange)
        
        ratingControl.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesCurrentPlayInfoChanged(_:)), name: .iTunesCurrentPlayInfoChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioSetupRating(_:)), name: .iTunesRadioDidSetupRating, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRatingUp(_:)), name: .iTunesRadioRequestTrackRatingUp, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRatingDown(_:)), name: .iTunesRadioRequestTrackRatingDown, object: nil)
    }
    
}

extension MenuBarRatingControl {
    
    private func updateMenuBar() {
        let margin: CGFloat = 4 + 4
        let playingWidth = margin + ratingControl.starsImage.size.width
        let pauseWidth = margin + CGFloat(2) * ratingControl.spacing + ratingControl.starSize.width
        statusItem.length = isPlaying ?  playingWidth : pauseWidth
        statusItem.button?.image = isPlaying ? ratingControl.starsImage : menuBarIcon.image
        statusItem.button?.setButtonType(isPlaying ? .momentaryChange : .onOff)
    }
}

extension MenuBarRatingControl {
    
    @objc func action(_ sender: NSButton) {
        guard let event = NSApp.currentEvent else {
            return
        }

        switch event.type {
        case .leftMouseUp where !isPlaying:
            fallthrough
        case .rightMouseUp:
            let position = sender.convert(event.locationInWindow, to: nil)
            menuBarMenu.popUp(positioning: nil, at: position, in: sender)

        default:
            ratingControl.action(from: sender, with: event)
        }
    }

    @objc func preferencesMenuItemPressed(_ sender: NSMenuItem) {
        WindowManager.shared.open(.preferences)
    }
    
}

// MARK: - RatingControlDelegate
extension MenuBarRatingControl: RatingControlDelegate {
    
    func ratingControl(_ ratingControl: RatingControl, shouldUpdateRating rating: Int) -> Bool {
        return isPlaying
    }
    
    func ratingControl(_ ratingControl: RatingControl, userDidUpdateRating rating: Int) {
        // Update iTunes current track rating
        iTunesRadioStation.shared.setRating(rating)
        statusItem.button?.needsDisplay = true
    }
    
}

extension MenuBarRatingControl {
    
    @objc func iTunesCurrentPlayInfoChanged(_ notification: Notification) {
        guard let playInfo = notification.object as? PlayInfo else {
            return
        }
        isPlaying = playInfo.playerState == .playing
        ratingControl.update(rating: playInfo.notComputedRating ?? 0)
    }
    
    @objc func iTunesRadioSetupRating(_ notification: Notification) {
        guard let change = iTunesRadioStationTrackRatingChange(notification) else {
            return
        }
        
        isPlaying = change.isPlaying
        ratingControl.update(rating: change.rating)
    }
    
    @objc func iTunesRadioRequestTrackRatingUp(_ notification: Notification) {
        guard let change = iTunesRadioStationTrackRatingChange(notification),
        change.isPlaying else {
            return
        }
        
        isPlaying = change.isPlaying
        ratingControl.update(rating: ratingControl.rating + 20)
        iTunesRadioStation.shared.setRating(ratingControl.rating)
    }
    
    @objc func iTunesRadioRequestTrackRatingDown(_ notification: Notification) {
        guard let change = iTunesRadioStationTrackRatingChange(notification),
        change.isPlaying else {
            return
        }
        
        isPlaying = change.isPlaying
        ratingControl.update(rating: ratingControl.rating - 20)
        iTunesRadioStation.shared.setRating(ratingControl.rating)
    }
    
}

