#!/bin/bash
#
# rsync file
# example: bash rsync-file-from-server.sh 远程账号 远程路径 远程IP 远程端口 本地路径
# 同步服务器文件到本地

# 解决相对路径问题
cd `dirname $0`

# 定义变量
SERVER_ACCOUNT=$1
SERVER_FILE_PATH=$2
SERVER_IP=$3
SERVER_PORT=$4
LOCAL_FILE_PATH=$5
# 判断变量
if [[ ! -n ${SERVER_ACCOUNT} ]]; then
  echo "请输入远程账号"
  exit 1
fi
if [[ ! -n ${SERVER_FILE_PATH} ]]; then
  echo "请输入远程路径"
  exit 1
fi
if [[ ! -n ${SERVER_IP} ]]; then
  echo "请输入远程IP"
  exit 1
fi
if [[ ! -n ${SERVER_PORT} ]]; then
  echo "请输入远程端口"
  exit 1
fi
if [[ ! -n ${LOCAL_FILE_PATH} ]]; then
  echo "请输入本地路径"
  exit 1
fi

# 执行
rsync -avh -e 'ssh -p '${SERVER_PORT} ${SERVER_ACCOUNT}@${SERVER_IP}:${SERVER_FILE_PATH} ${LOCAL_FILE_PATH} 