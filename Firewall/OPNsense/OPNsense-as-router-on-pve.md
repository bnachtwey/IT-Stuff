# Running a OPNsense as virtual router on PVE
👷
This approach should also work for other setups besides *Proxmox Virtual Environment*
## Motivation / Assumtion
- your OPNsense vm should act as a *filtering router* between your _computing center network (CCN)_ and local networks defined _inside your PVE only_ (otherwise there's no need to do the routing and filtering _inside the PVE_, isn't it?)

## Limitations / Pitfalls
- running OPNsense *as designed*, your computing centre network (CCN) is on the WAN side of the OPNsense. Therefore you cannot access it from anywhere outside your PVE :-(<br>
  Workaround:
  - set up a port forwarding *on* your PVE host, so that the ssh and http ports are accessible
    - prerouting rule that forwards Port `<host>:<hostport` to `<vm>:<clientport`:
      ```
      iptables -t nat -A PREROUTING -p tcp --dport <hostport> -j DNAT --to-destination <vm-IP on internal VLAN>:<clientport>
      ```
    - postrouting rule that maps all returing packages:
      ```
      iptables -t nat -A POSTROUTING -p tcp --sport <clientport> -j SNAT --to-source <host-IP on public VLAN>:<hostport>
      ```
    - example for ssh on a vm "995" with internal ip `172.16.0.1` and host `10.3.1.120`, accessable on hostport `22995`:
      ```
      iptables -t nat -A PREROUTING  -p tcp --dport 22995 -j DNAT --to-destination 172.16.0.1:22
      iptables -t nat -A POSTROUTING -p tcp --sport 22    -j SNAT --to-source      10.3.1.120:22995
      ```
