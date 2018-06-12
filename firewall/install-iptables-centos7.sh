#!/bin/bash
#
# CentOS 7 iptables Install

# 检查是否为root用户，脚本必须在root权限下运行
source common/check-root.sh

# 安装iptables
yum install -y iptables
# 升级iptables
yum update iptables 
# 安装iptables-services
yum install -y iptables-services

# 设置开机启动
systemctl enable iptables

# 启动
systemctl start iptables
