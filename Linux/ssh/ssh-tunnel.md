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

---
https://stackoverflow.com/questions/58270768/how-to-specify-remoteforward-in-the-ssh-config-file
