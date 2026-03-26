# Collected SQL statements

<!--
<!--

###############################################################################
# changelog
# date          version AIA       remark
# 2026-03-26    0.1.1   no AI     added changelog and AIA
#
##############################################################################
#
#   SQL/ReadMe.md
#    
#   Overview Page for collected SQL statements in the scope of DB2 @ IBM SP
#
#   The Author:
#   (C) 2020 --      Bjørn Nachtwey, tsm@bjoernsoe.net
#
#   Grateful Thanks to the Companies, who allowed to do the development
#   (C) 2023 --      Cristie Data Gmbh, www.cristie.de
#   (C) 2020 -- 2023 GWDG, www.gwdg.de
#
##############################################################################
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
##############################################################################
-->

-->

## on Containers

### get Number of Containers grouped by TYPE and STATE

```SQL
select count(*) as "#", STATE, TYPE from CONTAINERS group by STATE, TYPE
```

```DSMADMC
Protect: TSM>select count(*) as "#", STATE, TYPE from CONTAINERS group by STATE, TYPE

           #     STATE                TYPE
------------     ----------------     ----------------
         266     AVAILABLE            DEDUP
         180     AVAILABLE            NONDEDUP
          80     PENDING              DEDUP
```

### get number of containers accessed some days ago *and* sparsely filled

look only for containers, that

- are *AVAILABLE*
- were last accessed for writing more than 30 days ago
- are filled 10% or less

```SQL
select count(*) as "#" from CONTAINERS where ( days(CURRENT_DATE) - days(LASTWR_DATE)>30) and (FREE_SPACE_MB / TOTAL_SPACE_MB)>0.9 and STATE='AVAILABLE'
```

```DSMADMC
Protect: TSM>select count(*) as "#" from CONTAINERS where ( days(CURRENT_DATE) - days(LASTWR_DATE)>30) and (FREE_SPACE_MB / TOTAL_SPACE_MB)>0.9 and STATE='AVAILABLE'

           #
------------
         226
```

### get amount of wasted space for containers accessed some days ago *and* sparsely filled

look only for containers, that

- are *AVAILABLE*
- were last accessed for writing more than 30 days ago
- are filled 10% or less

```SQL
select cast(sum(FREE_SPACE_MB) / 1024 as dec(10,2)) as "Space (GB)" from CONTAINERS where ( days(CURRENT_DATE) - days(LASTWR_DATE)>30) and (FREE_SPACE_MB / TOTAL_SPACE_MB)>0.9 and STATE='AVAILABLE'
```

```DSMADMC
Protect: TSM>select CAST(sum(FREE_SPACE_MB) / 1024 AS DEC(10,2)) as "Space (MB)" from CONTAINERS where ( days(CURRENT_DATE) - days(LASTWR_DATE)>30) and (FREE_SPACE_MB / TOTAL_SPACE_MB)>0.9 and STATE='AVAILABLE'

   Space (GB)
-------------
      2081.00
```

### get X less filled containers accessed some days ago *and* sparsely filled

look only for containers, that

- are *AVAILABLE*
- were last accessed for writing more than 30 days ago
- are filled 10% or less
- number is *limited* to *10* in this example

```SQL
select CONTAINER_NAME, FREE_SPACE_MB, TOTAL_SPACE_MB  from CONTAINERS where ( days(CURRENT_DATE) - days(LASTWR_DATE)>30) and (FREE_SPACE_MB / TOTAL_SPACE_MB)>0.9 and STATE='AVAILABLE' order by FREE_SPACE_MB DESC limit 10
```

```DSMADMC
CONTAINER_NAME: G:\TSMContainer4\0f\0000000000000fec.dcf
 FREE_SPACE_MB: 10228
TOTAL_SPACE_MB: 10240

CONTAINER_NAME: F:\TSMContainer2\01\00000000000001a5.dcf
 FREE_SPACE_MB: 10227
TOTAL_SPACE_MB: 10240

CONTAINER_NAME: G:\TSMContainer1\00\000000000000000c.dcf
 FREE_SPACE_MB: 10227
TOTAL_SPACE_MB: 10240

CONTAINER_NAME: F:\TSMContainer2\08\00000000000008e8.dcf
 FREE_SPACE_MB: 10226
TOTAL_SPACE_MB: 10240

CONTAINER_NAME: G:\TSMContainer1\01\0000000000000156.dcf
 FREE_SPACE_MB: 10226
TOTAL_SPACE_MB: 10240

CONTAINER_NAME: G:\TSMContainer1\00\0000000000000052.dcf
 FREE_SPACE_MB: 10225
TOTAL_SPACE_MB: 10240

CONTAINER_NAME: G:\TSMContainer1\01\0000000000000186.dcf
 FREE_SPACE_MB: 10225
TOTAL_SPACE_MB: 10240

CONTAINER_NAME: G:\TSMContainer1\01\0000000000000199.dcf
 FREE_SPACE_MB: 10225
TOTAL_SPACE_MB: 10240

CONTAINER_NAME: F:\TSMContainer2\01\0000000000000165.dcf
 FREE_SPACE_MB: 10224
TOTAL_SPACE_MB: 10240

CONTAINER_NAME: F:\TSMContainer2\09\000000000000092a.dcf
 FREE_SPACE_MB: 10224
TOTAL_SPACE_MB: 10240
```

### Create list of MOVE commands to reclaim sparsely filled containers

look only for containers, that

- are *AVAILABLE*
- were last accessed for writing more than 30 days ago
- are filled 10% or less
- number is *limited* to *10* in this example

```SQL
select 'MOVE CONTAINER ' || CONTAINER_NAME as MOVE_CMD from CONTAINERS where ( days(CURRENT_DATE) - days(LASTWR_DATE)>30) and (FREE_SPACE_MB / TOTAL_SPACE_MB)>0.9 and STATE='AVAILABLE' order by FREE_SPACE_MB DESC limit 10
```

```DSMADMC
Protect: TSM>select 'MOVE CONTAINER ' || CONTAINER_NAME as MOVE_CMD from CONTAINERS where ( days(CURRENT_DATE) - days(LASTWR_DATE)>30) and (FREE_SPACE_MB / TOTAL_SPACE_MB)>0.9 and STATE='AVAILABLE' order by FREE_SPACE_MB DESC limit 10

MOVE_CMD: MOVE CONTAINER G:\TSMContainer4\0f\0000000000000fec.dcf

MOVE_CMD: MOVE CONTAINER F:\TSMContainer2\01\00000000000001a5.dcf

MOVE_CMD: MOVE CONTAINER G:\TSMContainer1\00\000000000000000c.dcf

MOVE_CMD: MOVE CONTAINER F:\TSMContainer2\08\00000000000008e8.dcf

MOVE_CMD: MOVE CONTAINER G:\TSMContainer1\01\0000000000000156.dcf

MOVE_CMD: MOVE CONTAINER G:\TSMContainer1\00\0000000000000052.dcf

MOVE_CMD: MOVE CONTAINER G:\TSMContainer1\01\0000000000000199.dcf

MOVE_CMD: MOVE CONTAINER G:\TSMContainer1\01\0000000000000186.dcf

MOVE_CMD: MOVE CONTAINER F:\TSMContainer2\01\0000000000000165.dcf

MOVE_CMD: MOVE CONTAINER F:\TSMContainer2\09\000000000000092a.dcf
```

> [!TIP]
> If you have configured *command routing* to the server itself, you can replace `MOVE_CMD` with your server's name and get a list of commands.
>
> If you redirect the output to a macro file, you can run these commands after the select automatically -- *without beeing prompted for "yes"*
