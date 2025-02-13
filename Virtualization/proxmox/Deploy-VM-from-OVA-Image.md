# Deploying a new VM using an existing `ova` image
*Simple Example with no addtional disks or special settings* 

## 1 -- Extract the `.ova` file 
```bash
ovafile=<name of the ova file>
mkdir $(basename -a ${ovafile})
cd $(basename -a ${ovafile})
tar -xf ../${ovafile}
```

## 2 -- Creating a machine from values gathered from the `.ovf` file
- Number of CPUs
- Amount of Memory
- ???

```bash
#! /bin/bash

## Basic VM Info
VMID=111
NAME="TEST-VM"

## Memory Size
MEMORY=8
MEMORY_SIZE=$(( MEMORY * 1024 ))

## Processors
CORES=2
SOCKETS=2

## Network
INTERFACE="vmbr0"

## Create VM
qm create ${VMID} --name ${NAME}

## Setup Memory and CPUs
qm set ${VMID} --memory ${MEMORY_SIZE}
qm set ${VMID} --balloon ${MEMORY_SIZE}
qm set ${VMID} --cpu cputype=host
qm set ${VMID} --cores ${CORES} --sockets ${SOCKETS} --numa 1

## Network 
qm set ${VMID} --net0 virtio,bridge=${INTERFACE},queues=4

## Enable QEMU agent
qm set ${VMID} --agent enabled=1
## Set OS Type to Linux 2.6 (or newer)
qm set ${VMID} --ostype l26
```

## 3 -- convert vmdk disk and import into VM
```bash
#! /bin/bash

## Basic VM Info
VMID=111
NAME="TEST-VM"

## Hard Drive Size
SYSTEM_DISK_STORAGE="fastpool"    # Replace with your disk sto/satarage name
SYSTEM_DISK="/${SYSTEM_DISK_STORAGE}/images/${VMID}/vm-${VMID}-disk-0.qcow2"
SYSTEM_DISK_SOURCE="/satapool/SRC/TEST-VM/disk1.vmdk"

## Configure Storage
### SYSTEM DISK, just import given qcow2 file
qm disk import ${VMID} $SYSTEM_DISK_SOURCE $SYSTEM_DISK_STORAGE --format qcow2
qm set ${VMID} --scsi0 $SYSTEM_DISK_STORAGE:${VMID}/vm-${VMID}-disk-0.qcow2,iothread=1

### Set Boot order
qm set ${VMID} --boot order='scsi0'
```

---
## Further Readings / other guides
- unfortunately there's no official guide, but a *two sections*:
  - [*in the proxmox documentation*](https://pve.proxmox.com/pve-docs/chapter-qm.html#_import_ovf_ova_through_cli)
  - [*in the proxmox wiki*](https://pve.proxmox.com/wiki/Migrate_to_Proxmox_VE#Import_OVF)
- https://syncbricks.com/how-to-import-ova-to-proxmox/
