# Common Notes on my first *~Single~ Node Cluster* Rollout
I follow the [guide published by RedHat](https://www.redhat.com/en/blog/ceph-cluster-single-machine)
## System Setting
🚧this part vvv is obsolete 🚧
- one VM running on Proxmox 8.3.1
- Rocky Linux 9.5<br>
  by now (Dec 12th 2024) *AlmaLinux* still supports *Ceph 18.2* but not *19.2*
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
🚧this part ^^^is obsolete 🚧
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
  
> [!NOTE]
> using the distro's `ceph-common` will install the version of ceph assigned to the OS version ???
  
- fix `chronyd` configuration<br>
  do *as root:*
  ```bash
  sed -i '/^server/ s/\(\S\+\s\+\)\S\+/\1pool.ntp.org/' /etc/chrony.conf
  systemctl restart chronyd
  ```
> [!NOTE]
> For Testing purposes create a folder shared with all OSDs to execute commands by script<br>
> do *as root:*
> ```bash
> mkdir /mnt/sata/ceph/cns
> echo "# Ceph Share" >> /etc/exports
> echo "/mnt/cns 192.168.189.0/0(ro) >> /etc/exports
> systemctl restart nfs-server
> ```
> Also add on Monitor node and all OSDs<br>
> do *as root:*
> ```bash
> dnf install -y nfs-utils
> mkdir /mnt/cns
> echo "# Ceph Share" >> /etc/fstab
> echo "192.168.122.1:/mnt/sata/ceph/cns /mnt/cns nfs defaults 0 0" >> /etc/fstab
> mount -a
> ```
## bootstrap monitoring node
- Assumptions
  - no dedicated communication network
- `cephadm bootstrap` command
  - `--mon-ip 192.168.189.100` : IP to access the Monitoring node
  - `--cluster-network 192.168.189.0/24` define the network for the internal cluster communication (practically skipped as there's no)
  - `--dashboard-password-noupdate` :  stop forced dashboard password change
  - `--initial-dashboard-user admin` : Initial user for the dashboard
  - `--initial-dashboard-password <Password>` : Initial password for the initial dashboard user
  - `--log-to-file` :  configure cluster to log to traditional log files in `/var/log/ceph/$fsid`
  - `--single-host-defaults` : adjust configuration defaults to suit a single-host cluster
  ```bash
  sudo cephadm bootstrap --mon-ip 192.168.189.101 --cluster-network 192.189.122.0/24 --dashboard-password-noupdate --initial-dashboard-user admin --initial-dashboard-password PassW0rd --log-to-file 
  ```
  <br>==>
  ```bash
  Ceph Dashboard is now available at:

             URL: https://PAG-L:8443/
            User: admin
        Password: PassW0rd
  
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
- check Ceph CLI
  ```bash
  # sudo /sbin/cephadm shell
  Inferring fsid c9b21574-b95e-11ef-9b8f-e89c25c69efd
  Inferring config /var/lib/ceph/c9b21574-b95e-11ef-9b8f-e89c25c69efd/mon.PAG-L/config
  Using ceph image with id '37996728e013' and tag 'v19' created on 2024-09-27 22:08:21 +0000 UTC
  quay.io/ceph/ceph@sha256:200087c35811bf28e8a8073b15fa86c07cce85c575f1ccd62d1d6ddbfdc6770a
  [ceph: root@PAG-L /]#
  [ceph: root@PAG-L /]#exit
  ```
- check config `ceph -s` or `ceph status`:
  ```bash
  sudo ceph -s
    cluster:
  id:      c9b21574-b95e-11ef-9b8f-e89c25c69efd
  health: HEALTH_WARN
          OSD count 0 < osd_pool_default_size 3

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
## check cluster using the GUI
- show an alert *404 - Not Found Could not reach Alertmanager's API on http://PAG-L:9093/api/v2*
  - having a deeper look on the *alerts* gives a hint: <br>
  *Information*
  *To see all active Prometheus alerts, please provide the URL to the API of Prometheus' Alertmanager as described in the [documentation](https://docs.ceph.com/en/squid/mgr/dashboard/#enabling-prometheus-alerting)."
  
## add further nodes to cluster
### EXCURSE : Setting up further VMs as OSDs
just add the local disk files does not work, so create three KVMs as OSDs ...
- ... which can be done easly using the *cockpit GUI* for RHEL and derivates ;-) ...
  - use the basic installation setup (initally without an additional storage disk)

> [!NOTE]
> preparing one node without adding the data disk lowers the effort for the next steps ;-)

- add the ceph stuff as mentioned above<br>
  ```bash
  sudo dnf -y install podman
  sudo dnf -y install python3-jinja2
  sudo dnf search release-ceph
  sudo dnf install --assumeyes centos-release-ceph-squid
  sudo cephadm add-repo --release squid
  sudo cephadm install ceph-common
  ```
  or put commands into a script on the common share and run it remotely
  ```bash
  ssh OSD1 "bash /mnt/cns/install-ceph.sh"
  ssh OSD2 "bash /mnt/cns/install-ceph.sh"
  ssh OSD3 "bash /mnt/cns/install-ceph.sh"
  ```
> [!NOTE]
> using a parallel command shell will do a better job, I know :-)

- copy the public *ceph* key to the nodes:<br>
  ```bash
  ssh-copy-id -f -i /etc/ceph/ceph.pub root@OSD1
  ssh-copy-id -f -i /etc/ceph/ceph.pub root@OSD2
  ssh-copy-id -f -i /etc/ceph/ceph.pub root@OSD3
  ```
- add new nodes to cluster:
  ```bash
  sudo ssh-copy-id -f -i /etc/ceph/ceph.pub root@*<new-host>*
  ```
  e.g.
  ```
  sudo ceph orch host add OSD1 192.168.122.101
  sudo ceph orch host add OSD1 192.168.122.102
  sudo ceph orch host add OSD1 192.168.122.103
  ```
- attach storage disk
  - Tell Ceph to consume any available and unused storage device:
     ```bash
     ceph orch apply osd --all-available-devices
     ```
  - Create an OSD from a specific device on a specific host:
    ```bash
    ceph orch daemon add osd *<host>*:*<device-path>*
    ```
    <br>so
    ```bash
    sudo ceph orch daemon add osd OSD1:/dev/vdb
    sudo ceph orch daemon add osd OSD2:/dev/vdb
    sudo ceph orch daemon add osd OSD3:/dev/vdb
    ```



---
# *Tabular Rasa* -- How to remove whole Ceph stuff if anything gets f****d up?
## the hardcore approach
- remove all ceph services from systemd (on Monitor and OSD nodes
  ```bash
  sudo rm -rf /etc/systemd/system/ceph*
  ```
- remove cluster using cluster *fsid*
  ```bash
  cephadm rm-cluster --fsid <cluster_fsid> --force
  ```
- kill all podman containers
  ```bash
  sudo podman kill -a
  ```
- remove all podman containers
  ```bash
  sudo podman kill -a
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
