# Comparing CLI commands for plain KVM and PVE
Although Proxmox uses KVM as technique, not only the GUI is different, but also some commands.

I'm going to collect at least those I'm using :-)

> [!INFO]
> by now (Feburary 2025) I compare
> - *Proxmox 8.3.2 on Debian 12 / Bookwork*, Kernel `6.8.12-5-pve`
> - *Rocky Linux 9.5 (Blue Onyx)*, Kernel `5.14.0-503.21.1.el9_5.x86_64`

## Gather Information
### Get list of VMs
#### Proxmox
```bash
# qm list
      VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID
       102 Rocky                stopped    4096              32.00 0
       104 VM 104               stopped    24000            128.00 0
       190 W25S                 running    4096              60.00 277805
       191 BNW-W25S-PG          running    8192              90.00 2328921
       831 PVET1                running    16384             32.00 1598834
       832 PVET2                running    16384             32.00 1638727
       833 PVET3                running    16384             32.00 1600424
       834 PBS                  running    4096              32.00 3031
```
### RHEL-KVM 
```bash
# virsh list --all
 Id   Name       State
---------------------------
 1    TEST-VM1   running
 -    TEST-VM2   shut off
```

### Get list of storage pools
#### Proxmox
```bash
# pvesm status
Name            Type     Status           Total            Used       Available        %
fastpool         dir     active      1934547328       136394752      1798152576    7.05%
isopool          dir     active       172714880       108200448        64514432   62.65%
local            dir     active        81435064        65118236        12134200   79.96%
saspool          dir     active        81435064        65118236        12134200   79.96%
satapool         dir     active     17414445952       350865536     17063580416    2.01%
```
### RHEL-KVM 
```bash
# for p in $(virsh pool-list | tail -n +3 | awk '{print $1}'); do virsh pool-info $p; echo "---"; done
Name:           default
UUID:           b7d7cb0c-46d7-44cd-ac16-1808006fe358
State:          running
Persistent:     yes
Autostart:      yes
Capacity:       1.50 TiB
Allocation:     13.33 GiB
Available:      1.49 TiB

---
```
or
```bash
#!/bin/bash

# Get all pool names
pools=$(virsh pool-list --all --name)

# Print header
printf "%-20s %-10s %-12s %-12s %-12s %-12s\n" "Name" "State" "Capacity" "Allocation" "Available" "Autostart"

# Loop through each pool and print info
for pool in $pools; do
    info=$(virsh pool-info "$pool")
    name=$(echo "$info" | awk '/^Name:/ {print $2}')
    state=$(echo "$info" | awk '/^State:/ {print $2}')
    capacity=$(echo "$info" | awk '/^Capacity:/ {print $2, $3}')
    allocation=$(echo "$info" | awk '/^Allocation:/ {print $2, $3}')
    available=$(echo "$info" | awk '/^Available:/ {print $2, $3}')
    autostart=$(echo "$info" | awk '/^Autostart:/ {print $2}')
    
    printf "%-20s %-10s %-12s %-12s %-12s %-12s\n" "$name" "$state" "$capacity" "$allocation" "$available" "$autostart"
done

Name                 State      Capacity     Allocation   Available    Autostart
default              running    1.50 TiB     13.33 GiB    1.49 TiB     yes
```
