//
//  PlayerViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-8-18.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import DominantColor

final class PlayerViewController: NSViewController {
    
    let backCoverImageView: MovableImageView = {
        let view = MovableImageView()
        view.wantsLayer = true
        view.layer = CALayer()
        view.layer?.contentsGravity = CALayerContentsGravity.resizeAspectFill
        return view
    }()
    let backCoverImageVisualEffectView: NSVisualEffectView = {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.blendingMode = .withinWindow
        visualEffectView.material = .hudWindow
        visualEffectView.isEmphasized = true
        visualEffectView.state = .active
        return visualEffectView
    }()
    let coverImageView: MovableImageView = {
        let imageView = MovableImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        return imageView
    }()
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
        defer {
            view.needsLayout = true
        }
        
        guard let track = track else {
            coverImageView.image = nil
            backCoverImageView.layer?.contents = nil
            return
        }
        
        
        if let artwork = track.artworks?().firstObject as? iTunesArtwork,
        let data = artwork.rawData,
        let image = NSImage(data: data) {
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
