//
//  PlayerViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-8-18.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import os
import DominantColor

final class PlayerViewController: NSViewController {
    
    private let playerPanelViewController = PlayerPanelViewController()
    private let playerHistoryViewController = PlayerHistoryViewController()
    
    private let backCoverImageView: MovableImageView = {
        let view = MovableImageView()
        view.wantsLayer = true
        view.layer = CALayer()
        view.layer?.contentsGravity = CALayerContentsGravity.resizeAspectFill
        return view
    }()
    private let backCoverImageVisualEffectView: NSVisualEffectView = {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.blendingMode = .withinWindow
        visualEffectView.material = .hudWindow
        visualEffectView.isEmphasized = true
        visualEffectView.state = .active
        return visualEffectView
    }()
    private let coverImageView: MovableImageView = {
        let imageView = MovableImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        return imageView
    }()

    override func loadView() {
        self.view = NSView()
    }
    
    private(set) var state = State.playerWithHistory
    private var playerHistoryViewHeightLayoutConstraint: NSLayoutConstraint!
    private lazy var playerHistoryTriggerButton: NSButton = {
        let button = NSButton()
        button.title = "Trigger"
        button.target = self
        button.action = #selector(PlayerViewController.playerHistoryTriggerButtonPressed(_:))
        return button
    }()
    
    var playerHeight: CGFloat {
        return coverImageView.frame.height + playerPanelViewController.view.frame.height + playerHistoryTriggerButton.frame.height
    }
    
    var playerHistoryHeight: CGFloat = 5 * 40
    
}

extension PlayerViewController {
    
    @objc private func playerHistoryTriggerButtonPressed(_ sender: NSButton) {
        state = state.toggle()
        
        // Use NSWindow API calculate correct frame (contains shadow margin)
        guard let window = view.window else {
            assertionFailure()
            return
        }
        
        let originalWindowFrameHeight = window.frame.size.height
        let listHeight: CGFloat = state == .player ? 0.0 : playerHistoryHeight
        
        var contentRect = window.contentLayoutRect
        contentRect.size.height = playerHeight + listHeight     // resize content height
        let newFrameSize = window.frameRect(forContentRect: contentRect).size
        
        var newFrame = window.frame
        newFrame.size.height = newFrameSize.height
        let diff = originalWindowFrameHeight - newFrame.size.height
        newFrame.origin.y += diff
        
        
        window.setFrame(newFrame, display: true, animate: true)
    }
    
}

extension PlayerViewController {
    
    enum State {
        case player
        case playerWithHistory
        
        func toggle() -> State {
            switch self {
            case .player:               return .playerWithHistory
            case .playerWithHistory:    return .player
            }
        }
    }
    
}

extension PlayerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addTrackingArea(NSTrackingArea(rect: view.bounds, options: [.activeAlways, .mouseEnteredAndExited, .inVisibleRect], owner: self, userInfo: nil))

        // V-StackView
        // - backCoverImageVisualEffectView & coverImageView
        // - playerInfoView
        // - playerHistoryViewController
                
        let stackView = NSStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        stackView.alignment = .centerX
        stackView.spacing = 0
        
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(coverImageView)
        NSLayoutConstraint.activate([
            coverImageView.widthAnchor.constraint(equalToConstant: 300),
            coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor),
        ])
        
        backCoverImageVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backCoverImageVisualEffectView, positioned: .below, relativeTo: coverImageView)
        NSLayoutConstraint.activate([
            backCoverImageVisualEffectView.topAnchor.constraint(equalTo: coverImageView.topAnchor),
            backCoverImageVisualEffectView.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor),
            backCoverImageVisualEffectView.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor),
            backCoverImageVisualEffectView.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor),
        ])
        
        backCoverImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backCoverImageView, positioned: .below, relativeTo: backCoverImageVisualEffectView)
        NSLayoutConstraint.activate([
            backCoverImageView.topAnchor.constraint(equalTo: coverImageView.topAnchor),
            backCoverImageView.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor),
            backCoverImageView.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor),
            backCoverImageView.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor),
        ])
        
        addChild(playerPanelViewController)
        playerPanelViewController.view.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(playerPanelViewController.view)
        NSLayoutConstraint.activate([
            playerPanelViewController.view.widthAnchor.constraint(equalTo: coverImageView.widthAnchor, multiplier: 1.0),
        ])
        
        // stackView.addArrangedSubview(playerHistoryTriggerButton)
        
        addChild(playerHistoryViewController)
        playerHistoryViewController.view.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(playerHistoryViewController.view)
        playerHistoryViewHeightLayoutConstraint = playerHistoryViewController.scrollView.heightAnchor.constraint(equalToConstant: playerHistoryHeight)
        NSLayoutConstraint.activate([
            playerHistoryViewController.view.widthAnchor.constraint(equalTo: coverImageView.widthAnchor),
            playerHistoryViewHeightLayoutConstraint,    // placeholder constraint. deactive after appeare
        ])
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        playerHistoryViewHeightLayoutConstraint.isActive = false
        
        /*
        #if DEBUG
        WindowManager.shared.open(.popover)
        #endif
        */
    }
    

}

extension PlayerViewController {
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        os_log("%{public}s[%{public}ld], %{public}s: mouseEntered", ((#file as NSString).lastPathComponent), #line, #function)
        
        playerPanelViewController.state = .control
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        os_log("%{public}s[%{public}ld], %{public}s: mouseEntered", ((#file as NSString).lastPathComponent), #line, #function)
        
        playerPanelViewController.state = .info
    }
    
}


extension PlayerViewController {
    
    func updateCurrentTrack(_ track: iTunesTrack?) {
        defer {
            view.needsLayout = true
            
            // update panel view
            playerPanelViewController.updateCurrentTrack(track)
            
            // update history table view
            playerHistoryViewController.playerHistoryTableView.reloadData()
        }
    
        // update cover image
        guard let track = track else {
            coverImageView.image = nil
            backCoverImageView.layer?.contents = nil
            return
        }
    
        let firstImage: NSImage? = {
            guard let artwork = track.artworks?().firstObject as? iTunesArtwork else { return nil }
            if let descriptor = (artwork.data as Any) as? NSAppleEventDescriptor {
                return NSImage(data: descriptor.data)
            }
            if let image = (artwork.data as Any) as? NSImage {
                return image
            }
            if let data = artwork.rawData, let image = NSImage(data: data) {
                return image
            }
            
            return nil
        }()
        
        if let image = firstImage {
            let transition = CATransition()
            transition.duration = 0.33
            transition.type = .fade
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.isRemovedOnCompletion = true
            coverImageView.layer?.add(transition, forKey: nil)

            coverImageView.image = image
            backCoverImageView.layer?.contents = image
            
        } else {
            coverImageView.image = nil
            backCoverImageView.layer?.contents = nil
        }
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(macOS 10.15.0, *)
struct PlayerViewController_Preview: PreviewProvider {
    
    // Live preview
    static var previews: some View {
        NSViewControllerPreview {
            let playerViewController = PlayerViewController()
            NotificationCenter.default.addObserver(forName: .iTunesPlayerDidUpdated, object: nil, queue: .main) { notification in
                playerViewController.updateCurrentTrack(iTunesPlayer.shared.currentTrack)
            }
            playerViewController.updateCurrentTrack(iTunesPlayer.shared.currentTrack)
            return playerViewController
        }.frame(width: 300, height: 800, alignment: .center)
    }
    
}

#endif
