#!/bin/bash
#
# disable ipv6 for centos7

# 没有添加，有则替换
if [[ `grep -c "^net.ipv6.conf.all.disable_ipv6" /etc/sysctl.conf` = 0 ]]; then
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
else
    sed -i 's/net.ipv6.conf.all.disable_ipv6 = 0/net.ipv6.conf.all.disable_ipv6 = 1/g' /etc/sysctl.conf    
fi

sysctl -p