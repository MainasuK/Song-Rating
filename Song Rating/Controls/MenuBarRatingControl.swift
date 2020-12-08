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
    
    private let clickGestureRecognizer: NSClickGestureRecognizer = {
        let gestureRecognizer = NSClickGestureRecognizer()
        return gestureRecognizer
    }()
    private let doubleClickGestureRecognizer: NSClickGestureRecognizer = {
        let gestureRecognizer = NSClickGestureRecognizer()
        gestureRecognizer.numberOfClicksRequired = 2
        return gestureRecognizer
    }()
    private let pressGestureRecognizer: NSPressGestureRecognizer = {
        let gestureRecognizer = NSPressGestureRecognizer()
        return gestureRecognizer
    }()
    private let panGestureRecognizer: NSPanGestureRecognizer = {
        let gestureRecognizer = NSPanGestureRecognizer()
        return gestureRecognizer
    }()

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
    private(set) var playState: PlayInfo.PlayerState = .unknown {
        didSet {
            // FIXME: close attached popover when menu bar collapse
            if playState == .unknown {
                WindowManager.shared.attachedPopover?.close()
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
        button.sendAction(on: [.rightMouseUp])
        button.action = #selector(MenuBarRatingControl.action(_:))
        button.target = self
        button.setButtonType(.momentaryChange)
        
        // set fail rule
        doubleClickGestureRecognizer.shouldRequireFailure(of: clickGestureRecognizer)
        panGestureRecognizer.shouldRequireFailure(of: pressGestureRecognizer)
        
        clickGestureRecognizer.action = #selector(MenuBarRatingControl.clickGestureRecognizerHandler(_:))
        clickGestureRecognizer.target = self
        button.addGestureRecognizer(clickGestureRecognizer)
        
        doubleClickGestureRecognizer.action = #selector(MenuBarRatingControl.doubleClickGestureRecognizerHandler(_:))
        doubleClickGestureRecognizer.target = self
        button.addGestureRecognizer(doubleClickGestureRecognizer)
        
        pressGestureRecognizer.action = #selector(MenuBarRatingControl.pressGestureRecognizerHandler(_:))
        pressGestureRecognizer.target = self
        button.addGestureRecognizer(pressGestureRecognizer)
        
        panGestureRecognizer.action = #selector(MenuBarRatingControl.panGestureRecognizerHandler(_:))
        panGestureRecognizer.target = self
        button.addGestureRecognizer(panGestureRecognizer)

        let trackingArea = NSTrackingArea(rect: button.bounds, options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved], owner: trackingAreaResponser, userInfo: nil)
        button.addTrackingArea(trackingArea)

        trackingAreaResponser.delegate = self

        ratingControl.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesPlayerDidUpdated(_:)), name: .iTunesPlayerDidUpdated, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRatingUp(_:)), name: .iTunesRadioRequestTrackRatingUp, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRatingDown(_:)), name: .iTunesRadioRequestTrackRatingDown, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRating5(_:)), name: .iTunesRadioRequestTrackRating5, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRating4(_:)), name: .iTunesRadioRequestTrackRating4, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRating3(_:)), name: .iTunesRadioRequestTrackRating3, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRating2(_:)), name: .iTunesRadioRequestTrackRating2, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRating1(_:)), name: .iTunesRadioRequestTrackRating1, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.iTunesRadioRequestTrackRating0(_:)), name: .iTunesRadioRequestTrackRating0, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuBarRatingControl.windowDidResize(_:)), name: NSWindow.didResizeNotification, object: nil)
    }

}

extension MenuBarRatingControl {

    private func updateMenuBar() {
        let margin: CGFloat = 4 + 4
        let playingWidth = margin + ratingControl.starsImage.size.width
        let pauseWidth = margin + CGFloat(2) * ratingControl.spacing + ratingControl.starSize.width

        statusItem.length = !isStop ? playingWidth : pauseWidth
        statusItem.button?.image = !isStop ? ratingControl.starsImage : menuBarIcon.image
        statusItem.button?.setButtonType(!isStop ? .momentaryChange : .onOff)
    }

}

extension MenuBarRatingControl {

    @objc private func action(_ sender: NSButton) {
        guard let event = NSApp.currentEvent else {
            return
        }
        os_log("%{public}s[%{public}ld], %{public}s: menu bar button receive event %s", ((#file as NSString).lastPathComponent), #line, #function, event.debugDescription)

        switch event.type {
        case .rightMouseUp where isStop:
            let position = sender.convert(event.locationInWindow, to: nil)
            menuBarMenu.popUp(positioning: nil, at: position, in: sender)

        case .rightMouseUp:
            WindowManager.shared.triggerPopover()

        default:
            os_log("%{public}s[%{public}ld], %{public}s: no handler for event %s", ((#file as NSString).lastPathComponent), #line, #function, event.debugDescription)
        }
    }
    
    @objc private func clickGestureRecognizerHandler(_ sender: NSClickGestureRecognizer) {
        os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, sender.debugDescription)
        guard let button = statusItem.button else { return }
        
        switch sender.state {
        case .ended:
            ratingControl.action(from: button, by: sender, behavior: .full)
        default:
            break
        }
    }
    
    @objc private func doubleClickGestureRecognizerHandler(_ sender: NSClickGestureRecognizer) {
        os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, sender.debugDescription)
        guard let button = statusItem.button else { return }
        
        switch sender.state {
        case .ended:
            ratingControl.action(from: button, by: sender, behavior: .half)
        default:
            break
        }
    }
    
    @objc private func pressGestureRecognizerHandler(_ sender: NSPressGestureRecognizer) {
        os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, sender.debugDescription)
        guard let button = statusItem.button else { return }

        switch sender.state {
        case .ended:
            ratingControl.action(from: button, by: sender, behavior: .full)
        default:
            break
        }
    }


    @objc private func panGestureRecognizerHandler(_ sender: NSPanGestureRecognizer) {
        os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, sender.debugDescription)
        guard let button = statusItem.button else { return }
        
        switch sender.state {
        case .changed, .ended:
            ratingControl.action(from: button, by: sender, behavior: .both)
        default:
            break
        }
    }
    
}

// MARK: - RatingControlDelegate
extension MenuBarRatingControl: RatingControlDelegate {

    func ratingControl(_ ratingControl: RatingControl, shouldUpdateRating rating: Int) -> Bool {
        return !isStop
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

    @objc func iTunesRadioRequestTrackRating5(_ notification: Notification) {
        setRating(stars: 5)
    }

    @objc func iTunesRadioRequestTrackRating4(_ notification: Notification) {
        setRating(stars: 4)
    }

    @objc func iTunesRadioRequestTrackRating3(_ notification: Notification) {
        setRating(stars: 3)
    }

    @objc func iTunesRadioRequestTrackRating2(_ notification: Notification) {
        setRating(stars: 2)
    }

    @objc func iTunesRadioRequestTrackRating1(_ notification: Notification) {
        setRating(stars: 1)
    }

    @objc func iTunesRadioRequestTrackRating0(_ notification: Notification) {
        setRating(stars: 0)
    }

    @objc func setRating(stars: Int) {
      isPlaying = iTunesPlayer.shared.isPlaying
      guard !isStop else {
          return
      }

      ratingControl.update(rating: stars * 20)
      iTunesRadioStation.shared.setRating(ratingControl.rating)
    }

    @objc func windowDidResize(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else {
            return
        }

        // Always update menu bar to prevent wrong state when iTunes not running
        DispatchQueue.once(token: "firstDisplay") {
            updateMenuBar()
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

extension NSPopover {

    // tweak NSPopoverFrame: https://github.com/mstg/OSX-Runtime-Headers/blob/master/AppKit/NSPopoverFrame.h
    func configureCloseButton() {
        guard let popoverViewController = contentViewController as? PopoverViewController,
        let superView = popoverViewController.view.superview else {
            assertionFailure()
            return
        }

        guard NSStringFromClass(type(of: superView)) == "NSPopoverFrame" else {
            assertionFailure()
            return
        }

        guard let closeButton = superView.value(forKey: "closeButton") as? NSButton else {
            assertionFailure()
            return
        }

        // Tweak works under 10.14, 10.15

        closeButton.image = nil
        closeButton.isEnabled = false

        // tell view controller we tweak it
        popoverViewController.hostPopover = self
    }

}
