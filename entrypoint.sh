#!/usr/bin/env sh

#
# iptables configuration
#
# The following allows in- and outbound traffic
# within a certain `CIDR` (default: `192.168.0.0/24`),
# but blocks all other network traffic.
#
ACCEPT_CIDR=${ALLOWED_CIDR:-192.168.0.0/24}

iptables -A INPUT -s $ACCEPT_CIDR -j ACCEPT
iptables -A INPUT -j DROP
iptables -A OUTPUT -d $ACCEPT_CIDR -j ACCEPT
iptables -A OUTPUT -j DROP

#
# After configuring `iptables` as root, execute
# the passed command as the non-privileged `app` user.
#
sudo -u app sh -c "$@"
