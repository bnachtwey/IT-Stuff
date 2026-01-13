#! /bin/bash

# check for needed input values, no review for meaningfulness of input values!

IFACE=$1            # interface to check,   e.g. "tun0"
TNW=$2              # target network,       e.g. "10.0.0.0/8"
TDM=$3              # target domain,        e.g. "mine.localhost"
TDNS=$4             # DNS server to use for target network / interface
                    #                       e.g. "10.0.0.2"

# check for NIC itself 
IPL=$(ip l | grep ${IFACE} )
if [[ ! ${IPL} ]]
then
    echo "no VPN interface 'tun0' defined. EXIT!"
    exit 1;
else
    echo "${IPL}"
fi

# check routing
IPR=$(ip r | grep ${TNW} | grep ${IFACE})
if [[ ! ${IPR} ]]
then
    echo "no routing for interface 'tun0' defined. EXIT!"
    exit 2;
else 
    echo ${IPR}
fi

# check DNS setting
RCTT=$(resolvectl dns ${IFACE} | grep ${TDNS})
if [[ ! ${RCTT} ]]
then
    echo no specific dns set ... adding 
    (
        set -x
        resolvectl dns      "${IFACE}" ${TDNS}      # add DNS to NIC
        resolvectl domain   "${IFACE}" ~${TDM}      # limit DNS to specfic domain
    )
    exit 0;
else
    echo "DNS already set"
    exit 0;
fi