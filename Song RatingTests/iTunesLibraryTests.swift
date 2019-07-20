//
//  iTunesLibraryTests.swift
//  Song RatingTests
//
//  Created by Cirno MainasuK on 2019-7-20.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import XCTest
import iTunesLibrary

class iTunesLibraryTests: XCTestCase {
    
    var library: ITLibrary?

    override func setUp() {
        do {
            library = try ITLibrary(apiVersion: "1.0")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLink() {
        // should throw no error to link iTunesLibrary framework
        guard let library = library else {
            XCTFail()
            return
        }
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
