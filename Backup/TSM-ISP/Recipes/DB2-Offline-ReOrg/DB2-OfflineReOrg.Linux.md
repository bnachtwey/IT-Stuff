# Db2 OfflineReOrg _using temporary table space_

<!--

AIA No AI, _This work was entirely human-created, without the use of AI._

###############################################################################
# changelog
# date          version AIA       remark
# 2026-03-26    0.2.5   no AI     fixed some linter issues, add AIA
# 2024-04-10    0.2.4   no AI     add remark on table "SD_REPLICATING_CHUNKS"
# 2023-11-21    0.2.3   no AI     moved to new repo, changed one URL
# 2023-11-10    0.2.2   no AI     add some remarks
# 2023-09-21    0.2.1   no AI     add subsection "check summary file" and "selecting tabels"
#                                 some minor fixes 
# 2023-09-20    0.2.0   no AI     adding this comments, Copyrights into file 
#                                 and do some beautifications ;-)
# 2022-XX-XX    0.1.0   no AI     adding the checkboxes, putting under Apache 2.0 license
# 2020-XX-XX    0.0.1   no AI     initial coding inside internal GWDG documentation
#
##############################################################################
#
#   Db2-OfflineReOrg.Linux.md
#    
#   A template for the workflow of a Db2 Offline Reorganisation -- Linux Version
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
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
##############################################################################
-->

As now this pad may be used by others, I added some sources at the bottom :-)

## Short track for Linux Servers

(C) 2023 by <tsm@bjoernsoe.net>

### Assumptions

- the instance user is named `tsmXYZ`
  => can easily replaced by
  `sed -e 's#tsmXYZ#<real user name#g' <this file> > <new file>`

- it's home directory is `/tsmXYZ`

- the server config is located at `/tsmXYZ/config`

- there's a path `/OfflineReOrg` or a symlink of this name directing to a folder containing the anaylysis scripts and where to put the output

- the path for the temporary dbspace is given by the variable `$tpath`,
  e.g. by `export tpath=/stageX/`

### Advises

- Copy the shown commands as a template and remove all lines according tables you don't want to reorganize
- Copy _trailing blank line_ in the templates, so _all_ commands will be executed step-by-step including the last one

---
---

### [ToDo|WIP|Done] determine potential of ReOrg

IBM offers a Perl script combining all the necessary SQL requests and putting the data together [1],[2]. So just run this script:

```bash
su - tsmXYZ
perl -f /OfflineReOrg/bin/analyze_DB2_formulas.pl
```

#### [ ] Check `summary.out` file for suitable tables to reorganize

Running the script, it creates a folder with the actual date-time stamp. Besides many detailed information, there's also a summary to look on:

```bash
cat \OfflineReOrg\20230921-0755\summary.out
BEGIN SUMMARY
"db2 alter tablespace BACKOBJIDXSPACE reduce max" will return =174.2G to the operating system file system
If BACKUP_OBJECTS were to be off line reorganized the estimated savings is Table          144 GB, Index    0 GB
If BF_AGGREGATED_BITFILES were to be off line reorganized the estimated savings is Table   14 GB, Index   57 GB
If GROUP_LEADERS were to be off line reorganized the estimated savings is Table            64 GB, Index   75 GB
If AS_SEGMENTS were to be off line reorganized the estimated savings is Table               2 GB, Index    0 GB
If AF_BITFILES were to be off line reorganized the estimated savings is Table               0 GB, Index    2 GB
If AF_SEGMENTS were to be off line reorganized the estimated savings is Table 0 GB, Index 1 GB
If BF_AGGREGATE_ATTRIBUTES were to be off line reorganized the estimated savings is Table   0 GB, Index    0 GB
If TSMMON_STATUS were to be off line reorganized the estimated savings is Table             1 GB, Index    0 GB
If ACTIVITY_LOG were to be off line reorganized the estimated savings is Table             26 GB, Index    4 GB
Total estimated savings 390 GB
END SUMMARY
```

- The lines starting with `db2 alter tablespace` show space that be freed directly, by just issuing the menationed command after connecting to the Db2. (See section _Free space using "alter tablespace"_)

- The lines starting with `IF` show tables and the estimated space that can be freed after reoganziation of the table

#### [ ] Selecting tables

consider

- the amount that can be freed in relationship with the whole Db2 size
  - small wins are not useful as reorganiaztion costs time and do not really speed up db2 operations
- take the _space needed_ from the next section as a hint how much data is stored in a single table to consider the win for each table

> **IMPORTANT:**
>
> Due to some painful experience:
>
> Defragmentation on table `SD_REPLICATING_CHUNKS` has an **massive impact** on the _chunk deletion threads_. Even if this table looks very small and the savings are tiny, I strongly recommend to reorganize it every time you do an offline reorg!

**BUT:** Doing Offline Reoganizations for many times, I observered it often reclaims about 50% more space than estimated by the script [1] :-)

### [ ] Get Pagessize and estimate temporary space needed

as this means issuing some commands for each table, it's easier combine them in a script:

_run as INSTANCE user_ run script `db-selects.sh` [2]

```bash
su - tsmXYZ

tsmXYZ@tsmhostX:~> bash /OfflineReOrg/bin/db-selects.sh
                  Tabname ;    object-Count ; est. time (sec) ;    object-space ;    space needed ;   Pagesize
             ACTIVITY_LOG ;         1203346 ;           8.595 ;       202646496 ;        0.189 GB ;        16K
              AF_SEGMENTS ;        20836284 ;         148.831 ;       727963200 ;        0.678 GB ;        16K
              AF_BITFILES ;        20836041 ;         148.829 ;       788334976 ;        0.734 GB ;        16K
          ARCHIVE_OBJECTS ;           34588 ;           0.247 ;         8592990 ;        0.008 GB ;        32K
              AS_SEGMENTS ;        20836284 ;         148.831 ;      3428519168 ;        3.193 GB ;        16K
           BACKUP_OBJECTS ;       763629399 ;        5454.500 ;    327958790144 ;      305.435 GB ;        32K
  BF_AGGREGATE_ATTRIBUTES ;        16531482 ;         118.082 ;       577663040 ;        0.538 GB ;        16K
   BF_AGGREGATED_BITFILES ;       585727419 ;        4183.770 ;     21671911424 ;       20.183 GB ;        16K
       BF_BITFILE_EXTENTS ;               0 ;           0.000 ;               0 ;        0.000 GB ;        16K
   BF_DEREFERENCED_CHUNKS ;               0 ;           0.000 ;               0 ;        0.000 GB ;        16K
            GROUP_LEADERS ;       309856174 ;        2213.260 ;     11763646464 ;       10.956 GB ;        16K
           EXPORT_OBJECTS ;               0 ;           0.000 ;               0 ;        0.000 GB ;        16K
        SC_OBJECT_TRACKER ;        87935418 ;         628.110 ;      1574498304 ;        1.466 GB ;        16K
       REPLICATED_OBJECTS ;               0 ;           0.000 ;              -1 ;       -0.000 GB ;         8K
            TSMMON_STATUS ;         3715341 ;          26.538 ;       292830496 ;        0.273 GB ;        16K
```

> **NOTICE**:
>
>- estimated times are completely inaccurate
>- estimated space requirement fits reasonably
>
>**BE AWARE**:
>
>- `ARCHIVE_OBJECTS` and `BACKUP_OBJECTS` are of size **_32K_**
>- `REPLICATED_OBJECTS` uses **_8K_**

### [ ] Stop any activity

> _stop server inside admin CLI_

```dsmadmc
HALT
```

> _and restart in MAINT mode_

```bash
su - tsmXYZ

cd config
dsmserv MAINT
```

### [ ] Do a DB backup having a fallback option

Do this before doing any changes to the Db2, so if you have to recover, not steps need to be taken back.

_The author_ suggests a local file based devclass with using

```dsmadmc
NUMStreams=<something more than 1>
```

### [ ] Create temporary paths

```bash
tpath=/tstageX/
smx=tsmXYZ
su -c "mkdir $tpath/temp1-8K " $smx && ln -s $tpath/temp1-8K  /temp1-8K
su -c "mkdir $tpath/temp2-16K" $smx && ln -s $tpath/temp2-16K /temp2-16K
su -c "mkdir $tpath/temp3-32K" $smx && ln -s $tpath/temp3-32K /temp3-32K
```

### [ ] Create temporary tables

> _run as INSTANCE user while TSM is still running_

```bash
su - tsmXYZ

db2 connect to tsmdb1 

db2 "CREATE SYSTEM TEMPORARY TABLESPACE REORG8K PAGESIZE 8K MANAGED BY SYSTEM USING ('/temp1-8K') BUFFERPOOL REPLBUFPOOL1 DROPPED TABLE RECOVERY OFF"
db2 "CREATE SYSTEM TEMPORARY TABLESPACE REORG16K PAGESIZE 16K MANAGED BY SYSTEM USING ('/temp2-16K') BUFFERPOOL IBMDEFAULTBP DROPPED TABLE RECOVERY OFF"
db2 "CREATE SYSTEM TEMPORARY TABLESPACE REORG32K PAGESIZE 32K MANAGED BY SYSTEM USING ('/temp3-32K') BUFFERPOOL LARGEBUFPOOL1 DROPPED TABLE RECOVERY OFF"

```

### [ ] Stop TSM server

> _stop server inside admin CLI_

```dsmadmc
HALT
```

### [ ] Prepare Reorg

> _run as INSTANCE user_

```bash
su - tsmXYZ

db2 connect to tsmdb1

db2 force application all

db2stop

db2start

db2 connect to tsmdb1

db2 "DROP TABLESPACE TEMPSPACE1"
db2 "DROP TABLESPACE LGTMPTSP"
db2 update db cfg for tsmdb1 using auto_tbl_maint off

```

### [ ] Start Reorg

> **Advise**
>
> Use a `screen` [4] for this operation, so connection issues will not interrupt the process and will not lead to a broken Db2
>
> ```bash
>  screen -S DO_REORG
>  ```

```bash
su - tsmXYZ

db2 connect to tsmdb1

db2 "reorg table tsmdb1.ACTIVITY_LOG allow no access use REORG16K"
db2 "reorg table tsmdb1.AF_BITFILES allow no access use REORG16K"
db2 "reorg table tsmdb1.AF_SEGMENTS allow no access use REORG16K"
db2 "reorg table tsmdb1.ARCHIVE_OBJECTS allow no access use REORG32K"
db2 "reorg table tsmdb1.AS_SEGMENTS allow no access use REORG16K"
db2 "reorg table tsmdb1.BACKUP_OBJECTS allow no access use REORG32K"
db2 "reorg table tsmdb1.BF_AGGREGATE_ATTRIBUTES allow no access use REORG16K"
db2 "reorg table tsmdb1.BF_AGGREGATED_BITFILES allow no access use REORG16K"
db2 "reorg table tsmdb1.BF_BITFILE_EXTENTS allow no access use REORG16K"
db2 "reorg table tsmdb1.EXPORT_OBJECTS allow no access use REORG16K"
db2 "reorg table tsmdb1.GROUP_LEADERS allow no access use REORG16K"
db2 "reorg table tsmdb1.SC_OBJECT_TRACKER allow no access use REORG16K"
db2 "reorg table tsmdb1.REPLICATED_OBJECTS allow no access use REORG8K"
db2 "reorg table tsmdb1.TSMMON_STATUS allow no access use REORG16K"

```

### [ ] Monitor ReOrg

> [!NOTE]
> **suggested to use a screen**
>
> ```bash
> screen -S watch-reorg
> ```

```bash
su - tsmXYZ

db2 connect to tsmdb1 && watch 'db2pd -d tsmdb1 -reorg'
```

### [ ] Finish ReOrg

> _run as INSTANCE user_

```bash
su - tsmXYZ

db2 connect to tsmdb1

db2 "create system temporary tablespace TEMPSPACE1 pagesize 16k bufferpool ibmdefaultbp"
db2 "create system temporary tablespace LGTMPTSP pagesize 32k bufferpool largebufpool1"
db2 "drop tablespace REORG8K"
db2 "drop tablespace REORG16K"
db2 "drop tablespace REORG32K"
db2 update db cfg for tsmdb1 using auto_tbl_maint on

```

### [ ] Start the server in MAINT mode

```bash
su - tsmXYZ

cd /tsmXYZ/config

dsmserv MAINT
```

### [ ] Do runstats

> **recommended to use a screen!**
>
> ```bash
> screen -S RUNSTATS
> ```

```bash
su - tsmXYZ

db2 connect to tsmdb1

db2 "RUNSTATS ON TABLE tsmdb1.ACTIVITY_LOG WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"
db2 "RUNSTATS ON TABLE tsmdb1.AF_BITFILES WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"
db2 "RUNSTATS ON TABLE tsmdb1.AF_SEGMENTS WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"
db2 "RUNSTATS ON TABLE tsmdb1.ARCHIVE_OBJECTS WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"
db2 "RUNSTATS ON TABLE tsmdb1.AS_SEGMENTS WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"

db2 "RUNSTATS ON TABLE tsmdb1.BACKUP_OBJECTS WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"
db2 "RUNSTATS ON TABLE tsmdb1.BF_AGGREGATED_BITFILES WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"
db2 "RUNSTATS ON TABLE tsmdb1.BF_AGGREGATE_ATTRIBUTES WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"
db2 "RUNSTATS ON TABLE tsmdb1.BF_BITFILE_EXTENTS WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"

db2 "RUNSTATS ON TABLE tsmdb1.EXPORT_OBJECTS WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"
db2 "RUNSTATS ON TABLE tsmdb1.GROUP_LEADERS WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"

db2 "RUNSTATS ON TABLE tsmdb1.SC_OBJECT_TRACKER WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"
db2 "RUNSTATS ON TABLE tsmdb1.REPLICATED_OBJECTS WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"

db2 "RUNSTATS ON TABLE tsmdb1.TSMMON_STATUS WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"
```

Hint: once again, copy a trailing blank line :-)

### [ ] Monitor Runstats

> **suggested to use a screen!**
>
> ```bash
> screen -S WATCH
> ```

```bash
su tsmXYZ

db2 connect to tsmdb1

watch 'db2pd -d tsmdb1 -runstats | grep -A3 -B3 "In Progress"'
```

> [!IMPORTANT]
>
> **as long as this command shows anything, the runstats are still running**

### [ ] WAIT FOR RUNSTATS TO COMPLETE

**DO NOT RESTART instance as long as runstats are still running!**

### [ ] Either (re)start server in operational mode or go on in MAINT-Mode

### [ ] Free space using "alter tablespace"

- do new analysis using the perl script again

```bash
su - tsmXYZ

cd /OfflineReOrg/tsmXYZ

perl /OfflineReOrg/bin/analyze_DB2_formulas.pl
```

- look for free space (Example)

  ```bash
  tsmXYZ@tsmhostX:/OfflineReOrg/tsmXYZ> cat <newest folder>/summary.out 
  BEGIN SUMMARY
  "db2 alter tablespace USERSPACE1 reduce max" will return = 38.6G to the operating system file system
  "db2 alter tablespace IDXSPACE1 reduce max" will return = 40.3G to the operating system file system
  "db2 alter tablespace BACKOBJDATASPACE reduce max" will return =178.0G to the operating system file system
  "db2 alter tablespace BACKOBJIDXSPACE reduce max" will return =291.6G to the operating system file system
  "db2 alter tablespace BFBFEXTDATASPACE reduce max" will return =  9.2G to the operating system file system
  "db2 alter tablespace BFBFEXTIDXSPACE reduce max" will return = 76.3G to the operating system file system
  If BACKUP_OBJECTS were to be off line reorganized the estimated savings is Table   16 GB, Index    0 GB
  If BF_AGGREGATED_BITFILES were to be off line reorganized the estimated savings is Table    1 GB, Index    0 GB
  If AS_SEGMENTS were to be off line reorganized the estimated savings is Table    0 GB, Index    0 GB
  If GROUP_LEADERS were to be off line reorganized the estimated savings is Table    0 GB, Index    0 GB
  If AF_BITFILES were to be off line reorganized the estimated savings is Table    0 GB, Index    0 GB
  If EXPORT_OBJECTS were to be off line reorganized the estimated savings is Table    0 GB, Index    0 GB
  If AF_SEGMENTS were to be off line reorganized the estimated savings is Table    0 GB, Index    0 GB
  Total estimated savings 17 GB
  END SUMMARY
  ```

- free space as suggested

  ```bash
  su - tsmXYZ

  db2 connect to tsmdb1

  db2 alter tablespace USERSPACE1 reduce max
  db2 alter tablespace IDXSPACE1 reduce max
  db2 alter tablespace BACKOBJDATASPACE reduce max
  db2 alter tablespace BACKOBJIDXSPACE reduce max
  db2 alter tablespace BFBFEXTDATASPACE reduce max
  db2 alter tablespace BFBFEXTIDXSPACE reduce max

  ```

### [ ] restart server in operational mode if not already done

### [ ] check if empty and remove folders for temporary tables

```bash
tpath=/tstageX

ls -la /temp*-*K/

rm -f /temp1-8K  && rm -rf $tpath/temp1-8K
rm -f /temp2-16K && rm -rf $tpath/temp2-16K
rm -f /temp3-32K && rm -rf $tpath/temp3-32K
```

### [ ] Check if usage of db-volumes is decreasing

```bash
df -k /db*

watch "df -k /db*"
```

or issue periodically (inside dsm admin CLI)

```dsmadmc
q dbs
```

### Sources

[1] Analysis script as mentioned above:

- [Version 1.14](https://www.ibm.com/support/pages/sites/default/files/inline-files/$FILE/analyze_DB2_formulas_v1_14.zip)

- [Version 1.15](https://www.ibm.com/support/pages/system/files/inline-files/analyze_DB2_formulas_v1_15.zip)

[2] DB2 scripts: <https://github.com/bnw4cristie/TSM-Tricks/tree/main/DB2>

[3] [IBM extended Guide to DB2 offline Reorg](https://www.ibm.com/support/pages/resolving-and-preventing-issues-related-database-growth-and-degraded-performance-tivoli-storage-manager-v711200-and-later-servers#offline_table)

[4] [GNU Screen Project](https://www.gnu.org/software/screen/)
