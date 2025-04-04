#! /bin/bash

# ##########################################################
# Changelog
# 2025-04-04  0.0.1  initial coding using fixed values
# ##########################################################

## initial settings (to be edited)
VMID=851                        # VMid
VMNAME="OnTap-9.16-Simulator"   # Set VM name
MEMORY=6144                     # 6144 MB Memory
VCPU=2                          # 2 vCPUs
MIFACE=vmbr0                    # Management Interface
DIFACE=vmbr0                    # DataInterface
STORAGE=fastpool                # storage class for disks

echo "look for .ova file and untar it"
for ova in $(ls *.ova)
do
        tar xvf ${ova}
done

## rollout the VM
echo "roll out VM .."
qm create ${VMID} --name ${VMNAME}

qm set  ${VMID} --cpu           cputype=host
qm set  ${VMID} --cores         ${VCPU}
qm set  ${VMID} --memory        ${MEMORY}
qm set  ${VMID} --net0          e1000,bridge=${MIFACE},firewall=0
qm set  ${VMID} --net1          e1000,bridge=${MIFACE},firewall=0
qm set  ${VMID} --net2          e1000,bridge=${DIFACE},firewall=0
qm set  ${VMID} --net3          e1000,bridge=${DIFACE},firewall=0

DID=0
for DISK in $(ls *.vmdk)
do
        qm disk import ${VMID} ${DISK} ${STORAGE} --target-disk ide${DID}
        ((++DID))               # increase disk number
done

qm set  ${VMID} --boot          order=ide0
qm set  ${VMID} --agent         enabled=1
