#!/bin/bash

# =============================================================================
# SSL Certificate Generator - User Friendly Version
# This script helps you generate free SSL certificates using acme.sh and ZeroSSL
# =============================================================================

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✅${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }
print_header() { echo -e "${BOLD}${CYAN}$1${NC}"; }

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to validate domain format
validate_domain() {
    # Allow subdomains, main domains, and international domains
    if [[ $1 =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$ ]]; then
        # Additional checks
        if [[ ${#1} -le 253 ]] && [[ ! $1 =~ \.\. ]] && [[ ! $1 =~ ^- ]] && [[ ! $1 =~ -$ ]]; then
            return 0
        fi
    fi
    return 1
}

# Function to validate email format
validate_email() {
    if [[ $1 =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if port 80 is available
check_port_80() {
    if command_exists netstat; then
        if netstat -tlnp 2>/dev/null | grep -q ":80 "; then
            return 1
        fi
    elif command_exists ss; then
        if ss -tlnp 2>/dev/null | grep -q ":80 "; then
            return 1
        fi
    fi
    return 0
}

# Function to pause and wait for user confirmation
pause_for_confirmation() {
    echo
    read -p "Press Enter to continue or Ctrl+C to cancel..."
    echo
}

# =============================================================================
# MAIN SCRIPT
# =============================================================================

clear
print_header "🔐 SSL Certificate Generator"
echo
print_info "This script will help you generate a free SSL certificate for your domain."
print_info "The certificate will be issued by ZeroSSL using the acme.sh client."
echo

# 1. Check system requirements
print_header "📋 System Requirements Check"
print_info "Checking if required tools are available..."

missing_tools=""
for tool in curl openssl; do
    if ! command_exists "$tool"; then
        missing_tools="$missing_tools $tool"
    fi
done

if [ -n "$missing_tools" ]; then
    print_error "Missing required tools:$missing_tools"
    print_info "Please install these tools and run the script again."
    exit 1
fi

print_success "All required system tools are available."
echo

# 2. Check/Install acme.sh
print_header "🛠️  acme.sh Installation Check"
if ! command_exists acme.sh && [ ! -f "$HOME/.acme.sh/acme.sh" ]; then
    print_warning "acme.sh is not installed on your system."
    print_info "acme.sh is a free, automatic SSL certificate client that we'll use to get your certificate."
    echo
    read -p "Would you like to install acme.sh now? (y/n): " install_acme
    
    if [[ $install_acme =~ ^[Yy] ]]; then
        print_info "Installing acme.sh..."
        curl https://get.acme.sh | sh
        if [ $? -ne 0 ]; then
            print_error "Failed to install acme.sh. Please check your internet connection and try again."
            exit 1
        fi
        export PATH="$HOME/.acme.sh:$PATH"
        print_success "acme.sh installed successfully!"
    else
        print_error "acme.sh is required to continue. Exiting."
        exit 1
    fi
else
    print_success "acme.sh is already installed."
fi
echo

# 3. Get domain information
print_header "🌐 Domain Configuration"
print_info "We need your domain name to generate the SSL certificate."
print_warning "Important: Your domain must be pointing to this server's IP address!"
echo

while true; do
    read -p "Enter your domain name (e.g., example.com): " domain
    
    if [ -z "$domain" ]; then
        print_error "Domain name cannot be empty. Please try again."
        continue
    fi
    
    # Remove any protocol prefixes
    domain=$(echo "$domain" | sed 's|^https\?://||' | sed 's|/.*||')
    
    if validate_domain "$domain"; then
        break
    else
        print_error "Invalid domain format. Please enter a valid domain (e.g., example.com)"
    fi
done

print_success "Domain set to: $domain"
echo

# 4. Get email information
print_header "📧 Contact Information"
print_info "ZeroSSL requires an email address for certificate registration."
print_info "This email will be used for important notifications about your certificate."
echo

while true; do
    read -p "Enter your email address: " email
    
    if [ -z "$email" ]; then
        print_error "Email address cannot be empty. Please try again."
        continue
    fi
    
    if validate_email "$email"; then
        break
    else
        print_error "Invalid email format. Please enter a valid email address."
    fi
done

print_success "Email set to: $email"
echo

# 5. Pre-flight checks
print_header "🔍 Pre-flight Checks"

# Check if port 80 is available
if ! check_port_80; then
    print_warning "Port 80 appears to be in use by another service."
    print_info "The certificate validation process needs port 80 to be free."
    print_info "You may need to stop your web server temporarily."
    echo
    read -p "Do you want to continue anyway? (y/n): " continue_anyway
    if [[ ! $continue_anyway =~ ^[Yy] ]]; then
        print_info "Please free up port 80 and run the script again."
        exit 1
    fi
fi

# Check if domain resolves to this server
print_info "Checking if $domain points to this server..."
server_ip=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null)
if [ -n "$server_ip" ]; then
    domain_ip=$(dig +short "$domain" 2>/dev/null | tail -n1)
    if [ "$server_ip" = "$domain_ip" ]; then
        print_success "Domain correctly points to this server ($server_ip)"
    else
        print_warning "Domain might not be pointing to this server."
        print_info "Server IP: ${server_ip:-"Unable to detect"}"
        print_info "Domain IP: ${domain_ip:-"Unable to resolve"}"
        echo
        read -p "Do you want to continue anyway? (y/n): " continue_domain
        if [[ ! $continue_domain =~ ^[Yy] ]]; then
            print_info "Please update your domain's DNS settings and try again."
            exit 1
        fi
    fi
fi
echo

# 6. Summary and confirmation
print_header "📋 Configuration Summary"
echo "Domain: $domain"
echo "Email:  $email"
echo "Certificate will be saved to: ./xray-certs/"
echo
print_warning "The certificate generation process will:"
print_info "• Clean up any existing certificates for this domain"
print_info "• Register your email with ZeroSSL"
print_info "• Use port 80 temporarily for domain validation"
print_info "• Generate and install the SSL certificate"

pause_for_confirmation

# 7. Start certificate generation
print_header "🚀 Starting Certificate Generation"

# Clean up previous certificates
print_info "Cleaning up any existing certificates..."
~/.acme.sh/acme.sh --remove -d "$domain" --ecc >/dev/null 2>&1 || true

# Register account
print_info "Registering account with ZeroSSL..."
~/.acme.sh/acme.sh --register-account -m "$email" --server zerossl
if [ $? -ne 0 ]; then
    print_error "Failed to register account with ZeroSSL."
    exit 1
fi

# Create certificate directory if it doesn't exist
print_info "Checking certificate directory..."
if [ ! -d "./xray-certs" ]; then
    print_info "Creating ./xray-certs directory..."
    mkdir -p ./xray-certs
    if [ $? -ne 0 ]; then
        print_error "Could not create the ./xray-certs directory."
        exit 1
    fi
    print_success "Certificate directory created successfully."
else
    print_success "Certificate directory already exists."
fi

# Issue the certificate
print_info "Issuing SSL certificate..."
print_warning "This may take a few minutes. Please be patient..."
~/.acme.sh/acme.sh --issue --ecc -d "$domain" --standalone
if [ $? -ne 0 ]; then
    print_error "Certificate issuance failed!"
    print_info "Common causes:"
    print_info "• Domain is not pointing to this server"
    print_info "• Port 80 is blocked by firewall"
    print_info "• Another service is using port 80"
    exit 1
fi

# Install the certificate
print_info "Installing certificate to ./xray-certs/..."
~/.acme.sh/acme.sh --install-cert --ecc -d "$domain" \
--fullchain-file ./xray-certs/xray.crt \
--key-file ./xray-certs/xray.key
if [ $? -ne 0 ]; then
    print_error "Certificate installation failed."
    exit 1
fi

# Set proper permissions
chmod 600 ./xray-certs/xray.key
chmod 644 ./xray-certs/xray.crt

# Success message
echo
print_header "🎉 Certificate Generated Successfully!"
echo
print_success "Your SSL certificate has been generated and installed!"
echo
print_info "Certificate details:"
echo "  • Domain: $domain"
echo "  • Certificate file: ./xray-certs/xray.crt"
echo "  • Private key file: ./xray-certs/xray.key"
echo "  • Issuer: ZeroSSL"
echo "  • Auto-renewal: Enabled (via acme.sh)"
echo
print_info "Next steps:"
print_info "• Your certificate will automatically renew before expiration"
print_info "• You can now run './menu.sh' to start your services"
print_info "• Keep the ./xray-certs directory secure and backed up"
echo
print_success "Setup complete! 🔐"