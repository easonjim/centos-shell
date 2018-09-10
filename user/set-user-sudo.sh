#!/bin/bash
#
# 设置用户sudo

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 增加sudo权限
# 检查阐述是否为空
if [[ ! -n $1 ]]; then
  echo "请输入用户名"
  exit 1
fi
usermod -a -G www-data $1