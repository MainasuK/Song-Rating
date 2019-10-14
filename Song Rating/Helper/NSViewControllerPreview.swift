//
//  NSViewControllerPreview.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-10-14.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct NSViewControllerPreview<ViewController: NSViewController>: NSViewControllerRepresentable {
    
    let viewController: ViewController
    
    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }
    
    // MARK: - NSViewControllerRepresentable
    
    func makeNSViewController(context: Context) -> ViewController {
        return viewController
    }
    
    func updateNSViewController(_ viewController: ViewController, context: Context) {
        
    }
    
}
#endif
