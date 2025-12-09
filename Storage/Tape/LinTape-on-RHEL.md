# Notes on installing LinTape on RHEL

> [!NOTE]
> 
> IBM is always a litte late, so the newest *LinTape* driver typically does not support the actual RHEL version.
>
> And whenever IBM fixes this, RedHat has released a new version and therefore the problem persists :-(

## Basic installation steps

### getting the driver package

get the LinTape package from [IBM FIX CENTRAL](https://www.ibm.com/support/fixcentral/):

- select as *Product selector*: `Tape device drivers`
- select as *Platform*: `Linux 64-bit,x86_64`
- *continue*
- select the ones you're looking for, e.g. *RHEL9*<br>
  ![](FixCentral-TapeDrivers-Selection.png)
- *continue* (at the very bottom of that page, scroll down)
- *Log in with your IBM credentials*
- Choose your Download option  

### installing and building the kernel module

The installation splits in three steps:

1) install the `taped` daemon:

   ```bash
   rpm -hiv lin_taped-3.0.69-rhel9.x86_64.rpm
   rpm -hiv lin_tape-3.0.69-1.src.rpm
   ```
   
2) Build the new kernel module package from the source package

   ```bash
   rpmbuild --rebuild lin_tape-3.0.69-1.src.rpm
   ```
   
4) Install the new module from the new rpm

   look for the "Wrote" line in the output of the build process, e.g. piping it's output into a `grep` ;-)

   ```bash
   rpmbuild --rebuild lin_tape-3.0.69-1.src.rpm 2>&1 | grep "^Wrote"
   ```

## Coping IBM beeing behind the RHEL releases

### Workaround 1

Sometimes it works if you just replace the version number in the `/etc/os-release` with an older one for which the building of lin_tape work, .e.g.

```bash
sed -i 's/9.4/9.5/g' /etc/*release
```

Unfortunately, this does not work always :-(

### Workaround 2

Another approach is to add annother `if` clause to the makefile. T.B.D.

----

### Logbook on attempts in Detail

#### RHEL9.5 and LinTape 3.0.68
Although Lintape 3.0.69 fixed this issue, let's have a look on it and how a workaround may look like 

AFAIR, *Workaroung 2* worked.

#### RHEL9.6 and LinTape 3.0.69
Running `rpmbuild --rebuild lin_tape-3.0.69-1.src.rpm` the compilation fails with

```bash
make[2]: Entering directory '/usr/src/kernels/5.14.0-570.25.1.el9_6.x86_64'
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.69/join.o
/root/rpmbuild/BUILD/lin_tape-3.0.69/join.c: In function 'join_add':
/root/rpmbuild/BUILD/lin_tape-3.0.69/join.c:174:18: error: too many arguments to function 'join_class_intf.add_dev'
  174 |         result = join_class_intf.add_dev(dev, intf);
      |                  ^~~~~~~~~~~~~~~
/root/rpmbuild/BUILD/lin_tape-3.0.69/join.c: In function 'join_remove':
/root/rpmbuild/BUILD/lin_tape-3.0.69/join.c:188:9: error: too many arguments to function 'join_class_intf.remove_dev'
  188 |         join_class_intf.remove_dev(dev, intf);
      |         ^~~~~~~~~~~~~~~
make[3]: *** [scripts/Makefile.build:249: /root/rpmbuild/BUILD/lin_tape-3.0.69/join.o] Error 1
make[2]: *** [Makefile:1947: /root/rpmbuild/BUILD/lin_tape-3.0.69] Error 2
make[2]: Leaving directory '/usr/src/kernels/5.14.0-570.25.1.el9_6.x86_64'
make[1]: *** [Makefile:97: lin_tape.ko] Error 2
make[1]: Leaving directory '/root/rpmbuild/BUILD/lin_tape-3.0.69'
make: *** [Makefile:136: bldtmp/lin_tape-5.14.0-570.25.1.el9_6.x86_64.ko] Error 2
error: Bad exit status from /var/tmp/rpm-tmp.DbBIcM (%build)
```

##### 1st Attempt: "rename RHEL9.6 to RHEL9.5"
As there's no statement for `RHEL96` in the Makefile, just rename the os by
```bash
sed -i 's/9.5/9.6/g' /etc/*release
```
but ...
*Make* successfully starts and then fails again
```bash
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.69/lin_tape_scsi_tape.o
In file included from /root/rpmbuild/BUILD/lin_tape-3.0.69/lin_tape_scsi_tape.c:23:
/root/rpmbuild/BUILD/lin_tape-3.0.69/lin_tape_scsi_ioctl.h:1672: warning: "MAX_PAGE_ORDER" redefined
 1672 | #define MAX_PAGE_ORDER (8)
      |
In file included from ./include/linux/gfp.h:7,
                 from ./include/linux/xarray.h:15,
                 from ./include/linux/radix-tree.h:19,
                 from ./include/linux/idr.h:15,
                 from ./include/linux/kernfs.h:13,
                 from ./include/linux/sysfs.h:16,
                 from ./include/linux/kobject.h:20,
                 from ./include/linux/energy_model.h:7,
                 from ./include/linux/device.h:16,
                 from /root/rpmbuild/BUILD/lin_tape-3.0.69/lin_tape_scsi_tape.h:26,
                 from /root/rpmbuild/BUILD/lin_tape-3.0.69/lin_tape_scsi_tape.c:22:
./include/linux/mmzone.h:30: note: this is the location of the previous definition
   30 | #define MAX_PAGE_ORDER 10
      |
/root/rpmbuild/BUILD/lin_tape-3.0.69/lin_tape_scsi_tape.c: In function ‘lin_tape_get_user_pages’:
/root/rpmbuild/BUILD/lin_tape-3.0.69/lin_tape_scsi_tape.c:11574:38: error: too many arguments to function ‘get_user_pages’
11574 |                                               rw, pages, NULL);
      |                                      ^        ~~~~~
In file included from /root/rpmbuild/BUILD/lin_tape-3.0.69/lin_tape_tape.h:26,
                 from /root/rpmbuild/BUILD/lin_tape-3.0.69/lin_tape_scsi_tape.h:27,
                 from /root/rpmbuild/BUILD/lin_tape-3.0.69/lin_tape_scsi_tape.c:22:
./include/linux/mm.h:2534:6: note: declared here
 2534 | long get_user_pages(unsigned long start, unsigned long nr_pages,
      |      ^~~~~~~~~~~~~~
make[2]: *** [scripts/Makefile.build:249: /root/rpmbuild/BUILD/lin_tape-3.0.69/lin_tape_scsi_tape.o] Error 1
make[1]: *** [Makefile:1947: /root/rpmbuild/BUILD/lin_tape-3.0.69] Error 2
make[1]: Leaving directory '/usr/src/kernels/5.14.0-570.25.1.el9_6.x86_64'
make: *** [Makefile:97: default] Error 2
```
diffent point of failure, but not successfull in the end :-(

OK, was this was like a *shot for nothing*, the error above point to another problem at all

##### 2nd Attempt: Add clause for RHEL96 to makefile

Unfortunately the Makefile does not use any indention, so I first added some increase *human readability*:
```bash
RHELRELEASE := $(shell [ -f "/etc/redhat-release" ] && echo 1 || echo 0)
ifeq ($(RHELRELEASE), 1)
  KERNELDIR ?= /lib/modules/$(shell uname -r)/build
  KERNELVER = $(shell uname -r 2>/dev/null|sed "s/[\.-]/_/g"|sed "s/\([0-9]*_[0-9]*_[0-9]*_[0-9]*\).*/\1/")
  EXTRA_CFLAGS += -DKERNELVERSION_${KERNELVER}
  RHEL94 := $(shell grep -qi 9.4 /etc/*release && echo 1 || echo 0)
  ifeq ($(RHEL94), 1)
    EXTRA_CFLAGS += -DRHEL94
  else
    RHEL95 := $(shell grep -qi 9.5 /etc/*release && echo 1 || echo 0)
    ifeq ($(RHEL95), 1)
      EXTRA_CFLAGS += -DRHEL94
      EXTRA_CFLAGS += -DRHEL95
    endif
  endif
else
```
then I added a line for RHEL9.6 and extended the `ifeq` clause
```bash
  else
    RHEL95 := $(shell grep -qi 9.5 /etc/*release && echo 1 || echo 0)
    RHEL96 := $(shell grep -qi 9.6 /etc/*release && echo 1 || echo 0)
    ifeq ($(filter 1, $(RHEL95) $(RHEL96)), 1)
      EXTRA_CFLAGS += -DRHEL94
      EXTRA_CFLAGS += -DRHEL95
    endif
```
Same error as without any changes
```bash
# make -f /root/Makefile
export PWD
make -C /lib/modules/5.14.0-570.25.1.el9_6.x86_64/build M=/root/rpmbuild/BUILD/lin_tape-3.0.69 PWD=/root/rpmbuild/BUILD/lin_tape-3.0.69 modules
make[1]: Entering directory '/usr/src/kernels/5.14.0-570.25.1.el9_6.x86_64'
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.69/join.o
/root/rpmbuild/BUILD/lin_tape-3.0.69/join.c: In function ‘join_add’:
/root/rpmbuild/BUILD/lin_tape-3.0.69/join.c:174:18: error: too many arguments to function ‘join_class_intf.add_dev’
  174 |         result = join_class_intf.add_dev(dev, intf);
      |                  ^~~~~~~~~~~~~~~
/root/rpmbuild/BUILD/lin_tape-3.0.69/join.c: In function ‘join_remove’:
/root/rpmbuild/BUILD/lin_tape-3.0.69/join.c:188:9: error: too many arguments to function ‘join_class_intf.remove_dev’
  188 |         join_class_intf.remove_dev(dev, intf);
      |         ^~~~~~~~~~~~~~~
make[2]: *** [scripts/Makefile.build:249: /root/rpmbuild/BUILD/lin_tape-3.0.69/join.o] Error 1
make[1]: *** [Makefile:1947: /root/rpmbuild/BUILD/lin_tape-3.0.69] Error 2
make[1]: Leaving directory '/usr/src/kernels/5.14.0-570.25.1.el9_6.x86_64'
make: *** [/root/Makefile:98: default] Error 2
```

#### RHEL 9.7 and LinTape 3.0.71

I used a *Rocky Linux 9.7* but no *RHEL 9.7*.

##### 1st Attempt using *Workaround 1*

```bash
# sed -i 's/9.7/9.6/g' /etc/*release

# grep VERSION /etc/os-release
VERSION="9.6 (Blue Onyx)"
VERSION_ID="9.6"
ROCKY_SUPPORT_PRODUCT_VERSION="9.6"
REDHAT_SUPPORT_PRODUCT_VERSION="9.6"
```

and works :

```bash
# rpmbuild  --rebuild lin_tape-3.0.71-1.src.rpm
Installing lin_tape-3.0.71-1.src.rpm
setting SOURCE_DATE_EPOCH=1690848000
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.us90pi
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd /root/rpmbuild/BUILD
+ rm -rf lin_tape-3.0.71
+ /usr/bin/gzip -dc /root/rpmbuild/SOURCES/lin_tape-3.0.71.tgz
+ /usr/bin/tar -xof -
+ STATUS=0
+ '[' 0 -ne 0 ']'
+ cd lin_tape-3.0.71
+ /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
+ RPM_EC=0
++ jobs -p
+ exit 0
Executing(%build): /bin/sh -e /var/tmp/rpm-tmp.Hdcd5R
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd lin_tape-3.0.71
++ echo x86_64-redhat-linux-gnu
++ cut -f 1 -d -
+ p=x86_64
+ '[' x86_64 == i386 ']'
+ '[' x86_64 == i586 ']'
+ '[' x86_64 == i686 ']'
+ '[' x86_64 == ppc64 ']'
+ '[' x86_64 == powerpc ']'
+ '[' x86_64 == powerpc64 ']'
+ '[' x86_64 == s390 ']'
+ '[' x86_64 == s390x ']'
+ '[' x86_64 == ia64 ']'
+ '[' x86_64 == x86_64 ']'
+ proc=AMD
+ make KERNEL=5.14.0-611.11.1.el9_7.x86_64 PROC=x86_64 SFMP=0 driver
make -C /lib/modules/5.14.0-611.11.1.el9_7.x86_64/build M=/root/rpmbuild/BUILD/lin_tape-3.0.71 PWD=/root/rpmbuild/BUILD/lin_tape-3.0.71 clean
make[1]: Entering directory '/usr/src/kernels/5.14.0-611.11.1.el9_7.x86_64'
make[1]: Leaving directory '/usr/src/kernels/5.14.0-611.11.1.el9_7.x86_64'
mkdir bldtmp
make KERNEL=5.14.0-611.11.1.el9_7.x86_64 compileclean lin_tape.ko
make[1]: Entering directory '/root/rpmbuild/BUILD/lin_tape-3.0.71'
rm -f *.o
export PWD
make -C /lib/modules/5.14.0-611.11.1.el9_7.x86_64/build M=/root/rpmbuild/BUILD/lin_tape-3.0.71 PWD=/root/rpmbuild/BUILD/lin_tape-3.0.71 modules
make[2]: Entering directory '/usr/src/kernels/5.14.0-611.11.1.el9_7.x86_64'
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/join.o
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/lin_tape_scsi_config.o
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/lin_tape_scsi_tape.o
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/lin_tape_scsi_trace.o
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/lin_tape_ioctl_tape.o
sed -i 's/9.7/9.6/g' /etc/*release  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/lin_tape_ioctl_changer.o
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/lin_tape_extra_ioctl.o
  LD [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/lin_tape.o
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/resolve_ibm_hp.o
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/fo_util.o
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/upper.o
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/lower.o
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/intercept.o
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/trace.o
  LD [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/pfo.o
  MODPOST /root/rpmbuild/BUILD/lin_tape-3.0.71/Module.symvers
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/lin_tape.mod.o
  LD [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/lin_tape.ko
  BTF [M] /root/rpmbuild/BUILD/lin_tape-3.0.71/lin_tape.ko
Skipping BTF generation for /root/rpmbuild/BUILD/lin_tape-3.0.71/lin_tape.ko due to unavailability of vmlinux
  CC [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/pfo.mod.o
  LD [M]  /root/rpmbuild/BUILD/lin_tape-3.0.71/pfo.ko
  BTF [M] /root/rpmbuild/BUILD/lin_tape-3.0.71/pfo.ko
Skipping BTF generation for /root/rpmbuild/BUILD/lin_tape-3.0.71/pfo.ko due to unavailability of vmlinux
make[2]: Leaving directory '/usr/src/kernels/5.14.0-611.11.1.el9_7.x86_64'
make[1]: Leaving directory '/root/rpmbuild/BUILD/lin_tape-3.0.71'
mv lin_tape.ko bldtmp/lin_tape-5.14.0-611.11.1.el9_7.x86_64.ko
mv pfo.ko bldtmp/pfo-5.14.0-611.11.1.el9_7.x86_64.ko
+ RPM_EC=0
++ jobs -p
+ exit 0
Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.XFD0N1
+ umask 022
+ cd /root/rpmbuild/BUILD
+ '[' /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64 '!=' / ']'
+ rm -rf /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64
++ dirname /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64
+ mkdir -p /root/rpmbuild/BUILDROOT
+ mkdir /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64
+ cd lin_tape-3.0.71
+ rm -rf /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64
+ install -D -m 644 bldtmp/pfo-5.14.0-611.11.1.el9_7.x86_64.ko /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64/lib/modules/5.14.0-611.11.1.el9_7.x86_64/kernel/drivers/scsi/pfo.ko
+ install -D -m 644 bldtmp/lin_tape-5.14.0-611.11.1.el9_7.x86_64.ko /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64/lib/modules/5.14.0-611.11.1.el9_7.x86_64/kernel/drivers/scsi/lin_tape.ko
+ install -D -m 755 lin_tape /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64/usr/sbin/lin_tape
+ install -D -m 666 IBM_tape.h /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64/usr/include/sys/IBM_tape.h
+ install -D -m 0644 lin_tape.service /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64/usr/lib/systemd/system/lin_tape.service
+ cd /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64
+ cd -
/root/rpmbuild/BUILD/lin_tape-3.0.71
+ /usr/lib/rpm/check-buildroot
+ /usr/lib/rpm/redhat/brp-ldconfig
+ /usr/lib/rpm/brp-compress
+ /usr/lib/rpm/brp-strip /usr/bin/strip
+ /usr/lib/rpm/brp-strip-comment-note /usr/bin/strip /usr/bin/objdump
+ /usr/lib/rpm/redhat/brp-strip-lto /usr/bin/strip
+ /usr/lib/rpm/brp-strip-static-archive /usr/bin/strip
+ /usr/lib/rpm/redhat/brp-python-bytecompile '' 1 0
+ /usr/lib/rpm/brp-python-hardlink
+ /usr/lib/rpm/redhat/brp-mangle-shebangs
mangling shebang in /usr/sbin/lin_tape from /bin/bash to #!/usr/bin/bash
Processing files: lin_tape-3.0.71-1.x86_64
Executing(%doc): /bin/sh -e /var/tmp/rpm-tmp.KrUrlb
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd lin_tape-3.0.71
+ DOCDIR=/root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64/usr/share/doc/lin_tape
+ export LC_ALL=C
+ LC_ALL=C
+ export DOCDIR
+ /usr/bin/mkdir -p /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64/usr/share/doc/lin_tape
+ cp -pr lin_tape.ReadMe /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64/usr/share/doc/lin_tape
+ cp -pr lin_tape_daemon.ReadMe /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64/usr/share/doc/lin_tape
+ cp -pr COPYING /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64/usr/share/doc/lin_tape
+ cp -pr COPYING.LIB /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64/usr/share/doc/lin_tape
+ RPM_EC=0
++ jobs -p
+ exit 0
Provides: lin_tape = 3.0.71-1 lin_tape(x86-64) = 3.0.71-1
Requires(interp): /bin/sh /bin/sh /bin/sh /bin/sh
Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
Requires(pre): /bin/sh
Requires(post): /bin/sh
Requires(preun): /bin/sh
Requires(postun): /bin/sh
Conflicts: lin_tape < 3.0.71
Checking for unpackaged file(s): /usr/lib/rpm/check-files /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64
Wrote: /root/rpmbuild/RPMS/x86_64/lin_tape-3.0.71-1.x86_64.rpm
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.xyspD3
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd lin_tape-3.0.71
+ rm -rf /root/rpmbuild/BUILDROOT/lin_tape-3.0.71-1.x86_64
+ RPM_EC=0
++ jobs -p
+ exit 0
Executing(--clean): /bin/sh -e /var/tmp/rpm-tmp.4abohg
+ umask 022
+ cd /root/rpmbuild/BUILD
+ rm -rf lin_tape-3.0.71
+ RPM_EC=0
++ jobs -p
+ exit 0
```

and

```bash
# rpm -hiv lin_taped-3.0.71-rhel9.x86_64.rpm /root/rpmbuild/RPMS/x86_64/lin_tape-3.0.71-1.x86_64.rpm
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:lin_tape-3.0.71-1                ################################# [ 50%]
Created symlink /etc/systemd/system/multi-user.target.wants/lin_tape.service → /usr/lib/systemd/system/lin_tape.service.
lin_tape loaded
   2:lin_taped-3.0.71-1               ################################# [100%]
Starting lin_tape...

lin_taped loaded
```

check

```
# lsmod | grep tape
lin_tape              724992  2
pfo                  1150976  1 lin_tape

# ps fax | grep tape
   7608 pts/0    S+     0:00                          \_ grep --color=auto tape
   7567 ?        Ss     0:00 /usr/bin/lin_taped start
```
