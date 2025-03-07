#!/bin/bash

# Copyright 2019 Cohesity Inc.
# ###############
# Copyright 2025 Bjørn Nachtwey @ Cristie Data GmbH
# - check added if selinux is not set to "Enforcing"
# - removed "--os-type" option as it's deprecated
# - if-statement fixed for boot disk given but no template, so do not ask for template again
# ###############

# Utilities
QEMU_IMG=""
VIRT_INSTALL=""
VIRSH=""
BC=""
RSYNC=""
SED=""
GREP=""

# Arguments
argName=""
argIface=""
argTemplatedisk=""
argBootdisk=""
argMetadisk=""
argMetasz=""
argDatadisk=""
argDatasz=""
argThin=false

# Global state variables
skipClone=0
missingUtils=""

function printArgs()
{
    echo -e "==[ Input arguments ]==\n"\
        "\t Cohesity VE VM name: $argName\n" \
        "\t Network-interface  : $argIface\n" \
        "\t Template boot-disk : $argTemplatedisk\n" \
        "\t Boot-disk          : $argBootdisk\n" \
        "\t Data disk, size    : $argDatadisk, "$argDatasz"GB\n" \
        "\t Metadata disk, size: $argMetadisk, "$argMetasz"GB\n" \
        "\t Thin provision disk: $argThin\n" \
        "\t Skip-cloning       : $skipClone"
}

function printUsage()
{
    echo -ne "\nUSAGE: $0 \n" \
        "\t\t -n <name of the Cohesity VE node to create>\n" \
        "\t\t -i <host network interface to use for VM's network interface>\n" \
        "\t\t -b <absolute path of Cohesity VE system-disk to set as VM's boot-disk>\n" \
        "\t\t -m <absolute path of metadata disk to create>\n" \
        "\t\t -x <size of metadata disk to create (in GBs, min 500)>\n" \
        "\t\t -d <absolute path of data disk to create>\n" \
        "\t\t -y <size of data disk to create (in GBs, min 1000)>\n" \
        "\t\t -t <(boolean) <true> if you want to create thin provisioned disk. Default <false> >\n" \
        "\t\t -c <(optional) absolute path of template Cohesity VE system-disk to clone>\n" \
        "\t\t -h <print this help message>\n"\
        "\t This script allows following two modes of provisioning the boot-disk.\n" \
        "\t 1) Cloning boot-disk from a template-disk.\n" \
        "\t    In this mode, this script will clone the template Cohesity VE system-disk \n"\
        "\t    to the Cohesity VE system-boot-disk path and use the latter as boot-disk\n" \
        "\t    for Cohesity VE VM.\n" \
        "\t    To use this mode, following two disks' paths must be specified:\n" \
        "\t    - Template Cohesity VE system-disk (-c), to clone the boot disk from.\n" \
        "\t    - Cohesity VE system-boot-disk (-b). This disk will be cloned from\n" \
        "\t      the template system-disk. The specified path must not exist.\n" \
        "\t 2) Import boot-disk.\n" \
        "\t    In this mode, the specified Cohesity VE system-boot-disk is imported directly\n" \
        "\t    and used by the Cohesity VE VM. This mode must not be used if the specified\n" \
        "\t    system-boot-disk is not intended to be modified by VM operations.\n" \
        "\t    To use this mode, only the Cohesity VE system-boot-disk (-b) must be provided\n" \
        "\t    and template Cohesity VE system-disk (-c) should not be specified.\n" \
        "\t Note on networking: \n" \
        "\t The Cohesity VE VMs support DHCP mode for ip assignment. This script creates\n" \
        "\t macvtap interface over the network interface provided as input (option -i).\n" \
        "\t Please ensure that a working DHCP server is reachable over the given interface\n"

}


function printUsageAndAbort()
{
    printUsage
    exit $1
}

function findUtilPath()
{
    utilName=$1
    out_var=$2
    local util=$( which $utilName )
    if [[ "$?" != "0" || "$util" == "" ]]; then
        missingUtils=$utilName" "$missingUtils
        return
    fi
    eval $out_var=$util
    return 0
}

function findUtils()
{
    findUtilPath 'qemu-img' QEMU_IMG
    findUtilPath 'virt-install' VIRT_INSTALL
    findUtilPath 'virsh' VIRSH
    findUtilPath 'bc' BC
    findUtilPath 'rsync' RSYNC
    findUtilPath 'sed' SED
    findUtilPath 'grep' GREP

    if [[ "$missingUtils" != "" ]]; then
        echo -e "Failed to find following utility/utilities.\n" \
            "Please install the appropriate package(s) and retry."
        for util in $missingUtils; do
            echo -e "\t - $util"
        done
        exit 301
    fi

    echo -e "Using following utils:\n" \
        "\t qemu-img     : $QEMU_IMG\n" \
        "\t virt-install : $VIRT_INSTALL\n" \
        "\t virsh        : $VIRSH\n" \
        "\t bc           : $BC\n" \
        "\t rsync        : $RSYNC\n" \
        "\t sed          : $SED\n" \
        "\t grep         : $GREP\n"
}

function prechkAndMaybeGetArgs()
{
    if [[ "x"$argName == "x" ]]; then
        read -p "Name of the Cohesity VE node to create: " argName
    fi
    if [[ "x"$argIface == "x" ]]; then
        read -p "Host network-interface: " argIface
    fi
    if [[ "x"$argTemplatedisk == "x"  &&  ! -f $argBootdisk ]]; then
        read -e -p "Cohesity VE image to clone from (optional, absolute-path): " argTemplatedisk
    fi
    if [[ "x"$argBootdisk == "x" ]]; then
        read -e -p "Cohesity VE system-disk to create (absolute-path): " argBootdisk
    fi
    if [[ "x"$argMetadisk == "x" ]]; then
        read -e -p "Metadata disk to create (absolute-path): " argMetadisk
    fi
    if [[ "x"$argMetasz == "x" ]]; then
        read -p "Size of metadata disk to create (GB): " argMetasz
    fi
    if [[ "x"$argDatadisk == "x" ]]; then
        read -e -p "Data disk to create (absolute-path): " argDatadisk
    fi
    if [[ "x"$argDatasz == "x" ]]; then
        read -p "Size of data disk to create (GB): " argDatasz
    fi
    if [[ "x"$argTemplatedisk == "x" ]]; then
        skipClone=1
    fi

    if [[ "x"$argThin == "x" ]]; then 
	read -e -p "Thin provision disk <true> OR  <false>: " argThin
    fi

    printArgs

    if [[ "x"$argName == "x" ]]; then
        echo -e "VM name not provided. Aborting...\n"
        printUsageAndAbort
    fi
    if [[ "x"$argIface == "x" ]]; then
        echo -e "Host network-interface not provided. Aborting...\n"
        printUsageAndAbort 2
    fi
    if [[ "x"$argBootdisk == "x" ]]; then
        echo -e "Cohesity VE system-disk path not provided. Aborting...\n"
        printUsageAndAbort 4
    fi
    if [[ "x"$argMetadisk == "x" ]]; then
        echo -e "Metadata disk path not provided. Aborting...\n"
        printUsageAndAbort 5
    fi
    if [[ "x"$argDatadisk == "x"  ]]; then
        echo -e "Data disk path not provided. Aborting...\n"
        printUsageAndAbort 6
    fi
    if [[ "x"$argMetasz == "x" ]]; then
        echo -e "Size of metadata disk not specified. Aborting...\n"
        printUsageAndAbort 7
    fi
    if [[ "x"$argDatasz == "x" ]]; then
        echo -e "Size of data disk not specified. Aborting...\n"
        printUsageAndAbort 8
    fi
    if [ "$argThin" != true ] && [ "$argThin" != false ]; then
        echo -e "Specify <true> or <false>  for thin provisioning. Aborting...\n"
        printUsageAndAbort 9
    fi
}

function validateIface()
{
    echo "Validating host network interface..."
    res=$( ip link show $argIface 2>&1 | grep UP )
    if [[ "$?" != "0" ]]; then
        echo "Specified network-interface $argIface is not valid. Aborting..."
        exit 10
    fi
    if [[ "$res" == "" ]]; then
        echo "Specified network-interface $argIface is not up. Aborting..."
        exit 11
    fi
}

function validateDisks()
{
    kMinMetaSz=500   # 500GB
    kMinDataSz=1000  # 1000GB
    kMaxData2MetaSzRatio=21

    if [[ $skipClone -eq 0 ]]; then
        echo "Validating template system-disk..."
        if [[ ! -f $argTemplatedisk ]]; then
            echo -e "Template Cohesity VE system-disk file does not "\
                "exist (path: $argTemplatedisk). Aborting...\n"
            exit 20
        fi

        echo "Validating system-boot-disk..."
        if [[ -e $argBootdisk ]]; then
            echo -e "Cohesity VE system-disk file exists (path: " \
                "$argBootdisk). Aborting...\n"
            exit 21
        fi
    else
        echo "Validating system-boot-disk..."
        if [[ ! -f $argBootdisk ]]; then
            echo -e "Cohesity VE system-boot-disk file does not exist "\
               " (path: $argBootdisk). Aborting...\n"
            exit 22
        fi
    fi

    echo "Validating Data to Metadata size ratio..."
    ratio=$( echo "$argDatasz/$argMetasz" | bc )
    echo "res: $?, ratio $ratio"
    if [[ "$?" != "0" ]]; then
        echo "Failed to compute data to metadata size ratio. Aborting...\n"
        exit 23
    fi
    if [[ $ratio -gt $kMaxData2MetaSzRatio ]]; then
        echo -e "\n Data to metadata size ratio ("$ratio") exceeds "\
            "threshold value $kMaxData2MetaSzRatio.\n"\
            "Please choose a smaller data-disk size or \n" \
            "a larger metadata disk size for optimum performance.\n"
           exit 24
     fi

    echo "Validating metadata-disk..."
    if [[ -e $argMetadisk ]]; then
        echo -e "Metadata disk already exists " \
            "(path: $argMetadisk). Aborting...\n"
        exit 25
    fi
    if [[ $argMetasz -lt $kMinMetaSz ]]; then
        echo -e "Size of metadata disk ("$argMetasz"GB) less than " \
            "minimum supported size ("$kMinMetaSz"GB). Aborting...\n"
        exit 26
    fi

    echo "Validating data-disk..."
    if [[ -e $argDatadisk ]]; then
        echo -e "Data disk already exists " \
            "(path: $argDatadisk). Aborting...\n"
        exit 27
    fi
    if [[ $argDatasz -lt $kMinDataSz ]]; then
        echo -e "Size of data disk ("$argDatasz"GB) less than " \
            "minimum supported size ("$kMinDataSz"GB). Aborting...\n"
        exit 28
    fi
}

function cleanupAtErr()
{
    if [[ -e $argMetadisk ]]; then
        echo "Removing newly create metadata disk $argMetadisk"
        rm -rf $argMetadisk
    fi
    if [[ -e $argDatadisk ]]; then
        echo "Removing newly create datadata disk $argDatadisk"
        rm -rf $argDatadisk
    fi
    exit $1
}


function maybeCloneDisk()
{
    srcfile=$1
    dstfile=$2

    if [[ $skipClone -eq 1 ]]; then
        echo -e "Skipped cloning template system-disk $argTemplatedisk " \
            "to boot-disk $argBootdisk"
        return 0
    fi

    dstdir=$( dirname $dstfile )
    if [[ ! -d $dstdir ]]; then
        mkdir -p $dstdir
        if [[ "$?" != "0" ]]; then
            echo "Failed to create parent-dir for boot-disk \
                $argBootdisk. Aborting..."
            cleanupAtErr 30
        fi
    fi

    echo "Cloning disk $srcfile to $dstfile"
    $RSYNC -av --progress $srcfile $dstfile
    if [[ "$?" != "0" ]]; then
        echo "Failed to clone $srcfile to $dstdir, err: $?. Aborting..."
        cleanupAtErr 31
    fi
}

function createDisk()
{
    FORMAT="qcow2"

    path=$1
    sz=$2
    pathdir=$( dirname $path )
    if [[ ! -d $pathdir ]]; then
        mkdir -p $pathdir
        if [[ "$?" != "0" ]]; then
            echo "Failed to create parent-dir for disk $path. Aborting..."
            cleanupAtErr 40
        fi
    fi

    echo -e "\nCreating $FORMAT disk of size "$sz"GB at $path\n"

    if [ "$argThin" = false ]
    then
        $QEMU_IMG create -f $FORMAT -o preallocation=full $path $sz"G"
    else
        $QEMU_IMG create -f $FORMAT $path $sz"G"
    fi

    if [[ "$?" != "0" ]]; then
        echo "Failed to create $FORMAT disk of size "$sz"GB at $path. Aborting"
        cleanupAtErr 41
    fi
    return 0
}

# Create graphics-vnc parameter for virt-install.
# Extract the IP address of the user-specified network-interface
# and configure the qemu-kvm's VNC server to listen only on that.
function makeParamVnc()
{
  iface=$1
  paramVnc=$2
  ifaceIP=$( ip address show $iface | $GREP -w inet | head -1 | \
      $SED -e 's/\ *inet \([^\/]*\)\/.*/\1/g' )
  if [[ "$?" != "0" || "$ifaceIP" == "" ]]; then
      eval paramVnc=""
      return
  fi
  eval paramVnc="--graphics=vnc,listen=$ifaceIP"
}

function installVM()
{
    paramMemory=32768  # ram - 32GB
    paramCpu=4         # cpu - 4 vCPU
    paramDisk="format=qcow2,bus=scsi,cache=writethrough,discard=unmap,address.type=drive"
    paramNet="type=direct,source="$argIface",source_mode=bridge,model=virtio,trustGuestRxFilters=yes"
    paramBoot="--boot=hd"
    paramCpuModel="--cpu host"
    paramMisc="--noautoconsole"
    qemuUri="qemu:///system"
    vncAvailable=0

    makeParamVnc $argIface paramVnc
    if [[ "$paramVnc" != "" ]]; then
        vncAvailable=1
    fi

    cmd="$VIRT_INSTALL \
        --name $argName \
        --ram=$paramMemory  \
        --vcpus=$paramCpu \
        --os-variant=rhel7.9 \
        --controller type=scsi,model=virtio-scsi,index=0 \
        --controller type=scsi,model=virtio-scsi,index=1 \
        --controller type=scsi,model=virtio-scsi,index=2 \
        --import \
        --disk path=$argBootdisk","$paramDisk",address.controller=0" \
        --network $paramNet \
        $paramCpuModel \
        $paramBoot \
        $paramMisc \
        $paramVnc \
        --disk $argMetadisk","$paramDisk",address.controller=1" \
        --disk $argDatadisk","$paramDisk",address.controller=2""
    
    if [[ "x"$DEBUG != "x" ]]; then
      echo -e "\nrunning cmd: $cmd\n"
    fi
    $cmd
    if [[ "$?" != 0 ]]; then
        echo "Failed to create VM $argName"
        cleanupAtErr 50
    fi

    if [[ $vncAvailable -eq 1 ]]; then
        vncPort=$( $VIRSH -c $qemuUri dumpxml $argName | \
            $GREP graphics\ type | \
            $SED -e "s/.*port=.\([0-9]*\)'.*/\1/g" )
        if [[ "$?" != "0" ]]; then
            echo "Failed to get vncport for newly created VM"
            vncAvailable=0
        else
            vncAvailable=1
        fi
    fi

    if [[ $vncAvailable -eq 1 ]]; then
        echo -e "Cohesity VE VM is now provisioned. It may be accessed\n" \
            "using virsh console $argName or via qemu-KVM vnc service over port $vncPort \n" \
            "For vnc connectivity, please ensure that iptables,firewalld etc\n" \
            "are configured to allow traffic over port $vncPort.\n" \
            "If not, the VM may need to stopped and restarted once\n" \
            "appropriate changes have been made to allow connectivity over the port".
    else
        echo -e "Cohesity VE VM is now provisioned." \
          "Please use virsh console $argName to access it"
    fi
}
# Check if being run as root, bail if not...
if [[ $EUID -ne 0 || $(id -u) -ne 0 ]]; then
  echo -e "Please run this script as root\n\n"
  printUsageAndAbort
  exit 100
fi

# check selinux settings as script fails if Enforcing is set (at least on AlmaLinux 9.5)
if [[ "$(getenforce)" == "Enforcing" ]]; then
  echo "Please disable selinux"
  echo "e.g. by"
  echo "         setenforce 0"
  echo
  exit 101;
fi

OPTIND=1
while getopts "n:i:c:b:d:m:x:y:t:h" opt; do
    case ${opt} in
        n )
            argName=$OPTARG
            ;;
        i )
            argIface=$OPTARG
            ;;
        c)
            argTemplatedisk=$OPTARG
            ;;
        b )
            argBootdisk=$OPTARG
            ;;
        d )
            argDatadisk=$OPTARG
            ;;
        m )
            argMetadisk=$OPTARG
            ;;
        x )
            argMetasz=$OPTARG
            ;;
        y )
            argDatasz=$OPTARG
            ;;
        t )
            argThin=$OPTARG
            ;;
        h )
          printUsageAndAbort 0
          ;;
    esac
done
# If no options are specified, print usage.
if [[ $OPTIND -eq 1 ]]; then
  printUsage
  echo ""
fi

findUtils
prechkAndMaybeGetArgs
validateIface
validateDisks

maybeCloneDisk $argTemplatedisk $argBootdisk
createDisk $argMetadisk $argMetasz
createDisk $argDatadisk $argDatasz

installVM
