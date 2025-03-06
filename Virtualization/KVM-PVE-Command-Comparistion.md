# Comparing CLI commands for plain KVM and PVE
Although Proxmox uses KVM as technique, not only the GUI is different, but also some commands.

I'm going to collect at least those I'm using :-)

> [!INFO]
> by now (Feburary 2025) I compare
> - *Proxmox 8.3.2 on Debian 12 / Bookwork*, Kernel `6.8.12-5-pve`
> - *Rocky Linux 9.5 (Blue Onyx)*, Kernel `5.14.0-503.21.1.el9_5.x86_64`

## Gather Information
### Get list of VMs
| Proxmox | KVM |
| :------ | :--- |
| `qm list` | `virsh list`|

### Get list of storage pools
| Proxmox | KVM |
| :------ | :--- |
| `pvesh status` | no simple command :-( -- see [examples](./KVE-PVE-Command-Examples.md)| 

## Shutdown - Start - HardStop - Suspend - Resume VMs
### Shutting down a certain VM
| Proxmox | KVM |
| :------ | :--- |
| `qm shutdown <vmid>` | `virsh start <vm-name>` |

### Start a certain VM
| Proxmox | KVM |
| :------ | :--- |
| `qm start <vmid>` | `virsh shutdown <vm-name>` |

### (Hard) Stopping a certain VM
| Proxmox | KVM |
| :------ | :--- |
| `qm stop <vmid>` | `virsh destroy <vm-name>` |

### (Hard) Reseting a certain VM
| Proxmox | KVM |
| :------ | :--- |
| `qm reset <vmid>` | `virsh reboot <vm-name>` |
| | `virsh destroy <vm-name> && virsh start <vm-name>` |

### Suspend a certain VM
*ordinary suspend*, just freerzing the VM
| Proxmox | KVM |
| :------ | :--- |
| `qm suspend <vmid>` | `virsh suspend <vm-name>` |

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
