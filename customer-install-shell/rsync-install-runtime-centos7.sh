#!/bin/bash
#
# 应用运行环境-同步版，CentOS 7
# 注意：需要提前做ssh免密登录，并且使用www-data账号进行同步
# 从本机同步到目标机
# 依赖sshpass

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
if [[ ! -n ${TAGER_ROOT_PASSWD} ]]; then
  echo "请输入目标root密码"
  exit 1
fi

# 同步环境
# java
bash ../rsync/rsync-file.sh www-data /data/service/java www-data /data/service/java ${TAGER_IP} ${TAGER_PORT}
bash ../rsync/rsync-file-sudo.sh www-data /etc/profile.d/java.sh www-data /etc/profile.d/ ${TAGER_IP} ${TAGER_PORT}
bash ../rsync/rsync-file.sh www-data /data/service/maven www-data /data/service/maven ${TAGER_IP} ${TAGER_PORT}
bash ../rsync/rsync-file-sudo.sh www-data /etc/profile.d/maven.sh www-data /etc/profile.d/ ${TAGER_IP} ${TAGER_PORT}
bash ../rsync/rsync-file.sh www-data /data/service/tomcat www-data /data/service/tomcat ${TAGER_IP} ${TAGER_PORT}
bash ../rsync/rsync-file-sudo.sh www-data /etc/init.d/tomcat8 www-data /etc/init.d/ ${TAGER_IP} ${TAGER_PORT}
bash ../rsync/rsync-file-sudo.sh www-data /etc/profile.d/tomcat.sh www-data /etc/profile.d/ ${TAGER_IP} ${TAGER_PORT}
# node
bash ../rsync/rsync-file.sh www-data /data/service/node www-data /data/service/node ${TAGER_IP} ${TAGER_PORT}
bash ../rsync/rsync-file-sudo.sh www-data /etc/profile.d/node.sh www-data /etc/profile.d/ ${TAGER_IP} ${TAGER_PORT}
# nodejs特出处理pm2
sshpass -p ${TAGER_ROOT_PASSWD} ssh -o StrictHostKeychecking=no root@${TAGER_IP} -p ${TAGER_PORT} "
npm install pm2 -g
"
# ng
bash ../rsync/rsync-file.sh www-data /data/service/nginx www-data /data/service/nginx ${TAGER_IP} ${TAGER_PORT}
bash ../rsync/rsync-file-sudo.sh www-data /etc/profile.d/nginx.sh www-data /etc/profile.d/ ${TAGER_IP} ${TAGER_PORT}
bash ../rsync/rsync-file-sudo.sh www-data /etc/init.d/nginx www-data /etc/init.d/ ${TAGER_IP} ${TAGER_PORT}
sshpass -p ${TAGER_ROOT_PASSWD} ssh -o StrictHostKeychecking=no root@${TAGER_IP} -p ${TAGER_PORT} "
# 设置开机启动
chkconfig nginx on

# 启动
service nginx start 

# 设置用户隶属于www-data用户组
usermod -aG www-data nginx
"

# docker
sshpass -p ${TAGER_ROOT_PASSWD} ssh -o StrictHostKeychecking=no root@${TAGER_IP} -p ${TAGER_PORT} " bash /root/centos-shell/docker/install-docker_last-centos7.sh "