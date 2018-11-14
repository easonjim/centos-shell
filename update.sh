#!/bin/bash
#
# 更新本脚本

# 检查root
if [[ "$(whoami)" != "root" ]]; then
    echo "please run this script as root !" >&2
    exit 1
fi

cd /root/centos-shell && git pull