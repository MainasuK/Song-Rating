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
        
        // Walk up from Contents/Library/LoginItems/Song Rating Helper.app to the
        // containing app bundle. `openApplication(at:)` takes an *application* URL, not
        // the executable inside it: passing Contents/MacOS/Song Rating made LaunchServices
        // treat it as a document to open, so the user saw
        // "not allowed to open the document" and nothing launched.
        let mainAppURL = Bundle.main.bundleURL
            .deletingLastPathComponent()    // LoginItems
            .deletingLastPathComponent()    // Library
            .deletingLastPathComponent()    // Contents
            .deletingLastPathComponent()    // Song Rating.app
        
        os_log("%{public}s[%{public}ld], %{public}s: launch %{public}s", ((#file as NSString).lastPathComponent), #line, #function, mainAppURL.path)
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = false
        NSWorkspace.shared.openApplication(at: mainAppURL,
                                           configuration: configuration) { _, error in
            if let error {
                os_log("%{public}s[%{public}ld], %{public}s: launch failed: %{public}s",
                       ((#file as NSString).lastPathComponent), #line, #function, error.localizedDescription)
            }
        }
    }

}

extension AppDelegate {
    
    @objc private func terminate() {
//        os_log("%{public}s[%{public}ld], %{public}s: exit", ((#file as NSString).lastPathComponent), #line, #function)
        NSApp.terminate(nil)
    }
    
}

