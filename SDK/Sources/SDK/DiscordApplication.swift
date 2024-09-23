//
//  DiscordApplication.swift
//  
//
//  Created by MainasuK on 2022/11/18.
//

import Foundation
import DiscordGameSDK

//public class DiscordApplication {
//    public var core: UnsafeMutablePointer<IDiscordCore>? = .allocate(capacity: 0)
//    public var users: UnsafeMutablePointer<IDiscordUserManager>? = .allocate(capacity: 0)
//    public var achievements: UnsafeMutablePointer<IDiscordAchievementManager>? = .allocate(capacity: 0)
//    public var activities: UnsafeMutablePointer<IDiscordActivityManager>? = .allocate(capacity: 0)
//    public var relationships: UnsafeMutablePointer<IDiscordRelationshipManager>? = .allocate(capacity: 0)
//    public var application: UnsafeMutablePointer<IDiscordApplicationManager>? = .allocate(capacity: 0)
//    public var lobbies: UnsafeMutablePointer<IDiscordLobbyManager>? = .allocate(capacity: 0)
////    public var user_id: DiscordUserId = 0
//
//    public init() { }
//
//    public func initialize() {
//        users = core?.pointee.get_user_manager(core)
//        achievements = core?.pointee.get_achievement_manager(core)
//        activities = core?.pointee.get_activity_manager(core)
//        relationships = core?.pointee.get_relationship_manager(core)
//        application = core?.pointee.get_application_manager(core)
//        lobbies = core?.pointee.get_lobby_manager(core)
//
//        var currentUserUpdate: (@convention(c) UnsafeMutableRawPointer? -> Void) = { _ in
//
//        }
//        var userEvents = IDiscordUserEvents()
//        userEvents.on_current_user_update = currentUserUpdate
////        var user = DiscordUser()
////        users?.pointee.get_current_user(users, &user)
////        user_id = user.id
//    }
//}
//
//extension DiscordApplication {
//    public var activityManager: UnsafeMutablePointer<IDiscordActivityManager>? {
//        core?.pointee.get_activity_manager(core)
//    }
//}
