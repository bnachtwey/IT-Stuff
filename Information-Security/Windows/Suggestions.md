# Suggestion to minimize Windows attack vectors

## disble NetBIOS
```powershell
# Disable NetBIOS over TCP/IP for all active network adapters
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=TRUE" |
ForEach-Object {
    $_.SetTcpipNetbios(2)
}

# Verify the change
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=TRUE" |
Select-Object Description, TcpipNetbiosOptions
```
