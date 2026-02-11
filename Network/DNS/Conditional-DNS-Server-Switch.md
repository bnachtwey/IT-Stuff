# how to set up a domain-depending switching of DNS servers?
<!--
AIA Primarily AI, Content edits, Human-initiated, Reviewed v1.0

# changelog
# date          version     remark
# 2026-01-13    0.1.1       add new section 3. on refreshing the state plus dedicated scripts
# 2026-01-06    0.1         initial coding: take suggestion from *copilot*, verify and fix it ;-)

-->

if you want to use a well an internal DNS for the machines running in a private network and also still use another one for all other requests, there a two ways to do:

> Let's assume, the VPN connection always creates a `tun` device with an non-routable IP from `10.0.0.0/8`

---

## **Approach 1 : systemd-resolved + Networkd-dispatcher hook**

`networkd-dispatcher` lets you run scripts when interfaces go up/down.

### 1. Install helper (and `resolved` itself)

```bash
sudo apt-get install systemd-resolved
sudo apt install networkd-dispatcher
```

### 2. Create a script that runs automatically whenever the VPN is enabled / disabled

> The `networkd-dispatcher` looks for any changes in the network settings and then runs all scripts placed at `/etc/networkd-dispatcher:/usr/lib/networkd-dispatcher`

```bash
sudo tee /etc/networkd-dispatcher/routable.d/10-dns-switch.sh >/dev/null <<'EOF'
#!/bin/bash
# Triggered when an interface becomes routable
IFACE="$IFACE"
IP=$(ip -4 addr show dev "$IFACE" | awk '/inet / {print $2}' | cut -d/ -f1)

# Check if interface name starts with tun and IP is in 10.0.0.0/8
if [[ "$IFACE" =~ ^tun && "$IP" =~ ^10\. ]]
then
    # VPN active: route mine.localhost to 10.0.0.2
    resolvectl dns    "${IFACE}" 10.0.0.2
    resolvectl domain "${IFACE}" ~mine.localhost
else
    # Default DNS only
    resolvectl revert "${IFACE}"
fi
EOF

sudo chmod +x /etc/networkd-dispatcher/routable.d/10-dns-switch.sh
```

> Trigger does not work!

### 3. Create a script that checks and refreshes state peridocally

see [`check-VPN-DNS.sh``](./check-VPN-DNS.sh)

### 4. Set global fallback DNS

```bash
sudo tee /etc/systemd/resolved.conf.d/99-default-dns.conf >/dev/null <<'EOF'
[Resolve]
DNS=9.9.9.9
Domains=~.
EOF

sudo systemctl restart systemd-resolved
```

**Result:**

- When a `tun*` interface comes up with a `10.x.x.x` address, `mine.localhost` routes to `10.0.0.2`.
- When it goes down, the script reverts to default DNS (9.9.9.9).
- besides this the `systemd.timer` check periodically and sets DNS if VPN is running

### *Why this works*

- `systemd-resolved` supports per-interface routing domains (`~domain`).
- `networkd-dispatcher` reacts to interface state changes, so no manual toggling.
