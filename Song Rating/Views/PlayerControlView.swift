//
//  PlayerControlView.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-10-15.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

final class PlayerControlView: NSView {
    
    private static let playImage = NSImage(named: "play.fill.button")!
    private static let pauseImage = NSImage(named: "pause.fill.button")!
    private static let backwardImage = NSImage(named: "backward.button")!
    private static let forwardImage = NSImage(named: "forward.button")!
    private static let ellipsisImage = NSImage(named: "ellipsis.button")!
    private static let listBulletImage = NSImage(named: "list-bullet.button")!
    
    private lazy var playPauseButton: NSButton = {
        let button = NSButton()
        button.imageScaling = .scaleProportionallyUpOrDown
        button.image = PlayerControlView.playImage
        button.isBordered = false
        return button
    }()
    private lazy var forwardButton: NSButton = {
        let button = NSButton()
        button.imageScaling = .scaleProportionallyUpOrDown
        button.image = PlayerControlView.forwardImage
        button.isBordered = false
        return button
    }()
    private lazy var backwardButton: NSButton = {
        let button = NSButton()
        button.imageScaling = .scaleProportionallyUpOrDown
        button.image = PlayerControlView.backwardImage
        button.isBordered = false
        return button
    }()
    private lazy var menuButton: NSButton = {
        let button = NSButton()
        button.imageScaling = .scaleProportionallyUpOrDown
        button.image = PlayerControlView.ellipsisImage
        button.isBordered = false
        return button
    }()
    private lazy var listButton: NSButton = {
        let button = NSButton()
        button.imageScaling = .scaleProportionallyUpOrDown
        button.image = PlayerControlView.listBulletImage
        button.isBordered = false
        return button
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _init()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        _init()
    }
    
    private func _init() {
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playPauseButton)
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        backwardButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backwardButton)
        NSLayoutConstraint.activate([
            backwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            backwardButton.rightAnchor.constraint(equalTo: playPauseButton.leftAnchor),
        ])
        
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(forwardButton)
        NSLayoutConstraint.activate([
            forwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            forwardButton.leftAnchor.constraint(equalTo: playPauseButton.rightAnchor),
        ])
        
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(menuButton)
        NSLayoutConstraint.activate([
            menuButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            menuButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
        ])
        
        listButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(listButton)
        NSLayoutConstraint.activate([
            listButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            rightAnchor.constraint(equalTo: listButton.rightAnchor, constant: 8),
        ])
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(macOS 10.15.0, *)
struct PlayerControlView_Preview: PreviewProvider {
    
    static var previews: some View {
        NSViewPreview {
            let playerControlView = PlayerControlView()
            return playerControlView
        }.frame(width: 300, height: 60, alignment: .center)
    }
    
}

#endif
