//
//  iTunesRadioStation.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-6-28.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import os
import Foundation
import ScriptingBridge
import MASShortcut
import DiscordGameSDK
import ArkanaKeys
import SDK
import AWSS3
import AWSClientRuntime
import CryptoKit

extension Notification.Name {
//    static let iTunesPlayInfoChanged = Notification.Name("iTunesPlayInfoChanged")
//    static let iTunesRadioDidSetupRating = Notification.Name("iTunesRadioDidSetupRating")
    static let iTunesRadioRequestTrackRatingUp = Notification.Name("iTunesRadioRequestTrackRatingUp")
    static let iTunesRadioRequestTrackRatingDown = Notification.Name("iTunesRadioRequestTrackRatingDown")
    static let iTunesRadioRequestTrackRating5 = Notification.Name("iTunesRadioRequestTrackRating5")
    static let iTunesRadioRequestTrackRating4 = Notification.Name("iTunesRadioRequestTrackRating4")
    static let iTunesRadioRequestTrackRating3 = Notification.Name("iTunesRadioRequestTrackRating3")
    static let iTunesRadioRequestTrackRating2 = Notification.Name("iTunesRadioRequestTrackRating2")
    static let iTunesRadioRequestTrackRating1 = Notification.Name("iTunesRadioRequestTrackRating1")
    static let iTunesRadioRequestTrackRating0 = Notification.Name("iTunesRadioRequestTrackRating0")
}

final class iTunesRadioStation {

    let logger = Logger(subsystem: "iTunesRadioStation", category: "Service")
    
    // MARK: - Singleton
    static let shared = iTunesRadioStation()

    private lazy var _iTunes: iTunesApplication? = {
        let application = SBApplication(bundleIdentifier: OSVersionHelper.bundleIdentifier)
        application?.delegate = self
        return application
    }()

    var iTunes: iTunesApplication? {
        guard _iTunes?.isRunning == true else {
            return nil
        }
        return _iTunes
    }

    private(set) var latestPlayInfo: PlayInfo? {
        didSet {
            iTunesPlayer.shared.update()
            // os_log("%{public}s[%{public}ld], %{public}s: latestPlayInfo %s", ((#file as NSString).lastPathComponent), #line, #function, latestPlayInfo?.description ?? "nil")
        }
    }

    private var debounceSetRatingTimer: Timer?

    private init() {
        // Listen iTunes play state change notification
        // Note: The notification name on Catalina is same as Mojave
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(iTunesRadioStation.playInfoChanged(_:)), name: NSNotification.Name("com.apple.iTunes.playerInfo"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(iTunesRadioStation.sourceSaved(_:)), name: NSNotification.Name("com.apple.iTunes.sourceSaved"), object: nil)  // only set rating in iTunes edit song info panel can trigger that

        // Due to iTunes may already playing before app launch,update player when app start
        iTunesPlayer.shared.update(iTunes?.currentTrackCopy)

        // Bind and broadcast keyboard
        // Notify control directly without trigger player update notification
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PreferencesViewController.ShortcutKey.songRatingUp.rawValue, toAction: {
            iTunesPlayer.shared.update(broadcast: false)
            NotificationCenter.default.post(name: .iTunesRadioRequestTrackRatingUp, object: nil)
        })
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PreferencesViewController.ShortcutKey.songRatingDown.rawValue, toAction: {
            iTunesPlayer.shared.update(broadcast: false)
            NotificationCenter.default.post(name: .iTunesRadioRequestTrackRatingDown, object: nil)
        })
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PreferencesViewController.ShortcutKey.songRating5.rawValue, toAction: {
            iTunesPlayer.shared.update(broadcast: false)
            NotificationCenter.default.post(name: .iTunesRadioRequestTrackRating5, object: nil)
        })
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PreferencesViewController.ShortcutKey.songRating4.rawValue, toAction: {
            iTunesPlayer.shared.update(broadcast: false)
            NotificationCenter.default.post(name: .iTunesRadioRequestTrackRating4, object: nil)
        })
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PreferencesViewController.ShortcutKey.songRating3.rawValue, toAction: {
            iTunesPlayer.shared.update(broadcast: false)
            NotificationCenter.default.post(name: .iTunesRadioRequestTrackRating3, object: nil)
        })
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PreferencesViewController.ShortcutKey.songRating2.rawValue, toAction: {
            iTunesPlayer.shared.update(broadcast: false)
            NotificationCenter.default.post(name: .iTunesRadioRequestTrackRating2, object: nil)
        })
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PreferencesViewController.ShortcutKey.songRating1.rawValue, toAction: {
            iTunesPlayer.shared.update(broadcast: false)
            NotificationCenter.default.post(name: .iTunesRadioRequestTrackRating1, object: nil)
        })
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PreferencesViewController.ShortcutKey.songRating0.rawValue, toAction: {
            iTunesPlayer.shared.update(broadcast: false)
            NotificationCenter.default.post(name: .iTunesRadioRequestTrackRating0, object: nil)
        })
        
        setupDiscordActivity()
    }
    


    private func setupDiscordActivity() {
        // start eventLoop
        Task(priority: .background) {
            while true {
                // update discord activity
                var discord = await AppContext.shared.discord
                let activityManager = discord.activities
                
                if var activity = await createDiscordActivity() {
                    activityManager?.pointee.update_activity(activityManager, &activity, nil, nil)
                } else {
//                    var activity = DiscordActivity()
//                    activityManager?.pointee.update_activity(activityManager, &activity, nil, nil)
                    let callback: (@convention(c) (UnsafeMutableRawPointer?, EDiscordResult) -> Void) = { context, result in
                        if result.rawValue == DiscordResult_Ok.rawValue {
                            print("Successfully clear the current activity")
                        } else {
                            print("Failed to clear the current activity")
                        }
                    }
                    activityManager?.pointee.clear_activity(activityManager, &discord, callback)
                }
                
                assert(!Thread.isMainThread)
                try await Task.sleep(nanoseconds: 5 * .second)  // 5s
            }
        }   // end Task
    }
    
    @MainActor
    private func createDiscordActivity() async -> DiscordActivity? {
        var activity = DiscordActivity()
        activity.type = DiscordActivityType_Listening
        
        guard iTunes?.playerState == .playing else { return nil }
        
        if let track = iTunes?.currentTrack {
            let state = [track.album, track.artist ?? track.albumArtist]
                .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: " - ")
            state.toTuple(tuple: &activity.state, size: 128)
            let details = [track.trackNumber.flatMap { "\($0). " }, track.name]
                .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined()
            details.toTuple(tuple: &activity.details, size: 128)
            
            if let playerPosition = iTunes?.playerPosition,
               let totalTime = track.duration
            {
                let now = Date()
                let start = Date(timeInterval: -playerPosition, since: now)
                let end = start.addingTimeInterval(totalTime)
                activity.timestamps = DiscordActivityTimestamps(
                    start: DiscordTimestamp(start.timeIntervalSince1970),
                    end: DiscordTimestamp(end.timeIntervalSince1970)
                )
            }
            
            do {
                let firstImage: NSImage? = {
                    do {
                        return try ExceptionCatcher.catchException {
                            guard let artwork = track.artworks?().firstObject as? iTunesArtwork else { return nil }
                            if let descriptor = (artwork.data as Any) as? NSAppleEventDescriptor {
                                return NSImage(data: descriptor.data)
                            }
                            if let image = (artwork.data as Any) as? NSImage {
                                return image
                            }
                            if let data = artwork.rawData, let image = NSImage(data: data) {
                                return image
                            }
                            
                            return nil
                        } as? NSImage ?? nil
                    } catch {
                        os_log("%{public}s[%{public}ld], %{public}s: %{public}s", ((#file as NSString).lastPathComponent), #line, #function, error.localizedDescription)
                        return nil
                    }
                }()
                
                let filename = [track.year.flatMap(String.init), track.album, track.albumArtist]
                    .compactMap { $0 }
                    .map { $0.replacingOccurrences(of: "/", with: "") }
                    .joined(separator: "_")
                
                guard let image = firstImage, let data = image.imageJPEGRepresentation(), !filename.isEmpty else {
                    throw NSError()
                }
                
                let digest = Data(filename.utf8).sha256
                
                let key = String(digest.prefix(42)) + ".jpg"
                var url = URL(string: "https://mainasuk.sfo3.digitaloceanspaces.com")!
                url.appendPathComponent(key)
                
                if !AppContext.shared.assetURLCache.contains(url) {
                    let client = try await S3Client(config: S3Client.S3ClientConfiguration(
                        credentialsProvider: DigitalOceanCredentialsProvider(),
                        endpoint: "https://sfo3.digitaloceanspaces.com",
                        region: "us-east-1"
                    ))
                    
                    _ = try await client.putObject(input: PutObjectInput(
                        acl: .publicRead,
                        body: .from(data: data),
                        bucket: "mainasuk",
                        contentType: "image/jpeg",
                        key: key
                    ))
                    AppContext.shared.assetURLCache.insert(url)
                    logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public): upload album cover:\n\(url.absoluteString)")
                }
                
                var assets = DiscordActivityAssets()
                url.absoluteString.toTuple(tuple: &assets.large_image, size: 128)
                (track.name ?? "").toTuple(tuple: &assets.large_text, size: 128)
                activity.assets = assets
                
            } catch {
                logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public): s3 upload error: \(error.localizedDescription)")
                debugPrint(error)
            }
            
        }
        
        return activity
    }
                    
    struct DigitalOceanCredentialsProvider: AWSClientRuntime.CredentialsProviding {
        func getCredentials() async throws -> Credentials {
            return AWSCredentials(accessKey: "DO00NXNA86QC7WDG6BT2", secret: "Eh4MEo/lqSOIXIsrPzrquhUA3bBarDna5GdYqNPMj20")
        }
    }

}

extension iTunesRadioStation {

    @objc func sourceSaved(_ notification: Notification) {
        os_log("%{public}s[%{public}ld], %{public}s: sourceSaved", ((#file as NSString).lastPathComponent), #line, #function)
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

            self.latestPlayInfo = playInfo

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

        guard latestPlayInfo != nil || !(iTunes?.currentTrack?.name ?? "").isEmpty else {
            os_log("%{public}s[%{public}ld], %{public}s: try to set rating but no current track info", ((#file as NSString).lastPathComponent), #line, #function)
            return
        }

        // save the record for later rating
        let targetTrack = iTunes?.currentTrack?.copy()

        // Note: latestPlayInfo could not set when App just launch without recieved playInfoChanged notification
        let name = latestPlayInfo?.name ?? iTunes?.currentTrack?.name ?? "nil"
        os_log("%{public}s[%{public}ld], %{public}s: set timer for 2.0s and set rating for %{public}s %{public}ld…", ((#file as NSString).lastPathComponent), #line, #function, name, rating)

        debounceSetRatingTimer = Timer(timeInterval: 2.0, repeats: false, block: { [weak self] timer in
            guard let `self` = self else { return }
            // here we use the saved record
            // so the delay will not rate the next track if song just finish (a.k.a rate in last 2s)
            let track = targetTrack ?? self.iTunes?.currentTrack
            track?.setRating?(rating)
            os_log("%{public}s[%{public}ld], %{public}s: … set %{public}s rating %{public}ld", ((#file as NSString).lastPathComponent), #line, #function, track?.name ?? "nil", rating)
        })
        debounceSetRatingTimer.flatMap {
            RunLoop.current.add($0, forMode: .default)
        }
    }

    func backward() {
        iTunes?.backTrack?()
    }

    func forward() {
        iTunes?.nextTrack?()
    }

    func playPause() {
        iTunes?.playpause?()
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

