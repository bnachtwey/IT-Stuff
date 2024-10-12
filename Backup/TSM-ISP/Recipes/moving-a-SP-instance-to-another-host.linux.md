# Moving a SP instance to another host
<!--
##############################################################################
# changelog
# date          version remark
# 2024-10-11    0.0.3   moved to my personal github repo, some smaller typos fixed
#                       added step for reenabling repliction after DB restore
#                       added some markdown hacks
# 2023-11-22    0.0.2	  remove special settings for GWDG, so it's now more generic
# 2020-XX-XX    0.0.1   initial coding inside internal GWDG documentation
#
##############################################################################
#
#   https://github.com/bnachtwey/IT-Stuff/new/main/Backup/TSM-ISP/moving-a-SP-instance-to-another-host.linux.md
#    
#   A template for the workflow of moving an TSM instance to another host -- Linux Version
#
#   The Author:
#   (C) 2020 -- 2024 Bjørn Nachtwey, tsm@bjoernsoe.net
#
#   Grateful Thanks to the Companies, who allowed to do the development
#   (C) 2023 --      Cristie Data Gmbh, www.cristie.de
#   (C) 2020 -- 2023 GWDG, www.gwdg.de
#
##############################################################################
#
#  Licensed under the Mozilla Public License (MPL) Version 2.0;

#  you may not use this file except in compliance with the License.
#  If a copy of the MPL was not distributed with this file, You can obtain one at 
# 
#   http://mozilla.org/MPL/2.0/.
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
##############################################################################
-->

## Preparation (SEVERAL DAYS BEFORE MIGRATION)

This manual assumes that the host is already prepared for TSM/ISP, i.e. 

- TSM/SP is already installed
- also the appropriate BA client
- the basic directory structure (e.g. `/actlog/`,`/archlog/`,`/db[x]/`) is created
- a common share accessible from both servers exists (in this example `/tsmmove`)
- the tape drives incl. LinTape driver are already configured

### [ TODO / WIP / DONE ] Decrease TTL of CName for Instance

Whereever you manage your IP settings ;-)

> [!TIP]
> I suggest a value of **60** (seconds) instead of default (3600 aka 1 hour).

If you use an a-record instead of an c-name, you've to change that.

---

# Step-by-Step schedule

## SOME DAYS BEFORE MIGRATION

### [ TODO ] create instance user, it's $HOME folder and additional folders for the ISP instance

*run this on NEW server*

```bash
uid=215

# create user`s home folder

# preferably as separate LV on localVG / rootVG
lcvreate -n sm{$uid}LV -L 5G localVG 

mkfs.ext4 /dev/localVG/sm{uid$}LV
echo "/dev/localVG/sm{$uid}LV                            /sm$uid          ext4     defaults        0 5" >> /etc
/fstab
mount /sm$uid

# set access rights
chown 1$uid:1000 /sm$uid

# create user sm$uid
cat "sm$uid:x:1$uid:1000:sm$uid:/sm$uid:/bin/bash" >> /etc/passwd

# set password
echo "sm$uid:<PW>" | chpasswd

# add to groups
usermod -a -G disk,tape sm$uid

# set password
echo "sm$uid:<PW>" | chpasswd

# create db + logfolders
su -c "mkdir /actlog/sm$uid" -l sm$uid
su -c "mkdir /archlog/sm$uid" -l sm$uid

for d in $(ls /db* );
do
        su -c "mkdir $d/sm$uid" -l sm$uid
done

# copy db path to file for Instance creation / restoreDB
ls -d /db*/sm$uid > /sm$uid/dbdirs.txt

# create instance's "home" directory + planfile directory
su -c "mkdir /sm$uid/config/planfiles -p" -l sm$uid
```

### [ TODO ] create (temporary) SP instance

*run this on NEW server*

- automatically by script does not work by now 
  
  - using the wizard `/opt/tivoli/tsm/server/bin/dsmicfgx `
    
    - UID  => `sm$uid `
    - Instance Directory: => `/sm$uid/config`
    - The database directories are listed in this file: => `/sm$uid/dbdirs.txt` 
    - Active log size (GB): => `16`  (16 GB is enough for the installation, can be changed later)
    - Active log directory:  => `/actlog/sm$uid `
    - Primary Archive log directory:  => `/archlog/sm$uid`
    - Active log mirror directory:  => *keep empty*
    - Secondary archive log directory:  => *keep empty*
    - Server Name: => `SM$uid` 
    - When the machine boots: 
      => `Start the server automatically using the instance user ID` (this creates `initd`-scripts and/or systemd services)
    - Administrator Name : => `<some user, that should have SYSTEM privileges>` 
      (useful to take one that will be used in production, too)
- manually or by playbook
  - 🚧 T.B.D. 🚧
 
  
### [ TODO ] extend file `dsm.sys` with settings for this new instance

*run this on NEW server*

```bash
uid=215

echo ""                          >> /opt/tivoli/tsm/client/ba/bin/dsm.sys
echo "* *****************************************************************" >> /opt/tivoli/tsm/client/ba/bin/dsm.sys
echo "* *****************************************************************" >> /opt/tivoli/tsm/client/ba/bin/dsm.sys
echo "*    admin stanza for SM$uid" >> /opt/tivoli/tsm/client/ba/bin/dsm.sys  
echo "* *****************************************************************" >> /opt/tivoli/tsm/client/ba/bin/dsm.sys
echo "* *****************************************************************" >> /opt/tivoli/tsm/client/ba/bin/dsm.sys
echo "SErvername              sm$uid" >> /opt/tivoli/tsm/client/ba/bin/dsm.sys
echo "TCPPort                 2$uid"  >> /opt/tivoli/tsm/client/ba/bin/dsm.sys
echo "TCPADMINPort            4$uid"  >> /opt/tivoli/tsm/client/ba/bin/dsm.sys
echo "TCPServeraddress        127.0.0.1" >> /opt/tivoli/tsm/client/ba/bin/dsm.sys
echo "ERRORLOGName            /tsm/sm$uid.errorlog" >> /opt/tivoli/tsm/client/ba/bin/dsm.sys
echo "ERRORLOGRetention       30" >> /opt/tivoli/tsm/client/ba/bin/dsm.sys
echo "ENABLEINSTRUMENTATION   No" >> /opt/tivoli/tsm/client/ba/bin/dsm.sys
```

### [ TODO ] stop (temporary) SP instance

*run this on NEW server*

```bash
dsmadmc -se=sm$uid -id=<Admin-UID> -pa "<PW>" halt
```

### [ TODO ] delete Db2 database of temporary ISP instance

*run this on NEW server*

```bash
su - <instuser>
cd config

dsmserv removedb TSMDB1

rm -rf /actlog/$USER/*  -rf
rm -rf /archlog/$USER/* -rf

rm -rf /db*/$USER/* -rf
```

### [ TODO ] reduce size of staging pools to minimize time for full migration

for example

- reduce number of scratch volumes for FILEPools
  `upd stg <Pool name> maxscr=<lower number>`
- set `hi` and `lo` watermark to lower values
  `upd stg <Pool name> hi=<lower number> lo=<lower number>` 

---

## ON DAY OF MIGRATION

### [ TODO ] disable access to old instance and lock admin users

*run this on **OLD server** inside TSM*

e.g. 
```dsmadmc
DISable SEssion
LOCK ADMIN storadm
LOCK ADMIN poladm
LOCK ADMIN sysadm
```

### [ TODO ] cleanup staging pools

*run this on **OLD server** inside TSM*

- for each pool of type `DISK` or `FILE` move all data to next non-local pool

	```dsmadmc
	MIGrate STGPool <pool name> LO=0
	```
  **WAIT till finished!**

- `FILE` volumes should either vanish automatically or become of type `EMPTY`, so you should remove them manually

	```dsmadmc
	Query VOLume STGPool=<pool name>
	
	DELete VOLume <path and name of volume> DISCARD=Yes
	```

	you can again use some SQL scripting to get these volumes in groups of maybe 10 :-)
	
	```dsmadmc
	SELECT 'DELETE VOLUME ' || volume_name || ' DISCARD=Yes' FROM volumes WHERE devclass_name=<devc name> LIMIT 10
	```
- `DISK` volumes do not vanish automatically and must be removed manually

## [ TODO ] wait for tapes umounted

*run this on **OLD server** inside TSM*

```dsmadmc
Query MOunt Format=Detailed
```

Force umount

```dsmadmc
DISMount VOLume <Volume Name>
```

Cross check on LibMan all Volumes are really unmounted

```dsmadmc
LM2XX: Query MOunt
```
> [!CAUTION]
> as long as tapes are DISMOUNTING the LibMan wants to reply the SM-Instance => do not stop SM until umount is finished **completely**!

### [ TODO ] *SPECIAL TASK for LIBMAN instances*

Disable Libclients from accessing tapes using

```dsmadmc
PERForm LIBACTion <Library Name> ACTion=QUIesce
```

unfortunately this also sets path to the libman and the drives offline. Lateron you need both online to run a `AUDIT LIBRary` command.

Alternatively you can set all paths manually offline 
```dsmadmc
UPdate PATH <SOURCE> <DEST> SRCType=SERver DESTType=DRive LIBRary=<lib> DEVIce=<devname> ONLine=No
```

Setting all paths offline, you may use a SQL query to get all commands:

```dsmadmc
SELECT 'UPdate PATH ' || source_name || ' ' || destination_name || ' SRCType=SERver DESTType=DRive LIBRary=' || library_name || ' DEVIce=' || device || ' ONLine=No' FROM paths WHERE destination_type='DRIVE' AND NOT source_name='<name of LibMan>'
```

e.g.

```dsmadmc
Protect: TSM02>select 'UPdate PATH ' || SOURCE_NAME || ' ' || DESTINATION_NAME || ' SRCType=SERver DESTType=DRive LIBRary=' || LIBRARY_NAME || ' DEVIce=' || DEVICE || ' ONLine=No' from paths where DESTINATION_TYPE='DRIVE'

Unnamed[1]: UPdate PATH TSM02 DRIVE1 SRCType=SERver DESTType=DRive LIBRary=QUADSTORU DEVIce=/dev/IBMtape0 ONLine=No

Unnamed[1]: UPdate PATH TSM02 DRIVE2 SRCType=SERver DESTType=DRive LIBRary=QUADSTORU DEVIce=/dev/IBMtape1 ONLine=No
```

> [!TIP]
> issuing `PERForm LIBACTion` brings down the paths, but also sets the drives offline. For further steps you need to set them online again!

unfortunately, typically some LibClients are accessing the library (they cause errors on script execution above)

Stop tape access by canceling processes / session on **each Libclient**!

```dsmadmc
Query PPocess
CANCEL PRocess <Process-ID>

Query SEssion
CANCEL SEssion <Session-ID>
```

rerun the `UPDATE PATH` commands as often as needed.

> [!TIP] 
> rerun the `UPDATE PATH` commands multiple times to avoid (any) instances accessing the newly emptied drives

Check at the end all paths are really offline:

```dsmadmc
Query PATH
```

### [ TODO ] do Db2 backup 2 File class

*run this on **OLD server** inside TSM*

> [!TIP]
> using a FILE DEVC makes the access to the DB2 backup much easier as no libman connections needs to be configured

> [!TIP]
>  you can use the `BAckup DB` command from your daily housekeeping script, but DO NOT run the script, especially when not using MAINT mode! Consider using `Wait=No`

> [!TIP]
> Using `NUMStrems` with more than one parallel stream speeds up a lot. But consider the size of the DB, some are really small, then this parallelization has only limited effect.

e.g.

```dsmadmc
BAckup DB Type=Full DEVClass=FDBB Wait=No COMP=N NUMS=1 PROTECTKEYS=YES 
PASSWORD=<replace with your DB password>
```

### [ TODO ] copy vital instance data to common share

*run this on **OLD server***

```bash
$imf=/tsmmove/instmove/sm$uid
mkdir $imf
cp -a /sm$uid/config/cert*               $imf/
cp -a /sm$uid/config/dsmkeydb*           $imf/
cp -a /sm$uid/config/planfiles           $imf/
cp -a /sm$uid/config/dsmserv.opt         $imf/
cp -a /sm$uid/config/devconf.dat         $imf/
cp -a /sm$uid/config/volhist.dat         $imf/
```

### [ TODO ] overwrite instance settings with vital data from old host

*run this on **NEW server***

```bash
cp -a $imf/* /sm$uid/config/
```

### [ TODO ] adapt settings of dsmserv.opt if needed

*run this on **NEW server***

e.g.

```
DBMEMPERCENT    <Number>      
REORGBEGINTime  <hh:mm> 
```

### [ TODO ] Restore

*run this on **NEW server***

[ ] create temporary `RECOVerydir` folder, e.g. on a separate volume or within the staging area ... using a symlink shortes the following command and allows to use the same on all server whereever the folder is located.

```bash
mkdir /<storage/rst
ln -s /<storage/rst /rst

rm -rf /rst/*
su -c 'mkdir /rst/sm$uid' -l sm$uid
```

[ ] Do the Db2 restore
 **IMPORTANT** As this may take some time, you're strongly advised to use a `screen` for this! **IMPORTANT**

```bash
screen -S sm$uid-Restore

cd config

dsmserv restore db on=../dbdirs.txt RECOVerydir=/rst/sm$uid/ RESTOREKeys=Yes 
PASSWORD=<replace with your DB password> PROMPT=No
```

### [ TODO ] Prohibit access to production data as while doing test run

*run this on **NEW server***

- concerns tape accesses
  - It would be possible to prevent outgoing connections to LibMan, but this would also affect a second instance that is already running
  - bad workaround:
    - Prevent connections of the LibMan to the "new" instance: No confirmation of drive assignment, LibClient waits until TimeOut.
    - Problem: Also blocks further instances on the new host.
  - better workaround:
    - Bend configuration of LibMan in devconf.dat, i.e. change the destination port(s) so that the host FW on the LibMan blocks connections, e.g.
      `sed -i 's/LLADDRESS=420/LLADDRESS=720/g' devconf.dat `
- network share
  - idea1: set whole share to readonly => hinders parallel instance
  - Idea2: change UID and GID 
    - GID might not matter, if whole share belongs to root anyway
    - UID ... impacts plenty of interchange with everything possible ... 
  - any more ideas?

### [ TODO ] start instance in MAINT mode for test

*run this on **NEW server***

```bash
su - sm$uid

cd config
dsmserv MAINT
```

check license validity and register if necessary

```dsmadmc
q lic

reg lic fil=tsmee.lic
```

pull a new DB backup right away

```dsmadmc
 BAckup DB Type=Full DEVClass=FDBB NUMStreams=2 PROTECTKEYS=YES PASSWORD=<replace with your DB password>
```

### [ TODO ] Create / Fix DISKvolumes

*run this on **NEW server** inside TSM**

Delete volumes being OFFLINE  (repeat as often as needed)

```dsmadmc
q vol *DSM* ACC=OFFLINEDELETE VOLume <Path>
```

Create new volumes (repeat as often as needed)

```dsmadmc
DEFine VOLume <POOL> <PATH> FORMATSIZE=<Size in MB>
```

### [ TODO ] UPdate DEVClasses (if needed)

*run this on **NEW server** inside TSM*

e.g. for local FILE pools (CephFS should use the same path!)

```dsmadmc
UPDate DEVClass <Name> DIRectory=<new Path>
```

### [ TODO ] SPECIAL TASK for LIBMAN instances
*run this on **NEW server***

**ADVISE**: first run a `AUDIT LIBRARY` before enabling libclients

**CAUTION**: make sure the changer device path and the paths between LibMan and drives and the drives itself are online, otherwise the AUDIT will fail!

```dsmadmc
AUDIT LIBRary <LibName> CHECKLabel=Barcode
```

then enable LibClients by setting all paths online

```dsmadmc
PERForm LIBACTion <Library Name> ACTion=RESet
```

**ADVISE** Check if all paths are really online, perhaps the script does not cover all drives / libclients – if the script is outdated 

```dsmadmc
Query PATH
```

### [ TODO ] Move CName for Instance to new hostrecord

Whereever you manage your IP settings ;-)

### [ TODO ] Stop instance and start it normally and configure automatic start

*run this on **NEW server***

```dsmadmc
HALT
```
*run this on **NEW server***

```bash
systemctl enable --now sm$uid
```

### [ TODO ] unlock admins

*run this on **NEW server** inside TSM*

e.g.
```dsmadmc
unlock admin storadm
unlock admin poladm
unlock admin sysadm
```

### [ TODO ] if the server was a *replication source*
... you will receive `ANR0340E` messages, as [*When you restore the IBM® Storage Protect database on a source replication server, replication is automatically disabled.*](https://www.ibm.com/docs/en/storage-protect/8.1.24?topic=replication-replicating-client-node-data-after-database-restore).

The IBM description of the  `ANR0340E` message assumess, you do a DB restore *point-in-time* and having lost some primary data to need to recover from the replication target server. But when *moving an instance* you don't have to do so. In this case the only step you have to do

* (re-)enable replication again

*run this on **NEW server** inside TSM*

e.g.
```dsmadmc
enable replication
```

--- 

### [ TODO ] Clean up (perhaps SOME DAYS AFTER MIGRATION)

*run this on **OLD server***

- delete copied data from network share, e.g.
  `rm -rf $imf/sm$uid`

- delete Data from former host
  - remove DB2 instance from DB2 host
	```bash
	su - <inst user>
	# first remove db inside TSM
	dsmserv remove db
	
	# second remove it from the DB2 host
	# get all instances
	/opt/tivoli/tsm/db2/instance/db2ilist
	
	# remove db
	/opt/tivoli/tsm/db2/instance/db2idrop <instance name>
	```
  - delete DB folders
    `for d in $(ls /db*/sm$uid -d); do rm -rf $d; done `
  - delete Actlog folder
    `rm -rf /actlog/sm$uid`
  - delete Archlog folder
    `rm -rf /archlog/sm$uid`
  - delete staging folders (if not located on network share)
    `rm -rf /stage*/sm{$uid}*`
  - delete user and group association
    `deluser --force --remove-home <UID>`
  - delete init scripts and systemd services
    ```bash
    rm /etc/init.d/sm$uid
    rm /etc/systemd/system/sm$uid.servicename
    rm /usr/lib/systemd/system/sm$uid.servicename 
    sudo systemctl daemon-reload
    ```

*run this on **NEW server***

- delete temporary RECOVDir
  `rm -rf /rst/sm$uid/*`

### [ TODO ] Increase TTL for CName to ordinary value

Whereever you manage your IP settings ;-)
