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
TAGER_ROOT_PASSWD=$3
if [[ ! -n ${TAGER_IP} ]]; then
  echo "请输入远程IP"
  exit 1
fi
if [[ ! -n ${TAGER_PORT} ]]; then
  echo "请输入远程端口"
  exit 1
fi
if [[ ! -n ${TAGER_ROOT_PASSWD} ]]; then
  echo "请输入远程root密码"
  exit 1
fi

# rsync-file-from-server.sh 远程账号 远程路径 远程IP 远程端口 本地路径
# 同步环境
# java
bash ../rsync/rsync-file-from-server.sh root /data/service/java ${TAGER_IP} ${TAGER_PORT} /data/service/java
bash ../rsync/rsync-file-from-server.sh root /etc/profile.d/java.sh ${TAGER_IP} ${TAGER_PORT} /etc/profile.d/
bash ../rsync/rsync-file-from-server.sh root /data/service/maven ${TAGER_IP} ${TAGER_PORT} /data/service/maven
bash ../rsync/rsync-file-from-server.sh root /etc/profile.d/maven.sh ${TAGER_IP} ${TAGER_PORT} /etc/profile.d/
bash ../rsync/rsync-file-from-server.sh root /data/service/tomcat ${TAGER_IP} ${TAGER_PORT} /data/service/tomcat
bash ../rsync/rsync-file-from-server.sh root /etc/init.d/tomcat8 ${TAGER_IP} ${TAGER_PORT} /etc/init.d/
bash ../rsync/rsync-file-from-server.sh root /etc/profile.d/tomcat.sh ${TAGER_IP} ${TAGER_PORT} /etc/profile.d/
# node
bash ../rsync/rsync-file-from-server.sh root /data/service/node ${TAGER_IP} ${TAGER_PORT} /data/service/node
bash ../rsync/rsync-file-from-server.sh root /etc/profile.d/node.sh ${TAGER_IP} ${TAGER_PORT} /etc/profile.d/
# nodejs特殊处理pm2
npm install pm2 -g

# ng
bash ../rsync/rsync-file-from-server.sh root /data/service/nginx ${TAGER_IP} ${TAGER_PORT} /data/service/nginx
bash ../rsync/rsync-file-from-server.sh root /etc/profile.d/nginx.sh ${TAGER_IP} ${TAGER_PORT} /etc/profile.d/
bash ../rsync/rsync-file-from-server.sh root /etc/init.d/nginx ${TAGER_IP} ${TAGER_PORT} /etc/init.d/
# 设置开机启动
chkconfig nginx on
# 启动
service nginx start 
# 设置用户隶属于www-data用户组
usermod -aG www-data nginx

bash ../docker/install-docker_last-centos7.sh