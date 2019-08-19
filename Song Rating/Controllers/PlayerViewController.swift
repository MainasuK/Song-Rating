//
//  PlayerViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-8-18.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

final class PlayerViewController: NSViewController {
    
    let coverImageView = MovableImageView()
    let playerInfoView = PlayerInfoView()

    override func loadView() {
        self.view = NSView()
    }
    
}

extension PlayerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        playerInfoView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(playerInfoView)

        NSLayoutConstraint.activate([
            playerInfoView.widthAnchor.constraint(equalTo: coverImageView.widthAnchor, multiplier: 1.0),
        ])
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        playerInfoView.titleTextField.reset()
        playerInfoView.captionTextField.reset()
    }
    
}

extension PlayerViewController {
    
    func updateCurrectTrack(_ track: iTunesTrack?) {
        guard let track = track else {
            coverImageView.image = nil
            coverImageView.needsLayout = true
            return
        }
        
        if let artwork = track.artworks?().firstObject as? iTunesArtwork,
            let data = artwork.rawData {
            let image = NSImage(data: data)
            coverImageView.image = image
            view.needsLayout = true
            
        } else {
            coverImageView.image = nil
        }
        
        // setup playInfoView
        playerInfoView.titleTextField.stringValue = track.name ?? "No Title"
        playerInfoView.titleTextField.scroll()
        
        let caption = [track.artist ?? track.albumArtist, track.album].compactMap { $0 }.joined(separator: " – ")
        playerInfoView.captionTextField.stringValue = caption
        playerInfoView.captionTextField.scroll()
    }
    
}

final class PlayerInfoView: NSView {
    
    let titleTextField: AutoScrollTextField = {
        let textField = AutoScrollTextField(labelWithString: "")
        textField.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        textField.textColor = NSColor.labelColor
        return textField
    }()
    
    let captionTextField: AutoScrollTextField = {
        let textField = AutoScrollTextField(labelWithString: "")
        textField.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        textField.textColor = NSColor.secondaryLabelColor
        return textField
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
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleTextField)
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: topAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        captionTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(captionTextField)
        NSLayoutConstraint.activate([
            captionTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor),
            captionTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            captionTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            captionTextField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
