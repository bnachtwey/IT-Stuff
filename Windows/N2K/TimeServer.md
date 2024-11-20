# Windows Timeserver settings
> the commands below must issued in an *administrative cmd*

## getting actual settings
issueing
```
w32tm /query /status
```
gives an output like this (sorry german settings)

```
C:\WINDOWS\system32>w32tm /query /status
Sprungindikator: 0(keine Warnung)
Stratum: 4 (Sekundärreferenz - synchr. über (S)NTP)
Präzision: -23 (119.209ns pro Tick)
Stammverzögerung: 0.0168694s
Stammabweichung: 7.7960610s
Referenz-ID: 0x0D5F41FB (Quell-IP:  13.95.65.251)
Letzte erfolgr. Synchronisierungszeit: 20.09.2024 10:43:13
Quelle: time.windows.com,0x9
Abrufintervall: 10 (1024s)
```

## setting new timeservers

taking `ntp1.t-online.de` as ntpserver issue
```
w32tm /config /manualpeerlist:"ntp1.t-online.de" /syncfromflags:manual /reliable:yes /update
```

if you want to add multiple, just separate them by `,`:

```
C:\WINDOWS\system32>w32tm /config /manualpeerlist:"ptbtime2.ptb.de,ptbtime4.ptb.de" /syncfromflags:manual /reliable:yes /update
```

Now the query gives a different output:

```
C:\WINDOWS\system32>w32tm /query /status
Sprungindikator: 0(keine Warnung)
Stratum: 2 (Sekundärreferenz - synchr. über (S)NTP)
Präzision: -23 (119.209ns pro Tick)
Stammverzögerung: 0.0173337s
Stammabweichung: 7.7618182s
Referenz-ID: 0x7CD8A40E (MD5-Hashbruchteil der IPv6-Adresse: )
Letzte erfolgr. Synchronisierungszeit: 20.09.2024 10:47:48
Quelle: ptbtime2.ptb.de,ptbtime4.ptb.de
Abrufintervall: 10 (1024s)
```
# Windows Timezone settings
## get actual timezone
```
tzutil /g
```
## set new timezone
```
tzutil /s <timezone>
```
e.g. for UTC
```
tzutil /s UTC
```
for CET
```
tzutil /s "Central Europe Standard Time"
```
