//
//  AppContext.swift
//  
//
//  Created by MainasuK on 2022/11/18.
//

import os.log
import Foundation

public class AppContext {
    
    let logger = Logger(subsystem: "AppContext", category: "Context")

    public var assetURLCache = Set<URL>()

    public init() {
        // do nothing
    }
}

