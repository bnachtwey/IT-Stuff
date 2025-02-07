#! /bin/bash

############### PREPARE ##############
######################################

## Basic VM Info
VMID=850
NAME="TEST1"

## Memory Size
MEMORY_GB=8
MEMORY_SIZE=$(( MEMORY_GB * 1024 ))

## Processors
CORES=2
SOCKETS=2
CPUTYPE="host"

## Network
INTERFACE="vmbr0"

## DISK Settings
SYSTEM_DISK_STORAGE="fastpool"    # Replace with your disk sto/satarage name
SYSTEM_DISK_SOURCE="/satapool/SRC/noble-server/noble-server.vmdk"

################# GO #################
######################################

## Create VM
qm create ${VMID} --name ${NAME}

## Setup Memory and CPUs
qm set ${VMID} --memory ${MEMORY_SIZE}
qm set ${VMID} --balloon ${MEMORY_SIZE}
qm set ${VMID} --cpu cputype=${CPUTYPE}
qm set ${VMID} --cores ${CORES} --sockets ${SOCKETS} --numa 1

## Network 
qm set ${VMID} --net0 virtio,bridge=${INTERFACE},queues=4

## Enable QEMU agent
qm set ${VMID} --agent enabled=1
## Set OS Type to Linux 2.6 (or newer)
qm set ${VMID} --ostype l26

## Hard Drive Size
#DATA_DISK_STORAGE="satapool"
#DATA_DISK_SIZE="1024G"

## Configure Storage
### SYSTEM DISK, just import given qcow2 file
SYSTEM_DISK="/${SYSTEM_DISK_STORAGE}/images/${VMID}/vm-${VMID}-disk-0.qcow2"
qm disk import ${VMID} $SYSTEM_DISK_SOURCE $SYSTEM_DISK_STORAGE --format qcow2
qm set ${VMID} --ide0 $SYSTEM_DISK_STORAGE:${VMID}/vm-${VMID}-disk-0.qcow2

### DATA DISK, create new one and attach
#pvesm alloc ${DATA_DISK_STORAGE} ${VMID} vm-${VMID}-disk-1.qcow2 ${DATA_DISK_SIZE} --format qcow2
#qm set ${VMID} --ide1 ${DATA_DISK_STORAGE}:${VMID}/vm-${VMID}-disk-2.qcow2

### Set Boot order
qm set ${VMID} --boot order='ide0'
