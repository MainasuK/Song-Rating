//
//  iTunesRadioStation.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-6-28.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Foundation
import ScriptingBridge
import os
import MASShortcut

extension Notification.Name {
    static let iTunesCurrentPlayInfoChanged = Notification.Name("iTunesCurrentPlayInfoChanged")
    static let iTunesRadioSetupRating = Notification.Name("iTunesRadioSetupRating")
}

final class iTunesRadioStation {

    // MARK: - Singleton
    static let shared = iTunesRadioStation()
    
    var iTunes: iTunesApplication? {
        let application = SBApplication(bundleIdentifier: "com.apple.iTunes")
        application?.delegate = self
        return application
    }
    
    private(set) var currentPlayInfo: PlayInfo? {
        didSet {
            NotificationCenter.default.post(name: .iTunesCurrentPlayInfoChanged, object: currentPlayInfo)
        }
    }
    
    private var debounceSetRatingTimer: Timer?
    
    private init() {
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(iTunesRadioStation.playInfoChanged(_:)), name: NSNotification.Name("com.apple.iTunes.playerInfo"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(iTunesRadioStation.sourceSaved(_:)), name: NSNotification.Name("com.apple.iTunes.sourceSaved"), object: nil)  // only set rating in iTunes edit song info panel can trigger that

        updateRadioStation()

        // Post notification to rating control to keep UI behavior consist
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PreferencesViewController.ShortcutKey.trackRatingUp.rawValue, toAction: {

        })
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PreferencesViewController.ShortcutKey.trackRatingDown.rawValue, toAction: {

        })
    }
    
    func updateRadioStation() {
        if let track = iTunes?.currentTrack,
            let name = track.name, !name.isEmpty,
            let rating = track.rating {
            let userInfo: [String : Any] = [
                "rating": rating,
                "playerState": iTunes?.playerState ?? iTunesEPlS.stopped
            ]
            NotificationCenter.default.post(name: .iTunesRadioSetupRating, object: rating, userInfo: userInfo)
        }
    }

}

extension iTunesRadioStation {
    
    @objc func sourceSaved(_ notification: Notification) {
        playInfoChanged(notification)
    }
    
    @objc func playInfoChanged(_ notification: Notification) {
        var dict: [String : Any] = [:]
        for (key, value) in notification.userInfo ?? [:] {
            guard let key = key as? String else { continue }
            switch value {
            case is Int:
                dict[key] = value as? Int ?? nil
            case is String:
                dict[key] = value as? String ?? nil
            case is Date:
                guard let date = value as? Date else { return }
                let formatter = ISO8601DateFormatter()
                dict[key] = formatter.string(from: date)
            default:
                os_log("%{public}s[%{public}ld], %{public}s: can not decode PlayInfo at key \"%{public}s\" with value \"%s\"", ((#file as NSString).lastPathComponent), #line, #function, key, String(describing: value))
                continue
            }
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .custom { keys -> CodingKey in
                let key = keys.last!
                return AnyKey(stringValue: key.stringValue.snakeCaseKey) ?? AnyKey(stringValue: "")!
            }
            let playInfo = try decoder.decode(PlayInfo.self, from: jsonData)
            
            os_log("%{public}s[%{public}ld], %{public}s: %{public}s", ((#file as NSString).lastPathComponent), #line, #function, playInfo.shortDescription)
            
            #if DEBUG
            let keys = Set(dict.keys.map { $0.snakeCaseKey })
            let labels = Mirror(reflecting: playInfo).children.compactMap { $0.label }
            let remains = keys.subtracting(labels)
            let remainsDict = dict.filter { remains.contains($0.key.snakeCaseKey) }
            if !remainsDict.isEmpty {
                os_log(.debug, "%{public}s[%{public}ld], %{public}s: remains info in dict %s not parse", ((#file as NSString).lastPathComponent), #line, #function, remainsDict.debugDescription)
            }
            #endif
            
            self.currentPlayInfo = playInfo
            
        } catch {
            os_log(.error, "%s: fail to parse playInfo with error %{public}s", #function, error.localizedDescription)
            assertionFailure(error.localizedDescription)
            return
        }
    }
    
}

extension iTunesRadioStation {


    /// setRating for current track
    ///
    /// - Parameter rating: integer in 0 ~ 100
    /// - Note: call track.setRating with debounce. Prevent apple event trigger jumping bug
    func setRating(_ rating: Int) {
        debounceSetRatingTimer?.invalidate()

        guard currentPlayInfo != nil || !(iTunes?.currentTrack?.name ?? "").isEmpty else {
            os_log("%{public}s[%{public}ld], %{public}s: try to set rating but no current track info", ((#file as NSString).lastPathComponent), #line, #function)
            return
        }

        // Note: currentPlayInfo could not set when App just launch without recieved playInfoChanged notification
        let name = currentPlayInfo?.name ?? iTunes?.currentTrack?.name ?? "nil"
        os_log("%{public}s[%{public}ld], %{public}s: set timer for 2.0s and set rating for %{public}s %{public}ld…", ((#file as NSString).lastPathComponent), #line, #function, name, rating)

        // FIXME: delay may cause set rating to *next* song just playing
        debounceSetRatingTimer = Timer(timeInterval: 2.0, repeats: false, block: { [weak self] timer in
            let track = self?.iTunes?.currentTrack
            track?.setRating?(rating)
            os_log("%{public}s[%{public}ld], %{public}s: … set %{public}s rating %{public}ld", ((#file as NSString).lastPathComponent), #line, #function, track?.name ?? "nil", rating)
        })
        debounceSetRatingTimer.flatMap {
            RunLoop.current.add($0, forMode: .default)
        }
    }
    
}

// MARK: - SBApplicationDelegate
extension iTunesRadioStation: SBApplicationDelegate {
    
    func eventDidFail(_ event: UnsafePointer<AppleEvent>, withError error: Error) -> Any? {
        var appleEvent = event.pointee
        let chars = [UInt8](Data(bytes: &appleEvent.descriptorType, count: 4))
        let id = chars.map { String(format: "%c", $0) }.joined()    // appleEvent 4 char id (descType)
        os_log("%{public}s[%{public}ld], %{public}s: AppleEvent (%{public}s) call fail with error %{public}s", ((#file as NSString).lastPathComponent), #line, #function, id, error.localizedDescription)
        return nil
    }
    
}

extension String {
    
    var snakeCaseKey: String {
        let joined = self.split(separator: " ").joined()
        return joined.prefix(1).lowercased() + joined.dropFirst()
    }
    
}

fileprivate struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

