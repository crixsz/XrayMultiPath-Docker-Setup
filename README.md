# XrayMultiPath with Docker

This repository provides a Docker-based setup for a powerful and flexible proxy server using Xray-core, Nginx, and Cloudflare WARP. The primary feature is a "multi-path" configuration that allows routing traffic through either a direct connection or via Cloudflare WARP for enhanced privacy.

## Key Features

- **Containerized:** All services run in isolated Docker containers, managed by Docker Compose.
- **Easy Management:** Includes a simple menu script to install, uninstall, and manage the services.
- **Dual Routing:** Simultaneously supports direct connections and connections routed through Cloudflare WARP.
- **Multiple Protocols:** Comes pre-configured with VLESS and Trojan protocols over WebSocket.
- **Persistent SSL:** SSL certificates are stored in a Docker volume to persist across container restarts.

## How It Works

This setup consists of two main services orchestrated by `docker-compose`:

1.  **`xray-nginx`:** A custom-built Docker container that runs both Nginx and the multiple Xray services. Nginx acts as a reverse proxy on ports 80 and 443, directing traffic to the correct Xray instance based on the requested WebSocket path.
2.  **`warp`:** A container running the Cloudflare WARP service, which provides a SOCKS5 proxy. The main Xray configuration is set up to route traffic through this container.

The two containers communicate over a dedicated Docker network, ensuring they can securely connect to each other.

## Prerequisites

- **Docker:** You must have Docker installed on your system. [Install Docker](https://docs.docker.com/engine/install/)
- **Docker Compose:** You must have Docker Compose installed. [Install Docker Compose](https://docs.docker.com/compose/install/)
- **Domain Name:** You need a domain name pointing to your server's IP address for SSL to work correctly.
- **Git:** You need git to clone the repository.

## How to Run

### 1. Clone the Repository
```bash
git clone https://github.com/crixsz/XrayMultiPath-Docker-Setup.git
cd XrayMultiPath-Docker-Setup
```

### 2. Obtain SSL Certificates
Before starting the services, you need to place your SSL certificate and key files in a directory named `xray-certs`. The container will mount this directory to `/root`, where the Xray configuration expects to find them.

Create the directory:
```bash
mkdir xray-certs
```

Place your full chain certificate as `xray.crt` and your private key as `xray.key` inside the `xray-certs` directory.

**Example using `acme.sh`:**
If you use `acme.sh`, you can issue a certificate and copy it to the correct location like this:
```bash
# Install acme.sh
# curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --issue -d your.domain.com --standalone
~/.acme.sh/acme.sh --install-cert -d your.domain.com \
--fullchain-file ./xray-certs/xray.crt \
--key-file ./xray-certs/xray.key
```

### 3. Use the Management Script
With your certificates in place, you can use the `menu.sh` script to manage the application.

First, make the script executable:
```bash
chmod +x menu.sh
```

Then, run the script:
```bash
./menu.sh
```

The script provides the following options:
- **Install and Start Services:** Builds and starts the Docker containers.
- **Stop and Remove Services:** Stops and removes all containers, networks, and volumes created by this setup.
- **View Service Logs:** Tails the logs from the running containers.

## Client Configurations

Your server is now running. Replace `your.domain.com` with your actual domain name in the configurations below.

### Cloudflare Warp Route (Port 80 & 443)

**VLESS-WS (Port 80)**
```
vless://5d871382-b2ec-4d82-b5b8-712498a348e5@your.domain.com:80?security=&type=ws&path=/vless-ws&host=your.domain.com&encryption=none
```

**VLESS-WS (Port 443 - TLS)**
```
vless://5d871382-b2ec-4d82-b5b8-712498a348e5@your.domain.com:443?security=tls&sni=your.domain.com&allowInsecure=1&type=ws&path=/vless-ws&encryption=none
```

**TROJAN-WS (Port 80)**
```
trojan://trojanaku@your.domain.com:80?security=&type=ws&path=/trojan-ws&host=your.domain.com#
```

**TROJAN-WS (Port 443 - TLS)**
```
trojan://trojanaku@your.domain.com:443?security=&type=ws&path=/trojan-ws&host=your.domain.com#
```

### Direct Route (Port 80)

**TROJAN-WS (Direct)**
```
trojan://trojanaku@your.domain.com:80?security=&type=ws&path=/direct-trojan&host=your.domain.com#
```

**VLESS-WS (Direct)**
```
vless://5d871382-b2ec-4d82-b5b8-712498a348e5@your.domain.com:80?security=&type=ws&path=/direct-vless&host=your.domain.com&encryption=none
```

