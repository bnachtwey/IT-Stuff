#!/bin/bash

# Step 1: Ask where the ISO files are stored, suggest "/local/ISO"
read -e -p "Enter directory where ISO files are stored [default: /local/ISO]: " iso_dir
iso_dir=${iso_dir:-/local/ISO}

# Ensure directory exists
if [[ ! -d "$iso_dir" ]]; then
  echo "Directory $iso_dir does not exist."
  exit 1
fi

# Step 2: Look up for ISO files containing "kali" in their name
mapfile -t iso_files < <(find "$iso_dir" -type f -iname '*kali*.iso')

if [[ ${#iso_files[@]} -eq 0 ]]; then
  echo "No Kali ISO files found in $iso_dir."
  exit 1
fi

# Step 3: Make a selection list
echo "Select a Kali ISO file to use:"
select iso_path in "${iso_files[@]}"; do
  if [[ -n "$iso_path" ]]; then
    echo "Selected: $iso_path"
    break
  else
    echo "Invalid selection."
  fi
done

# Step 4: Ask for USB device
echo "Available USB devices:"
lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"
read -p "Enter the USB device (e.g., /dev/sdX): " usb_device
if [[ ! -b "$usb_device" ]]; then
  echo "Invalid device. Please try again."
  exit 1
fi

# Step 5: Write selected ISO to USB
echo "Writing ISO to USB device..."
sudo dd if="$iso_path" of="$usb_device" bs=4M status=progress conv=fsync

if [ $? -ne 0 ]; then
  echo "Failed to write ISO to USB. Exiting."
  exit 1
fi

# Step 6: Create another partition for encrypted persistent storage
echo "Creating a new partition for persistence storage..."
sudo fdisk "$usb_device" <<EOF
n
p



w
EOF

persistent_partition="${usb_device}3"

# Step 7: Encrypt the new partition with LUKS and format it as ext4
echo "Encrypting the persistence partition..."
sudo cryptsetup --verbose --verify-passphrase luksFormat "$persistent_partition"

if [ $? -ne 0 ]; then
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
