# Examples for *Block all, but <Application X>*
> [WARNING]
> If you issue these rules remotely, consider the order, early `DROP` commands will kill your running ssh session
- Block all incoming but ...<br>
  Suggested general settings, should be issued *AFTER* more detailed rules for exceptions ...
  ```bash
  # Preserve exiting connections
  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

  # Allow Loopback (esp. for local services)
  iptables -A INPUT -i lo -j ACCEPT  

  # Set DROP as default policy for all incoming iptables
  iptables -P INPUT DROP
  ```
- ... `ssh`
  ```bash
  # allow incoming SSH (Port 22)
  iptables -A INPUT -p tcp --dport 22 -j ACCEPT
  ```

- ... `http  on Port 80`
  ```bash
  # allow incoming http (Port 80)
  iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  ```

- ... `https  on Port 443`
  ```bash
  # allow incoming https (Port 443)
  iptables -A INPUT -p tcp --dport 443 -j ACCEPT
  ```

- ... `ssh` on `ens123` only
  ```bash
  # Allow incoming SSH on ens123 only
  iptables -A INPUT -i ens123 -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  
  # Allow outgoing SSH replies from ens123
  iptables -A OUTPUT -o ens123 -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
  ```

  
