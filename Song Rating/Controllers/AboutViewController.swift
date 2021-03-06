//
//  AboutViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-2.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

final class AboutViewController: NSViewController {

    // lazy var imageView = NSImageView()
    lazy var visualEffectBackgroundView: NSVisualEffectView = {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.material = .underWindowBackground
        visualEffectView.isEmphasized = true
        visualEffectView.state = .active
        return visualEffectView
    }()
    lazy var titleTextField: NSTextField = {
        let textField = NSTextField(labelWithString: String.infoValue(for: "CFBundleName") ?? "Song Rating")
        textField.font = NSFont.systemFont(ofSize: 18, weight: .semibold)
        return textField
    }()
    lazy var versionTextFiled: NSTextField = {
        let version = String.infoValue(for: "CFBundleShortVersionString") ?? "NA"
        let build = String.infoValue(for: "CFBundleVersion").flatMap { "(\($0))" } ?? "(NA)"
        let string = [version, build].joined(separator: " ")
        let textField = NSTextField(labelWithString: string)
        textField.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        return textField
    }()
    lazy var copyrightTextField: NSTextField = {
        let textField = NSTextField(labelWithString: String.infoValue(for: "NSHumanReadableCopyright") ?? "")
        textField.font = NSFont.systemFont(ofSize: 9, weight: .light)
        textField.textColor = NSColor.secondaryLabelColor
        return textField
    }()

    lazy var contactMeButton: NSButton = {
        let button = NSButton()
        button.title = "Contact me"
        button.bezelStyle = NSButton.BezelStyle.inline
        button.action = #selector(AboutViewController.contactMeButtonPressed(_:))
        return button
    }()

    lazy var githubButton: NSButton = {
        let button = NSButton()
        button.title = "GitHub"
        button.bezelStyle = NSButton.BezelStyle.inline
        button.action = #selector(AboutViewController.githubButtonPressed(_:))
        return button
    }()

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 200))
    }

}

extension AboutViewController {

    func setupWindow() {
        view.window?.styleMask.remove(.resizable)
        view.window?.styleMask.insert(.fullSizeContentView)
        view.window?.titleVisibility = .hidden
        view.window?.titlebarAppearsTransparent = true
        view.window?.isOpaque = false
        view.window?.isMovableByWindowBackground = true
    }

    @objc func contactMeButtonPressed(_ sender: NSButton) {
        guard let url = URL(string: "https://twitter.com/MainasuK") else { return }
        NSWorkspace.shared.open(url)
    }

    @objc func githubButtonPressed(_ sender: Bundle) {
        guard let url = URL(string: "https://github.com/MainasuK/Song-Rating") else { return }
        NSWorkspace.shared.open(url)
    }

}

extension AboutViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "About"
        
        visualEffectBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectBackgroundView)
        NSLayoutConstraint.activate([
            visualEffectBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            visualEffectBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let contentView = NSView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectBackgroundView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: visualEffectBackgroundView.topAnchor, constant: 4 + 22),
            contentView.leadingAnchor.constraint(equalTo: visualEffectBackgroundView.leadingAnchor, constant: 16),
            visualEffectBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 16),
            visualEffectBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8),
        ])

        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleTextField)
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        versionTextFiled.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(versionTextFiled)
        NSLayoutConstraint.activate([
            versionTextFiled.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 4),
            versionTextFiled.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        copyrightTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(copyrightTextField)
        NSLayoutConstraint.activate([
            copyrightTextField.trailingAnchor.constraint(equalTo: versionTextFiled.trailingAnchor),
            copyrightTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        githubButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(githubButton)
        NSLayoutConstraint.activate([
            copyrightTextField.topAnchor.constraint(equalTo: githubButton.bottomAnchor, constant: 4),
            githubButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        contactMeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contactMeButton)
        NSLayoutConstraint.activate([
            copyrightTextField.topAnchor.constraint(equalTo: contactMeButton.bottomAnchor, constant: 4),
            githubButton.leadingAnchor.constraint(equalTo: contactMeButton.trailingAnchor, constant: 8),
            contactMeButton.widthAnchor.constraint(equalTo: githubButton.widthAnchor, multiplier: 1.0),
        ])
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        setupWindow()
    }

}

extension String {

    fileprivate static func infoValue(for key: String) -> String? {
        return Bundle.main.infoDictionary?[key] as? String
    }

}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(OSX 10.15.0, *)
struct AboutViewController_Preview: PreviewProvider {
    
    static var previews: some View {
        NSViewControllerPreview {
            return AboutViewController()
        }
    }
    
}

#endif
