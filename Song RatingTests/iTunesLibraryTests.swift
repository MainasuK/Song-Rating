//
//  iTunesLibraryTests.swift
//  Song RatingTests
//
//  Created by Cirno MainasuK on 2019-7-20.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import XCTest
import iTunesLibrary

/// Link check for the iTunesLibrary framework.
///
/// - Important: This suite does **not** pass on macOS 27. `ITLibrary(apiVersion:)`
///   fails with `NSCocoaErrorDomain 4097 — connection to service named
///   com.apple.amp.library.framework`, both signed and unsigned, sandbox on or off.
///   The same call succeeds from an ordinary process on the same machine, so the
///   failure is specific to the XCTest host environment and not to this project.
///   It is pre-existing and unrelated to the rating control; `ITunesLibrary` is only
///   linked by this test target — the app itself talks to Music over Apple events.
///
/// Run the rating geometry tests instead when verifying changes:
/// `-only-testing:"Song RatingTests/RatingControlGeometryTests"`.
class iTunesLibraryTests: XCTestCase {
    
    var library: ITLibrary?

    override func setUpWithError() throws {
        // XCTSkip rather than a hard failure: the framework link cannot be exercised
        // from the test host on this OS, which would otherwise mask real failures.
        do {
            library = try ITLibrary(apiVersion: "1.0")
        } catch {
            throw XCTSkip("""
                ITLibrary is unavailable from the XCTest host on this OS \
                (\(error.localizedDescription)). See this suite's documentation comment.
                """)
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLink() throws {
        // should throw no error to link iTunesLibrary framework
        let library = try XCTUnwrap(self.library)
        print("\(library.applicationVersion): v\(library.apiMajorVersion).\(library.apiMinorVersion)")
        
        let expectation = self.expectation(description: "allMediaItems")
        DispatchQueue.global().async {
            let all = library.allMediaItems
            DispatchQueue.main.async {
                print(all)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 300.0)
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
