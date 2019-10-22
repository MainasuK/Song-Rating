//
//  PlayerInfoView.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-10-14.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

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
        let groupView = NSView()
        groupView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(groupView)
        NSLayoutConstraint.activate([
            groupView.leadingAnchor.constraint(equalTo: leadingAnchor),
            groupView.trailingAnchor.constraint(equalTo: trailingAnchor),
            groupView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        groupView.addSubview(titleTextField)
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: groupView.topAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
        ])
        
        captionTextField.translatesAutoresizingMaskIntoConstraints = false
        groupView.addSubview(captionTextField)
        NSLayoutConstraint.activate([
            captionTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 4),   // padding
            captionTextField.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            captionTextField.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            captionTextField.bottomAnchor.constraint(equalTo: groupView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleTextField.heightAnchor.constraint(equalTo: captionTextField.heightAnchor, multiplier: 1.0)
        ])
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(OSX 10.15.0, *)
struct PlayerInfoView_Preview: PreviewProvider {
    
    static var previews: some View {
        NSViewPreview {
            let playerInfoView = PlayerInfoView()
            playerInfoView.titleTextField.stringValue = "Title"
            playerInfoView.captionTextField.stringValue = "Caption"
            return playerInfoView
        }.frame(width: 300, height: 60, alignment: .center)
    }
    
}

#endif
