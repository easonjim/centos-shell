#!/bin/bash
#
# disable ipv6 for centos6

echo "options ipv6 disable=1" >> /etc/modprobe.d/ipv6.conf

chkconfig ip6tables off

