# Collecting Tips and Tricks to recreate the UserExperiance

## Skip direct data sharing with MS and the *Three-Letter-Agencies*
Unfortunately you cannot do this setting for all *MicrosoftOffice* application although they are called *suite* and also imply it's *all just one*.

> [!IMPORTANT]
> - **So you have to deactivate the sharing for each single MSO application individually and manually.**
> - **Do expect with every update, your settings are wiped, so either check it after each update or create an "automated task", that runs registry key update periodically**

### RegKeys 
This example is for Word, Excel, PowerPoint and OneNote 2016/2019/365 (Office version 16.0). If you use a different Office version, adjust the 16.0 in the path accordingly (e.g., 15.0 for Office 2013, 14.0 for Office 2010).

```
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Word\Options]
"DOC-PATH"="D:\\Documents"

[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Excel\Options]
"DOC-PATH"="D:\home\nachtwey\Documents"

[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\PowerPoint\Options]
"DOC-PATH"="D:\home\nachtwey\Documents"

[HKEY_CURRENT_USER\Software\Policies\Microsoft\office\16.0\onenote\options\paths]
"backupfolderpath"="D:\\Documents"

[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\General]
"PreferCloudSaveLocations"=dword:00000000
```

Of course, MSO application do use different keys to set the default path 🤡
