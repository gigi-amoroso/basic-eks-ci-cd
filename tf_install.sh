#!/bin/bash

# Function to print messages in a formatted way
print_message() {
    echo "================================================================="
    echo "$1"
    echo "================================================================="
}

# Function to check if a command exists; if not, install the corresponding package
ensure_command() {
    if ! command -v "$1" &> /dev/null; then
        print_message "'$1' is not installed. Installing..."
        if [ -n "$CLOUDSHELL" ]; then
            sudo yum install -y "$2"
        else
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y "$2"
            elif command -v yum &> /dev/null; then
                sudo yum install -y "$2"
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y "$2"
            elif command -v pacman &> /dev/null; then
                sudo pacman -Sy "$2"
            else
                print_message "Package manager not detected. Please install '$2' manually."
                exit 1
            fi
        fi
    else
        print_message "'$1' is already installed."
    fi
}

# Function to install Terraform using tfenv
install_terraform_tfenv() {
    print_message "Installing Terraform using tfenv..."

    # Clone tfenv repository
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv

    # Create a bin directory in the home directory if it doesn't exist
    mkdir -p ~/bin

    # Create symbolic links for tfenv scripts in the bin directory
    ln -s ~/.tfenv/bin/* ~/bin/

    # Install the latest version of Terraform
    tfenv install latest

    # Set the installed version as the default
    tfenv use latest

    print_message "Terraform installation via tfenv completed."
}

# Function to install Terraform manually
install_terraform_manual() {
    print_message "Installing Terraform manually..."

    # Determine the latest version of Terraform
    LATEST_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)

    # Download the latest version
    curl -O https://releases.hashicorp.com/terraform/${LATEST_VERSION}/terraform_${LATEST_VERSION}_linux_amd64.zip

    # Unzip the downloaded file
    unzip terraform_${LATEST_VERSION}_linux_amd64.zip

    # Move the Terraform binary to /usr/local/bin
    sudo mv terraform /usr/local/bin/

    # Clean up the zip file
    rm terraform_${LATEST_VERSION}_linux_amd64.zip

    print_message "Terraform manual installation completed."
}

# Function to check if Terraform is installed
check_terraform_installed() {
    if command -v terraform &> /dev/null; then
        print_message "Terraform is already installed. Version: $(terraform --version | head -n 1)"
        exit 0
    fi
}

# Main script execution
print_message "Starting Terraform installation script..."

# Check if Terraform is already installed
check_terraform_installed

# Ensure necessary dependencies are installed
ensure_command "jq" "jq"
ensure_command "unzip" "unzip"

# Detect if running in AWS CloudShell
if [ -n "$CLOUDSHELL" ]; then
    print_message "Detected AWS CloudShell environment."
    install_terraform_tfenv
else
    print_message "Detected standard Linux environment."
    install_terraform_manual
fi

# Verify the installation
if command -v terraform &> /dev/null; then
    print_message "Terraform installation was successful. Version: $(terraform --version | head -n 1)"
else
    print_message "Terraform installation failed. Please check the logs for details."
    exit 1
fi

