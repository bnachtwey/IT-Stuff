# Gathering Support information
## General information
Information nearly always asked for
- `Query SYStem`<br> contains (nearly) **all** information about the server
- `Query ACTlog BEGINTime<StartTime> ENDTime=<End Time>` covering the timeframe of error reported
- Client's `dsmerror.log`


## Special DB2 information

Typically IBM asks for some further data if Db2 is affected
- last `db2diag.log`<br>Look for the timestamp, the db2 usally creates multiple files named `db2diag.log`, `db2diag.log.0`, `db2diag.log.1` ...
- last `dsmffdc.log`<br>same as with `db2diag.log`
- `db2support.zip` <br>created by
  issueing as db2-instance user: `db2support . -d TSMDB1 -c -s`<br> further information on _db2support_ and ...
  - [... HowTo for Unix / Linux](https://www.ibm.com/support/pages/db2-how-collect-db2support-unixlinux-platforms)
  - [... HowTo for Windows](https://www.ibm.com/support/pages/db2-how-collect-db2support-windows-platforms)

## Inspecting DB2
Gathering some more information from the db2 itself by running an _inspection_. This can be done while the db2 is still running. So issue as _instance user_:
```
db2 connect to tsmdb1

db2 inspect check database results keep inspect_resfile.out

db2inspf inspect_resfile.out inspect_resfile_fmt.out
```
The last command converts the output in a readable format ;-)

## Offline Analysis: `db2dart`
If neither the _db2support_ nor the _db2 inspect_ gathers enough information for identifying the problem, running an offline `db2dart` is the last opportunity.

> If possible run an db2 backup before!

