<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

## Using WireGuard/WG-Easy Behind CGNAT

If your WireGuard server (including setups using WG-Easy) is behind Carrier-Grade NAT (CGNAT), you cannot directly expose it to the public internet because you do not control a public IP or port forwarding. However, you can still enable remote access by leveraging a Virtual Private Server (VPS) with a public IP as a relay or "jump host." Here’s how to set this up:

**1. Overview of the Solution**

- Deploy a VPS with a public IP address.
- Run WireGuard (or WG-Easy) on the VPS.
- Configure your home server (behind CGNAT) as a WireGuard client, connecting out to the VPS.
- Route traffic between your remote clients and your home network via the VPS.

**2. Step-by-Step Configuration**

**A. Set Up WireGuard/WG-Easy on the VPS**

- Install WireGuard or WG-Easy on your VPS.
- Assign a private WireGuard subnet (e.g., 10.9.0.0/24).
- Open a UDP port on the VPS firewall for WireGuard (e.g., 51820)[^1_3][^1_5].

**B. Configure the Home Server as a WireGuard Peer (Client)**

- On your home server (behind CGNAT), configure WireGuard to connect to the VPS as a client.
- Use the VPS’s public IP and WireGuard port as the endpoint.
- Set `PersistentKeepAlive = 25` in the home server’s WireGuard config to maintain the tunnel through CGNAT[^1_5][^1_9].
- Assign a unique IP from the WireGuard subnet (e.g., 10.9.0.2).

**Example Home Server Config:**

```ini
[Interface]
PrivateKey = <home-server-private-key>
Address = 10.9.0.2/32

[Peer]
PublicKey = <vps-public-key>
Endpoint = <VPS-public-IP>:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepAlive = 25
```

**C. Routing and Access to LAN Devices**

- If you want remote clients to access your home LAN (e.g., 192.168.40.0/24), add this subnet to the `AllowedIPs` for the home server’s peer entry on the VPS[^1_6].
- On the VPS, update the WireGuard config to include the home LAN in the peer’s `AllowedIPs`:

```
[Peer]
PublicKey = <home-server-public-key>
AllowedIPs = 10.9.0.2/32, 192.168.40.0/24
```

- On your home server, enable IP forwarding and set up NAT (masquerading) to allow traffic from the WireGuard interface to reach your LAN[^1_8][^1_9]:

```bash
sysctl net.ipv4.ip_forward=1
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -t nat -A POSTROUTING -o <LAN-interface> -j MASQUERADE
```


**D. Connect Clients via the VPS**

- Remote clients connect to the VPS WireGuard server.
- Their `AllowedIPs` should include the WireGuard subnet and optionally the home LAN subnet if you want them to access devices behind CGNAT.

**3. Key Points**

- The home server must initiate and maintain the connection to the VPS (CGNAT allows outbound, not inbound, connections).
- The VPS acts as a relay, allowing remote clients to reach your home network.
- Adjust firewall and routing rules to ensure traffic flows correctly between all peers.

**4. WG-Easy Specific Notes**

- WG-Easy is a management UI for WireGuard and follows the same networking principles.
- You may need to manually edit the `AllowedIPs` in the config files if the GUI does not support advanced routing[^1_6].

---

**Summary Table:**


| Component | Role/Config |
| :-- | :-- |
| VPS (Public IP) | WireGuard server, open UDP port, relay between clients \& home |
| Home Server | WireGuard client, connects to VPS, enables LAN routing |
| Remote Clients | Connect to VPS, access home LAN via VPS relay |


---

This setup allows full remote access to your home network even when your ISP places you behind CGNAT, using only self-hosted infrastructure[^1_1][^1_2][^1_3][^1_5][^1_6][^1_8][^1_9].

<div style="text-align: center">⁂</div>

[^1_1]: https://www.reddit.com/r/WireGuard/comments/198fqqp/help_setting_up_wireguard_for_outsidein_access/

[^1_2]: https://forum.gl-inet.com/t/bypassing-cgnat-with-wireguard-possible-configurations/48278

[^1_3]: https://gist.github.com/Quick104/d6529ce0cf2e6f2e5b94c421a388318b

[^1_4]: https://forum.netgate.com/topic/182023/setting-up-tunnel-through-cgnat-using-wireguard

[^1_5]: https://www.kmr.me/posts/wireguard/

[^1_6]: https://github.com/wg-easy/wg-easy/discussions/1518

[^1_7]: https://www.youtube.com/watch?v=7TOwr1Hs9fk

[^1_8]: https://hacdias.com/2020/11/30/access-network-behind-cgnat/

[^1_9]: https://moddedbear.com/using-wireguard-to-self-host-around-a-carrier-grade-nat/

