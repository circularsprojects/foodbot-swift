//
// foodbot-swift
// Created by circular with <3 on 1/11/2024
// please excuse my spaghetti code
//

import DDBKit
import DDBKitUtilities
import Foundation
import Logging

@main

struct foodbot: DiscordBotApp {
    var bot: Bot
    var cache: Cache
    let httpClient = HTTPClient()
    var startTime: Date
    let env = ProcessInfo.processInfo.environment
    var logger: Logger
    
    init() async {
        let token = env["DISCORD_TOKEN"]
        guard let token = token else { fatalError("No token provided. Set `DISCORD_TOKEN` in your environment.") }
        
        bot = await BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            token: token,
            largeThreshold: 250,
            presence: .init(activities: [.init(name: "meow", type: .custom, state: "food-bot swift rewrite :3")], status: .online, afk: false),
            intents: [.guilds]
        )
        cache = await .init(
            gatewayManager: bot,
            intents: [.guilds],
            requestAllMembers: .disabled,
            messageCachingPolicy: .normal
        )
        
        let logger = DiscordGlobalConfiguration.makeLogger("foodbot")
        self.logger = logger
        startTime = .now
    }
    
    func boot() async throws {
        AssignGlobalCatch { bot, error, i in
            logger.error("\(error)")
            try? await bot.updateOriginalInteractionResponse(of: i) {
                Message {
                    MessageEmbed {
                        Title("⛔️ Encountered a fatal error!")
                        Description {
                            Text(error.localizedDescription)
                            Codeblock("\(error)", lang: "swift")
                        }
                        Footer("Contact @circular or send an email to circular@circulars.dev")
                    }
                    .setColor(.red)
                }
            }
        }
        let analyticsEnabled = env["ANALYTICS_ENABLED"]
        if let analyticsEnabled {
            if analyticsEnabled.lowercased() == "true" {
                let _ = Task { await startWebServer() }
            }
        }
    }
    
    var body: [any BotScene] {
        Commands
        
        ReadyEvent { ready in
            logger.info("Foodbot online!")
        }
    }
}
