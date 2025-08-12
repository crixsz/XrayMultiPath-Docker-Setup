# Use a standard Debian base image
FROM debian:bullseye-slim

# Install prerequisites
RUN apt-get update && apt-get install -y \
    curl \
    socat \
    nginx \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Xray-core manually
RUN apt-get update && apt-get install -y unzip &&     curl -L https://github.com/XTLS/Xray-core/releases/download/v1.5.0/Xray-linux-64.zip -o /tmp/xray.zip &&     unzip /tmp/xray.zip -d /tmp/xray &&     mv /tmp/xray/xray /usr/local/bin/xray &&     rm -rf /tmp/xray.zip /tmp/xray &&     apt-get remove -y unzip &&     apt-get autoremove -y &&     rm -rf /var/lib/apt/lists/*

# Create log directory for Xray
RUN mkdir -p /var/log/xray && \
    chown -R nobody:nogroup /var/log/xray

# Copy Nginx and Xray configuration files into the container

COPY Nginx/nginx.conf /etc/nginx/nginx.conf
COPY Nginx/xray.conf /etc/nginx/conf.d/xray.conf
COPY Xray/config.json /usr/local/etc/xray/config.json
COPY Xray/direct.json /usr/local/etc/xray/direct.json
COPY Xray/none.json /usr/local/etc/xray/none.json
# Expose ports for HTTP and HTTPS
EXPOSE 80 443

# Add an entrypoint script to start services
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

