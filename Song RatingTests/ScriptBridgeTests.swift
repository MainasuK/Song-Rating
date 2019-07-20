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
    }
    
}
