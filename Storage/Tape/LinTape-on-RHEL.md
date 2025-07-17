# Notes on installing LinTape on RHEL
🚧
> [!WARNING]<br>
> IBM is always a litte late, so the newest *LinTape* driver typically does not support the actual RHEL version.
>
> And whenever IBM fixes this, RedHat has released a new version and therefore the problem persists :-(

## Basic installation steps

### getting the driver package

get the LinTape package from [IBM FIX CENTRAL](https://www.ibm.com/support/fixcentral/), using **:
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
1) install the `taped` daemon:<br>
   ```bash
   rpm -hiv lin_taped-3.0.69-rhel9.x86_64.rpm
   rpm -hiv lin_tape-3.0.69-1.src.rpm
   ```
2) Build the new kernel module package from the source package<br>
   ```bash
   rpmbuild --rebuild lin_tape-3.0.69-1.src.rpm
   ```
3) Install the new module from the new rpm
   - look for the "Wrote" line in the output of the build process, e.g. piping it's output into a `grep` ;-)<br>
     ```bash
     rpmbuild --rebuild lin_tape-3.0.69-1.src.rpm 2>&1 | grep "^Wrote"
     ```
🚧
## Coping IBM beeing behind the RHEL releases

### RHEL9.5 and LinTape 3.0.68
Although Lintape 3.0.69 fixed this issue, let's have a look on it and how a workaround may look like 
🚧
### RHEL9.6 and LinTape 3.0.69
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

#### 1st Attempt: "rename RHEL9.6 to RHEL9.5"
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

#### 2nd Attempt: Add clause for RHEL96 to makefile

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
