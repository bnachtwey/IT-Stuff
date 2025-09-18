# Get List of tables and colums used by Db2 for SP/TSM

## get list of tables at all
```sql
>select * from TABLES limit 1

     TABSCHEMA: SYSCAT
       TABNAME: COLUMNS
   CREATE_TIME: 2021-02-04 16:48:27.962001
      COLCOUNT: 58
INDEX_COLCOUNT: 0
  UNIQUE_INDEX: FALSE
       REMARKS:
```

so to get a list

```sql
select TABSCHEMA, TABNAME from TABLES
```

and format directly as markdown:

```sql
select 
  '| Table Schema | Table Name |' as HEADER 
from SYSIBM.SYSDUMMY1 
union all 
select 
  '|:--------|:--------|' as SEPARATOR 
from SYSIBM.SYSDUMMY1 
union all 
select 
  '| ' || TABSCHEMA || ' | ' || TABNAME || ' |' 
from TABLES 
```

## get list of columns for the `SYSCAT/COLUMNS` table

```sql
select 
  '| Table Name | Column Name | Number of Entries | Datatype | Length |' as HEADER 
from SYSIBM.SYSDUMMY1 
union all 
select 
  '|:--------|:--------|:--------:|:--------:|:--------:|' as SEPARATOR 
from SYSIBM.SYSDUMMY1 
union all 
select 
  '| ' || TABNAME || ' | ' || COLNAME || ' | ' || COLNO || ' | ' || TYPENAME || ' | ' || LENGTH || ' |' 
from COLUMNS 
```
> unfortunately, each line starts with `HEADER:` if the command is issued within the `dsmadmc`, maybe different using the `db2` command ..
