# my notes on Installating NetBox on a proxmox LXC with Alma9
## Hardware / Container Setup
- 2 vCPU *Intel(R) Xeon(R) CPU E5-2630 v2 @ 2.60GHz*
- 4 GB RAM
- 16 GB Disk (no partitions), located on nvme-Storage
- *AlmaLinux release 9.5 (Teal Serval)*
- Kernel *6.8.12-5-pve*
- ...
## 0 -- Check Requirements & install additional software
as [mentioned](https://netboxlabs.com/docs/netbox/en/stable/installation/)
### Python 3.10, 3.11 or 3.12
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

### PostgreSQL 	13+
by default `postgresql-server-13.20-1.el9_5.x86_64` will be installed, so the requirements are met :-)
```bash
dnf -y install postgresql-server
```
### Redis 	4.0+
by default `redis-6.2.17-1.el9_5.x86_64` will be installed, so the requirements are met :-)
```bash
dnf -y install redis
```
## 1 -- PostgreSQL Database Installation
### Installation & Init

as package was already installed, start with ´initdb`<br>
```bash
# postgresql-setup --initdb
 * Initializing database in '/var/lib/pgsql/data'
 * Initialized, logs are in /var/lib/pgsql/initdb_postgresql.log
```

*CentOS configures ident host-based authentication for PostgreSQL by default. Because NetBox will need to authenticate using a username and password, modify `/var/lib/pgsql/data/pg_hba.conf` to support MD5 authentication by changing ident to md5 for the lines below:*

```bash
# sed -i '/^host/s/ident/md5/g'  /var/lib/pgsql/data/pg_hba.conf

# tail -n 15 /var/lib/pgsql/data/pg_hba.conf


# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
```

*Once PostgreSQL has been installed, start the service and enable it to run at boot:*
```bash
sudo systemctl enable --now postgresql
```
*Before continuing, verify that you have installed PostgreSQL 13 or later:*
```bash
psql -V
psql (PostgreSQL) 13.20
```
### Database Creation
At a minimum, we need to create a database for NetBox and assign it a username and password for authentication. Start by invoking the PostgreSQL shell as the system Postgres user.
```bash
sudo -u postgres psql
```
Within the shell, enter the following commands to create the database and user (role), substituting your own value for the password:
```psql
postgres=# CREATE DATABASE netbox;
CREATE USER netbox WITH PASSWORD 'STRONG PASSWORD';
ALTER DATABASE netbox OWNER TO netbox;
CREATE DATABASE
CREATE ROLE
ALTER DATABASE
```

### Verify Service Status
*You can verify that authentication works by executing the psql command and passing the configured username and password. (Replace localhost with your database server if using a remote database.)*

```bash
$ psql --username netbox --password --host localhost netbox
Password for user netbox: 
psql (13.20)
Type "help" for help.

netbox=> \conninfo
You are connected to database "netbox" as user "netbox" on host "localhost" (address "::1") at port "5432".

netbox=> \q
```
