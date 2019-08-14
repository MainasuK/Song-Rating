//
//  TrackPlaybackRecorder.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-8-15.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Foundation
import ScriptingBridge
import os

final class TrackPlaybackRecorder {
    
    private var _tracks: [iTunesTrack] = []
    var tracks: [iTunesTrack] {
        return _tracks.filter { $0.exists?() == true }
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(TrackPlaybackRecorder.iTunesPlayInfoChanged(_:)), name: .iTunesPlayInfoChanged, object: nil)
    }
    
}

extension TrackPlaybackRecorder {
    
    @objc func iTunesPlayInfoChanged(_ notification: Notification) {
        // Get track object deep copy
        guard let object = iTunesRadioStation.shared.iTunes?.currentTrack as? SBObject,
        let track = object.get() as? iTunesTrack else {
            return
        }

        _tracks.removeAll { $0.databaseID == track.databaseID }
        _tracks.append(track)
        _tracks = _tracks.filter { $0.exists?() == true }
        
        os_log("%{public}s[%{public}ld], %{public}s: playback history append track: %{public}s", ((#file as NSString).lastPathComponent), #line, #function, track.name ?? "null")
        
        for track in tracks {
            print(track.name, track.databaseID)
        }
    }
    
}

