# Notes on HomeAssistant

## Install on Proxmox
- prepare a machine<br>
  ```bash
  #! /bin/bash
  
  ############### PREPARE: CUSTOMIZE CONFIGURATION ###############
  ################################################################

  ## Basic VM Info
  VMID=411
  NAME="HAOS-T"
  
  ## Memory Size
  MEMORY_GB=4
  MEMORY_SIZE=$(( MEMORY_GB * 1024 ))
 
  ## Processors
  CORES=2
  SOCKETS=1
  CPUTYPE="host"
  
  ## Network
  INTERFACE="vmbr0"
  MAC_ADR="BC:24:11:59:B8:E5"

  ## Disk settings
  DISKPATH="/pve/fastpool/images/${VMID}"
  DISKNAME="${DISKPATH}/vm-${VMID}-disk-0.qcow2"
  
  
  ################# GO : DEPLOY VM #################
  ##################################################
  
  ## Create VM and attach given disk
  qm create ${VMID} --name ${NAME}
 
  ## Setup Memory and CPUs
  qm set ${VMID} --memory ${MEMORY_SIZE}
  qm set ${VMID} --balloon ${MEMORY_SIZE}
  qm set ${VMID} --cpu cputype=${CPUTYPE}
  qm set ${VMID} --cores ${CORES} --sockets ${SOCKETS} --numa 1
  
  ## Network 
  qm set ${VMID} --net0 virtio=${MAC_ADR},bridge=${INTERFACE},queues=4

  ## Enable QEMU agent
  qm set ${VMID} --agent enabled=1
  ## Set OS Type to Linux 2.6 (or newer)
  qm set ${VMID} --ostype l26

  ## prepare DISK settings
  qm set ${VMID} --scsihw virtio-scsi-single
  qm set ${VMID} --bios ovmf

  if [[ ! -d ${DISKPATH} ]]
  then
    mkdir ${DISKPATH}
  fi

  curl -o ${DISKNAME}.xz https://github.com/home-assistant/operating-system/releases/download/14.2/haos_ova-14.2.qcow2.xz

  cd ${DISKPATH}
  xz -d ${DISKNAME}.xz

  # edit machines config file, add line like
  echo "scsi0: fastpool:${VMID}/vm-${VMID}-disk-0.qcow2,iothread=1,size=32G" >> /etc/pve/qemu-server/${VMID}.conf

  # rescan disks to reset it's size
  qm disk rescan --vmid ${VMID}

  ```

- start VM

- Warings:
  ```bash
  WARN: no efidisk configured! Using temporary efivars disk.
  ```
