# Current Version of Products from the Storage Protect Suite

IBM created a [landing page](https://public.dhe.ibm.com/software/products/ISP/currency/protect_server/), but it's still not complete -- imho

[Link to actual documentation](https://www.ibm.com/docs/en/storage-protect/8.1.26)

## Storage Protect Server

### latest versions

| OS | latest VRM | latest Patches / FixPacks | Remarks|
| :-: | :-: | :----------: | :----- |
| AIX | 8.1.27-0 | [8.1.22-100](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/AIX/8.1.22.100/),[8.1.16-100](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/AIX/8.1.16.100/),[8.1.15-100](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/AIX/8.1.15.100/),[8.1.14-200](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/AIX/8.1.14.200/) | |
| Linux x86 | 8.1.27-0 | [8.1.22-100](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/Linux/8.1.22.100/x86_64/),[8.1.16-100](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/Linux/8.1.16.100/x86_64/),[8.1.15-100](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/Linux/8.1.15.100/x86_64/), [8.1.14-200](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/Linux/8.1.14.200/x86_64/) | |
| Windows | 8.1.27-0 | [8.1.22-100](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/NT/8.1.22.100/), [8.1.16-100](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/NT/8.1.16.100/), [8.1.15-100](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/NT/8.1.15.100/), [8.1.14-200](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/server/NT/8.1.14.200/) | |

### latest eFixes

### Withdrawn versions

- 8.1.14-000 due to bug in MFA

## Storage Protect Operations Center

| OS | latest VRM | latest Patches / FixPacks | Remarks|
| :-: | :-: | :----------: | :----- |
| All | [8.1.27-0](https://ftp.software.ibm.com/storage/tivoli-storage-management/maintenance/opcenter/v8r1/) | [8.1.13-400](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/opcenter/8.1.13.400/)

## Spectrum Protect Clients

### BA Client

| OS | latest VRM | latest Patch / FixPack | Remarks|
| :-: | :-: | :----------: | :----- |
| AIX | [8.1.27-0](https://ftp.software.ibm.com/storage/tivoli-storage-management/maintenance/client/v8r1/AIX/BA/v8127/) | [8.1.17-2](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/client/v8r1/AIX/BA/v8117/) |
| Linux DEB | [8.1.27-0](https://ftp.software.ibm.com/storage/tivoli-storage-management/maintenance/client/v8r1/Linux/LinuxX86_DEB/BA/v8127/) | [8.1.17-2](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/client/v8r1/Linux/LinuxX86_DEB/v8117/) | 
| Linuxx x86 | [8.1.27-0](https://ftp.software.ibm.com/storage/tivoli-storage-management/maintenance/client/v8r1/Linux/LinuxX86/BA/v8127/) | [8.1.17-2](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/client/v8r1/Linux/LinuxX86/BA/v8117/) | 
| Windows | [8.1.27-0](https://ftp.software.ibm.com/storage/tivoli-storage-management/maintenance/client/v8r1/Windows/x64/v8127/) | [8.1.25-1](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/client/v8r1/Windows/x64/v8125/) |

### [TSM4ERP](https://www.ibm.com/docs/en/spferp) / HANA

| latest VRM | latest Patch / FixPack | Remarks|
| :-: | :----------: | :----- |
| [8.1.11](https://www.ibm.com/docs/en/spferp/8.1.11) | [8.1.11-1](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/tivoli-data-protection/r3/v81111/hana/) | |

### [TSM4SQL](https://www.ibm.com/docs/en/spfd)

| latest VRM | latest Patch / FixPack | Remarks|
| :-: | :----------: | :----- |
| [8.1.24](https://www.ibm.com/docs/en/spfd/8.1.24) | [8.1.17-2](https://www.ibm.com/support/fixcentral/swg/doSelectFixes?options.selectedFixes=8.1.17.2-TIV-TSMSQL-Win&continue=1) (via FixCentral), [8.1.17-1](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/tivoli-data-protection/sql/v8117/windows/) (IBM FTP) | |

### [TSM4Mail](https://www.ibm.com/docs/en/spfm)

| latest VRM | latest Patch / FixPack | Remarks|
| :-: | :----------: | :----- |
| [8.1.22](https://www.ibm.com/docs/en/spfm/8.1.22) | [8.1.17-2](https://www.ibm.com/support/fixcentral/swg/doSelectFixes?options.selectedFixes=8.1.17.2-TIV-TSMEXC-Win&continue=1) (via FixCentral) | |

### TSM4Oracle

IBM decides sometimes in the past to put the Oracle TDP together with the one for MSSQL, so you've check the _TDP4SQL_ if there's a new Oracle client ...

| OS | latest VRM | latest Patches / FixPacks | Remarks|
| :-: | :-: | :----------: | :----- |
| AIX | [8.1.24](https://www.ibm.com/docs/en/spfd/8.1.24?topic=whats-new) | [8.1.9-1](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/tivoli-data-protection/oracle/aix/v819/) | |
| Linux | [8.1.24](https://www.ibm.com/docs/en/spfd/8.1.24?topic=whats-new) | [8.1.9-1](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/tivoli-data-protection/oracle/linux/linux86_64/v819/) | |
| Windows | [8.1.22](https://www.ibm.com/docs/en/spfd/8.1.24?topic=whats-new) | [8.1.9-1](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/tivoli-data-protection/oracle/win/x64/v819/) | |

### [TSM4VE](https://www.ibm.com/docs/en/spfve)

| OS | latest VRM | latest Patches / FixPacks | Remarks|
| :-: | :-: | :----------: | :----- |
| Linux | [8.1.27](https://www.ibm.com/docs/en/spfve/8.1.27) | [8.1.23-1](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/tivoli-data-protection/vmware/linux/linux86/v8123/) (vmware only)| |
| Windows | [8.1.27](https://www.ibm.com/docs/en/spfve/8.1.27) | [8.1.23-1](https://ftp.software.ibm.com/storage/tivoli-storage-management/patches/tivoli-data-protection/vmware/windows/v8123/) (vmware only) | |

---
## Product Roadmap

well, not a really Roadmap, but a FAQ gives an answer

- [Which IBM Spectrum Protect Family products and releases have support extension contracts available for purchase beyond their End of Support (EOS) date?](https://www.ibm.com/support/pages/node/259159)

  - Withdrawal announcement letters:

    - **31 December 2021** is announced as the End of Support date (EOS), for IBM Spectrum Protect and IBM Tivoli Storage Manager 7.1 products and for IBM Spectrum Protect Snapshot and IBM Tivoli Storage FlashCopy® Manager 4.1. 
         The withdrawal announcement letter is available here: [Software support discontinuance: IBM Spectrum Protect and IBM Tivoli Storage Manager programs.](https://w3-03.ibm.com/sales/support/ShowDoc.wss?docid=IA/897/ENUS921-006)
    - **30 September 2017** is announced as the End of Support date (EOS) for **IBM Tivoli Storage Manager 6.4** products and for IBM Tivoli Storage FlashCopy Manager 3.2. The announcement letter is available [here](http://www.ibm.com/common/ssi/rep_ca/7/897/ENUS916-117/index.html)
    - **30 April 2017** is announced as the End of Support date (EOS) for **IBM Tivoli Storage Manager 6.3** products and for IBM Tivoli Storage FlashCopy Manager 3.1. The announcement letter is available [here](http://www.ibm.com/common/ssi/rep_ca/2/897/ENUS916-072/index.html)
    - **30 April 2016** is announced as the End of Support date (EOS) for **IBM Tivoli Storage Manager for Virtual Environments 6.2** product. The announcement letter is available [here](http://www.ibm.com/common/ssi/cgi-bin/ssialias?subtype=ca&infotype=an&appname=iSource&supplier=897&letternum=ENUS915-114)
    - **30 April 2015** is announced as the End of Support date (EOS) for most **IBM Tivoli Storage Manager 6.2** products. The announcement letter is available [here](http://www.ibm.com/common/ssi/cgi-bin/ssialias?subtype=ca&infotype=an&appname=iSource&supplier=897&letternum=ENUS914-056)
    - **30 April 2014** was the End of Support date (EOS) for most **IBM Tivoli Storage Manager 5.5 and 6.1 products** with distributed platforms. The announcement letter is available [here](http://www.ibm.com/common/ssi/cgi-bin/ssialias?subtype=ca&infotype=an&appname=iSource&supplier=897&letternum=ENUS913-063)

-  T.B.D.
---
ToDo:
How to gather this information automatically? 👷‍♀️

Maybe evaluate this? https://www.ibm.com/docs/en/storage-protect/8.1.26?topic=product-family-related-products
