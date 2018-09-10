#!/bin/bash
# 
# CentOS 7 init Firewall
# 彻底干掉firewall，用回iptables

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 设置
bash disable-firewall-centos7.sh
bash uninstall-NetworkManager-centos7.sh
bash install-iptables-centos7.sh
# 关闭iptables
bash disable-iptables.sh