//
//  iTunesPlayerHistory.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-8-15.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Foundation
import ScriptingBridge
import os

final class iTunesPlayerHistory {
    
    var limit = 10
    
    private var _tracks: [iTunesTrack] = []
    var tracks: [iTunesTrack] {
        return _tracks.filter { $0.exists?() == true }
    }
    
    init() {

        
    }
    
}

extension iTunesPlayerHistory {
    
    func insert(_ track: iTunesTrack) {
        _tracks.removeAll { $0.databaseID == track.databaseID }
        _tracks.append(track)
        _tracks = _tracks.filter { $0.exists?() == true }
        _tracks = _tracks.suffix(limit)
        
        os_log("%{public}s[%{public}ld], %{public}s: playback history append track: %{public}s", ((#file as NSString).lastPathComponent), #line, #function, track.name ?? "null")

        /*
        for track in tracks {
            print(track.name, track.databaseID)
        }
         */
    }
    
}

