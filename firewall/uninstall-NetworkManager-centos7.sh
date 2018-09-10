#!/bin/bash
#
# CentOS 7 NetworkManager Uninstall

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

systemctl stop NetworkManager
systemctl disable NetworkManager
