//
//  ViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-6-28.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import ScriptingBridge

class ViewController: NSViewController {
    
    let iTunes: iTunesApplication? = SBApplication(bundleIdentifier: "com.apple.iTunes")!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
        //print(iTunes?.isRunning)
        //print(iTunes!.version)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        DispatchQueue.global().async {
            let target =  NSAppleEventDescriptor(bundleIdentifier: "com.apple.iTunes")
            let status = AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, true)
            
            DispatchQueue.main.async {
                print(status)
            }
        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

