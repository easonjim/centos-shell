#!/bin/bash
#
# CentOS 7 iptables Install

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 安装iptables
yum install -y iptables
# 升级iptables
yum update iptables 
# 安装iptables-services
yum install -y iptables-services

# 设置开机不启动
systemctl disable iptables

# 启动
systemctl start iptables
