# Problems and Workarounds

## `rcd ls` shows recursively ALL files

limit the output to a number of depth levels

```bash
rclone ls --max-depth <N> <remote>:[path/]
```

## restrict `rcd ls` showing only certain files

`grep` + _RegEx_ are your solution, e.g.

```bash
rcd ls <path> | grep ".pdf$"
```

> DON'T forget the  `$` at the end, otherwise grep will match all files _containing_ your suffix of concern ...
