#!/bin/bash
#
# 免密登录，直接复制

# 解决相对路径问题
cd `dirname $0`

# 引入外部文件
source ../common/util.sh

# 检查root
util::check_root

# 设置指定用户免密登录
if [[ ! -n $1 ]]; then
  echo "请输入用户名"
  exit 1
fi
# 设置指定用户免密登录
if [[ ! -n $2 ]]; then
  echo "请输入IP"
  exit 1
fi

sudo -u $1 sh-copy-id $1@$2