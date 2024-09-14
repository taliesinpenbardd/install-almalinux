#!/bin/bash

set -e -u

#############################################
# Variables
#############################################
username="almalinux"

# Set keyboard to MacOS and French
sudo localectl set-keymap fr-mac

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
    cp -r /root/install-almalinux /home/$username
    chmod -R 777 /home/$username/install-almalinux

    # Make it executable
    chmod +x /home/$username/install-almalinux/install-almalinux.sh

    echo "************************************************************"
    echo "User $username created successfully."
    echo "************************************************************"

    # Login as the user
    su - $username
}

#############################################
# User
#############################################

# if user is root, then create a new user (non-root) and add it to the wheel group
if checkIfRoot; then
        echo "************************************************************"
        echo "User is root, creating a new user..."
        echo "************************************************************"

        createNewUser $username
else
    if checkIfUserExists; then
        echo "************************************************************"
        echo "User $username already exists, skipping user creation."
        echo "************************************************************"
    else
        echo "************************************************************"
        echo "User is not root, skipping user creation. Please ensure you have root access though."
        echo "************************************************************"

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

    echo "************************************************************"
    echo "User $username added to group almalinux"
    echo "************************************************************"
else
    echo "************************************************************"
    echo "User $username already in group almalinux"
    echo "************************************************************"
fi

# Echo whoami
echo "************************************************************"
echo "whoami: $(whoami)"
echo "************************************************************"

# Disallow root login through SSH
echo "************************************************************"
echo "Disabling root login through SSH..."
echo "************************************************************"

sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "Done."

#############################################
# Generic
#############################################

# Update the system
echo "************************************************************"
echo "Updating the system..."
echo "************************************************************"

sudo dnf update -y && sudo dnf upgrade -y

echo "Done."

# Install tar
echo "************************************************************"
echo "Installing tar..."
echo "************************************************************"

sudo dnf install tar -y

echo "Done."

# Install epel-release
echo "************************************************************"
echo "Installing epel-release..."
echo "************************************************************"

sudo dnf install epel-release -y
sudo dnf update -y

echo "Done."

# Install curl
echo "************************************************************"
echo "Installing curl..."
echo "************************************************************"

sudo dnf install curl -y

echo "Done."

# Install micro editor
echo "************************************************************"
echo "Installing micro editor..."
echo "************************************************************"

sudo curl https://getmic.ro | sudo bash
sudo mv micro /usr/bin

echo "Done."

# Install docker
echo "************************************************************"
echo "Installing docker..."
echo "************************************************************"

sudo dnf install docker -y

echo "Done."

# Install git
echo "************************************************************"
echo "Installing git..."
echo "************************************************************"

sudo dnf install git -y

echo "Done."

# Install NodeJS
echo "************************************************************"
echo "Installing NodeJS 20"
echo "************************************************************"

sudo dnf module install nodejs:20 -y

echo "Done."

# Install PHP-FPM
echo "************************************************************"
echo "Installing PHP-FPM..."
echo "************************************************************"

sudo dnf install -y http://rpms.remirepo.net/enterprise/remi-release-9.rpm
sudo dnf makecache -y
sudo dnf module reset php -y
sudo dnf module install -y php:remi-8.3
sudo dnf install -y php
sudo dnf install -y php-{common,pear,cgi,curl,gettext,bcmath,json,intl,imap,fpm,cli,gd,mbstring,mysqlnd,xml,zip,opcache,pdo}
sudo sed -i 's/;listen.owner = nobody/listen.owner = caddy/g' /etc/php-fpm.d/www.conf
sudo sed -i 's/;listen.group = nobody/listen.group = caddy/g' /etc/php-fpm.d/www.conf
sudo sed -i 's/;listen.mode = 0660/listen.mode = 0660/g' /etc/php-fpm.d/www.conf
sudo sed -i 's/listen.acl_users = apache,nginx/listen.acl_users = apache,nginx,caddy/g' /etc/php-fpm.d/www.conf
sudo systemctl enable php-fpm
# sudo systemctl start php-fpm

echo "Done."

# Install Composer
echo "************************************************************"
echo "Installing Composer..."
echo "************************************************************"

sudo dnf install composer -y

echo "Done."

# Install caddy server
echo "************************************************************"
echo "Installing caddy server..."
echo "************************************************************"

sudo dnf install caddy -y
sudo systemctl enable caddy
sudo mkdir -p /var/www/production/html
sudo mkdir -p /var/www/production/logs
sudo touch /var/www/production/logs/access.caddy.log
# sudo cp localhost.caddyfile /etc/caddy/Caddyfile.d
sudo curl -o /etc/caddy/Caddyfile.d/localhost.caddyfile https://raw.githubusercontent.com/taliesinpenbardd/install-almalinux/main/localhost.caddyfile
sudo systemctl start caddy
sudo systemctl start php-fpm

echo "Done."

# Enable and start firewalld
echo "************************************************************"
echo "Enabling and starting firewalld..."
echo "************************************************************"

sudo dnf install firewalld -y
sudo systemctl enable firewalld
sudo systemctl start firewalld

echo "Done."

# Open ports
echo "************************************************************"
echo "Opening ports..."
echo "************************************************************"

sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh
# Uncomment the next line if you need your mysql server accessible from outside
# sudo firewall-cmd --permanent --add-service=mysql
sudo systemctl restart firewalld

echo "Done."

# Install fail2ban
echo "************************************************************"
echo "Installing fail2ban..."
echo "************************************************************"

sudo dnf install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "Done."

# Permissions
echo "************************************************************"
echo "Setting permissions..."
echo "************************************************************"

sudo usermod -aG wheel caddy
sudo usermod -aG caddy almalinux
sudo usermod -aG almalinux caddy
sudo find /var/www -type f -exec chmod 644 {} \;
sudo find /var/www -type d -exec chmod 755 {} \;
sudo chown -R almalinux:caddy /var/www
# @see https://stackoverflow.com/a/52121913
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/production/html/storage(/.*)?"
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/production/html/bootstrap/cache(/.*)?"
sudo restorecon -Rv /var/www/production/html

echo "Done."

# Install MariaDB
echo "************************************************************"
echo "Installing MariaDB..."
echo "************************************************************"

sudo dnf install mariadb-server -y
sudo systemctl enable mariadb
sudo systemctl start mariadb
# sudo mysql_secure_installation

echo "************************************************************"
echo "Installation complete."
echo "Don't forget to run 'sudo mysql_secure_installation' later to secure your MariaDB installation."
echo "************************************************************"

# echo "Do you want to run mysql_secure_installation now? (y/n)"
# read -r response
# if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then sudo mysql_secure_installation; else echo "Please remember to run 'sudo mysql_secure_installation' later to secure your MariaDB installation."; fi
