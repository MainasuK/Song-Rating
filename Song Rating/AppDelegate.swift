//
//  AppDelegate.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-6-28.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import ServiceManagement
import os
import MASShortcut

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let radioStation = iTunesRadioStation.shared
    private(set) var menuBarRatingControl: MenuBarRatingControl?
    
    private var launchAtLoginObservation: NSKeyValueObservation?
    
    @IBAction func openAboutWindow(_ sender: NSMenuItem) {
        WindowManager.shared.open(.about)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // setup shortcut validator
        MASShortcutValidator.shared()!.allowAnyShortcutWithOptionModifier = true
        
        setupAppleEvent()
        setupUserDefaults()
        
        // setup menu bar
        menuBarRatingControl = MenuBarRatingControl()
        WindowManager.shared.menuBarRatingControl = menuBarRatingControl
        
        #if DEBUG
        // WindowManager.shared.open(.preferences)
        #endif
        
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
                    iTunesPlayer.shared.update()
                    
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
        // register shortcut
        do {
            let ratingDownShortcut = MASShortcut(keyCode: kVK_ANSI_Comma, modifierFlags: .option)
            let ratingUpShortcut = MASShortcut(keyCode: kVK_ANSI_Period, modifierFlags: .option)
            let showOrClosePopoverShortcut = MASShortcut(keyCode: kVK_ANSI_Slash, modifierFlags: .option)
            let ratingDownShortcutData = try NSKeyedArchiver.archivedData(withRootObject: ratingDownShortcut as Any, requiringSecureCoding: false)
            let ratingUpShortcutData = try NSKeyedArchiver.archivedData(withRootObject: ratingUpShortcut as Any, requiringSecureCoding: false)
            let showOrClosePopoverShortcutData = try NSKeyedArchiver.archivedData(withRootObject: showOrClosePopoverShortcut as Any, requiringSecureCoding: false)
            UserDefaults.standard.register(defaults: [
                PreferencesViewController.ShortcutKey.songRatingDown.rawValue : ratingDownShortcutData,
                PreferencesViewController.ShortcutKey.songRatingUp.rawValue : ratingUpShortcutData,
                PreferencesViewController.ShortcutKey.showOrClosePopover.rawValue : showOrClosePopoverShortcutData,
            ])
        } catch {
            os_log("%{public}s[%{public}ld], %{public}s: Default shortcut set fail", ((#file as NSString).lastPathComponent), #line, #function)
        }
        
        // register application behavior
        UserDefaults.standard.register(defaults: [
            ApplicationKey.isFirstLaunch.rawValue : true,
            ApplicationKey.launchAtLogin.rawValue : false
        ])
        
        // setup observer
        launchAtLoginObservation = UserDefaults.standard.observe(\.launchAtLogin, options: [.initial, .new]) { [weak self] defaults, change in
            os_log("%{public}s[%{public}ld], %{public}s: launchAtLoginObservation observe .launchAtLogin get newValue: %{public}s | oldValue: %{public}s", ((#file as NSString).lastPathComponent), #line, #function, change.newValue?.description ?? "nil", change.oldValue?.description ?? "nil")
            self?.setupLaunchAtLogin()
        }
        
    }
    
    private func setupLaunchAtLogin() {
        let launcherAppId = "com.mainasuk.Song-Rating-Helper"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains(where: { $0.bundleIdentifier == launcherAppId })
        
        let shouldLaunchAtLogin = UserDefaults.standard.launchAtLogin
        SMLoginItemSetEnabled(launcherAppId as CFString, shouldLaunchAtLogin)
        os_log("%{public}s[%{public}ld], %{public}s: set launchAtLogin to %{public}s", ((#file as NSString).lastPathComponent), #line, #function, shouldLaunchAtLogin.description)

        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher, object: Bundle.main.bundleIdentifier)
        }
        
    }
}
