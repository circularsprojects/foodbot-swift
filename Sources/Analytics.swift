//
// foodbot-swift
// Created by circular with <3 on 5/11/2024
// please excuse my spaghetti code
//

@_spi(Extensions) import DDBKit
import Foundation
import AsyncHTTPClient
import NIOCore

func setInterval(
    seconds: TimeInterval,
    action: @escaping @Sendable () async -> Void
) -> Task<Void, Never> {
    Task {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            await action()
        }
    }
}

let env = ProcessInfo.processInfo.environment
let influxURL = env["INFLUX_URL"]
let influxToken = env["INFLUX_TOKEN"]
let influxBucket = env["INFLUX_BUCKET"]
let influxOrg = env["INFLUX_ORG"]
let influxLocation = env["INFLUX_LOCATION"]

actor CommandBuffer {
    var commandBuffer: [String] = []
    
    func append(_ string: String) {
        commandBuffer.append(string)
    }
    
    func flush() {
        commandBuffer = []
    }
    
    func get() -> [String] {
        return commandBuffer
    }
}

actor InfluxDBExtension: DDBKitExtension {
    let logger = DiscordGlobalConfiguration.makeLogger("InfluxDBExtension")
    
    func onBoot(_ instance: inout BotInstance) async throws {
        guard let influxURL = influxURL,
              let influxToken = influxToken,
              let influxBucket = influxBucket,
              let influxOrg = influxOrg
        else {
            logger.error("Not all required InfluxDB environment variables are set. Analytics will be disabled.")
            return
        }
        
        let commandBuffer = CommandBuffer()
        let location = influxLocation ?? ProcessInfo.processInfo.hostName
        
        instance.commands = instance.commands.map {
            $0
                .postAction { cmd, _ in
                    await commandBuffer.append("command,location=\(location),command=\(cmd.baseInfo.name) count=1i \(Int(Date().timeIntervalSince1970 * 1000))")
                }
        }
        let _ = setInterval(seconds: 3600) { [cache = instance.cache] in
            let cacheStorage = await cache.storage
            var data = "servers,location=\(location) count=\(cacheStorage.guilds.count)i \(Int(Date().timeIntervalSince1970 * 1000))"
            let commands = await commandBuffer.get()
            for command in commands {
                data += "\n" + command
            }
            await commandBuffer.flush()
            
            do {
                var request = HTTPClientRequest(url: "\(influxURL)/api/v2/write?org=\(influxOrg)&bucket=\(influxBucket)&precision=ms")
                request.method = .POST
                request.headers.add(name: "Authorization", value: "Token \(influxToken)")
                request.headers.add(name: "Content-Type", value: "text/plain; charset=utf-8")
                request.headers.add(name: "Content-Encoding", value: "gzip")
                request.headers.add(name: "Accept", value: "application/json")
                
                var byteData = ByteBuffer(string: data)
                request.body = .bytes(try byteData.compress(with: .gzip))
                
                let response = try await HTTPClient.shared.execute(request, timeout: .seconds(30))
                if response.status != .noContent {
                    self.logger.error("Server response was not ok while sending analytics data: \(response.status)")
                    let body = try await response.body.collect(upTo: 1024 * 1024)
                    if let bodyString = body.getString(at: body.readerIndex, length: body.readableBytes) {
                        self.logger.info("\(bodyString)")
                    }
                    self.logger.info("Data sent: \(data)")
                }
            } catch {
                self.logger.error("Unexpected error occurred while sending analytics data: \(error)")
            }
        }
        logger.info("Analytics enabled.")
    }
}
