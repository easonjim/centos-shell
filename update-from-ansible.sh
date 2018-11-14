#!/bin/bash
#
# 使用ansible更新本脚本，用于批量更新集群环境
# 前提需要安装ansible

# 检查root
if [[ "$(whoami)" != "root" ]]; then
    echo "please run this script as root !" >&2
    exit 1
fi

# 定义变量
GROUP=$1

[ -z $1 ] && GROUP=all

ansible ${GROUP} -m shell -a "cd /root/centos-shell && git pull"