#!/bin/bash
#
# 自定义整合安装脚本，CentOS 7

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 可以提前设置变量
HOSTNAME=$1
PASSWD=$2
PORT=$3
if [[ ! -n $1 ]]; then
  export HOSTNAME="centos7"
fi
if [[ ! -n $2 ]]; then
  export PASSWD=`openssl rand -base64 32`
fi
if [[ ! -n $3 ]]; then
  export PORT="50022"
fi

# 初始化文件夹
bash ../directory/init-dir-business.sh

# 初始化防火墙
bash ../firewall/init-centos7.sh

# 初始化环境
bash ../init/init-centos7.sh
# rsync
bash ../rsync/install-rsync_3.1.3.sh

# 优化内核
bash ../kernel/init-sysctl.sh

# 初始化ssh
bash ../ssh/clean-welcome.sh
bash ../ssh/edit-port.sh ${PORT}
# 不允许root远程登录（不自动设置）
# bash ../ssh/set-root-nologin.sh

# 初始化hostname
bash ../hostname/init-hostname.sh ${HOSTNAME}

# 初始化www-data用户密码
bash ../directory/init-www-data-passwd.sh ${PASSWD}
echo "www-data用户密码初始化完成："${PASSWD}
