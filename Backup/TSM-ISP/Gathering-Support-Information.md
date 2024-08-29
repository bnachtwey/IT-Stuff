# Gathering Support information
## general information
Information nearly always asked for
- `Query SYStem`<br> contains (nearly) **all** information about the server
- `Query ACTlog BEGINTime<StartTime> ENDTime=<End Time>` covering the timeframe of error reported
- Client's `dsmerror.log`


## Special DB2 information

Typically IBM asks for some further data if Db2 is affected
- last `db2diag.log`<br>Look for the timestamp, the db2 usally creates multiple files named `db2diag.log`, `db2diag.log.0`, `db2diag.log.1` ...
- last `dsmffdc.log`<br>same as with `db2diag.log`
- `db2support.zip` <br>gatherin by
  - [HowTo for Unix / Linux](https://www.ibm.com/support/pages/db2-how-collect-db2support-unixlinux-platforms)
  - [HowTo for Windows](https://www.ibm.com/support/pages/db2-how-collect-db2support-windows-platforms)
