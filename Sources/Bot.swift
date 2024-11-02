//
// foodbot-swift
// Created by circular with <3 on 1/11/2024
// please excuse my spaghetti code
//

import DDBKit
import DDBKitUtilities
import Foundation

@main

struct foodbot: DiscordBotApp {
    var bot: Bot
    var cache: Cache
    let httpClient = HTTPClient()
    var startTime: Date
    
    init() async {
        var env = ProcessInfo.processInfo.environment
        var token = env["discord-token"]
        guard let token = token else { fatalError("No token provided. Set `discord-token` in your environment.") }
        
        bot = await BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            token: token,
            largeThreshold: 250,
            presence: .init(activities: [], status: .online, afk: false),
            intents: [.guildMessages]
        )
        cache = await .init(
            gatewayManager: bot,
            intents: .all,
            requestAllMembers: .enabledWithPresences,
            messageCachingPolicy: .saveEditHistoryAndDeleted
        )
        startTime = .now
    }
    
    func boot() async throws {
        AssignGlobalCatch { bot, error, i in
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
    }
    
    var body: [any BotScene] {
        Commands
        
        ReadyEvent { ready in
            print("foodbot online")
        }
    }
}
