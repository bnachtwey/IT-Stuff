# Dual-Tunnel Wireguard
It's a common approach to split up the traffic using a VPN solution. So internal traffic, accessing servers and services that are running at home or in the company are using the wireguard tunnel while all other goes directly into the internet.

This is very comfy, but in this setting the public network operator can and will get knowledge about all activity.

Therefore some use a kind of *all traffic tunnel* approach, but this directs really all traffic to the VPN server so, you need as well a quite large bandwith and more hardware ressources in the server.

## Basic Idea

Another approach is splitting up the tunnel, but directing the *public traffic* to jumphost server controlled by yourself. Such jumphost may run in a DMZ or somewhere in the cloud (depending on whom you trust). This at least allows to discover or pseudomise the DNS requests.

## Pitfalls