//
//  PlayerPanelViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-10-14.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

protocol PlayerPanelViewControllerDelegate: class {
    func playerPanelViewController(_ playerPanelViewController: PlayerPanelViewController, menuButtonPressed button: NSButton)
    func playerPanelViewController(_ playerPanelViewController: PlayerPanelViewController, listButtonPressed button: NSButton)
    func playerPanelViewController(_ playerPanelViewController: PlayerPanelViewController, backwardButtonPressed button: NSButton)
    func playerPanelViewController(_ playerPanelViewController: PlayerPanelViewController, forwardButtonPressed button: NSButton)
    func playerPanelViewController(_ playerPanelViewController: PlayerPanelViewController, playPauseButtonToggled button: NSButton)
}

final class PlayerPanelViewController: NSViewController {
    
    enum State {
        case info
        case control
    }
    
    var isStop = false {
        didSet {
            stateDidUpdate(.control)
        }
    }
    var state: State = .info {
        didSet {
            stateDidUpdate(self.state)
        }
    }
    
    weak var delegate: PlayerPanelViewControllerDelegate?
    
    private let playerInfoView = PlayerInfoView()
    private let playerControlView = PlayerControlView()

    override func loadView() {
        self.view = NSView()
    }
    
}

extension PlayerPanelViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerInfoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerInfoView)
        NSLayoutConstraint.activate([
            playerInfoView.topAnchor.constraint(equalTo: view.topAnchor),
            playerInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerInfoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerInfoView.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        playerControlView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerControlView)
        NSLayoutConstraint.activate([
            playerControlView.topAnchor.constraint(equalTo: playerInfoView.topAnchor),
            playerControlView.leadingAnchor.constraint(equalTo: playerInfoView.leadingAnchor),
            playerControlView.trailingAnchor.constraint(equalTo: playerInfoView.trailingAnchor),
            playerControlView.bottomAnchor.constraint(equalTo: playerInfoView.bottomAnchor),
        ])
        playerControlView.alphaValue = 0
        
        playerControlView.menuButton.target = self
        playerControlView.menuButton.action = #selector(PlayerPanelViewController.menuButtonPressed(_:))
        playerControlView.listButton.target = self
        playerControlView.listButton.action = #selector(PlayerPanelViewController.listButtonPressed(_:))
        playerControlView.backwardButton.target = self
        playerControlView.backwardButton.action = #selector(PlayerPanelViewController.backwardButtonPressed(_:))
        playerControlView.forwardButton.target = self
        playerControlView.forwardButton.action = #selector(PlayerPanelViewController.forwardButtonPressed(_:))
        playerControlView.playPauseButton.target = self
        playerControlView.playPauseButton.action = #selector(PlayerPanelViewController.playPauseButtonToggled(_:))
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerPanelViewController.iTunesPlayerDidUpdated(_:)), name: .iTunesPlayerDidUpdated, object: nil)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        playerControlView.playPauseButton.state = iTunesPlayer.shared.isPlaying ? .on : .off
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        playerInfoView.titleTextField.reset()
        playerInfoView.captionTextField.reset()
    }
    
}

extension PlayerPanelViewController {
    
    func updateCurrentTrack(_ track: iTunesTrack?) {
        isStop = track == nil
        
        guard let track = track else {
            return
        }
        
        // setup playInfoView
        playerInfoView.titleTextField.stringValue = track.name ?? "No Title"
        playerInfoView.titleTextField.scroll()
        
        let caption = [track.artist ?? track.albumArtist, track.album].compactMap { $0 }.joined(separator: " – ")
        playerInfoView.captionTextField.stringValue = caption
        playerInfoView.captionTextField.scroll()
    }
    
    func stateDidUpdate(_ state: State) {
        playerControlView.backwardButton.isEnabled = !isStop
        playerControlView.forwardButton.isEnabled = !isStop
        
        guard !isStop else {
            playerInfoView.alphaValue = 0
            playerControlView.alphaValue = 1
            return
        }
        
        switch state {
        case .control:
            playerInfoView.alphaValue = 0
            playerControlView.alphaValue = 1
            
            playerInfoView.titleTextField.reset()
            playerInfoView.titleTextField.scroll()
            playerInfoView.captionTextField.reset()
            playerInfoView.captionTextField.scroll()
            
        case .info:
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.33
                playerInfoView.animator().alphaValue = 1
                playerControlView.animator().alphaValue = 0
            }
        }
    }
    
}

extension PlayerPanelViewController {
    
    @objc private func menuButtonPressed(_ sender: NSButton) {
        delegate?.playerPanelViewController(self, menuButtonPressed: sender)
    }
    
    @objc private func listButtonPressed(_ sender: NSButton) {
        delegate?.playerPanelViewController(self, listButtonPressed: sender)
    }
    
    @objc private func backwardButtonPressed(_ sender: NSButton) {
        delegate?.playerPanelViewController(self, backwardButtonPressed: sender)
    }
    
    @objc private func forwardButtonPressed(_ sender: NSButton) {
        delegate?.playerPanelViewController(self, forwardButtonPressed: sender)
    }
    
    @objc private func playPauseButtonToggled(_ sender: NSButton) {
        delegate?.playerPanelViewController(self, playPauseButtonToggled: sender)
    }

    // NotificationCenter listener
    @objc private func iTunesPlayerDidUpdated(_ notification: Notification) {
        // prevent concurrent conflict
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.playerControlView.playPauseButton.state = iTunesPlayer.shared.isPlaying ? .on : .off
        }
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(macOS 10.15.0, *)
struct PlayerPanelViewController_Preview: PreviewProvider {
    
    // Live preview
    static var previews: some View {
        NSViewControllerPreview {
            let playerPanelViewController = PlayerPanelViewController()
            NotificationCenter.default.addObserver(forName: .iTunesPlayerDidUpdated, object: nil, queue: .main) { notification in
                playerPanelViewController.updateCurrentTrack(iTunesPlayer.shared.currentTrack)
            }
            playerPanelViewController.updateCurrentTrack(iTunesPlayer.shared.currentTrack)
            
            return playerPanelViewController
        }.frame(width: 300, height: 60, alignment: .center)
    }
    
}

#endif
