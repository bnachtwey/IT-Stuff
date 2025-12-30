# Guide to install OpenVAS

> [!Note]
>
> *OpenVAS* or `gvm` is not part of *Debian / Trixie*, so you have to extend the repo list if not using already *SID* or *Kali*
>
> 1. create repo file for SID:
>
> ```bash
> sudo tee /etc/apt/sources.list.d/SID.list>/dev/null <<'EOF'
> # SID Repo
> deb http://deb.debian.org/debian sid main contrib non-free non-free-firmware
> EOF
> ```
>
> 2. add pinning for default packages
>
> ```bash
> sudo tee /etc/apt/preferences.d/00-default-release >/dev/null <<'EOF'
> Package: *
> Pin: release a=stable
> Pin-Priority: 900
> 
> Package: *
> Pin: release a=unstable
> Pin-Priority: 100
> EOF
> ```

## run apt-get update && apt-get

```bash
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo apt-get -y autoremove
```

## Install *Greenbone Vulnerability Management* and *OpenBC*

```bash
apt-get -y update
apt-get install -y gvm

```

> if using SID as additional repo use
>
> ```bash
> sudo apt-get install -t unstable gvm
> ```

### do basic setup and get `admin` Password

```bash
sudo gvm-setup
```

=> Kali-VM: `dabebf34-92a8-4e98-ad5d-9122a047ae`

### change admin password

```bash
sudo runuser -u _gvm --gvmd --user=admin --newpassword=admin
```
