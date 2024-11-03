# Use the official Swift image based on Ubuntu
FROM swift:6.0.2-jammy AS build

# Set the working directory in the container
WORKDIR /app

# Copy the entire Swift package into the container
COPY . .

# Build the Swift package
RUN swift build -c release

# Create a smaller final image for running the app
FROM swift:6.0.2-jammy AS runtime

# Install necessary runtime dependencies
RUN apt-get update && apt-get install -y \
    libcurl4 \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# Copy the built executable from the build stage
COPY --from=build /app/.build/release/foodbot-swift /usr/local/bin/foodbot-swift

# Set the entrypoint to run your Swift executable
ENTRYPOINT ["foodbot-swift"]
