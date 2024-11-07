# Comparing Two Approaches for DB2 Reorganization in the Scope of IBM Spectrum Protect
🚧 IN PROGRESS 🚧
This is an update to my article first published in my former employee's customer magazine [GWDG Nachrichten, p. 16f](https://gwdg.de/about-us/gwdg-news/2021/GN_5-2021_www.pdf)

*Running IBM Spectrum Protect for some time, you will face fragmentation of the internal DB2 database as old entries vanish and new occur. 
Due to the growth of the database, increasing disk space is required. In addition, several processes – e.g. performing the database backup – last longer. 
IBM, therefore, recommends using database reorganization for reclaiming such gaps. 
In this article, we will have a look at two different approaches for a database reorganization, comparing the efforts and savings on a 1.3 TB database.*

## MOTIVATION
After analyzing and reorganizing the database of different Spectrum Protect (SP) instances, the author was shown another approach to clean up the database gaps: extract and insert the
database again. Doing it for the first time, it seems the savings are much more extensive as running an offline reorganization.

Therefore, the idea was born to do a comparison of both approaches. Fortunately, the largest database has not been reorganized yet, so a clone copy could be done. This clone allows freezing
the database, meaning neither having new ingests nor any changes as expiration and online reorganization is disabled. The connection to the real data was prevented by renaming the instance
to SM131T and setting the Library Manager’s LLA (so called “low level adress“) to a wrong port number. 

## SOME WORDS ABOUT THE TEST ENVIRONMENT

The example system was originially a SP7.1.7-500 instance initially set up in October 2014 as TSM 7.1.1-100 -– and already uses the DB2-9.7 format. In this nearly six years, the database has
reached a size of nearly 1.4 TB:
```dsmadmc
sm: SMXYZ>q db f=d

                    Database Name: TSMDB1 
  Total Space of File System (MB): 7,207,430
    Space Used on File System(MB): 1,533,469 
       Space Used by Database(MB): 1,344,338 
        Free Space Available (MB): 9,788,239
                      Total Pages: 71,581,744 
                     Usable Pages: 71,578,640 
                       Used Pages: 65,819,756
                       Free Pages: 5,758,884
            Buffer Pool Hit Ratio: 61.0
            Total Buffer Requests: 4,191,526
                   Sort Overflows: 0 
          Package Cache Hit Ratio: 81.8
     Last Database Reorganization: 
           Full Device Class Name: FDBBA
Number of Database Backup Streams: 1 
     Incrementals Since Last Full: 0
   Last Complete Backup Date/Time: 07/21/2020 08:02:58 AM
        Compress Database Backups: No 
    Protect Master Encryption Key: No
```

The backup data is stored on a single LTO-6 pool managed by a library manager instance (without COPYPOOL), neither replication nor deduplication is used. Several domains are defined to separa-
te different departments; the default policy includes 355 versions in 95 days.

In the last years, several updates were done, but due to some complexity in the whole TSM/SP setup, the upgrade to SP 8 was postponed at the GWDG.

For this comparison the instance was moved to a new server with two Intel 4112 CPUs (8 Cores @ 2.60 GHz, HyperThreading disabled), 128 GB RAM and local SSD storage running SuSE Linux 
Enterprise 12: 2 x 480 GB (RAID-1) for Operating System and Actlog, 2 x 960 GB (RAID-1) for Archlog, 2 x 3.84 TB (two single SSDs, no RAID nor JBOD) for the database and 2 x 3.84 TB (two 
single SSDs) for database backup, extraction files (*.ost) and temporary reorganization space. All SSDs are “read-intensive”. Sure, this setup does not follow the blueprint suggestions, but it is much more affordable.

For each approach, the system is restored to the initial set-up without having to run the alter tablespace command mentioned below.

## ESTIMATING THE POTENTIAL OF A DB2 REORGANIZATION
Different DB2 commands allow measuring the amount of space used by the so-called “gaps in the DB2”. The more easy way to do this is by using a Perl™ script `analyse_DB2_formulas.pl`
provided by IBM [1]. Just logging in as the instance user and running that script shows the potential of a DB2 reorganization. For 
this example Spectrum Protect instance the result is as shown:
```dsmadmc
BEGIN SUMMARY
"db2 alter tablespace BACKOBJIDXSPACE reduce max" will return =174.2G to the operating system file system
If BACKUP_OBJECTS were to be off line reorganized the estimated savings is Table          144 GB, Index    0 GB 
If BF_AGGREGATED_BITFILES were to be off line reorganized the estimated savings is Table   14 GB, Index   57 GB 
If GROUP_LEADERS were to be off line reorganized the estimated savings is Table            64 GB, Index   75 GB 
If AS_SEGMENTS were to be off line reorganized the estimated savings is Table               2 GB, Index    0 GB 
If AF_BITFILES were to be off line reorganized the estimated savings is Table               0 GB, Index    2 GB 
If AF_SEGMENTS were to be off line reorganized the estimated savings is Table 0 GB, Index   1 GB 
If BF_AGGREGATE_ATTRIBUTES were to be off line reorganized the estimated savings is Table   0 GB, Index    0 GB 
If TSMMON_STATUS were to be off line reorganized the estimated savings is Table             1 GB, Index    0 GB 
If ACTIVITY_LOG were to be off line reorganized the estimated savings is Table             26 GB, Index    4 GB 
Total estimated savings 390 GB
END SUMMARY
```

## FEEING DATABASE SPACE BY `“alter tabespace”`

Of special interest is the first line of the summary file, as 174.2 GB can be freed just by altering the tablespace “BACKOBJIDXSPACE” – this can be done while the instance 
(at least the database according to the instance) is running. It is recommended not to perform a database backup, expiration, or online reorganization 
when entering the command:
```dsmadmc
q db f=d
                    Database Name: TSMDB1 
  Total Space of File System (MB): 7,207,430
    Space Used on File System(MB): 1,533,469 
       Space Used by Database(MB): 1,165,969 
        Free Space Available (MB): 5,673,961
                      Total Pages: 65,873,176 
                     Usable Pages: 65,871,624 
                       Used Pages: 65,819,748
                       Free Pages: 51,812 
            Buffer Pool Hit Ratio: 96.5
            Total Buffer Requests: 47,736,641
                   Sort Overflows: 0 
          Package Cache Hit Ratio: 83.6
     Last Database Reorganization:
           Full Device Class Name: FDBBA
Number of Database Backup Streams: 1 
     Incrementals Since Last Full: 0
   Last Complete Backup Date/Time: 07/21/2020 08:02:58 AM
        Compress Database Backups: No 
    Protect Master Encryption Key: No
```
> [!TIP]
> The number of `Total Pages` decreased from `71,581,744` to `65,873,176` <br>
> and the `Space Used on File System(MB):` from `1,344,338` to `1,165,969`.
