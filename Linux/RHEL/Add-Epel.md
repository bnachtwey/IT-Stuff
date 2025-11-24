# Adding the EPEL Repo to ..

(tested with [AlmaLinux](https://almalinux.org/))

See https://docs.fedoraproject.org/en-US/epel/getting-started/

## .. RHEL8

```bash
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
```

## .. RHEL9


- CentOS 9, AlmaLinux 9

  ```bash
  sudo dnf config-manager --set-enabled crb && sudo  dnf install https://dl.fedoraproject.org/pub/epel/epel{,-next}-release-latest-9.noarch.rpm
  ```

- RHEL 9

  ```bash
  ```

## .. RHEL10

- CentOS Stream 10

  ```bash
  sudo dnf config-manager --set-enabled crb && sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
  ```

- RHEL 10

  ```bash
   sudo subscription-manager repos --enable codeready-builder-for-rhel-10-$(arch)-rpms
   sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
  ```
