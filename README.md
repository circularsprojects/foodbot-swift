# foodbot (swift rewrite)
Made using [DDBKit](https://ddbkit.llsc12.me/), works on both macOS and Linux.
> [!IMPORTANT]
> DDBKit is currently still in-development, which means you won't be able to build this yourself, unless you're a tester.\
> Follow the org for updates: https://github.com/DDBKit

## Running your own instance
Replace the bot token environment variable in `docker-compose.yml`, run `docker compose build`, and then run `docker compose up -d` to start the bot.

Alternatively, you can install swift manually and compile the bot with `swift build` and `swift run`.

## Analytics
(the bot used to have an analytics webserver, but this has been removed)

The bot has in-built support for analytics using InfluxDB.\
You can configure the env variables for InfluxDB in the docker compose file, or however you would normally manage environment variables.\
If you set `ANALYTICS_ENABLED` to true, you *must* also provide a value for each of the `INFLUXDB` environment variables, or it will not work.

The analytics module is meant to be as modular as possible. It's loaded as a DDBKit extension, and should be able to be dropped into any other DDBKit project with minimal modification.
