# Some thoughts on how to identify and monitor all your network devices
## Motivation
Even in my small home network, sometimes the *Quality of Service* seems to *flatter*.

Therefore I'd like to 
1) gather information on all devices connected to my network
2) gather information on the connections
3) gather information on the bandwidth (and may be latency) on each "cable" (including WLAN)

So how to get this?

A first source may be my DSL router, as AVM shows at least the devices and also some actual WLAN quality indicators.

But I don't want to rely on *having a AVM Fritz box*, but looking for a more generic solution, that may work for any set up. 
Furthermore I should also work when I setup the (long time planned) VLANs in my network, therefore having not a *Fritzbox* as my core router.

So again, *how to get this*?

## Free software that might do the job?
Crawling the Internet I found a [comparision](https://www.goodfirms.co/network-mapping-software/blog/best-free-and-open-source-network-mapping-software=
-  Cacti
-  [Open NMS / Horizon](https://www.opennms.com/horizon/)
-  [Networkmaps](https://www.networkmaps.org/)<br>
   looks a little *too fancy*

besides this I also thought of
-  Observium
