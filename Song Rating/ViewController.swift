//
//  ViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-6-28.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa
import ScriptingBridge

// Debug only
class ViewController: NSViewController {
    
    let iTunes: iTunesApplication? = SBApplication(bundleIdentifier: "com.apple.iTunes")!

    let radioStation = iTunesRadioStation.shared
    
    let starsView = NSView()
    let ratingControl = RatingControl(rating: 0, size: NSSize(width: 100, height: 100), spacing: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let starImage = ratingControl.image
        starImage.isTemplate = true
        let imageView = NSImageView(frame: NSRect(origin: .zero, size: starImage.size))
        imageView.image = starImage
        
        starsView.frame.size = imageView.bounds.size
        starsView.addSubview(imageView)
        ratingControl.hostView = imageView

        view.addSubview(starsView)
        NSLayoutConstraint.activate([
            starsView.topAnchor.constraint(equalTo: view.topAnchor),
            starsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            starsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

