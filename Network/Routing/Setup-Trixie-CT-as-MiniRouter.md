# Setting up a Minirouter on a LXC container running Debian Trixie

Solution proviced by [Perplexity](https:\\perplexity.ai)

> Prompt:
>
> *how to set up Trixie to act as a gateway from NIC eth1 to eth0 using iptables?*

*To turn Trixie into a simple IPv4 gateway from `eth1` (LAN) to `eth0` (WAN) with **iptables**, you need: correct IPs, IP forwarding, and NAT + FORWARD rules.\[1\]\[2\]*

## 1. Network assumptions

Example layout (adjust to your reality):

- `eth0` (WAN): gets IP via DHCP from ISP/router
- `eth1` (LAN): static, e.g. `192.168.10.1/24`

On Trixie (if you still use `ifupdown`):

```bash
# /etc/network/interfaces (example)
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 192.168.10.1
    netmask 255.255.255.0
```

LAN clients must use:

- IP in `192.168.10.0/24`
- Default gateway: `192.168.10.1` (Trixie’s `eth1`) \[3\]\[4\]

## 2. Enable IP forwarding (persistent)

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

## 3. Runtime iptables rules

Minimal router rules:

```bash
# Flush old rules (optional, be careful if remote)
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -X

# Default policies
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Allow forwarding from LAN -> WAN
sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

# Allow return traffic (stateful)
sudo iptables -A FORWARD -i eth0 -o eth1 \
  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# NAT (masquerade) on WAN
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

- The MASQUERADE rule rewrites source addresses of LAN hosts to the `eth0` address.\[5\]\[2\]\[1\]
- You can inspect rules with:

```bash
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v
```

At this point, with clients pointed to `192.168.10.1` as gateway, they should reach the internet.

## 4. Make iptables rules persistent

On Trixie with iptables:

```bash
sudo apt install iptables-persistent
```

Then save rules:

```bash
sudo iptables-save | sudo tee /etc/iptables/rules.v4 >/dev/null
```

`iptables-persistent` loads `/etc/iptables/rules.v4` automatically at boot, restoring your gateway rules.\[6\]\[1\]

## 5. Quick verification checklist

On Trixie:

- `ip a` shows:
  - `eth0` with valid WAN IP.
  - `eth1` with `192.168.10.1/24` (or your chosen LAN subnet).
- `cat /proc/sys/net/ipv4/ip_forward` → `1`.
- `iptables -t nat -L -n -v` shows `MASQUERADE` on `eth0`.
- `iptables -L FORWARD -n -v` shows ACCEPT rules for `eth1 -> eth0` and ESTABLISHED/RELATED back.\[7\]\[1\]

On a LAN client:

- `ip route` shows default via `192.168.10.1`
- `ping 8.8.8.8` works
- If DNS is configured, `ping debian.org` works

If you want a stricter firewall on the router (e.g. limit what FROM LAN can go out), rules can be tightened, but the above is the minimal working gateway using `iptables`.\[10\]\[11\]\[12\]\[8\]\[9\]

## Sources

- \[1\]: <https://www.systutorials.com/setting-up-gateway-using-iptables-and-route-on-linux/>

- \[2\]: <https://www.revsys.com/writings/quicktips/nat.html>

- \[3\]: <https://www.linode.com/docs/guides/linux-router-and-ip-forwarding/>

- \[4\]: <https://wiki.debian.org/NetworkConfiguration>

- \[5\]: <https://www.thomas-krenn.com/de/wiki/Internet_Connection_Sharing_(Masquerade)_unter_Linux>

- \[6\]: <https://gridscale.io/en/community/tutorials/debian-router-gateway/>

- \[7\]: <https://www.baeldung.com/linux/server-router-configure>

- \[8\]: <https://www.digitalocean.com/community/tutorials/how-to-forward-ports-through-a-linux-gateway-with-iptables>

- \[9\]: <https://wiki.debian.org/BridgeNetworkConnections>

- \[10\]: <https://geek64.de/linux/linux-iptables-masquerade-einrichten-netzwerk-nat-forwarding/>

- \[11\]: <https://stackoverflow.com/questions/60782425/iptables-masquerade-not-working-on-debian-vm>

- \[12\]: <https://ilearnedhowto.wordpress.com/2016/05/10/how-to-configure-a-simple-router-with-iptables-in-ubuntu/>

---

## Addon: Wireguard on Router

> under construction, does not work this way :-(

If your router also acts as a VPN server using wireguard, you must extend the routing rules mentioned above to do routing between the wg interface and the LAN, too :-)

Assuming the wireguard NIC is called `wg0` add the following lines:

```bash
# Allow forwarding from wg0 -> LAN
sudo iptables -A FORWARD -i wg0 -o eth1 -j ACCEPT

# Allow return traffic (stateful)
sudo iptables -A FORWARD -i ethq -o wg0 \
  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

```
