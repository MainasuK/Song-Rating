//
//  WindowManager.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-2.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import os
import MASShortcut

final class WindowManager: NSObject {

    private(set) var aboutWindowController: NSWindowController?
    private(set) var preferencesWindowController: NSWindowController?
    private(set) var popoverWindowController: NSWindowController?

    private var hasWindowDisplay: Bool {
        return ![aboutWindowController, preferencesWindowController].compactMap { $0 }.isEmpty
    }
    
    private let popoverProxy = PopoverProxy()
    
    weak var menuBarRatingControl: MenuBarRatingControl?
    private(set) var invisibleWindows: [Int: NSWindow] = [:]
    private(set) var undetachedPopover: NSPopover?
    private(set) var detachedPopover: NSPopover?

    // MARK: - Singleton
    public static let shared = WindowManager()
    
    private override init() {
        super.init()
        
        NSWindow.allowsAutomaticWindowTabbing = false
        
        popoverProxy.delegate = self
        
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PreferencesViewController.ShortcutKey.showOrClosePopover.rawValue, toAction: { [weak self] in
            guard self?.undetachedPopover == nil else {
                self?.undetachedPopover?.close()
                self?.undetachedPopover = nil
                return
            }
            
            self?.showPopover()
        })
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
            case .popover:
                if popoverWindowController == nil {
                    popoverWindowController = NSWindowController(window: NSWindow(contentViewController: windowType.viewController))
                }
                return popoverWindowController
            }
        }()

        windowController?.window?.delegate = self
        windowController?.showWindow(self)
        
        // brint to front
        NSApplication.shared.activate(ignoringOtherApps: true)
        windowController?.window?.makeKeyAndOrderFront(nil)

        updateActivationPolicy()
    }
    
    func showPopover() {
        guard let button = menuBarRatingControl?.statusItem.button else {
            return
        }
        
        // Ref: https://stackoverflow.com/questions/48594212/how-to-open-a-nspopover-at-a-distance-from-the-system-bar/48604455#48604455
        // TODO: fix windows leaking issue
        let popoverRelativeWindow = NSWindow(contentRect: NSMakeRect(0, 0, 20, 5), styleMask: .borderless, backing: .buffered, defer: false)
        popoverRelativeWindow.delegate = self
        popoverRelativeWindow.backgroundColor = .red
        popoverRelativeWindow.alphaValue = 1

        // find the coordinates of the statusBarItem in screen space
        let buttonRect = button.convert(button.bounds, to: nil)
        guard let buttonWindow = button.window else {
            assertionFailure()
            return
        }
        let screenRect = buttonWindow.convertToScreen(buttonRect)
        
        // calculate the bottom center position (10 is the half of the window width)
        let posX = screenRect.origin.x + (screenRect.width / 2) - 10
        let posY = screenRect.origin.y
        
        // position and show the window
        popoverRelativeWindow.setFrameOrigin(NSPoint(x: posX, y: posY))
        popoverRelativeWindow.makeKeyAndOrderFront(self)
        popoverRelativeWindow.level = .floating                       // make popover always on top
        popoverRelativeWindow.isReleasedWhenClosed = false            // seealso: WindowManager.popoverDidClose(_:)
    
        let popover = NSPopover()
        popover.contentViewController = WindowManager.WindowType.popover.viewController
        popover.behavior = .transient
        popover.delegate = popoverProxy
        
        invisibleWindows[popover.hashValue] = popoverRelativeWindow
        
        // position and show the NSPopover
        popover.show(relativeTo: popoverRelativeWindow.contentView!.frame, of: popoverRelativeWindow.contentView!, preferredEdge: NSRectEdge.minY)
//        NSApplication.shared.activate(ignoringOtherApps: true)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            popover.contentViewController?.view.window?.makeKey()   // fix popover not get focus issue
//        }
    
        undetachedPopover = popover
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
        case popover

        var viewController: NSViewController {
            switch self {
            case .about:        return AboutViewController()
            case .preferences:  return PreferencesViewController()
            case .popover:      return PopoverViewController()
            }
        }
    }

}

extension WindowManager {
    
    @objc func preferencesMenuItemPressed(_ sender: NSMenuItem) {
        open(.preferences)
    }
    
    @objc func aboutMenuItemPressed(_ sender: NSMenuItem) {
        open(.about)
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
        case _ where window === self.popoverWindowController?.window:
            popoverWindowController = nil
            os_log("%{public}s[%{public}ld], %{public}s: Popover window closed", ((#file as NSString).lastPathComponent), #line, #function)
        default:
            os_log("%{public}s[%{public}ld], %{public}s: %{public}s", ((#file as NSString).lastPathComponent), #line, #function, notification.description)
        }

        updateActivationPolicy()
    }
}

// MARK: - PopoverProxyDelegate
extension WindowManager: PopoverProxyDelegate {
    
    func popoverDidClose(_ notification: Notification) {
        // check which popover closed and release it
        
        os_log("%{public}s[%{public}ld], %{public}s: %{public}s", ((#file as NSString).lastPathComponent), #line, #function, notification.description)
        
        if let popover = undetachedPopover, !popover.isShown {
            undetachedPopover = nil
        }
        
        if let popover = detachedPopover, !popover.isShown {
            detachedPopover = nil
        }
        
        // fix popover relative window crash app when set release when close issue
        if let popover = notification.object as? NSPopover {
            let window = self.invisibleWindows[popover.hashValue]       // retain
            self.invisibleWindows[popover.hashValue] = nil
            window?.close()
            // auto release here
        }
    }

    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        popover.configureCloseButton()
        return true
    }
    
    func popoverDidDetach(_ popover: NSPopover) {
        undetachedPopover = nil
        detachedPopover?.close()
        
        popover.behavior = .applicationDefined
        detachedPopover = popover
        
        os_log("%{public}s[%{public}ld], %{public}s: popoverDidDetach", ((#file as NSString).lastPathComponent), #line, #function)
    }

}
