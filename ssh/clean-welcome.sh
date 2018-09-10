#!/bin/bash
# 清楚登录ssh时的还原信息

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 备份文件，并重新新建文件
cp /etc/motd{,.bak} & echo "" > /etc/motd
cp /etc/issue{,.bak} & echo "" > /etc/issue