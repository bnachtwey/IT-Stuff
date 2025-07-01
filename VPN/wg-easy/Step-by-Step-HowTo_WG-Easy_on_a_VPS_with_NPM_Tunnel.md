<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

## Step-by-Step HowTo: WG-Easy on a VPS with NPM, Tunneling to a CGNAT Home Peer, and Accessing 192.168.15.0/24


---

**1. Deploy WG-Easy on Your VPS**

- Provision a VPS (Debian 12 recommended).
- Install Docker and Docker Compose[^6].
- Use the following `docker-compose.yml` for WG-Easy:

```yaml
version: '3.8'

services:
  wg-easy:
    image: weejewel/wg-easy
    container_name: wg-easy
    environment:
      - WG_HOST=<YOUR_VPS_PUBLIC_IP_OR_DOMAIN>
      - PASSWORD=<SET_ADMIN_PASSWORD>
      - WG_DEFAULT_ADDRESS=10.8.0.x
      - WG_DEFAULT_DNS=1.1.1.1
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    volumes:
      - ./data:/etc/wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
```

Replace `<YOUR_VPS_PUBLIC_IP_OR_DOMAIN>` and `<SET_ADMIN_PASSWORD>` as needed.

- Start the container:

```
docker compose up -d
```

- WG-Easy admin GUI will be at `http://<VPS_IP>:51821`.

---

**2. Secure WG-Easy Admin GUI with Nginx Proxy Manager (NPM)**

- Deploy NPM in another Docker container (or on the same VPS).
- Point a domain/subdomain (e.g., `vpnadmin.example.com`) to your VPS IP.
- In NPM, create a new proxy host:
    - Domain Names: `vpnadmin.example.com`
    - Forward Hostname/IP: `wg-easy`
    - Forward Port: `51821`
    - Enable SSL (Let's Encrypt) and force HTTPS.
    - Set up HTTP authentication (NPM > Access List) for extra protection.

---

**3. WireGuard Tunneling to Home Peer Behind CGNAT**

- The VPS acts as the WireGuard "server" with a public IP.
- The home peer (192.168.15.29) acts as a "client" and initiates the tunnel to the VPS[^1][^2][^4][^5].
- On the home peer, install WireGuard and set up a peer config pointing to the VPS's public IP and port 51820.

**Example Home Peer Config (`wg0.conf`):**

```ini
[Interface]
PrivateKey = <HOME_PRIVATE_KEY>
Address = 10.8.0.2/32

[Peer]
PublicKey = <VPS_PUBLIC_KEY>
Endpoint = <VPS_PUBLIC_IP>:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

- Bring up the tunnel on the home peer:

```
sudo wg-quick up wg0
```

- Enable IP forwarding on the home peer:

```
sudo sysctl -w net.ipv4.ip_forward=1
```


---

**4. Access All Hosts in 192.168.15.0/24 via the Tunnel**

- On the VPS, edit the WireGuard config (via WG-Easy or manually) to add the following for the home peer:

```ini
[Peer]
PublicKey = <HOME_PUBLIC_KEY>
AllowedIPs = 192.168.15.0/24
```

- On the home peer, add a PostUp rule to allow forwarding from the tunnel to the LAN:

```ini
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

Replace `eth0` with your home peer's LAN interface name[^2][^5].

- This setup allows any client connected to the VPS's WireGuard to reach any device in 192.168.15.0/24, routed through the home peer.

---

**Summary Table**


| Component | Role | Key Configs/Notes |
| :-- | :-- | :-- |
| VPS | WireGuard server | Public IP, runs WG-Easy, open UDP 51820, Docker Compose as above |
| NPM | Reverse proxy | Secures WG-Easy GUI with SSL and HTTP Auth |
| Home Peer | WireGuard client | Initiates outbound tunnel, forwards 192.168.15.0/24, enables IP forwarding/NAT |
| WireGuard Peer | Access 192.168.15.0/24 | AllowedIPs includes 192.168.15.0/24 |


---

**References Used:**

- [How to Self Host and Install WG-Easy VPN using a VPS - Noted.lol][^6]
- [Wireguard VPN to Network Behind a CGNAT - Henrique Dias][^2]
- [Expose a server behind CG:NAT via Wireguard - GitHub Gist][^5]
- [Wireguard behind CGNAT - Reddit][^1]
- [Hosting Behind CGNAT With Wireguard - Lawrence Systems][^7]

If you need a ready-to-use NPM Docker Compose or want help with client configs, let me know!

<div style="text-align: center">⁂</div>

[^1]: https://www.reddit.com/r/WireGuard/comments/1jdysy7/wireguard_behind_cgnat/

[^2]: https://hacdias.com/2020/11/30/access-network-behind-cgnat/

[^3]: https://www.youtube.com/watch?v=7TOwr1Hs9fk

[^4]: https://www.kmr.me/posts/wireguard/

[^5]: https://gist.github.com/Quick104/d6529ce0cf2e6f2e5b94c421a388318b

[^6]: https://noted.lol/wg-easy-vps/

[^7]: https://forums.lawrencesystems.com/t/hosting-behind-cgnat-with-wireguard/23546

[^8]: https://www.zenarmor.com/docs/network-security-tutorials/wireguard-installation

