# Notes on the attempt to use MacOS

No need to have a ReadMe, as MacOS is just pain in the a...

## "hidden" characters and keys

Approach for german keyboard layout, but MacOS running english language, others setups ~~may~~ will be different.

| missed character / key | MacOS dislocation |
| :--------------------: | :---------------: |
| `~`                    | `<OPTION> + <N>`  |
| `[`                    | `<OPTION> + <5>`  |
| `]`                    | `<OPTION> + <6>`  |
| `\|`                    | `<OPTION> + <7>`  |
| `{`                    | `<OPTION> + <8>`  |
| `}`                    | `<OPTION> + <9>`  |
| `\`                    | `<OPTION> + <Y>` <br> `<OPTION>+<SHIFT>+<7>`  |
| `<Pos1>`               | `<OPTION>+<Left>` |
| `<End>`                | `<OPTION>+<Right>` |
| `<PgnUp>`              | `<Fn> + <Up>`     |
| `<PgnDown>`            | `<Fn> + <Down>`   |
| `<DEL>`                | `<Fn> + <BackSpace>` |
| `<STRG> + <PgnUp>`     | `<CMD> + <Up>`    |
| `<STRG> + <PgnDown>`   | `<CMD> + <Down>`  |

## zsh issues

### getting rid of `zsh`

```bash
chsh -s /bin/bash
```

### force reading of `.bashrc`

By default new sessions are _login sessions_ that ignore `.bashrc` but evaluate `.bash_profile` :-(

> [!TIP]
>
> just force using `bashrc` by
>
> ```bash
> echo "if [ -f ~/.bashrc ]; then source ~/.bashrc; fi" >> ~/.bash_profile
> ```

## collecting further pain points ...

### no localhost access ?

by default as well _Safari_ as other browsers like _FireFox_ have no access to localhost. Setting up e.g. `rclone` therefore needs a more reliable device like a linux notebook

### zsh prohibits usage of scp

No idea why, but `scp` cannot used from `zsh`

> [!TIP]
>
> just start a `bash` and everything is fine :-)
