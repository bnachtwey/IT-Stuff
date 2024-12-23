#! /bin/bash

#
# Heavily inspired by https://github.com/dnschneid/crouton/wiki/VirtualBox-udev-integration
#

echo "Updating the locatedb"
updatedb


vbox_usbnode_path=$(locate VBoxCreateUSBNode.sh 2> /dev/null | head -n 1)
if [[ -z $vbox_usbnode_path ]]; then
    echo Warning: VBoxCreateUSBNode.sh file has not been found.
    exit 1
fi

#chmod 755 $vbox_usbnode_path
#chown root:root $vbox_usbnode_path

vboxusers_gid=$(getent group vboxusers | awk -F: '{printf "%d\n", $3}')

vbox_rules="SUBSYSTEM==\"usb_device\", ACTION==\"add\", RUN+=\"$vbox_usbnode_path \$major \$minor \$attr{bDeviceClass} $vboxusers_gid\"
SUBSYSTEM==\"usb\", ACTION==\"add\", ENV{DEVTYPE}==\"usb_device\", RUN+=\"$vbox_usbnode_path \$major \$minor \$attr{bDeviceClass} $vboxusers_gid\"
SUBSYSTEM==\"usb_device\", ACTION==\"remove\", RUN+=\"$vbox_usbnode_path --remove \$major \$minor\"
SUBSYSTEM==\"usb\", ACTION==\"remove\", ENV{DEVTYPE}==\"usb_device\", RUN+=\"$vbox_usbnode_path --remove \$major \$minor\""

echo "$vbox_rules" > /etc/udev/rules.d/virtualbox.rules
rm -f /etc/udev/rules.d/*-virtualbox.rules
udevadm control --reload
adduser `logname` vboxusers

echo All actions succeeded.
echo Log out and log in to see if the issue go fixed.