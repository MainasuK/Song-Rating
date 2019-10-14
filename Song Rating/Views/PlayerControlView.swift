//
//  PlayerControlView.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-10-15.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

final class PlayerControlView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _init()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        _init()
    }
    
    private func _init() {
        
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
        }
    }
    
}

#endif
