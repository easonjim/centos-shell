#!/bin/bash
#
# init 使用curl获取脚本，纯shell，不引用外部文件

# 检查root
if [[ "$(whoami)" != "root" ]]; then
    echo "please run this script as root !" >&2
    exit 1
fi

yum install -y git wget
git clone https://github.com/easonjim/centos-shell /root/centos-shell