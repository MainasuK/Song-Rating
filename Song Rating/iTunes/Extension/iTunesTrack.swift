//
//  iTunesTrack.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-8-17.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Foundation

extension iTunesTrack {
    
    var userRating: Int? {
        return ratingKind == .user ? rating : nil
    }
    
}
