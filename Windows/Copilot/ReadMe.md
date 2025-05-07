# How get rid off

## Suggestion by the scum itself:
If you're looking to disable Copilot across all Microsoft applications, the process varies depending on whether you're an individual user or an IT admin.

For Microsoft 365 apps like Word, Excel, PowerPoint, and OneNote, you can disable Copilot by:
- Opening the app.
- Navigating to File > Options > Copilot.
- Unchecking Enable Copilot.
- Restarting the app
- 
If you're an IT admin, you can disable Copilot for multiple users via:

- Microsoft 365 Admin Center: Go to Settings > Org settings > Microsoft 365 Copilot and turn it off for specific apps or users
- Group Policy or Intune: Create a policy to disable Copilot in Office apps

For other Microsoft applications, the method may differ. You can check Microsoft's official guidance [here](https://answers.microsoft.com/en-us/msoffice/forum/all/i-want-to-turn-copilot-off-in-all-my-microsoft/7b21fe01-2c83-43e5-adb7-1859e255c010)

## Disabling Copilot 
- using Powershell:
  ```ps
  Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*Copilot*" } | ForEach-Object {Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue}
  ```
- using a reg key (no idea if this works as M$ ignores some settings due to *improved user experience*)
  ```cmd
  Windows Registry Editor Version 5.00
  
  [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
  "TurnOffWindowsCopilot"=dword:00000001
  ```
