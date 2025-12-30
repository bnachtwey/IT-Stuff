# Suggest Hardware Requirements for "Greenbone Community Edition" / OpenVAS

For a small‑to‑medium lab setup on Debian, plan at least 2 vCPUs, 4–8 GB RAM, and 40–60 GB disk for a Greenbone Community Edition / OpenVAS container or VM.  For smoother scans and future growth, 4 vCPUs, 8 GB RAM, and ≥60 GB disk are preferable.\[1]\[2]\[3]

## Official baseline (Debian host)

Greenbone’s current documentation for Community Edition (incl. containers) lists:\[2]\[1]

- Minimal: **2 CPU cores**, 4 GB RAM, 20 GB free disk.\[1]\[2]
- Recommended: **4 CPU cores**, 8 GB RAM, 60 GB free disk.\[2]\[1]

These values apply whether you run in a VM or as Docker/Podman containers on a Debian host, because the scanner, PostgreSQL, and feed data have similar needs.\[1]\[2]

## Practical sizing by use case

For a Debian VM or container host:

- Light use (home lab, tens of hosts, few concurrent scans)
  - vCPU: **2 cores**
  - RAM: 4–6 GB (assign ~4 GB to the containers/VM)\[4]\[1]
  - Disk: 40 GB (20 GB minimum, 60 GB if you can)\[2]\[1]
- Regular use (small company, hundreds of hosts, more frequent scans)
  - vCPU: **4 cores**
  - RAM: 8 GB (this is often cited as a realistic minimum for comfortable scanning)\[3]\[2]
  - Disk: 60–80 GB (feeds and reports grow over time)\[5]\[2]
- Heavier use (parallel scans, large scopes)
  - vCPU: 4–8 cores
  - RAM: 8–16 GB (more RAM helps avoid crashes/timeouts under load)\[4]\[3]
  - Disk: ≥100 GB, consider separate storage for backups/archives.\[5]

## Container vs VM notes

- Container deployment
  - Ensure the Docker/Podman host itself meets at least the **recommended** specs so that containers can use 4 cores / 8 GB effectively.\[1]
  - Allocate enough memory limits to the scanner and database containers; too tight limits cause “out of memory” and scan failures.\[6]
- VM deployment
  - For an all‑in‑one Debian VM, mirror the recommended values directly on the VM (4 vCPUs, 8 GB RAM, 60+ GB disk).\[2]
  - If using prebuilt images like OPENVAS FREE VMs, the vendor also suggests 2 CPUs and 5 GB RAM as an absolute minimum, again pointing to roughly the same range.\[7]

## Network and OS hints for Debian

- OS: Debian stable (Bookworm) is explicitly supported for Greenbone Community Edition and containers.\[8]\[1]
- Network:
  - VM: bridged or routed connectivity with direct Internet access for feed syncs.\[7]
  - Container: host must reach the Internet and target networks; avoid overly restrictive firewall rules that block feed downloads or scan traffic.\[1]

If you share how many targets you plan to scan and how often, more tailored sizing (and tuning tips) can be suggested.

## Sources

- \[1\] <https://greenbone.github.io/docs/latest/22.4/container/>
- \[2\] <https://greenbone.github.io/docs/latest/22.4/source-build/hardware.html>
- \[3\]  <https://hackertarget.com/install-openvas-gvm-on-kali/>
- \[4\]  <https://www.kali.org/blog/configuring-and-tuning-openvas-in-kali-linux/>
- \[5\]  <https://github.com/itiligent/Easy-OpenVAS-Installer>
- \[6\]  <https://forum.greenbone.net/t/openvas-works-in-kali-container-but-docker-containers-cant-allocate-enough-memory/13527>
- \[7\]  <https://www.greenbone.net/en/openvas-free/>
- \[8\]  <https://greenbone.github.io/docs/latest/22.4/container/index.html>
- \[9\]  <https://forum.greenbone.net/t/greenbone-community-editions-installation-licensing-procedure/19538>
- \[10\]  <https://greenbone.github.io/docs/latest/22.4/source-build/index.html>
- \[11\]  <https://forum.greenbone.net/t/scanners-and-their-minimum-requrements/8590>
- \[12\]  <https://www.youtube.com/watch?v=2mPOsBVDS2E>
- \[13\]  <https://github.com/beep-projects/VASpberryPi>
- \[14\]  <https://www.youtube.com/watch?v=MH4vVhHPm4s>
- \[15\]  <https://forum.greenbone.net/t/which-platform-for-community-edition/16367>
- \[16\]  <https://notes.51sec.org/article/192cdfbf-51b4-48ae-afeb-179f82a5e242>
- \[17\]  <https://www.greenbone.net/en/blog/official-docker-container-for-greenbone-community-edition/>
- \[18\]  <https://www.bsi.bund.de/DE/Themen/Unternehmen-und-Organisationen/Informationen-und-Empfehlungen/Freie-Software/Tools/OpenVAS/OpenVAS.html>
- \[19\]  <https://itorakul.com.ua/en/openvas-2/>
- \[20\]  <https://github.com/greenbone/docs/blob/main/src/22.4/container/index.md?plain=true>
