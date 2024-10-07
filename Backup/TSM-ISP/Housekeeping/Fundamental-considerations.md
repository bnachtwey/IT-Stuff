# Some Fundamental considerations on the housekeeping job(s) for TSM/ISP
🚧just collecting all my ideas ... 🚧
You may consider to create 

## an internal housekeeping script, that
- makes a daily backup
  - preferably to a FILE device class, as these backups are important for a “point-in-time” restore
- makes an additional DB2 snapshot backup
  - preferably on a TAPE device class, as these backups are important for a disaster recovery restore
- cleans up the `volhistory`
- writes at least on `planfile`
- additionally backs up the `defconf.dat` and  `volhist.dat` to a second location

## an external houesekeeping script that
- script should run daily
- cuts off the db2diaglog daily by
  ```
  su -c "db2diag -A" <instance user>
  ```
- backs up some vital server data to another location, including:
  - the *planfile*
  - `devconf.dat`, `volhist.dat` (OK, both included in the planfile, but as dedicated files you don't have to extract them)
  - the keydb and the masterkey
  - the server's certificates: so all `cert*` files
 
- remove all `*.events.bin` files
- remove all `<ProcID>.apm.bin` and all `<ProcID>.dump.bin` files

- collect data on the db2 fragmentation by running the `db2analysis.pl` script
  - daily run only useful if you want to collect and monitor the change of the results
