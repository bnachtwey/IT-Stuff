# Tapespeed overview

## LTO Speedmatching

LTO drive speed matching native data rates (MB/s / GB/h)

| Generation 10 *)| Generation 9 *) |	Generation 8 | Generation 7 |	Generation 6 | Generation 5 |
| ------------    | ------------    | ------------ | ------------ | ------------ | ------------ |
|   t.b.d.        |  408 / 1468  |  360 / 1296  |  306.00 / 1101.60  |  160.00 / 576.00  |  140.00 / 504.00  |
|                 |  385 / 1386  |  341 / 1228 	|  287.52 / 1035.07  |  150.77 / 542.77  |  130.00 / 468.00  |
|                 |  366 / 1318  |  318 / 1145 	|  268.56 / 966.82 	 |  141.54 / 509.54  |  120.00 / 432.00  |
|                 |  347 / 1249  |  306 / 1103 	|  250.66 / 902.38   |  132.31 / 476.32  |  112.70 / 405.72  |
|                 |  325 / 1170  |  273 / 983 	|  231.86 / 834.70   |  123.08 / 443.09  |  105.50 / 379.80  |
|                 |  305 / 1098  |  249 / 896   |  213.06 / 767.02   |  113.85 / 409.86  |  98.20 / 353.52  |
|                 |  284 / 1022  |  226 / 814   |  194.26 / 699.34   |  104.62 / 376.63  |  90.90 / 327.24  |
|                 |  263 / 947   |  203 / 731   |  175.46 / 631.66   |  95.38 / 343.37   |  83.60 / 300.96  |
|                 |  244 / 878   |  180 / 648   |  157.67 / 567.61   |  86.15 / 310.14   |  76.40 / 275.04  |
|                 |  223 / 803   |  157 / 567   |  138.52 / 498.67   |  76.92 / 276.91   |  69.10 / 248.76  |
|                 |  203 / 731   |  135 / 486   |  120.11 / 432.40   |  67.69 / 243.68   |  61.80 / 222.48  |
|                 |  177 / 637 	 |  112 / 403   |  101.46 / 365.26   |  58.46 / 210.46   |  53.50 / 192.60  |
|                 |              |              |                    |	49.23 / 177.23   |	46.30 / 166.68  |
|                 |              |              |                    |	40.00 / 144.00 	 |  40.00 / 144.00  |

Sources:<br>
- [IBM Redbook: _IBM Tape Library Guide for Open Systems_](https://www.redbooks.ibm.com/redbooks/pdfs/sg245946.pdf), August 2024
  - Table 2-10 for LTO9 FH
  - Table 2-12 for LTO8 FH
  - Table 2-14 for LTO7 FH
  - Table 2-16 for LTO6 FH
- [IBM TS4500 R9 Tape Library Guide](https://www.redbooks.ibm.com/redbooks/pdfs/sg248235.pdf)
- [IBM: Performance specifications for LTO tape drives](https://www.ibm.com/docs/en/ts4500-tape-library?topic=performance-lto-specifications)

*) Speedsteps below 305 mb/s for full hight drives only

# Enterprise Tape (Jaguar) Speedmatching

Jaguar drive speed matching data rates (MB/s) depend on the media and the generation style used (see [1] – [4])

| media / Generation 	      | Jaguar 6 (12 speed steps)  | 	Jaguar 5 (12 speed steps) 	| Jaguar 4 (13 speed steps) | Capacity (native) |
| ------------------------- | -------------------------- | ---------------------------- | ------------------------- | -----------------  |
| JE @ G6 	| up to 400MBps (1600 MBps) |	– |	– |	20 TB |
| JD @ G6 	| up to 400MBps (800 MBps) 	| – | 	– | 	15 TB| 
| JD @ G5.5 |	– | 	up to 360MBps | 	– 	| 15 TB| 
| JD @ G5 	| – | 	112 – 365 MBps | 	– | 	10 TB| 
| JC @ G5 	| – | 	99 – 303 MBps | 	– | 	7 TB| 
| JC @ G4 	| – | 	90 – 252 MBps | 	76 – 251 MBps | 	4 TB| 
| JB @ G4 	| – | 	– 	| 74 – 203 MBps | 	1.6 TB| 
| JB @ G3 	| – | 	– 	| 41 – 163 MBps | 	1 TB| 

Sources:(all vanished in the meanwhile)<br>
- [1] https://www.ibm.com/us-en/marketplace/ts1140/specifications
- [2] https://www.ibm.com/us-en/marketplace/ts1150/specifications
- [3] https://www.ibm.com/us-en/marketplace/ts1155/specifications
- [4] https://www.ibm.com/us-en/marketplace/ts1160/specifications / https://www-01.ibm.com/common/ssi/cgi-bin/ssialias?infotype=an&subtype=ca&appname=gpateam&supplier=899&letternum=ENUSLG18-0135

