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
  

## bootstrap monitoring node
- Assumptions
  - no dedicated communication network


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
