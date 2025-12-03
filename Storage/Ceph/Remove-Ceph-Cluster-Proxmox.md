# Removing a Ceph cluster when defined inside Proxmox

Run all commands on each PVE node:

-  Stop Ceph services

  ```bash
  systemctl stop ceph-mon.target
  systemctl stop ceph-mgr.target
  systemctl stop ceph-mds.target
  systemctl stop ceph-osd.target
  ```

- remove service descriptions

  ```bash
  rm -rf /etc/systemd/system/ceph*
  ```
- make sure, all ceph jobs are really down

  ```bash
  killall -9 ceph-mon ceph-mgr ceph-mds
  ```

- remove all ceph related files in `/var`

  ```bash
  rm -rf /var/lib/ceph/mon/  /var/lib/ceph/mgr/  /var/lib/ceph/mds/
  rm -rf /var/lib/ceph
  ```

- remove ceph from Proxmox

  ```bash
  pveceph purge
  ```

- remove packages

  ```bash
  apt purge ceph-mon ceph-osd ceph-mgr ceph-mds
  apt purge ceph-base ceph-mgr-modules-core
  ```

- remove all ceph settings

  ```bash
  rm -rf /etc/ceph/*
  rm -rf /etc/pve/ceph.conf
  rm -rf /etc/pve/priv/ceph.*
  ```

- done? I will check :-)
