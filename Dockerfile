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

# Install Xray-core
RUN bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version 1.5.0 -u root

# Copy Nginx and Xray configuration files into the container
COPY Nginx/nginx.conf /etc/nginx/nginx.conf
COPY Nginx/xray.conf /etc/nginx/conf.d/xray.conf
COPY Xray/config.json /usr/local/etc/xray/config.json
COPY Xray/direct.json /usr/local/etc/xray/direct.json
COPY Xray/none.json /usr/local/etc/xray/none.json
COPY Xray/xray@.service /etc/systemd/system/xray@.service

# Expose ports for HTTP and HTTPS
EXPOSE 80 443

# Add an entrypoint script to start services
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

