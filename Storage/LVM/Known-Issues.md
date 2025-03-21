# Collecting known issues and fixes according LVM

## pvcreate fails as `device is a multipath component`
- check `/etc/multipath.conf` if device is really excluded
- check `/etc/multipath/wwids` if disk is listed
