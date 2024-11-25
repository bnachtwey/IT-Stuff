# Basic Network Analysis on Linux

## get basic information on NIC / network links
- using the [ip](https://linux.die.net/man/8/ip) command
  - show all nics including their `MAC` address
    ```bash
    ip l
    ip link
    ip link show
    ```
  - show information on specific link / nics, e.g. `eth0`
    ```bash
    $ ip l show eth0
    6: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
        link/ether 00:15:5d:38:3a:44 brd ff:ff:ff:ff:ff:ff
    ```
  - get all local IPs
    ```bash
    ip a
    ip addr
    ip addr show
    ```
  - show information on specific adress / nics, e.g. those bound on  `eth0`
    ```bash
    $ ip a show eth0
    6: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
        link/ether 00:15:5d:38:3a:44 brd ff:ff:ff:ff:ff:ff
        inet 172.29.89.154/20 brd 172.29.95.255 scope global eth0
           valid_lft forever preferred_lft forever
        inet6 fe80::215:5dff:fe38:3a44/64 scope link
           valid_lft forever preferred_lft forever
    ```
  - show routing information for all nics
    ```bash
    ip r
    ip route
    ip route show
    ip route list
    ```
  ...
