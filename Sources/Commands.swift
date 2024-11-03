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

func timeSinceStart(from startTime: Date) -> String {
    let now = Date()
    let elapsed = now.timeIntervalSince(startTime)
    
    let days = Int(elapsed) / 86400
    let hours = (Int(elapsed) % 86400) / 3600
    let minutes = (Int(elapsed) % 3600) / 60
    
    var components: [String] = []
    if days > 0 {
        components.append("\(days) day" + (days > 1 ? "s" : ""))
    }
    if hours > 0 {
        components.append("\(hours) hour" + (hours > 1 ? "s" : ""))
    }
    if minutes > 0 {
        components.append("\(minutes) minute" + (minutes > 1 ? "s" : ""))
    }
    
    return components.isEmpty ? "0 minutes" : components.joined(separator: ", ")
}

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
                            Title("food image")
                            Description {
                                Text("category: \(foodCategory)")
                            }
                            Image(Embed.DynamicURL(from: food.image))
                        }
                        .setColor(.blue)
                    }
                }
            }
            .description("get a picture of food")
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
                            Title("food image")
                            Description {
                                Text("category: \(foodCategory)")
                            }
                            Image(Embed.DynamicURL(from: food.image))
                        }
                        .setColor(.blue)
                    }
                }
            }
            .addingOptions {
                StringOption(name: "category", description: "food category")
                    .required()
                    .choices { foodCategories.map{.string($0)} }
            }
            .description("get a certain category of food")
            .integrationType(.all, contexts: .all)
            
            Command("info") { i, cmd, dbreq in
                try? await bot.createInteractionResponse(to: i, type: .deferredChannelMessageWithSource())
                
                try? await bot.updateOriginalInteractionResponse(of: i) {
                    Message {
                        MessageEmbed {
                            Title("food-bot info")
                            Description {
                                Text("food-bot swift rewrite by @circular")
                                Link("https://circulars.dev")
                                Text("built with DDBKit")
                                Heading("Stats")
                                    .small()
                                Text("version v0.1")
                                Text("uptime: \(timeSinceStart(from: startTime))")
                                Text("OS: \(ProcessInfo.processInfo.operatingSystemVersionString)")
                            }
                        }
                        .setColor(.green)
                    }
                }
            }
            .description("get info about the bot")
            .integrationType(.all, contexts: .all)
        }
    }
}

struct food: Codable {
    var image: String
}
