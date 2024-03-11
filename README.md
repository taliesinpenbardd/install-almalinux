# Installation

## First steps

You might wanna install `git` to clone the script:

```
dnf install -y git
```

If needed, you can set your keyboard to the right configuration:

```
localectl set-keymap fr-mac
```

(Use `fr-oss` on Windows)

Then, all you have to do is :

```
git clone https://github.com/taliesinpenbardd/install-almalinux.git
cd install-almalinux
chmod +x install-almalinux.sh
bash ./install-almalinux.sh
```

You'll be asked for your password a few times, but the rest is automatic.

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
  - caddy server
  - fail2ban
  - PHP-FPM with PHP 8.3
  - MariaDB
- Adapt the firewall to open ports for Caddy
- Adapt the PHP-FPM config file to allow Caddy to use it, in case of need of the `reverse_proxy` directive
- Create a localhost.caddyfile in `/etc/caddy/Caddyfile.d` that you will be able to edit and customize. Usually, in this file, you'll want to replace `localhost` with your domain name (e.g. `example.com`). As per Caddy rules, no need to precise the scheme, the HTTPS connexion is automatically generated.
- At the very end of the script, you are left with MariaDB's `mysql_secure_installation` where you'll need to change the password for the root MySQL user.

### Note

This script is tailored for me. Use at your own risks.
