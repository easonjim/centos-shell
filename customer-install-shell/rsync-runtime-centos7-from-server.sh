#!/bin/bash
#
# 应用运行环境-同步版，CentOS 7
# 同步服务器环境到本地

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 定义变量
TAGER_IP=$1
TAGER_PORT=$2
if [[ ! -n ${TAGER_IP} ]]; then
  echo "请输入远程IP"
  exit 1
fi
if [[ ! -n ${TAGER_PORT} ]]; then
  echo "请输入远程端口"
  exit 1
fi

# rsync-file-from-server.sh 远程账号 远程路径 远程IP 远程端口 本地路径
# 同步环境
bash ../rsync/rsync-file-from-server.sh root /data/service/ ${TAGER_IP} ${TAGER_PORT} /data/service/
bash ../rsync/rsync-file-from-server.sh root /etc/init.d/ ${TAGER_IP} ${TAGER_PORT} /etc/init.d/
bash ../rsync/rsync-file-from-server.sh root /etc/profile.d/ ${TAGER_IP} ${TAGER_PORT} /etc/profile.d/
# 特殊处理
# ng
source /etc/profile
# 设置开机启动
chkconfig nginx on
# 添加用户
useradd nginx
# 设置用户隶属于www-data用户组
usermod -aG www-data nginx
# 启动
service nginx start 
# tomcat
# 设置开机启动
chkconfig --add tomcat8
# docker
bash ../docker/install-docker_last-centos7.sh