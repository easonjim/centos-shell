#!/bin/bash
#
# 免密登录

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

# 以某个身份执行命令
# 生产ssh密钥
su - $1 -c "ssh-keygen"
# 出现如下信息后一路回车
# Enter file in which to save the key (path-to-id-rsa-in-nginx-home): ...
# 配置权限
su - $1 -c "touch ~/.ssh/config && echo -e \"StrictHostKeyChecking=no\nUserKnownHostsFile=/dev/null\" >> ~/.ssh/config"
su - $1 -c "chmod 0600 ~/.ssh/config"
sudo -u $1 ssh-copy-id $1@$2 -p $3