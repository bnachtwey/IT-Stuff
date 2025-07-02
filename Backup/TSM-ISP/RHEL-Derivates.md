<!--
##############################################################################
# changelog
# date          version remark
# 2025-07-02    0.1.    first version covering RHEL9 and SP up to 8.1.27
# 2025-06-27    0.0.1   initial version, shared with IBM
#
##############################################################################
#
#   https://github.com/bnachtwey/IT-Stuff/blob/main/Backup/TSM-ISP/RHEL-Derivates.md
#    
#   A short abstract on installing IBM Storage Protect on non-supported RHEL derivates
#
#   The Author:
#   (C) 2025        Bjørn Nachtwey, tsm@bjoernsoe.net
#
#   Grateful Thanks to the Company, that allowed me to do this
#   (C) 2025        Cristie Data Gmbh, www.cristie.de
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
# ISP Derivates Issues (and fix)

Using not *original [Redhat Entprise Linux 9](https://www.redhat.com/en/blog/install-linux-rhel-9) (TM)*, but derivates like [*AlmaLinux*](https://almalinux.org/get-almalinux/) or [*Rocky Linux*](https://rockylinux.org/download) you face a problem as *Storage Protect 8.1.23* (and newer version including 8.1.27) does allow to configure a database. This affects as well *plain new installations* as *in place updates*

> [!INFO]
>
> Testing with [Oracle Linux](https://yum.oracle.com/oracle-linux-isos.html), the problem *does not* occur.

## SUMMARY

- SP 8.1.23 and newer fails on install and update using RHEL9 derivates
- issue (and fix) is verified for *AlmaLinux9.6* and *RockyLinux9.6*, but *Oracle Linux R9-U6* is not affected
- error messages are misleading
- root cause are missing `awslib-*`files in default path
- adding the RHEL9.2 path to the `ldconfig` solves the problem

---
---

# Complete analysis and error description and solution

> [!INFO]
> The installation of TSM/SP on *RHEL derivates* fail always as some checks are not passed.
>
> You can bypass these checks by running the installation with an extra option `-DBYPASS_TSM_REQ_CHECKS=true`, e.g. call :
>
> ```bash
> ./install.sh -c -vmargs -DBYPASS_TSM_REQ_CHECKS=true
> ```

## Problem description

Trying to update or newly install ISP 8.1.23+, the database operation fails on starting the database manager.
Unfortunately the error messsage is not very helpful as it reports an *I/O error* due to *access problems* (Example taken from installation of SP8.1.26)

```bash
ANR0236E Fail to start the database manager due to an I/0 error. Check for
filesystem full conditions, file permissions, and operating system errors.
ANR0162W Supplemental database diagnostic information:  -1:08001:-1032
([IBM][CLI Driver] SQL1032N  No start database manager command was issued. 
SQLSTATE=57019).
ANR2678E Server database format failed.
```

Attempts to trace the system calls with `strace` fail due to my limited knowledge on `strace` ;-)

So I decided to do some other checks first, starting with:

- Cross check with `ldd`

  A first hint to the real root cause you get when checking the library links:

  ```bash
  $ ldd ~/sqllib/adm/db2start | grep "not found"
          libaws-cpp-sdk-transfer.so => not found
          libaws-cpp-sdk-s3.so => not found
          libaws-cpp-sdk-core.so => not found
          libaws-cpp-sdk-kinesis.so => not found
  ```

  So it seems, these libs are missing and therefore the `db2start` fails.

- Next, let's search for missing libs, e.g. `libaws-cpp-sdk-s3.so`

  ```bash
  $ locate libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/7.6/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/8.1/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/9.2/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/SLES/12.4/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/SLES/15.1/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/UBUNTU/18.04/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/UBUNTU/20.04/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/UBUNTU/22.04/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/UBUNTU/24.04/libaws-cpp-sdk-s3.so
  ```

  Well, these libs *are* available, but only in subfolders and not in the default library path `/opt/tivoli/tsm/db2/lib64/` :-(

- Do a cross check with *original RHEL9.6*

  Using original RHEL9.6, the libs mentioned above *are* also located at `/opt/tivoli/tsm/db2/lib64/`

  ```bash
  $ locate libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/7.6/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/8.1/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/9.2/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/SLES/12.4/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/SLES/15.1/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/UBUNTU/18.04/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/UBUNTU/20.04/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/UBUNTU/22.04/libaws-cpp-sdk-s3.so
  /opt/tivoli/tsm/db2/lib64/awssdk/UBUNTU/24.04/libaws-cpp-sdk-s3.so
  ```

  As it seems, *the location* may cause the problem.

- Let's check if the subfolders contain the *"correct lib"* versions

  compare *md5sum* of "missing libs" in RHEL9.6 system:

  ```bash
  $ locate libaws-cpp-sdk-s3.so | grep -v SLES | grep -v UBUNTU |  xargs -d '\n' md5sum 
  b83228600d80513baad12bc2e79f5159  /opt/tivoli/tsm/db2/lib64/libaws-cpp-sdk-s3.so
  d0b1bc7916f0efb2b1add791fb0b5135  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/7.6/libaws-cpp-sdk-s3.so
  0b7fbe9bdb85863bf5fa4e58e7bb6b19  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/8.1/libaws-cpp-sdk-s3.so
  b83228600d80513baad12bc2e79f5159  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/9.2/libaws-cpp-sdk-s3.so
  ```

  Obvoiusly the *"missing lib"* and the one from the *`RHEL9.2` folder* are *binary identical*.

## Fixing the issue, adding the missing libs

### Attempt 1: add missing libs using `yum` or `dnf`?

Nope, no such library packages available.

### Attempt 2: add using rpm and packages?

Nope, [*rpmseek*](https://rpm.pbone.net) does not find at least `libaws-cpp-sdk-s3.so` for AlmaLinux9 nor RockyLinux9 :-(

```
FILE WASN'T FOUND IN ANY RPM FILE. TRYING TO SEARCH THIS FILE ON FTP SERVERS
You have chosen search rpm in world FTP resources.
Your search libaws-cpp-sdk-s3.so did not match any entry in database.
If you didn't do it, try add to searched space more distributions and repositories.
```

No need to look for the other libs.

### Attempt 3: just copy the files

Copying the files from `/opt/tivoli/tsm/db2/lib64/awssdk/RHEL/9.2/` to `/opt/tivoli/tsm/db2/lib64/` does unfortunately not solve the issue.

The `ldd` still fails, `dsmserv` does not work :-(

### Attempt 4: Using the *Ubuntu Fix*

Running the SP server on Ubuntu *always* fails as some libaries are not included in the `LD_LIBRARY_PATH`

Try to fix this issue the same way:

```bash
echo "# aws library addon for derivates"          > /etc/ld.so.conf.d/RHEL4TSM.conf
echo "/opt/tivoli/tsm/db2/lib64/awssdk/RHEL/9.2" >> /etc/ld.so.conf.d/RHEL4TSM.conf

ldconfig
```

**WORKS :-)**

## last check: Update

Let's check if this workaround will also work for updating SP.

- Having a RockyLinux9.6 running SP8.1.22 and update to 8.1.23 (fix needed) ... **WORKS :-)**

- Fallback to Snapshot with 8.1.22 and try to update directly to 8.1.27 ... **WORKS :-)**



## Looking back: Why were there no problems with ISP up to version 8.1.22?

*I don't know!*

But, of course, I have an idea:

Well, there are no `libaws` files for RHEL9 at all:

```bash
$ ls -l /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/
total 0
drwxr-xr-x. 2 bin bin 98 Jan 12  2024 7.6
drwxr-xr-x. 2 bin bin 98 Jan 12  2024 8.1
```

so the `ldd $(which db2start)` does not fail on missing libs ...
```bash
$ ldd $(which db2start) | wc -l
64
$ ldd $(which db2start) | grep aws | wc -l
0
$ ldd $(which db2start) | grep "not" | wc -l
0
```

So perhaps, 8.1.22 does not need them?

well, the [*what's new* announcements](https://www.ibm.com/docs/en/storage-protect/8.1.27?topic=servers-whats-new) for 8.1.23 *does not metion AWS*:

```
8.1.23 -- Server

- Updated IBM Storage Protect server to use the following versions of the dependent software to address the security-related issues and vulnerabilities:
  - Db2 11.5.9 SB#40226
  - WebSphere Liberty Fix Pack 24.0.0.4
  - Logback jars v1.3.14
  - IBM Java™ Virtual Machine v8.0.8.21
  - Poco: 1.12.5p2-release
  - threetenbp lib 1.6.9
  - GO Crypto Lib 0.22.0
  - GO OpenSSL Lib 2.0.1
  - Installation Manager 1.9.2.8
- A number of APARs are included in this version of the product.
``` 

Well, AWS-Support was added in [8.1.8](http://www.ibm.com/support/knowledgecenter/SSEQVQ_8.1.8/srv.common/r_techchg_intelligenttier_818.html) and further S3 functionality in [8.1.15](https://www.ibm.com/docs/en/storage-protect/8.1.15?topic=servers-whats-new).

Even the [APAR list](https://www.ibm.com/support/pages/node/6447173#8123) does not menton neither *Amazon* nor *AWS* for 8.1.23.

**Sorry, no idea after all :-(**