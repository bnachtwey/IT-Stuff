# Notes on Sandboxing
*Sandboxes* allow to run application separated from the actual operation system, so using a sandbox does not change any current settings and allow to test software with minimum impact on your environment.

> [!IMPORTANT]
> *Sandboxes* only separate, they do not protect your environment from any harm coming out of the sandbox.
>
> So do not use sandboxes for testing / analysis of potential harmful software like inspection of virus infected files! (Although the firejail teams says something different -- better be paranoid ;-) )

## Approaches for Sandboxes
### Windows Sandbox
The *Windows Sandbox* is a feature introdueced with late versions of Windows 10 and Windows 11. As it's an *optional feature*, you cannot install it, but enable this feature.
See [Officical Microsoft Installation Guide](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-install)

Windows sandboxes are not persistant, although you're allowed to restart the sandbox (e.g. because the software installations requires a restart), all settings and software vanishes once you stop the sandbox (or reboot your windows)

### Sandboxie-Plus for Windows
[Sandboxie-Plus](https://sandboxie-plus.com/) is an Windows Software having many additional features compared with *Windows Sandbox*, see [feature comparision list](https://sandboxie-plus.com/feature-comparison/) -- Well, I think the windows sandbox has none of the list ..

Please concider the license terms, although *Sandboxie* is [hosted on GitHub](https://github.com/sandboxie-plus/Sandboxie/releases), it's only free for personal use!

### Firejail
*[Firejail](https://github.com/netblue30/firejail)  is a lightweight security tool intended to protect a Linux system by setting up a restricted environment for running (potentially untrusted) applications.*
  - [Introduction to Firejail](https://firejail.wordpress.com/) 
  - Installation Guides including videos are available on the project landing page.
  - [Overview on Versions deployed with several linux distros](https://repology.org/project/firejail/versions), or RedHat and Derivates, it's part of the EPEL-Repo.

### t.b.d.
