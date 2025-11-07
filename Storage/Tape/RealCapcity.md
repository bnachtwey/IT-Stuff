# Measures on real Capacities

Tapes sales often use amazing numbers for throughput and capacity. In the _real world_ both are are rarely actually achieved.

Bandwith differs with every use case, but _real usable capacity_ is a measurable number:

## Measuring using SQL

Using the following SQL statement on IBM SP servers show how much data can _really_ stored on tapes:

```sql
select -
  v.DEVCLASS_NAME, - 
  d.FORMAT, count(*) as NUMBER, - 
  cast((avg(v.EST_CAPACITY_MB)/1048576) as decimal(10,3)) as "AVERAGE (TB)", -
  cast((percentile_cont(0.5) within group (order by v.EST_CAPACITY_MB)/1048576) as decimal(10,3)) as "MEDIAN (TB)" -
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
select v.DEVCLASS_NAME, d.FORMAT, count(*) as NUMBER, cast((avg(v.EST_CAPACITY_MB) / 1048576) as decimal(10,3)) as "AVERAGE (TB)", cast((percentile_cont(0.5) within group (order by v.EST_CAPACITY_MB) / 1048576) as decimal(10,3)) as "MEDIAN (TB)" from VOLUMES v, DEVCLASSES d where (v.DEVCLASS_NAME = d.DEVCLASS_NAME) and ( d.DEVTYPE = 'LTO' or d.DEVTYPE = '3592' ) and v.STATUS = 'FULL' group by v.DEVCLASS_NAME, d.FORMAT
```
## "real" LTO capacity measures

The values given are derived from a given number of tapes marked as full inside TSM
|  Generation         |  LTO-10 | LTO-9   |  LTO-8  |   M8    |  LTO-7  |  LTO-6	 |  LTO-5  |
| ------------------- | :-----: | :-----: | :-----: | :-----: | :-----: | :------: | :-----: |
|  Minimum            | 	 —   |   —     |  10.91  |   —   |  2.44  |    1.17  |  0.97   |
|  Maximum            | 	 — 	 |   —     |  38.55  |   —   |  47.05 	|   10.73  |  5.18   |
|  Average            | 	 —   |  22.48	 |  13.18  |  10.31  |   6.73 	|   2.93 	 |  1.71   |
|  Median _*)_        | 	 — 	 |  _21.45_ |  _12.48_ |  9.85  |  _6.19_ |  2.83 	 |  1.60   |
||||
|  native             |  30.00  |  18.00   | 	12.00  | 	9.00  |  6.00   | 	 	2.50  | 	 	1.50  |
|  compressed 	      |  75.00  |  45.00   | 	30.00  | 	 —    |  15.00  | 		6.25  | 	 	3.00  |
||||			
|  Number of Tapes 	  |  --     |  1024    |  3025  |	 594  | 3985   |	 4051   |	 659      |

*) Average of multiple median values

> **THANKS to all the members of the so called _TSM-JF_*) (a non-official TSM usergroup hosted by University of Marburg and me, mainly attending academic) who shared their data with me** 👍
>
> *) The _TSM-JF_ is a (non-official) TSM usergroup hosted by University of Marburg and me, mainly attending academic users, IBM partners and guys from the [GSE SSMSD](https://www.gse.org/german-workinggroups/ssmsd-system-managed-storage/)

**I do invite anyone to share her/his measures with me to extend this knowledge base.**
