# Disabling KVM Kernel module for Using Virtualbox


**T.B.D.**
## Problem

Running Virtualbox on a (nearly) plain Debian fails, as staring the machine throws an exeption like

```

```

## Workaround

To prevent this problem, you need to disable the `kvm` kernel module. There are at least three ways to do so:

### temporarily unload module

may not work if module is currently loaded, may also fail if module is loaded by default on system start (e.g. Debian Trixie)


### blacklist module


### disable module
