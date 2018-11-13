#!/bin/bash
#
# rsync file for sudo
# example: bash rsync-file.sh 本机账号 本机路径 目标账号 目标路径 目标IP 目标端口

# 解决相对路径问题
cd `dirname $0`

# 定义变量
LOCAL_FILE_PATH=$1
TAGER_ACCOUNT=$2
TAGER_FILE_PATH=$3
TAGER_IP=$4
TAGER_PORT=$5
# 判断变量
if [[ ! -n ${LOCAL_FILE_PATH} ]]; then
  echo "请输入本地路径"
  exit 1
fi
if [[ ! -n ${TAGER_ACCOUNT} ]]; then
  echo "请输入目标账号"
  exit 1
fi
if [[ ! -n ${TAGER_FILE_PATH} ]]; then
  echo "请输入目标路径"
  exit 1
fi
if [[ ! -n ${TAGER_IP} ]]; then
  echo "请输入目标IP"
  exit 1
fi
if [[ ! -n ${TAGER_PORT} ]]; then
  echo "请输入目标端口"
  exit 1
fi

# 执行
rsync -avh --rsync-path="sudo rsync" -e 'ssh -p '${TAGER_PORT} ${LOCAL_FILE_PATH} ${TAGER_ACCOUNT}@${TAGER_IP}:${TAGER_FILE_PATH}