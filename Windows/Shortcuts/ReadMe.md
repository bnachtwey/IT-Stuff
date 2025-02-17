# Windows shortcuts are very helpful and the alternative to "many clicks, but still not there"

- [List of Windows Shortcuts](https://virot.eu/shortcuts-to-microsoft-management-consoles-control-panel-snap-ins/)
  - The ServerManager is different: `%windir%\system32\ServerManager.exe`

- Creating own new links
  - Basic command:<br>
    ```cmd
    mklink <Link-Name> <original / full path to target>
    ```
  - figure out the full path:<br>
    ```cmd
    where <command
    ```
  - example for Disk Management
    ```cmd
    C:\> where diskmgmt.msc
    C:\Windows\System32\diskmgmt.msc

    C:\> mklink "C:\Users\Public\Desktop\DiskManagement" "C:\Windows\System32\diskmgmt.msc"
    ```
- Limitations / Does not work
  - Link for Windows-Update as `ms-settings:windows-update` has no location in the filesystem
