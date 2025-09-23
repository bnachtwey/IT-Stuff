# Comparing CLI commands for plain KVM and PVE
Although Proxmox uses KVM as technique, not only the GUI is different, but also some commands.

I'm going to collect at least those I'm using :-)

> [!INFO]
> by now (Feburary 2025) I compare
> - *Proxmox 8.3.2 on Debian 12 / Bookwork*, Kernel `6.8.12-5-pve`
> - *Rocky Linux 9.5 (Blue Onyx)*, Kernel `5.14.0-503.21.1.el9_5.x86_64`

## Gather Information
### Get list of running VMs
| Proxmox VM | Proxmox LXC | KVM |
| :------ | :------ | :--- |
| `qm list` | `pct list`| `virsh list`|

### Get list of all VMs
| Proxmox VM | Proxmox LXC | KVM |
| :------ | :------ | :--- |
| `qm list \| grep -v "stopped"`  |  `pct list \| grep -v "stopped"`  | `virsh list --all`|

### Get list of storage pools
| Proxmox | KVM |
| :------ | :--- |
| `pvesh status` | no simple command :-( -- see [examples](./KVE-PVE-Command-Examples.md)| 

## Shutdown - Start - HardStop - Suspend - Resume VMs
### Shutting down a certain VM
| Proxmox VM | Proxmox LXC | KVM |
| :------ | :------ | :--- |
| `qm shutdown <vmid>` | `pct shutdown <vmid>` | `virsh shutdown <vm-name>` |

### Start a certain VM| Proxmox VM | Proxmox LXC | KVM |
| :------ | :------ | :--- |
| `qm start <vmid>` | `pct start <vmid>` | `virsh start <vm-name>` |

### (Hard) Stopping a certain VM
### Start a certain VM
| Proxmox VM | Proxmox LXC | KVM |
| :------ | :------ | :--- |
| `qm stop <vmid>` | `pct stop <vmid>` ||`virsh destroy <vm-name>` |

### (Hard) Reseting a certain VM
| Proxmox VM | Proxmox LXC | KVM |
| :------ | :------ | :--- |
| `qm reset <vmid>` | `pct stop <vmid> && pct start <vmid>` | `virsh reboot <vm-name>` |
| | | `virsh destroy <vm-name> && virsh start <vm-name>` |

### Suspend a certain VM
*ordinary suspend*, just freerzing the VM
| Proxmox VM | Proxmox LXC | KVM |
| :------ | :------ | :--- |
| `qm suspend <vmid>`| `pct suspend <vmid>` | `virsh suspend <vm-name>` |

### Suspend a certain VM with saving the state to disk
works like VMware-like *Suspend* functionality
| Proxmox | KVM |
| :------ | :--- |
| `qm suspend <vmid> --todisk 1` | `virsh managedsave <vm-name>` |

### Resume a certain suspended VM
| Proxmox | KVM |
| :------ | :--- |
| `qm resume <vmid>` | `virsh resume <vm-name>` |

### Unlock a certain *unresponsive* VM
| Proxmox | KVM |
| :------ | :--- |
| `qm unlock <vmid>` | `virsh managedsave-remove <vm-name>` |



## Connect to an running VM
🏗️

| Proxmox | KVM |
| :------ | :--- |
| `qm terminal <vmid>` | `virsh console <vm-name>` |

## remove a VM
| Proxmox VM | Proxmox LXC |KVM |
| :------ | :--- | :--- |
| `qm destroy <vmid>` | ?? | `virsh undefine <vm-name>` |

## get ressources of running vm

| Proxmox VM | Proxmox LXC |KVM |
| :------ | :--- | :--- |
| T.B.D.  | T.B.D. | `virsh dominfo <vm-name>` |
