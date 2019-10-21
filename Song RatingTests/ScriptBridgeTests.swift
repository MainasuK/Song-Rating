//
//  ScriptBridgeTests.swift
//  Song RatingTests
//
//  Created by Cirno MainasuK on 2019-7-21.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import XCTest
@testable import Song_Rating

class ScriptBridgeTests: XCTestCase {
    
    func testApplication() {
        let application = iTunesRadioStation.shared.iTunes
        let version = application?.version ?? ""
        
        XCTAssertFalse(version.isEmpty)
        print(version)
    }
    
    func testCurrentTrackToPlayInfo() {
        let iTunes = iTunesRadioStation.shared.iTunes
        let track = iTunes?.currentTrackCopy
        
        // Play something before start testing
        XCTAssertNotNil(track)
        
        // cover image (if have)
        let artwork = track?.artworks?().firstObject as? iTunesArtwork
        let image = artwork?.data
        XCTAssertNotNil(image)
        
        
        
    }
    
}
