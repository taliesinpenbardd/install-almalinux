# Installation

## First steps

```bash
sudo dnf update -y && sudo dnf upgrade -y && \
sudo localectl set-keymap fr-mac && \
sudo dnf install -y git && \
sudo git clone https://github.com/taliesinpenbardd/install-almalinux.git && \
cd install-almalinux && \
sudo chmod +x install-almalinux.sh && \
bash ./install-almalinux.sh
```

Line by line, it:

- updates and upgrades the system
- sets the keyboard layout to French/Mac (use `fr-oss` on Windows)
- installs git
- clones this repository
- goes in the directory
- makes the installation script executable
- launches the installation script

You will be asked for your password, and then the installation will be automatic.

## New user

If you need to create a new user (because you are root by default), the process will copy the installation file to your new user's home directory and log you as the new user. Then relaunch the process (`bash ./install-almalinux.sh`), answer `n` when asked if you want to create a new user and go on.

## Detailed steps

This script will:

- Check if you're root or not. If you're root, create another user and add it to sudoers, then log in as this user.
- Disable root login for security
- Install :
  - tar
  - epel-release
  - git
  - curl
  - micro editor
  - docker
  - NodeJS 18
  - caddy server
  - fail2ban
  - PHP-FPM with PHP 8.3
  - Composer
  - MariaDB
- Adapt the firewall to open ports for Caddy
- Adapt the PHP-FPM config file to allow Caddy to use it, in case of need of the `reverse_proxy` directive
- Create a localhost.caddyfile in `/etc/caddy/Caddyfile.d` that you will be able to edit and customize. Usually, in this file, you'll want to replace `localhost` with your domain name (e.g. `example.com`). As per Caddy rules, no need to precise the scheme, the HTTPS connexion is automatically generated.
- At the very end of the script, you are left with MariaDB's `mysql_secure_installation` where you'll need to change the password for the root MySQL user.

### MariaDB Config

Once the `mysql_secure_installation` process is done (do not forget to change the root password), you are left with the task of creating the tables. Typically, that looks like that:

```bash
sudo systemctl enable mariadb
sudo systemctl start mariadb

sudo mysql
create database your_database_name;
create user your_user_name@localhost identified by 'your_user_password';
grant all on your_database_name.* to your_user_name@localhost;
flush privileges;
exit;
```

### Domain config

You'll have to redirect your domain's A records to the IPv4 address of the server, and the domain's AAAA records to its IPv6 address, for each subdomain.

### SELinux

Although a good defense, SELinux is a pain. If you have write errors on your files (most probably on /bootstrap/cache/\* and /storage/logs/\* for Laravel), begin by temporarily deactivate SELinux with `setenforce 0`. If the website runs normally, that was the problem. In that case, get security back with `setenforce 1`. Then use `semanage` to change the context authorizations (always check the paths):

```bash
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/production/html/storage(/.*)?" && \
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/production/html/bootstrap/cache(/.*)?" && \
sudo restorecon -Rv /var/www/production/html
```

### Note

This script is tailored for me. Use at your own risks.
