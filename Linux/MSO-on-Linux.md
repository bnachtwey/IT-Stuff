# Running Microsoft Office Apps on Linux
## The most privacy aware approach
Don't use any Microsoft products at all, don't trust the statement, _Microsoft won't process your data or share it with the agencies_.

Use instead
 
| MS product |                                               Altenative                                               |
| :--------: | :----------------------------------------------------------------------------------------------------: |
| MS Office  | [Libreoffice](www.libreoffice.org), [Softmaker Office](https://softmaker.de/produkte/softmaker-office) |
| MS Outlook |    [Thunderbird](https://www.thunderbird.net/), [Evolution](https://wiki.gnome.org/Apps/Evolution)     |
 
## The most simple approach: Use the WebApps
Of course, the easiest way is not to install the Apps, but run them as WebbApp in the Azure Cloud. Unfortunately, with this approach, Microsoft get *full control* on your personal and perhaps also private data -- do so, _if you've nothing not to share with the public..._ 

## Trying to have some controll: do a local install
As long as there are still _on-prem versions_ of Microsoft Office, you can install them using [wine](https://www.winehq.org/).

### MS Office

T.B.D.

### Teams

> [!TIP]
> Unfortunately Microsoft stopped shipping a Linux Binary, so the only way to use *MS Teams* is the webclient :-(

#### Teams 4 Debian11

Old Approach due to `https://linux.how2shout.com/2-ways-to-install-microsoft-teams-on-debian-11-bullseye/`

##### Import MS Teams GPG key

To ensure the packages we get from the official repository of Teams are from the official source without any alteration, the system needs the GPG key signed by the application developers.

```bash
sudo apt install curl -y
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/ms-teams.gpg > /dev/null
```

##### Add Microsoft Teams repository in Debian 11

After adding the GPG key, also add the Microsoft Teams package source repo because it is not available via the default system repository.

```bash
echo 'deb [signed-by=/usr/share/keyrings/ms-teams.gpg] https://packages.microsoft.com/repos/ms-teams stable main' | sudo tee /etc/apt/sources.list.d/ms-teams.list
sudo apt update -y
```

##### Install Microsoft Teams Debian 11 Bullseye

So, far we have successfully set the source to download the MS Teams packages using the default APT package manager, now we can easily use it to install the same.

```bash
sudo apt install teams -y
```

### OneDrive

have a look at https://abraunegg.github.io/ or https://github.com/abraunegg/onedrive
