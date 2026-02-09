# Starting the TSM server in Maintenance Mode

staring with TSM 7 you can start a TSM intance in maintenance mode which suppresses client session, automatically starting scripts …

## Linux

* starting the instance as root – `-q` indicates the quite mode, so without an admin shell

  ```bash
  /opt/tivoli/tsm/server/bin/rc.dsmserv -u <USER> -i <Instance Home> -q MAINT
  ```

* starting the instance as root – the missing of `-q` indicates the console mode, so with an admin shell in the foreground

  ```bash
  /opt/tivoli/tsm/server/bin/rc.dsmserv -u <USER> -i <Instance Home> MAINT
  ```

### the easier way

there's also a quite more simple way to run a server in Maintenance mode:

1) I suggest to run it in a screen, so first start a screen by `screen -S <Name>`
2) become instance user: `sudo - <Instance user's account name>`
3) switch to folder containing the server's config files: `cd <path to config files>`
4) run directly `dsmserv MAINT`

so for instance TSM123 it may look like
```bash
screen -S "TSM123"
su - tsm123
cd ~/config
dsmserv MAINT
```

## Windows

Due to the [ISP documentation](https://www.ibm.com/docs/en/storage-protect/8.2.0?topic=utilities-dsmserv-start-server) windows should work in the same way as Linux

* run Windows-Commandline as admin:

  ![Start CMD as admin](./Pictures/CMD_as_admin.png)

* you need to remind the different commandline options, espcially giving the Instance by issuing the registry key

  ```cmd
  D:\TSM123-Config>"c:\Program Files\Tivoli\TSM\server\dsmserv.exe" -k tsm123 MAINT
  ```

  ![Start TSM123 from CMD](./Pictures/Start-TSM123)


>[!WARNING] 
>
> Starting the instance without the `-k <Instance Name` seems to work, but right at the beginning some error messages
>
> ```CMD
> C:\Windows\system32>d:
>
> D:\>cd TSM123\Config
>
> D:\TSM123/Config>"c:\Program Files\Tivoli\TSM\server\dsmserv.exe" MAINT
> The server has not been properly installed.
> Could not find the output logfile key.
> Issue dsmserv -help for a usage statement
>
> ANR7800I DSMSERV generated at 10:27:11 on Feb  3 2026.
>
> IBM Spectrum Protect for Windows
> Version 8, Release 1, Level 27.000
>
> Licensed Materials - Property of IBM
>
> (C) Copyright IBM Corporation 1990, 2020.
> All rights reserved.
> U.S. Government Users Restricted Rights - Use, duplication or disclosure
> restricted by GSA ADP Schedule Contract with IBM Corporation.
> 
> ANR0900I Processing options file D:\SM180-Config\dsmserv.opt.
> ANR3339I Default Label in key data base is TSM Server SelfSigned SHA Key.
> ANR4726I The ICC support module has been loaded.
> ANR0990I Server restart-recovery in progress.
>
> DBI1306N    Das Instanzprofil ist nicht definiert.
> ```


## further readings

* [IBM Documention on startin / stopping an SP instance](https://www.ibm.com/docs/en/storage-protect/8.2.0?topic=utilities-dsmserv-start-server)
