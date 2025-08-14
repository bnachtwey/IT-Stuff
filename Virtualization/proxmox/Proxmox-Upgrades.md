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

5) Cleanup Repos again

   > Well, after the full upgrade, the enterprise repo is back again and enabled, so just remove it again
   >
   > ```bash
   > rm -f /etc/apt/sources.list.d/pve-enterprise.sources
   > ```

## Workflow PBS 3.4.1 => PBS ??

> [!INFO]
> This Notes cover a dedicated Backup Server

1) First, make sure that the system is using the latest Proxmox Backup Server packages:

   ```bash
   apt update
   apt dist-upgrade
   ```
2) check versions with `pbs3to4`

   e.g.
   ```bash
   ~# pbs3to4
   = CHECKING VERSION INFORMATION FOR PBS PACKAGES =
   
   INFO: Checking for package updates..
   PASS: all packages up-to-date
   INFO: Checking proxmox backup server package version..
   PASS: 'proxmox-backup' has version >= 3.4.0
   INFO: Check running kernel version..
   PASS: running kernel '6.8.12-10-pve' is considered suitable for upgrade.
   
   = MISCELLANEOUS CHECKS =
   
   INFO: Checking PBS daemon services..
   PASS: systemd unit 'proxmox-backup.service' is in state 'active'
   PASS: systemd unit 'proxmox-backup-proxy.service' is in state 'active'
   INFO: Checking for supported & active NTP service..
   PASS: Detected active time synchronisation unit
   INFO: Checking for package repository suite mismatches..
   PASS: found no suite mismatch
   INFO: Checking bootloader configuration...
   SKIP: System booted in legacy-mode - no need for additional pacckages.
   SKIP: could not get dkms status
   
   = SUMMARY =
   
   TOTAL:     9
   PASSED:    7
   SKIPPED:   2
   NOTICE:    0
   ```
    
3) Update all Debian and PBS repository entries to Trixie.

  ```bash
  sed -i 's/bookworm/trixie/g' /etc/apt/sources.list
  ```

4) do dist-upgrade

  ```bash
  apt-get clean all
  apt-get update
  apt-get dist-upgrade
  ```

5) ..
