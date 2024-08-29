Monitoring a _Itron ACE3000 Typ 260_ with a _Hichi IR_ Head using MQTT and HomeAssistant

> The main purpose of these instructions is to document my own configuration.

Well, there are already many guides in the web like

* by [Simon42](https://community.simon42.com/t/itron-ace3000-typ-260-mit-tasmota-auslesen/13610)

but all these do not contain a step-by-step schedule I need, when dealing with it once a year or less often :-(

So, how to do?

1. Buy a IR Head
2. Flash / update the ESP8266 
    * you do need a binary with scripting enabled!
    * the "regular images provided by (Theo Arends)[https://github.com/arendst/Tasmota/releases] do not include scripting.
    * espically the _1M_ controllers have to less space to update the image, you need to do the upgrade in two steps
      * update to the _minimal version_ of the next release, <br>
      replace `http://ota.tasmota.com/tasmota/release/tasmota.bin.gz` <br> with `http://ota.tasmota.com/tasmota/release/tasmota-minimal.bin.gz` in the upgrade GUI <br> **BUT** in many cases the upgrade fails back to the minimal release if the space is not sufficient.
      * update to the next full image
    * replace in the second update step the _regular image_ with one _including scripting_, e.g. provides by [Ottelo](https://ottelo.jimdofree.com/stromz%C3%A4hler-auslesen-tasmota/#Downloads)
3. After restarting the IR head, connect to it using it's IP and add a script using the `Tools`-Button and the `Edit Script`:
    * for reading data from the `ITRON ACE3000 Typ 260` it may look like:
      ```
      >D
      >B
      ->sensor53 r
      >M 1
      +1,3,o,16,300,PVE,1,100,2F3F210D0A,063035310D0A
      1,1.8.0(@1,PVE,KWh,Total_inZ1,1
      1,C.1(@1,ZählerNr,,Meter_number,0
      #
      ```
    * Detailed Explanation:
      * `>D` is needed for all scripts, indicating the start
      * `>B` T.D.B.
      * `->sensor52 r` the IR-module is named `sensor52`, the `r` enables this sensor to read data
      * `M 1` T.D.B.
      * `+1,3,o,16,300,PVE,1,100,2F3F210D0A,063035310D0A`
        * `+1` TBD
        * `3` TBD
        * `o` TBD
        * `16` TBD
        * `300` read interval in seconds, range must be within 10 .. 300 
        * `PVE` Name of senser (neede in HA)
        * `1` TBD
        * `100` TBD
        * `2F3F210D0A` TBD
        * `063035310D0A` TBD
      * `1,1.8.0(@1,PVE,KWh,Total_inZ1,1`
        * `1` number of sensor if multiple heads are connected ??
        * `1.8.0(@1` value to read: `1.8.0` revers to first counter in powermeter
        * `PVE` name to be displayed
        * `KWh` unit to be displayed
        * `Total_inZ1` entity name for HA
        * `1` number of fractional digits
      * `1,C.1(@1,ZählerNr,,Meter_number,0`
        * `1` number of sensor if multiple heads are connected ??
        * `C.1(@1` value to read: `C.1` revers to ID of powermeter
        * `ZählerNr`name to be displayed
        * `Meter_number` value to be didplayed
        * `0` TBD
    * second script for reading data from the `ITRON ACE3000 Typ 260` if used for 2-way meter (power purchase and reingest) with reading a second counter (`2.8.0(@1`)
      ```
      >D
      >B
      ->sensor53 r
      >M 1
      +1,3,o,16,300,PVE,1,100,2F3F210D0A,063035310D0A
      1,1.8.0(@1,TotalIn,kWh,Total_inZ1,2
      1,2.8.0(@1,TotalEx,kWh,Total_exZ1,2
      #
      ```