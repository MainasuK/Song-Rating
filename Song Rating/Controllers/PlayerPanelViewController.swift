//
//  PlayerPanelViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-10-14.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

final class PlayerPanelViewController: NSViewController {
    
    enum State {
        case info
        case control
    }
    
    var state: State = .info {
        didSet {
            stateDidUpdate(self.state)
        }
    }
    
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
        
        state = .info
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        playerInfoView.titleTextField.reset()
        playerInfoView.captionTextField.reset()
    }
    
}

extension PlayerPanelViewController {
    
    func updateCurrentTrack(_ track: iTunesTrack?) {
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
        switch state {
        case .control:
            playerInfoView.isHidden = true
            playerControlView.isHidden = false
        case .info:
            playerInfoView.animator().isHidden = false
            playerControlView.animator().isHidden = true
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
