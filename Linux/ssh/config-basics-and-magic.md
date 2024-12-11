# Some general remarks on `.ssh/config`

> [!TIP]
> the config file is processed *top-down*, so
>  - put the `include config.d/*` to the top, processing detailed settings from dedicated files first
>  - put *catch all* statements at the end, so they are processed only if no other, more specific setting was done

🚧 I'm still collecting and not sure, which is the best default setting ... 🚧

# useful configuration settings
- `include config.d/*` should be places at the top of your local `config` file to read settings for specific hosts first
- `IdentitiesOnly yes` <br>
  Specifies that ssh should only use the configured authentication identity and certificate files (either the default files, or those explicitly configured in the ssh_config files or passed on the ssh(1) command-line), even if ssh-agent(1) or a PKCS11Provider or SecurityKeyProvider offers more identities.  The argument to this keyword must be yes or no (the default).  This option is intended for situations where ssh-agent offers many different identities.

