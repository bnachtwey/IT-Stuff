# Setting up a Minirouter on a LXC container running Debian Trixie

## Assumptions

Haveing a Linux / Debian VM attached to two networks:

- `192.168.1.2/24` @ `eth0` as *WAN* / *outer network*
- `192.168.2.1/24` @ `eth1` as *LAN* / *inner network*

## Basic Idea / Approach

To make the Debian VM route traffic between `192.168.1.0/24` (WAN) and `192.168.2.0/24` (LAN) -- and *vice versa*

- enable IPv4 forwarding
- ensure the firewall and host routes are set correctly
- ensure endpoints have correct gateways

## Step by Step

### 1. Enable IPv4 forwarding (persistent)

Add this (once you have sysctl working on Trixie):

```bash
sudo tee /etc/sysctl.d/60-ip-forward.conf >/dev/null <<'EOF'
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
```

Verify:

```bash
cat /proc/sys/net/ipv4/ip_forward  # should be 1
```

### 2. Allow forwarding in the firewall

If you use iptables and have restrictive rules, allow forwarding between `eth0` and `eth1` by

```bash
# Flush old rules (optional, be careful if remote)
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -X

# Default policies
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Accept forwarding between WAN and LAN
sudo iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
```

> [!Note]
> If you are not doing NAT on this VM and just routing between the two private networks, you do **not** need a MASQUERADE rule; simple forwarding is enough as long as routes are correct.

If you later want LAN hosts to reach the internet through this VM (and `eth0` is the internet uplink), *add NAT* by

```bash
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

> Check settings
>
> ```bash
> # iptables -L -v
> Chain INPUT (policy ACCEPT 1514 packets, 163K bytes)
>  pkts bytes target     prot opt in     out     source               destination         
> 
> Chain FORWARD (policy DROP 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source               destination         
>   142 64582 ACCEPT     all  --  eth0   eth1    anywhere             anywhere            
>   172 20745 ACCEPT     all  --  eth1   eth0    anywhere             anywhere            
>     0     0 ACCEPT     all  --  eth0   wg0     anywhere             anywhere            
>     0     0 ACCEPT     all  --  wg0    any     anywhere             anywhere            
> 
> Chain OUTPUT (policy ACCEPT 1290 packets, 123K bytes)
>  pkts bytes target     prot opt in     out     source               destination  
> ```

### 3. Make iptables rules persistent

On Trixie with iptables:

```bash
sudo apt install iptables-persistent
```

Then save rules:

```bash
sudo iptables-save | sudo tee /etc/iptables/rules.v4 >/dev/null
```

`iptables-persistent` loads `/etc/iptables/rules.v4` automatically at boot, restoring your gateway rules.

### 4. Configure host gateways/routes

Both networks must know to use this Debian VM as the router, so

- On `192.168.2.0/24` (LAN) hosts:

  Set default gateway to `192.168.2.1`,
  
  or at least a route to `192.168.1.0/24` via `192.168.2.1`

- On `192.168.1.0/24` (WAN) hosts or upstream router:
  
  Add a static route: `192.168.2.0/24 via 192.168.1.2`
