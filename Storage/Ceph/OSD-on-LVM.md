# Creating OSDs on Multipath devices: using LVM
unfortunately multipath devices cannot be used for OSDs directly, but there's a workaround: unsing a *logical volume* :-)

1) Create logical volume, e.g. by
   ```bash
   pvcreate --metadatasize 250k -y -ff /dev/mapper/mpathk
   vgcreate cephVG1 /dev/mapper/mpathk
   lvcreate -n cephLV1 -l 100%VG cephVG1
   ```
1) get keyring for further steps (no idea why, but obviously it's necessary)
   ```bash
   ceph auth get client.bootstrap-osd -ov
   ```
1) create a ceph-volume using the LV
   ```bash
   ceph-volume lvm prepare --data cephVG1/cephLV1
   ceph-volume lvm activate 0 e701b2dc-8ff2-454a-a808-6b43f06cd870
   ```
   or a litte more generic
   ```bash
   ceph-volume lvm activate $(ceph-volume lvm list | grep "osd id" | awk '{print $3}') $(ceph-volume lvm list | grep "osd fsid" | awk '{print $3}')
   ```
