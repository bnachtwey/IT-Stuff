# Some general remarks on `.ssh/config`

> [!TIP]
> the config file is processed *top-down*, so
>  - put the `include config.d/*` to the top, processing detailed settings from dedicated files first
>  - put *catch all* statements at the end, so they are processed only if no other, more specific setting was done

🚧 I'm still collecting and not sure, which is the best default setting ... 🚧

# useful configuration settings
- `include config.d/*` should be places at the top of your local `config` file to read settings for specific hosts first

example configuration setting, may be 
```
Host <Alias1> [Alias2] [ ... Alias N]`<br>
  Define *Shortnames* or *Aliases* to Access hosts using specific settings
- `HostName <IP-Name or IP-Adress>`<br>

# Some magic's ideas
