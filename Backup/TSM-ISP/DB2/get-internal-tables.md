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
  '| Schema | Table |' as HEADER 
from SYSIBM.SYSDUMMY1 
union all 
select 
  '|--------|--------|' as SEPaRATOR 
from SYSIBM.SYSDUMMY1 
union all 
select 
  '| ' || TABSCHEMA || ' | ' || TABNAME || ' |' 
from TABLES 
```

unfortunately, each line starts with `HEADER:` if the command is issued within the `dsmadmc`, maybe different using the `db2` command ..

## get list of columns for the `SYSCAT` table
