#!/bin/bash

#############################################
# Variables
#############################################
username="almalinux"

#############################################
# Functions
#############################################
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
    passwd almalinux
    echo "User '$username' created successfully"
fi

# the user exists, does the group exist?
if checkIfGroupExists $username; then
    echo "Group '$username' already exists"
else
    # Create the group of the same name as the user
    groupadd $username
    echo "Group '$username' created successfully"
fi

# Add the user to the group of the same name
usermod -a -G $username $username
echo "User '$username' added to group $username"

# Add the user to the sudoers file
# echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/$username
usermod -aG wheel $username

# Login as the user
su - $username

# Echo whoami
echo "whoami: $(whoami)"

#############################################
# Generic
#############################################

# Update the system
echo "Updating the system..."
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