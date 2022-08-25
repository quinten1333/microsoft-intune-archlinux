# Intune for Archlinux

There are two levels of Intune Setup. 

After installing level-1, you can access everything with certificate copied from a level-2 machine.   
After installing level-2, you can actually enroll the machine. 

## Install Level-1

1. Install `libsdbus-c++0 msalsdk-dbusclient msft-identity-broker` packages in this repo. Note that they depends on `jre11-openjdk`. 
2. Install `microsoft-edge-dev-bin` from AUR. 

## Install Level-2 and enroll

> Installing level-2 components will make your machine managed. You must satisfy password requirements, and disk-encryption requirements. Ref: <https://aka.ms/LinuxPortal>

Use a Ubuntu 20.04 VM to perform level-2 enroll. ArchLinux level-2 enroll is theoretically supported, but I never tested it. 

1. install intune-portal and its dependencies (pwquality)
2. copy /etc/os-release from ubuntu 2004 to archlinux
3. make sure you followed procedure of official doc

## Move certificates from Level-2 machine to Level-1 machine

> You need to keep your level-2 machine running, or your certificate will invalidate in 1 month. 

Copy the following files from enrolled Level-2 machine to unenrolled Level-1 machine: 

```
/var/lib/msft-identity-device-broker/1000.db
/etc/machine-id
/etc/os-release # Note: this is a symbol-link in ubuntu
/home/YourName/.config/msft-identity-broker/account-data.db
/home/YourName/.config/msft-identity-broker/broker-data.db
/home/YourName/.config/msft-identity-broker/cookies.db
/home/YourName/.local/share/keyrings/login.keyring
```

**Reboot** to make sure gnome-keyring-daemon is using the latest keyring file. 

Then, run `seahorse` to double-confirm your "login" keyring is unlocked and non-empty. It may ask you to enter the previous login password. 

> You could change the password but DO NOT remove the password protection! There is a known bug <https://gitlab.gnome.org/GNOME/gnome-keyring/-/issues/103>

You are all set! 

## FAQ and debug

If your edge browser is not allowing you to login, check the following logs: 

1. Any error message in `journalctl --user -u msft-identity-broker.service`?
2. Any error message in `sudo journalctl -u msft-identity-device-broker.service`? 
3. Run `seahorse` and is there Intune entries in your `login` keyring? Is it `set as default`? 
4. Run `ldd /usr/lib/libmsal_dbus_client.so`. Is there undefined reference? 

### Common errors

- msft-identity-broker.service: Failed at step STATE_DIRECTORY spawning /opt/msft/identitybroker/bin/msft-identity-broker: Operation not permitted

This is a permission issue. Please run `chmod 777 -R /opt/msft` as root and restart the service. 

- msft-identity-broker.service: Failed to set up special execution directory in /home/YourName/.config: Operation not permitted

This is also a permission issue while overwritting user config with root account manually. Please run `chown -R YourName /home/YourName/.config` and restart the service. 
