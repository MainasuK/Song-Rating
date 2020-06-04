//
//  PopoverViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-8-17.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

final class StopProgressFreestandingTemplateButton: NSButton {
    override var allowsVibrancy: Bool { return true }
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
    private let closeButtonContainerVisualEffectView: NSVisualEffectView = {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.wantsLayer = true
        visualEffectView.blendingMode = .withinWindow
        visualEffectView.material = .hudWindow
        visualEffectView.isEmphasized = true
        visualEffectView.state = .active
        
        visualEffectView.alphaValue = 0
        visualEffectView.maskImage = NSImage(named: NSImage.stopProgressFreestandingTemplateName)   // clip non-button part effect out 
        
        return visualEffectView
    }()
    private lazy var closeButton: NSButton = {
        let button = StopProgressFreestandingTemplateButton()
        button.image = NSImage(named: NSImage.stopProgressFreestandingTemplateName)
        button.image?.isTemplate = true
        button.bezelStyle = .inline
        button.isBordered = false
        button.target = self
        button.action = #selector(PopoverViewController.closeButtonPressed(_:))
        
        button.alphaValue = 0
        button.isEnabled = false
        
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
        
        closeButtonContainerVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButtonContainerVisualEffectView)
        NSLayoutConstraint.activate([
            closeButtonContainerVisualEffectView.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            closeButtonContainerVisualEffectView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5),
            closeButtonContainerVisualEffectView.widthAnchor.constraint(equalTo: closeButtonContainerVisualEffectView.heightAnchor, multiplier: 1.0),
        ])
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButtonContainerVisualEffectView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: closeButtonContainerVisualEffectView.topAnchor, constant: -1),
            closeButton.leadingAnchor.constraint(equalTo: closeButtonContainerVisualEffectView.leadingAnchor, constant: -1),
            closeButton.trailingAnchor.constraint(equalTo: closeButtonContainerVisualEffectView.trailingAnchor, constant: 1),
            closeButton.bottomAnchor.constraint(equalTo: closeButtonContainerVisualEffectView.bottomAnchor, constant: 1),
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(PopoverViewController.iTunesPlayerDidUpdated(_:)), name: .iTunesPlayerDidUpdated, object: nil)
        view.addTrackingArea(NSTrackingArea(rect: view.bounds, options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited], owner: self, userInfo: nil))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        closeButtonContainerVisualEffectView.layer?.cornerRadius = floor(0.5 * closeButtonContainerVisualEffectView.frame.width)
        
        playerViewController.updateCurrentTrack(iTunesPlayer.shared.currentTrack)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        
        guard hostPopover != nil else { return }
        NSAnimationContext.runAnimationGroup { context in
            closeButtonContainerVisualEffectView.animator().alphaValue = 1
            closeButton.animator().alphaValue = 1
            closeButton.isEnabled = true
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        
        guard hostPopover != nil else { return }
        NSAnimationContext.runAnimationGroup({ context in
            closeButtonContainerVisualEffectView.animator().alphaValue = 0
            closeButton.animator().alphaValue = 0
        }) {
            self.closeButton.isEnabled = false
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
        playerViewController.updateCurrentTrack(iTunesPlayer.shared.currentTrack)
    }
    
    @objc private func closeButtonPressed(_ button: NSButton) {
        hostPopover?.close()
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(macOS 10.15.0, *)
struct PopoverViewController_Preview: PreviewProvider {
    
    static var previews: some View {
        NSViewControllerPreview {
            return PopoverViewController()
        }
    }
    
}

#endif
