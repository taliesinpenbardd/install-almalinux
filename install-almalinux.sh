#!/bin/bash

#############################################
# Variables
#############################################
username="almalinux"

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

# Check if the user exists
read -p "Enter your username: [Default: almalinux]" username
username=${username:-almalinux}

if checkIfUserExists $username; then
    echo "User '$username' already exists"
else
    # Create the user
    useradd -m $username
    passwd $username
    echo "User '$username' created successfully"
fi

# the user exists, does the group exist?
if checkIfGroupExists almalinux; then
    echo "Group almalinux already exists"
else
    # Create the group of the same name as the user
    groupadd almalinux
    echo "Group almalinux created successfully"
fi

# Add the user to the group of the same name
usermod -aG almalinux $username
echo "User '$username' added to group almalinux"

# Add the user to the sudoers file
usermod -aG wheel $username

# Login as the user
su - $username

# Echo whoami
echo "whoami: $(whoami)"

# Disallow root login through SSH
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

#############################################
# Generic
#############################################

# Update the system
echo "Updating the system..."
sudo dnf update -y

# Install epel-release
sudo dnf install epel-release -y
sudo dnf update -y

# Install Git
echo "Installing Git..."
sudo dnf install git -y

# Install curl
echo "Installing curl..."
sudo dnf install curl -y

# Install docker
echo "Installing docker..."
sudo dnf install docker -y

# Install caddy server
echo "Installing caddy server..."
sudo dnf install caddy -y
sudo systemctl enable caddy
sudo systemctl start caddy

# Enable and start firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld

# Open ports
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh
sudo systemctl reload firewalld

# Install fail2ban
echo "Installing fail2ban..."
sudo dnf install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
