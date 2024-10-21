# Guide for Deciding the "correct size" of your SP Instance
👷
Due to the *IBM Blueprints V5.1*

## Sizing inputs
IBM does not concider the actual DB2 size for renewing SP hosts, but this is also a valid indicator. The blueprints also do not mention an *extra large* set-up.

You should concider the smallest set-up that fullfill all your boundary conditions.

| total managed data | daily ingest having one replication copy | daily ingest having two replication copies | server size suggested | Actual DB2 Size |
| :----------------: | :--------------------------------------: |  :---------------------------------------: | :-------------------: | :-------------: |
| 10 TB - 40 TB	    | Up to 1 TB  | Up to 0.6 TB | **Extra Small** | < 100 GB        |
| 60 TB - 240 TB    | Up to 10 TB | Up to 6 TB   | **Small** | < 500 GB|
| 360 TB - 1440 TB  |	10 - 30 TB |	6 - 18 TB | **Medium** | < 1 TB | 
| 1 PB – 4 PB |	30 - 100 TB | 18 - 60 TB | **Large** | > 1 TB          |
| > 4 PB | | | **Extra Large** | > 2 TB |

> [!NOTE]
> The *managed data* is not the *managed backend capacity* as small objects / files impact the server performance differently from larger objects. IBM therefore advises to calculate the *managed data size* depending on the frontend capacity and typical change rates:
> - Client types with incremental-forever backup operations<br>
>   Use the following formula to estimate the total managed data:<br>
>   `Frontend + (Frontend * changerate * (retention - 1))`<br>
>   For example, if you back up 100 TB of front-end data, use a 30-day retention period, and have a 5% change rate, calculate your total managed data as shown:
>   `100 TB + (100TB * 0.05 * (30-1)) = 245 TB total managed data`
> - Client types with full daily backup operations<br>
>   Use the following formula to estimate the total managed data:<br>
>   `Frontend * retention * (1 + changerate)`<br>
>   For example, if you back up 10 TB of front-end data, use a 30-day retention period, and have a 3% change rate, calculate your total managed data as shown:<br>
>   `10 TB * 30 * (1 + .03) = 309 TB total managed data`


## System Requirements due to determined server size
| Requirement | **Extra Small** | **Small** | **Medium** | **Large** |
| :---------: | --------------- | --------- | ---------- | --------- |
| CPU-Cores   |

## Remarks on *multiple instance hosts*
