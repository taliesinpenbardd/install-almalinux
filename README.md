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
curl -o install.sh https://raw.githubusercontent.com/taliesinpenbardd/install-almalinux/main/install-almalinux.sh
chmod +x install.sh
bash ./install.sh
```

You'll be asked for your password a few times, but the rest is automatic.
