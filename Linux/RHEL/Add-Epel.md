# Adding the EPEL Repo to ..

(tested with [AlmaLinux](https://almalinux.org/))

See https://docs.fedoraproject.org/en-US/epel/getting-started/

## .. RHEL8

```bash
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
```

## .. RHEL9

Approach for Centos9 works fine with AlmaLinux:

```bash
sudo dnf config-manager --set-enabled crb && sudo  dnf install https://dl.fedoraproject.org/pub/epel/epel{,-next}-release-latest-9.noarch.rpm
```

## .. RHEL10

not testes with Alma yet :-(

```bash
sudo dnf config-manager --set-enabled crb && sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
```
