#!/bin/bash
#
# 设置静态IP

# 引入外部文件
source ../common/util.sh

# 检查root
util::check_root

# 设置变量
INTERFACE=$1
IPADDR=$2
NETMASK=$3
GATEWAY=$4
UUID=`uuidgen`
readonly IP_PATH=/etc/sysconfig/network-scripts/ifcfg-${INTERFACE}

# 校验变量
if [[ ! -n $1 ]]; then
  echo "请输入INTERFACE,e.g. ./set-static-ip.sh INTERFACE IPADDR NETMASK GATEWAY"
  exit 1
fi
if [[ ! -n $2 ]]; then
  echo "请输入IPADDR,e.g. ./set-static-ip.sh INTERFACE IPADDR NETMASK GATEWAY"
  exit 1
fi
if [[ ! -n $3 ]]; then
  echo "请输入NETMASK,e.g. ./set-static-ip.sh INTERFACE IPADDR NETMASK GATEWAY"
  exit 1
fi
if [[ ! -n $4 ]]; then
  echo "请输入GATEWAY,e.g. ./set-static-ip.sh INTERFACE IPADDR NETMASK GATEWAY"
  exit 1
fi

# 备份
cp ${IP_PATH} /tmp/${IP_PATH}

# 修改
cat > ${IP_PATH} << EOF 
TYPE=Ethernet
NAME=${INTERFACE} 
DEVICE=${INTERFACE} 
BOOTPROTO=static 
ONBOOT=yes 
IPADDR=${IPADDR}
NETMASK=${NETMASK}
GATEWAY=${GATEWAY}
UUID=${UUID}
EOF 

# 重启服务
service network restart
 
