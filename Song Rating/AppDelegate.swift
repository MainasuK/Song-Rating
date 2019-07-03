//
//  AppDelegate.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-6-28.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import os
import MASShortcut

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let ratingControl = RatingControl(rating: 0)
    let radioStation = iTunesRadioStation.shared
    
    lazy var menuBarMenu: NSMenu = {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Preferences…", action: #selector(AppDelegate.preferencesMenuItemPressed(_:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Song Rating", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }()

    @IBAction func openAboutWindow(_ sender: NSMenuItem) {
        WindowManager.shared.open(.about)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupAppleEvent()
        setupUserDefaults()
        
        if let button = statusItem.button {
            ratingControl.hostView = button
            button.image = ratingControl.image
            button.sendAction(on: [.leftMouseUp, .rightMouseUp, .leftMouseDragged])
            button.action = #selector(AppDelegate.action(_:))
            button.setButtonType(.momentaryChange)
        }

        if UserDefaults.standard.bool(forKey: ApplicationKey.isFirstLaunch.rawValue) {
            UserDefaults.standard.set(false, forKey: ApplicationKey.isFirstLaunch.rawValue)
            WindowManager.shared.open(.preferences)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        os_log("%{public}s[%{public}ld], %{public}s: Application will terminate", ((#file as NSString).lastPathComponent), #line, #function)
    }

}

extension AppDelegate {
    
    @objc func action(_ sender: NSButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            let position = sender.convert(event.locationInWindow, to: nil)
            menuBarMenu.popUp(positioning: nil, at: position, in: sender)

        } else {
            ratingControl.action(from: sender, with: event)
        }
    }

    @objc func preferencesMenuItemPressed(_ sender: NSMenuItem) {
        WindowManager.shared.open(.preferences)
    }

}

extension AppDelegate {

    // Request AppleEvent permission
    func setupAppleEvent() {
        DispatchQueue.global().async {
            let target =  NSAppleEventDescriptor(bundleIdentifier: "com.apple.iTunes")
            let status = AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, true)
            
            DispatchQueue.main.async {
                switch status {
                case noErr:
                    os_log("%{public}s[%{public}ld], %{public}s: AppleEvent permission status: noErr", ((#file as NSString).lastPathComponent), #line, #function)
                    iTunesRadioStation.shared.updateRadioStation()
                    
                case OSStatus(procNotFound):
                    os_log("%{public}s[%{public}ld], %{public}s: AppleEvent permission status: iTunes not running", ((#file as NSString).lastPathComponent), #line, #function)
                case OSStatus(errAEEventNotPermitted):
                    os_log("%{public}s[%{public}ld], %{public}s: AppleEvent permission status: not permitted", ((#file as NSString).lastPathComponent), #line, #function)
                default:
                    os_log("%{public}s[%{public}ld], %{public}s: AppleEvent permission status: %s", ((#file as NSString).lastPathComponent), #line, #function, String(describing: status))
                }
                
            }
        }   // end DispatchQueue.global().async
    }
    
    func setupUserDefaults() {
        do {
            let ratingDownShortcut = MASShortcut(keyCode: kVK_ANSI_Comma, modifierFlags: .option)
            let ratingUpShortcut = MASShortcut(keyCode: kVK_ANSI_Period, modifierFlags: .option)
            let ratingDownShortcutData = try NSKeyedArchiver.archivedData(withRootObject: ratingDownShortcut as Any, requiringSecureCoding: false)
            let ratingUpShortcutData = try NSKeyedArchiver.archivedData(withRootObject: ratingUpShortcut as Any, requiringSecureCoding: false)
            UserDefaults.standard.register(defaults: [
                PreferencesViewController.ShortcutKey.songRatingDown.rawValue : ratingDownShortcutData,
                PreferencesViewController.ShortcutKey.songRatingUp.rawValue : ratingUpShortcutData,
                ])
        } catch {
            os_log("%{public}s[%{public}ld], %{public}s: Default shortcut set fail", ((#file as NSString).lastPathComponent), #line, #function)
        }
        
        UserDefaults.standard.register(defaults: [
            PreferencesUserDefaultsKey.hideMenuBarWhenNotPlaying.rawValue : NSControl.StateValue.on.rawValue
        ])
        
        UserDefaults.standard.register(defaults: [
            ApplicationKey.isFirstLaunch.rawValue : true
        ])
    }
    
    enum ApplicationKey: String {
        case isFirstLaunch
    }
    
}
