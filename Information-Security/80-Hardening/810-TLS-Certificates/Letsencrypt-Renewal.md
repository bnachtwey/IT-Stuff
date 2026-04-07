# Automating Let's Encrypt Certificate Renewal

Let's Encrypt certificates are valid for 90 days, so automating their renewal is essential for uninterrupted HTTPS service. The standard tool for this is **Certbot**, and automation is typically handled by scheduling periodic renewal checks using either **cron jobs** or **systemd timers**.

---

## Using Cron Jobs

- Certbot is designed to be run periodically. The command to renew all certificates is:

```bash
sudo certbot renew
```

- To automate this, add a cron job. For example, to check for renewal twice daily, edit the root crontab:

```bash
sudo crontab -e
```

And add:

```
0 7,19 * * * certbot -q renew
```

This will quietly check for certificate renewals at 7:00 AM and 7:00 PM every day[^1][^2][^6].
- Certbot typically installs a cron job automatically at `/etc/cron.d/certbot`, but you can add your own if needed[^2].

---

## Using Systemd Timers

- On systemd-based systems, you can use a timer instead of cron. This example creates a service and timer to run `certbot renew` daily:

1. Create `/etc/systemd/system/RenewCertbot.service`:

```bash
[Unit]
Description=RenewCertbot

[Service]
Type=oneshot
ExecStart=/usr/bin/certbot renew
WorkingDirectory=/tmp
```

2. Create `/etc/systemd/system/RenewCertbot.timer`:

```bash
[Unit]
Description=RenewCertbot

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

3. Enable and start the timer:

```bash
sudo systemctl enable RenewCertbot.timer
sudo systemctl start RenewCertbot.timer
```

This will check for renewals daily[^8].

---

**Best Practices**

- **Test Renewal:** Before relying on automation, test renewal with:

```bash
sudo certbot renew --dry-run
```

This ensures your configuration is correct and renewal will succeed when scheduled[^6].
- **Reload Services:** If your web server (e.g., Nginx or Apache) needs to be reloaded after renewal, Certbot can handle this automatically if installed with the appropriate plugin (e.g., `--nginx` or `--apache`), or you can add a deploy hook to reload the server after renewal[^2].

---

**Summary Table**


| Method | How to Schedule | Example Command |
| :-- | :-- | :-- |
| Cron Job | `/etc/cron.d/certbot` | `0 7,19 * * * certbot -q renew` |
| Systemd Timer | systemd timer/service | See service/timer example above |


---

Automating Let's Encrypt renewal is straightforward using Certbot with either cron or systemd. Always verify your setup with a dry run and ensure your web server reloads certificates as needed[^2][^6][^8].

[^1]: https://community.letsencrypt.org/t/how-to-automatically-renew-certificates/4393

[^2]: https://www.baeldung.com/linux/letsencrypt-renew-ssl-certificate-automatically

[^3]: https://www.reddit.com/r/sysadmin/comments/lmg9bo/lets_encrypt_certificate_deployment_automation/

[^4]: https://community.home-assistant.io/t/automate-lets-encrypt-certificate-renewals/509668

[^5]: https://poanchen.github.io/blog/2019/07/13/The-easiest-way-to-make-Let-s-Encrypt-renewal-automated

[^6]: https://tecadmin.net/auto-renew-lets-encrypt-certificates/

[^7]: https://www.youtube.com/watch?v=J6LTMsa5bPM

[^8]: https://techoverflow.net/2019/07/07/how-to-install-automated-certbot-letsencrypt-renewal-in-30-seconds/

