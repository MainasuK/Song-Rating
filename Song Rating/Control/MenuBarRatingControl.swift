//
//  MenuBarRatingControl.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-20.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import os

protocol TrackingAreaResponderDelegate: class {
    func mouseEntered(with event: NSEvent)
    func mouseExited(with event: NSEvent)
}

final class TrackingAreaResponder: NSView {

    weak var delegate: TrackingAreaResponderDelegate?

    override func mouseEntered(with event: NSEvent) {
        delegate?.mouseEntered(with: event)
    }

    override func mouseExited(with event: NSEvent) {
        delegate?.mouseExited(with: event)
    }

}

protocol PopoverProxyDelegate: class {
    func popoverWillShow(_ notification: Notification)
    func popoverDidShow(_ notification: Notification)
    func popoverShouldDetach(_ popover: NSPopover) -> Bool
}

final class PopoverProxy: NSObject, NSPopoverDelegate {

    weak var delegate: PopoverProxyDelegate?

    func popoverWillShow(_ notification: Notification) {
        delegate?.popoverWillShow(notification)
    }

    func popoverDidShow(_ notification: Notification) {
        delegate?.popoverDidShow(notification)
    }

    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        return delegate?.popoverShouldDetach(popover) ?? false
    }

}

final class MenuBarRatingControl {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let ratingControl = RatingControl(rating: 0)
    let menuBarIcon: MenuBarIcon
    let trackingAreaResponser = TrackingAreaResponder()
    let popover = NSPopover()
    let popoverProxy = PopoverProxy()

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

        let trackingArea = NSTrackingArea(rect: button.bounds, options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved], owner: trackingAreaResponser, userInfo: nil)
        button.addTrackingArea(trackingArea)

        trackingAreaResponser.delegate = self
        popoverProxy.delegate = self
        ratingControl.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesPlayInfoChanged(_:)), name: .iTunesPlayInfoChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioSetupRating(_:)), name: .iTunesRadioDidSetupRating, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRatingUp(_:)), name: .iTunesRadioRequestTrackRatingUp, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRatingDown(_:)), name: .iTunesRadioRequestTrackRatingDown, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.windowDidResize(_:)), name: NSWindow.didResizeNotification, object: nil)
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
        os_log("%{public}s[%{public}ld], %{public}s: menu bar button receive event %s", ((#file as NSString).lastPathComponent), #line, #function, event.debugDescription)

        switch event.type {
        case .leftMouseUp where !isPlaying:
            let position = NSPoint(x: 0, y: sender.bounds.height + 5)
            menuBarMenu.popUp(positioning: nil, at: position, in: sender)

        case .rightMouseUp where !isPlaying:
            let position = sender.convert(event.locationInWindow, to: nil)
            menuBarMenu.popUp(positioning: nil, at: position, in: sender)

        case .leftMouseUp, .leftMouseDragged:
            ratingControl.action(from: sender, with: event)

        case .rightMouseUp:
            guard let button = statusItem.button, !popover.isShown else { return }
            popover.contentViewController = WindowManager.WindowType.about.viewController
            popover.behavior = .transient
            popover.delegate = popoverProxy
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

        default:
            os_log("%{public}s[%{public}ld], %{public}s: no handler for event %s", ((#file as NSString).lastPathComponent), #line, #function, event.debugDescription)
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
    
    @objc func iTunesPlayInfoChanged(_ notification: Notification) {
        guard let playInfo = notification.object as? PlayInfo else {
            return
        }
        isPlaying = playInfo.playerState == .playing
        ratingControl.update(rating: playInfo.notComputedRating ?? 0)
    }
    
    @objc func iTunesRadioSetupRating(_ notification: Notification) {
        guard let change = iTunesRadioStationTrackInfo(notification) else {
            return
        }
        
        isPlaying = change.isPlaying
        ratingControl.update(rating: change.rating)
    }
    
    @objc func iTunesRadioRequestTrackRatingUp(_ notification: Notification) {
        guard let change = iTunesRadioStationTrackInfo(notification),
        change.isPlaying else {
            return
        }
        
        isPlaying = change.isPlaying
        ratingControl.update(rating: ratingControl.rating + 20)
        iTunesRadioStation.shared.setRating(ratingControl.rating)
    }
    
    @objc func iTunesRadioRequestTrackRatingDown(_ notification: Notification) {
        guard let change = iTunesRadioStationTrackInfo(notification),
        change.isPlaying else {
            return
        }
        
        isPlaying = change.isPlaying
        ratingControl.update(rating: ratingControl.rating - 20)
        iTunesRadioStation.shared.setRating(ratingControl.rating)
    }

    @objc func windowDidResize(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else {
            return
        }

        os_log("%{public}s[%{public}ld], %{public}s: window size change to %{public}s", ((#file as NSString).lastPathComponent), #line, #function, window.frame.debugDescription)

    }
    
}

// MARK: - TrackingAreaResponderDelegate
extension MenuBarRatingControl: TrackingAreaResponderDelegate {

    func mouseEntered(with event: NSEvent) {
        os_log("%{public}s[%{public}ld], %{public}s: mouse entered", ((#file as NSString).lastPathComponent), #line, #function)
    }

    func mouseExited(with event: NSEvent) {
        os_log("%{public}s[%{public}ld], %{public}s: mouse exited", ((#file as NSString).lastPathComponent), #line, #function)
    }

}

// MARK: - PopoverProxyDelegate
extension MenuBarRatingControl: PopoverProxyDelegate {

    func popoverWillShow(_ notification: Notification) {
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    func popoverDidShow(_ notification: Notification) {
//        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        return true
    }

}
