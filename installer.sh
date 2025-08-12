#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Main Script ---

# 1. Check for acme.sh
if ! command_exists acme.sh; then
    echo "--> acme.sh not found. Installing..."
    curl https://get.acme.sh | sh
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install acme.sh. Please install it manually and try again."
        exit 1
    fi
    # Add acme.sh to the current shell session's PATH
    export PATH="$HOME/.acme.sh:$PATH"
    echo "--> acme.sh installed successfully."
fi

# 2. Prompt for domain name
read -p "Please enter your domain name (e.g., your.domain.com): " domain
if [ -z "$domain" ]; then
    echo "Error: Domain name cannot be empty."
    exit 1
fi

echo "--> Using domain: $domain"

# 3. Create the certificate directory
mkdir -p ./xray-certs
if [ $? -ne 0 ]; then
    echo "Error: Could not create the ./xray-certs directory."
    exit 1
fi

# 4. Issue the certificate using the standalone server
echo "--> Issuing certificate using acme.sh standalone server..."
echo "--> Note: This requires port 80 to be free. Stop any running webservers if necessary."

~/.acme.sh/acme.sh --issue -d "$domain" --standalone
if [ $? -ne 0 ]; then
    echo "Error: Certificate issuance failed. Please check that your domain is pointing to this server's IP and that port 80 is not in use."
    exit 1
fi

# 5. Install the certificate to the target directory
echo "--> Installing certificate to ./xray-certs/"
~/.acme.sh/acme.sh --install-cert -d "$domain" \
--fullchain-file ./xray-certs/xray.crt \
--key-file ./xray-certs/xray.key
if [ $? -ne 0 ]; then
    echo "Error: Certificate installation failed."
    exit 1
fi

echo "-------------------------------------------------"
echo "✅ SSL Certificate generated successfully!"
echo "Your certificate and key are now in the ./xray-certs directory."
echo ""
echo "You can now run './menu.sh' to start the services."
echo "-------------------------------------------------"
