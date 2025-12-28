# My notes on vxLAN with Proxmox

> My Setup:
>
> - 3 PVE hosts
> - using Proxmox 9.1.2

## on configuration

- `Peer IP`: IPs of the *proxmox nodes* in the outer / underlaying network
- `MTU`: MTU of *underlaying network* minus 50, so `1450` for ordinary networks without *jumbo frames*

## to consider

- *SNAT* is not working on a PVE cluster as having multiple PVE nodes a unique gateway cannot assigned to these nodes

  - Workaround: define another vm / container with two NIC acting as a gateway / router between vxlan net and underlaying network

    see e.g. [my notes on Trixie as mini router](./../../../Network/Routing/Setup-Trixie-CT-as-MiniRouter.md)
