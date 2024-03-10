#!/bin/bash

set -e -u

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

createNewUser() {
    read -r -p "Enter your username: [Default: almalinux]" username
    username=${username:-almalinux}
    useradd -m $username
    passwd $username
    usermod -aG wheel $username

    # Move the script to the user's home directory
    cp ./install-almalinux.sh /home/$username

    # Make it executable
    chmod +x /home/$username/install-almalinux.sh

    # Login as the user
    su - $username

    echo " "
    User $username created successfully.
    echo " "
}

#############################################
# User
#############################################

# if user is root, then create a new user (non-root) and add it to the wheel group
if checkIfRoot; then
        echo " "
        echo "User is root, creating a new user..."
        echo " "

        createNewUser $username
else
    if checkIfUserExists; then
        echo " "
        echo "User $username already exists, skipping user creation."
        echo " "
    else
        echo " "
        echo "User is not root, skipping user creation. Please ensure you have root access though."
        echo " "

        read -p "Would you create another user? [y/n] " -n 1 -r response
        if [[ $response =~ ^[Yy]$ ]]; then
            createNewUser $username
        fi
    fi
fi

# if user is not in the almalinux group, add him to the group
if ! grep -q "^$username:" /etc/group; then
    groupadd almalinux
    usermod -aG almalinux $username

    echo " "
    echo "User $username added to group almalinux"
    echo " "
else
    echo " "
    echo "User $username already in group almalinux"
    echo " "
fi

# Echo whoami
echo " "
echo "whoami: $(whoami)"
echo " "

# Disallow root login through SSH
echo " "
echo "Disabling root login through SSH..."
echo " "

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

# Install tar
echo " "
echo "Installing tar..."
echo " "
sudo dnf install tar -y
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
