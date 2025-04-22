#! /bin/bash

############### PREPARE ##############
######################################

## Basic VM Info
VMID=861
NAME="Coh1n-T"

## Memory Size
MEMORY_GB=32
MEMORY_SIZE=$(( MEMORY_GB * 1024 ))

## Processors
CORES=2
SOCKETS=2
CPUTYPE="host"

## Network
INTERFACE="vmbr0"
MAC_ADR="BC:24:11:9B:43:2F"

## Disk settings
DISKPATH="/satapool/pve/images/${VMID}"
ODISKNAME="vm-${VMID}-disk-OS.qcow2"
MDISKNAME="vm-${VMID}-disk-Meta.qcow2"
DDISKNAME="vm-${VMID}-disk-Data.qcow2"
OSRCDISK=/satapool/SRC/DP/cohesity-kvm-robo-7.1.2_u3_release-20241231_bb47fe77.qcow2


################# GO #################
######################################

## Create VM and attach given disk
qm create ${VMID} --name ${NAME}

## Setup Memory and CPUs
qm set ${VMID} --memory ${MEMORY_SIZE}
qm set ${VMID} --balloon ${MEMORY_SIZE}
qm set ${VMID} --cpu cputype=${CPUTYPE}
qm set ${VMID} --cores ${CORES} --sockets ${SOCKETS} --numa 1

## Network 
qm set ${VMID} --net0 virtio=${MAC_ADR},bridge=${INTERFACE}

## Enable QEMU agent
qm set ${VMID} --agent enabled=1
## Set OS Type to Linux 2.6 (or newer)
qm set ${VMID} --ostype l26

## prepare DISK settings
qm set ${VMID} --scsihw virtio-scsi-single
qm set ${VMID} --bios seabios
qm set ${VMID} --boot order:scsi0

mkdir ${DISKPATH}

cp ${OSRCDISK} ${DISKPATH}/${ODISKNAME}
qemu-img create -f qcow2 ${DISKPATH}/${MDISKNAME} 512G
qemu-img create -f qcow2 ${DISKPATH}/${DDISKNAME} 2024G

# edit machines config file, add line like
echo "scsi0: satapool2:${VMID}/${ODISKNAME},iothread=1" >> /etc/pve/qemu-server/${VMID}.conf
echo "scsi1: satapool2:${VMID}/${MDISKNAME},iothread=1" >> /etc/pve/qemu-server/${VMID}.conf
echo "scsi2: satapool2:${VMID}/${DDISKNAME},iothread=1" >> /etc/pve/qemu-server/${VMID}.conf


