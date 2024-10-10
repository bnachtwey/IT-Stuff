# some basic commans using `iptables`
look at https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules

## show rules
- show filtering rules / chains
  ```
  iptables -L
  ```
- show NATing / PREROUTING & POSTROUTING rules
  ```
  iptables -L -t nat
  ```
  - show NATing / PREROUTING & POSTROUTING rules with numbers
  ```
  iptables -L -t nat --line-numbers
  ```
## delete existing rules by chain and line number
- first get the line number
  ```
  iptables -L <CHAIN> --line-number
  ```
- delete rule
  ```
  iptables -D <chain> <line-number>
  ```

## delete existing rules by chain and line number for NAT
- first get the line number
  ```
  iptables -L --line-number -t nat
  ```
- delete rule
  ```
  iptables -D <chain> <line-number> -t nat
  ```
