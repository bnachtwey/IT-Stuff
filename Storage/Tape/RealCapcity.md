# Measures on real Capacities

Tapes sales often use amazing numbers for throughput and capacity. In the _real world_ both are are rarely actually achieved.

Bandwith differs with every use case, but _real usable capacity_ is a measurable number:

Using the following SQL statement on IBM SP servers show how much data can _really_ stored on tapes:

```sql
select -
  v.DEVCLASS_NAME, - 
  d.FORMAT, count(*) as NUMBER, - 
  cast((avg(v.EST_CAPACITY_MB)/1048576) as decimal(4,3)) as "AVERAGE (TB)", -
  cast((percentile_cont(0.5) within group (order by v.EST_CAPACITY_MB)/1048576) as decimal(4,3)) as "MEDIAN (TB)" -
from - 
  VOLUMES v, DEVCLASSES d -
where - 
  (v.DEVCLASS_NAME = d.DEVCLASS_NAME) - 
and -
  ( - 
    d.DEVTYPE = 'LTO' - 
  or - 
    d.DEVTYPE = '3592' - 
  ) - 
and - 
  v.STATUS = 'FULL' - 
group by - 
  v.DEVCLASS_NAME, - 
  d.FORMAT
```

same as one-liner

```
select v.DEVCLASS_NAME, d.FORMAT, count(*) as NUMBER, cast((avg(v.EST_CAPACITY_MB)/1048576) as decimal(4,3)) as "AVERAGE (TB)", cast((percentile_cont(0.5) within group (order by v.EST_CAPACITY_MB)/1048576) as decimal(4,3)) as "MEDIAN (TB)" from VOLUMES v, DEVCLASSES d where (v.DEVCLASS_NAME = d.DEVCLASS_NAME) and ( d.DEVTYPE = 'LTO' or d.DEVTYPE = '3592' ) and v.STATUS = 'FULL' group by v.DEVCLASS_NAME, d.FORMAT
```
