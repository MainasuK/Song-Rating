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
    
    static var defaultTextFieldFontSize: CGFloat {
        return NSTextField(labelWithString: "sample").font!.pointSize
    }

    lazy var StartupTextField: NSTextField = {
        return NSTextField(labelWithString: "Startup: ")
    }()
    lazy var songRatingDownTextField: NSTextField = {
        return NSTextField(labelWithString: "Song rating down: ")
    }()
    lazy var songRatingUpTextField: NSTextField = {
        return NSTextField(labelWithString: "Song rating up: ")
    }()
    lazy var songRating5TextField: NSTextField = {
        let attributedString = PreferencesViewController.starsAttributedString(count: 5, fontSize: PreferencesViewController.defaultTextFieldFontSize)
        attributedString.append(NSAttributedString(string: ": "))
        return NSTextField(labelWithAttributedString: attributedString)
    }()
    lazy var songRating4TextField: NSTextField = {
        let attributedString = PreferencesViewController.starsAttributedString(count: 4, fontSize: PreferencesViewController.defaultTextFieldFontSize)
        attributedString.append(NSAttributedString(string: ": "))
        return NSTextField(labelWithAttributedString: attributedString)
    }()
    lazy var songRating3TextField: NSTextField = {
        let attributedString = PreferencesViewController.starsAttributedString(count: 3, fontSize: PreferencesViewController.defaultTextFieldFontSize)
        attributedString.append(NSAttributedString(string: ": "))
        return NSTextField(labelWithAttributedString: attributedString)
    }()
    lazy var songRating2TextField: NSTextField = {
        let attributedString = PreferencesViewController.starsAttributedString(count: 2, fontSize: PreferencesViewController.defaultTextFieldFontSize)
        attributedString.append(NSAttributedString(string: ": "))
        return NSTextField(labelWithAttributedString: attributedString)
    }()
    lazy var songRating1TextField: NSTextField = {
        let attributedString = PreferencesViewController.starsAttributedString(count: 1, fontSize: PreferencesViewController.defaultTextFieldFontSize)
        attributedString.append(NSAttributedString(string: ": "))
        return NSTextField(labelWithAttributedString: attributedString)
    }()
    lazy var songRating0TextField: NSTextField = {
        return NSTextField(labelWithString: "Remove stars: ")
    }()
    lazy var showOrClosePopoverTextField: NSTextField = {
        return NSTextField(labelWithString: "Show/Close popover: ")
    }()
    let launchAtLoginCheckboxButton: NSButton = {
        let button = NSButton(checkboxWithTitle: "Launch at login", target: nil, action: nil)
        return button
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
    let songRating5ShortcutView: MASShortcutView = {
        let shortcutView = MASShortcutView()
        shortcutView.associatedUserDefaultsKey = ShortcutKey.songRating5.rawValue
        return shortcutView
    }()
    let songRating4ShortcutView: MASShortcutView = {
        let shortcutView = MASShortcutView()
        shortcutView.associatedUserDefaultsKey = ShortcutKey.songRating4.rawValue
        return shortcutView
    }()
    let songRating3ShortcutView: MASShortcutView = {
        let shortcutView = MASShortcutView()
        shortcutView.associatedUserDefaultsKey = ShortcutKey.songRating3.rawValue
        return shortcutView
    }()
    let songRating2ShortcutView: MASShortcutView = {
        let shortcutView = MASShortcutView()
        shortcutView.associatedUserDefaultsKey = ShortcutKey.songRating2.rawValue
        return shortcutView
    }()
    let songRating1ShortcutView: MASShortcutView = {
        let shortcutView = MASShortcutView()
        shortcutView.associatedUserDefaultsKey = ShortcutKey.songRating1.rawValue
        return shortcutView
    }()
    let songRating0ShortcutView: MASShortcutView = {
        let shortcutView = MASShortcutView()
        shortcutView.associatedUserDefaultsKey = ShortcutKey.songRating0.rawValue
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
        
        let gridView = NSGridView(views: [
            [StartupTextField, launchAtLoginCheckboxButton],
            [NSBox.separatorLine],
            [songRatingDownTextField, songRatingDownShortcutView],
            [songRatingUpTextField, songRatingUpShortcutView],
            [showOrClosePopoverTextField, showOrClosePopoverShortcutView],
            [NSBox.separatorLine],
            [songRating0TextField, songRating0ShortcutView],
            [songRating1TextField, songRating1ShortcutView],
            [songRating2TextField, songRating2ShortcutView],
            [songRating3TextField, songRating3ShortcutView],
            [songRating4TextField, songRating4ShortcutView],
            [songRating5TextField, songRating5ShortcutView],
            [leadingPaddingView, trailingPaddingView]
        ])

        gridView.row(at: 0).rowAlignment = .lastBaseline

        gridView.column(at: 0).xPlacement = .trailing
        gridView.column(at: 1).xPlacement = .leading
        gridView.rowSpacing = 8
        
        let lines = gridView.subviews.filter { ($0 as? NSBox)?.boxType == .separator }
        for line in lines {
            guard let lineRow = gridView.cell(for: line)?.row else {
                continue
            }
            lineRow.mergeCells(in: NSMakeRange(0, 2))
            lineRow.topPadding = 8
            lineRow.bottomPadding = 8
        }

        return gridView
    }()

    var launchAtLoginObservation: NSKeyValueObservation?

    override func loadView() {
        self.view = NSView()
    }

    deinit {
        launchAtLoginObservation?.invalidate()
    }

}

extension PreferencesViewController {
    private static func starsAttributedString(count: Int, fontSize: CGFloat) -> NSMutableAttributedString {
        let font = NSFont.systemFont(ofSize: fontSize)
        let stars = Stars(
            stars: Array(repeating: Star(size: CGSize(width: fontSize, height: fontSize), style: .full), count: count),
            spacing: 3
        )
        var image = stars.image
        image.isTemplate = true
        image = image.withTintColor(.labelColor)
        
        let attachment = NSTextAttachment()
        attachment.image = image
        // center vertical image
        attachment.bounds = CGRect(
            x: 0,
            y: (font.capHeight - image.size.height) * 0.5,
            width: image.size.width,
            height: image.size.height
        )

        let attributedString = NSMutableAttributedString()
        let attachmentAttributedString = NSAttributedString(attachment: attachment)
        attributedString.append(attachmentAttributedString)
        // not works. use tinted image workaround it
        attributedString.addAttribute(.foregroundColor, value: NSColor.labelColor, range: NSRange(location: 0, length: attributedString.length))
   
        return attributedString
    }
}

extension PreferencesViewController {

    @objc private func launchAtLoginCheckboxButtonChanged(_ sender: NSButton) {
        UserDefaults.standard.launchAtLogin = sender.state == .on
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

        launchAtLoginCheckboxButton.target = self
        launchAtLoginCheckboxButton.action = #selector(PreferencesViewController.launchAtLoginCheckboxButtonChanged(_:))
        launchAtLoginObservation = UserDefaults.standard.observe(\.launchAtLogin, options: [.initial, .new]) { [weak self] defaults, launchAtLogin in
            self?.launchAtLoginCheckboxButton.state = defaults.launchAtLogin ? .on : .off
        }
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
        case songRating5
        case songRating4
        case songRating3
        case songRating2
        case songRating1
        case songRating0
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
