# Use the official Swift image based on Ubuntu
FROM swift:6.0.2-jammy AS build

# Set the working directory in the container
WORKDIR /app

# Copy the entire Swift package into the container
COPY . .

# Build the Swift package
RUN swift build -c release

FROM swift:6.0.2-jammy-slim AS runtime

# Copy the built executable
COPY --from=build /app/.build/release/foodbot-swift /usr/local/bin/foodbot-swift

ENTRYPOINT ["foodbot-swift"]
