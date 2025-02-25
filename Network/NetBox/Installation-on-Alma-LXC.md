# my notes on Installating NetBox on a proxmox LXC with Alma9
## Hardware / Container Setup
- 2 vCPU *Intel(R) Xeon(R) CPU E5-2630 v2 @ 2.60GHz*
- 4 GB RAM
- 16 GB Disk (no partitions), located on nvme-Storage
- *AlmaLinux release 9.5 (Teal Serval)*
- Kernel *6.8.12-5-pve*
- ...

## Summary
- especially for Alma Linux (and therefore Rocky and CentOS and RHEL) some packages are missing<br>
  ```bash
  dnf -y update
  dnf -y install python3.12 python3.12-devel
  ```
- the default python3 version is too old, but cannot removed, so a workaround is needed:<br>
  ```bash
  rm /usr/bin/python3
  ln -s /usr/bin/python3.12 /usr/bin/python3
  ```
--
# Detailed log book on attempt to install
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

## Redis Installation
### Install Redis
install and enable redis by
```bash
sudo dnf install -y redis
sudo systemctl enable --now redis
```
check version to be at least 4.0 ..
```bash
# redis-server -v
Redis server v=6.2.17 sha=00000000:0 malloc=jemalloc-5.1.0 bits=64 build=5e7d2a5c1d1fb236
```
### Verify Service Status
```bash
# redis-cli ping
PONG
```

## NetBox Installation

This section of the documentation discusses installing and configuring the NetBox application itself.
### Install System Packages
```bash
dnf install -y gcc libxml2-devel libxslt-devel libffi-devel libpq-devel openssl-devel redhat-rpm-config
```
installs 106 Packages ...
```bash
Installed:
  annobin-12.65-1.el9.x86_64               binutils-2.35.2-54.el9.x86_64                         binutils-gold-2.35.2-54.el9.x86_64            cmake-filesystem-3.26.5-2.el9.x86_64          cpp-11.5.0-5.el9_5.alma.1.x86_64           dwz-0.14-3.el9.x86_64
  efi-srpm-macros-6-2.el9_0.0.1.noarch     elfutils-debuginfod-client-0.191-4.el9.alma.1.x86_64  file-5.39-16.el9.x86_64                       fonts-srpm-macros-1:2.0.5-7.el9.1.noarch      gcc-11.5.0-5.el9_5.alma.1.x86_64           gcc-plugin-annobin-11.5.0-5.el9_5.alma.1.x86_64
  ghc-srpm-macros-1.5.0-6.el9.noarch       glibc-devel-2.34-125.el9_5.1.alma.2.x86_64            glibc-headers-2.34-125.el9_5.1.alma.2.x86_64  go-srpm-macros-3.6.0-3.el9.noarch             groff-base-1.22.4-10.el9.x86_64            kernel-headers-5.14.0-503.23.2.el9_5.x86_64
  kernel-srpm-macros-1.0-13.el9.noarch     libffi-devel-3.4.2-8.el9.x86_64                       libgpg-error-devel-1.42-5.el9.x86_64          libmpc-1.2.1-4.el9.x86_64                     libpkgconf-1.7.3-10.el9.x86_64             libpq-13.20-1.el9_5.x86_64
  libpq-devel-13.20-1.el9_5.x86_64         libxcrypt-devel-4.4.18-3.el9.x86_64                   libxml2-devel-2.9.13-6.el9_5.1.x86_64         libxslt-1.1.34-9.el9.x86_64                   libxslt-devel-1.1.34-9.el9.x86_64          llvm-libs-18.1.8-3.el9.x86_64
  lua-srpm-macros-1-6.el9.noarch           make-1:4.3-8.el9.x86_64                               ncurses-6.2-10.20210508.el9.x86_64            ocaml-srpm-macros-6-6.el9.noarch              openblas-srpm-macros-2-11.el9.noarch       openssl-devel-1:3.2.2-6.el9_5.1.x86_64
  perl-AutoLoader-5.74-481.el9.noarch      perl-B-1.80-481.el9.x86_64                            perl-Carp-1.50-460.el9.noarch                 perl-Class-Struct-0.66-481.el9.noarch         perl-Data-Dumper-2.174-462.el9.x86_64      perl-Digest-1.19-4.el9.noarch
  perl-Digest-MD5-2.58-4.el9.x86_64        perl-Encode-4:3.08-462.el9.x86_64                     perl-Errno-1.30-481.el9.x86_64                perl-Exporter-5.74-461.el9.noarch             perl-Fcntl-1.13-481.el9.x86_64             perl-File-Basename-2.85-481.el9.noarch
  perl-File-Path-2.18-4.el9.noarch         perl-File-Temp-1:0.231.100-4.el9.noarch               perl-File-stat-1.09-481.el9.noarch            perl-FileHandle-2.03-481.el9.noarch           perl-Getopt-Long-1:2.52-4.el9.noarch       perl-Getopt-Std-1.12-481.el9.noarch
  perl-HTTP-Tiny-0.076-462.el9.noarch      perl-IO-1.43-481.el9.x86_64                           perl-IO-Socket-IP-0.41-5.el9.noarch           perl-IO-Socket-SSL-2.073-2.el9.noarch         perl-IPC-Open3-1.21-481.el9.noarch         perl-MIME-Base64-3.16-4.el9.x86_64
  perl-Mozilla-CA-20200520-6.el9.noarch    perl-NDBM_File-1.15-481.el9.x86_64                    perl-Net-SSLeay-1.94-1.el9.x86_64             perl-POSIX-1.94-481.el9.x86_64                perl-PathTools-3.78-461.el9.x86_64         perl-Pod-Escapes-1:1.07-460.el9.noarch
  perl-Pod-Perldoc-3.28.01-461.el9.noarch  perl-Pod-Simple-1:3.42-4.el9.noarch                   perl-Pod-Usage-4:2.01-4.el9.noarch            perl-Scalar-List-Utils-4:1.56-462.el9.x86_64  perl-SelectSaver-1.02-481.el9.noarch       perl-Socket-4:2.031-4.el9.x86_64
  perl-Storable-1:3.21-460.el9.x86_64      perl-Symbol-1.08-481.el9.noarch                       perl-Term-ANSIColor-5.01-461.el9.noarch       perl-Term-Cap-1.17-460.el9.noarch             perl-Text-ParseWords-3.30-460.el9.noarch   perl-Text-Tabs+Wrap-2013.0523-460.el9.noarch
  perl-Time-Local-2:1.300-7.el9.noarch     perl-URI-5.09-3.el9.noarch                            perl-base-2.27-481.el9.noarch                 perl-constant-1.33-461.el9.noarch             perl-if-0.60.800-481.el9.noarch            perl-interpreter-4:5.32.1-481.el9.x86_64
  perl-libnet-3.13-4.el9.noarch            perl-libs-4:5.32.1-481.el9.x86_64                     perl-mro-1.23-481.el9.x86_64                  perl-overload-1.31-481.el9.noarch             perl-overloading-0.02-481.el9.noarch       perl-parent-1:0.238-460.el9.noarch
  perl-podlators-1:4.14-460.el9.noarch     perl-srpm-macros-1-41.el9.noarch                      perl-subs-1.03-481.el9.noarch                 perl-vars-1.05-481.el9.noarch                 pkgconf-1.7.3-10.el9.x86_64                pkgconf-m4-1.7.3-10.el9.noarch
  pkgconf-pkg-config-1.7.3-10.el9.x86_64   pyproject-srpm-macros-1.12.0-1.el9.noarch             python-srpm-macros-3.9-54.el9.noarch          qt5-srpm-macros-5.15.9-1.el9.noarch           redhat-rpm-config-208-1.el9.alma.1.noarch  rust-srpm-macros-17-4.el9.noarch
  unzip-6.0-57.el9.x86_64                  xz-devel-5.2.5-8.el9_0.x86_64                         zip-3.0-35.el9.x86_64                         zlib-devel-1.2.11-40.el9.x86_64

Complete!
```
 :-)

check python3 version
```bash
# python3 -V
Python 3.12.5
```

### Download NetBox
Take *Option B: Clone the Git Repository*

Install `git`
```bash
dnf -y install git

Installed:
  emacs-filesystem-1:27.2-10.el9_4.noarch  git-2.43.5-2.el9_5.x86_64            git-core-2.43.5-2.el9_5.x86_64  git-core-doc-2.43.5-2.el9_5.noarch  less-590-5.el9.x86_64  perl-DynaLoader-1.47-481.el9.x86_64  perl-Error-1:0.17029-7.el9.noarch  perl-File-Find-1.37-481.el9.noarch
  perl-Git-2.43.5-2.el9_5.noarch           perl-TermReadKey-2.38-11.el9.x86_64  perl-lib-0.65-481.el9.x86_64

Complete!
```
Create the base directory for the NetBox installation. For this guide, we'll use /opt/netbox.

```bash
sudo mkdir -p /opt/netbox/
cd /opt/netbox/
```
Next, clone the git repository:
```bash
git clone https://github.com/netbox-community/netbox.git .
```

Finally, check out the tag for the desired release. You can find these on our releases page. Replace vX.Y.Z with your selected release tag below.
```bash
# sudo git checkout v4.2.4
Note: switching to 'v4.2.4'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false

HEAD is now at c4304d059 Merge pull request #18703 from netbox-community/release-v4.2.4
```
### Create the NetBox System User
```bash
sudo groupadd --system netbox
sudo adduser --system -g netbox netbox
sudo chown --recursive netbox /opt/netbox/netbox/media/
sudo chown --recursive netbox /opt/netbox/netbox/reports/
sudo chown --recursive netbox /opt/netbox/netbox/scripts/
```

### Configuration
```bash
cd /opt/netbox/netbox/netbox/
sudo cp configuration_example.py configuration.py
```
#### ALLOWED_HOSTS
```bash
sed -i 's#ALLOWED_HOSTS = \[\]#ALLOWED_HOSTS = \[10.0.0.0/8\]#' configuration.py
sed -i 's#ALLOWED_HOSTS = \[\]#ALLOWED_HOSTS = \[10.0.0.0/8\]#' configuration.py
```
### Run the Upgrade Script
Fails:
```bash
# bash /opt/netbox/upgrade.sh
You are installing (or upgrading to) NetBox version 4.2.4
Using Python 3.12.5
Removing old virtual environment...

.
.
.

  Building wheel for psycopg-c (pyproject.toml) ... error
  error: subprocess-exited-with-error

  × Building wheel for psycopg-c (pyproject.toml) did not run successfully.
  │ exit code: 1
  ╰─> [26 lines of output]
      running bdist_wheel
      running build
      running build_py
      creating build/lib.linux-x86_64-cpython-312/psycopg_c
      copying psycopg_c/version.py -> build/lib.linux-x86_64-cpython-312/psycopg_c
      copying psycopg_c/__init__.py -> build/lib.linux-x86_64-cpython-312/psycopg_c
      copying psycopg_c/_psycopg.pyi -> build/lib.linux-x86_64-cpython-312/psycopg_c
      copying psycopg_c/py.typed -> build/lib.linux-x86_64-cpython-312/psycopg_c
      copying psycopg_c/pq.pxd -> build/lib.linux-x86_64-cpython-312/psycopg_c
      creating build/lib.linux-x86_64-cpython-312/psycopg_c/_psycopg
      copying psycopg_c/_psycopg/__init__.pxd -> build/lib.linux-x86_64-cpython-312/psycopg_c/_psycopg
      copying psycopg_c/_psycopg/oids.pxd -> build/lib.linux-x86_64-cpython-312/psycopg_c/_psycopg
      copying psycopg_c/_psycopg/endian.pxd -> build/lib.linux-x86_64-cpython-312/psycopg_c/_psycopg
      creating build/lib.linux-x86_64-cpython-312/psycopg_c/pq
      copying psycopg_c/pq/__init__.pxd -> build/lib.linux-x86_64-cpython-312/psycopg_c/pq
      copying psycopg_c/pq/libpq.pxd -> build/lib.linux-x86_64-cpython-312/psycopg_c/pq
      running build_ext
      building 'psycopg_c._psycopg' extension
      creating build/temp.linux-x86_64-cpython-312/psycopg_c
      creating build/temp.linux-x86_64-cpython-312/psycopg_c/types
      gcc -fno-strict-overflow -Wsign-compare -DDYNAMIC_ANNOTATIONS_ENABLED=1 -DNDEBUG -O2 -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fstack-protector-strong -m64 -march=x86-64-v2 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -O2 -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fstack-protector-strong -m64 -march=x86-64-v2 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -O2 -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fstack-protector-strong -m64 -march=x86-64-v2 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -fPIC -I/usr/include -I/opt/netbox/venv/include -I/usr/include/python3.12 -c psycopg_c/_psycopg.c -o build/temp.linux-x86_64-cpython-312/psycopg_c/_psycopg.o
      psycopg_c/_psycopg.c:42:10: fatal error: Python.h: No such file or directory
         42 | #include "Python.h"
            |          ^~~~~~~~~~
      compilation terminated.
      error: command '/usr/bin/gcc' failed with exit code 1
      [end of output]

  note: This error originates from a subprocess, and is likely not a problem with pip.
  ERROR: Failed building wheel for psycopg-c
Failed to build psycopg-c
ERROR: Failed to build installable wheels for some pyproject.toml based projects (psycopg-c)
```

=> no `Python.h` available
=> on Debian, it's part of `Python3.11` ???

let's try to install `python3.12-devel` ... <br>
... works 
```bash
]# dnf -y install python3.12-devel
Last metadata expiration check: 0:08:50 ago on Tue 25 Feb 2025 03:05:35 PM UTC.
Dependencies resolved.
===========================================================================================================================================================================================================================================================================================
 Package                                                                  Architecture                                                   Version                                                                   Repository                                                         Size
===========================================================================================================================================================================================================================================================================================
Installing:
 python3.12-devel                                                         x86_64                                                         3.12.5-2.el9_5.2                                                          appstream                                                         274 k

Transaction Summary
===========================================================================================================================================================================================================================================================================================
Install  1 Package

Total download size: 274 k
Installed size: 1.2 M
Downloading Packages:
python3.12-devel-3.12.5-2.el9_5.2.x86_64.rpm                                                                                                                                                                                                               1.8 MB/s | 274 kB     00:00
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                                                                                                                      482 kB/s | 274 kB     00:00
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                                                                                                                                   1/1
  Installing       : python3.12-devel-3.12.5-2.el9_5.2.x86_64                                                                                                                                                                                                                          1/1
  Running scriptlet: python3.12-devel-3.12.5-2.el9_5.2.x86_64                                                                                                                                                                                                                          1/1
  Verifying        : python3.12-devel-3.12.5-2.el9_5.2.x86_64                                                                                                                                                                                                                          1/1

Installed:
  python3.12-devel-3.12.5-2.el9_5.2.x86_64

Complete!
```

Next attempt ...<br>
.. works
```bash
.
.
.
Completed.
Removing expired user sessions (python3 netbox/manage.py clearsessions)...
Upgrade complete! Don't forget to restart the NetBox services:
  > sudo systemctl restart netbox netbox-rq
```

... but no such services defined :-(

```bash
 systemctl restart netbox netbox-rq
Failed to restart netbox.service: Unit netbox.service not found.
Failed to restart netbox-rq.service: Unit netbox-rq.service not found.
```

.. need to copy them manually
```bash
# locate netbox.service
/opt/netbox/contrib/netbox.service
# locate netbox-rq.service
/opt/netbox/contrib/netbox-rq.service

# cp /opt/netbox/contrib/netbox*.service /etc/systemd/system/

# systemct daemon-reload

# systemctl restart netbox.service netbox-rq.service

# systemctl status netbox.service netbox-rq.service
● netbox.service - NetBox WSGI Service
     Loaded: loaded (/etc/systemd/system/netbox.service; disabled; preset: disabled)
     Active: activating (auto-restart) (Result: exit-code) since Tue 2025-02-25 15:35:11 UTC; 5s ago
       Docs: https://docs.netbox.dev/
    Process: 3419 ExecStart=/opt/netbox/venv/bin/gunicorn --pid /var/tmp/netbox.pid --pythonpath /opt/netbox/netbox --config /opt/netbox/gunicorn.py netbox.wsgi (code=exited, status=1/FAILURE)
   Main PID: 3419 (code=exited, status=1/FAILURE)
        CPU: 350ms

● netbox-rq.service - NetBox Request Queue Worker
     Loaded: loaded (/etc/systemd/system/netbox-rq.service; disabled; preset: disabled)
     Active: active (running) since Tue 2025-02-25 15:35:11 UTC; 6s ago
       Docs: https://docs.netbox.dev/
   Main PID: 3418 (python3)
      Tasks: 1 (limit: 1649879)
     Memory: 143.4M
        CPU: 6.249s
     CGroup: /system.slice/netbox-rq.service
             └─3418 /opt/netbox/venv/bin/python3 /opt/netbox/netbox/manage.py rqworker high default low
```
so, failed at all again ...<br>
perhaps, because *right now*, no *gunicorn* is installed nor configured??
