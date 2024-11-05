# foodbot (swift rewrite)
Made using [DDBKit](https://ddbkit.llsc12.me/), works on both macOS and Linux.
> [!IMPORTANT]
> DDBKit is currently still in-development, which means you won't be able to build this yourself, unless you're a tester.\
> Follow the org for updates: https://github.com/DDBKit

## Running your own instance
Replace the bot token environment variable in `docker-compose.yml`, run `docker compose build`, and then run `docker compose up -d` to start the bot.

Alternatively, you can install swift manually and compile the bot with `swift build` and `swift run`.

## Analytics
You can enable an "analytics server" by setting the environment variable `ANALYTICS_ENABLED` to true.

By default, this server runs on port 3100, but can be changed by setting `ANALYTICS_PORT`.

Current API endpoints:
- `/servers`: Returns a JSON object with the amount of servers the bot is in. (`{"servers":1337}`)
