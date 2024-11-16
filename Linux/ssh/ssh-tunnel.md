# Setting up ssh-tunnel

## general syntax
```bash
ssh -f -N ...
```
| Option | Meaning |
| :----: | ------- |
| `-f`   | `ForkAfterAuthentication yes` aka *run in background* |
| `-N`   | run without session, so do not open a remote shell |

## forward local port to remote port
## forward remote port to local port

## run as a systemd service
```
[Unit]
Description=SSH tunnel to server jumphost
After=network.target

[Service]
Type=simple
User=sshtunnel
ExecStart=/usr/bin/ssh -NT -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes wgtunnel
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

---
https://stackoverflow.com/questions/58270768/how-to-specify-remoteforward-in-the-ssh-config-file
