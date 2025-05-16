# some basic commans using `iptables`
look at https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules

## show rules
- show filtering rules / chains
  ```bash
  iptables -L
  ```
- show NATing / PREROUTING & POSTROUTING rules
  ```bash
  iptables -L -t nat
  ```
  - show NATing / PREROUTING & POSTROUTING rules with numbers
  ```bash
  iptables -L -t nat --line-numbers
  ```
## delete existing rules by chain and line number
- first get the line number
  ```bash
  iptables -L <CHAIN> --line-number
  ```
- delete rule
  ```bash
  iptables -D <chain> <line-number>
  ```

## delete existing rules by chain and line number for NAT
- first get the line number
  ```bash
  iptables -L --line-number -t nat
  ```
- delete rule
  ```bash
  iptables -D <chain> <line-number> -t nat
  ```

## delete all existing rules
   ```bash
   iptables -F
   ```
