# Disable the Intel “Alder Lake PCH‑P High Definition Audio Controller”** on Linux

## Identify the device (important first step)

On Alder Lake systems the controller is usually:

```bash
lspci -nn | grep -i audio
```

Typical output:

```text
00:1f.3 Multimedia audio controller: Intel Corporation Alder Lake PCH‑P High Definition Audio Controller [8086:51c8]
```

Key facts:

* **PCI address**: `0000:00:1f.3`
* **Vendor:Device ID**: `8086:51c8`
* Driver: `snd_hda_intel` or `snd_sof_pci_intel_*`

## systemd one‑shot service (more reliable than udev)

This is **strongly recommended in enterprise / recovery / appliance setups** because udev timing can be inconsistent.

### Create service

```bash
sudo nano /etc/systemd/system/disable-alderlake-audio.service
```

```ini
[Unit]
Description=Disable Intel Alder Lake PCH-P Audio Controller
After=systemd-udevd.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo 1 > /sys/bus/pci/devices/0000:00:1f.3/remove'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable:

```bash
sudo systemctl daemon-reload
sudo systemctl enable disable-alderlake-audio.service
```

✅ This approach is commonly used when udev rules fail to fire early enough and is known to work for PCI audio devices. [\[unix.stack...change.com\]](https://unix.stackexchange.com/questions/702774/how-to-disable-pcie-device-at-boot)

## ❌ Why **not** driver blacklisting?

Blacklisting **does NOT work cleanly** for Alder Lake PCH‑P audio because:

* `snd_hda_intel` is **shared** with:
  * HDMI audio
  * GPU audio
  * USB‑C DP audio
* Blacklisting breaks unrelated audio devices
* This is confirmed by multiple distro forums. [\[forum.ende...vouros.com\]](https://forum.endeavouros.com/t/how-do-i-disable-this-audio-device/56311)

❌ **Do not do this** unless you fully understand the impact:

```bash
blacklist snd_hda_intel
```
