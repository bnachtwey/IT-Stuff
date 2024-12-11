# Common Notes on my first *Single Node Cluster* Rollout
I follow the [guide published by RedHat](https://www.redhat.com/en/blog/ceph-cluster-single-machine)
## System Setting
- one VM running on Proxmox 8.3.1
- no dedicated communication network
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
