# Backup-Approaches for Proxmox
Of course, the most simple approach is using proxmox own [*Proxmox Backup Server*](https://www.proxmox.com/en/products/proxmox-backup-server/overview) as a target for the built-in backup service.

However, this approach has a number of weaknesses in terms of IT security:
- The Proxmox Backup Server offers a special share, that's mounted on all proxmox hosts. Once such a host has been captured by an offender, all data including the backups are accessible -- and can be deleted.
- The connection of both services rely on *UID* and *password*, so a quite weak security approach.
- 
---
## idea box
- using different approaches as a backup target for offloading the data backed up
  - something like cohesity/smartfile
  - [s3fs-fuse](https://github.com/s3fs-fuse)

- what about `veeam`?
- what about `TSM^H ISP`
- what else?


---
# Collected Links
- [How to use the command 'qmrestore' (with examples)](https://commandmasters.com/commands/qmrestore-linux/)
