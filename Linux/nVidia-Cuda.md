# Installing the nVdia / CUDA Driver

## Debian
t.b.d.
## RHEL9
following [this guide](https://forums.rockylinux.org/t/tutorial-for-nvidia-gpu/4234) from the RockyLinux Forum:
```bash
sudo dnf update && sudo dnf upgrade -y
sudo dnf install -y epel-release
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
sudo reboot now
sudo dnf install -y kernel-devel-$(uname -r) kernel-headers-$(uname -r)
sudo dnf install -y nvidia-driver nvidia-settings
sudo dnf install -y cuda-driver
sudo reboot now
```
