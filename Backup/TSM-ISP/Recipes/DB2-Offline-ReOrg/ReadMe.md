# Recipies for DB2 within IBM SP

some Stuff around DB2 in the scope of IBM TSM / ISP

(C) 2023f Bjørn Nachtwey, <tsm@bjoernsoe.net>

## already available

- [DB2-OfflineReOrg.Linux.md](DB2-OfflineReOrg.Linux.md): process template for offline reorganization of the ISP Db2 (approach using extra, temporary space)

- [db2-selects.sh](./db2-selects.sh): collection of `select` statements needed for Offline-Reorg (`bash` for Linux/AIX)
- [reorg-tables.sh](./reorg-tables.sh): collections of commands to run the Db2 reorganization (`bash`, for Linux/AIX)
- [run-stats.sh](./run-stats.sh): collection of commands to run the `runstats` on Db2 (`bash`, for Linux/AIX)

## comming up

- [DB2-OfflineReOrg.Windows.md] : same as for Linux, but for Windows hosts
- [db2-select.cmd]   : same as for Linux, but for Windows hosts
- [reorg-tables.cmd]: same as for Linux, but for Windows hosts
- [run-stats.cmd]   : same as for Linux, but for Windows hosts
