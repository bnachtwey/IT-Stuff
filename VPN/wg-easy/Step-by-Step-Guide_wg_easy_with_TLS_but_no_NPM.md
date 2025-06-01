# Step-by-Step: Install Let's Encrypt Certificate in WG-Easy Container

## **1. Obtain a Let's Encrypt Certificate on the Host**

You cannot run Certbot directly inside the wg-easy container. Instead, generate the certificate on the host, then mount it into the container.

**A. Install Certbot on the Host:**

```bash
sudo apt update
sudo apt install certbot
```

**B. Obtain the Certificate (standalone mode):**
Stop any service using port 80 (temporarily), then run:

```bash
sudo systemctl stop nginx apache2 docker
sudo certbot certonly --standalone -d wg-easy.example.com
```

- Replace `wg-easy.example.com` with your domain pointing to your server's public IP.

Certificates will be saved in `/etc/letsencrypt/live/wg-easy.example.com/` as `fullchain.pem` and `privkey.pem`.

---

## **2. Mount Certificates into the WG-Easy Container**

Modify your `docker-compose.yml` (or `docker run` command) to mount the certificates:

```yaml
services:
  wg-easy:
    image: weejewel/wg-easy
    container_name: wg-easy
    environment:
      - WG_HOST=wg-easy.example.com
      - PASSWORD=your_admin_password
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    volumes:
      - ./data:/etc/wireguard
      - /etc/letsencrypt/live/wg-easy.example.com/fullchain.pem:/etc/wg-easy/ssl/cert.pem:ro
      - /etc/letsencrypt/live/wg-easy.example.com/privkey.pem:/etc/wg-easy/ssl/key.pem:ro
    restart: unless-stopped
```

- Adjust the paths if your certificate files are elsewhere.

---

## **3. Configure WG-Easy to Use the Certificates**

By default, WG-Easy looks for certificates at `/etc/wg-easy/ssl/cert.pem` and `/etc/wg-easy/ssl/key.pem` inside the container. The above volume mounts ensure the correct files are available at those paths.

---

## **4. Restart the WG-Easy Container**

```bash
docker compose down
docker compose up -d
```

or

```bash
docker restart wg-easy
```

WG-Easy will now serve HTTPS using your Let's Encrypt certificate.

---

## **5. Automatic Certificate Renewal**

Let's Encrypt certificates are valid for 90 days. Set up a cron job on the host to renew and reload:

**A. Add a cron job for renewal:**

```bash
sudo crontab -e
```

Add this line:

```cron
0 3 * * * certbot renew --deploy-hook "docker restart wg-easy"
```

- This checks daily at 3:00 AM and restarts the container if the certificate is renewed.

---

## **Summary Table**

| Step | Action |
| :-- | :-- |
| Obtain certificate | `certbot certonly --standalone -d wg-easy.example.com` |
| Mount certs into container | Volume mount in Docker Compose (`cert.pem`, `key.pem`) |
| Configure WG-Easy | Default: `/etc/wg-easy/ssl/cert.pem` and `/key.pem` |
| Restart container | `docker compose up -d` or `docker restart wg-easy` |
| Automate renewal | Cron job with `certbot renew` and container restart |


---

This approach ensures WG-Easy uses a valid Let's Encrypt certificate **inside** the container, as required for secure admin access[^1][^5][^6].

[^1]: https://github.com/wg-easy/wg-easy

[^2]: https://github.com/wg-easy/wg-easy/issues/1084

[^3]: https://www.reddit.com/r/docker/comments/1dhbe01/traefik_deactivating_tls_1011/

[^4]: https://hub.docker.com/r/weejewel/wg-easy

[^5]: https://docs.vultr.com/how-to-install-wg-easy-an-opensource-web-ui-for-wireguard-vpn

[^6]: https://www.einsle.com/blog/wireguard-easy-vpn-mit-docker-und-ssl-auf-ubuntu-22-04-installieren-422/

[^7]: https://www.truenas.com/docs/scale/22.12/scaletutorials/apps/communityapps/installwgeasyapp/

[^8]: https://elest.io/open-source/wg-easy/resources/managed-service-features

