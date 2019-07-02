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

    lazy var trackRatingDownTextField: NSTextField = {
        return NSTextField(labelWithString: "Track Rating Down")
    }()
    lazy var trackRatingUpTextField: NSTextField = {
        return NSTextField(labelWithString: "Track Rating Up")
    }()
    let trackRatingDownShortcutView: MASShortcutView = {
        let shortcutView = MASShortcutView()
        shortcutView.associatedUserDefaultsKey = ShortcutKey.trackRatingDown.rawValue
        return shortcutView
    }()
    let trackRatingUpShortcutView: MASShortcutView = {
        let shortcutView = MASShortcutView()
        shortcutView.associatedUserDefaultsKey = ShortcutKey.trackRatingUp.rawValue
        return shortcutView
    }()


    let leadingPaddingView = NSView()
    let trailingPaddingView = NSView()

    lazy var gridView: NSGridView = {
        let gridView = NSGridView(views: [
            [trackRatingDownTextField, trackRatingDownShortcutView],
            [trackRatingUpTextField, trackRatingUpShortcutView],
            [leadingPaddingView, trailingPaddingView]
        ])
        gridView.column(at: 0)
        gridView.column(at: 0).xPlacement = .trailing
        gridView.column(at: 1).xPlacement = .leading
        gridView.rowSpacing = 8

        return gridView
    }()

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 200))
    }
    
}

extension PreferencesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Preferences"

        gridView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridView)
        NSLayoutConstraint.activate([
            gridView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: gridView.trailingAnchor, constant: 16),
            view.bottomAnchor.constraint(greaterThanOrEqualTo: gridView.bottomAnchor, constant: 8),
            leadingPaddingView.widthAnchor.constraint(equalTo: trailingPaddingView.widthAnchor, multiplier: 1.0),
        ])

        // setup shortcut validator
        MASShortcutValidator.shared()!.allowAnyShortcutWithOptionModifier = true
    }

}

extension PreferencesViewController {

    enum ShortcutKey: String {
        case trackRatingDown
        case trackRatingUp
    }

}
