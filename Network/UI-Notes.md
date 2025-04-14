# Notes on using Ubiquiti Network components
- [A Comparision of many UI switches](https://evanmccann.net/blog/ubiquiti/unifi-comparison-charts)

🚧
## getting the linux Network management Server
https://ui.com/download/unifi/linux/download-started

## 1. attempt to install into debian 12 LXC container
- do update & upgrade

- get package
-  wget https://dl.ui.com/unifi/9.0.108/unifi_sysvinit_all.deb

<<<<<<< HEAD
-  try to install
=======
-  install prerequisites<br>
   ```bash
   apt --fix-broken install
   apt-get install binutils curl mongodb-server mongodb-10gen ongodb-org-server
   ```


https://help.ui.com/hc/en-us/articles/220066768-Updating-and-Installing-Self-Hosted-UniFi-Network-Servers-Linux


```bash
apt-get install gnupg

```

>>>>>>> a31bf9e (just added)
```bash
# dpkg -i unifi_sysvinit_all.deb 
Selecting previously unselected package unifi.
(Reading database ... 19138 files and directories currently installed.)
Preparing to unpack unifi_sysvinit_all.deb ...
Unpacking unifi (9.0.108-27982-1) ...
dpkg: dependency problems prevent configuration of unifi:
 unifi depends on binutils; however:
  Package binutils is not installed.
 unifi depends on curl; however:
  Package curl is not installed.
 unifi depends on mongodb-server (>= 1:3.6.0) | mongodb-10gen (>= 3.6.0) | mongodb-org-server (>= 3.6.0); however:
  Package mongodb-server is not installed.
  Package mongodb-10gen is not installed.
  Package mongodb-org-server is not installed.
 unifi depends on mongodb-server (<< 1:8.1.0) | mongodb-10gen (<< 8.1.0) | mongodb-org-server (<< 8.1.0); however:
  Package mongodb-server is not installed.
  Package mongodb-10gen is not installed.
  Package mongodb-org-server is not installed.
 unifi depends on openjdk-17-jre-headless | temurin-17-jre | openjdk-21-jre-headless | temurin-21-jre; however:
  Package openjdk-17-jre-headless is not installed.
  Package temurin-17-jre is not installed.
  Package openjdk-21-jre-headless is not installed.
  Package temurin-21-jre is not installed.

dpkg: error processing package unifi (--install):
 dependency problems - leaving unconfigured
Errors were encountered while processing:
 unifi
```
-  
