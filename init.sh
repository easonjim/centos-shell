#!/bin/bash
#
# init 使用curl获取脚本

# 引入外部文件
source common/util.sh

# 检查root
util::check_root

yum install -y git wget
git clone https://github.com/easonjim/centos-shell /root/centos-shell