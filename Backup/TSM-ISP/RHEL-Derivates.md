<!---
(C) 2025 Bjørn Nachtwey, Cristie Data GmbH
-->

# ISP Derivates Issues

Using not *real Redhat Entprise Linux 9*, but derivates like [*AlmaLinux*](https://almalinux.org/get-almalinux/) or [*Rocky Linux*](https://rockylinux.org/download) you face a problem as *Storage Protect 8.1.23* (and newer version including 8.1.27) does allow to configure a database. This affects as well *plain new installations* as *in place updates*

> [!INFO]
>
> Testing with [Oracle Linux](https://yum.oracle.com/oracle-linux-isos.html), the problem *does not* occur.

## SUMMARY

- SP 8.1.23 and newer fails on install and update using RHEL9 derivates
- issue (and fix) is verified for *AlmaLinux9.6* and *RockyLinux9.6*, *Oracle Linux R9-U6* is not affected
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

Trying to update or newly install ISP 8.1.23+, the database operation fail on starting the database manager, unfortunately the error messsage is not very helpful as it reports an *I/O error* due to *access problems* (Example from installation of SP8.1.26)

```bash
ANR0236E Fail to start the database manager due to an I/0 error. Check for
filesystem full conditions, file permissions, and operating system errors.
ANR0162W Supplemental database diagnostic information:  -1:08001:-1032
([IBM][CLI Driver] SQL1032N  No start database manager command was issued. 
SQLSTATE=57019
).
ANR2678E Server database format failed.
```

Attempts to trace the system calls with strace fail due to my limited knowledge on `strace`, so I decided to do some other checks first, starting with:

- Cross check with ldd
  A first hint to the real root cause you get when checking the library links:

  ```bash
  [tsm@tsm ~]$ ldd ~/sqllib/adm/db2start | grep "not found"
          libaws-cpp-sdk-transfer.so => not found
          libaws-cpp-sdk-s3.so => not found
          libaws-cpp-sdk-core.so => not found
          libaws-cpp-sdk-kinesis.so => not found
  ```

  So it seems, these libs are missing and therefore the `db2start` fails.

- search for missing libs, e.g. `libaws-cpp-sdk-s3.so`

  ```bash
  # locate libaws-cpp-sdk-s3.so
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

  So these libs *are* available, but only in subfolders and not in the default library path `/opt/tivoli/tsm/db2/lib64/` :-(

- cross check with *original RHEL9.6*

  Using original RHEL9.6, the libs mentioned above *are* located at `/opt/tivoli/tsm/db2/lib64/`.

  ```bash
  # locate libaws-cpp-sdk-s3.so
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

  => As it seems, *the location* may cause the problem.

- check if the subfolders contain the *"correct lib"* versions

  compare *md5sum* of "missing libs" in RHEL9.6 system:

  ```bash
  # locate libaws-cpp-sdk-s3.so | grep -v SLES | grep -v UBUNTU |  xargs -d '\n' md5sum 
  b83228600d80513baad12bc2e79f5159  /opt/tivoli/tsm/db2/lib64/libaws-cpp-sdk-s3.so
  d0b1bc7916f0efb2b1add791fb0b5135  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/7.6/libaws-cpp-sdk-s3.so
  0b7fbe9bdb85863bf5fa4e58e7bb6b19  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/8.1/libaws-cpp-sdk-s3.so
  b83228600d80513baad12bc2e79f5159  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/9.2/libaws-cpp-sdk-s3.so
  ```

  So, the *"missing lib"* and the one from the *`RHEL9.2` folder* are *binary identical*.

## Fixing the issue, adding the missing libs

### Attempt 1: add using yum or dnf?

Nope, no such library packages available

### Attempt 2: add using rpm and packages?

Nope, *rpmseek* located at `https://rpm.pbone.net` does not find at least `libaws-cpp-sdk-s3.so` for AlmaLinux9 nor RockyLinux9 :-(

```
FILE WASN'T FOUND IN ANY RPM FILE. TRYING TO SEARCH THIS FILE ON FTP SERVERS
You have chosen search rpm in world FTP resources.
Your search libaws-cpp-sdk-s3.so did not match any entry in database.
If you didn't do it, try add to searched space more distributions and repositories.
```

### Attempt 3: just copy the files

Copying the files from `/opt/tivoli/tsm/db2/lib64/awssdk/RHEL/9.2/` to `/opt/tivoli/tsm/db2/lib64/` does unfortunately not solve the issue.

The `ldd` still fails, `dsmserv` does not work :-(

### Attempt 4: Using the *Ubuntu Fix*

Since ever running the SP server on Ubuntu fails as some libaries are not included in the `LD_LIBRARY_PATH`

Try to fix this issue the same way:

```bash
echo "# aws library addon for derivates" > /etc/ld.so.conf.d/RHEL4TSM.conf
echo "/opt/tivoli/tsm/db2/lib64/awssdk/RHEL/9.2" >> /etc/ld.so.conf.d/RHEL4TSM.conf

ldconfig
```
