#!/bin/bash
#
# 增加用户到用户组

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

if [[ ! -n $1 ]]; then
  echo "请输入用户组"
  exit 1
fi
if [[ ! -n $2 ]]; then
  echo "请输入用户名"
  exit 1
fi

usermod -a -G $1 $2