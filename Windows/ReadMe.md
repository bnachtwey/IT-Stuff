# ReadMe for Windows Remarks

- [Rant on the disadvantages of Bitlocker for Windows11 Home and the force-4-microsoft-online-accounts -- and how to disable it](https://www.heise.de/forum/heise-online/Kommentare/Nicht-verhandelbar-Microsoft-beharrt-auf-TPM-2-0-Pflicht-fuer-Windows-11/Re-Man-braucht-kein-TPM-fuer-BitLocker/posting-44689311/show/):<br>
  *Microsoft's Default "TPM ohne PIN" war dagegen schon immer völlig sinnfrei. Jetzt auch noch alle Bitlocker Schlüssel zu Microsoft zwangshochzuladen pervertiert jegliche Sicherheit durch Bitlocker aber endgültig und vollständig.*<br>
  *Wer sich bei der Installation wohl oder übel schon bei Microsoft Online zwangsanmelden musste ohne das überhaupt zu wollen kann sein Onlinekonto zumindest jederzeit auch nachträglich wieder in ein Offlinekonto zurückverwandeln:*<br>
   https://www.thewindowsclub.com/change-microsoft-account-to-local-account-windows-10

- As *Defined Working Hours* are completely ignored when Windows (especially Win11) wants to *reboot NOW!!*, I tried another approach: Adding a special key to the registry. Let's hope Microsoft considers this.<br>
  For convenience issues I also put the content in a `.reg` [file](./files/DisableAutoReboot.reg)
---

- Alternative to the Windows GUI
  - [Cairo Shell](https://cairoshell.com/) : https://github.com/cairoshell/cairoshell/releases
- [List of Windows Shortcuts](https://virot.eu/shortcuts-to-microsoft-management-consoles-control-panel-snap-ins/)
  - The ServerManager may be different: `%windir%\system32\ServerManager.exe`
