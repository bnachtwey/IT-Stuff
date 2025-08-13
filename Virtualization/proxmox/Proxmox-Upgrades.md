# Upgrading Proxmox
Although the process is well described at [proxmox' website](), I'd like to share some personal experiences and advise:

## Workflow PVE 8 => PVE9

1) First, make sure that the system is using the latest Proxmox VE 8.4 packages:

   ```bash
   apt update
   apt dist-upgrade
   ```
   check with
   ```
   root@pve:~# pveversion
   pve-manager/8.4.10/293f4abc4b22fa08 (running kernel: 6.8.12-13-pve)
   ```

2) Update all Debian and Proxmox VE repository entries to Trixie.

   ```bash
   sed -i 's/bookworm/trixie/g' /etc/apt/sources.list
   sed -i 's/bookworm/trixie/g' /etc/apt/sources.list.d/pve-enterprise.list
   ```
   
   > Me: Don't forget Ceph if you're using it

   ```bash
   sed -i 's/bookworm/trixie/g' /etc/apt/sources.list.d/ceph.list
   ```
   
   > If you're using the _non-subscription_, don't forget to clean up a little bit
   > and add the `non-free-firmware` repo

   > Well, I suggest to replace the whole sources stuff by one new file:
   >
   > ```bash
   > deb http://ftp.de.debian.org/debian trixie main contrib non-free-firmware
   > 
   > deb http://ftp.de.debian.org/debian trixie-updates main contrib non-free-firmware
   > 
   > # security updates
   > deb http://security.debian.org trixie-security main contrib non-free-firmware
   >
   > # Proxmox and Ceph
   > deb http://download.proxmox.com/debian/pve trixie pve-no-subscription
   > deb http://download.proxmox.com/debian/ceph-squid trixie no-subscription
   > ```
   
   Rebuild Apt Cache

   ```bash
   apt-get clean all
   apt-get update
   ```
3) check for further problems using `pve8to9`, fix at least

   - remove `systemd-boot` if installed:

     ```bash
     apt-get remove systemd-boot
     ```
   - add `intel-microcode` if using intel CPUs

     ```bash
     apt-get install intel-microcode
     ```
4) do full upgrade

   ```bash
   apt-get dist-upgrade
   ```

   > I do wonder, why I have to reconfigre my keyboard and console locale ... well ...
   > No need to restart services as you'll reboot the whole maschine afterwards
    
