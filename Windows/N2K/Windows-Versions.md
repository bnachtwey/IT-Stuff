# Getting Windows Versions
## using GUI-Tools
start the `winver`, e.g. by typing `<WINDOWS-KEY>`+`<R>` and the `winver`+`<ENTER>`

## using the CLI 
  - Shell:
    - start a shell _as administrator_
    - issue `ver`<br
      ```
      >ver
      
      Microsoft Windows [Version 10.0.22631.4037]
      ```
  - Powershell:
    - issue `[System.Environment]::OSVersion`
      ```
      > [System.Environment]::OSVersion.Version
      
      Major  Minor  Build  Revision
      -----  -----  -----  --------
      10     0      22631  0
      ```
  - you need to look up the `Build` number, as `Major = 10` indicates Windows 10 or 11<br>
    e.g. at [Wikipedia](https://en.wikipedia.org/wiki/List_of_Microsoft_Windows_versions)<br>
    `Build = 22631` stands for `Windows 11 Nickel` aka `Windows 11 23H2`
