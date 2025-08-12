
# XrayMultiPath with Docker

This repository provides a Docker-based setup for a powerful and flexible proxy server using Xray-core, Nginx, and Cloudflare WARP. The primary feature is a "multi-path" configuration that allows routing traffic through either a direct connection or via Cloudflare WARP for enhanced privacy.

## Key Features

- **Containerized:** All services run in isolated Docker containers, managed by Docker Compose.
- **Automated SSL:** Includes an installer script to automatically generate SSL certificates using `acme.sh`.
- **Easy Management:** A simple menu script handles starting, stopping, and managing the services.
- **Dual Routing:** Simultaneously supports direct connections and connections routed through Cloudflare WARP.
- **Multiple Protocols:** Comes pre-configured with VLESS and Trojan protocols over WebSocket.

## Prerequisites

- **Docker & Docker Compose V2:** You must have both installed on your system.
- **Domain Name:** You need a domain name pointing to your server's IP address.
- **Git:** Required to clone the repository.
- **Curl:** Required by the installer to download `acme.sh`.

## How to Run

### Step 1: Clone the Repository
```bash
git clone https://github.com/crixsz/XrayMultiPath-Docker-Setup.git
cd XrayMultiPath-Docker-Setup
```

### Step 2: Run the Installer for SSL Certificates
The installer script will handle the generation of your SSL certificates.

First, make the script executable:
```bash
chmod +x installer.sh
```

Then, run the installer and follow the prompts:
```bash
./installer.sh
```
The script will ask for your domain name and automatically generate the necessary `xray.crt` and `xray.key` files, placing them in the `./xray-certs` directory.

### Step 3: Use the Management Script
Once the certificates are generated, you can use the `menu.sh` script to manage the application.

Make the menu script executable:
```bash
chmod +x menu.sh
```

Then, run the script:
```bash
./menu.sh
```

### Step 4: Register the WARP Client
Before starting the services, you need to register the WARP client. Select option 4 from the menu to do this. This only needs to be done once.

### Step 5: Start the Services
Select option 1 from the menu to build and start the Docker containers.

The menu provides the following options:
- **Install and Start Services:** Builds and starts the Docker containers.
- **Stop and Remove Services:** Stops and removes all containers, networks, and volumes.
- **View Service Logs:** Tails the logs from the running containers.
- **Register WARP Client:** Registers the WARP client.

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
