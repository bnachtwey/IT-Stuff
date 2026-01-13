# Notes on triggered execution of "check-VPN-DNS"

<!--
AIA Primarily AI, Content edits, Human-initiated, Reviewed v1.0

# changelog
# date          version    remark
# 2026-01-13    0.1        initial coding: take suggestion from *copilot*, verify and fix it ;-)
#                          approach with xss-lock does not work, besides xss-lock and resolvectl run in different user scopes ...

-->

## 1) Run the script every 10 minutes

Use a **systemd timer** (recommended) or **cron**.

### ✅ Using systemd timer

Create two files:

**Service unit** (`/etc/systemd/system/check-dns.service`):

```ini
[Unit]
Description=Check DNS switching for VPN interface

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check_dns.sh tun0
```

**Timer unit** (`/etc/systemd/system/check-dns.timer`):

```ini
[Unit]
Description=Run DNS check every 10 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=10min
Unit=check-dns.service

[Install]
WantedBy=timers.target
```

Enable and start:

```bash
sudo systemctl enable --now check-dns.timer
```

***

### ✅ Using cron

Add to root’s crontab:

```bash
*/10 * * * * /usr/local/bin/check_dns.sh tun0
```

## 2) Run when the user unlocks the screen

> T.B.D, `xss-lock` seems not to work :-(

This depends on your desktop environment:

### ✅ For systemd-logind (generic approach)

Create a **systemd user unit** that triggers on `Unlock`:

```ini
[Unit]
Description=Run DNS check on screen unlock

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check-VPN-DNS.sh tun0 10.0.0.0/8 mine.localhost 10.0.0.2

[Install]
WantedBy=default.target
```

Then add a **loginctl hook** using `systemd` **inhibitors** or use **PAM**.

### ✅ For GNOME/KDE (using `dbus-monitor`)

You can listen for `org.freedesktop.login1.Session.Unlock` and trigger the script:

```bash
dbus-monitor --system "type='signal',interface='org.freedesktop.login1.Session',member='Unlock'" | \
while read -r
do
    /usr/local/bin/check-VPN-DNS.sh tun0 10.0.0.0/8 mine.localhost 10.0.0.2
done
```

Run this as a background service.

### ✅ For xfce

For **XFCE**, there’s no built-in systemd trigger for screen unlock, but you can hook into **XScreenSaver** or **LightDM** events, which XFCE typically uses.

#### ✅ Option 1: Using `xss-lock` (recommended)

`xss-lock` can run a command when the session is locked/unlocked. Install it:

```bash
sudo apt install xss-lock
```

Then start it with:

```bash
xss-lock -- /usr/local/bin/check-VPN-DNS.sh tun0 10.0.0.0/8 mine.localhost 10.0.0.2
```

This will run the script when the screen is unlocked after a lock event.

#### ✅ Option 2: Using LightDM PAM session hooks

Create a script in:

```bash
/etc/lightdm/lightdm.conf.d/99-dns-check.conf
```

with:

```bash
[Seat:*]
session-setup-script=/usr/local/bin/check-VPN-DNS.sh tun0 10.0.0.0/8 mine.localhost 10.0.0.2
```

This runs at session start, but not exactly on unlock. For unlock, you need **XScreenSaver hooks**.

#### ✅ Option 3: XFCE + XScreenSaver unlock hook

If XFCE uses `xscreensaver` or `light-locker`, you can use `xss-event`:

```bash
dbus-monitor "interface='org.freedesktop.ScreenSaver',member='ActiveChanged'" |
while read -r line
do
    if echo "$line" | grep -q "boolean false"
    then
        /usr/local/bin/check-VPN-DNS.sh tun0 10.0.0.0/8 mine.localhost 10.0.0.2
    fi
done
```

`boolean false` means the screen is now **unlocked**.
