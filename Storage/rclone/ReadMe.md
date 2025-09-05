# ReadMe

## healing MacOS pains

Using the _rclone_ package from _homebrew_ not mount of remote shares is possible. But getting the rclone from the projekt itself, the binary is blocked by MacOS' _"security"_ features as the binary is _not verified_.

The Workaround is very simple: Just remove the _quarantine_ setting from the binary:

```bash
/usr/sbin/xattr -d com.apple.quarantine ~/bin/rclone
```

DONE!

> [!TIP]
>
> removing the _quarantine attribute_ need no escalated privileges, **ordinary users can do** so :-)
