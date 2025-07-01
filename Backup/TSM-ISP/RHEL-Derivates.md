<!---
(C) 2025 Bjørn Nachtwey, Cristie Data GmbH
-->

# ISP Derivates Issues
Using not *real Redhat Entprise Linux 9*, but derivates like [*AlmaLinux*](https://almalinux.org/get-almalinux/), [Oracle Linux](https://yum.oracle.com/oracle-linux-isos.html) or [*Rocky Linux*](https://rockylinux.org/download) you face a problem as *Storage Protect 8.1.23* (and newer version including 8.1.27) does allow to configure a database. This affects as well *plain new installations* as *in place updates*

## SUMMARY
- SP 8.1.23 and newer fails on install and update using RHEL9 derivates
- issue (and fix) is verified for AlmaLinux9.6, Oracle Linux R9-U6 and RockyLinux9.6
- error messages are misleading 
- root cause are missing `awslib-*`files in default path
- adding the RHEL9.2 path to the `ldconfig` solves the problem


---
---
# Complete analysis and error description and solution

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
  # locate libaws-cpp-sdk-s3.so | xargs -d '\n' md5sum | sort
  0b7fbe9bdb85863bf5fa4e58e7bb6b19  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/8.1/libaws-cpp-sdk-s3.so
  2e4d8e7e32c0067434f6ebae26b708b0  /opt/tivoli/tsm/db2/lib64/awssdk/SLES/15.1/libaws-cpp-sdk-s3.so
  36ece243e2fb63256582746bf82c7eec  /opt/tivoli/tsm/db2/lib64/awssdk/UBUNTU/22.04/libaws-cpp-sdk-s3.so
  408de9b1100cd81a8bb83447d426a961  /opt/tivoli/tsm/db2/lib64/awssdk/UBUNTU/24.04/libaws-cpp-sdk-s3.so
  4f01191ca070667474edc3b2251e06e4  /opt/tivoli/tsm/db2/lib64/awssdk/UBUNTU/20.04/libaws-cpp-sdk-s3.so
  753f1432c4e094d3f75693f9a5204825  /opt/tivoli/tsm/db2/lib64/awssdk/UBUNTU/18.04/libaws-cpp-sdk-s3.so
  8f547b8179f8bac2b7c8868d2f959e6b  /opt/tivoli/tsm/db2/lib64/awssdk/SLES/12.4/libaws-cpp-sdk-s3.so
  b83228600d80513baad12bc2e79f5159  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/9.2/libaws-cpp-sdk-s3.so
  b83228600d80513baad12bc2e79f5159  /opt/tivoli/tsm/db2/lib64/libaws-cpp-sdk-s3.so
  d0b1bc7916f0efb2b1add791fb0b5135  /opt/tivoli/tsm/db2/lib64/awssdk/RHEL/7.6/libaws-cpp-sdk-s3.so
  ```

  So, the *"missing lib"* and the one from the *`RHEL9.2` folder* are binary identical.