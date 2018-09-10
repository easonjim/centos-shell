#!/bin/bash
#
# 设置DNS

# 引入外部文件
source ../common/util.sh

# 检查root
util::check_root

# 设置变量
DNS1=$1
DNS2=$2

# 检查是否为空
if [[ ! -n $1 ]]; then
  echo "请输入DNS1,e.g. ./set-dns.sh dns1 dns2"
  exit 1
fi
if [[ ! -n $2 ]]; then
  echo "请输入DNS2,e.g. ./set-dns.sh dns1 dns2"
  exit 1
fi

# 设置
echo "" > /etc/resolv.conf     
echo "nameserver $DNS1" > /etc/resolv.conf
echo "nameserver $DNS2" >> /etc/resolv.conf
ping -c 3 www.baidu.com &> /dev/null || echo "请检查网络连接,此脚本需要访问外网"