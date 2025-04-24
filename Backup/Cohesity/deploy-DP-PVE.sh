#! /bin/bash

# changelog
# date          version	 remark
# 2025-04-22    0.1		initial coding 
# 2025-04-23    0.2		some additions for checking requirements
#                       some minor fixes
##############################################################################
#
#        deploy-DP.sh
#        
#        script for deploying {Cohesity | IBM Defender} Data Protect VM on Proxmox
#
#  (C) 2025 		 Bjørn Nachtwey himself
#                    mailto:code@bjoernsoe.net
#   
#   Thanks to my company Cristie Data GmbH for the opportunity to do this coding
#	see https://www.cristie.de
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
##############################################################################


#############################################
############### FUNCTIONS USED ##############
#############################################

# check for needed tools
PVESM=""
QEMU_IMG=""
QM=""
JQ=""
RSYNC=""
SED=""
GREP=""

function findUtilPath()
{
    utilName=$1
    out_var=$2
    local util=$( which $utilName )
    if [[ "$?" != "0" || "$util" == "" ]]
	then
        missingUtils=$utilName" "$missingUtils
        return
    fi
    eval $out_var=$util
    return 0
}

function findUtils()
{
    findUtilPath 'pvesm' PVESM
	findUtilPath 'qemu-img' QEMU_IMG
    findUtilPath 'qm' QM
    findUtilPath 'jq' JQ
    findUtilPath 'rsync' RSYNC
    findUtilPath 'sed' SED
    findUtilPath 'grep' GREP

    if [[ "$missingUtils" != "" ]]
	then
        echo -e "Failed to find following utility/utilities.\n" \
            "Please install the appropriate package(s) and retry."
        for util in $missingUtils
		do
            echo -e "\t - $util"
        done
        exit 301
    fi

    echo -e "Using following utils:\n" \
        "\t pvesm        : $PVESM\n" \
		"\t qemu-img     : $QEMU_IMG\n" \
		"\t qm           : $QM\n" \
        "\t jq           : $JQ\n" \
        "\t rsync        : $RSYNC\n" \
        "\t sed          : $SED\n" \
        "\t grep         : $GREP\n"
}

###############################################
############### PREPARE ROLL-OUT ##############
###############################################
# Check if needed utilities are installed
findUtils


# Set basic VM infos
## Get highest already deployed VMs
next_vmid=$(($(qm list | awk 'END{print $1}') + 1))

## Ask for VMID with suggesting the next number available
read -p "Enter VMID [${next_vmid}]: " -e -i "${next_vmid}" vmid
VMID="${vmid:-${next_vmid}}"

## Ask for name with VMID-based suggestion
read -p "Enter VM name [VM${vmid}]: " -e -i "VM${vmid}" VMNAME
VMNAME="${VMNAME:-VM${vmid}}"

## Set Memory Size
read -p "Enter memory in GB [32]: " -e -i "32" MEMORY_GB
MEMORY_GB="${MEMORY_GB:-32}"
MEMORY_SIZE=$(( MEMORY_GB * 1024 ))

## Set Number of Processors (Sockets & Cores)
read -p "Enter number of cores [2]: " -e -i "2" CORES
CORES="${CORES:-32}"

read -p "Enter number of sockets [2]: " -e -i "2" SOCKETS
SOCKETS="${CORES:-32}"

## Set CPU type, suggest type based on actual system
## get capability of actual CPU
if grep -qw 'avx512' /proc/cpuinfo; then
    CPU=x86-64-v4
elif grep -qw 'avx2' /proc/cpuinfo; then
    CPU=x86-64-v3
elif grep -qw 'avx' /proc/cpuinfo; then
    CPU=x86-64-v2
else
    CPU=x86-64-v1
fi

echo "Set CPU type"
echo "If you're using a proxmox cluster chose minimum requirements met by all nodes"
read -p "Enter CPUTYPE [${CPU}]: " -e -i "$CPU" CPUTYPE
CPUTYPE="${CPUTYPE:-${CPUTYPE}}"

# Network

## Get active non-bridge interfaces
mapfile -t interfaces < <(
    ip -o link show |
    awk -F': ' '!/bridge|NO-CARRIER|DOWN|fwbr|fwpr|tap/ && $2 != "lo" {print $2}'
)

## Check if any interfaces found
if [[ ${#interfaces[@]} -eq 0 ]]; then
    echo "No active network interfaces found" >&2
    exit 1
fi

## Create selection menu
PS3="Select network interface: "
select INTERFACE in "${interfaces[@]}"; do
    if [[ -n "$INTERFACE" ]]; then
        break
    else
        echo "Invalid selection" >&2
    fi
done

MAC_ADR="BC:24:11:9B:43:2F"

# Disk settings

## Get all storage pools eligable for "images"
mapfile -t pools < <(pvesm status --content images | tail -n +2 | grep active | awk '{print $1}')

## Function to display selection menu for storage pools
select_pool() {
    local prompt="$1"
    PS3="$prompt: "
    select pool in "${pools[@]}"; do
        if [[ -n "$pool" ]]; then
            echo "$pool"
            break
        else
            echo "Invalid selection" >&2
        fi
    done
}
opool=$(select_pool "Choose storage pool for OS disk ")
mpool=$(select_pool "Choose storage pool for Meta data disk ")
while true; do
    read -p "Enter Size of meta data disk in GB [at least 512]: " -e -i "512" MDISKSIZE
    MDISKSIZE=${MDISKSIZE:-512}
    
    if [[ $MDISKSIZE -ge 512 ]]; then
        break
    else
        echo "Error: Must be ≥ 512" >&2
    fi
done
dpool=$(select_pool "Choose storage pool for Mass data disk ")
while true; do
    read -p "Enter Size of meta data disk in GB [at least 1024]: " -e -i "1024" DDISKSIZE
    DDISKSIZE=${DDISKSIZE:-1024}
    
    if [[ $DDISKSIZE -ge 1024 ]]; then
        break
    else
        echo "Error: Must be ≥ 1024" >&2
    fi
done

ODISKNAME="vm-${VMID}-disk-OS.qcow2"
ODISKPATH=$(pvesh get /storage --output-format json  | jq ".[] | select(.storage==\"${opool}\") | .path")/images/${VMID}
ODISKPATH="${ODISKPATH//\"/}"
MDISKNAME="vm-${VMID}-disk-Meta.qcow2"
MDISKPATH=$(pvesh get /storage --output-format json  | jq ".[] | select(.storage==\"${mpool}\") | .path")/images/${VMID}
MDISKPATH="${MDISKPATH//\"/}"
DDISKNAME="vm-${VMID}-disk-Data.qcow2"
DDISKPATH=$(pvesh get /storage --output-format json  | jq ".[] | select(.storage==\"${dpool}\") | .path")/images/${VMID}
DDISKPATH="${ODISKPATH//\"/}"

if [[ ! -d ${ODISKPATH} ]]; then mkdir -p ${ODISKPATH}; fi
if [[ ! -d ${MDISKPATH} ]]; then mkdir -p ${MDISKPATH}; fi
if [[ ! -d ${DDISKPATH} ]]; then mkdir -p ${DDISKPATH}; fi

##echo ${opool} : ${ODISKPATH}/${ODISKNAME}
##echo ${mpool} : ${MDISKPATH}/${MDISKNAME}
##echo ${dpool} : ${DDISKPATH}/${DDISKNAME}

##exit;
OSRCDISK=/satapool/SRC/DP/cohesity-kvm-robo-7.1.2_u3_release-20241231_bb47fe77.qcow2


##################################################
################# GO & DO ROLLOUT#################
##################################################

## Create VM and attach given disk
qm create ${VMID} --name ${VMNAME}

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

## copy OS DISK
cp ${OSRCDISK} ${ODISKPATH}/${ODISKNAME}
ODISKSIZE=$(($(ls -l ${OSRCDISK} | awk '{print $5'})/1073741824 + 1))

## create further disks
qemu-img create -f qcow2 ${MDISKPATH}/${MDISKNAME} ${MDISKSIZE}G
qemu-img create -f qcow2 ${DDISKPATH}/${DDISKNAME} ${DDISKSIZE}G

# edit machines config file, add line like
echo "scsi0: ${opool}:${VMID}/${ODISKNAME},iothread=1,size=${ODISKSIZE}" >> /etc/pve/qemu-server/${VMID}.conf
echo "scsi1: ${mpool}:${VMID}/${MDISKNAME},iothread=1,size=${MDISKSIZE}" >> /etc/pve/qemu-server/${VMID}.conf
echo "scsi2: ${dpool}:${VMID}/${DDISKNAME},iothread=1,size=${DDISKSIZE}" >> /etc/pve/qemu-server/${VMID}.conf

qm set ${VMID} --boot order=scsi0
