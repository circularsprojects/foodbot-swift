//
// foodbot-swift
// Created by circular with <3 on 1/11/2024
// please excuse my spaghetti code
//

import DDBKit
import DDBKitUtilities
import Foundation

let foodCategories: [String] = [
    "biryani",
    "burger",
    "butter-chicken",
    "dessert",
    "dosa",
    "idly",
    "pasta",
    "pizza",
    "rice",
    "samosa"
]

extension foodbot {
    var Commands: Group {
        Group {
            Command("food") { i, cmd, dbreq in
                try? await bot.createInteractionResponse(to: i, type: .deferredChannelMessageWithSource())
                let request = HTTPClientRequest(url: "https://circulars.dev/foodish/api")
                let response = try await httpClient.execute(request, timeout: .seconds(30))
                
                let body = try await response.body.collect(upTo: 1024 * 1024)
                
                let food = try JSONDecoder().decode(food.self, from: body)
                let foodCategory = food.image.split(separator: "/")[4]
                try? await bot.updateOriginalInteractionResponse(of: i) {
                    Message {
                        MessageEmbed {
                            Title("Food Image")
                            Description {
                                Text("Category: `\(foodCategory)`")
                            }
                            Image(Embed.DynamicURL(from: food.image))
                        }
                        .setColor(.blue)
                    }
                }
            }
            .description("Get a picture of food")
            .integrationType(.all, contexts: .all)
            
            Command("category") { i, cmd, dbreq in
                try? await bot.createInteractionResponse(to: i, type: .deferredChannelMessageWithSource())
                
                let category = try cmd.requireOption(named: "category").requireString()
                let request = HTTPClientRequest(url: "https://circulars.dev/foodish/api/images/\(category)")
                let response = try await httpClient.execute(request, timeout: .seconds(30))
                
                let body = try await response.body.collect(upTo: 1024 * 1024)
                
                let food = try JSONDecoder().decode(food.self, from: body)
                let foodCategory = food.image.split(separator: "/")[4]
                try? await bot.updateOriginalInteractionResponse(of: i) {
                    Message {
                        MessageEmbed {
                            Title("Food Image")
                            Description {
                                Text("`Category: \(foodCategory)`")
                            }
                            Image(Embed.DynamicURL(from: food.image))
                        }
                        .setColor(.blue)
                    }
                }
            }
            .addingOptions {
                StringOption(name: "category", description: "Food Category")
                    .required()
                    .choices { foodCategories.map{.string($0)} }
            }
            .description("Get a certain category of food")
            .integrationType(.all, contexts: .all)
            
            Command("info") { i, cmd, dbreq in
                try? await bot.createInteractionResponse(to: i, type: .deferredChannelMessageWithSource())
                
                let cacheStorage = await cache.storage
                
                try? await bot.updateOriginalInteractionResponse(of: i) {
                    Message {
                        MessageEmbed {
                            Title("Food-Bot Info")
                            Description {
                                Text("Food-Bot [Swift Rewrite](https://github.com/circularsprojects/foodbot-swift) by [@circular](https://circulars.dev)")
                                Text("Built with [DDBKit](https://ddbkit.llsc12.me/)")
                                Heading("Stats")
                                    .small()
                                Text("Version: `v1.0 prerelease`")
                                Text("Bot Started: <t:\(Int(startTime.timeIntervalSince1970)):R>")
                                Text("Server Count: \(cacheStorage.guilds.count)")
                                Text("Host OS: \(ProcessInfo.processInfo.operatingSystemVersionString.replacingOccurrences(of: "Version", with: "MacOS"))")
                            }
                        }
                        .setColor(.green)
                    }
                }
            }
            .description("Get info about the bot")
            .integrationType(.all, contexts: .all)
        }
    }
}

struct food: Codable {
    var image: String
}
