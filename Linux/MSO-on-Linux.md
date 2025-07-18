# Running Microsoft Office Apps on Linux

## The most privacy aware approach

Don't use any Microsoft products at all, don't trust the statement, _Microsoft won't process your data or share it with the agencies_.

Use instead

| MS product |                                               Altenative                                               |
| :--------: | :----------------------------------------------------------------------------------------------------: |
| MS Office  | [Libreoffice](www.libreoffice.org), [Softmaker Office](https://softmaker.de/produkte/softmaker-office) |
| MS Outlook |    [Thunderbird](https://www.thunderbird.net/), [Evolution](https://wiki.gnome.org/Apps/Evolution)     |

## The most simple approach: Use the WebApps

Of course, the easiest way is not to install the Apps, but run them as WebbApp in the Azure Cloud. Unfortunately, with this approach, Microsoft get _full control_ on your personal and perhaps also private data -- do so, _if you've nothing not to share with the public..._

## Trying `wine` and `PlayOnLinux`

see <https://thelinuxcode.com/install-microsoft-office-linux/>

Hm, _PlayOnLinux_ sees very outdated ...

## Trying to have some controll: do a local install

As long as there are still _on-prem versions_ of Microsoft Office, you can install them using [wine](https://www.winehq.org/).

## _Codeweaevers' CrossOver_

- not free, cost about 74,- €
- get it [here](https://www.codeweavers.com/crossover)

### Installation _crossover itself_

- get installable binary, e.g. `crossover_24.0.6-1.deb`
- install using the installer, e.g. `dpkg -i crossover_24.0.6-1.deb`
  - having `wine` already installed, no dependecies are missing

Crossover add a new section to the _Xfce_ Menu, offering a selections of Windows applications to install:<br>
![](./.pictures/Crossover-01.png)

### Installation _MS Office_

When installing MS Office, you have to provide an _installation binary_, e.g. `OfficeSetup.exe`:<br>
![](./.pictures/MSOffice-01.png)

- Limitations
  - Office is only compatible with a _Windows 7 32-bit Bottle_
  - Only some languages supported, at least english :-)<br>
  ![](./.pictures/MSOffice-02.png)

- Crossover will also install some dependencies:<br>
  ![](./.pictures/MSOffice-03.png)

- Therefore you must either be `root` do belong to the `sudoers` group:<br>
  ![](./.pictures/Crossover-02.png)<br>
  ![](./.pictures/Crossover-03.png)

- When _nearly_ finished, _CrossOver_ asks for a license :-(<br>
  ![](./.pictures/Crossover-04.png)

- Going on with _TryNow_

- Next the installer asks for some Microsoft Licensese .. <br>
  ![](./.pictures/MSOffice-04.png)<br>
  ![](./.pictures/MSOffice-05.png)<br>
  ![](./.pictures/MSOffice-06.png)

- Then installing Office itself<br>
  ![](./.pictures/MSOffice-07.png)

- Nearly finished, Microsofts tries to persuade to the mobile apps<br>
  ![](./.pictures/MSOffice-08.png)

- Remember, there's a _double opt out_, *Don't you __really_ want these fantastic mobile Apps??_

- Standing brave, you'll get the real _finished_ statement<br>
  ![](./.pictures/MSOffice-09.png)

### Running _Outlook_

- First start _crossover_, then select _Outlook_<br>
  ![](./.pictures/Outlook-01.png)<br>

- Enter your E-Mail address
  ![](./.pictures/Outlook-02.png)

- FAIL<br>
  ![](./.pictures/Outlook-03.png)

=> Maybe Office was a 64Bit Application causing this problems in a _32bit Win7 Bottle_?

**T.B. continued ...**

### Teams

> [!TIP]
> Unfortunately Microsoft stopped shipping a Linux Binary, so the only way to use _MS Teams_ is the webclient :-(

## Trying to have some controll: do a local install

As long as there are still _on-prem versions_ of Microsoft Office, you can install them using [wine](https://www.winehq.org/).

### MS Office

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

 > [!WARNING]
 >
 > does not work :-(

### OneDrive

have a look at <https://abraunegg.github.io/> or <https://github.com/abraunegg/onedrive>
