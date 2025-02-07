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

## Create VM and attach given disk
qm create ${VMID} --name ${NAME} --ide0 ${SYSTEM_DISK_STORAGE}:0,import-from=${SYSTEM_DISK_SOURCE},format=qcow2 --boot order=ide0

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
