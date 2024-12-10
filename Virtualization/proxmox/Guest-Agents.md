# Adding Guest Agents for best usage
> [!IMPORTANT]
> Check if `QEMU Guest Agent` is enabled in the *Options* section -- as it's not by default :-(

Due to the [official proxmox documentation](https://pve.proxmox.com/wiki/Qemu-guest-agent) the `qemu-guest-agent` should be installed
- for Debian style Linuxes<br>
  `apt-get install qemu-guest-agent`
- on Redhat based systems (with yum):<br>
  `yum install qemu-guest-agent`
- Depending on the distribution, the guest agent might not start automatically after the installation.
  - Start it either directly with<br>
    `systemctl start qemu-guest-agent`
  - Then enable the service to autostart (permanently) if not auto started, with<br>
    `systemctl enable qemu-guest-agent`
- restart the VM

## Issues
- Starting the daemon in a privte subnet, the name resultion may fail<br>
  `sudo: unable to resovle <host name>: Temporary failure in name resolution`<br>
  FIX:<br>
  - check if the correct `hostname` is recorded in the `/etc/hosts` file
  - 
