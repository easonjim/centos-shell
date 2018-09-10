#!/bin/bash
#
# 自定义整合安装脚本，CentOS 7

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 初始化文件夹
sh ../directory/init-directory.sh

# 初始化防火墙
sh ../firewall/init-centos7.sh

# 初始化环境
sh ../init/init-centos7.sh

# 初始化www-data用户密码
WWW_DATA_PASSWD=`openssl rand -base64 32`
sh ../directory/init-www-data-passwd.sh ${WWW_DATA_PASSWD}
echo "www-data用户密码初始化完成："${WWW_DATA_PASSWD}

# 初始化ssh
sh ../ssh/clean-welcome.sh
sh ../ssh/edit-port.sh 50022
sh ../ssh/set-root-nologin.sh
