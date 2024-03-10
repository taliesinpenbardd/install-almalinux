# Installation

## First steps

You might wanna install `curl` to download the installer:

```
dnf install -y curl
```

If needed, you can set your keyboard to the right configuration:

```
localectl set-keymap fr-mac
```

(Use `fr-oss` on Windows)

Then, all you have to do is :

```
curl -O https://raw.githubusercontent.com/taliesinpenbardd/install-almalinux/main/install-almalinux.sh
chmod +x install-almalinux.sh
bash ./install-almalinux.sh
```

You'll be asked for your password a few times, but the rest is automatic.

## Note

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
- Adapt the firewall to open ports for Caddy
-
