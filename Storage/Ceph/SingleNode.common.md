# Common Notes on my first *Single Node Cluster* Rollout
I follow the [guide published by RedHat](https://www.redhat.com/en/blog/ceph-cluster-single-machine)
## System Setting
- one VM running on Proxmox 8.3.1
- Rocky Linux 9.5
- Kernel `5.14.0-503.15.1.el9:5.x86`
- 16 GB RAM
- 2 vCPU (*Intel (R) Xeon(R) CPU E5-2630 v2 @ 2.60GHz*)
- 4 Disks:
  - one SSD `sda` for OS, three SATA `sd{b,c,d}` for data
  ```bash
  $ lsblk
  NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
  sda           8:0    0   32G  0 disk
  ├─sda1        8:1    0    1G  0 part /boot
  └─sda2        8:2    0   31G  0 part
    ├─rl-root 253:0    0 27.8G  0 lvm  /var/lib/containers/storage/overlay
    │                                  /
    └─rl-swap 253:1    0  3.2G  0 lvm  [SWAP]
  sdb           8:16   0    1T  0 disk
  sdc           8:32   0    1T  0 disk
  sdd           8:48   0    1T  0 disk
  sr0          11:0    1 1024M  0 rom
  ```

  ## preparation
- additional software
  ```bash
  dnf -y install podman
  dnf -y install python3-jinja2
  ```

- install `cephadm` itself
  ```bash
  sudo dnf search release-ceph
  sudo dnf install --assumeyes centos-release-ceph-squid
  sudo dnf install --assumeyes cephadm
  ```

- add `squid` repo
  ```bash
  sudo cephadm add-repo --release squid
  ```
- add `ceph-common` tools (containing e.g. `ceph`, `rbd`, `mount.ceph`)
  ```bash
  sudo cephadm add-repo --release squid
  sudo cephadm install ceph-common
  ```
  
  > [INFO]
  > using the distro's `ceph-common` will install the version of ceph assigned to the OS version ???
  

## bootstrap monitoring node
- Assumptions
  - no dedicated communication network
- `cephadm bootstrap` command
  - `--mon-ip 192.168.189.101` : IP to access the Monitoring node
  - `--cluster-network 192.168.189.0/24` define the network for the internal cluster communication (practically skipped as there's no)
  - `--dashboard-password-noupdate` :  stop forced dashboard password change
  - `--initial-dashboard-user admin` : Initial user for the dashboard
  - `--initial-dashboard-password <Password>` : Initial password for the initial dashboard user
  - `--log-to-file` :  configure cluster to log to traditional log files in `/var/log/ceph/$fsid`
  - `--single-host-defaults` : adjust configuration defaults to suit a single-host cluster
  <br>==>
  ```bash
  Ceph Dashboard is now available at:

             URL: https://PAG-L:8443/
            User: admin
        Password: <Password>
  
  Enabling client.admin keyring and conf on hosts with "admin" label
  Saving cluster configuration to /var/lib/ceph/<ceph cluster ID>/config directory
  You can access the Ceph CLI as following in case of multi-cluster or non-default config:

        sudo /sbin/cephadm shell --fsid <ceph cluster ID> -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring
  
  Or, if you are only running a single cluster on this host:
  
        sudo /sbin/cephadm shell
  
  Please consider enabling telemetry to help improve Ceph:
  
        ceph telemetry on
  
  For more information see:
  
        https://docs.ceph.com/en/latest/mgr/telemetry/
  
  Bootstrap complete.
  ```
- check config `ceph -s` or `ceph status`:
  ```bash
  sudo ceph -s
    cluster:
  id:     1f3cb94c-b7c3-11ef-b021-e89c25c69efd
  health: HEALTH_WARN
          OSD count 0 < osd_pool_default_size 2

  services:
    mon: 1 daemons, quorum PAG-L (age 24m)
    mgr: PAG-L.suzyia(active, since 23m), standbys: PAG-L.khupoi
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
  ```
---
# Bugs
- by default the installation of the ceph repo fails, as the `jinja2` package is missing:
  ```
  $ sudo cephadm add-repo --release squid
  Traceback (most recent call last):
    File "/usr/lib64/python3.9/runpy.py", line 197, in _run_module_as_main
      return _run_code(code, main_globals, None,
    File "/usr/lib64/python3.9/runpy.py", line 87, in _run_code
      exec(code, run_globals)
    File "/sbin/cephadm/__main__.py", line 131, in <module>
    File "<frozen zipimport>", line 259, in load_module
    File "/sbin/cephadm/cephadmlib/logging.py", line 17, in <module>
    File "<frozen zipimport>", line 259, in load_module
    File "/sbin/cephadm/cephadmlib/templating.py", line 11, in <module>
  ModuleNotFoundError: No module named 'jinja2'
```
