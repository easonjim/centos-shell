#!/bin/bash
#
# 应用运行环境-同步版，CentOS 7
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
TAGER_ROOT_PASSWD=$3
if [[ ! -n ${TAGER_IP} ]]; then
  echo "请输入目标IP"
  exit 1
fi
if [[ ! -n ${TAGER_PORT} ]]; then
  echo "请输入目标端口"
  exit 1
fi

# 同步环境
bash ../rsync/rsync-file.sh /data/service/ root /data/service/ ${TAGER_IP} ${TAGER_PORT}
bash ../rsync/rsync-file-sudo.sh /etc/profile.d/ root /etc/profile.d/ ${TAGER_IP} ${TAGER_PORT}
bash ../rsync/rsync-file-sudo.sh /etc/init.d/ root /etc/init.d/ ${TAGER_IP} ${TAGER_PORT}
# 特殊处理
# nodejs特殊处理pm2
ssh -o StrictHostKeychecking=no root@${TAGER_IP} -p ${TAGER_PORT} "
source /etc/profile
npm install pm2 -g
"
# ng
ssh -o StrictHostKeychecking=no root@${TAGER_IP} -p ${TAGER_PORT} "
# 设置开机启动
chkconfig nginx on

# 设置用户隶属于www-data用户组
usermod -aG www-data nginx

# 启动
service nginx start 
"
# docker
ssh -o StrictHostKeychecking=no root@${TAGER_IP} -p ${TAGER_PORT} " bash /root/centos-shell/docker/install-docker_last-centos7.sh "