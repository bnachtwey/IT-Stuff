#!/bin/bash

# Function to prompt for USB device
get_usb_device() 
{
  echo "Available USB devices:"
  lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"
  read -p "Enter the USB device (e.g., /dev/sdX): " usb_device
  if [[ ! -b "$usb_device" ]]
  then
    echo "Invalid device. Please try again."
    exit 1
  fi
}

# Function to validate encryption passphrase
get_encryption_passphrase() 
{
  while true
  do
    read -s -p "Enter encryption passphrase: " passphrase1
    echo
    read -s -p "Re-enter encryption passphrase: " passphrase2
    echo
    
    if [ "$passphrase1" == "$passphrase2" ]
    then
      echo "Passphrases match."
      break
    else
      echo "Passphrases do not match. Try again."
    fi
  done
}

# Step 1: Ask where to store the ISO file, with default suggestion "/tmp"
read -e -p "Enter the directory to store the ISO file [default: /tmp]: " iso_dir
iso_dir=${iso_dir:-/tmp}

# Validate if the directory exists or create it if necessary
if [[ ! -d "$iso_dir" ]]
then
  echo "$iso_dir does not exist. Creating it..."
  mkdir -p "$iso_dir" || { echo "Failed to create directory. Exiting."; exit 1; }
fi

# Define the full path for the ISO file
iso_path="$iso_dir/kali-linux.iso"

# Step 2: Download the latest Kali Linux ISO for x86-64
echo "Downloading the latest Kali Linux ISO..."
iso_url="https://cdimage.kali.org/kali-2025.1a/kali-linux-2025.1a-live-amd64.iso"
#iso_url="https://cdimage.kali.org/kali-weekly/kali-linux-weekly-amd64.iso"
wget -O "$iso_path" "$iso_url"

# Verify download success
if [ $? -ne 0 ]
then
  echo "Failed to download the ISO. Exiting."
  exit 1
fi

# Step 3: Select USB device and write the ISO to it
get_usb_device

echo "Writing ISO to USB device..."
sudo dd if="$iso_path" of="$usb_device" bs=4M status=progress conv=fsync

if [ $? -ne 0 ]
then
  echo "Failed to write ISO to USB. Exiting."
  exit 1
fi

# Step 4: Create a new partition for persistence storage on the USB drive
echo "Creating a new partition for persistence storage..."
sudo fdisk "$usb_device" <<EOF
n
p



w
EOF

# Get the new partition name (assumes it's the third partition)
persistent_partition="${usb_device}3"

# Step 5: Encrypt the new partition with LUKS and format it as ext4
#get_encryption_passphrase

echo "Encrypting the persistence partition..."
sudo cryptsetup --verbose --verify-passphrase luksFormat "$persistent_partition"

if [ $? -ne 0 ]
then
  echo "Failed to encrypt the partition. Exiting."
  exit 1
fi

echo "Opening encrypted partition..."
sudo cryptsetup luksOpen "$persistent_partition" my_usb

echo "Formatting encrypted partition as ext4..."
sudo mkfs.ext4 -L persistence /dev/mapper/my_usb

echo "Configuring persistence..."
sudo mkdir -p /mnt/my_usb
sudo mount /dev/mapper/my_usb /mnt/my_usb
echo "/ union" | sudo tee /mnt/my_usb/persistence.conf > /dev/null
sudo umount /mnt/my_usb

echo "Closing encrypted partition..."
sudo cryptsetup luksClose /dev/mapper/my_usb

echo "Kali Linux Live USB with encrypted persistence is ready!"