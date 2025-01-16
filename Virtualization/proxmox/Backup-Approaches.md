# Backup-Approaches for Proxmox
Of course, the most simple approach is using proxmox own [*Proxmox Backup Server*](https://www.proxmox.com/en/products/proxmox-backup-server/overview) as a target for the built-in backup service.

However, this approach has a number of weaknesses in terms of IT security:
- The Proxmox Backup Server offers a special share, that's mounted on all proxmox hosts. Once such a host has been captured by an offender, all data including the backups are accessible -- and can be deleted.
- The connection of both services rely on *UID* and *password*, so a quite weak security approach.
- 
