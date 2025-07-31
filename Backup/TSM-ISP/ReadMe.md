# Collecting everything according TSM / ISP

> [!TIP]
> **dsmci** ..
> .. has moved to it's own [repository](https://github.com/bnachtwey/dsmci)

> [!IMPORTANT]
> ## Security Information on SP
> - CVE issues fixed in given versions (also includes a list of APARs):<br>
>   https://www.ibm.com/support/pages/node/6447173

## IBM FTP Server for Downloading Clients and Server Fixes
- Clients:<br>
    https://ftp.software.ibm.com/storage/tivoli-storage-management/maintenance/client/
- Server Patches<br>
    https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/
- OC Patches<br>
    https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/opcenter/

> [!TIP]
> Server Major Releases (ending with .0 / -000) must be downloaded using the customer portal as the versions on the ftp server do not include the license file!

## System Requirements and supported OS
- [SP 8.1.26 Server Requirements](https://www.ibm.com/docs/en/storage-protect/8.1.26?topic=systems-minimum-linux-x86-64-server-requirements)
  - [SP 8.1.26 Server Requirements and Support for Linux x86_64](https://www.ibm.com/support/pages/node/7186417)
- [Overview - SP Supported Operating Systems](https://www.ibm.com/support/pages/overview-ibm-storage-protect-supported-operating-systems)

- Bypassing the OS checks:<br>
  ```bash
  ./install.sh -c -vmargs -DBYPASS_TSM_REQ_CHECKS=true
  ```
> [!TIP]
> 
>   This throws a lot of warning ...
>   ```bash
>   =====> IBM Installation Manager> Install> Prerequisites
> 
>   Validation results:
>   
>   * [WARNING] IBM Storage Protect server 8.1.26.20250315_0033 contains validation warning.
>        1. WARNING: The command "rpm -qa --queryformat '%{RELEASE}\n' redhat-release* | grep \\." has failed.
>        2. WARNING: The installation cannot continue if Security-enhanced Linux (SELinux) is enabled and in enforcing mode.
>   
>   * [WARNING] IBM Storage Protect license 8.1.26.20250315_0025 contains validation warning.
>        3. WARNING: The command "rpm -qa --queryformat '%{RELEASE}\n' redhat-release* | grep \\." has failed.
>   
>   * [WARNING] IBM Storage Protect storage agent 8.1.26.20250315_0021 contains validation warning.
>        4. WARNING: The command "rpm -qa --queryformat '%{RELEASE}\n' redhat-release* | grep \\." has failed.
>   
>   * [WARNING] IBM Storage Protect device driver  8.1.26.20250315_0028 contains validation warning.
>        5. WARNING: The command "rpm -qa --queryformat '%{RELEASE}\n' redhat-release* | grep \\." has failed.
>   
>   * [WARNING] IBM Storage Protect Operations Center 8.1.26000.20250314_1902 contains validation warning.
>        6. WARNING: The operating system on which you are installing the product is not supported. For more information, see http://www.ibm.com/support/docview.wss?uid=swg21243309.
>   
>    * [WARNING] Open Snap Store Manager 8.1.26.20250315_0023 contains validation warning.
>       7. WARNING: The command "rpm -qa --queryformat '%{RELEASE}\n' redhat-release* | grep \\." has failed.
>       8. WARNING: The command "rpm -qa --queryformat '%{RELEASE}\n' redhat-release* | grep \\." has failed.
>   
>   Enter the number of the error or warning message above to view more details.
>   
>   Options:
>       R. Recheck status.
>   
>       B. Back,      N. Next,      C. Cancel
>   ```
>   **BUT** you can just enter **N**ext :-)
>   ```bash
>   -----> [N]
>   ```

## Blueprints & Blueprint Tools

- Overview page<br>
    https://www.ibm.com/support/pages/ibm-storage-protect-blueprints
- The *tsmdiskperf tool* is now part of the whole Blueprint Configuration Scripts Collection ... and called `spdiskperf.pl `<br>
    https://www.ibm.com/support/pages/system/files/inline-files/sp-config-v51.zip
- [GitHub Repo on Blueprints](https://github.com/IBM/storage-protect-galaxy)

## Part Numbers and Products
see [Product Search -- Find licensing and ordering information for IBM offerings](https://www.ibm.com/about/software-licensing/us-en/product_search?search=Storage%20Protect)

## Other Stuff
### GitHub Repos
- [IBM's SP Repo](https://github.com/IBM/ansible-storage-protect)

### Using Ansible with SP
https://medium.com/@sarthak.ksh.dev/ibm-storage-protect-client-deployments-from-manual-chaos-to-automation-5d4a54c1ee3b
