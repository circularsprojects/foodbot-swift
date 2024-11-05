//
// foodbot-swift
// Created by circular with <3 on 5/11/2024
// please excuse my spaghetti code
//

import DDBKit
import FlyingFox
import Foundation

let webServer = HTTPServer(port: getPort() ?? 3100)

func getPort() -> UInt16? {
    let env = ProcessInfo.processInfo.environment
    let port = env["ANALYTICS_PORT"]
    if let port {
        return UInt16(port)
    }
    return nil
}

extension foodbot {
    func startWebServer() async {
        do {
            await webServer.appendRoute("/servers") { request in
                let cacheStorage = await cache.storage
                return HTTPResponse(
                    statusCode: .ok,
                    headers: [.contentType: "application/json"],
                    body: "{\"servers\":\(cacheStorage.guilds.count)}".data(using: .utf8)!
                )
            }
            print("Starting analytics server on http://127.0.0.1:\(getPort() ?? 3100)")
            try await webServer.run()
        } catch {
            fatalError("Analytics server failed to initialize. \(error)")
        }
    }
    
    func stopWebServer() async {
        await webServer.stop(timeout: 3)
    }
}
