#!/bin/bash

# Function to display the menu
show_menu() {
    clear
    echo "====================================="
    echo "  XrayMultiPath Docker Management  "
    echo "====================================="
    echo "1) Install and Start Services"
    echo "2) Stop and Remove Services"
    echo "3) View Service Logs"
    echo "4) Exit"
    echo "-------------------------------------"
    read -p "Please select an option [1-4]: " option
}

# Function to install and start the services
install_services() {
    echo "--> Building and starting containers..."
    if ! docker compose up --build -d; then
        echo "Error: Failed to start services. Please check your Docker and Docker Compose installation."
        read -p "Press Enter to continue..."
        return
    fi
    echo "--> Services started successfully in the background."
    read -p "Press Enter to continue..."
}

# Function to stop and remove the services
uninstall_services() {
    read -p "Do you want to remove the images as well? [y/N]: " remove_images
    if [[ "$remove_images" == "y" || "$remove_images" == "Y" ]]; then
        echo "--> Stopping and removing containers, networks, volumes, and images..."
        if ! docker compose down --rmi all -v; then
            echo "Error: Failed to stop services. Please check your Docker and Docker Compose installation."
            read -p "Press Enter to continue..."
            return
        fi
    else
        echo "--> Stopping and removing containers, networks, and volumes..."
        if ! docker compose down -v; then
            echo "Error: Failed to stop services. Please check your Docker and Docker Compose installation."
            read -p "Press Enter to continue..."
            return
        fi
    fi
    echo "--> All services and associated data have been removed."
    read -p "Press Enter to continue..."
}

# Function to view the logs
view_logs() {
    echo "--> Fetching logs... (Press Ctrl+C to exit)"
    docker compose logs -f
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    case $option in
        1)
            install_services
            ;;
        2)
            uninstall_services
            ;;
        3)
            view_logs
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please select a valid option."
            read -p "Press Enter to continue..."
            ;;
    esac
done
