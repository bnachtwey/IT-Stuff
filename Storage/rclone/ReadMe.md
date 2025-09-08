# ReadMe

## MacOS pains

### homebrew package with limited functionality, binary blocked by MacOS
Using the _rclone_ package from _homebrew_, mounting remote shares is not possible. But getting the rclone binary from the projekt itself, it's blocked by MacOS' (so called) _"security"_ features as the binary is _not verified_.

The Workaround is very simple: Just remove the _quarantine_ setting from the binary:

```bash
/usr/sbin/xattr -d com.apple.quarantine ~/bin/rclone
```

DONE!

> [!TIP]
>
> removing the _quarantine attribute_ need no escalated privileges, **ordinary users can do** so :-)


### `rclone authorize` fails due to _no access to localhost_

_rclone_ starts a local webserver to redirect to the foreign authentication server. 

**unfortunately, MacOS distrusts the host it's running (facepalm)**

> still looking for a workaround to overrule MacOS (so called) _"security settings"_ :-(

### `rclone rcd --rc-web-gui` fails due to _no access to localhost_

_rclone_ sets up a local webserver for accessing the connected drive, unfortunately. 

**unfortunately, MacOS distrusts the host it's running (facepalm)**

> still looking for a workaround to overrule MacOS (so called) _"security settings"_ :-(
