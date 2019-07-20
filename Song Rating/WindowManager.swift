//
//  WindowManager.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-2.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import os

final class WindowManager: NSObject {

    private(set) var aboutWindowController: NSWindowController?
    private(set) var preferencesWindowController: NSWindowController?

    var hasWindowDisplay: Bool {
        return ![aboutWindowController, preferencesWindowController].compactMap { $0 }.isEmpty
    }

    // MARK: - Singleton
    public static let shared = WindowManager()
    private override init() {
        super.init()
        
        NSWindow.allowsAutomaticWindowTabbing = false
    }
}

extension WindowManager {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

    }
    
}

extension WindowManager {

    func open(_ windowType: WindowType) {
        let windowController: NSWindowController? = {
            switch windowType {
            case .about:
                if aboutWindowController == nil {
                    aboutWindowController = NSWindowController(window: NSWindow(contentViewController: windowType.viewController))
                }
                return aboutWindowController

            case .preferences:
                if preferencesWindowController == nil {
                    preferencesWindowController = NSWindowController(window: NSWindow(contentViewController: windowType.viewController))
                }
                return preferencesWindowController
            }
        }()

        windowController?.window?.delegate = self
        windowController?.showWindow(self)
        
        // brint to front
        NSApplication.shared.activate(ignoringOtherApps: true)
        windowController?.window?.makeKeyAndOrderFront(nil)

        updateActivationPolicy()
    }

}

extension WindowManager {

    private func updateActivationPolicy() {
        NSApplication.shared.setActivationPolicy(hasWindowDisplay ? .regular : .accessory)
    }

}

extension WindowManager {

    enum WindowType {
        case about
        case preferences

        var viewController: NSViewController {
            switch self {
            case .about:        return AboutViewController()
            case .preferences:  return PreferencesViewController()
            }
        }
    }

}

// MARK: - NSWindowDelegate
extension WindowManager: NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else {
            return
        }

        switch notification {
        case _ where window === self.aboutWindowController?.window:
            aboutWindowController = nil
            os_log("%{public}s[%{public}ld], %{public}s: About window closed", ((#file as NSString).lastPathComponent), #line, #function)
        case _ where window === self.preferencesWindowController?.window:
            preferencesWindowController = nil
            os_log("%{public}s[%{public}ld], %{public}s: Preferences window closed", ((#file as NSString).lastPathComponent), #line, #function)
        default:
            assertionFailure()
        }

        updateActivationPolicy()
    }

}
