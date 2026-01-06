# Getting License Keys from running Maschine

## Windows

Many ways to do, buts

- using `regedit.exe` as *Administrator*

  - travel to `Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform`
  - click / view `BackupProductKeyDefault`

- accessing the registry using *powershell*

  ```powershell
  type "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\BackupProductKeyDefault"
  ```

  fails due to

  ```powershell
  type : Cannot find path 'HKLM:\SOFTWARE\Microsoft\WindowscNT\CurrentVersion\SoftwareProtectionPlatform\BackupProductKeyDefault' because it does not exist.
  ```

  ??? It's definitively visible using `regedit.exe` ???

## Linux

- ensure `binutils` is installed

- enter in shell

  ```bash
  sudo strings /sys/firmware/acpi/tables/MSDM
  ```

  it's obviously the last line :-)
