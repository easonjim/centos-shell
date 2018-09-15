#!/bin/bash
#
# 免密登录

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
# 切换到用户
su - $1 -s /bin/bash
# 生产ssh密钥
ssh-keygen
# 出现如下信息后一路回车
# Enter file in which to save the key (path-to-id-rsa-in-nginx-home): ...
# 配置权限
touch ~/.ssh/config && echo -e "StrictHostKeyChecking=no\nUserKnownHostsFile=/dev/null" >> ~/.ssh/config
chmod 0600 ~/.ssh/config
sh-copy-id $1@$2