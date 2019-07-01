//
//  AppDelegate.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-6-28.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import os

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let ratingControl = RatingControl(rating: 0)
    let radioStation = iTunesRadioStation.shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupAppleEvent()
        
        if let button = statusItem.button {
            button.image = ratingControl.image
            button.sendAction(on: [.leftMouseUp, .rightMouseUp, .leftMouseDragged])
            button.action = #selector(AppDelegate.action(_:))
            button.setButtonType(.momentaryChange)
            ratingControl.hostView = button
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

extension AppDelegate {
    
    @objc func action(_ sender: NSButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            
        } else {
            ratingControl.action(from: sender, with: event)
        }
    }
    
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
    
}
