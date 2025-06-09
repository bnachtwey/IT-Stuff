# Step-by-Step Guide: Expose WG-Easy GUI via Nginx Proxy Manager (NPM) on Port 51822

This guide will walk you through exposing your WG-Easy GUI securely using Nginx Proxy Manager (NPM), mapping external port **51822** to the internal **51821** of your `wg-easy` Docker container.

---

## **1. Prerequisites**

- WG-Easy and Nginx Proxy Manager (NPM) are both running as Docker containers on the same host (or the host can reach the container network).
- You have admin access to NPM (default: http://your-server-ip:81).
- Your domain (e.g., `jump.h15n.de`) points to your server's public IP.
- Ports 80, 443, and 51822 are open on your firewall/router.

---

## **2. Configure WG-Easy Docker Compose**

Ensure your `wg-easy` service exposes port **51821** only to the Docker network (not directly to the public):

```yaml
services:
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy
    container_name: wg-easy
    environment:
      - WG_HOST=jump.h15n.de
      - PASSWORD=your_admin_password
      - WG_DEFAULT_ADDRESS=10.15.0.x
      - WG_ALLOWED_IPS=10.15.0.0/24,192.168.15.0/24
    volumes:
      - ./wg-easy-data:/etc/wireguard
    ports:
      - "51820:51820/udp"        # WireGuard VPN
      - "51821:51821/tcp"        # Web UI (internal)
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
```


---

## **3. Access Nginx Proxy Manager (NPM)**

- Open your browser and go to:
`http://your-server-ip:81`
- Log in with your NPM admin credentials.

---

## **4. Add a New Proxy Host**

1. Go to **Hosts** > **Proxy Hosts**.
2. Click **Add Proxy Host**.
3. Fill in the form:
    - **Domain Names:**
`jump.h15n.de`
    - **Scheme:**
`http`
    - **Forward Hostname/IP:**
`wg-easy` (if using Docker networking) or `localhost`
    - **Forward Port:**
`51821`
    - **Cache Assets:** Off
    - **Block Common Exploits:** On
    - **Websockets Support:** On

---

## **5. Set Custom Access Port (51822)**

- In NPM, by default, proxy hosts listen on 80/443.
- To use a custom external port (51822), you must map port 51822 on your host to NPM’s internal port 80 or 443.

**Edit your NPM Docker Compose (or run command):**

```yaml
services:
  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: npm
    ports:
      - "80:80"
      - "443:443"
      - "81:81"
      - "51822:443"  # Add this line
    ...
```

- Restart NPM after editing the compose file.

**Result:**

- External requests to `https://jump.h15n.de:51822` will be handled by NPM and forwarded to WG-Easy’s GUI.

---

## **6. Enable SSL**

1. In the Proxy Host form, go to the **SSL** tab.
2. Check **Request a new SSL Certificate**.
3. Enter your email and agree to the terms.
4. Optionally, enable **Force SSL** and **HTTP/2 Support**.
5. Click **Save**.

NPM will automatically obtain and renew a Let's Encrypt certificate for your domain.

---

## **7. Test the Setup**

- Visit:
`https://jump.h15n.de:51822`
- You should see the WG-Easy login page, secured by SSL.

---

## **Summary Table**

| External Port | NPM Listens On | WG-Easy Internal Port | Access URL |
| :-- | :-- | :-- | :-- |
| 51822 | 443 | 51821 | https://jump.h15n.de:51822 |


---

### **References**

- [Vultr: Nginx Proxy Manager with WG-Easy](https://docs.vultr.com/how-to-install-wg-easy-an-opensource-web-ui-for-wireguard-vpn)[^2]
- [WG-Easy GitHub Issue: Nginx Proxy Manager Example](https://github.com/wg-easy/wg-easy/issues/499)[^3]

---

This setup gives you secure, browser-based access to the WG-Easy GUI on a custom port using NPM and Let's Encrypt SSL.

[^1]: https://github.com/wg-easy/wg-easy/wiki/Using-WireGuard-Easy-with-nginx-SSL

[^2]: https://docs.vultr.com/how-to-install-wg-easy-an-opensource-web-ui-for-wireguard-vpn

[^3]: https://github.com/wg-easy/wg-easy/issues/499

[^4]: https://superuser.com/questions/1824728/how-to-proxy-requests-into-wg-easy-docker-container

[^5]: https://github-wiki-see.page/m/unixzen/wg-easy/wiki/Using-WireGuard-Easy-with-nginx-SSL

[^6]: https://github.com/ad84/DuckDNS-wg-easy-proxy

[^7]: https://rm-solutions.de/en/blog/show/secure-vpn-with-wireguard-and-wg-easy/

[^8]: https://wiki.opensourceisawesome.com/books/wg-easy-for-wireguard/page/install-wg-easy/export/pdf