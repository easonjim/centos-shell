#!/bin/bash
#
# 查询所有用户组

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

cat /etc/group |cut -f 1 -d :