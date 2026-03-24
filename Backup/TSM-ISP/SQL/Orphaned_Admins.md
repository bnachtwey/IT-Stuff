# get orphaned admin accounts

## .. and connected schedules

### Admin Schedules

```SQL
select SCHEDULE_NAME, CHG_ADMIN, CHG_TIME  from ADMIN_SCHEDULES where CHG_ADMIN not in (select ADMIN_NAME from ADMINS)
```

```DSMADMC
Protect: TSMPROD>select SCHEDULE_NAME, CHG_ADMIN, CHG_TIME  from ADMIN_SCHEDULES where CHG_ADMIN not in (select ADMIN_NAME from ADMINS)

SCHEDULE_NAME                        CHG_ADMIN                            CHG_TIME
--------------------------------     --------------------------------     ---------------------------
TEST                                 TEST                                 2024-08-05 14:05:38.000000
CLEAN                                TSMADMIN                             2023-03-31 13:39:08.000000
CONTAINER_COPY                       TSMADMIN                             2022-12-20 16:12:29.000000
TSM_ADMIN                            TSMADMIN                             2023-03-31 13:39:30.000000
```

### Client Schedules

```SQL
select DOMAIN_NAME, SCHEDULE_NAME, CHG_ADMIN, CHG_TIME  from CLIENT_SCHEDULES where CHG_ADMIN not in (select ADMIN_NAME from ADMINS)
```

```DSMADMC
Protect: TSM>select DOMAIN_NAME, SCHEDULE_NAME, CHG_ADMIN, CHG_TIME  from CLIENT_SCHEDULES where CHG_ADMIN not in (select ADMIN_NAME from ADMINS)

DOMAIN_NAME             SCHEDULE_NAME                     CHG_ADMIN        CHG_TIME
----------------------  --------------------------------  ---------------  ----------------- --------------------------------
PVE                     HOST-DAILY                        BNW              2025-03-25 12:11:48.000000
WORKSTATION             09H00                             TSMADMIN         2025-03-25 09:32:59.000000
WORKSTATION             WS_DAILY_22                       TSMADMIN         2022-11-30 15:11:58.000000
```

## .. and connected scripts

```SQL
select DISTINCT(NAME), CHG_ADMIN, CHG_TIME  from scripts where CHG_ADMIN not in (select ADMIN_NAME from ADMINS)
```

```DSMADMC
Protect: TSM>select DISTINCT(NAME), CHG_ADMIN, CHG_TIME  from scripts where CHG_ADMIN not in (select ADMIN_NAME from ADMINS)

NAME                                 CHG_ADMIN                            CHG_TIME
--------------------------------     --------------------------------     ---------------------------
DRIVEPATH                            TSMADMIN                             2018-01-29 16:10:23.000000
GENDEDUPSTATS                        TSMADMIN                             2022-12-20 16:13:38.000000
EXP2                                 TSMADMIN                             2023-06-21 14:59:24.000000
CONTAINER_COPY                       TSMADMIN                             2023-09-18 16:37:04.000000
```
