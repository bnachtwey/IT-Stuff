# Nice to Know about nmap
- [Zenmap](https://nmap.org/zenmap/) is no longer part of the Debian Repos, so you've to install it manually:
    - wget lastest version, e.g. <br>
    `wget https://nmap.org/dist/zenmap-7.94-1.noarch.rpm`
    - convert RPM to _deb_ using alien: <br>
    `sudo alien -c -d zenmap-7.94-1.noarch.rpm`
    - install using dpkg <br>
    `sudo dpkg -i zenmap_7.94-2_all.deb`
    - done :smile: 
# using nmap
- Basic command structure <br>
  `nmap [Scan Type(s)] [Options] {target specification}`
- `target specification` are 
  - single IPv4 IPs or FQDN
  - networks given by IP and Subnet using the CIDR notation, e.g.<br>
  `nmap 192.168.0.0/24`

## Examples
:construction: 
