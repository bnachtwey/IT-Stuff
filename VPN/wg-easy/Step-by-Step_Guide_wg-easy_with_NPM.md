# Step-by-Step Guide: Installing a Let's Encrypt Certificate for WG-Easy (WireGuard UI) in Docker using NPM

**As suggested by Perplexity LLM**

This guide explains how to secure the WG-Easy admin interface (port 51821) with a Let's Encrypt certificate using a reverse proxy (Nginx Proxy Manager) and ensure automatic certificate renewal. This is the most robust and widely recommended approach for Dockerized apps like WG-Easy[^7][^5].

---

**Prerequisites**

- Docker host has a public IP.
- You have a domain name (e.g., wg-easy.example.com) pointing to your server's public IP.
- Docker and Docker Compose are installed.
- Ports 80 (HTTP) and 443 (HTTPS) are open on your firewall.

---

## 1. Deploy WG-Easy with Docker

If you haven't already, deploy WG-Easy using Docker Compose:

```yaml
version: "3.8"
services:
  wg-easy:
    image: weejewel/wg-easy
    container_name: wg-easy
    environment:
      - WG_HOST=wg-easy.example.com  # Replace with your domain
      - PASSWORD=your_admin_password
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    volumes:
      - ./data:/etc/wireguard
    restart: unless-stopped
```

Start the container:

```bash
docker compose up -d
```


---

## 2. Set Up Nginx Proxy Manager (NPM) in Docker

Nginx Proxy Manager (NPM) is the easiest way to handle Let's Encrypt certificates and reverse proxy for Docker containers[^7].

**Create a docker-compose.yml for NPM:**

```yaml
version: "3"
services:
  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: npm
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "81:81"
    environment:
      - TZ=Europe/Berlin
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
```

Start NPM:

```bash
docker compose up -d
```


---

## 3. Configure the Reverse Proxy and SSL Certificate

**Access NPM UI:**

- Open `http://YOUR_SERVER_IP:81`
- Default login: `admin@example.com` / `changeme`
- Change the default credentials after first login.

**Add a Proxy Host:**

- Go to **Hosts > Proxy Hosts > Add Proxy Host**
- **Domain Names:** `wg-easy.example.com`
- **Scheme:** `http`
- **Forward Hostname/IP:** `wg-easy` (or the Docker network name or `localhost`)
- **Forward Port:** `51821`
- Enable **Block Common Exploits** and **Websockets Support**
- Go to the **SSL** tab:
    - Check **Request a new SSL Certificate**
    - Enter your email, agree to terms
    - Enable **Force SSL** and **HTTP/2 Support** (optional but recommended)
- Click **Save**

NPM will automatically obtain and configure a Let's Encrypt certificate for your domain and proxy HTTPS traffic to WG-Easy[^7][^5].

---

## 4. Access WG-Easy Securely

- Visit `https://wg-easy.example.com` in your browser.
- You should see the WG-Easy admin UI with a valid SSL certificate (padlock icon).

---

## 5. Automatic Certificate Renewal

Nginx Proxy Manager handles Let's Encrypt certificate renewal automatically. No further action is required; certificates are renewed every 60 days before expiry[^7].

---

## Troubleshooting \& Notes

- **DNS:** Your domain must point to your server's public IP for Let's Encrypt to validate.
- **Firewall:** Ensure ports 80 and 443 are open.
- **No direct SSL in WG-Easy:** WG-Easy does not natively support SSL; reverse proxy is required for proper HTTPS[^7][^5].

> This is obviously wrong, as the `docker-compose.yml` from *wg-easy* has an option to disable a secure connection. This *INSECURE* option is set *off by default*.

- **Renewal:** NPM automates renewal; monitor your email for any Let's Encrypt issues.

---

## Summary Table

| Step | Tool/Action | Purpose |
| :-- | :-- | :-- |
| 1. Deploy WG-Easy | Docker Compose | Run WireGuard UI |
| 2. Deploy NPM | Docker Compose | Reverse proxy \& SSL management |
| 3. Configure Proxy | NPM Web UI | Secure WG-Easy with Let's Encrypt |
| 4. Access | Browser | Use HTTPS to access admin UI |
| 5. Renewal | NPM (automatic) | Keeps SSL certificate valid |


---


[^2]: https://insights.ditatompel.com/en/tutorials/installing-wireguard-ui-to-manage-your-wireguard-vpn-server/

[^3]: https://discourse.pi-hole.net/t/web-admin-not-accessible-through-https-wireguard/50248

[^4]: https://github.com/wg-easy/wg-easy

[^5]: https://www.youtube.com/watch?v=BRLB4wRL4cM

[^6]: https://vps-installation.readthedocs.io

[^7]: https://docs.vultr.com/how-to-install-wg-easy-an-opensource-web-ui-for-wireguard-vpn

[^8]: https://superuser.com/questions/1488844/issues-running-wireguard-on-windows-10-as-non-administrator-ui-is-only-access

