# Notes on the Dokiwiki Container
## Installation
There a simple approach by using the predefined *turnkey-dokueiki* container, e.g. `debian-12-turnkey-dokuwiki_18.0-1_amd64.tar.gz`

Just roll it out and everything is fine :-)
## Upgrade
Doing the upgrade is well [documented](https://www.dokuwiki.org/install:upgrade) -- but, unfortunately contains an error:

The 4th step gives a command to *untar* the new versions tarball, doing so you do not only untar, but also overwrite the owner and security settings with that ones the developer used. Therefore your local wiki copy may not run.

The workaroung is quite simple: just skip the *preserving the owner settings*:
```bash
tar zxvf dokuwiki-xxxx-xx-xx.tgz
cp -rv dokuwiki-xxxx-xx-xx/* /path/to/dokuwiki/
```

