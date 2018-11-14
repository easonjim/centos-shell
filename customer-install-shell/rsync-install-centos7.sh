#!/bin/bash
#
# 环境初始化-同步版，CentOS 7
# 注意：需要提前做ssh免密登录
# 从本机同步到目标机

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 定义变量
TAGER_IP=$1
TAGER_PORT=$2
if [[ ! -n ${TAGER_IP} ]]; then
  echo "请输入目标IP"
  exit 1
fi
if [[ ! -n ${TAGER_PORT} ]]; then
  echo "请输入目标端口"
  exit 1
fi

# 下载初始化环境并执行
ssh -o StrictHostKeychecking=no root@${TAGER_IP} -p ${TAGER_PORT} " 
curl https://raw.githubusercontent.com/easonjim/centos-shell/master/init.sh | bash
bash /root/centos-shell/customer-install-shell/install-centos7.sh
"
