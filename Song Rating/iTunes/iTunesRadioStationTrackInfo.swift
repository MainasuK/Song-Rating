//
//  iTunesRadioStationTrackInfo.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-7-20.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Foundation


struct iTunesRadioStationTrackInfo {
    
    let rating: Int
    let isPlaying: Bool
    
    init(rating: Int, isPlaying: Bool) {
        self.rating = rating
        self.isPlaying = isPlaying
    }
    
}

extension iTunesRadioStationTrackInfo {
    
    init?(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return nil
        }
        
        guard let rating = userInfo["rating"] as? Int,
            let isPlaying = userInfo["isPlaying"] as? Bool else {
                return nil
        }
        
        self.init(rating: rating, isPlaying: isPlaying)
    }
    
    var userInfo: [String : Any] {
        return [
            "rating": rating,
            "isPlaying": isPlaying,
        ]
    }
    
}
