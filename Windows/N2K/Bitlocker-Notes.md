# Notes on Bitlocker
## Using Bitlocker from the commandline
🚧 I first wrote this text in german, so translation to english will follow 🚧
The following approach was tested with
  * Windows 10 Pro / 22H2
  * Windows 11 Pro / 23H2

> [!TIP]
> **All commands must be issued using a *commandline runas Administrator*!**

**Step-by-Step guide**
* Check if bitlocker is already running:<br>
  `manage-bde -status`<br>
   ```
   C:\Windows\system32>manage-bde -status
   BitLocker-Laufwerkverschlüsselung: Konfigurationstool, Version 10.0.19041
   Copyright (C) 2013 Microsoft Corporation. Alle Rechte vorbehalten.

   Datenträgervolumes, die mit BitLocker-Laufwerkverschlüsselung
   geschützt werden können:
   Volume "C:" []
   [Betriebssystemvolume]

     Größe:                        49,36 GB
     BitLocker-Version:            Kein
     Konvertierungsstatus:         Vollständig entschlüsselt
     Verschlüsselt (Prozent):      0,0 %
     Verschlüsselungsmethode:      Kein
     Schutzstatus:                 Der Schutz ist deaktiviert.
     Sperrungsstatus:              Entsperrt
     ID-Feld:                      Kein
     Schlüsselschutzvorrichtungen: Keine gefunden
   ```
* _TDB:_ (if not) activate Bitlocker
  * Either using the graphical UI tool by clicking on the concidered drive in the `explorer` and then chose `Bitlocker`

  * or using the command line to enable bitlocker on a specific drive:<br>
    `manage-bde -on <DRIVE>`<br>
    e.g.
    ```
    C:\Windows\system32>manage-bde.exe -on c:
    BitLocker-Laufwerkverschlüsselung: Konfigurationstool, Version 10.0.19041
    Copyright (C) 2013 Microsoft Corporation. Alle Rechte vorbehalten.
    
    Volume "C:" []
    [Betriebssystemvolume]
    Hinzugefügte Schlüsselschutzvorrichtungen:
    
        TPM:
          ID: {53465F4B-98AB-45E2-823D-1F93C0911081}
          PCR-Validierungsprofil:
            0, 2, 4, 11
    
    ERFORDERLICHE AKTIONEN:
    
        1. Starten Sie den Computer neu, um einen Hardwaretest auszuführen.
        (Geben Sie "shutdown /?" ein, ein, um Befehlszeilenanweisungen anzuzeigen.)
    
        2. Geben Sie "manage-bde -status" ein, um zu überprüfen, ob der
        Hardwaretest erfolgreich abgeschlossen wurde.
    
    HINWEIS: Der Verschlüsselungsvorgang beginnt nach erfolgreichem Abschluss
             des Hardwaretests.
    ```  
    ... but first to a `reboot` to start a hardware check, then you can monitor the progress by <br>
    ```
    C:\Windows\system32>manage-bde.exe -status
    BitLocker-Laufwerkverschlüsselung: Konfigurationstool, Version 10.0.19041
    Copyright (C) 2013 Microsoft Corporation. Alle Rechte vorbehalten.
    
    Datenträgervolumes, die mit BitLocker-Laufwerkverschlüsselung
    geschützt werden können:
    Volume "C:" []
    [Betriebssystemvolume]
    
        Größe:                        49,36 GB
        BitLocker-Version:            2.0
        Konvertierungsstatus:         Verschlüsselung wird durchgeführt
        Verschlüsselt (Prozent):      3,5 %
        Verschlüsselungsmethode:      XTS-AES 128
        Schutzstatus:                 Der Schutz ist deaktiviert.
        Sperrungsstatus:              Entsperrt
        ID-Feld:                      Unbekannt
        Schlüsselschutzvorrichtungen:
            TPM
    ```
    wait until the encryption has finished:<br>
    ```
    C:\Windows\system32>manage-bde.exe -status
    BitLocker-Laufwerkverschlüsselung: Konfigurationstool, Version 10.0.19041
    Copyright (C) 2013 Microsoft Corporation. Alle Rechte vorbehalten.
    
    Datenträgervolumes, die mit BitLocker-Laufwerkverschlüsselung
    geschützt werden können:
    Volume "C:" []
    [Betriebssystemvolume]
    
        Größe:                        49,36 GB
        BitLocker-Version:            2.0
        Konvertierungsstatus:         Verschlüsselung wird durchgeführt
        Verschlüsselt (Prozent):      100,0 %
        Verschlüsselungsmethode:      XTS-AES 128
        Schutzstatus:                 Der Schutz ist aktiviert.
        Sperrungsstatus:              Entsperrt
        ID-Feld:                      Unbekannt
        Schlüsselschutzvorrichtungen:
            TPM
    ```
* check / get Bitlocker key by:<br>
  `manage-bde -protectors -get C:`
  e.g. for the example above it looks like
  ```
  Copyright (C) 2013 Microsoft Corporation. Alle Rechte vorbehalten.
  
  Volume "C:" []
  Alle Schlüsselschutzvorrichtungen
  
      TPM:
        ID: {53465F4B-98AB-45E2-823D-1F93C0911081}
        PCR-Validierungsprofil:
          0, 2, 4, 11
  ```  
* get Bitlocker key and pipe into a file:<br>
  `manage-bde -protectors -get C: > bitlocker_c.txt`
  
> [!TIP]
> The key (in the example: `53465F4B-98AB-45E2-823D-1F93C0911081`) was already shown during the encryption.
