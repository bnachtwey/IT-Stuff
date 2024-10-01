# Silent Debian Package Upgrade

```
alias 'silentupgrade'=\
  'sudo apt-get update && \
   sudo DEBIAN_FRONTEND=noninteractive apt-get \
   -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef \
   -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
   upgrade'
```
and
```
alias 'silentdistupgrade'=\
  'sudo apt-get update &&\
   sudo DEBIAN_FRONTEND=noninteractive apt-get \
   -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef \
   -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
   dist-upgrade && \
   sudo apt-get -y autoremove'
```
