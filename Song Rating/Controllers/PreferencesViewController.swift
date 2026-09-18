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

    lazy var startupTextField: NSTextField = {
        return NSTextField(labelWithString: "Startup: ")
    }()
    lazy var halfStarTextField: NSTextField = {
        return NSTextField(labelWithString: "Half star: ")
    }()
    /// Circular ⓘ button that opens a popover with the Terminal commands.
    ///
    /// Music has no UI for this: the hidden `allow-half-stars` preference has to be set
    /// through its defaults domain. The app cannot do it for the user — it is sandboxed,
    /// and the sandbox silently redirects writes to another app's defaults domain into
    /// this app's own container — so the commands are shown for the user to run.
    lazy var halfStarInfoButton: NSButton = {
        let button = NSButton()
        button.bezelStyle = .inline
        button.isBordered = false
        button.image = NSImage(systemSymbolName: "info.circle", accessibilityDescription: "About half stars")
        button.imagePosition = .imageOnly
        button.contentTintColor = .secondaryLabelColor
        button.toolTip = "About half stars in Music"
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    lazy var halfStarInfoPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = HalfStarInfoViewController()
        return popover
    }()
    /// Explanation, then each command on its own line in a monospaced font so it can be
    /// read and copied as-is, then a caveat about newer systems.
    static let halfStarHint: NSAttributedString = {
        let body: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
            .foregroundColor: NSColor.labelColor,
        ]
        let note: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
            .foregroundColor: NSColor.secondaryLabelColor,
        ]
        let command: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular),
            .foregroundColor: NSColor.labelColor,
        ]
        
        let hint = NSMutableAttributedString(
            string: "Music shows half stars only after running one of these in Terminal:\n",
            attributes: body
        )
        for line in [
            "defaults write com.apple.Music allow-half-stars -bool TRUE",
            "defaults write com.apple.Music allow-half-stars -bool FALSE",
        ] {
            hint.append(NSAttributedString(string: line + "\n", attributes: command))
        }
        // Music keeps storing half stars on recent systems, but its rating column only
        // draws whole stars, so the value is saved without being visible there.
        hint.append(NSAttributedString(
            string: "\nNote: half stars are still saved, but recent macOS versions may not display them.",
            attributes: note
        ))
        return hint
    }()
    lazy var songRatingDownTextField: NSTextField = {
        return NSTextField(labelWithString: "Song rating down: ")
    }()
    lazy var songRatingUpTextField: NSTextField = {
        return NSTextField(labelWithString: "Song rating up: ")
    }()
    lazy var showOrClosePopoverTextField: NSTextField = {
        return NSTextField(labelWithString: "Show/Close popover: ")
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
    
    let launchAtLoginCheckboxButton: NSButton = {
        let button = NSButton(checkboxWithTitle: "Launch at login", target: nil, action: nil)
        return button
    }()
    let halfStarCheckboxButton: NSButton = {
        let button = NSButton(checkboxWithTitle: "Enable", target: nil, action: nil)
        return button
    }()
    /// The checkbox with the info button next to it.
    lazy var halfStarRow: NSStackView = {
        let stackView = NSStackView(views: [halfStarCheckboxButton, halfStarInfoButton])
        stackView.orientation = .horizontal
        stackView.spacing = 6
        stackView.alignment = .centerY
        return stackView
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

    let leadingPaddingView = NSView()
    let trailingPaddingView = NSView()

    lazy var gridView: NSGridView = {
        let empty = NSGridCell.emptyContentView
        
        let gridView = NSGridView(views: [
            [startupTextField, launchAtLoginCheckboxButton],
            [halfStarTextField, halfStarRow],
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
    var halfStarObservation: NSKeyValueObservation?

    override func loadView() {
        self.view = NSView()
    }

    deinit {
        launchAtLoginObservation?.invalidate()
        halfStarObservation?.invalidate()
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
    
    @objc private func halfStarCheckboxButtonChanged(_ sender: NSButton) {
        UserDefaults.standard.allowHalfStar = sender.state == .on
    }
    
    @objc private func halfStarInfoButtonPressed(_ sender: NSButton) {
        guard !halfStarInfoPopover.isShown else {
            halfStarInfoPopover.performClose(sender)
            return
        }
        halfStarInfoPopover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxX)
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
        
        halfStarCheckboxButton.target = self
        halfStarCheckboxButton.action = #selector(PreferencesViewController.halfStarCheckboxButtonChanged(_:))
        halfStarInfoButton.target = self
        halfStarInfoButton.action = #selector(PreferencesViewController.halfStarInfoButtonPressed(_:))
        halfStarObservation = UserDefaults.standard.observe(\.allowHalfStar, options: [.initial, .new]) { [weak self] defaults, launchAtLogin in
            self?.halfStarCheckboxButton.state = defaults.allowHalfStar ? .on : .off
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

/// Popover contents for the half-star info button: why Music needs the command, and
/// the commands themselves, shown in a monospaced font so they can be copied.
final class HalfStarInfoViewController: NSViewController {

    /// Width the commands are measured against; the longer one needs ~401pt.
    private static let contentWidth: CGFloat = 440

    lazy var textField: NSTextField = {
        let textField = NSTextField(labelWithAttributedString: PreferencesViewController.halfStarHint)
        textField.isSelectable = true          // so a command can be copied
        textField.lineBreakMode = .byWordWrapping
        textField.maximumNumberOfLines = 0     // no limit inside the popover
        textField.preferredMaxLayoutWidth = Self.contentWidth
        return textField
    }()

    override func loadView() {
        let container = NSView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
        ])
        self.view = container
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // NSPopover sizes itself from `preferredContentSize`; without it the popover
        // collapses to a narrow default and squeezes the text.
        //
        // `fittingSize` must be read *after* the constraints are resolved: queried too
        // early it reports a stale height and the last line gets clipped, which is what
        // happened here — the popover reserved room for the note but the label was cut
        // off before it. Lay out first, then measure.
        view.layoutSubtreeIfNeeded()
        let fitting = view.fittingSize
        preferredContentSize = NSSize(width: Self.contentWidth + 24, height: fitting.height)
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        // Keep the popover in step if the text or width changes after first layout.
        let fitting = view.fittingSize
        guard fitting.height > 0, preferredContentSize.height != fitting.height else { return }
        preferredContentSize = NSSize(width: Self.contentWidth + 24, height: fitting.height)
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
