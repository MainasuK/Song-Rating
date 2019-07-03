//
//  PlayInfo.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-6-28.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Foundation

struct PlayInfo: Codable {
    // MARK: - basic meta
    let name: String?
    let artist: String?
    let album: String?
    let albumArtist: String?
    let composer: String?
    let grouping: String?
    let compilation: Int?
    let genre: String?

    let year: Int?
    let trackNumber: Int?
    let trackCount: Int?
    let discNumber: Int?
    let discCount: Int?
    // ?
    var rating: Int?            // be careful it's maybe computed rating
    let likeStatus: String?     // always "None"
    let playCount: Int?

    let albumRating: Int?
    let ratingComputed: Int?
    let albumRatingComputed: Int?
    

    // MARK: - additional meta
    let artworkCount: Int?
    
    // MARK: - player state
    let elapsedStr: String?
    let totalTime: Int?
    let playerState: PlayerState?

    // MARK: - sort info
    let displayLine0: String?
    let displayLine1: String?

    // MARK: - URI
    let persistentID: Int?
    let playlistPersistentID: Int?
    let libraryPersistentID: Int?
    let storeURL: String?
    let location: String?
    
    // MARK: - player history
    let playDate: Date?
    let skipCount: Int?
    let skipDate: Date?

    // MARK: - others
    let backButtonState: String?
}

extension PlayInfo {
    
    var notComputedRating: Int? {
        guard rating != nil else { return nil }
        return ratingComputed != 1 ? rating : 0
    }
    
}

extension PlayInfo {
    
    enum PlayerState: String, Codable {
        case paused = "Paused"
        case playing = "Playing"
        
        case unknown
        
        init(from decoder: Decoder) throws {
            self = try PlayerState(rawValue: decoder.singleValueContainer().decode(String.self)) ?? .unknown
        }
    }
    
}

extension PlayInfo: CustomStringConvertible {
    
    var description: String {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let jsonData = try encoder.encode(self)
            let jsonString = String(data: jsonData, encoding: .utf8).flatMap { String(describing: PlayInfo.self) + ": " + $0 }
            return jsonString ?? shortDescription
        } catch {
            return shortDescription
        }
    }
    
    var shortDescription: String {
        let playerState = self.playerState.flatMap { $0 != .unknown ? "\($0.rawValue): " : nil  } ?? ""
        return playerState + [
            ([trackNumber.flatMap { "[\(String($0))]" }, name].compactMap { $0 }.joined(separator: " ")),
            artist,
            [album, year.flatMap { "(\(String($0)))" }].compactMap { $0 }.joined(separator: " "),
            "\(notComputedRating ?? -1)"
        ].compactMap { $0 }.joined(separator: " | ")
    }
    
}

