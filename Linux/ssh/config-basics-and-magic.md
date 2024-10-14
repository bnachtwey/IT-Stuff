# Some general remarks on `.ssh/config`
- the config file is processed *top-down*, so
  - put the `include config.d/*` to the top, processing detailed settings from dedicated files first
  - put *catch all* statements at the end, so they are processed only if no other, more specific setting was done

# Some magic's ideas
