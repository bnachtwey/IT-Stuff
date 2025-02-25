# my notes on Netbox
## Installation on a proxmox LXC with Alma9
### Check Requirements
as [mentioned](https://netboxlabs.com/docs/netbox/en/stable/installation/)
#### Python 3.10, 3.11 or 3.12
the default python version is not sufficient:<br>
```bash
# python3 --version
Python 3.9.21
```
so let's install a newer one<br>
```bash
dnf -y install python3.12
```
unfortunately, `python3` still points to<br>
```bash
# -ls -l /usr/bin/python3
lrwxrwxrwx 1 root root 9 Dec 12 10:11 /usr/bin/python3 -> python3.9
```
let's try to switch the symlink<br>
```bash
rm /usr/bin/python3
ln -s /usr/bin/python3.12 /usr/bin/python3
```
as `dnf` relies on `python3`, let's check it<br>
```bash
# dnf clean all
26 files removed
```
seems so :-)

#### PostgreSQL 	13+
by default `postgresql-server-13.20-1.el9_5.x86_64` will be installed, so the requirements are met :-)
```bash
dnf -y install postgresql-server
```
#### Redis 	4.0+
by default `redis-6.2.17-1.el9_5.x86_64` will be installed, so the requirements are met :-)
```bash
dnf -y install redis
```
