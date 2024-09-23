//
//  AppContext.swift
//  
//
//  Created by MainasuK on 2022/11/18.
//

import os.log
import Foundation
import DiscordGameSDK
import CDiscordGameSDK
import ArkanaKeys

public class AppContext {
    
    let logger = Logger(subsystem: "AppContext", category: "Context")
    
    public var discord = Application()
    
    public var assetURLCache = Set<URL>()

    public init() {
        setupDiscord()
    }
}

extension AppContext {
    private func setupDiscord() {
        logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public): discord init...")
        
        var usersEvents = IDiscordUserEvents()
        usersEvents.on_current_user_update = OnUserUpdated
        
        var activityEvents = IDiscordActivityEvents()
        
        var relationshipEvents = IDiscordRelationshipEvents()
        relationshipEvents.on_refresh = OnRelationshipsRefresh
        
        var params = DiscordCreateParams()
        params.client_id = DiscordClientId(Keys.Release().discordApplicationID)
        params.flags = UInt64(DiscordCreateFlags_Default.rawValue)
        params.event_data = withUnsafeMutablePointer(to: &discord) { UnsafeMutableRawPointer($0) }
        params.activity_events = withUnsafeMutablePointer(to: &activityEvents) { UnsafeMutablePointer<IDiscordActivityEvents>($0) }
        params.relationship_events = withUnsafeMutablePointer(to: &relationshipEvents) { UnsafeMutablePointer<IDiscordRelationshipEvents>($0) }
        params.user_events = withUnsafeMutablePointer(to: &usersEvents) { UnsafeMutablePointer<IDiscordUserEvents>($0) }
        
        let createResult = DiscordCreate(DISCORD_VERSION, &params, &discord.core)
        guard createResult == DiscordResult_Ok else {
            assertionFailure()
            logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public): discord init failure: code \(createResult.rawValue)")
            return
        }
        
        discord.users = discord.core.pointee.get_user_manager(discord.core)
        discord.achievements = discord.core.pointee.get_achievement_manager(discord.core)
        discord.activities = discord.core.pointee.get_activity_manager(discord.core)
        discord.application = discord.core.pointee.get_application_manager(discord.core)
        discord.lobbies = discord.core.pointee.get_lobby_manager(discord.core)
        
        logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public): discord init success")
        
        // start eventLoop
        Task(priority: .background) {
            while true {
                let result = discord.core?.pointee.run_callbacks(discord.core)
                if result != DiscordResult_Ok {
                    logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public): EventLoop run callback failure: \(result?.rawValue ?? 0)")
                }
                try await Task.sleep(nanoseconds: .second / 10)
            }
        }   // end Task
    }
}
