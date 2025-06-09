# My notes on `tmux`

`tmux` developed in 2007, `screen` in 1996
https://tmuxcheatsheet.com/
## `screen` vs `tmux`
pro `screen`
- ... runs on more systems like `AIX`, `solaris`
- ... works on serial connections
- ... screen supports ACL and more detailed controls on shared sessions
pro `tmux`
- ... allows more sophisticated scripting

control key
- screen: `<CTRL>-<a>`
- tmux: `<CTRL>-<b>` <= *`b`is default*, change by `set -g prefix C-<X>` for `X`

## shortcuts

| Task                         | screen              | tmux                 |
| :--------------------------- | ------------------- | -------------------- |
| create new session with Name | `screen  -S <Name>` | `tmux new -s <Name>` |

## `~\tmux.conf`

