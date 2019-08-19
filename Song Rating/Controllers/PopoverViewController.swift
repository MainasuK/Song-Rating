//
//  PopoverViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-8-17.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

final class StopProgressFreestandingTemplateButton: NSButton {
//    override var allowsVibrancy: Bool { return false }
}

final class PopoverViewController: NSViewController {
    
    weak var hostPopover: NSPopover? {
        didSet {
            NSAnimationContext.runAnimationGroup { context in
                closeButton.animator().isHidden = hostPopover == nil
            }
        }
    }
    
    private let playerViewController = PlayerViewController()
    
    private lazy var closeButton: NSButton = {
        let button = StopProgressFreestandingTemplateButton()
        button.image = NSImage(named: NSImage.stopProgressFreestandingTemplateName)
        button.image?.isTemplate = true
        button.bezelStyle = .inline
        button.isBordered = false
        button.target = self
        button.action = #selector(PopoverViewController.closeButtonPressed(_:))
        return button
    }()
    
    override func loadView() {
        self.view = NSView()
    }
}

extension PopoverViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(playerViewController)
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerViewController.view)
        
        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5),
        ])
        closeButton.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(PopoverViewController.iTunesPlayerDidUpdated(_:)), name: .iTunesPlayerDidUpdated, object: nil)
        view.addTrackingArea(NSTrackingArea(rect: view.bounds, options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited], owner: self, userInfo: nil))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        playerViewController.updateCurrectTrack(iTunesPlayer.shared.currentTrack)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        
        guard hostPopover != nil else { return }
        NSAnimationContext.runAnimationGroup { context in
            closeButton.animator().isHidden = false
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        
        guard hostPopover != nil else { return }
        NSAnimationContext.runAnimationGroup({ context in
            closeButton.animator().alphaValue = 0
        }) {
            self.closeButton.isHidden = true
            self.closeButton.alphaValue = 1
        }
    }
    
//    override func mouseDragged(with event: NSEvent) {
//        print(event)
//    }
    
}

//extension PopoverViewController: NSWindowDelegate {
//
//    func windowWillStartLiveResize(_ notification: Notification) {
//        print(notification)
//    }
//
//}

extension PopoverViewController {
    
    @objc private func iTunesPlayerDidUpdated(_ notification: Notification) {
        playerViewController.updateCurrectTrack(iTunesPlayer.shared.currentTrack)
    }
    
    @objc private func closeButtonPressed(_ button: NSButton) {
        hostPopover?.close()
    }
    
}

extension PopoverViewController {
    
    
//    private func addCustomCloseButton() {
//
//    }
   
}
