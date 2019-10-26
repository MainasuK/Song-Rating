//
//  UserDefaults.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-10-26.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Foundation

enum ApplicationKey: String {
    case isFirstLaunch
    case launchAtLogin
}

extension UserDefaults {
    
    subscript<T: RawRepresentable>(key: String) -> T? {
        get {
            if let rawValue = value(forKey: key) as? T.RawValue {
                return T(rawValue: rawValue)
            }
            return nil
        }
        set { set(newValue?.rawValue, forKey: key) }
    }
    
    subscript<T>(key: String) -> T? {
        get { return value(forKey: key) as? T }
        set { set(newValue, forKey: key) }
    }
    
}

extension UserDefaults {
    
    @objc dynamic var launchAtLogin: Bool {
        get {
            return bool(forKey: ApplicationKey.launchAtLogin.rawValue)
        }
        set {
            set(newValue, forKey: ApplicationKey.launchAtLogin.rawValue)
        }
    }
    
}
