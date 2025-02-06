# Comparing CLI commands for plain KVM and PVE
Although Proxmox uses KVM as technique, not only the GUI is different, but also some commands.

I'm going to collect at least those I'm using :-)

> [!INFO]
> by now (Feburary 2025) I compare
> - *Proxmox 8.3.2 on Debian 12 / Bookwork*, Kernel `6.8.12-5-pve`
> - *Rocky Linux 9.5 (Blue Onyx)*, Kernel `5.14.0-503.21.1.el9_5.x86_64`

## Gather Infos
### Get list of VMs
#### Proxmox
```bash
```
KVM 
```bash
# virsh list --all
 Id   Name       State
---------------------------
 1    TEST-VM1   running
 -    TEST-VM2   shut off
```
