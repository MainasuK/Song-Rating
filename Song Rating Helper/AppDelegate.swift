//
//  AppDelegate.swift
//  Song Rating Helper
//
//  Created by Cirno MainasuK on 2019-10-26.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import os

// Ref: https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/DesigningYourSandbox/DesigningYourSandbox.html#//apple_ref/doc/uid/TP40011183-CH4-SW3
//      https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLoginItems.html#//apple_ref/doc/uid/10000172i-SW5-SW1
//      https://products.delitestudio.com/start-dockless-apps-at-login-with-app-sandbox-enabled/

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let mainAppIdentifier = "com.mainasuk.Song-Rating"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains(where: { $0.bundleIdentifier == mainAppIdentifier })
        
        guard !isRunning else {
            os_log("%{public}s[%{public}ld], %{public}s: Main app isRunning. Helper exit", ((#file as NSString).lastPathComponent), #line, #function)
            terminate()
            return
        }
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(AppDelegate.terminate), name: .killLauncher, object: mainAppIdentifier)
        
        let path = Bundle.main.bundlePath as NSString
        var components = path.pathComponents
        components.removeLast()
        components.removeLast()
        components.removeLast()
        components.append("MacOS")
        components.append("Song Rating")
        
        let newPath = NSString.path(withComponents: components)
        
        os_log("%{public}s[%{public}ld], %{public}s: launch %{public}s", ((#file as NSString).lastPathComponent), #line, #function, newPath)
        NSWorkspace.shared.launchApplication(newPath)
    }

}

extension AppDelegate {
    
    @objc private func terminate() {
//        os_log("%{public}s[%{public}ld], %{public}s: exit", ((#file as NSString).lastPathComponent), #line, #function)
        NSApp.terminate(nil)
    }
    
}

