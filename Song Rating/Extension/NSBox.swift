//
//  NSBox.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2020/9/13.
//  Copyright © 2020 Cirno MainasuK. All rights reserved.
//

import Cocoa

extension NSBox {
    static var separatorLine: NSBox {
        let line = NSBox()
        line.boxType = .separator
        return line
    }
}
