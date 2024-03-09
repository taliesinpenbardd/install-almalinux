#!/bin/bash

#############################################
# Variables
#############################################
username="almalinux"

# Set keyboard to MacOS and French
localectl set-keymap fr-mac

#############################################
# Functions
#############################################
# Check if user is root
checkIfRoot() {
    if [ "$(id -u)" -ne 0 ]; then
        return 1
    else
        return 0
    fi
}

# Check if the user exists
checkIfUserExists() {
    if id "$username" &>/dev/null; then
        return 1
    else
        return 0
    fi
}

# Check if the group of the same name exists
checkIfGroupExists() {
    if grep -q "^$username:" /etc/group; then
        return 1
    else
        return 0
    fi
}

#############################################
# User
#############################################

# if user is root, then create a new user (non-root) and add it to the wheel group
if checkIfRoot; then
    echo "User is root, creating a new user..."
    read -p "Enter your username: [Default: almalinux]" username
    username=${username:-almalinux}
    useradd -m $username
    passwd $username
    usermod -aG wheel $username

    echo <<MESSAGE

User $username created successfully.

MESSAGE
else
    echo <<MESSAGE

User is not root, skipping user creation. Please ensure you have root access though.

MESSAGE
fi

# if user is not in the almalinux group, add him to the group
if ! grep -q "^$username:" /etc/group; then
    groupadd almalinux
    usermod -aG almalinux $username

    echo <<MESSAGE

User $username added to group almalinux

MESSAGE
else
    echo <<MESSAGE

User $username already in group almalinux

MESSAGE

fi

# Login as the user
su - $username

# Echo whoami
echo <<MESSAGE

whoami: $(whoami)

MESSAGE

# Disallow root login through SSH
echo <<<MESSAGE

Disabling root login through SSH...

MESSAGE
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo "Done."

#############################################
# Generic
#############################################

# Update the system
echo " "
echo "Updating the system..."
echo " "
sudo dnf update -y
echo "Done."

# Install epel-release
echo " "
sudo dnf install epel-release -y
echo " "
sudo dnf update -y
echo "Done."

# Install Git
echo " "
echo "Installing Git..."
echo " "
sudo dnf install git -y
echo "Done."

# Install curl
echo " "
echo "Installing curl..."
echo " "
sudo dnf install curl -y
echo "Done."

# Install micro editor
echo " "
echo "Installing micro editor..."
echo " "
curl https://getmic.ro | bash
sudo mv micro /usr/bin
echo "Done."

# Install docker
echo " "
echo "Installing docker..."
echo " "
sudo dnf install docker -y
echo "Done."

# Install caddy server
echo " "
echo "Installing caddy server..."
echo " "
sudo dnf install caddy -y
sudo systemctl enable caddy
sudo systemctl start caddy
echo "Done."

# Enable and start firewalld
echo " "
echo "Enabling and starting firewalld..."
echo " "
sudo systemctl enable firewalld
sudo systemctl start firewalld
echo "Done."

# Open ports
echo " "
echo "Opening ports..."
echo " "
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh
sudo systemctl restart firewalld
echo "Done."

# Install fail2ban
echo " "
echo "Installing fail2ban..."
echo " "
sudo dnf install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
echo "Done."
