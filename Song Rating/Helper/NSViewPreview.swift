//
//  NSViewPreview.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-10-14.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct NSViewPreview<View: NSView>: NSViewRepresentable {
    
    let view: View
    
    init(_ builder: @escaping () -> View) {
        view = builder()
    }
    
    // MARK: - NSViewRepresentable
    func makeNSView(context: Context) -> View {
        return view
    }
    
    func updateNSView(_ view: View, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
}
#endif
