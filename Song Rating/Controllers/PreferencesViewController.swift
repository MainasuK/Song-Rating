//
//  PreferencesViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-2.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import MASShortcut

final class PreferencesViewController: NSViewController {

    lazy var songRatingDownTextField: NSTextField = {
        return NSTextField(labelWithString: "Song rating down: ")
    }()
    lazy var songRatingUpTextField: NSTextField = {
        return NSTextField(labelWithString: "Song rating up: ")
    }()
    lazy var showOrClosePopoverTextField: NSTextField = {
        return NSTextField(labelWithString: "Show/Close popover: ")
    }()
    let songRatingDownShortcutView: MASShortcutView = {
        let shortcutView = MASShortcutView()
        shortcutView.associatedUserDefaultsKey = ShortcutKey.songRatingDown.rawValue
        return shortcutView
    }()
    let songRatingUpShortcutView: MASShortcutView = {
        let shortcutView = MASShortcutView()
        shortcutView.associatedUserDefaultsKey = ShortcutKey.songRatingUp.rawValue
        return shortcutView
    }()
    let showOrClosePopoverShortcutView: MASShortcutView = {
        let shortcutView = MASShortcutView()
        shortcutView.associatedUserDefaultsKey = ShortcutKey.showOrClosePopover.rawValue
        return shortcutView
    }()


    let leadingPaddingView = NSView()
    let trailingPaddingView = NSView()

    lazy var gridView: NSGridView = {
        let empty = NSGridCell.emptyContentView
        let line = NSBox()
        line.boxType = .separator
        
        let gridView = NSGridView(views: [
            [songRatingDownTextField, songRatingDownShortcutView],
            [songRatingUpTextField, songRatingUpShortcutView],
            [showOrClosePopoverTextField, showOrClosePopoverShortcutView],
            [leadingPaddingView, trailingPaddingView]
        ])
        gridView.column(at: 0)
        gridView.column(at: 0).xPlacement = .trailing
        gridView.column(at: 1).xPlacement = .leading
        gridView.rowSpacing = 8
        
        let lineRow = gridView.cell(for: line)?.row
        lineRow?.mergeCells(in: NSMakeRange(0, 2))
        lineRow?.topPadding = 8
        lineRow?.bottomPadding = 8

        return gridView
    }()

    override func loadView() {
        self.view = NSView()
    }
    
}

extension PreferencesViewController {
    
    func setupWindow() {
        view.window?.styleMask.remove(.resizable)
    }

}

extension PreferencesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Preferences"

        gridView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridView)
        NSLayoutConstraint.activate([
            gridView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: gridView.trailingAnchor, constant: 16),
            view.bottomAnchor.constraint(equalTo: gridView.bottomAnchor, constant: 8),
            leadingPaddingView.widthAnchor.constraint(equalTo: trailingPaddingView.widthAnchor, multiplier: 1.0),
            gridView.widthAnchor.constraint(greaterThanOrEqualToConstant: 420), // magic width
        ])

        // setup shortcut validator
        MASShortcutValidator.shared()!.allowAnyShortcutWithOptionModifier = true
    }
    
    override func viewDidAppear() {
        setupWindow()
    }

}

extension PreferencesViewController {

    enum ShortcutKey: String {
        case songRatingDown
        case songRatingUp
        case showOrClosePopover
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(macOS 10.15.0, *)
struct PreferencesViewController_Preview: PreviewProvider {
    
    static var previews: some View {
        NSViewControllerPreview {
            return PreferencesViewController()
        }
    }
    
}

#endif
