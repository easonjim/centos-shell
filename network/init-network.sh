#!/bin/bash
#
# init network

# 关闭IPV6
if [[ `rpm -q centos-release|cut -d- -f3` = 6 ]]
    then
        bash disable-ipv6_centos6.sh
    else
        bash disable-ipv6_centos7.sh
fi

# 设置DNS
bash set-dns.sh 223.5.5.5 223.6.6.6

# 设置IP
bash set-static-ip.sh "eth0" "192.168.1.2" "255.255.255.0" "192.168.1.1" 