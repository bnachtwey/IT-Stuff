# Enabeling and disabling Windows Remote Desktop

due to [The Windows Club](https://www.thewindowsclub.com/enable-remote-desktop-using-command-line)

## Enable and open Firewall port
```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
netsh advfirewall firewall set rule group="remote desktop" new enable=yes
```

By default, the value of fDenyTSConnections is set to 1. This command will change the value to 0.<br>
The second command will add and update three rules in the Firewall so that you can start using the Remote Desktop.


## Disable Remote Desktop using Command Prompt

You need to set the default value of fDenyTSConnections as 1. For that, use this command-

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f
```

Now you need to remove rules from the Firewall. For that, use this command-

```cmd
netsh advfirewall firewall set rule group="remote desktop" new enable=No
```
## Disable Remote Desktop using PowerShell

You need to change the value of fDenyTSConnections as 1. You can do that by using this command-

```powershell
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 1
```
The second command will let you remove the rules from the Firewall:
```powershell
Disable-NetFirewallRule -DisplayGroup "Remote Desktop"
```

## ToDo
limit the service to dedicated users 
