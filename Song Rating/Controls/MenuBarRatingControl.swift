//
//  MenuBarRatingControl.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-20.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import os
import MASShortcut

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
    func popoverDidClose(_ notification: Notification)
    func popoverShouldDetach(_ popover: NSPopover) -> Bool
    func popoverDidDetach(_ popover: NSPopover)
}

final class PopoverProxy: NSObject, NSPopoverDelegate {

    weak var delegate: PopoverProxyDelegate?
    
    func popoverDidClose(_ notification: Notification) {
        delegate?.popoverDidClose(notification)
    }

    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        return delegate?.popoverShouldDetach(popover) ?? false
    }
    
    func popoverDidDetach(_ popover: NSPopover) {
        delegate?.popoverDidDetach(popover)
    }

}

final class MenuBarRatingControl {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let ratingControl = RatingControl(rating: 0)
    let menuBarIcon: MenuBarIcon
    let trackingAreaResponser = TrackingAreaResponder()
    let popoverProxy = PopoverProxy()
    
    var undetachedPopover: NSPopover?
    var detachedPopover: NSPopover?

    private(set) lazy var menuBarMenu: NSMenu = {
        let menu = NSMenu()
        let about = NSMenuItem(title: "About Song Rating", action: #selector(WindowManager.aboutMenuItemPressed(_:)), keyEquivalent: "")
        about.target = WindowManager.shared
        menu.addItem(about)
        let preferences = NSMenuItem(title: "Preferences…", action: #selector(WindowManager.preferencesMenuItemPressed(_:)), keyEquivalent: ",")
        preferences.target = WindowManager.shared
        menu.addItem(preferences)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Song Rating", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }()
    private(set) var isPlaying = false {
        didSet {
            if let playState = iTunesRadioStation.shared.latestPlayInfo?.playerState {
                self.playState = playState
            } else {
                if iTunesRadioStation.shared.iTunes?.playerState == .playing {
                    self.playState = .playing
                } else if iTunesRadioStation.shared.iTunes?.playerState == .paused {
                    self.playState = .paused
                } else {
                    self.playState = .unknown
                }
            }
            
            updateMenuBar()
        }
    }
    private(set) var playState: PlayInfo.PlayerState? {
        didSet {
            if playState == .unknown {
                undetachedPopover?.close()
            }
        }
    }
    
    var isStop: Bool {
        return playState == .unknown
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesPlayerDidUpdated(_:)), name: .iTunesPlayerDidUpdated, object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRatingUp(_:)), name: .iTunesRadioRequestTrackRatingUp, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRatingDown(_:)), name: .iTunesRadioRequestTrackRatingDown, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.windowDidResize(_:)), name: NSWindow.didResizeNotification, object: nil)
        
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PreferencesViewController.ShortcutKey.showOrClosePopover.rawValue, toAction: { [weak self] in
            guard self?.undetachedPopover == nil else {
                self?.undetachedPopover?.close()
                self?.undetachedPopover = nil
                return
            }
            self?.showPopover()
        })
    }
    
}

extension MenuBarRatingControl {
    
    private func updateMenuBar() {
        let margin: CGFloat = 4 + 4
        let playingWidth = margin + ratingControl.starsImage.size.width
        let pauseWidth = margin + CGFloat(2) * ratingControl.spacing + ratingControl.starSize.width
        
        statusItem.length = !isStop ?  playingWidth : pauseWidth
        statusItem.button?.image = !isStop ? ratingControl.starsImage : menuBarIcon.image
        statusItem.button?.setButtonType(!isStop ? .momentaryChange : .onOff)
    }
}

extension MenuBarRatingControl {
    
    @objc func action(_ sender: NSButton) {
        guard let event = NSApp.currentEvent else {
            return
        }
        os_log("%{public}s[%{public}ld], %{public}s: menu bar button receive event %s", ((#file as NSString).lastPathComponent), #line, #function, event.debugDescription)

        switch event.type {
        case .leftMouseUp where isStop:
            let position = NSPoint(x: 0, y: sender.bounds.height + 5)
            menuBarMenu.popUp(positioning: nil, at: position, in: sender)

        case .rightMouseUp where isStop:
            let position = sender.convert(event.locationInWindow, to: nil)
            menuBarMenu.popUp(positioning: nil, at: position, in: sender)

        case .leftMouseUp, .leftMouseDragged:
            ratingControl.action(from: sender, with: event)

        case .rightMouseUp:
            showPopover()
            
        default:
            os_log("%{public}s[%{public}ld], %{public}s: no handler for event %s", ((#file as NSString).lastPathComponent), #line, #function, event.debugDescription)
        }
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
    
    @objc func iTunesPlayerDidUpdated(_ notification: Notification) {
        let player = iTunesPlayer.shared
        
        isPlaying = player.isPlaying
        let userRating = player.currentTrack?.userRating ?? 0
        ratingControl.update(rating: userRating)
    }
    
    @objc func iTunesRadioRequestTrackRatingUp(_ notification: Notification) {
        isPlaying = iTunesPlayer.shared.isPlaying
        guard !isStop else {
            return
        }
        
        ratingControl.update(rating: ratingControl.rating + 20)
        iTunesRadioStation.shared.setRating(ratingControl.rating)
    }
    
    @objc func iTunesRadioRequestTrackRatingDown(_ notification: Notification) {
        isPlaying = iTunesPlayer.shared.isPlaying
        guard !isStop else {
            return
        }
        
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

extension MenuBarRatingControl {
    
    private func showPopover() {
        guard let button = statusItem.button else { return }
        
        let popover = NSPopover()
        popover.contentViewController = WindowManager.WindowType.popover.viewController
        popover.behavior = .transient
        popover.delegate = popoverProxy
        
        // FIXME: should relative to windows
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
        
        undetachedPopover = popover
    }
    
}

// MARK: - PopoverProxyDelegate
extension MenuBarRatingControl: PopoverProxyDelegate {
    
    func popoverDidClose(_ notification: Notification) {
        // check which popover closed and release it
        
        if let popover = undetachedPopover, !popover.isShown {
            undetachedPopover = nil
        }
        
        if let popover = detachedPopover, !popover.isShown {
            detachedPopover = nil
        }
    }

    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        popover.configureCloseButton()
        return true
    }
    
    func popoverDidDetach(_ popover: NSPopover) {
        undetachedPopover = nil
        detachedPopover?.close()
        
        popover.behavior = .applicationDefined
        detachedPopover = popover
    }

}

extension NSPopover {
    
    // tweak NSPopoverFrame: https://github.com/mstg/OSX-Runtime-Headers/blob/master/AppKit/NSPopoverFrame.h
    func configureCloseButton() {
        guard let popoverViewController = contentViewController as? PopoverViewController,
        let superView = popoverViewController.view.superview else {
            return
        }
        
        guard NSStringFromClass(type(of: superView)) == "NSPopoverFrame" else {
            return
        }
        
        guard let closeButton = superView.value(forKey: "closeButton") as? NSButton else {
            return
        }
        
        closeButton.image = nil
        closeButton.isEnabled = false

        // tell view controller we tweak it
        popoverViewController.hostPopover = self
    }
    
}
