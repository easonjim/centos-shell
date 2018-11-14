#!/bin/bash
#
# 免密登录，直接复制

# 解决相对路径问题
cd `dirname $0`

# 引入外部文件
source ../common/util.sh

# 检查root
util::check_root

if [[ ! -n $1 ]]; then
  echo "请输入用户名"
  exit 1
fi
if [[ ! -n $2 ]]; then
  echo "请输入IP"
  exit 1
fi
if [[ ! -n $3 ]]; then
  echo "请输入Port"
  exit 1
fi

sudo -u $1 ssh-copy-id $1@$2 -p $3