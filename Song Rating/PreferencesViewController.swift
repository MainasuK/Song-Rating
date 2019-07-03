//
//  PreferencesViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-2.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import MASShortcut

enum PreferencesUserDefaultsKey: String {
    case hideMenuBarWhenNotPlaying
}

final class PreferencesViewController: NSViewController {
    
    lazy var hideMenuBarWhenNotPlayingCheckButton: NSButton = {
       let button = NSButton(checkboxWithTitle: "Hide menu bar icon when not playing", target: self, action: #selector(PreferencesViewController.hideMenubarWhenNotPlayingCheckButtonPressed(_:)))
        button.state = NSControl.StateValue(UserDefaults.standard.integer(forKey: PreferencesUserDefaultsKey.hideMenuBarWhenNotPlaying.rawValue))
        return button
    }()

    lazy var SongRatingDownTextField: NSTextField = {
        return NSTextField(labelWithString: "Song rating down: ")
    }()
    lazy var songRatingUpTextField: NSTextField = {
        return NSTextField(labelWithString: "Song rating up: ")
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


    let leadingPaddingView = NSView()
    let trailingPaddingView = NSView()

    lazy var gridView: NSGridView = {
        let empty = NSGridCell.emptyContentView
        let line = NSBox()
        line.boxType = .separator
        
        let gridView = NSGridView(views: [
            [empty, hideMenuBarWhenNotPlayingCheckButton],
            [line],
            [SongRatingDownTextField, songRatingDownShortcutView],
            [songRatingUpTextField, songRatingUpShortcutView],
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
    
    @objc func hideMenubarWhenNotPlayingCheckButtonPressed(_ sender: NSButton) {
        UserDefaults.standard.set(sender.state.rawValue, forKey: PreferencesUserDefaultsKey.hideMenuBarWhenNotPlaying.rawValue)
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
    }
    
}
