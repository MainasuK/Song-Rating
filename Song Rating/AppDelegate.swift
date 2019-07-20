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

    let radioStation = iTunesRadioStation.shared
    var menuBarRatingControl: MenuBarRatingControl?
    
    @IBAction func openAboutWindow(_ sender: NSMenuItem) {
        WindowManager.shared.open(.about)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupAppleEvent()
        setupUserDefaults()
    
        menuBarRatingControl = MenuBarRatingControl()
        
//        if UserDefaults.standard.bool(forKey: ApplicationKey.isFirstLaunch.rawValue) {
//            UserDefaults.standard.set(false, forKey: ApplicationKey.isFirstLaunch.rawValue)
//            WindowManager.shared.open(.preferences)
//        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        os_log("%{public}s[%{public}ld], %{public}s: Application will terminate", ((#file as NSString).lastPathComponent), #line, #function)
    }

}

extension AppDelegate {

    // Request AppleEvent permission
    func setupAppleEvent() {
        DispatchQueue.global().async {
            let target =  NSAppleEventDescriptor(bundleIdentifier: OSVersionHelper.bundleIdentifier)
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
            ApplicationKey.isFirstLaunch.rawValue : true
        ])
    }
    
    enum ApplicationKey: String {
        case isFirstLaunch
    }
    
}
