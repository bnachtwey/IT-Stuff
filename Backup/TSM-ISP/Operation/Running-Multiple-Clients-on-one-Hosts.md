# Running multiple Clients / DSMCAD instances on one host

<!-- 
<!--
AIA Primarily human, Content edits, Human-initiated, Reviewed, DeepL v1.0

# changelog
# date          version    AIA                          remark
# 2026-03-27    0.1        AIA Ph Ce Hin R DeepL        initial copy from where I put it first ;-) 
-->

## Excurse: Single instance

by default, just on `dsmcad` is running on a single host. Therefore one option inside the `dsm.opt` (Windows) or `dsm.sys` (Linux, Unix, Mac) is mandatory:

```dsmadmc
MANAGEDService SCHEDULE
```

> [!Note]
>
> The `dsmcad` was recommended for Windows computers because it requires fewer memory resources while the *Scheudler* is not running. Given the current amount of RAM available on servers and clients, the additional memory usage caused by a scheduler running continuously is negligible. So there are only few reasons to configure the `dsmcad` instead of the *Scheduler* without:
>
> - The `dsmcad` may also handle the WebGUI (according to some security issues in the past, I strongly recommend, NOT TO install it)
> - Changes in the config file `dsm.[sys|opt]` requries a restart to take effect, the `dsmcad` does this automatically.
>
> On Linux, Unix MacOS, however, dsmcad can be started directly via init.d or systemd, but the mandatory services must be created for the scheduler. On the other hand, the `dsmcad` service is provided by the installation package, so it's recommended for Linux/BSD.

Darüber hinaus sollten Sie überlegen, die beiden folgenden Optionen zu nutzen:

- `SCHEDLOGMAX <MB>`
- `SCHEDLOGRetention <days>[D,S]`

The first option controls the maximum size of the scheduler log in `megabyte`, the second one limits the retention time by given number of days to keep (ingnoring how large the files becomes). The additional options controls if data is then `D`eleted (default) or prunged and `S`aved in another file (`dsmschedlog.pru`).

## Multiple dsmcad services on one host

### Windows

As Windows clients to use an dedicated `dsm.opt` file for any configuration, running multiple schedulers is quite simple:

1) Create a separate `dsm.opt` file for each scheduler.
2) Run the wizard for "configuring client scheduler" multiple times and assign the appropriate `dsm.opt` file to the service.

3) **Done!**

### Linux
