# Use a standard Debian base image
FROM debian:bullseye-slim

# Install prerequisites
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add the Cloudflare repository
RUN curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list

# Install the WARP client
RUN apt-get update && apt-get install -y cloudflare-warp && rm -rf /var/lib/apt/lists/*

# Create a directory for the WARP configuration
RUN mkdir -p /var/lib/cloudflare-warp

# Copy the entrypoint script
COPY entrypoint-warp.sh /entrypoint-warp.sh
RUN chmod +x /entrypoint-warp.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint-warp.sh"]
