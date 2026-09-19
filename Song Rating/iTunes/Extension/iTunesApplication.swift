//
//  iTunesApplication.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-8-16.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Foundation
import ScriptingBridge

extension iTunesApplication {
    
    var currentTrackCopy: iTunesTrack? {
        guard let object = currentTrack as? SBObject,
        let track = object.get() as? iTunesTrack else {
            return nil
        }
        
        return track
    }
    
}

extension iTunesTrack {
    public func copy() -> iTunesTrack? {
        guard let copy = self.get() as? iTunesTrack else {
            assertionFailure()
            return nil
        }
        return copy
    }
}
